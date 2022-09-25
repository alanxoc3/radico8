# radico8
radico8 is both a web radio and youtube stream that plays songs out of pico-8 cartridges.

## submitting songs
if you know of some good pico-8 songs, submit a pull request with your songs added to the [playlist.txt](./playlist.txt) file.

## how it works
an headless instance of pico-8 is running inside a docker container. a pico-8 script listens on stdin to figure out which cart it should load next. another script listens on the stdout of pico-8 to produce the youtube video image and webradio audio labels. ffmpeg listens to any audio produced in the image and forwards it to icecast. icecast is the webradio server. another ffmpeg instance forwards audio and the current video image from the container to the youtube stream.

## credits
pico-8 font for youtube stream came from here:
- https://www.lexaloffle.com/bbs/?tid=3760
