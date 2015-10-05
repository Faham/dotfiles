#!/bin/bash

# not needed
# 40-4_CCE_DVB_MPEG2_subtitle_SCTE27.ts
# 40-8_H264_subtitle_SCTE-27_Bad_PMT.mpg

rm /tmp/*.dot
# rm out/out.str

CMD=$1
FILE=$2

if [ $CMD = 'mpg2' ]; then
# vecima/40-3_ATSC_EIA708_MPEG2_CC_CEA708_using_SCTE21.mpg
# vecima/40-2_NTSC_DVT_Stream_01_720x480_4x3_MPEG2_CC_CEA608_using_SCTE21.ts
# vecima/40-1_NTSC_DVT_Stream_21_720x480_4x3_03.75Mbps_VBR_MPEG2_CC_CEA608_using_SCTE20.ts

    gst-launch filesrc location=$FILE ! tsdemux name=d ! \
    mpegvideoparse name=m \
    m.src ! queue max-size-buffers=0 max-size-time=0 ! \
    vaapidecode ! textoverlay name=txt wait-text=false ! vaapisink \
    m.user_data_src ! queue max-size-buffers=0 max-size-time=0 ! ccdec name=c \
    c. ! cea608dec ! 'text/x-raw' ! \
    txt.

    # tee name=t ! filesink location=out/out.str \
    # t. ! queue max-size-buffers=0 max-size-time=0 ! txt.

    #c. ! cea608dec ! 'text/x-raw' ! txt. \

    # c. ! queue max-size-buffers=0 max-size-time=0 ! cea708dec ! 'text/x-raw' ! txt.
    # c. ! queue max-size-buffers=0 max-size-time=0 ! cea608dec ! 'text/x-raw' ! txt.

elif [ $CMD = 'h264' ]; then
# vecima/40-7_Nat_Geo_HD_h264_CC_CEA708_using_SCTE21.mpg
    #c="
    # gst-launch filesrc location=$FILE blocksize=1316 ! \
    # tsdemux ! h264parse name=h h.src ! vaapidecode ! vaapisink sync=false

    gst-launch filesrc location=$FILE ! \
    tsdemux ! h264parse name=h \
    h.src ! queue max-size-buffers=0 max-size-time=0 ! \
    vaapidecode ! textoverlay name=txt wait-text=false ! vaapisink \
    h.user_data_src ! queue max-size-buffers=0 max-size-time=0 ! \
    ccdec ! cea608dec ! 'text/x-raw' ! \
    txt.

    # tee name=t ! filesink location=out/out.str \
    # t. ! queue max-size-buffers=0 max-size-time=0 ! txt.

    #filesink location=out/out.str
    #"
elif [ $CMD = 'uridb' ]; then
    
    gst-launch uridecodebin uri=file://$FILE ! xvimagesink

elif [ $CMD = 'dlnrm' ]; then
# vecima/Dolby_Digital_Test_Files/2_dnswp.ac3
    gst-launch filesrc location=$FILE ! ac3parse ! avdec_ac3 mode=stereo ! audioconvert ! alsasink

elif [ $CMD = 'afd' ]; then
    # gst-launch filesrc location=$FILE ! tsdemux ! mpegvideoparse name=m \
    # m.src ! vaapidecode ! vaapisink \
    # m.user_data_src ! queue max-size-buffers=0 max-size-time=0 ! ccdec name=c \
    # ! 'text/x-afd-raw' ! fakesink

    gst-launch filesrc location=$FILE ! tsdemux name=d ! \
    mpegvideoparse name=m \
    m.src ! queue max-size-buffers=0 max-size-time=0 ! \
    vaapidecode ! textoverlay name=txt wait-text=false ! vaapisink \
    m.user_data_src ! queue max-size-buffers=0 max-size-time=0 ! ccdec name=c \
    c. ! cea608dec ! 'text/x-raw' ! \
    txt.

elif [ $CMD = 'prf' ]; then
    gst-launch -e \
    v4l2src filesrc location=$FILE ! \
    video/x-raw-yuv, width=1920, height=1088 ! \
    dmaiaccel ! \
    dmaiperf print-arm-load=true ! \
    dmaienc_h264 targetbitrate=12000000 maxbitrate=12000000 ! \
    qtmux ! \
    filesink location=/media/sdcard/recording.mp4
fi

eval $c
echo "Executed command is:
 $c"

#rm out/ccextractor.str; ./ccextractor $FILE -out=txt -o out/ccextractor.str
# rm out/out.png; dot -Tpng /tmp/*_PLAYING* -o out/out.png; gnome-open out/out.png
