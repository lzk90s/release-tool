#!/bin/sh

htmlRlogFile=

htmlRlogInit() {
    htmlRlogFile=$1

    #truncate file
    true >$htmlRlogFile
    true >$unresolvedIssueFile

    cat <<EOF >>$htmlRlogFile
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<style>
#issuetable,.issue-table {
	background-color: #fff;
	border-collapse: collapse;
	margin: 8px 0;
	width: 100%
}

#issuetable>caption,.issue-table>caption {
	background-color: #f4f5f7;
	border-bottom: 1px solid #c1c7d0;
	caption-side: top;
	color: #7a869a;
	padding: 7px 10px;
	text-align: left
}

#issuetable>tbody>tr,.issue-table>tbody>tr,#issuetable>tfoot>tr,.issue-table>tfoot>tr {
	background-color: #fff;
	color: #172b4d
}

#issuetable>thead>tr>th,.issue-table>thead>tr>th {
	color: #7a869a;
	font-size: 12px;
	white-space: nowrap
}

#issuetable>tbody>tr>th,.issue-table>tbody>tr>th {
	background-color: #fff;
	color: #172b4d
}

#issuetable>thead>tr>th,.issue-table>thead>tr>th,#issuetable>tbody>tr>th,.issue-table>tbody>tr>th,#issuetable>thead>tr>td,.issue-table>thead>tr>td,#issuetable>tbody>tr>td,.issue-table>tbody>tr>td,#issuetable>tfoot>tr>td,.issue-table>tfoot>tr>td {
	border-bottom: 1px solid #c1c7d0;
	overflow: hidden;
	padding: 5px 7px;
	text-align: left;
	vertical-align: top
}

#issuetable>thead .sortable,.issue-table>thead .sortable {
	cursor: pointer
}

#issuetable>thead .sortable:hover,.issue-table>thead .sortable:hover {
	background-color: #f4f5f7
}

#issuetable>thead .active,.issue-table>thead .active {
	color: #7a869a;
	background-color: #f4f5f7
}

#issuetable>thead .active:hover,.issue-table>thead .active:hover {
	background-color: #ebecf0
}

#issuetable>thead .active .issuetable-header-sort-icon,.issue-table>thead .active .issuetable-header-sort-icon {
	position: relative;
	top: -1px
}

#issuetable>thead>tr>th:first-child,.issue-table>thead>tr>th:first-child,#issuetable>tbody>tr>th:first-child,.issue-table>tbody>tr>th:first-child,#issuetable>tbody>tr>td:first-child,.issue-table>tbody>tr>td:first-child {
	border-left: 2px solid transparent
}

#issuetable>tbody>tr:hover,.issue-table>tbody>tr:hover {
	background-color: #ebecf0
}

#issuetable tr.focused,.issue-table tr.focused {
	background-color: #deebff
}

#issuetable tr.focused>td:first-child,.issue-table tr.focused>td:first-child {
	border-left-color: #7a869a
}

#issuetable.hide-carrot tr.issueactioneddissapearing,.issue-table.hide-carrot tr.issueactioneddissapearing,#issuetable.hide-carrot tr.issueactioned,.issue-table.hide-carrot tr.issueactioned {
	background-color: #ffd
}

#issuetable.hide-carrot tr.focused,.issue-table.hide-carrot tr.focused {
	background-color: transparent
}

#issuetable.hide-carrot tr.focused>td:first-child,.issue-table.hide-carrot tr.focused>td:first-child {
	border-left-color: transparent
}

#issuetable.hide-carrot tr.focused:hover,.issue-table.hide-carrot tr.focused:hover {
	background-color: #f4f5f7
}

#issuetable tr.issueactioneddissapearing,.issue-table tr.issueactioneddissapearing,#issuetable tr.issueactioned,.issue-table tr.issueactioned {
	background-color: #ffd
}

#issuetable .rowHeader,.issue-table .rowHeader,#issuetable .rowNormal,.issue-table .rowNormal,#issuetable .rowAlternate,.issue-table .rowAlternate {
	background-color: transparent
}

#issuetable .parentIssue,.issue-table .parentIssue {
	color: #666
}

#issuetable .parentIssue::after,.issue-table .parentIssue::after {
	content: "/";
	padding: 0 0.3em;
	pointer-events: none;
	text-decoration: none
}

#issuetable img,.issue-table img,#issuetable .aui-lozenge,.issue-table .aui-lozenge {
	vertical-align: text-bottom
}

#issuetable td:not(.issuekey, .summary, .stsummary) a,.issue-table td:not(.issuekey, .summary, .stsummary) a,#issuetable td:not(.issuekey, .summary, .stsummary) a.parentIssue,.issue-table td:not(.issuekey, .summary, .stsummary) a.parentIssue {
	color: #172b4d
}

#issuetable .issuetype,.issue-table .issuetype,#issuetable .issuekey,.issue-table .issuekey,#issuetable .priority,.issue-table .priority,#issuetable .status,.issue-table .status {
	white-space: nowrap;
	width: 16px
}

#issuetable .resolution,.issue-table .resolution,#issuetable .created,.issue-table .created,#issuetable .updated,.issue-table .updated {
	max-width: 25em;
	white-space: nowrap
}

#issuetable .assignee,.issue-table .assignee,#issuetable .reporter,.issue-table .reporter,#issuetable .versions,.issue-table .versions,#issuetable .components,.issue-table .components,#issuetable .fixVersions,.issue-table .fixVersions {
	max-width: 60em;
	min-width: 80px
}

#issuetable .versions .tinylink,.issue-table .versions .tinylink,#issuetable .components .tinylink,.issue-table .components .tinylink,#issuetable .fixVersions .tinylink,.issue-table .fixVersions .tinylink {
	white-space: nowrap
}

#issuetable .summary>p,.issue-table .summary>p,#issuetable .description>p,.issue-table .description>p {
	min-width: 300px;
	margin: 0;
	max-width: 1400px;
	white-space: normal
}

#issuetable .issueCount,.issue-table .issueCount {
	text-align: center
}

#issuetable .stsequence,.issue-table .stsequence {
	white-space: nowrap
}

#issuetable td.progress,.issue-table td.progress,#issuetable td.aggregateprogress,.issue-table td.aggregateprogress {
	min-width: 150px;
	max-width: 150px;
	text-align: right;
	width: 150px
}

#issuetable td.progress>table,.issue-table td.progress>table,#issuetable td.aggregateprogress>table,.issue-table td.aggregateprogress>table {
	font-size: 1em;
	margin-top: 2px;
	width: 150px
}

#issuetable td.progress td,.issue-table td.progress td,#issuetable td.aggregateprogress td,.issue-table td.aggregateprogress td {
	line-height: 1;
	padding: 0;
	vertical-align: top
}

#issuetable table.tt_graph,.issue-table table.tt_graph {
	width: 100%
}

#issuetable td.progress td.tt_graph_percentage,.issue-table td.progress td.tt_graph_percentage,#issuetable td.aggregateprogress td.tt_graph_percentage,.issue-table td.aggregateprogress td.tt_graph_percentage {
	color: #999;
	padding-right: 3px;
	min-width: 0;
	width: auto
}

#issuetable td.progress td.tt_graph_percentage p,.issue-table td.progress td.tt_graph_percentage p,#issuetable td.aggregateprogress td.tt_graph_percentage p,.issue-table td.aggregateprogress td.tt_graph_percentage p {
	width: 3em
}

#issuetable td.progress table.tt_graph,.issue-table td.progress table.tt_graph,#issuetable td.aggregateprogress table.tt_graph,.issue-table td.aggregateprogress table.tt_graph {
	height: 6px
}

#issuetable .streorder,.issue-table .streorder {
	width: 10px
}

#issuetable .issuerow.focused .streorder div,.issue-table .issuerow.focused .streorder div,#issuetable .issuerow.issue-table-draggable:hover,.issue-table .issuerow.issue-table-draggable:hover {
	cursor: all-scroll
}

#issuetable .issuerow.issue-table-draggable.ui-sortable-helper,.issue-table .issuerow.issue-table-draggable.ui-sortable-helper {
	cursor: all-scroll;
	border-top: 1px solid #ccc;
	border-left: 1px solid #ccc;
	border-right: 1px solid #ccc;
	background-color: #f4f5f7;
	box-shadow: 0 2px 2px 0 rgba(0,0,0,0.2)
}

#issuetable .subtask-reorder a,.issue-table .subtask-reorder a {
	opacity: 0
}

#issuetable .issuerow:hover .subtask-reorder a,.issue-table .issuerow:hover .subtask-reorder a,#issuetable .issuerow .subtask-reorder a:focus,.issue-table .issuerow .subtask-reorder a:focus {
	opacity: 1
}

#issuetable .issuerow .issue-actions-trigger,.issue-table .issuerow .issue-actions-trigger {
	opacity: 0
}

#issuetable .issuerow.focused .issue-actions-trigger:hover,.issue-table .issuerow.focused .issue-actions-trigger:hover,#issuetable .issuerow:hover .issue-actions-trigger,.issue-table .issuerow:hover .issue-actions-trigger,#issuetable .issuerow .issue-actions-trigger:focus,.issue-table .issuerow .issue-actions-trigger:focus,#issuetable .issuerow .issue-actions-trigger.active,.issue-table .issuerow .issue-actions-trigger.active {
	opacity: 1
}

#issuetable .issuerow .issue-actions-trigger.active,.issue-table .issuerow .issue-actions-trigger.active {
	border: 1px solid #ccc
}

.count-pagination {
	clear: both;
	padding: 8px 0;
	table-layout: auto
}

.count-pagination .pagination {
	font-size: 0;
	text-align: right;
	white-space: nowrap
}

.count-pagination .pagination>a,.count-pagination .pagination>strong,.count-pagination .pagination>span {
	font-size: 14px;
	line-height: 1;
	height: auto;
	margin: 0 0 0 .15em;
	padding: .1em;
	position: relative;
	vertical-align: bottom
}

.count-pagination .aui-icon-small::before {
	margin-top: -7px;
	color: #42526e
}

.msie .count-pagination .aui-icon-small::before {
	margin-top: -6px;
	color: #42526e
}

.results-count-start,.results-count-end,.results-count-total {
	font-weight: bold
}

.msie #issuetable .issuekey,.msie .issuetable .issuekey,.msie #issuetable .status,.msie .issuetable .status {
	width: 1%
}

.gadget #issuetable .parentIssue,.gadget .issuetable .parentIssue {
	background-position: 100% 1px
}

.gadget #issuetable .summary>p,.gadget .issuetable .summary>p,.gadget #issuetable .description>p,.gadget .issuetable .description>p {
	margin: 0;
	min-width: 100px
}

.gadget #issuetable tr.hover .issue_actions a.aui-dd-link,.gadget .issuetable tr.hover .issue_actions a.aui-dd-link {
	left: 0;
	top: 0
}

a.hidden-link {
	display: block;
	font-size: 0;
	height: 1px;
	line-height: 0;
	outline: 0 none white;
	width: 1px
}

a.hidden-link span {
	display: none
}

#bulkedit .jira-issue-status-icon {
	vertical-align: middle
}
</style>
</head>
<body>
<h1>版本变更记录</h1>
EOF
}

htmlRlogBegin() {
    cat <<EOF >>$htmlRlogFile
<table class="issue-table">
<thead>
  <tr class="rowHeader">
    <th class="colHeaderLink sortable headerrow-issuetype" rel="issuetype:DESC" data-id="issuetype" onclick="window.document.location='$jira_host/issues/?jql=ORDER%20BY%20%22issuetype%22%20DESC'">
      <span title="排序 问题类型">T</span></th>
    <th class="colHeaderLink sortable headerrow-issuekey" rel="issuekey:ASC" data-id="issuekey" onclick="window.document.location='$jira_host/issues/?jql=ORDER%20BY%20%22issuekey%22%20ASC'">
      <span title="排序 关键字">关键字</span></th>
    <th class="colHeaderLink sortable headerrow-summary" rel="summary:ASC" data-id="summary" onclick="window.document.location='$jira_host/issues/?jql=ORDER%20BY%20%22summary%22%20ASC'">
      <span title="排序 概要">概要</span></th>
    <th class="colHeaderLink sortable headerrow-assignee" rel="assignee:ASC" data-id="assignee" onclick="window.document.location='$jira_host/issues/?jql=ORDER%20BY%20%22assignee%22%20ASC'">
      <span title="排序 经办人">经办人</span></th>
    <th class="colHeaderLink sortable headerrow-assignee" rel="assignee:ASC" data-id="assignee">
      <span title="排序 工程">工程</span></th>
    <th class="colHeaderLink sortable headerrow-assignee" rel="assignee:ASC" data-id="assignee">
      <span title="排序 版本">版本</span></th>
  </tr>
</thead>
<tbody>
EOF
}

htmlRlogEnd() {
    echo "</tbody>" >>$htmlRlogFile
}

htmlRlogWriteIssue() {
    local issueId=$1
    local projectName=$2
    local versiondiff=$3
    local detail=$(queryIssueDetail $issueId)
    local summary=$(parseIssueSummaryFromMsg $detail)
    local assignee=$(parseIssueAssigneeFromMsg $detail)
    local issuetypeIcon=$(parseIssueTypeIconFromMsg $detail)
    local issueUrl=$(buildIssueBrowseUrl $issueId)
    local status=$(parseIssueStatusFromMsg $detail)

    #记录未解决的问题
    if [ "$status" != "已解决" -a "$status" != "已关闭" ]; then
        addUnresolvedIssue "[$projectName] [$issueId] [$assignee] $summary"
    fi

    cat <<EOF >>$htmlRlogFile
<tr>
  <td class="issuetype">
    <a class="issue-link" data-issue-key="$issue_id" href="$issue_url">
      <img src="$issuetype_icon" height="16" width="16" border="0" align="absmiddle" /></a>
  </td>
  <td class="issuekey">
    <a class="issue-link" data-issue-key="$issue_id" href="$issue_url">$issue_id</a></td>
  <td class="summary">
    <p>
      <a class="issue-link" data-issue-key="$issue_id" href="$issue_url">$summary</a></p>
  </td>
  <td class="assignee">
    <span>$assignee</a></span>
  </td>
  <td class="project">
    <span>$project_name</a></span>
  </td>
  <td class="versiondiff">
    <span>$versiondiff</a></span>
  </td>
</tr>
EOF
}
