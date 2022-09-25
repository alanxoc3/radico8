FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y pulseaudio xvfb ffmpeg && rm -rf /var/lib/apt/lists/*
COPY start_radio  /usr/bin
COPY start_stream /usr/bin
ENTRYPOINT ["start_stream"]
