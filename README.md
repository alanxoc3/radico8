# radico8
radico8 is both a [web radio](http://radico8/xoc3.io/stream.ogg) and [youtube stream](youtube.com/channel/ucniwmnlnzy0rg17ii2rpikw/live) that plays [pico8](https://www.lexaloffle.com/pico-8.php) music.

## submitting songs
if you know some good pico-8 music, submit a pull request with your songs added to the [playlist.txt](./playlist.txt) file.

## how it works
- an headless instance of pico-8 is running inside a docker container.
- pico-8 cart listens on stdin to figure out which cart it should load next.
- a shell script listens on the stdout of pico-8 to produce the youtube video image and webradio audio labels.
- ffmpeg listens to any audio produced in the docker container and forwards it to icecast and youtube.

## credits
pico-8 font for youtube stream came from here:
- https://www.lexaloffle.com/bbs/?tid=3760
