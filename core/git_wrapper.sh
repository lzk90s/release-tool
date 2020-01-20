#!/bin/sh

pullRepo() {
    git checkout master
    git pull origin master
}

cloneRepoToDir() {
    git clone $1 $2
}

localCommit() {
    git add -A
    git commit -m "$@"
}

isLocalRepoClean() {
    git status | grep "clean" | wc -w
}

createNewBranch() {
    git branch $1
}

createNewTag() {
    git tag $1
}

pushToRemote() {
    #推送所有分支及tag
    git push origin --all
    git push --tags
}

isBranchExist() {
    git branch | grep $1 | wc -w
}

isTagExist() {
    git tag | grep $1 | wc -w
}

checkoutToBranch() {
    git checkout $1
}

getLatestTag() {
    git describe --abbrev=0 --tags
}

ignoreRegex='^merge|Update version to next iteration'
issueIdRegex='\[\w+\-[0-9]+\]'
getIssueIdsFromCommitlog() {
    local from=$1
    local to=$2
    local issueIds=$(git log $from..$to --no-decorate --no-merges | egrep -o $issueIdRegex | sort | uniq | cut -d'[' -f2 | cut -d ']' -f1)
    echo $issueIds
}
