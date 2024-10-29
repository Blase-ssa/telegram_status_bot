# syntax=docker/dockerfile:1
# ARG variables
ARG NODE_VERSION="slim-bullseye"

# create create a container
FROM python:${NODE_VERSION}

# ENV variables
ENV APP_NAME="telegram_status_bot"
ENV APP_WORKSPACE="/opt/${APP_NAME}"

## install Python
RUN apt update && \
    apt install -y curl python3 python3-pip python-is-python3 && \
    apt-get clean;\
    rm -rf /var/lib/apt/lists/*

## install Python requirements
COPY ${APP_PATH}/requirements.txt /tmp
RUN mkdir ${APP_WORKSPACE}
RUN pip install -r /tmp/requirements.txt
