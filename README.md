# radico8
radico8 is both a [youtube stream](https://youtube.com/channel/UCNiwmNlnzY0Rg17Ii2RPIkw/live) and [web radio](http://radico8.xoc3.io/stream.ogg) that plays [pico8](https://www.lexaloffle.com/pico-8.php) music.

## submitting songs
if you know some good pico-8 music, submit a pull request adding the lexaloffle cart-id and track to the [playlist.txt](./playlist.txt) file.

## how it works
- a headless instance of pico-8 is running inside a docker container.
- pico-8 listens on stdin to figure out which carts it should play next.
- a shell script listens on stdout of pico-8 to produce the youtube video image.
- ffmpeg listens to any audio produced in the docker container and forwards it to icecast and youtube.
- a cron job runs every hour to load playlist updates into the radio.
- carts are downloaded as p8.png images directly from lexaloffle.

## credits
pico-8 font for youtube stream came from here:
- https://www.lexaloffle.com/bbs/?tid=3760
