#!/bin/sh

isMavenProject() {
    if [ -f pom.xml ]; then
        echo 1
    else
        echo 0
    fi
}

getRepoDir() {
    local repoUrl=$1
    echo $(echo ${repoUrl##*/} | cut -d'.' -f1)
}

getMavenProjectVersion() {
    local version=$(cat pom.xml | sed 's/xmlns=".*"//g' | sed 's/xsi:schemalocation=".*"//g' | xmllint --xpath "//project/version/text()" -)
    echo $version
}

getNormalProjectVersion() {
    echo $(cat version)
}

getProjectVersion() {
    local flag=$(isMavenProject)
    if [ $flag -eq 1 ]; then
        echo $(getMavenProjectVersion)
    else
        echo $(getNormalProjectVersion)
    fi
}

updateMavenVersion() {
    local newVersion=$1
    mvn versions:set -DnewVersion=${newVersion}
}

updateNormalVersion() {
    local newVersion=$1
    echo ${newVersion} >version
}

updateVersion() {
    local flag=$(isMavenProject)
    if [ $flag -ne 0 ]; then
        updateMavenVersion $1
    else
        updateNormalVersion $1
    fi
}

isLegalVersion() {
    echo $1 | grep "^[0-9]\{1,2\}\.[[0-9]\{1,2\}\.[0-9]\{1,3\}*" | wc -w
}

isBugfixVersion() {
    local v=$1
    echo ${v%-*} | grep "^[0-9]\{1,2\}\.[[0-9]\{1,2\}\.[1-9]\{1,2\}" | wc -w
}

#是否是次版本
isMinorReleaseVersion() {
    local v=$1
    echo ${v%-*} | grep -iv "RC[0-9]*" | grep "^[0-9]\{1,2\}\.[[0-9]\{1,2\}\.0" | wc -w
}

#是否是rc版本
isRcVersion() {
    local v=$1
    echo $v | grep -i "RC[0-9]*" | wc -w
}

checkResult() {
    if [ $? -ne 0 ]; then
        logError "$@"
        exit 1
    fi
}

buildNextMicroVersion() {
    local v=$1
    local major=$(echo ${v%-*} | cut -d'.' -f1)
    local minor=$(echo ${v%-*} | cut -d'.' -f2)
    local micro=$(echo ${v%-*} | cut -d'.' -f3)
    local nextMicro=$(expr $micro + 1)
    echo $v | sed "s/$major.$minor.$micro/$major.$minor.$nextMicro/g"
}
