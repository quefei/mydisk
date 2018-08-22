#!/bin/bash

VERSION="1804"

CENTOS="CentOS-7-x86_64-Minimal-${VERSION}.iso"
CENTOS_MD5="fabdc67ff3a1674a489953effa285dfd"
CENTOS_SRC="${ROOTDIR}/mydisk/resource/${CENTOS}"
CENTOS_DEST="${ROOTDIR}/${CENTOS}"

MYDISK="Mydisk-${VERSION}.iso"
MYDISK_MD5="810f146cb8119457c34b04f64d490894"
MYDISK_SRC="${ROOTDIR}/mydisk/resource/${MYDISK}"
MYDISK_DEST="${ROOTDIR}/LMT/${MYDISK}"
MYDISK_URL="https://github.com/quefei/mydisk/raw/master/ol/lfs/${MYDISK}"

KS_SRC="${ROOTDIR}/mydisk/resource/ks.cfg.default"
KS_DEST="${ROOTDIR}/ks.cfg"

DOWNLOAD_DEST="${ROOTDIR}/mydisk/tmp/download.tmp"
DOWNLOAD_URL="https://gitee.com/quefei/mydisk/raw/master/ol/resource/${CENTOS}.download"

NULL="${ROOTDIR}/mydisk/tmp/null.tmp"
DISK="${ROOTDIR}/mydisk/tmp/disk.tmp"
UDISK="${ROOTDIR}/mydisk/tmp/udisk.tmp"

DEFAULT_IPADDR="192.168.1.5"
DEFAULT_GATEWAY="192.168.1.1"
DEFAULT_DNS="114.114.114.114"
DEFAULT_HOSTNAME="mydisk"
DEFAULT_PASSWORD="123456"

COMPLETE="reboot"
MAX="100"

IP_FORMAT="^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$"
HOSTNAME_FORMAT="^[A-Za-z_][A-Za-z0-9_\-\.]*$"
DEVICE_FORMAT="^/dev/[A-Za-z][A-Za-z0-9/_\-]*$"
DIR_FORMAT="^/[A-Za-z0-9_][A-Za-z0-9/_\-]*$"

NUMBER=
NUM=
