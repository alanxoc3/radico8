FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y pulseaudio xvfb ffmpeg && rm -rf /var/lib/apt/lists/*
RUN apt update && apt install -y imagemagick
COPY pico8mono.ttf /usr/share/fonts/
COPY create_image start_radio stream_to_youtube stream_to_icecast /usr/bin/
ENTRYPOINT ["start_radio"]
