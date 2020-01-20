#!/bin/sh

jiraHost=https://jira.gosuncs.com:520
baseUrl=$jiraHost/browse/
restApiBaseUrl=$jiraHost/rest/api/2
unresolvedIssueFile=/tmp/.unresolvedIssue

addUnresolvedIssue() {
    echo "$@" >>$unresolvedIssueFile
}

hasUnresolvedIssues() {
    cat $unresolvedIssueFile | wc -w
}

dumpUnresolvedIssues() {
    cat $unresolvedIssueFile
}

buildIssueBrowseUrl() {
    local issueId=$1
    if [ "$issueId" = "" ]; then
        echo ""
    else
        echo $baseUrl$issueId
    fi
}

issueFields='summary,assignee,issuetype,status'
buildIssueQueryRestUrl() {
    local issueId=$1
    local url=${restApiBaseUrl}/issue/${issueId}?fields=$issueFields
    echo $url
}

jiraIssueCurlQueryArgs="--user zk.liu@hzgosun.com:lzk@123580 -m 10 -s"
queryIssueDetail() {
    local issueId=$1

    local url=$(buildIssueQueryRestUrl $issueId)
    local jsonData=$(curl $jiraIssueCurlQueryArgs $url)
    echo $jsonData
}

parseIssueSummaryFromMsg() {
    local jsonData=$@
    local summary=$(echo $jsonData | jq '.fields.summary' | sed 's/\"//g')
    echo $summary
}

parseIssueAssigneeFromMsg() {
    local jsonData=$@
    local assignee=$(echo $jsonData | jq '.fields.assignee.displayname' | sed 's/\"//g')
    echo $assignee
}

parseIssueTypeFromMsg() {
    local jsonData=$@
    local issueType=$(echo $jsonData | jq '.fields.issuetype.name' | sed 's/\"//g')
    echo $issueType
}

parseIssueTypeIconFromMsg() {
    local jsonData=$@
    local issueType=$(echo $jsonData | jq '.fields.issuetype.iconurl' | sed 's/\"//g')
    echo $issueType
}

parseIssueStatusFromMsg() {
    local jsonData=$@
    local status=$(echo $jsonData | jq '.fields.status.name' | sed 's/\"//g')
    echo $status
}
