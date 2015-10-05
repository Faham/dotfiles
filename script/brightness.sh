#!/bin/sh

device=/sys/class/backlight/intel_backlight
cur=`cat $device/brightness`
max=`cat $device/max_brightness`
diff=$1
val=$(($cur+$diff))

echo $val | sudo tee $device/brightness
# echo $val
