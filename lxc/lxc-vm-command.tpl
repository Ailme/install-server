#!/bin/bash

set -eu
set -o pipefail

# Author: Alexandr Tumaykin <alexandrtumaykin@gmail.com>

if [[ -r /usr/bin/colorizer ]]; then
    . /usr/bin/colorizer
else
    colorize() {
        echo $1
    }
fi

CONTAINER_NAME="{{CONTAINER_NAME}}"
LINK_CONTAINERS="{{LINK_CONTAINERS}}"
DOMAIN_NAME=
PORT_SRC=
PORT_DEST=
USE_IPTABLES=0
HOSTS=/etc/hosts
LXC_HOSTS=/var/lib/lxc/$CONTAINER_NAME/rootfs/etc/hosts

#
# Function that starts the daemon/service
#
do_start()
{
    # Return
    #   0 if daemon has been started
    #   1 if daemon was already running
    lxc-info -sn $CONTAINER_NAME | grep -qv RUNNING > /dev/null || return 0

    colorize "<green>Starting container $CONTAINER_NAME ...</green>"
    lxc-start -n $CONTAINER_NAME -d

    while : ; do
        IP=$(lxc-info -in $CONTAINER_NAME | awk {'print $2'})
        [[ -n "$IP" ]] && break
    done
    colorize "<green>IP: $IP</green>"

    # обновляем запись в файле hosts
    if [[ -w $HOSTS ]]; then
        sed -i "/$CONTAINER_NAME/ d" $HOSTS
        echo "$IP $CONTAINER_NAME" >> $HOSTS
        colorize "<green>File $HOSTS updated</green>"
    else
        colorize "<red>Error: file $HOSTS is not writable</red>"
    fi

    # обновляем записи в файле hosts контейнера
    if [[ -w $LXC_HOSTS ]]; then
        sed -i "/### lxc-vm-begin/,/### lxc-vm-end/ d" $LXC_HOSTS
        echo "### lxc-vm-begin" >> $LXC_HOSTS

        for LINK in $LINK_CONTAINERS; do
            if [[ -n $(lxc-ls --active $LINK) ]]; then
                IP=$(lxc-info -in $LINK | awk {'print $2'})
                echo "$IP $LINK" >> $LXC_HOSTS
            fi
        done
        echo "### lxc-vm-end" >> $LXC_HOSTS
        colorize "<green>File $LXC_HOSTS updated</green>"
    else
        colorize "<red>Error: file $LXC_HOSTS is not writable</red>"
    fi

    if [[ "$USE_IPTABLES" == 1 && -n "$PORT_SRC" && -n "$PORT_DEST" ]]; then
		iptables-nat add $PORT_SRC $IP:$PORT_DEST
        echo "iptables rules updated"
    fi

    return 0
}

#
# Function that stops the daemon/service
#
do_stop()
{
    # Return
    #   0 if daemon has been stopped
    #   1 if daemon was already stopped
    #   other if a failure occurred
    lxc-info -sn $CONTAINER_NAME | grep -qv STOPPED > /dev/null || return 0

    colorize "<green>Stoping container $CONTAINER_NAME ...</green>"

    IP=$(lxc-info -in $CONTAINER_NAME | awk {'print $2'})
    colorize "<green>IP: $IP</green>"
    lxc-stop -n $CONTAINER_NAME

    if [[ "$USE_IPTABLES" == 1 && -n "$PORT_SRC" && -n "$PORT_DEST" ]]; then
		iptables-nat del $PORT_SRC $IP:$PORT_DEST
        echo "iptables rules updated"
    fi

    return 0
}

case "$1" in
    start)
        do_start
        case "$?" in
            0|1) exit 0 ;;
            2) exit 1 ;;
        esac
        ;;
    stop)
        do_stop
        case "$?" in
            0|1) exit 0 ;;
            2) exit 1 ;;
        esac
        ;;
    restart)
        do_stop
        case "$?" in
            0|1)
                do_start
                case "$?" in
                    0) exit 0 ;;
                    1) exit 1 ;; # Old process is still running
                    *) exit 1 ;; # Failed to start
                esac
                ;;
            *)
                # Failed to stop
                exit 1
                ;;
        esac
        ;;
    status)
        lxc-info -n $CONTAINER_NAME
        lxc-info -n $CONTAINER_NAME | grep RUNNING && exit 0 || exit $?
        ;;
    *)
        echo "Usage: $NAME {start|stop|restart|status}" >&2
        exit 3
        ;;
esac
