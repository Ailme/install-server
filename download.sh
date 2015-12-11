#!/bin/bash

set -eu
set -o pipefail

if [[ "$UID" -ne "0" ]]; then
    echo 'You must be root'
    exit 1
fi

if [[ ! $(which unzip) ]]; then
    echo "Need install unzip"
    apt-get install -y unzip
fi

COLORIZER_ZIP=colorizer.zip
REPO_ZIP=colorizer.zip
COLORIZER_URI="https://github.com/jakobwesthoff/colorizer/archive/master.zip"
REPO_URI="https://github.com/Ailme/install-server/archive/master.zip"

###

cd /tmp

echo "[$(date +%T)] download colorizer"
wget --no-check-certificate -O $COLORIZER_ZIP $COLORIZER_URI

echo "[$(date +%T)] unzip archive"
unzip $COLORIZER_ZIP -d /tmp

echo "[$(date +%T)] check and remove older version"
[[ ! -d /usr/bin/colorizer-master ]] && rm -rf /usr/bin/colorizer-master

echo "[$(date +%T)] copy"
mv /tmp/colorizer-master /usr/bin/

echo "[$(date +%T)] create link"
[[ ! -r /usr/bin/colorizer ]] && ln -s /usr/bin/colorizer-master/Library/colorizer.sh /usr/bin/colorizer

echo "[$(date +%T)] remove archive"
rm $COLORIZER_ZIP

echo "[$(date +%T)] download installer"
wget --no-check-certificate -O $REPO_ZIP $REPO_URI

echo "[$(date +%T)] unzip archive"
unzip $REPO_ZIP -d /tmp

echo "[$(date +%T)] remove archive"
rm $REPO_ZIP

echo "[$(date +%T)] run install script"
bash /tmp/install-server-master/install.sh
