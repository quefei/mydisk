#!/bin/bash

set -eu

#### Variable
UDISK_ROOT="/$(pwd | cut -d/ -f 2)"
KS_CFG_DEFAULT="${UDISK_ROOT}/mydisk/resource/ks.cfg.default"
NULL_TMP="${UDISK_ROOT}/mydisk/tmp/null.tmp"
UDISK_TMP="${UDISK_ROOT}/mydisk/tmp/udisk.tmp"
DISK_TMP="${UDISK_ROOT}/mydisk/tmp/disk.tmp"
DOWNLOAD_TMP="${UDISK_ROOT}/mydisk/tmp/download.tmp"

DOWNLOAD_URL="https://gitee.com/quefei/mydisk/raw/master/resource/ol/resource/CentOS-7-x86_64-Minimal-1804.iso.download"

CENTOS_MD5="fabdc67ff3a1674a489953effa285dfd"
CENTOS_ISO="CentOS-7-x86_64-Minimal-1804.iso"
CENTOS_ISO_ROOT="${UDISK_ROOT}/${CENTOS_ISO}"
CENTOS_ISO_RES="${UDISK_ROOT}/mydisk/resource/${CENTOS_ISO}"

SEQ_MAX="100"
REBOOT="reboot"

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

check_file()
{
        if [[ ! -s "$1" ]]; then
                read -n1 -p "Error: ${1} 文件不存在! "
                exit 1
        fi
        
        sed -i "s/\r$//g" ${1}
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
clear
echo "配置完成!"
echo ""

check_file "$KS_CFG_DEFAULT"
cp -af ${KS_CFG_DEFAULT} ${UDISK_ROOT}/ks.cfg

echo ""
echo "..........你的IP: ${IPADDR}"
echo "........你的网关: ${GATEWAY}"
echo ".........你的DNS: ${DNS}"
echo ""
echo "......你的主机名: ${HOSTNAME}"
echo ""
echo "........root密码: ${ROOT_PASSWORD}"
echo ".......admin密码: ${ADMIN_PASSWORD}"

if [[ "$MOUNT_UDISK" == "Y" ]] || [[ "$MOUNT_UDISK" == "YES" ]]; then
        check_file "$UDISK_TMP"
        echo ""
        
        nl -n rz -w 2 ${UDISK_TMP} | while read LINE; do
                NUMBER=$(echo "$LINE" | cut -f 1)
                UDISK_VID=$(echo "$LINE" | cut -d" " -f 2)
                UDISK_PID=$(echo "$LINE" | cut -d" " -f 4)
                UDISK_SN=$(echo "$LINE" | cut -d" " -f 6)
                
                echo "....U盘序列号 ${NUMBER}: ${UDISK_SN}"
                
                sed -i "/##CUSTOM##ADD##/a\mount_udisk \"${UDISK_VID}\" \"${UDISK_PID}\" \"${UDISK_SN}\"" ${UDISK_ROOT}/ks.cfg
        done
fi

if [[ "$MOUNT_DISK" == "Y" ]] || [[ "$MOUNT_DISK" == "YES" ]]; then
        check_file "$DISK_TMP"
        REBOOT="poweroff"
        
        nl -n rz -w 2 ${DISK_TMP} | while read LINE; do
                NUMBER=$(echo "$LINE" | cut -f 1)
                MOUNT_DEVICE=$(echo "$LINE" | cut -d" " -f 2)
                MOUNT_DIR=$(echo "$LINE" | cut -d" " -f 4)
                
                echo ""
                echo ".....设备名称 ${NUMBER}: ${MOUNT_DEVICE}"
                echo ".......挂载点 ${NUMBER}: ${MOUNT_DIR}"
                
                sed -i "/##CUSTOM##ADD##/a\mount_disk \"${MOUNT_DIR}\" \"${MOUNT_DEVICE}\"" ${UDISK_ROOT}/ks.cfg
        done
fi

sed -i "/##CUSTOM##ADD##/a\echo '${ADMIN_PASSWORD}' | passwd --stdin admin" ${UDISK_ROOT}/ks.cfg
sed -i "/##CUSTOM##ADD##/a\echo '${ROOT_PASSWORD}'  | passwd --stdin root"  ${UDISK_ROOT}/ks.cfg

sed -i "s/##CUSTOM##IP##/${IPADDR}/g"         ${UDISK_ROOT}/ks.cfg
sed -i "s/##CUSTOM##GATEWAY##/${GATEWAY}/g"   ${UDISK_ROOT}/ks.cfg
sed -i "s/##CUSTOM##DNS##/${DNS}/g"           ${UDISK_ROOT}/ks.cfg
sed -i "s/##CUSTOM##HOSTNAME##/${HOSTNAME}/g" ${UDISK_ROOT}/ks.cfg
sed -i "s/##CUSTOM##REBOOT##/${REBOOT}/g"     ${UDISK_ROOT}/ks.cfg

echo ""
echo ""
read -n1 -p "请按任意键开始安装... "

## screen 4
clear
echo "正在安装 请稍后..."

for NUM in $(seq ${SEQ_MAX}); do
          if [[ -s "$CENTOS_ISO_ROOT" ]] && [[ "$CENTOS_MD5" == "$(md5sum ${CENTOS_ISO_ROOT} | cut -d' ' -f 1)" ]]; then
                break
        elif [[ -s "$CENTOS_ISO_RES" ]]; then
                mv ${CENTOS_ISO_RES} ${CENTOS_ISO_ROOT}
        else
                curl -sSo ${DOWNLOAD_TMP} ${DOWNLOAD_URL} &> ${NULL_TMP} || true
                check_file "$DOWNLOAD_TMP"
                curl -o ${CENTOS_ISO_ROOT} $(head -1 ${DOWNLOAD_TMP})
        fi
done





















#### End
