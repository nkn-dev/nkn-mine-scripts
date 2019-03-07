#!/bin/bash

function init_somthing() {
    nkn_run_dir=/home/nkn/nkn-mine
}

function check_sys(){
    UNAME_S=$(uname -s)     # Darwin
    release=linux
    if [ "Darwin" = "$UNAME_S" ]
    then
        release=darwin
        echo "this script not support for mac os"
        exit 0
    fi
}

function check_version(){
    bit=`uname -m`
    if [[ ${bit} = "x86_64" ]]; then
        bit="64"
        nkn_zip_name=$release-amd64
    else
        bit="32"
        nkn_zip_name=$release-386
    fi
}

function check_nkn_latest_version() {
    # cd $nkn_run_dir
    wget https://github.com/nknorg/nkn/releases.atom -O $nkn_run_dir/nkn-releases.xml

    nkn_latest_version=$(grep -E -o -e 'releases/tag/.+"/>' $nkn_run_dir/nkn-releases.xml | sed 's/releases\/tag\///g' | sed 's/"\/>//g' | sed -n '1p')

    rm -rf $nkn_run_dir/nkn-releases.xml

    if [ "v" != "${nkn_latest_version:0:1}" ]
    then
        echo "get latest version error"
        exit 0
    fi

    nkn_local_version=`cat $nkn_run_dir/nkn-version`

    if [ "$nkn_local_version" = "$nkn_latest_version" ]
    then
        echo "local: $nkn_local_version"
        echo "latest: $nkn_latest_version"
        echo "no need update"
        exit 0
    fi

}

function do_nkn_update() {

    wget -N https://github.com/nknorg/nkn/releases/download/$nkn_latest_version/$nkn_zip_name.zip
    sleep 1
    unzip $nkn_zip_name.zip
    sleep 1

    if [ -d "$nkn_run_dir/$nkn_zip_name" ]
    then
        rm -rf $nkn_run_dir/nknd
        rm -rf $nkn_run_dir/nknc

        echo "mv $nkn_run_dir/$nkn_zip_name/nknd $nkn_run_dir/nknd"
        echo "mv $nkn_run_dir/$nkn_zip_name/nknc $nkn_run_dir/nknc"

        mv $nkn_run_dir/$nkn_zip_name/nknd $nkn_run_dir/nknd
        mv $nkn_run_dir/$nkn_zip_name/nknc $nkn_run_dir/nknc

        killall -q -9 nknd
        killall -q -9 nknd
        killall -q -9 nknd

        echo "$nkn_latest_version" > $nkn_run_dir/nkn-version
        echo "$nkn_latest_version" > $nkn_run_dir/nkn-version

    else
        echo "update error"
    fi

        rm -rf $nkn_run_dir/$nkn_zip_name
        rm -rf $nkn_run_dir/$nkn_zip_name.zip
}

sleep 10

init_somthing

check_sys

check_version

check_nkn_latest_version

do_nkn_update
