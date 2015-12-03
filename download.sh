#!/bin/bash

set -eu
set -o pipefail

export DEBIAN_FRONTEND=noninteractive

if [[ "$UID" -ne "0" ]]; then
	echo 'You must be root'
	exit 1
fi

COLORIZER_URI="https://github.com/jakobwesthoff/colorizer/archive/master.zip"
REPOSITORY_URI="https://github.com/Ailme/install-server/archive/master.zip"

###

cd /tmp

mkdir install-server && cd install-server
wget $REPOSITORY_URI && unzip master.zip && rm master.zip

mkdir colorizer
wget $COLORIZER_URI && unzip master.zip -d colorizer && rm master.zip
