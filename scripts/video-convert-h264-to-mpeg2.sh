#!/bin/bash

# out=${1##*/}
out=`echo ${1} | sed 's/\/media\/fahamne\/windows_7\/videos/dopamine/g'`
out=${out%%.*}
# out_dir=$2
FFMPEG=~/src/ffmpeg/ffmpeg

# ffmpeg configuration:
# ./configure --prefix=/usr/local --enable-gpl --enable-nonfree \
# --enable-libass --enable-libfdk-aac --enable-libfreetype --enable-libmp3lame --enable-libopus \
# --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265

$FFMPEG -i $1 \
  -vcodec mpeg2video -b:v 0.5M \
  -f mpeg2video \
  $out.mpg
