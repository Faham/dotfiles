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
xrandr --output VGA1 --auto --left-of DP2
xrandr --output DP2 --primary
unclutter -idle 2 -jitter 10 -root & # hide cursor when idle
echo "this is a test\nthis is a test\nthis is a test\nthis is a test" > /tmp/aes.ecb

export BROWSER=google-chrome
export EDITOR=subl
export TERM=terminator

wait $wmpid