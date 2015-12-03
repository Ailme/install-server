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

COLORIZER_URI="https://github.com/jakobwesthoff/colorizer/archive/master.zip"
REPOSITORY_URI="https://github.com/Ailme/install-server/archive/master.zip"

###

cd /tmp

wget --no-check-certificate $REPOSITORY_URI && unzip master.zip -d /tmp && rm master.zip
wget --no-check-certificate $COLORIZER_URI && unzip master.zip -d /tmp  && rm master.zip

[[ ! -d /usr/bin/colorizer-master ]] && mv /tmp/colorizer-master /usr/bin/
[[ ! -r /usr/bin/colorizer ]] && ln -s /usr/bin/colorizer-master/Library/colorizer.sh /usr/bin/colorizer

bash /tmp/install-server-master/install.sh
