#!/bin/sh

_LogFile=

setLogFile() {
    _LogFile=$1
    mkdir -p $(dirname ${_LogFile})
    touch ${_LogFile}
}

logInfo() {
    local date=$(date "+%y-%m-%d %h:%m:%s")
    echo -e "$date [info] $@" >>${_LogFile}
}

logWarn() {
    local date=$(date "+%y-%m-%d %h:%m:%s")
    echo -e "\033[33m$date [warn] $@ \033[0m" >>${_LogFile}
}

logError() {
    local date=$(date "+%y-%m-%d %h:%m:%s")
    echo -e "\033[31m$date [error] $@ \033[0m" >>${_LogFile}
}

printMsg() {
    echo -e "\033[36m\033[1m$@\033[0m"
}
