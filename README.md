# radico8
A pico8 web radio.

## random notes to delete soon
```
ffmpeg -f pulse -i 'alsa_output.pci-0000_00_0e.0.analog-stereo.monitor' -f ogg -content_type audio/ogg icecast://source:$(pass show radico8.xoc3.io/source)@xoc3.io:8000/radico8.ogg
ffmpeg -f alsa -i default -f ogg -content_type audio/ogg icecast://source:"$PASS"@xoc3.io:8000/radico8.ogg

ffmpeg -f pulse -i 'alsa_output.pci-0000_00_0e.0.analog-stereo.monitor' output.ogg

ffmpeg -ac 1 -f alsa -i hw:0,0 -acodec libmp3lame -ab 32k -ac 1 -content_type audio/mpeg -f mp3 icecast://source:...@ip:port/mount

# Below is youtube stream:
# taken from: https://www.radioforge.com/how-to-create-a-live-radio-on-youtube/

#! /bin/bash

VBR="1500k"
FPS="24"
QUAL="superfast"

YOUTUBE_URL="rtmp://a.rtmp.youtube.com/live2"
KEY="xxxx-xxxx-xxxx-xxxx"

VIDEO_SOURCE="/home/radio.gif"
AUDIO_SOURCE="http://[radio-server-ip-address]:[port]/stream"

ffmpeg \
    -re -f lavfi -i "movie=filename=$VIDEO_SOURCE:loop=0, setpts=N/(FRAME_RATE*TB)" \
    -thread_queue_size 512 -i "$AUDIO_SOURCE" \
    -map 0:v:0 -map 1:a:0 \
    -map_metadata:g 1:g \
    -vcodec libx264 -pix_fmt yuv420p -preset $QUAL -r $FPS -g $(($FPS * 2)) -b:v $VBR \
    -acodec libmp3lame -ar 44100 -threads 6 -qscale:v 3 -b:a 320000 -bufsize 512k \
    -f flv "$YOUTUBE_URL/$KEY"
```
