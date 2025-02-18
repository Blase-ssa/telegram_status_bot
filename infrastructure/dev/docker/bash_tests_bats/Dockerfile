# syntax=docker/dockerfile:1

# create create a container
FROM ubuntu:devel

# ENV variables
# ENV APP_NAME="status_exporter"
ENV APP_WORKSPACE="/opt/WORKSPACE"
ENV BATS_BRANCH="master"

## install main packages
RUN apt update && \
    apt install -y bash curl wget zip && \
    apt-get clean;\
    rm -rf /var/lib/apt/lists/*

## install bats
RUN cd /tmp && \
    wget https://github.com/bats-core/bats-core/archive/refs/heads/${BATS_BRANCH}.zip && \
    unzip ${BATS_BRANCH}.zip && \
    bash /tmp/bats-core-${BATS_BRANCH}/install.sh /usr/local && \
    cd /tmp && rm -rf bats-core-${BATS_BRANCH} && rm -f ${BATS_BRANCH}.zip

## install project requirements requirements
## moved this section to pipeline
# COPY ${BASH_PATH}/${APP_NAME}/requirements.txt /tmp
# RUN xargs -a /tmp requirements.txt sudo apt install && \
#     apt-get clean;\
#     rm -rf /var/lib/apt/lists/*
RUN mkdir ${APP_WORKSPACE}