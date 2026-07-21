# EPGStation + ffmpeg. The upstream l3tnun/epgstation:*-debian image is
# node:18-bookworm-slim without ffmpeg, but EPGStation needs it for
# thumbnails, HLS streaming, and post-recording encoding. Layer ffmpeg
# (from Debian) on top.
ARG EPGSTATION_VERSION=v2.10.0
FROM docker.io/l3tnun/epgstation:${EPGSTATION_VERSION}-debian

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ffmpeg \
    && rm -rf /var/lib/apt/lists/*
