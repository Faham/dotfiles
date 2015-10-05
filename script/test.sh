#!/bin/sh

#-----------------------------------------------------------------------------

# DISP=wayland  # only works for gst-launch
DISP=x11

NUM_INSTANCE=2
NUM_STREAM_PER_INSTANCE=3

# APP=mmfd
APP=gst-launch-1.0

OP="exec"
# OP="echo"

AUDIO=true # only works for 3 pipes per instance for gst-launch
INTERLEAVE="interleave2"

# SRC="filesrc"
# SRC="virtual_udpsrc"
SRC="udpsrc"

MULTIQUEUE=false
QUEUE_BEFORE_VIDEOSINK=true # when set to false around 5% improvement on bitstream

MMFD_PATH=~/dev/penderwood/4X_Atom/target_src/bin/mmfd/src
# MMFD_PATH=~

#-----------------------------------------------------------------------------

# GST_DEBUG_COLOR_MODE=off
# GST_DEBUG=vaapidecode:7
# GST_DEBUG=vecima_mmfd:9
# GST_DEBUG=*vaapi*:1

#-----------------------------------------------------------------------------

WM_POS_SCL=true
SLEEP_BF_SCALE=7

VIDEO_W=640
# VIDEO_H=380
VIDEO_H=480
VIDEO_SCALE=1

DISPLAY_W=2560
DISPLAY_H=1425
POS_OFFSET_TOP=0
POS_OFFSET_LEFT=0

CONVERGE_X=0
CONVERGE_Y=0
VIDEO_ROW=3
VIDEO_COL=4

DOT_DIAGRAM=false

#-----------------------------------------------------------------------------

if [ "filesrc" = $SRC ] || [ "virtual_udpsrc" = $SRC ]; then

  # FILE=/media/fahamne/b640a999-ea4d-4f34-b550-aa94fa237db5/CooChaHD_HD__110.165_060115_172700.ts
  # FILE=~/test-streams/cox-pc1608/../../Comcast/AVCHDIP2.ts
  # FILE=~/test-streams/STARZ_HD_MPEG4_cleaned.ts
  # FILE=/media/fahamne/KINGSTON/TC600E_captures/FOX_NEWS_HD_MPEG2_cleaned.ts
  FILE=/media/fahamne/KINGSTON/CooChaHD_HD__110.165_060115_172700.ts
  TYPE=h264
  PRG_NUM=1

  if [ "virtual_udpsrc" = $SRC ]; then
    gst-launch-1.0 \
      filesrc location=$FILE ! \
      tsparse set-timestamps=true smoothing-latency=10 ! udpsink host=224.1.1.1 port=5000 auto-multicast=true &
    TYPE=h264
    IP=224.1.1.1
    PORT=5000
    PRG_NUM=1
  fi

elif [ "udpsrc" = $SRC ]; then
  # gbe_verizon mpeg2 MPTS
  # TYPE=mpeg2
  # IP=239.6.60.1
  # PORT=6100
  # PRG_NUM=7

  # avengers 1080p29.97 mpeg2 SPTS (DP2_010_Avengers_MPEG2_15min_1080p_17-25Mbps_VBR.m2t_05)
  # TYPE=mpeg2
  # IP=239.4.4.1
  # PORT=4000
  # PRG_NUM=1

  # avengers 1080i29.97 mpeg2 SPTS (DP2_010_Avengers_MPEG2_15min_1080p_17-25Mbps_VBR.m2t_05)
  TYPE=mpeg2
  IP=239.7.7.82
  PORT=10000
  PRG_NUM=1

  # batman 1080p29.97 SPTS (DP2_009_DK_1080p_h264_5_minutes.ts_05)
  # TYPE=h264
  # IP=239.6.6.5
  # PORT=6000
  # PRG_NUM=1

  # batman 1080i29.97 SPTS (NC_005_2-1_DK_9Mbps_CBR_h264_High_4-0_1920x1080i_DAR-16x9_PAR-1x1_29-97fps.ts)
  # TYPE=h264
  # IP=239.8.8.14
  # PORT=10000
  # PRG_NUM=1

  ############## COX CONTENTS ##############
  # cox 1080i29.97 7.5Mbps SPTS (PW_07_COX_CooChaHD_HD__110.165_060115_172700)
  # TYPE=h264
  # IP=239.4.4.24
  # PORT=10000
  # PRG_NUM=1

  # cox 1080i29.97 7.5Mbps SPTS (PW_08_COX_UNISPONETHD_HD__110.108_060115_171200)
  # TYPE=h264
  # IP=239.4.4.25
  # PORT=10000
  # PRG_NUM=1

  # cox 1080i29.97 6.5Mbps MPTS (PW_01_COX_DIYHD_HD__115.4_080115_103900_01)
  # TYPE=h264
  # IP=239.4.4.23
  # PORT=10000
  # PRG_NUM=3

  # cox 720p59.54 5.5Mbps MPTS (PW_01_COX_DIYHD_HD__115.4_080115_103900_01)
  # TYPE=h264
  # IP=239.4.4.23
  # PORT=10000
  # PRG_NUM=1

  ############## TIME WARNER CONTENTS ##############
  # AMC_SD_MPEG2_cleaned.ts
  # TYPE=mpeg2
  # IP=239.4.4.30
  # PORT=10000

  # CINEMAX_HD_MPEG4_cleaned.ts
  # TYPE=mpeg2
  # IP=239.4.4.31
  # PORT=10000

  # CNBC_HD_MPEG2_cleaned.ts
  # TYPE=mpeg2
  # IP=239.4.4.32
  # PORT=10000

  # CNBC_HD_MPEG2_cleaned.ts
  # TYPE=mpeg2
  # IP=239.3.3.4
  # PORT=3000

  # CNN_HD_MPEG2_cleaned.ts
  # TYPE=mpeg2
  # IP=239.4.4.33
  # PORT=10000

  # FOX_NEWS_HD_MPEG2_cleaned.ts
  # TYPE=mpeg2
  # IP=239.4.4.34
  # PORT=10000
  # PRG_NUM=1

  # FOX_NEWS_HD_MPEG2_cleaned.ts
  # TYPE=mpeg2
  # IP=239.3.3.8
  # PORT=3000

  # HBO_HD_MPEG4_cleaned.ts
  # TYPE=mpeg2
  # IP=239.4.4.35
  # PORT=10000

  # STARZ_COMEDY_HD_MPEG4_cleaned.ts
  # TYPE=mpeg2
  # IP=239.4.4.36
  # PORT=10000

  # STARZ_COMEDY_HD_MPEG4_cleaned.ts
  # TYPE=mpeg2
  # IP=239.3.3.4
  # PORT=3000

  # STARZ_HD_MPEG4_cleaned.ts
  # TYPE=mpeg2
  # IP=239.4.4.37
  # PORT=10000

  # STARZ_HD_MPEG4_cleaned.ts
  # TYPE=mpeg2
  # IP=239.3.3.7
  # PORT=3000

  # TBS_SD_MPEG2_cleaned.ts
  # TYPE=mpeg2
  # IP=239.4.4.38
  # PORT=10000

  # TNT_SD_MPEG2_cleaned.ts
  # TYPE=mpeg2
  # IP=239.4.4.39
  # PORT=10000
fi

#-----------------------------------------------------------------------------

QUEUE="queue max-size-bytes=0 max-size-buffers=0 max-size-time=10000000000"

VAAPI_POST_PROC="vaapipostproc \
scale-method=hq \
width=$VIDEO_W \
height=$VIDEO_H \
deinterlace-mode=disabled \
format=nv12 \
"
# format=i420 \
# force-aspect-ratio=true \
# deinterlace-method=none \

DEINTERLACE="deinterlace mode=disabled"
VIDEORATE="videorate ! video/x-raw,framerate=30/1"

if [ "filesrc" = $SRC ]; then
  SRC_ELEM="filesrc location=$FILE"
else
  # SRC_ELEM="udpsrc address=$IP port=$PORT"
  SRC_ELEM="udpsrc address=$IP port=$PORT buffer-size=2147483647 blocksize=100000"
fi

PARSER="unknown"
if [ $TYPE = 'h264' ]; then
  # PARSER="h264parse"
  PARSER="vaapiparse_h264"
elif [ $TYPE = 'mpeg2' ]; then
  PARSER="mpegvideoparse"
fi

# POST_DECODE="$VAAPI_POST_PROC ! $QUEUE ! $VIDEORATE ! "
# POST_DECODE="$QUEUE ! $VIDEORATE ! "
# POST_DECODE="$VAAPI_POST_PROC ! "
# POST_DECODE="$DEINTERLACE ! "
# PRE_DECODE="video/x-h264,stream-format=avc,alignment=au ! "

# DECODER=avdec_h264
DECODER=vaapidecode

ARGS_HEAD=
ARGS_BODY=

SINK="vaapisink display=$DISP"
# SINK="fakesink"

#-----------------------------------------------------------------------------

add_pipeline() {
  pipe_id=$1
  video_q="$QUEUE name=q_videoparse_${pipe_id}"
  int_1="int.sink_$(( ${pipe_id}*2-2 ))"
  int_2="int.sink_$(( ${pipe_id}*2-1 ))"
  video_sink_q="$QUEUE name=q_videosink_${pipe_id} !"

  if [ $QUEUE_BEFORE_VIDEOSINK = false ]; then
    video_sink_q=
  fi

  if [ $MULTIQUEUE = true ]; then
    ARGS_HEAD="$ARGS_HEAD
    multiqueue max-size-bytes=0 max-size-buffers=2 max-size-time=10000000000 name=mq${pipe_id}"
    video_q="mq${pipe_id}.sink_0 mq${pipe_id}.src_0"
    int_1="mq${pipe_id}.sink_1 mq${pipe_id}.src_1 ! ${int_1}"
    int_2="mq${pipe_id}.sink_2 mq${pipe_id}.src_2 ! ${int_2}"
  fi

  ARGS_BODY="$ARGS_BODY
    $SRC_ELEM name=udpsrc${pipe_id} ! $QUEUE name=q_tsdemux_${pipe_id} ! tsdemux name=dmx${pipe_id} program-number=$PRG_NUM
      dmx${pipe_id}. ! $PARSER ! $PRE_DECODE ${video_q} ! $DECODER name=vaapidecode_${pipe_id} ! $POST_DECODE ${video_sink_q} $SINK"
  if [ $AUDIO = true ]; then
    ARGS_BODY="$ARGS_BODY
      dmx${pipe_id}. ! identity ! ac3parse ! a52dec mode=stereo ! audioconvert ! audioresample sinc-filter-mode=full quality=3 ! audio/x-raw, format=S16LE, rate=44000 ! deinterleave name=dei${pipe_id}
      dei${pipe_id}. ! identity ! ${int_1}
      dei${pipe_id}. ! identity ! ${int_2}
    "
  fi
}

#-----------------------------------------------------------------------------

if [ $APP = 'gst-launch-1.0' ]; then

#-----------------------------------------------------------------------------

if [ $AUDIO = true ]; then
  ARGS_HEAD="
    $INTERLEAVE name=int ! capssetter caps=audio/x-raw,channels=(int)6,channel-mask=(bitmask)0x000000000000003f ! $QUEUE name=q_audiosink ! autoaudiosink"
fi

for i in $(seq 1 $NUM_STREAM_PER_INSTANCE); do
  add_pipeline $i
done

ARGS="
  $ARGS_HEAD
  $ARGS_BODY
"

if [ $OP = "exec" ]; then
  for i in $(seq 1 $NUM_INSTANCE); do
    gst-launch-1.0 $ARGS &
  done
elif [ $OP = "echo" ]; then
  echo "$ARGS"
fi

#-----------------------------------------------------------------------------

elif [ $APP = 'mmfd' ]; then

#-----------------------------------------------------------------------------

IP_ADDRESS_LIST=
PORT_LIST=

for i in $(seq 1 $NUM_STREAM_PER_INSTANCE); do
  IP_ADDRESS_LIST="$IP_ADDRESS_LIST $IP"
  PORT_LIST="$PORT_LIST $PORT"
done

CONFIG_FILE="-config /home/fahamne/dev/penderwood/4X_Atom/target_src/bin/mmfd/src/mmfd.cfg"
ARGS="-foreground $CONFIG_FILE"
# ARGS="-foreground -nums $NUM_STREAM_PER_INSTANCE -ipaddresslist $IP_ADDRESS_LIST -portlist $PORT_LIST"
# ARGS=" -ipaddresslist $IP_ADDRESS_LIST -portlist $PORT_LIST"
# ARGS="-foreground -ipaddresslist 239.1.1.1 239.1.1.1 239.1.1.1 239.1.1.1 -portlist 1000 1000 1000 1000 -nums 4 "
# ARGS="-foreground -config $CONFIG_FILE -portlist 10000 10000 10000 -ipaddresslist 239.4.4.24 239.4.4.24 239.4.4.24"

if [ $OP = "exec" ]; then
  for i in $(seq 0 $(( $NUM_INSTANCE - 1 )) ); do
    $MMFD_PATH/mmfd $i $ARGS &
    sleep 0.01 # to flush the buffer
  done
elif [ $OP = "echo" ]; then
  echo 0 $ARGS
fi


#-----------------------------------------------------------------------------

fi

#-----------------------------------------------------------------------------

if [ $WM_POS_SCL = true ] && [ $OP = "exec" ]; then
  sleep $SLEEP_BF_SCALE
  VIDEO_W=$( echo "scale=0; $VIDEO_W * $VIDEO_SCALE / 1" | bc )
  VIDEO_H=$( echo "scale=0; $VIDEO_H * $VIDEO_SCALE / 1" | bc )
  j=0
  k=0
  for i in `wmctrl -l -p | grep N/A | cut -c1-10`; do
    top="$(( POS_OFFSET_TOP + $j * ($VIDEO_H - $CONVERGE_Y) ))"
    left="$(( POS_OFFSET_LEFT + $k * ($VIDEO_W - $CONVERGE_X) ))"
    wmctrl -i -r $i -e 0,$left,$top,$VIDEO_W,$VIDEO_H;

    j="$(( $j + 1 ))"
    if [ $j -ge $VIDEO_ROW ]; then
      j=0
      k="$(( $k + 1 ))"
      if [ $k -ge $VIDEO_COL ]; then
        k=0
      fi
    fi
  done;
fi

#-----------------------------------------------------------------------------

if [ $DOT_DIAGRAM = true ] && [ $OP = "exec" ]; then
  sleep 5;
  DOT_FILE=`ls -clta /tmp/*PLAYING.dot | head -1 | awk '{print $9}'`
  OUT_FILE=${DOT_FILE%.*}
  OUT_FILE=${OUT_FILE##*/}.png
  dot -Tpng $DOT_FILE -o $OUT_FILE
  gnome-open $OUT_FILE
fi

#-----------------------------------------------------------------------------

# debugging/monitoring commands:
# top -Hid1
# watch -n1 'cat /proc/interrupts | grep "CPU\|107:"'      interrupts per core stat
# procinfo -n1                                             interrupts stat
# watch -n1 'mpstat -I SUM -P ALL'                         multi-process statu
# perf stat ./appname                                      measure cache misses
# perf stat -a sleep 30
# perf stat -a -e cache-misses timeout 30
# perf record -a -F 97 --call-graph dwarf -o mmfd.data -- sleep 30
# perf report -g graph -i mmfd.data
# perf timechart record -a -o 1proc.data timeout 30
# for i in `seq 0 1`; do ./mmfd $i -config ./mmfd.cfg 2> /dev/null; done;
#-----------------------------------------------------------------------------
