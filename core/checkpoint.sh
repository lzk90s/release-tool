#!/bin/sh

_CheckpointFile=

setCheckpointFile() {
    _CheckpointFile=$1
    mkdir -p $(dirname ${_CheckpointFile})
    touch ${_CheckpointFile}
}

writeCheckpoint() {
    echo $1 >>${_CheckpointFile}
}

checkpointExist() {
    grep "$1" ${_CheckpointFile} | wc -w
}
