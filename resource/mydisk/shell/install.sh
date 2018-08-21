#!/bin/bash

set -eu

#### Variable
UDISK_ROOT="/$(pwd | cut -d/ -f 2)"
NULL_TMP="${UDISK_ROOT}/mydisk/tmp/null.tmp"

DISK_TMP="${UDISK_ROOT}/mydisk/tmp/disk.tmp"

SEQ_MAX="100"
IP_FORMAT="^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$"
HN_FORMAT="^[A-Za-z_][A-Za-z0-9_\-\.]*$"

NUMBER=
NUM=

#### Function
read_var()
{
        echo ""
        echo -n "....${1}: "
        read VAR
        
        VAR=$(echo "$VAR" | sed "s/[ \t]//g")
}

echo_error()
{
        echo ""
        echo "Error: 输入错误, 请重新输入!"
}

read_os()
{
        for NUM in $(seq ${SEQ_MAX}); do
                read_var "${1} (默认:${2})"
                
                if [[ -z "$VAR" ]]; then
                        VAR="$2"
                fi
                
                if ( echo "$VAR" | grep "$3" &> ${NULL_TMP} ); then
                        "$4"
                else
                        "$5"
                fi
        done
}

read_mount()
{
        read_var "${1} [Y/N]"
        VAR=$(echo "$VAR" | tr "[a-z]" "[A-Z]")
}

read_disk()
{
        read_var "${1} ${NUMBER} (例如:${2}${NUM})"
        
        if [[ "$VAR" == "Q" ]] || [[ "$VAR" == "QUIT" ]] \
        || [[ "$VAR" == "q" ]] || [[ "$VAR" == "quit" ]]; then
                VAR="Q"
        fi
}

#### Operation
mkdir -p ${UDISK_ROOT}/mydisk/tmp

## screen 1
echo "正在配置 CentOS:"
echo ""

read_os     "....请输入你的IP"  "192.168.1.5"      "$IP_FORMAT"  "break"       "echo_error"  &&  IPADDR="$VAR"
read_os     "..请输入你的网关"  "192.168.1.1"      "$IP_FORMAT"  "break"       "echo_error"  &&  GATEWAY="$VAR"
read_os     "...请输入你的DNS"  "114.114.114.114"  "$IP_FORMAT"  "break"       "echo_error"  &&  DNS="$VAR"
read_os     "请输入你的主机名"  "mydisk"           "$HN_FORMAT"  "break"       "echo_error"  &&  HOSTNAME="$VAR"
read_os     "..请输入root密码"  "123456"           "'"           "echo_error"  "break"       &&  ROOT_PASSWORD="$VAR"
read_os     ".请输入admin密码"  "123456"           "'"           "echo_error"  "break"       &&  ADMIN_PASSWORD="$VAR"

read_mount  ".是否自动挂载U盘"  &&  MOUNT_UDISK="$VAR"
read_mount  "..是否挂载新硬盘"  &&  MOUNT_DISK="$VAR"

## screen 2
if [[ "$MOUNT_DISK" == "Y" ]] || [[ "$MOUNT_DISK" == "YES" ]]; then
        clear
        echo "正在配置 新硬盘:"
        echo ""
        echo ""
        echo "退出当前模式请输入 Q"
        
        if [[ -f "$DISK_TMP" ]]; then
                rm -rf ${DISK_TMP}
        fi
        
        for NUM in $(seq ${SEQ_MAX}); do
                NUMBER=$(printf "%02d\n" ${NUM})
                
                read_disk "请输入设备名称" "/dev/sdb" && MOUNT_DEVICE="$VAR"
                
                [[ "$MOUNT_DEVICE" == "Q" ]] && break
                
                if ( ! echo "$MOUNT_DEVICE" | grep "^/dev/[A-Za-z][A-Za-z0-9/_\-]*$" &> ${NULL_TMP} ); then
                        echo_error
                        continue 1
                fi
                
                read_disk "..请输入挂载点" "/mnt/dir" && MOUNT_DIR="$VAR"
                
                [[ "$MOUNT_DIR" == "Q" ]] && break
                
                if ( ! echo "$MOUNT_DIR" | grep "^/[A-Za-z0-9_][A-Za-z0-9/_\-]*$" &> ${NULL_TMP} ); then
                        echo_error
                        continue 1
                fi
                
                echo "DEVICE: ${MOUNT_DEVICE} DIR: ${MOUNT_DIR}" >> ${DISK_TMP}
        done
fi

## screen 3

## screen 4

#### End
