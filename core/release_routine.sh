#!/bin/sh

initRepo() {
    echo "pwd = $(pwd)"
    local repoUrl=$1
    if [ -d .git ]; then
        logInfo "pull repository"
        pullRepo $repoUrl
        checkResult "pull project $repoUrl failed"
    else
        logInfo "clone repository"
        cloneRepoToDir $repoUrl .
        checkResult "clone project $repoUrl failed"
    fi
}

updateProjectVersion() {
    local v=$1

    #更新版本号到新版本
    logInfo "update version to $v"
    updateVersion $v
    checkResult "update version failed"

    #更新部署文件中的版本号
    local d=.deploy/k8s
    for f in $(find $d -name *.yaml); do
        local currentVersion=$(cat $f | grep "image:" | cut -d ':' -f3)
        sed -i "s/$currentVersion/$v/g" $f
    done
}

commitWithMessage() {
    local msg=$@

    if [ $(isLocalRepoClean) -eq 0 ]; then
        localCommit "$msg"
        checkResult "commit error"
    fi
}

defaultReleaseRoutine() {
    local repoUrl=$1
    local group=$2
    local deployTag=$3

    initRepo $repoUrl

    checkoutToBranch master

    local repoName=$(basename $(pwd))

    printMsg "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    printMsg "+ repoName                   = $repoName"
    printMsg "+ group                      = $group"
    printMsg "+ deployTag                  = $deployTag"
    printMsg "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

    buildAssemblyYaml $group full .deploy/k8s/

    return 1
}

serviceReleaseRoutine() {
    local repoUrl=$1
    local releaseVersion=$2
    local nextDevVersion=$3
    local autoIncreaseVersion=$4
    local group=$5

    #克隆或更新仓库
    initRepo $repoUrl

    local tmpNextDevVersion=$nextDevVersion
    local isMinor=$(isMinorReleaseVersion $releaseVersion)
    local isRc=$(isRcVersion $releaseVersion)
    local workBranch=${releaseVersion%.*}.x-stable
    local type=

    if [ $isRc -eq 1 ]; then
        #rc是候选发布版本，是转测试时的版本，只在master分支上更新版本号
        type="rc转测试版本"
        workBranch=master
    elif [ $isMinor -eq 1 ]; then
        #常规版本: release分支的第一个开发版本为x.y.1，分支为x.y-stable分支
        type="常规版本"
        nextDevVersion=$(echo $releaseVersion | sed 's/\.0$/\.1/g')-SNAPSHOT
        if [ $(isBranchExist $workBranch) -eq 0 ]; then
            logInfo "create new branch $workBranch"
            createNewBranch $workBranch
            checkResult "create branch $workBranch failed"
        fi
    else
        # bugfix版本
        type="bugfix版本"
    fi

    #切换到workBranch
    logInfo "checkout to work branch $workBranch"
    checkoutToBranch $workBranch
    checkResult "checkout error for branch $workBranch"

    #计算变量
    local currentVersion=$(getProjectVersion)
    local releaseTag=v${releaseVersion}
    local lastReleaseTag=$(getLatestTag)
    local repoName=$(basename $(pwd))

    #判断是否自动需要自动增加版本号
    if [ "$autoIncreaseVersion" == "true" ]; then
        nextDevVersion=$(buildNextMicroVersion $currentVersion)
    fi

    printMsg "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    printMsg "+ type                       = $type"
    printMsg "+ repoName                   = $repoName"
    printMsg "+ currentVersion             = $currentVersion"
    printMsg "+ nextDevVersion             = $nextDevVersion"
    printMsg "+ group                      = $group"
    printMsg "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    printMsg "+ workBranch                 = $workBranch"
    printMsg "+ nextDevVersion             = $nextDevVersion"
    printMsg "+ tmpNextDevVersion          = $tmpNextDevVersion"
    printMsg "+ releaseVersion             = $releaseVersion"
    printMsg "+ releaseTag                 = $releaseTag"
    printMsg "+ lastReleaseTag             = $lastReleaseTag"
    printMsg "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

    #待发布的版本与当前版本相同，不处理
    if [ "$currentVersion" = "$nextDevVersion" ]; then
        logWarn "new version $currentVersion is same as original version, skip"
        return 0
    fi

    #更新版本号到发布版本
    if [ "$currentVersion" != "$releaseVersion" ]; then
        updateProjectVersion $releaseVersion
        commitWithMessage "Release version $releaseVersion"
    fi

    #给发布版本打tag
    if [ $(isTagExist $releaseTag) -eq 0 ]; then
        logInfo "create tag $releaseTag"
        createNewTag $releaseTag
        checkResult "create tag $releaseTag failed"
    fi

    #生成release-log
    local issueIds=$(getIssueIdsFromCommitlog $lastReleaseTag)
    for issueId in $issueIds; do
        htmlRlogWriteIssue $issueId $repoName $lastReleaseTag-$releaseTag
    done

    #生成yaml部署文件
    logInfo "build deploy yaml"
    buildAssemblyYaml $group full .deploy/k8s/
    if [ "$issueIds" != "" ]; then
        buildAssemblyYaml $group diff .deploy/k8s/
    fi

    #更新版本号到下一个开发版本
    updateProjectVersion $nextDevVersion
    commitWithMessage "Update version to next iteration $nextDevVersion"

    local changedFlag=$(echo $issueIds | wc -w)
    if [ $isMinor -eq 1 ]; then
        logInfo "checkout to master branch"
        checkoutToBranch master
        updateProjectVersion $tmpNextDevVersion
        commitWithMessage "Update version to next iteration $tmpNextDevVersion"
        changedFlag=1
    fi

    return $changedFlag
}

doPush() {
    local repoUrl=$1
    #1. 推送到远程仓库
    pushToRemote $repoUrl
    checkResult "push to remote failed"
}
