#!/bin/sh

usage() {
    printMsg "Usage: $PROGRAM"
    printMsg "  envs:"
    printMsg "  - RELEASE_VERSION           发布版本号 ($RELEASE_VERSION)"
    printMsg "  - NEXT_DEV_VERSION          下一个开发版本号 ($NEXT_DEV_VERSION)"
    printMsg "  - PUSH                      是否推送到远程仓库 ($PUSH)"
    printMsg "  - PROJECTS                  工程【可选，若为空，从PROJECT_FILE获取】 ($PROJECTS)"
    printMsg "  - PROJECT_FILE              工程文件【可选，若为空，取projects.txt】 ($PROJECT_FILE)"
    printMsg "  - SEND_RELEASE_LOG          是否发送releaselog ($SEND_RELEASE_LOG)"
    printMsg "  - ONLY_PUSH_CHANGED_PROJECT 是否仅推送变更的工程到远程git服务器 ($ONLY_PUSH_CHANGED_PROJECT)"
    printMsg "  - AUTO_INCREASE_VERSION     是否自动增加版本号 ($AUTO_INCREASE_VERSION)"
    exit 1
}

countdown() {
    local secondsLeft=$1
    echo "wait ${secondsLeft} seconds to start ......"
    while [ $secondsLeft -gt 0 ]; do
        echo -n $secondsLeft
        sleep 1
        secondsLeft=$(($secondsLeft - 1))
        echo -ne "\r     \r" #清除本行文字
    done
}

startApp() {
    local gitHost=${GIT_HOST:-""}
    local gitUser=${GIT_USER:-""}
    local gitPassword=${GIT_PASSWORD:-""}
    local releaseVersion=$RELEASE_VERSION
    local nextDevVersion=$NEXT_DEV_VERSION
    local push=${PUSH:-false}
    local projects=${PROJECTS:-}
    local projectFile=${PROJECT_FILE:-}
    local sendReleaseLog=${SEND_RELEASE_LOG:-false}
    local onlyPushChangedProject=${ONLY_PUSH_CHANGED_PROJECT:-false}
    local autoIncreaseVersion=${AUTO_INCREASE_VERSION:-false}

    local workDir=$TOP_DIR/data
    local gitBaseurl=http://$gitUser:$gitPassword@$gitHost
    local sendMailAddress=http://181.181.0.158:43234/notifyfile?topic=release-tool
    local checkpointFile=$workDir/checkpoint/checkpoint_$nextDevVersion.txt
    local releaseLogFile=$workDir/releaseLog.html
    local logFile=/dev/stdout

    #外部没有指定工程时，使用配置文件中的工程，去掉#开头的行
    if [ -z "$projects" ]; then
        if [ -f "$projectFile" ]; then
            projects=$(cat $projectFile | grep -v '^#' | sort)
        fi
    fi

    mkdir -p $workDir
    setLogFile $logFile
    #setCheckpointFile $checkpointFile
    setDeploySaveDir $workDir
    htmlRlogInit $releaseLogFile

    printMsg "-----------------------------------------------------------------"
    printMsg "gitHost                           = $gitHost"
    printMsg "workDir                           = $workDir"
    printMsg "releaseVersion                    = $releaseVersion"
    printMsg "nextDevVersion                    = $nextDevVersion"
    printMsg "push                              = $push"
    printMsg "sendReleaseLog                    = $sendReleaseLog"
    printMsg "releaseLogFile                    = $releaseLogFile"
    printMsg "projects                          = $projects"
    printMsg "projectFile                       = $projectFile"
    printMsg "onlyPushChangedProject            = $onlyPushChangedProject"
    printMsg "autoIncreaseVersion               = $autoIncreaseVersion"
    printMsg "-----------------------------------------------------------------"

    #必要参数非空校验
    if
        [ -z "$gitUser" -o -z "$gitPassword" -o \
        -z "$releaseVersion" -o -z "$nextDevVersion" -o \
        -z "$projects" ]
    then
        usage
    fi

    #校验版本号的合法性
    if [ $(isLegalVersion $nextDevVersion) -eq 0 ]; then
        logError "the version $nextDevVersion is illegal!"
        exit 2
    fi
    if [ $(isLegalVersion $releaseVersion) -eq 0 ]; then
        logError "the version $releaseVersion is illegal!"
        exit 2
    fi

    #如果是bugfix版本，需要保证minor版本号一致
    if [ $(isBugfixVersion $releaseVersion) -eq 1 -a "${releaseVersion%.*}" != "${nextDevVersion%.*}" ]; then
        logError "the minor number for $releaseVersion and $nextDevVersion is not equal"
        exit 1
    fi

    #倒计时等待
    countdown 3

    htmlRlogBegin

    #循环处理所有工程
    changedProjects=
    for line in $projects; do
        cd ${workDir}

        #解析出group，工程名
        local group=$(echo $line | cut -d',' -f1)
        local proj=$(echo $line | cut -d',' -f2)

        if [ -z "$group" -o -z "$proj" -o "$group" == "$proj" ]; then
            logError "invalid line $line"
            exit 3
        fi

        local repoUrl=$gitBaseurl$proj.git
        logInfo "process project $repoUrl"

        local repoDir=$(getRepoDir $repoUrl)
        mkdir -p $repoDir
        cd $repoDir

        if [ "$group" == "service" ]; then
            serviceReleaseRoutine $repoUrl $releaseVersion $nextDevVersion $autoIncreaseVersion $group
        else
            defaultReleaseRoutine $repoUrl $group master
        fi

        if [ $? -gt 0 ]; then
            changedProjects="$changedProjects $proj"
        fi
    done

    htmlRlogEnd

    # 检查是否还有未解决的问题
    if [ $(hasUnresolvedIssues) -gt 0 ]; then
        printMsg "------------------- 未解决的jira问题列表 -------------------"
        dumpUnresolvedIssues
        #exit 4
    fi

    #发送release-log
    if [ "$sendReleaseLog" != "false" ]; then
        curl -f "file=@$releaseLogFile" $sendMailAddress
        checkResult "failed to send mail"
    fi

    #推送到远程仓库
    if [ "$push" = "true" ]; then
        local projectsToPush=$projects
        if [ "$onlyPushChangedProject" = "true" ]; then
            projectsToPush=$changedProjects
        fi

        printMsg "projectsToPush = $projectsToPush"

        for p in $projectsToPush; do
            cd ${workDir}
            local repoUrl=$gitBaseurl$p.git
            logInfo "push project $repoUrl"

            local repoDir=$(getRepoDir $repoUrl)
            mkdir -p $repoDir
            cd $repoDir

            doPush $repoUrl
            checkResult "failed to push project $p"
        done
    fi

    #收集部署文件

    logInfo "-------------- all succeed, enjoy:) --------------"
}
