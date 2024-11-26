#!/bin/bash

export PATH="/usr/bin:/bin:/usr/sbin:/sbin"
export DEBIAN_FRONTEND="teletype"
export LC_CTYPE=C
export LC_COLLATE=C

ROOTFS_DIR="$(realpath ${1:-rootfs} 2>/dev/null)"

if [ $? -ne 0 ]; then
  echo "Invalid rootfs dir."
	exit 1
fi

if [[ ! -d $ROOTFS_DIR ]]; then
    echo "Cannot access '$ROOTFS_DIR': No such file or directory"
    exit 2
fi

__clean_up() {
    for dir in $(mount | grep "$ROOTFS_DIR/" | awk '{print $3}'); do
        mount | grep -q "on $dir type" && umount -v --lazy --recursive $dir
    done

    [ -f $ROOTFS_DIR/etc/.pwd.lock ]                && rm -rfv $ROOTFS_DIR/etc/.pwd.lock
    [ -f $ROOTFS_DIR/etc/passwd- ]                  && rm -rfv $ROOTFS_DIR/etc/passwd-
    [ -f $ROOTFS_DIR/etc/group- ]                   && rm -rfv $ROOTFS_DIR/etc/group-
    [ -f $ROOTFS_DIR/etc/shadow- ]                  && rm -rfv $ROOTFS_DIR/etc/shadow-
    [ -f $ROOTFS_DIR/etc/gshadow- ]                 && rm -rfv $ROOTFS_DIR/etc/gshadow-
    [ -f $ROOTFS_DIR/var/lib/dpkg/diversions-old ]  && rm -rfv $ROOTFS_DIR/var/lib/dpkg/diversions-old
    [ -f $ROOTFS_DIR/var/lib/dpkg/status-old ]      && rm -rfv $ROOTFS_DIR/var/lib/dpkg/status-old
    #[ -f $ROOTFS_DIR/etc/resolv.conf ]              && rm -rfv $ROOTFS_DIR/etc/resolv.conf

    exit 0
}

trap __clean_up SIGINT

mount -v none	-t devtmpfs  $ROOTFS_DIR/dev             -o defaults,size=0                                             || __clean_up
mount -v none	-t devpts    $ROOTFS_DIR/dev/pts         -o defaults                                                    || __clean_up
mount -v none	-t tmpfs     $ROOTFS_DIR/media           -o defaults,size=100%,nr_inodes=0,mode=0775                    || __clean_up
mount -v none	-t tmpfs     $ROOTFS_DIR/mnt             -o defaults,size=100%,nr_inodes=0,mode=0775                    || __clean_up
mount -v none	-t proc      $ROOTFS_DIR/proc            -o defaults                                                    || __clean_up
mount -v none	-t tmpfs     $ROOTFS_DIR/root            -o defaults,size=100%,nr_inodes=0,mode=0700                    || __clean_up
mount -v none	-t tmpfs     $ROOTFS_DIR/run             -o defaults,size=100%,nr_inodes=0,mode=0775                    || __clean_up
mount -v none	-t tmpfs     $ROOTFS_DIR/run/lock        -o defaults,size=100%,nr_inodes=0,nosuid,nodev,noexec --mkdir  || __clean_up
mount -v none	-t sysfs     $ROOTFS_DIR/sys             -o defaults                                                    || __clean_up
mount -v none	-t tmpfs     $ROOTFS_DIR/tmp             -o defaults,size=100%,nr_inodes=0,mode=1777,nosuid,nodev       || __clean_up
mount -v none	-t tmpfs     $ROOTFS_DIR/var/cache       -o defaults,size=100%,nr_inodes=0,mode=0755                    || __clean_up
mkdir -pv $ROOTFS_DIR/var/lib/apt
mount -v none  -t tmpfs     $ROOTFS_DIR/var/lib/apt     -o defaults,size=100%,nr_inodes=0,mode=0755                    || __clean_up
mount -v none  -t tmpfs     $ROOTFS_DIR/var/log         -o defaults,size=100%,nr_inodes=0,mode=0755                    || __clean_up
touch $ROOTFS_DIR/etc/resolv.conf
mount -v -B /etc/resolv.conf $ROOTFS_DIR/etc/resolv.conf                                                                || __clean_up
mount -v -B /etc/machine-id $ROOTFS_DIR/etc/machine-id	                                                                || __clean_up

chroot $ROOTFS_DIR /bin/bash
dpkg --admindir=$ROOTFS_DIR/var/lib/dpkg --root=$ROOTFS_DIR --instdir=$ROOTFS_DIR --clear-avail
__clean_up
