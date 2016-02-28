#!/bin/sh

DISPLAY_0=eDP1
DISPLAY_1=HDMI1

if [[ 'connected' == `xrandr --query | grep "$DISPLAY_1" | cut -d' ' -f2` ]]; then
    xrandr --auto --output $DISPLAY_1 --right-of $DISPLAY_0 --primary
    echo "extended to two screens"
else
    xrandr --auto --output $DISPLAY_0 --primary
fi
