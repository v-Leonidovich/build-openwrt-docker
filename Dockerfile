FROM ubuntu:24.04
#FROM debian:trixie

RUN apt-get update && apt-get install -y --no-install-recommends libncurses5-dev \
    build-essential file libncurses-dev zlib1g-dev gawk git libncursesw5-dev tar xz-utils \
    gettext libssl-dev xsltproc rsync wget unzip python3 python3-setuptools zstd bash \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN update-ca-certificates

WORKDIR /home/ubuntu
RUN chown -R ubuntu:ubuntu /home/ubuntu
USER ubuntu

CMD ["/home/ubuntu/config/build.sh"]
