#!/bin/bash

set -eu

#### Variable
ROOTDIR="/$(pwd | cut -d/ -f 2)"
SCRIPT_LIST="variable.sh function.sh"

#### Operation
for SCRIPT in ${SCRIPT_LIST}; do
        SCRIPT_PATH="${ROOTDIR}/mydisk/shell/${SCRIPT}"
        
        if [[ -s "$SCRIPT_PATH" ]]; then
                . ${SCRIPT_PATH}
        else
                read -n1 -p "Error: ${SCRIPT_PATH} not found! "
                exit 1
        fi
done

mkdir -p ${ROOTDIR}/mydisk/tmp

## display 1
echo_head "正在配置 CentOS:"

config_centos "....请输入你的IP" "$DEFAULT_IPADDR"   "$IP_REGEXP"       "break"      "echo_error" && IPADDR="$READ_VAR"
config_centos "..请输入你的网关" "$DEFAULT_GATEWAY"  "$IP_REGEXP"       "break"      "echo_error" && GATEWAY="$READ_VAR"
config_centos "...请输入你的DNS" "$DEFAULT_DNS"      "$IP_REGEXP"       "break"      "echo_error" && DNS="$READ_VAR"
config_centos "请输入你的主机名" "$DEFAULT_HOSTNAME" "$HOSTNAME_REGEXP" "break"      "echo_error" && HOSTNAME="$READ_VAR"
config_centos "..请输入root密码" "$DEFAULT_PASSWORD" "$PASSWORD_REGEXP" "echo_error" "break"      && ROOT_PASSWORD="$READ_VAR"
config_centos ".请输入admin密码" "$DEFAULT_PASSWORD" "$PASSWORD_REGEXP" "echo_error" "break"      && ADMIN_PASSWORD="$READ_VAR"

use_mount ".是否自动挂载U盘" && MOUNT_UDISK="$READ_VAR"
use_mount "..是否挂载新硬盘" && MOUNT_DISK="$READ_VAR"

















#### End
echo $IPADDR
echo $GATEWAY
echo $DNS
echo $HOSTNAME
echo $ROOT_PASSWORD
echo $ADMIN_PASSWORD
echo $MOUNT_UDISK
echo $MOUNT_DISK
read_tail "ivan"