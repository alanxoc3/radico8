FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y curl pulseaudio xvfb ffmpeg imagemagick && rm -rf /var/lib/apt/lists/*
COPY pico8mono.ttf /usr/share/fonts/
COPY template.gif /out.gif
RUN mkfifo /radico8-playlist.pipe
COPY stop_ffmpeg headless_pico8 docker_init_script create_image radio stream_to_youtube stream_to_icecast /usr/bin/
ENTRYPOINT ["docker_init_script"]
