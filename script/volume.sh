#!/bin/bash

case $1 in
up)
    mixer_option='3%+';;
down)
    mixer_option='3%-';;
toggle)
    mixer_option='toggle';;
*)
    exit 1;;
esac

if [[ $mixer_option == 'toggle' ]]; then
    current_state=`amixer -c 1 get Master | egrep 'Playback.*?\[o' | egrep -o '\[o.+\]'`

    if [[ $current_state == '[on]' ]]; then
        amixer -c 1 -q set Master mute
    else
        amixer -c 1 -q set Master unmute
        amixer -c 1 -q set Speaker unmute
        amixer -c 1 -q set Headphone unmute
    fi
else
    amixer -c 1 -q sset Master $mixer_option > /dev/null
fi

volume_percent=$(amixer -c 1 get Master,0 | awk '/Mono:/ {print $4}' | tr -d '[]')
volume_mute=$(amixer -c 1 get Master,0 | awk '/Mono:/ {print $6}')

if [[ $volume_mute == '[off]' ]]; then
    volume_mute='[Mute]'
else
    volume_mute=''
fi

osd_pid='/tmp/osd-volume.pid'
osd_cmd="osd_cat \
  --shadow=1 --shadowcolour=#333333 --color=#FFFFFF \
  --pos=bottom --offset=30 --align=center \
  --lines=2 --delay=1 --barmode=percentage --percentage=$volume_percent"

if [[ -f $osd_pid ]]; then
    kill $(cat $osd_pid) 2> /dev/null;
fi

($osd_cmd --font="-*-dejavu sans-bold-r-*-*-32-*-*-*-*-*-*-*" --text="Master Volume: $volume_percent $volume_mute") &
echo $! > $osd_pid
