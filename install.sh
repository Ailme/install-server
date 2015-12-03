#!/bin/bash

set -eu
set -o pipefail

export DEBIAN_FRONTEND=noninteractive

if [[ "$UID" -ne "0" ]]; then
	echo 'You must be root'
	exit 1
fi

TIMEZONE="Europe/Moscow"

###

cd /tmp

[[ ! -d ~/.ssh ]] && mkdir ~/.ssh

colorize "<green>Update timezone</green>"
echo $TIMEZONE > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata
