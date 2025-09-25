#!/bin/bash

# Initialize the package list variable
PACKAGES=""

# 7zip - A file archiver with high compression ratio
PACKAGES+=" 7zip"

# acpi - Shows battery status and other ACPI information
PACKAGES+=" acpi"

# alsa-utils - Utilities for configuring and using ALSA sound
PACKAGES+=" alsa-utils"

# base - Minimal package set to define a basic Arch Linux installation
PACKAGES+=" base"

# base-devel - Basic tools to build Arch Linux packages
PACKAGES+=" base-devel"

# bluez - Bluetooth protocol stack and tools
PACKAGES+=" bluez"

# brightnessctl - Utility to control display brightness
PACKAGES+=" brightnessctl"

# dmenu - Dynamic menu for X
PACKAGES+=" dmenu"

# downgrade - Downgrade installed packages
PACKAGES+=" downgrade"

# efibootmgr - Tool to manage UEFI boot entries
PACKAGES+=" efibootmgr"

# eza - A modern replacement for ls
PACKAGES+=" eza"

# feh - Lightweight image viewer
PACKAGES+=" feh"

# fzf - Command-line fuzzy finder
PACKAGES+=" fzf"

# ghostscript - Interpreter for PostScript and PDF
PACKAGES+=" ghostscript"

# gimp - GNU Image Manipulation Program
PACKAGES+=" gimp"

# git - Distributed version control system
PACKAGES+=" git"

# google-chrome - The popular web browser by Google
PACKAGES+=" google-chrome"

# grub - GRand Unified Bootloader
PACKAGES+=" grub"

# gvfs-mtp - Virtual filesystem for MTP devices
PACKAGES+=" gvfs-mtp"

# htop - Interactive process viewer
PACKAGES+=" htop"

# i3-wm - Improved tiling window manager
PACKAGES+=" i3-wm"

# i3blocks - Define blocks for i3bar
PACKAGES+=" i3blocks"

# i3lock - Improved screen locker
PACKAGES+=" i3lock"

# i3status - Generates status bar for i3bar
PACKAGES+=" i3status"

# imagemagick - Image manipulation tools
PACKAGES+=" imagemagick"

# intel-gpu-tools - Tools for debugging Intel GPUs
PACKAGES+=" intel-gpu-tools"

# intel-media-driver - Intel Media Driver for VAAPI
PACKAGES+=" intel-media-driver"

# jdk17-openjdk - OpenJDK Java 17 development kit
PACKAGES+=" jdk17-openjdk"

# jq - Command-line JSON processor
PACKAGES+=" jq"

# libva-utils - Collection of utilities for VAAPI
PACKAGES+=" libva-utils"

# man-db - Tools for reading manual pages
PACKAGES+=" man-db"

# masterpdfeditor-free - PDF editor with a free version
PACKAGES+=" masterpdfeditor-free"

# mesa-utils - Tools for Mesa 3D graphics library
PACKAGES+=" mesa-utils"

# mplayer - Media player
PACKAGES+=" mplayer"

# mtpfs - FUSE filesystem for MTP devices
PACKAGES+=" mtpfs"

# mupdf - Lightweight PDF and XPS viewer
PACKAGES+=" mupdf"

# neovim - Hyperextensible Vim-based text editor
PACKAGES+=" neovim"

# networkmanager - Network connection manager
PACKAGES+=" networkmanager"

# noto-fonts-emoji - Google Noto emoji fonts
PACKAGES+=" noto-fonts-emoji"

# npm - Node.js package manager
PACKAGES+=" npm"

# openssh - SSH connectivity tools
PACKAGES+=" openssh"

# pavucontrol - PulseAudio volume control
PACKAGES+=" pavucontrol"

# pcmanfm - File manager with tab support
PACKAGES+=" pcmanfm"

# pipewire - Server and user space API for handling multimedia
PACKAGES+=" pipewire"

# pyright - Static type checker for Python
PACKAGES+=" pyright"

# python-certifi - Python package for providing Mozilla's CA Bundle
PACKAGES+=" python-certifi"

# python-pip - Python package installer
PACKAGES+=" python-pip"

# rofi - Window switcher and application launcher
PACKAGES+=" rofi"

# rsync - Fast file transfer program
PACKAGES+=" rsync"

# rxvt-unicode - Unicode-enabled rxvt-clone terminal emulator
PACKAGES+=" rxvt-unicode"

# scrot - Command-line screen capture utility
PACKAGES+=" scrot"

# sof-firmware - Sound Open Firmware
PACKAGES+=" sof-firmware"

# sxiv - Simple X Image Viewer
PACKAGES+=" sxiv"

# telegram-desktop - Official Telegram Desktop client
PACKAGES+=" telegram-desktop"

# tlp - Power management for Linux
PACKAGES+=" tlp"

# tmux - Terminal multiplexer
PACKAGES+=" tmux"

# ttf-dejavu - DejaVu fonts
PACKAGES+=" ttf-dejavu"

# ttf-font-awesome - Iconic font designed for Bootstrap
PACKAGES+=" ttf-font-awesome"

# unzip - Unzip utility for .zip files
PACKAGES+=" unzip"

# vim - Vi Improved, a highly configurable text editor
PACKAGES+=" vim"

# vivaldi - Web browser with unique features
PACKAGES+=" vivaldi"

# vlc - Media player and streamer
PACKAGES+=" vlc"

# vulkan-intel - Intel's Vulkan mesa driver
PACKAGES+=" vulkan-intel"

# vulkan-tools - Vulkan utilities and demos
PACKAGES+=" vulkan-tools"

# wget - Command-line utility for downloading files
PACKAGES+=" wget"

# wireplumber - Session and policy manager for PipeWire
PACKAGES+=" wireplumber"

# xautolock - Automatic X screen locker
PACKAGES+=" xautolock"

# xbindkeys - Launch shell commands with keyboard shortcuts
PACKAGES+=" xbindkeys"

# xclip - Command-line interface to X clipboard
PACKAGES+=" xclip"

# xdotool - Command-line X11 automation tool
PACKAGES+=" xdotool"

# xf86-input-libinput - Generic input driver for X
PACKAGES+=" xf86-input-libinput"

# xorg-server - X.Org X server
PACKAGES+=" xorg-server"

# yay - Yet Another Yogurt, an AUR helper
PACKAGES+=" yay"

# yt-dlp - YouTube downloader with additional features
PACKAGES+=" yt-dlp"

# zip - Compression and file packaging utility
PACKAGES+=" zip"

# zoom - Video conferencing and web conferencing service
PACKAGES+=" zoom"

# zsh - Z shell, an extended Bourne shell with many improvements
PACKAGES+=" zsh"

# Calculator
PACKAGES+=" qalculate-gtk"

# Nerd Fonts
PACKAGES+=" ttf-nerd-fonts-symbols"

echo "$PACKAGES"
