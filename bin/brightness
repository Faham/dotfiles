#!/bin/sh

device=/sys/class/backlight/intel_backlight
cur=`cat $device/brightness`
max=`cat $device/max_brightness`
diff=$1
val=$(($cur+$diff))

if [[ "$val" -gt "$max" ]]; then
    val=$max
elif [[ "$val" -lt "0" ]]; then
    val=0
fi

echo $val | sudo tee $device/brightness
# xbacklight -dec 10
# xbacklight -inc 10

percent=$(($val * 100 / $max))

osd_pid='/tmp/osd-brightness.pid'
osd_cmd="osd_cat \
  --shadow=1 --shadowcolour=#333333 --color=#FFFFFF \
  --pos=bottom --offset=30 --align=center \
  --lines=2 --delay=1 --barmode=percentage --percentage=$percent"

if [[ -f $osd_pid ]]; then
    kill $(cat $osd_pid) 2> /dev/null;
fi

($osd_cmd --font="-*-dejavu sans-bold-r-*-*-32-*-*-*-*-*-*-*" --text="Brightness: $percent") &
echo $! > $osd_pid
