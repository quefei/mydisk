#!/bin/bash

set -eu

# Variable
UDISK_ROOT="/$(pwd | cut -d/ -f 2)"
NULL_TMP="${UDISK_ROOT}/udisk/tmp/null.tmp"
KS_CFG_DEFAULT="${UDISK_ROOT}/udisk/resource/ks.cfg.default"
MD5_TXT="${UDISK_ROOT}/udisk/resource/md5.txt"
ATTR_TMP="${UDISK_ROOT}/udisk/tmp/attr.tmp"
DOWNLOAD_TMP="${UDISK_ROOT}/udisk/tmp/download.tmp"
MOUNT_TMP="${UDISK_ROOT}/udisk/tmp/mount.tmp"
SEQ_MAX="100"
REBOOT="reboot"

# Function
check_file()
{
        if [[ ! -s "$1" ]]; then
                read -n1 -p "Error: ${1} 文件不存在! "
                exit 1
        fi
        
        sed -i "s/\r$//g" ${1}
}

# Operation
mkdir -p ${UDISK_ROOT}/udisk/tmp

curl -sSo ${DOWNLOAD_TMP} https://gitee.com/quefei/resource/raw/master/udisk/download.txt &> ${NULL_TMP} || true
check_file "$DOWNLOAD_TMP"

echo "正在配置 CentOS:"
echo ""

# IPADDR
for NUM in $(seq ${SEQ_MAX}); do
        echo ""
        echo -n "........请输入你的IP (默认:192.168.1.5): "
        read IPADDR
        
        IPADDR=$(echo "$IPADDR" | sed "s/[ \t]//g")
        
        if [[ -z "$IPADDR" ]]; then
                IPADDR="192.168.1.5"
        fi
        
        if ( echo "$IPADDR" | grep "^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$" &> ${NULL_TMP} ); then
                break 1
        else
                echo ""
                echo "Error: 输入错误, 请重新输入!"
        fi
done

# GATEWAY
for NUM in $(seq ${SEQ_MAX}); do
        echo ""
        echo -n "......请输入你的网关 (默认:192.168.1.1): "
        read GATEWAY
        
        GATEWAY=$(echo "$GATEWAY" | sed "s/[ \t]//g")
        
        if [[ -z "$GATEWAY" ]]; then
                GATEWAY="192.168.1.1"
        fi
        
        if ( echo "$GATEWAY" | grep "^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$" &> ${NULL_TMP} ); then
                break 1
        else
                echo ""
                echo "Error: 输入错误, 请重新输入!"
        fi
done

# DNS
for NUM in $(seq ${SEQ_MAX}); do
        echo ""
        echo -n ".......请输入你的DNS (默认:114.114.114.114): "
        read DNS
        
        DNS=$(echo "$DNS" | sed "s/[ \t]//g")
        
        if [[ -z "$DNS" ]]; then
                DNS="114.114.114.114"
        fi
        
        if ( echo "$DNS" | grep "^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$" &> ${NULL_TMP} ); then
                break 1
        else
                echo ""
                echo "Error: 输入错误, 请重新输入!"
        fi
done

# HOSTNAME
for NUM in $(seq ${SEQ_MAX}); do
        echo ""
        echo -n "....请输入你的主机名 (默认:udisk): "
        read HOSTNAME
        
        HOSTNAME=$(echo "$HOSTNAME" | sed "s/[ \t]//g")
        
        if [[ -z "$HOSTNAME" ]]; then
                HOSTNAME="udisk"
        fi
        
        if ( echo "$HOSTNAME" | grep "^[A-Za-z_][A-Za-z0-9_\-\.]*$" &> ${NULL_TMP} ); then
                break 1
        else
                echo ""
                echo "Error: 输入错误, 请重新输入!"
        fi
done

# ROOT_PASSWORD
for NUM in $(seq ${SEQ_MAX}); do
        echo ""
        echo -n "......请输入root密码 (默认:123456): "
        read ROOT_PASSWORD
        
        ROOT_PASSWORD=$(echo "$ROOT_PASSWORD" | sed "s/[ \t]//g")
        
        if [[ -z "$ROOT_PASSWORD" ]]; then
                ROOT_PASSWORD="123456"
        fi
        
        if ( ! echo "$ROOT_PASSWORD" | grep "'" &> ${NULL_TMP} ); then
                break 1
        else
                echo ""
                echo "Error: 输入错误, 请重新输入!"
        fi
done

# ADMIN_PASSWORD
for NUM in $(seq ${SEQ_MAX}); do
        echo ""
        echo -n ".....请输入admin密码 (默认:123456): "
        read ADMIN_PASSWORD
        
        ADMIN_PASSWORD=$(echo "$ADMIN_PASSWORD" | sed "s/[ \t]//g")
        
        if [[ -z "$ADMIN_PASSWORD" ]]; then
                ADMIN_PASSWORD="123456"
        fi
        
        if ( ! echo "$ADMIN_PASSWORD" | grep "'" &> ${NULL_TMP} ); then
                break 1
        else
                echo ""
                echo "Error: 输入错误, 请重新输入!"
        fi
done

# MOUNT_UDISK
echo ""
echo -n ".....是否自动挂载U盘 [Y/N]: "
read MOUNT_UDISK

MOUNT_UDISK=$(echo "$MOUNT_UDISK" | sed "s/[ \t]//g")
MOUNT_UDISK=$(echo "$MOUNT_UDISK" | tr "[a-z]" "[A-Z]")

# MOUNT_DISK
echo ""
echo -n "......是否挂载新硬盘 [Y/N]: "
read MOUNT_DISK

MOUNT_DISK=$(echo "$MOUNT_DISK" | sed "s/[ \t]//g")
MOUNT_DISK=$(echo "$MOUNT_DISK" | tr "[a-z]" "[A-Z]")

if [[ "$MOUNT_DISK" == "Y" ]] || [[ "$MOUNT_DISK" == "YES" ]]; then
        clear
        echo "正在配置 新硬盘:"
        echo ""
        echo ""
        echo "退出当前模式请输入 Q"
        
        if [[ -f "$MOUNT_TMP" ]]; then
                rm -rf ${MOUNT_TMP}
        fi
        
        for NUM in $(seq ${SEQ_MAX}); do
                
                NUMBER=$(printf "%02d\n" ${NUM})
                
                echo ""
                echo -n "....请输入设备名称 ${NUMBER} (例如:/dev/sdb${NUM}): "
                read MOUNT_DEVICE
                
                MOUNT_DEVICE=$(echo "$MOUNT_DEVICE" | sed "s/[ \t]//g")
                
                if [[ "$MOUNT_DEVICE" == "Q" ]] || [[ "$MOUNT_DEVICE" == "QUIT" ]] \
                || [[ "$MOUNT_DEVICE" == "q" ]] || [[ "$MOUNT_DEVICE" == "quit" ]]; then
                        break 1
                fi
                
                if ( ! echo "$MOUNT_DEVICE" | grep "^/dev/[A-Za-z][A-Za-z0-9/_\-]*$" &> ${NULL_TMP} ); then
                        echo ""
                        echo "Error: 输入错误, 请重新输入!"
                        continue 1
                fi
                
                echo ""
                echo -n "......请输入挂载点 ${NUMBER} (例如:/mnt/dir${NUM}): "
                read MOUNT_DIR
                
                MOUNT_DIR=$(echo "$MOUNT_DIR" | sed "s/[ \t]//g")
                
                if [[ "$MOUNT_DIR" == "Q" ]] || [[ "$MOUNT_DIR" == "QUIT" ]] \
                || [[ "$MOUNT_DIR" == "q" ]] || [[ "$MOUNT_DIR" == "quit" ]]; then
                        break 1
                fi
                
                if ( ! echo "$MOUNT_DIR" | grep "^/[A-Za-z0-9_][A-Za-z0-9/_\-]*$" &> ${NULL_TMP} ); then
                        echo ""
                        echo "Error: 输入错误, 请重新输入!"
                        continue 1
                fi
                
                echo "DEVICE: ${MOUNT_DEVICE} DIR: ${MOUNT_DIR}" >> ${MOUNT_TMP}
                
        done
fi

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
        
        check_file "$ATTR_TMP"
        echo ""
        
        nl -n rz -w 2 ${ATTR_TMP} | while read LINE; do
                
                NUMBER=$(echo "$LINE" | cut -f 1)
                UDISK_VID=$(echo "$LINE" | cut -d" " -f 2)
                UDISK_PID=$(echo "$LINE" | cut -d" " -f 4)
                UDISK_SN=$(echo "$LINE" | cut -d" " -f 6)
                
                echo "....U盘序列号 ${NUMBER}: ${UDISK_SN}"
                
                sed -i "/##CUSTOM##ADD##/a\mount_udisk \"${UDISK_VID}\" \"${UDISK_PID}\" \"${UDISK_SN}\"" ${UDISK_ROOT}/ks.cfg
                
        done
        
fi

if [[ "$MOUNT_DISK" == "Y" ]] || [[ "$MOUNT_DISK" == "YES" ]]; then
        
        check_file "$MOUNT_TMP"
        REBOOT="poweroff"
        
        nl -n rz -w 2 ${MOUNT_TMP} | while read LINE; do
                
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

# End
history -c
