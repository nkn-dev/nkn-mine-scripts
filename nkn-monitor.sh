#!/bin/bash
pid=`ps -ef | grep nknd | grep -v grep | awk '{print $2}'`
if [ -z "$pid" ];
then
    rm -rf /home/nkn/nkn-mine/Log/*

    cd /home/nkn/nkn-mine

    WALLET_PASSWD=$(cat ./wallet.pswd)

    /usr/bin/nohup ./nknd -p $WALLET_PASSWD --no-nat > /dev/null 2>&1 &
fi
exit 0
