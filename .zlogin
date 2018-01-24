#!/bin/sh
#
# ~/.zlogin
#

if [ -e /usr/share/terminfo/x/xterm-256color ]; then
   export TERM='xterm-256color'
else
   export TERM='xterm-color'
fi

export PATH="$PATH:$HOME/.scripts"
export BROWSER=google-chrome-stable
export EDITOR=vim
export TERM_EMU=xterm
export SHELL=/usr/bin/zsh
export FILES=pcmanfm
export PLAYER=vlc
export VISUAL="vim"

[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx -- -ardelay 170 -arinterval 70

