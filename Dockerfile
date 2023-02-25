FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y curl pulseaudio xvfb ffmpeg imagemagick && rm -rf /var/lib/apt/lists/*
COPY docker/pico8mono.ttf /usr/share/fonts/
COPY docker/template.gif /out.gif
COPY scripts/local-radio docker/stop_ffmpeg docker/headless_pico8 docker/docker_init_script docker/create_image docker/stream_to_youtube docker/stream_to_icecast /usr/bin/
ENTRYPOINT ["docker_init_script"]
