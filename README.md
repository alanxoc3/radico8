# radico8
radico8 is both a [youtube stream](https://youtube.com/channel/UCNiwmNlnzY0Rg17Ii2RPIkw/live) and [web radio](http://radico8.xoc3.io/stream.ogg) that plays [pico-8](https://www.lexaloffle.com/pico-8.php) music.

## submitting songs
if you know some good pico-8 music, submit a pull request adding the lexaloffle cart-id and track to the [playlist.txt](./playlist.txt) file.

## issues
you can submit a github issues for issues with the stream, feature suggestions, and bugfixes.

youtube changes the video url everytime the stream goes down unless you use the link at the top of this document. so make sure you bookmark that link.

giving credit to the actual artist of a song is a manual process. if a song is attributed to the wrong user please submit a pull request with the fix in the [playlist.txt](./playlist.txt) file.

## running locally
you can run the radio locally on a linux system. here are the steps:

```
# check your directory.
> ls
cartridges docker Dockerfile install_carts install_to_server LICENSE local-radio playlist.txt README.md remote-radio

# the radico8 p8/lua files should be in the cartridges directory.
> ls cartridges | grep radico8
radico8.lua
radico8.p8

# perform a 1 time download of the carts listed in the playlist file.
# running this script multiple times will skip carts that are already downloaded.
# this populates the cartridges directory with ".p8" and ".txt" files and removes comments/formatting from the playlist.txt file.
> ./install_carts ./playlist.txt cartridges #
Saved size: 212 212 3665

# and finally, run the radio! this opens up pico8 with your song (there is no ui right now).
> ./local-radio /opt/pico8/pico8 cartridges playlist.txt
hotfoot-2:0:0:34:repeat:
seinsim-0:18:0:16:repeat:
...
```

## how it works
- a headless instance of pico-8 is running inside a docker container.
- pico-8 listens on stdin to figure out which carts it should play next.
- a shell script listens on stdout of pico-8 to produce the youtube video image.
- ffmpeg listens to any audio produced in the docker container and forwards it to icecast and youtube.
- a cron job runs every hour to load playlist updates into the radio.
- carts are downloaded as p8.png images directly from lexaloffle.
- the pico-8 console is rebooted every monday and whenever i push code updates.

## behavior
- a song will play until it stops or for about 10-15 seconds after it starts repeating.
- the max length a single song can play is about 7 minutes, before radico8 will end the song.
- radico8 shuffles the entire playlist then plays songs until every song has been played.

## credits
- learn about pico-8: https://www.lexaloffle.com/pico-8.php
- pico-8 font for youtube stream: https://www.lexaloffle.com/bbs/?tid=3760
- inspired by the krelez's chiptune radio: https://www.youtube.com/c/Krelez
- splore api: https://www.ebartsoft.com/pico8

## legal stuff
please don't sue me. i'm not that rich anyways, so it's probably not worth it. if you're the author of a song and you'd like it removed from the radio, just submit a pull request to remove that song.

this repo is licensed under [CC4-BY-NC-SA](https://creativecommons.org/licenses/by-nc-sa/4.0/) because most pico-8 games use that license too.
