# personal-linux-config

after pulling the repo do the followings

git submodule update --init --recursive

install the required packages:

sudo pacman -S fluxbox xosd terminator zsh pcmanfm vlc \
unclutter conky xscreensaver goldendict yaourt xdotool \
xterm bashrun git vim xorg-server xorg-apps xorg-server-utils \
xf86-video-intel mesa-libgl xorg-xinit ttf-dejavu htop openssh \
wget pulseaudio cmake evince ctags gpicview zip unzip

then:
~/bin/config-machine

yaourt -S google-chrome subl-text-dev viber

then go to .vim/bundle/YouCompleteMe and run ./install.py
