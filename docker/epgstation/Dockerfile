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

# The base image ships log config as *.sample.yml and enc.js as
# *.template, but EPGStation looks up the un-suffixed names at boot
# and exits with "log file is not found" if they're missing. Convert
# them once here so the container works with only config.yml mounted.
RUN set -eux; cd /app/config; \
    for f in *.sample.yml; do cp -n "$f" "${f%.sample.yml}.yml"; done; \
    for f in *.template; do cp -n "$f" "${f%.template}"; done
