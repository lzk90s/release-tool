#!/bin/sh

bin=$(dirname "$0")
export MY_DIR=$(
    cd "$bin"
    pwd
)

apk update && apk add --no-cache git libxml2-utils && \
find $MY_DIR/ -type f -name "*.sh" | xargs dos2unix && \
chmod +x $MY_DIR/* -R && \
git config --global user.email "service@hzgosun.com" && \
git config --global user.name "devops"
