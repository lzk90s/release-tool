# release-tool

[![pipeline status](http://gitlab.gosuncs.com:10080/service/tools/release-tool/badges/master/pipeline.svg)](http://39.104.159.10:10080/service/tools/release-tool/commits/master)

## 变量说明
变量名 | 说明 | 是否必填 | 默认值
:---|:---|:---|:---
RELEASE_VERSION | 发布版本号，例如1.0.0 |必须 | 无
NEXT_DEV_VERSION | 下一个开发版本号，例如1.0.0-SNAPSHOT | 必须 | 无
PUSH | 是否推送到远程仓库，true/false |必须 | false
PROJECTS | 工程，多个以空格分隔【可选，若为空，从PROJECT_FILE获取】 | 非必须 | 空
PROJECT_FILE | 工程文件【可选】 | 非必须 | 无
ONLY_PUSH_CHANGED_PROJECT | 仅推送变更的工程 | 否 | false
AUTO_INCREASE_VERSION | 自动增加版本号（仅针对stable分支） | 否 | false


## 版本发布流程

### 需求阶段
* 规划本次版本的内容

### 开发阶段
* 使用带SNAPSHOT的版本号，例如1.0.0-SNAPSHOT
* 使用issue方式merge到master中，不要把非当前版本的特性合入master中

### 提测阶段
* 转测试时，发布RC(n)版本，例如1.0.0-RC1, 1.0.0-RC2，1.0.0-RC3，截止到测试认为已符合发布标准
* 转测试期间，不要往master分支合入新特性，只能解决bug

### 发布阶段
* 提测结束后，发布正式版本，生成发布分支，例如stable-1.0.x，发布版本1.0.0
* master进入下一个开发版本1.1.0-SNAPSHOT

### 维护阶段
* 当线上发现问题时，通过issue方式合入master，并cherry pick到特定的stable-x.x.x分支上

## 版本发布规则
* 版本号遵循语义化版本号规则：a.b.c，a为主版本号，b为次版本号，c为补丁版本号
* 分支模型遵循gitlab版本分支模型，详见[gitlab flow](https://docs.gitlab.com/ee/workflow/gitlab_flow.html)
* master为开发分支，a.b.x-stable为发布分支（例如：1.0.x-stable，1.2.x-stable）
* 根据当前版本号打tag，tag规则为：版本号前加v，例如v1.0.0
* 当NEW_VERSION的补丁版本号为0时，表示是大版本或者次版本迭代更新，会自动创建a.b.x-stable分支，反之，则不会自动创建发布分支
* 自动更新.deploy/k8s/*.yaml文件中的版本号到NEW_VERSION
* 支持maven工程（根路径下有pom.xml）和普通工程（根路径下无pom.xml，有VERSION文件）

## 自动生成版本CHANGELOG
* 版本发布时，默认会自动生成最近的一个release版本到当前release版本tag之间的所有服务的CHANGELOG
* CHANGELOG会通过邮件自动发送到指定的邮箱，邮箱指定方法见工程 /service/tools/devops-robot
* 如果commit中带了JIRA ISSUE号，生成的CHANGELOG中会自动添加对应ISSUE的超链接

## 附录
* [语义化版本](https://semver.org/lang/zh-CN/)
* [gitlab flow](https://docs.gitlab.com/ee/workflow/gitlab_flow.html)