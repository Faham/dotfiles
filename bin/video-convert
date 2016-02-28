#!/bin/bash

out=${1##*/}
out=${out%%.*}
out_dir=$2
FFMPEG=~/dev/3rdparty/ffmpeg/ffmpeg

# ffmpeg configuration:
# ./configure --prefix=/usr/local --enable-gpl --enable-nonfree \
# --enable-libass --enable-libfdk-aac --enable-libfreetype --enable-libmp3lame --enable-libopus \
# --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265

$FFMPEG -i $1 \
  -c:v libx265 -preset medium -x265-params crf=23 \
  -c:a aac -strict experimental -b:a 128k \
  $out_dir$out.mp4
