xrdb -I$HOME ~/.Xresources

# required linux packages for my setup
# fluxbox unclutter conky xscreensaver
# 

# i3 & wmpid=$!
fluxbox & wmpid=$!

# startup apps
xset r rate 200 40
xset +fp ~/.fonts
xsetroot -solid "#110011"
setxkbmap -model pc104 -layout us,ir -option grp:switch,grp:shift_toggle,grp_led:scroll
unclutter -idle 2 -jitter 10 -root & # hide cursor when idle
conky &
xscreensaver &
$TERM &
$BROWSER &
pcmanfm -d &
# xrandr --output VGA1 --auto --left-of DP2
# xrandr --output DP2 --primary
# nm-applet &
# goldendict &
# synergy &
# thunderbird &

echo "this is a test\nthis is a test\nthis is a test\nthis is a test" > /tmp/aes.ecb

wait $wmpid
