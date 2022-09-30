# radico8
radico8 is both a [youtube stream](https://youtube.com/channel/UCNiwmNlnzY0Rg17Ii2RPIkw/live) and [web radio](http://radico8.xoc3.io/stream.ogg) that plays [pico-8](https://www.lexaloffle.com/pico-8.php) music.

## submitting songs
if you know some good pico-8 music, submit a pull request adding the lexaloffle cart-id and track to the [playlist.txt](./playlist.txt) file.

## issues
please create a github issue if the stream is down and i'll try to get it back up as soon as i can. you can submit issues for small feature suggestions and bugfixes too.

giving credit to the actual artist of a song is a manual process. if a song is attributed to the wrong user please submit a pull request with the fix in the [playlist.txt](./playlist.txt) file.

## how it works
- a headless instance of pico-8 is running inside a docker container.
- pico-8 listens on stdin to figure out which carts it should play next.
- a shell script listens on stdout of pico-8 to produce the youtube video image.
- ffmpeg listens to any audio produced in the docker container and forwards it to icecast and youtube.
- a cron job runs every hour to load playlist updates into the radio.
- carts are downloaded as p8.png images directly from lexaloffle.
- the pico-8 console is rebooted every monday and whenever i push code updates.

## behavior
- once radico8 notices a song is repeating, it will end the song in 20 seconds.
- the max length a single song can play is 5 minutes, before radico8 will end the song.
- radico8 shuffles the entire playlist then plays songs until every song has been played.

## todo
- send track info to icecast

## credits
- learn about pico-8: https://www.lexaloffle.com/pico-8.php
- pico-8 font for youtube stream: https://www.lexaloffle.com/bbs/?tid=3760
- inspired by the krelez's chiptune radio: https://www.youtube.com/c/Krelez
- splore api: https://www.ebartsoft.com/pico8

## legal stuff
please don't sue me. i'm not that rich anyways, so it's probably not worth it. if you're the author of a song and you'd like it removed from the radio, just submit a pull request to remove that song.

this repo is licensed under [CC4-BY-NC-SA](https://creativecommons.org/licenses/by-nc-sa/4.0/) because most pico-8 games use that license too.
