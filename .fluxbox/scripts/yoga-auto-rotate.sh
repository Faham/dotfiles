#!/bin/bash
#
# yoga-auto-rotate -- ghetto-style tablet mode, with keyboard and all.
#
# Simple little script that will detect an orientation change for a
# Lenovo Yoga 13 (very hackily) and adjust the active display's
# orientation and disable/enable the touchpad as necessary.
#
# The Yoga 13 will emit keycode `e03e` at one second intervals
# when the screen is flipped into tablet mode. Since this keycode
# isn't actually mapped to anything by default, this script will
# use those events to determine if it should rotate the display or
# not.
#
# To make this work, the keycode that the system emits needs to be
# mapped first. You can pick a keycode to map it to via the `xmodmap -pk`
# command. The keycode mapping I used personally was `231`, for example:
#
#   setkeycodes e03e 231
#
# I run the above `setkeycodes` mapping command on start-up, and
# set an additional hotkey binding in my window manager to execute the
# `yoga-auto-rotate` script whenever the hotkey is pressed.
#
# It may be necessary to add the following commands to `/etc/sudoers`
# for your user or group, as `setkeycodes` and `input-events` may not
# allow it by default:
#
#   %users ALL=NOPASSWD: /usr/bin/setkeycodes, /usr/bin/input-events
#
# packages needed: easystroke, input-utils, onboard
#
# @author emiller
# @date 2013-09-08

input="Virtual core keyboard"
output="eDP1"
touchpad="SynPS/2 Synaptics TouchPad"

stub="/tmp/.yoga-tablet-watcher"
interval=2

function timestamp() {
  seconds=-1

  if [ -f $stub ]; then
    filemtime=`stat -c %Y $stub`
    currtime=`date +%s`
    seconds=$(( ($currtime - $filemtime) ))
  fi

  echo $seconds
}

function toggle_tablet() {
  orientation=`xrandr --properties | grep $output | cut -d ' ' -f4 | sed 's/(//g'`

  case $1 in
    enable)
      xrandr --output $output --rotate right
      xinput disable "$touchpad"
      which onboard && nohup onboard >/dev/null 2>&1 &
      which easystroke && nohup easystroke >/dev/null 2>&1 &
      ;;
    disable)
      xrandr --output $output --rotate normal
      which onboard && pkill -9 -f onboard
      which easystroke && pkill -9 -f easystroke
      xinput enable "$touchpad"
      ;;
  esac
}

function update_timer() {
  echo $(timestamp) > $stub
}

function clear_timer() {
  rm -f $stub
}

function watcher() {
  toggle_tablet "enable"
  update_timer

  sudo input-events -t $interval `xinput --list "$input" | head -n 1 | cut -d= -f2 | sed 's/\S*\[.*//g'`

  toggle_tablet "disable"
  clear_timer
}

test -f $stub || { watcher & }
