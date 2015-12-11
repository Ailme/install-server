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

wget --no-check-certificate -O $COLORIZER_ZIP $COLORIZER_URI && unzip $COLORIZER_ZIP -d /tmp
[[ ! -d /usr/bin/colorizer-master ]] && mv /tmp/colorizer-master /usr/bin/
[[ ! -r /usr/bin/colorizer ]] && ln -s /usr/bin/colorizer-master/Library/colorizer.sh /usr/bin/colorizer
rm $COLORIZER_ZIP

wget --no-check-certificate -O $REPO_ZIP $REPO_URI && unzip $REPO_ZIP -d /tmp
rm $REPO_ZIP
bash /tmp/install-server-master/install.sh
