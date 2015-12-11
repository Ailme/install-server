#!/bin/bash

#set -eu
#set -o pipefail

if [[ "$UID" -ne "0" ]]; then
	echo 'You must be root'
	exit 1
fi

###

cd /tmp

DEFAULT_PACKAGES="lsb-release aptitude vim supervisor tmux htop mc wget sudo iftop tcpdump ntp man less strace \
 tcpdump telnet sysstat rsync lsof time screen iptraf-ng lftp ftp xterm jq lynx pandoc xmlstarlet curl dstat ncdu \
 nethogs pxz pigz pbzip2 autossh git cron inetutils-ping bash-completion xz-utils lxc debootstrap libvirt-bin \
 bridge-utils ebtables dnsmasq dkms build-essential"

[[ ! -d /root/.ssh ]] && mkdir /root/.ssh
[[ ! -d /root/bin ]] && mkdir /root/bin
[[ ! -d /root/config ]] && mkdir /root/config

echo "Update timezone"
read -e -p "Enter Timezone: " -i "Europe/Moscow" TIMEZONE

echo $TIMEZONE > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

read -e -p "Add jessie-backports repository? " -i "Y" YES
if [[ "$YES" == "Y" || "$YES" == "y" ]]; then
	echo "deb http://http.debian.net/debian jessie-backports main" >  /etc/apt/sources.list.d/backports.list
	apt-get update

	read -e -p "Upgrade kernel? " -i "n" YES
	if [[ "$YES" == "Y" || "$YES" == "y" ]]; then
		apt-cache search -t jessie-backports linux-image
		echo -n "Paste linux-image name: "
		read IMAGE

		apt-cache search -t jessie-backports linux-headers
		colorize -n "<yellow>Paste linux-headers name:</yellow> "
		read HEADERS

		apt-get install -t jessie-backports "$IMAGE" "$HEADERS"

		update-grub2
	fi
fi

apt-get update && apt-get -y upgrade

read -e -p "Install default packages? " -i "Y" YES
if [[ "$YES" == "Y" || "$YES" == "y" ]]; then
	read -e -p "The following packages will be installed: " -i $DEFAULT_PACKAGES PACKAGES
	apt-get install -y "$PACKAGES"
fi

virsh net-start default
virsh net-autostart default

virsh net-info default

sysctl -w net.ipv4.ip_forward=1


cat ./ssh-keys/root.pub > /root/.ssh/authorized_keys
ssh-keygen -t dsa

read -e -p "Scan known hosts? " -i "n" YES
if [[ "$YES" == "Y" || "$YES" == "y" ]]; then
        read -e -p "hosts for scan: " -i "" HOSTS
        ssh-keyscan "$HOSTS" >> /root/.ssh/known_hosts
fi


chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
chmod 400 /root/.ssh/id_dsa

cp -r ./config/ /root/
cp -r ./lxc /root/config/
cp ./lxc/default.conf /etc/lxc/

read -e -p "Add user? " -i "n" YES
if [[ "$YES" == "Y" || "$YES" == "y" ]]; then
        read -e -p "username: " -i "" NAME
        adduser "$NAME"

	read -e -p "Add $NAME in sudo? " -i "n" YES
	[[ "$YES" == "Y" || "$YES" == "y" ]] && usermod -G sudo "$NAME"

	cp -r ./config/ /home/"$NAME"
	mkdir /home/"$NAME"/.ssh
	cat ./ssh-keys/ta.pub > /root/.ssh/authorized_keys
	cp /root/.ssh/known_hosts /home/"$NAME"/.ssh/

	chmod 700 /home/"$NAME"/.ssh
	chmod 600 /home/"$NAME"/.ssh/authorized_keys
	chmod 400 /home/"$NAME"/.ssh/id_dsa

	chown -R "$NAME":"$NAME" /home/"$NAME"
fi
