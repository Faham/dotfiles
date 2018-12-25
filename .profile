#!/bin/sh

if [ -e /usr/share/terminfo/r/rxvt-unicode-256color ]; then
   export TERM='rxvt-unicode-256color'
else
   export TERM='rxvt-color'
fi
