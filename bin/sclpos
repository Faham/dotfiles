#!/bin/sh

SLEEP_BF_SCALE=7

VIDEO_W=640
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
