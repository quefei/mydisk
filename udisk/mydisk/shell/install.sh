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

## display 2
if [[ "$MOUNT_DISK" == "Y" ]]; then
        echo_head "正在配置 新硬盘:"
        
        echo ""
        echo "退出当前模式请输入 Q"
        
        if [[ -f "$DISK" ]]; then
                rm -rf ${DISK}
        fi
        
        for NUM in $(seq ${READ_MAX}); do
                NUMBER=$(printf "%02d\n" ${NUM})
                
                config_disk "请输入设备名称" "/dev/sdb" && MOUNT_DEVICE="$READ_VAR"
                
                if [[ "$MOUNT_DEVICE" == "Q" ]]; then
                        break 1
                fi
                
                if ( ! echo "$MOUNT_DEVICE" | grep "$DEVICE_REGEXP" &> ${NULL} ); then
                        echo_error
                        continue 1
                fi
                
                config_disk "..请输入挂载点" "/mnt/dir" && MOUNT_DIR="$READ_VAR"
                
                if [[ "$MOUNT_DIR" == "Q" ]]; then
                        break 1
                fi
                
                if ( ! echo "$MOUNT_DIR" | grep "$DIR_REGEXP" &> ${NULL} ); then
                        echo_error
                        continue 1
                fi
                
                echo "DEVICE: ${MOUNT_DEVICE} DIR: ${MOUNT_DIR}" >> ${DISK}
        done
fi

## display 3
echo_head "配置完成!"

check_file "$KS_SRC"
cp -af ${KS_SRC} ${KS_DEST}

echo ""
echo "..........你的IP: ${IPADDR}"
echo "........你的网关: ${GATEWAY}"
echo ".........你的DNS: ${DNS}"
echo ""
echo "......你的主机名: ${HOSTNAME}"
echo ""
echo "........root密码: ${ROOT_PASSWORD}"
echo ".......admin密码: ${ADMIN_PASSWORD}"

read_tail "开始安装"

























#### End
