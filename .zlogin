#
# ~/.zlogin
#

export PATH="$PATH:$HOME/.scripts"
# export MANPATH="/usr/local/man:$MANPATH"
export BROWSER=google-chrome-stable
export EDITOR=subl
export TERM_EMU=xterm
export SHELL=/usr/bin/zsh
export FILES=pcmanfm
export PLAYER=vlc
export VISUAL="vim"

[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx
