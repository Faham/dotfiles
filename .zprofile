#!/bin/sh

if [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]]; then
     # remove exec to remain logged in when the X session ends
     # exec startx -- -ardelay 170 -arinterval 70
     startx -- -ardelay 170 -arinterval 50
fi
