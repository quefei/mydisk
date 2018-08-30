#!/bin/bash

set -ueo pipefail

VERSION="1804"

CENTOS="CentOS-7-x86_64-Minimal-${VERSION}.iso"
CENTOS_MD5="fabdc67ff3a1674a489953effa285dfd"
CENTOS_SRC="${ROOTDIR}/mydisk/resource/${CENTOS}"
CENTOS_DEST="${ROOTDIR}/${CENTOS}"

MYDISK="Mydisk-${VERSION}.iso"
MYDISK_SRC="${ROOTDIR}/mydisk/resource/${MYDISK}"
MYDISK_DEST="${ROOTDIR}/${MYDISK}"

KS_SRC="${ROOTDIR}/mydisk/resource/ks.cfg.default"
KS_DEST="${ROOTDIR}/ks.cfg"

GITEE_URL="https://gitee.com/quefei/online/raw/master/mydisk"

DOWNLOAD_DEST="${ROOTDIR}/mydisk/tmp/download.tmp"
DOWNLOAD_URL="${GITEE_URL}/resource/${CENTOS}.download"

SHELL_DIR="${ROOTDIR}/shell"
SHELL_COPY="${ROOTDIR}/mydisk/resource/shell.copy"

BAK_TIME="bak.$(date +"%Y%m%d%H%M%S")"

CONF_DEST="${SHELL_DIR}/conf/my.conf"
CONF_URL="${GITEE_URL}/resource/my.conf"

FOREVER_DEST="${SHELL_DIR}/forever/my.sh"
FOREVER_URL="${GITEE_URL}/shell/forever_my.sh"

ONCE_DEST="${SHELL_DIR}/once/my.sh"
ONCE_URL="${GITEE_URL}/shell/once_my.sh"

NULL="${ROOTDIR}/mydisk/tmp/null.tmp"
DISK="${ROOTDIR}/mydisk/tmp/disk.tmp"
UDISK="${ROOTDIR}/mydisk/tmp/udisk.tmp"
OTHER="${ROOTDIR}/mydisk/tmp/other.tmp"

DEFAULT_IPADDR="192.168.1.5"
DEFAULT_GATEWAY="192.168.1.1"
DEFAULT_DNS="114.114.114.114"
DEFAULT_HOSTNAME="mydisk"
DEFAULT_PASSWORD="123456"

COMPLETE="reboot"
READ_MAX="100"
CURL_MAX="5"

IP_REGEXP="^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$"
HOSTNAME_REGEXP="^[A-Za-z_][A-Za-z0-9_\-\.]*$"
PASSWORD_REGEXP="'"
DEVICE_REGEXP="^/dev/[A-Za-z][A-Za-z0-9/_\-]*$"
DIR_REGEXP="^/[A-Za-z0-9_][A-Za-z0-9/_\-]*$"

EXEC_SCRIPT=
NUMBER=
NUM=
