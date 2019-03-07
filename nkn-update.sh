#!/bin/bash

function init_somthing() {
    nkn_run_dir=/home/nkn/nkn-mine
}

function check_nkn_latest_version() {
    # cd $nkn_run_dir
    wget https://github.com/nknorg/nkn/releases.atom -O $nkn_run_dir/nkn-releases.xml
    nkn_latest_version=$(grep -E -o -e 'releases/tag/.+"/>' $current_dir/nkn-releases.xml | sed 's/releases\/tag\///g' | sed 's/"\/>//g' | sed -n '1p')
    rm -rf $nkn_run_dir/nkn-releases.xml
    if [ "v" != "${nkn_latest_version:0:1}" ]
    then
        echo "get latest version error"
        exit 0
    fi
}

function download_nkn_latest() {
    wget -N https://github.com/nknorg/nkn/releases/download/$nkn_latest_version/$nkn_zip_name.zip
    sleep 1
    unzip $nkn_zip_name.zip
    sleep 1
    mv $nkn_zip_name $nkn_run_dir
    mkdir -p $current_dir/$nkn_run_dir/Log
}

