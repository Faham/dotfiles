#!/bin/bash

# Configurable variables for text positioning in video
# Adjust these to change the position of the text overlay in the video
# X position: 'main_w - overlay_w' for right-aligned, add/subtract pixels if needed (e.g., 'main_w - overlay_w - 10')
TEXT_OVERLAY_X='main_w - overlay_w - 50'
# Y position: This places it in the lower 25%, centered within that area
# main_h * 0.75 is the start of the lower 25%, then center the overlay height within the remaining 25%
TEXT_OVERLAY_Y='main_h * 0.75 + (main_h * 0.25 - overlay_h)/2 - 100'

# Configurable variable for text overlay background shade
TEXT_OVERLAY_BACKGROUND='rgba(0,0,0,0.5)'

# Configurable variables for thumbnail
BAND_HEIGHT=150
BAND_Y_FRACTION=0.75  # Fraction of video height where the band starts (0.75 for lower 25%)
FONTSIZE_TITLE=32
TITLE_OVERLAY_X='main_w - overlay_w - 10'  # Adjust margin from right
TITLE_MARGIN_RIGHT=10  # Margin for title from right edge

# Check if enough arguments are provided (at least video, text_file, title_text, output)
if [ "$#" -lt 4 ]; then
    echo "Usage: $0 <video_file> <text_file> <title_text> [audio_file1 ...] <output_file>"
    exit 1
fi

# Input files from command line
VIDEO="$1"
TEXT_FILE="$2"
TITLE="$3"
shift 3

# Collect all audio files (all args except the last one)
AUDIOS=()
while [ "$#" -gt 1 ]; do
    AUDIOS+=("$1")
    shift
done

# Last argument is output
OUTPUT="$1"

# Check if video file exists
if [ ! -f "$VIDEO" ]; then
    echo "Error: Video file not found: $VIDEO"
    exit 1
fi

# Check if audio files exist (if provided)
for audio in "${AUDIOS[@]}"; do
    if [ ! -f "$audio" ]; then
        echo "Error: Audio file not found: $audio"
        exit 1
    fi
done

# Get video duration, width, and height
V_DUR=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$VIDEO")
VIDEO_WIDTH=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 "$VIDEO")
VIDEO_HEIGHT=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=noprint_wrappers=1:nokey=1 "$VIDEO")

# If audio is provided, generate the video
if [ ${#AUDIOS[@]} -gt 0 ]; then
    # Get total audio duration by summing individual durations
    A_DUR=0
    for audio in "${AUDIOS[@]}"; do
        dur=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$audio")
        A_DUR=$(echo "scale=6; $A_DUR + $dur" | bc)
    done

    # Compute sped-up audio duration and adjustment factors
    NEW_A_DUR=$(echo "scale=6; $A_DUR / 1.5" | bc)
    PTS_FACTOR_CALC=$(echo "scale=6; $NEW_A_DUR / $V_DUR" | bc)

    # Cap the slowness (PTS factor) to 4 (equivalent to 0.25x speed)
    if [ $(echo "$PTS_FACTOR_CALC > 4" | bc) -eq 1 ]; then
        USE_LOOP=1
        PTS_FACTOR=4
    else
        USE_LOOP=0
        PTS_FACTOR="$PTS_FACTOR_CALC"
    fi

    # Determine if slowing down the video (PTS_FACTOR > 1) for frame interpolation
    if [ $(echo "$PTS_FACTOR > 1" | bc) -eq 1 ]; then
        VIDEO_FILTER="[0:v]minterpolate=fps=120:mi_mode=mci,setpts=$PTS_FACTOR*PTS[v]"
    else
        VIDEO_FILTER="[0:v]setpts=$PTS_FACTOR*PTS[v]"
    fi

    # Build audio filter for concatenation and speed-up
    NUM_AUDIOS=${#AUDIOS[@]}
    if [ $NUM_AUDIOS -eq 1 ]; then
        AUDIO_FILTER="[1:a]atempo=1.5[a]"
    else
        CONCAT_PART=""
        for i in $(seq 1 $NUM_AUDIOS); do
            CONCAT_PART="$CONCAT_PART[${i}:a]"
        done
        AUDIO_FILTER="${CONCAT_PART}concat=n=${NUM_AUDIOS}:v=0:a=1[concat_a];[concat_a]atempo=1.5[a]"
    fi

    # Prepare text PNG for video overlay with ImageMagick
    MAX_TEXT_WIDTH=$(echo "scale=0; ($VIDEO_WIDTH * 0.7)/1" | bc)
    MAX_TEXT_HEIGHT=$VIDEO_HEIGHT  # Tall enough to allow wrapping without clipping
    FONTSIZE=24
    if command -v fc-match >/dev/null 2>&1; then
        FONT_PATH=$(fc-match -f '%{file}' 'Sans:lang=fa')
    else
        FONT_PATH="/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"  # Fallback
    fi
    TEMP_TEXT=$(mktemp)
    if [ -f "$TEXT_FILE" ]; then
        cp "$TEXT_FILE" "$TEMP_TEXT"
    else
        echo -e "$TITLE" > "$TEMP_TEXT"
    fi
    TEMP_PNG=$(mktemp --suffix=.png)
    magick -size "${MAX_TEXT_WIDTH}x${MAX_TEXT_HEIGHT}" -background "${TEXT_OVERLAY_BACKGROUND}" -font "${FONT_PATH}" -pointsize ${FONTSIZE} -gravity East -fill white caption:@"${TEMP_TEXT}" -trim +repage "${TEMP_PNG}"

    # Overlay filter for video: overlay the PNG according to configurable positions
    OVERLAY_INDEX=$((NUM_AUDIOS + 1))
    OVERLAY_FILTER="[v][${OVERLAY_INDEX}:v]overlay=x='${TEXT_OVERLAY_X}':y='${TEXT_OVERLAY_Y}'[v]"

    # Build FFmpeg input arguments as an array for video processing
    INPUTS=()
    if [ "$USE_LOOP" -eq 1 ]; then
        INPUTS+=("-stream_loop" "-1")
    fi
    INPUTS+=("-i" "$VIDEO")
    for audio in "${AUDIOS[@]}"; do
        INPUTS+=("-i" "$audio")
    done
    INPUTS+=("-i" "${TEMP_PNG}")

    # Run FFmpeg to generate the video (drops video's original audio; re-encodes video due to speed change)
    ffmpeg "${INPUTS[@]}" -filter_complex "$AUDIO_FILTER;$VIDEO_FILTER;$OVERLAY_FILTER" -map "[v]" -map "[a]" -c:v libx264 -crf 18 -c:a aac -shortest "$OUTPUT"

    # Cleanup video temp file
    rm "${TEMP_PNG}" "${TEMP_TEXT}"
fi

# Now generate thumbnail (always, regardless of audio)
TEMP_SCREENSHOT=$(mktemp --suffix=.png)
# Extract screenshot at 1 second (adjust -ss if needed)
ffmpeg -i "$VIDEO" -ss 1 -vframes 1 "$TEMP_SCREENSHOT" -y

# Calculate band position
BAND_Y=$(echo "scale=0; $VIDEO_HEIGHT * $BAND_Y_FRACTION / 1" | bc)

# Create dark transparent band PNG
TEMP_BAND=$(mktemp --suffix=.png)
magick -size "${VIDEO_WIDTH}x${BAND_HEIGHT}" xc:'rgba(0,0,0,0.5)' "${TEMP_BAND}"

# Composite band onto screenshot
TEMP_COMPOSITE=$(mktemp --suffix=.png)
magick "${TEMP_SCREENSHOT}" "${TEMP_BAND}" -geometry +0+${BAND_Y} -composite "${TEMP_COMPOSITE}"

# Prepare title PNG with ImageMagick (assuming title is a string, wrap if needed)
TEMP_TITLE_FILE=$(mktemp)
echo -e "${TITLE}" > "${TEMP_TITLE_FILE}"
MAX_TITLE_WIDTH=$(echo "scale=0; ($VIDEO_WIDTH * 0.9)/1" | bc)  # Wider for title
TEMP_TITLE_PNG=$(mktemp --suffix=.png)
magick -size "${MAX_TITLE_WIDTH}x${VIDEO_HEIGHT}" -background none -font "${FONT_PATH}" -pointsize ${FONTSIZE_TITLE} -gravity East -fill white caption:@"${TEMP_TITLE_FILE}" -trim +repage "${TEMP_TITLE_PNG}"

# Composite title onto the composite (centered vertically on the band)
TITLE_OVERLAY_Y="${BAND_Y} + (${BAND_HEIGHT} - overlay_h)/2"
ffmpeg -i "${TEMP_COMPOSITE}" -i "${TEMP_TITLE_PNG}" -filter_complex "overlay=x='${TITLE_OVERLAY_X}':y='${TITLE_OVERLAY_Y}'" "${OUTPUT%.*}_thumbnail.png" -y

# Cleanup thumbnail temp files
rm "${TEMP_SCREENSHOT}" "${TEMP_BAND}" "${TEMP_COMPOSITE}" "${TEMP_TITLE_FILE}" "${TEMP_TITLE_PNG}"
