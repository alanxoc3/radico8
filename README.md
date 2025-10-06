# radico8
radico8 is a [web radio](http://radico8.xoc3.io/stream.ogg) that plays [pico-8](https://www.lexaloffle.com/pico-8.php) music.

there was a youtube stream too, but as of 2025-10-06, it went down and i don't currently plan on bringing it back up. the youtube stream relies on ffmpeg, which has been straining my server.

## submitting songs
if you know some good pico-8 music, submit a pull request adding the lexaloffle cart-id and track to the [playlist.txt](./playlist.txt) file.

## issues
you can submit a github issues for issues with the stream, feature suggestions, and bugfixes.

youtube changes the video url everytime the stream goes down unless you use the link at the top of this document. so make sure you bookmark that link.

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
- a song will play until it stops or for about 10-15 seconds after it starts repeating.
- the max length a single song can play is about 7 minutes, before radico8 will end the song.
- radico8 shuffles the entire playlist then plays songs until every song has been played.

## running locally
you can run the radio locally on a linux system. here are the steps:

```
# the radico8 p8/lua files should be in the cartridges directory.
> ls cartridges | grep radico8
radico8.lua
radico8.p8

# perform a 1 time download of the carts listed in the playlist file.
# running this script multiple times will skip carts that are already downloaded.
# this populates the cartridges directory with ".p8" and ".txt" files and removes comments/formatting from the playlist.txt file.
> ./scripts/install_carts ./playlist.txt cartridges
Saved size: 212 212 3665

# and finally, run the radio!
# this opens up pico8 and loads carts/songs on demand.
# also listens to changes in the playlist.txt file (good for a 24/7 radio).
> ./scripts/local-radio /opt/pico8/pico8 cartridges playlist.txt
hotfoot-2:0:0:34:repeat:
seinsim-0:18:0:16:repeat:
...
```

## running the server
radico8 is currently hosted on a tiny arch-linux linode instance along with some other things. there are 4 parts to the server setup:

- the local-radio (pico8 running within a bash script)
- the cart install script (timer that downloads cart data when playlist.txt updates)
- the youtube stream (ffmpeg forwarding audio+picture into youtube stream)
- the webradio stream (ffmpeg forwarding audio to existing icecast installation

radico8 could be setup on any linux machine, but it is a bit of a manual process. here are the general steps:

```
1. ensure you have the docker daemon installed & running
2. if you want to host a webradio:
   - ensure you have icecast installed: https://icecast.org/
   - make sure you have a file at: /etc/radico8/icecast.env
   - the file content would be:
     PASS=<icecast-stream-token>
3. if you want to host a youtube stream:
   - setup a youtube stream, use these scripts to help:
     - ./get_oauth_refresh_token
     - ./update_youtube_broadcast
   - make sure you have a file at: /etc/radico8/youtube.env
   - the file content would be:
     PASS=<youtube-stream-token>
4. run this script: install_to_server
   - it may require some tweaking since it's designed for a specific setup
   - systemd services: radico8 radico8-icecast radico8-youtube radico8-youtube-backup
   - systemd timers: radico8-install-carts radico8-reboot
5. use systemd to manage the radico8 server:
   - initial install of carts: systemctl restart radico8-install-carts
   - restart radico8: systemctl restart radico8
```

## credits
- learn about pico-8: https://www.lexaloffle.com/pico-8.php
- pico-8 font for youtube stream: https://www.lexaloffle.com/bbs/?tid=3760
- inspired by the krelez's chiptune radio: https://www.youtube.com/c/Krelez
- splore api: https://www.ebartsoft.com/pico8

## legal stuff
please don't sue me. i'm not that rich anyways, so it's probably not worth it. if you're the author of a song and you'd like it removed from the radio, just submit a pull request to remove that song.

this repo is licensed under [CC4-BY-NC-SA](https://creativecommons.org/licenses/by-nc-sa/4.0/) because most pico-8 games use that license too.
