#
# ~/.zlogin
#

export TERM_EMU=terminator
export BROWSER=google-chrome-stable
export EDITOR=subl
export FILES=pcmanfm
export PLAYER=vlc

[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx
