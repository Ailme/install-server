#!/bin/bash

set -eu
set -o pipefail

if [[ "$UID" -ne "0" ]];then
	echo 'You must be root to install LXC Web Panel !'
	exit
fi

mkdir ~/.ssh
