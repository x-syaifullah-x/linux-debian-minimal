#!/bin/bash

export PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin

ROOTFS_DIR="rootfs"
INCLUDE_APT=1
INCLUDE_MAN=1
INCLUDE_DOC=1
INCLUDE_INFO=1
INCLUDE_LINTIAN=1

while [ "$#" -gt 0 ]; do
  case "$1" in
    --rootfs-dir)
      ROOTFS_DIR="$2"
      shift 2
      ;;
    --without-apt)
      INCLUDE_APT=
      shift
      ;;
    --without-man)
      INCLUDE_MAN=
      shift
      ;;
    --without-doc)
      INCLUDE_DOC=
      shift
      ;;
    --without-info)
      INCLUDE_INFO=
      shift
      ;;
    --without-lintian)
      INCLUDE_LINTIAN=
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

function download_package {
  local packages=$(echo "$@" | tr ' ' '\n' | sort)
  for package in $packages; do
      printf "Downloading $package...\n"
      apt-get download $package &>/dev/null
  done
}

function extract_package {
  local packages=$(echo "$@" | tr ' ' '\n' | sort)
  for package in $packages; do
      printf "Extracting $package...\n"
      dpkg -x ${package}_*.deb $ROOTFS_DIR
  done
}

function install_package {
  for package in $@; do
    dpkg --admindir=$ROOTFS_DIR/var/lib/dpkg --root=$ROOTFS_DIR --force-depends --ignore-depends=libc6,usr-is-merged,openssl-provider-legacy -i ${package}_*.deb
  done
}