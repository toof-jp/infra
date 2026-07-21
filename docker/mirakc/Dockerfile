# mirakc + recisdb: the upstream mirakc image ships mirakc-arib and
# dvbv5-zap but no B-CAS decoder (licensing). We layer recisdb on top so
# a single container can tune DVB, filter, and decode the scrambled TS.
ARG MIRAKC_VERSION=3.4.77
FROM docker.io/mirakc/mirakc:${MIRAKC_VERSION}-debian

ARG RECISDB_VERSION=1.2.4

# libpcsclite1 is the client library; pcscd itself runs on the host and
# is reached over /run/pcscd/pcscd.comm which the pod mounts hostPath.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        libpcsclite1 \
    && curl -fsSL -o /tmp/recisdb.deb \
        "https://github.com/kazuki0824/recisdb-rs/releases/download/${RECISDB_VERSION}/recisdb_${RECISDB_VERSION}-1_amd64.deb" \
    && dpkg -i /tmp/recisdb.deb \
    && rm /tmp/recisdb.deb \
    && apt-get purge -y --auto-remove curl \
    && rm -rf /var/lib/apt/lists/*
