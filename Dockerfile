FROM openjdk:8-jre-bullseye as image_builder

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    systemd systemd-sysv iproute2 isc-dhcp-client ifupdown \
    tar procps passwd gzip util-linux

ARG NEXUS_VERSION=3.41.1-01
ARG NEXUS_DOWNLOAD_URL=https://download.sonatype.com/nexus/3/nexus-3.41.1-01-unix.tar.gz
ARG NEXUS_DOWNLOAD_SHA256_HASH=1ad45fd883f41005e7f89ccb9e504f09a9a5708eb996493b985eed09e6482faa
ENV SONATYPE_DIR=/opt/sonatype
ENV NEXUS_HOME=/opt/sonatype/nexus NEXUS_DATA=/nexus-data NEXUS_CONTEXT= SONATYPE_WORK=/opt/sonatype/sonatype-work

RUN mkdir -p ${SONATYPE_DIR} && \
    groupadd --gid 200 -r nexus && \
    useradd --uid 200 -r nexus -g nexus -s /bin/false -d /opt/sonatype/nexus -c 'Nexus Repository Manager user'
RUN cd /tmp && \
    curl -L ${NEXUS_DOWNLOAD_URL} --output nexus.tar.gz && \
    echo "${NEXUS_DOWNLOAD_SHA256_HASH} nexus.tar.gz" > nexus.tar.gz.sha256 && \
    sha256sum -c nexus.tar.gz.sha256 && \
    cd ${SONATYPE_DIR} && \
    tar -xvf /tmp/nexus.tar.gz && \
    mv nexus-${NEXUS_VERSION} $NEXUS_HOME && \
    chown -R nexus:nexus ${SONATYPE_WORK} && \
    mv ${SONATYPE_WORK}/nexus3 ${NEXUS_DATA} && \
    ln -s ${NEXUS_DATA} ${SONATYPE_WORK}/nexus3

ADD ["files", "/"]

RUN systemctl enable networking.service && \
    systemctl enable systemd-resolved.service && \
    systemctl enable systemd-journald.service && \
    systemctl enable nexus.service

# CLEAN UP
RUN apt-get clean && \
    rm -rf /tmp/*

FROM alpine:3.16 as packager

RUN apk add \
    bash tar gzip && \
    mkdir -p /rootfs

COPY --from=image_builder ["/", "/rootfs"]
RUN cd /rootfs && tar -czf ../rootfs.tar.gz .

FROM scratch
ARG NEXUS_VERSION=3.41.1-01
COPY --from=packager ["/rootfs.tar.gz", "/nexus-${NEXUS_VERSION}-rootfs.tar.gz"]

