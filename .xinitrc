
[ -f ~/.Xresources ] && xrdb -merge -I$HOME ~/.Xresources

# required linux packages for my setup
# fluxbox unclutter conky xscreensaver
# 

# i3 & wmpid=$!
fluxbox & wmpid=$!

[ -f /etc/xprofile ] && source /etc/xprofile
[ -f ~/.xprofile ] && source ~/.xprofile

wait $wmpid
