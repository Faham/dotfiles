#!/bin/sh

[ -f ~/.Xresources ] && xrdb -merge -I$HOME ~/.Xresources

xbindkeys

# i3 & wmpid=$!
fluxbox & wmpid=$!

[ -f /etc/xprofile ] && source /etc/xprofile
[ -f ~/.xprofile ] && source ~/.xprofile

wait $wmpid
