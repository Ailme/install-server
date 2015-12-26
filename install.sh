#!/bin/bash

#set -eu
#set -o pipefail

export DEBIAN_FRONTEND=noninteractive

CODENAME="$(cat /etc/os-release |grep VERSION= |cut -f 2 -d \(|cut -f 1 -d \))"

if [[ "$UID" -ne "0" ]]; then
    echo 'You must be root'
    exit 1
fi

###

cd /tmp

DEFAULT_PACKAGES="lsb-release aptitude vim supervisor tmux htop mc wget sudo iftop tcpdump ntp man less strace 
 tcpdump telnet sysstat rsync lsof time screen iptraf-ng lftp ftp xterm jq lynx pandoc xmlstarlet curl dstat ncdu
 nethogs pxz pigz pbzip2 autossh git cron inetutils-ping bash-completion xz-utils lxc debootstrap libvirt-bin
 bridge-utils ebtables dnsmasq dkms build-essential"

[[ ! -d /root/.ssh ]] && mkdir /root/.ssh
[[ ! -d /root/bin ]] && mkdir /root/bin
[[ ! -d /root/config ]] && mkdir /root/config

echo "Update timezone"
read -e -p "Enter Timezone: " -i "Europe/Moscow" TIMEZONE

echo $TIMEZONE > /etc/timezone && dpkg-reconfigure -f tzdata

read -e -p "Add $CODENAME backports repository? [Y/n] " -i "Y"
if [[ "$REPLY" == "Y" || "$REPLY" == "y" ]]; then
	echo "deb http://http.debian.net/debian $CODENAME-backports main" >  /etc/apt/sources.list.d/backports.list
	apt-get update

	read -e -p "Upgrade kernel? [Y/n] " -i "n"
	if [[ "$REPLY" == "Y" || "$REPLY" == "y" ]]; then
		apt-cache search -t "$CODENAME"-backports linux-image
		read -e -p "Enter linux-image name: " IMAGE

		apt-cache search -t "$CODENAME"-backports linux-headers
		echo -e -p "Enter linux-headers name: " HEADERS

		apt-get install -t "$CODENAME"-backports "$IMAGE $HEADERS"

		update-grub2
	fi
fi

apt-get update && apt-get -y upgrade

read -e -p "Install default packages? [Y/n] " -i "Y"
if [[ "$REPLY" == "Y" || "$REPLY" == "y" ]]; then
	# read -e -p "The following packages will be installed: " -i "$DEFAULT_PACKAGES" PACKAGES
	apt-get install -y "$DEFAULT_PACKAGES"
fi

virsh net-start default
virsh net-autostart default

virsh net-info default

sysctl -w net.ipv4.ip_forward=1


cat /tmp/install-server-master/ssh-keys/root.pub > /root/.ssh/authorized_keys
ssh-keygen -t dsa

read -e -p "Scan known hosts? [Y/n] " -i "n"
if [[ "$REPLY" == "Y" || "$REPLY" == "y" ]]; then
        read -e -p "Enter hosts for scan: " HOSTS
        ssh-keyscan "$HOSTS" >> /root/.ssh/known_hosts
fi


chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
chmod 400 /root/.ssh/id_dsa

cp -r /tmp/install-server-master/config/ /root/
cp -r /tmp/install-server-master/lxc /root/config/
cp /tmp/install-server-master/lxc/default.conf /etc/lxc/

read -e -p "Add user? [Y/n] " -i "n"
if [[ "$REPLY" == "Y" || "$REPLY" == "y" ]]; then
        read -e -p "username: " NAME
        adduser "$NAME"

	read -e -p "Add user $NAME in sudo? [Y/n] " -i "n"
	[[ "$REPLY" == "Y" || "$REPLY" == "y" ]] && usermod -G sudo "$NAME"

	cp -r /tmp/install-server-master/config/ /home/"$NAME"
	mkdir /home/"$NAME"/.ssh
	cat /tmp/install-server-master/ssh-keys/ta.pub > /root/.ssh/authorized_keys
	cp /root/.ssh/known_hosts /home/"$NAME"/.ssh/

	chmod 700 /home/"$NAME"/.ssh
	chmod 600 /home/"$NAME"/.ssh/authorized_keys
	chmod 400 /home/"$NAME"/.ssh/id_dsa

	chown -R "$NAME":"$NAME" /home/"$NAME"
fi
