#!/bin/sh

mdRlogFile=

mdRlogInit() {
    mdRlogFile=$1
    #truncate file
    true >$mdRlogFile
}
