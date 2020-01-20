#!/bin/sh

deploySaveDir=/tmp/deploy

setDeploySaveDir() {
    deploySaveDir=$1
}

copyConfigmapYaml() {
    local group=$1
    local type=$2
    local path=$3
    local p=$deploySaveDir/$type-$group-configmap.yaml
    mkdir -p $deploySaveDir

    cat $path >>$p
    echo "" >>$p
    #写入yaml分隔符
    echo "---" >>$p
}

copyDeployYaml() {
    local group=$1
    local type=$2
    local path=$3
    local p=$deploySaveDir/$type-$group-deploy.yaml
    mkdir -p $deploySaveDir

    cat $path >>$p
    echo "" >>$p
    #写入yaml分隔符
    echo "---" >>$p
}

buildAssemblyYaml() {
    local group=$1
    local type=$2
    local dir=$3

    local configmapFiles=$(find $dir -type f -name "*.yaml" | grep "configmap")
    local deployFiles=$(find $dir -type f -name "*.yaml" | grep -v "configmap")

    for f in $configmapFiles; do
        copyConfigmapYaml $group $type $f
    done

    for f in $deployFiles; do
        copyDeployYaml $group $type $f
    done
}
