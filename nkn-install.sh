#!/bin/bash

function check_current_dir() {
    current_dir=$(pwd)
}

function init_something() {

    chain_data=Chain_634205
    nkn_run_dir=nkn-mine

    rm -rf $current_dir/nkn
    rm -rf $current_dir/linux-*
    rm -rf $current_dir/Chain_*
    rm -rf $current_dir/nkn-releases.xml

}

function get_beneficiary_addr () {
    beneficiary_addr=$1

    if [ "N" != "${beneficiary_addr:0:1}" ]
    then
      echo "nkn address error 'N' start"
      exit 0
    fi

    if [ ${#beneficiary_addr} -ne 34 ]
    then
      echo "nkn address error"
      exit 0
    fi
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
    wget https://github.com/nknorg/nkn/releases.atom -O $current_dir/nkn-releases.xml
    nkn_latest_version=$(grep -E -o -e 'releases/tag/.+"/>' $current_dir/nkn-releases.xml | sed 's/releases\/tag\///g' | sed 's/"\/>//g' | sed -n '1p')
    nkn_latest_version_first_letter=${nkn_latest_version:0:1}

    rm -rf $current_dir/nkn-releases.xml
    if [ "v" != "$nkn_latest_version_first_letter" ]
    then
        echo "get latest version error"
        exit 0
    fi
}

function install_unzip_psmisc() {
    if [[ ! -f /etc/redhat-release ]]
    then
        sudo apt-get update
        sudo apt-get install -y unzip psmisc
    else
        sudo yum install -y unzip psmisc
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

function initConfig () {
    cd $current_dir/$nkn_run_dir

    cat <<EOF > ./config.json
{
  "HttpWsPort": 30002,
  "HttpJsonPort": 30003,
  "SeedList": [
    "http://testnet-seed-0001.nkn.org:30003",
    "http://testnet-seed-0002.nkn.org:30003",
    "http://testnet-seed-0003.nkn.org:30003",
    "http://testnet-seed-0004.nkn.org:30003",
    "http://testnet-seed-0005.nkn.org:30003",
    "http://testnet-seed-0006.nkn.org:30003",
    "http://testnet-seed-0007.nkn.org:30003",
    "http://testnet-seed-0008.nkn.org:30003"
  ],
  "GenesisBlockProposer": "022d52b07dff29ae6ee22295da2dc315fef1e2337de7ab6e51539d379aa35b9503",
  "BeneficiaryAddr": "${beneficiary_addr}",
  "SyncBatchWindowSize": 128,
  "LogLevel": 2
}
EOF
    cd $current_dir
}

function initWallet () {

    cd $current_dir/$nkn_run_dir

    RANDOM_PASSWD=$(head -c 1024 /dev/urandom | shasum -a 512 -b | xxd -r -p | base64 | head -c 32)
    ./nknc wallet -c <<EOF
${RANDOM_PASSWD}
${RANDOM_PASSWD}
EOF
    echo ${RANDOM_PASSWD} > ./wallet.pswd
    chmod 0400 wallet.dat wallet.pswd

    cd $current_dir
}

function auto_update_set() {
    echo "$nkn_latest_version" > $current_dir/$nkn_run_dir/nkn-version

    

}

function download_chain_data() {
    wget -N https://storage.googleapis.com/nkn-testnet-snapshot/$chain_data.zip
    sleep 1
    unzip $chain_data.zip
    sleep 1
    mv Chain $current_dir/$nkn_run_dir/Chain
}


function create_nkn_user() {
    if [ "linux" = "$release" ]
    then
        id -u nkn
        if [ $? -ne 0 ];
        then
            rm -rf /home/nkn
            sudo useradd nkn -m
            sudo -u nkn mkdir -p /home/nkn/
        fi
    fi
}

function mv_to_nkn_user_home () {
    sudo mv $current_dir/$nkn_run_dir /home/nkn/$nkn_run_dir
    sudo chown -R nkn:nkn /home/nkn/$nkn_run_dir
}


function gen_nkn_monitor_and_update () {
    cd $current_dir/$nkn_run_dir

    wget https://xxx/nkn-monitor.sh -O $current_dir/$nkn_run_dir/nkn-monitor.sh
    wget https://xxx/nkn-update.sh -O $current_dir/$nkn_run_dir/nkn-update.sh

    chmod +x ./nkn-monitor.sh
    chmod +x ./nkn-update.sh
    cd $current_dir

}

function add_nkn_crontab() {

    sudo -u nkn echo "# nkn crontab" > conf
    sudo -u nkn echo "* * * * * /home/nkn/$nkn_run_dir/nkn-monitor.sh &" >> conf
    sudo -u nkn crontab conf
    sudo rm -f conf

}

# get script run dir
check_current_dir

# get beneficiary addr
get_beneficiary_addr $1

# init
init_something

# check sys (linux Darwin)
check_sys

# check sys version (X86_64 32)
check_version

install_unzip_psmisc


check_nkn_latest_version
download_nkn_latest
initConfig
initWallet
download_chain_data
gen_nkn_monitor


create_nkn_user

mv_to_nkn_user_home
add_nkn_crontab
