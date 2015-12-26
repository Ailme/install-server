#!/bin/bash

#set -eu
#set -o pipefail

if [[ "$UID" -ne "0" ]]; then
    echo 'You must be root'
    exit 1
fi

if [[ ! $(which unzip) ]]; then
    echo "Need install unzip"
    apt-get install -y unzip
fi

if [[ ! $(which wget) ]]; then
    echo "Need install wget"
    apt-get install -y wget
fi

REPO_ZIP=repo.zip
REPO_URI="https://github.com/Ailme/install-server/archive/master.zip"

###

cd /tmp

if [[ -d /tmp/install-server-master ]]; then
    read -e -p "folder /tmp/install-server-master exist. Remove before download? " -i "Y" CMD
    [[ "$CMD" == "Y" || "$CMD" == "y" ]] && rm -rf /tmp/install-server-master
fi

echo "[$(date +%T)] download installer"
wget --no-check-certificate -O $REPO_ZIP $REPO_URI

echo "[$(date +%T)] unzip archive"
unzip $REPO_ZIP -d /tmp

echo "[$(date +%T)] remove archive"
rm $REPO_ZIP

echo "[$(date +%T)] run install script"
bash /tmp/install-server-master/install.sh
