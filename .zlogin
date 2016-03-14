#
# ~/.zlogin
#

export TERM=terminator
export BROWSER=google-chrome-stable
export EDITOR=subl

[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx
