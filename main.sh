#!/bin/sh

bin=$(dirname "$0")
export TOP_DIR=$(
    cd "$bin"
    pwd
)
export PROGRAM=$(basename "$0")

importScript() {
    for f in $(find $TOP_DIR/core -type f); do
        source $f
    done
}

#-----------entrypoint---------#
importScript
startApp $@
