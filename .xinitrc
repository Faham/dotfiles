#!/bin/sh

for file in "/etc/profile" "$HOME/.profile" "/etc/xprofile" "$HOME/.xprofile"; do
    if [ -f "$file" ]; then
        . "$file"
    fi
done

for file in "/etc/X11/Xresources" "$HOME/.Xresources"; do
    if [ -f "$file" ]; then
        xrdb -merge "$file"
    fi
done

# Optional: Load xmodmap if not using XKB (deprecated; comment if using setxkbmap)
# if [ -z "$XKB_IN_USE" ]; then
#     for file in "/etc/X11/Xmodmap" "$HOME/.Xmodmap"; do
#         if [ -f "$file" ]; then
#            # echo "Loading modmap: $file" >> ~/.xinitrc.log
#            xmodmap "$file"
#         fi
#     done
# fi
# unset XKB_IN_USE

# Run all system xinitrc shell scripts
xinitdir="/etc/X11/xinit/xinitrc.d"
if [ -d "$xinitdir" ]; then
    for script in $xinitdir/*; do
        # echo "Loading xinit script $script" >> ~/.xinitrc.log
        if [ -x "$script" -a ! -d "$script" ]; then
            . "$script"
        fi
    done
fi

# Run user xsession shell script
script="$HOME/.xsession"
if [ -x "$script" -a ! -d "$script" ]; then
    # echo "Loading xsession script $script" >> ~/.xinitrc.log
    . "$script"
fi

# Optional: Start redshift in background (install with sudo pacman -S redshift; adjust location)
# if command -v redshift >/dev/null 2>&1; then
#     redshift -l 49.197168:-123.004449 &  # Use your lat:long from .xprofile
# fi

# Optional: Start compositor or other daemons (e.g., for i3)
# if command -v picom >/dev/null 2>&1; then
#     picom &
# fi

if command -v i3 >/dev/null 2>&1; then
    exec /usr/bin/i3
else
    echo "Error: i3 not found. Install with sudo pacman -S i3" >&2
    exit 1
fi
