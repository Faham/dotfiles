#!/bin/sh

if [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]]; then
     exec startx -- -ardelay 170 -arinterval 70
fi
