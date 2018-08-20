#!/bin/bash

set -eu

#### Variable
UDISK_ROOT="/$(pwd | cut -d/ -f 2)"
NULL_TMP="${UDISK_ROOT}/mydisk/tmp/null.tmp"
KS_CFG_DEFAULT="${UDISK_ROOT}/mydisk/resource/ks.cfg.default"
UDISK_TMP="${UDISK_ROOT}/mydisk/tmp/udisk.tmp"
DISK_TMP="${UDISK_ROOT}/mydisk/tmp/disk.tmp"
SEQ_MAX="100"
REBOOT="reboot"
IP_FORMAT="^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$"

#### Function
echo_error()
{
        echo ""
        echo "Error: 输入错误, 请重新输入!"
}

read_var()
{
        for NUM in $(seq ${SEQ_MAX}); do
                echo ""
                echo -n "....${1} (默认:${2}): "
                read VAR
                
                VAR=$(echo "$VAR" | sed "s/[ \t]//g")
                
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
        echo ""
        echo -n "....${1} [Y/N]: "
        read VAR
        
        VAR=$(echo "$VAR" | sed "s/[ \t]//g")
        VAR=$(echo "$VAR" | tr "[a-z]" "[A-Z]")
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

read_var   "....请输入你的IP" "192.168.1.5"     "$IP_FORMAT"                   "break"      "echo_error" && IPADDR="$VAR"
read_var   "..请输入你的网关" "192.168.1.1"     "$IP_FORMAT"                   "break"      "echo_error" && GATEWAY="$VAR"
read_var   "...请输入你的DNS" "114.114.114.114" "$IP_FORMAT"                   "break"      "echo_error" && DNS="$VAR"
read_var   "请输入你的主机名" "mydisk"          "^[A-Za-z_][A-Za-z0-9_\-\.]*$" "break"      "echo_error" && HOSTNAME="$VAR"
read_var   "..请输入root密码" "123456"          "'"                            "echo_error" "break"      && ROOT_PASSWORD="$VAR"
read_var   ".请输入admin密码" "123456"          "'"                            "echo_error" "break"      && ADMIN_PASSWORD="$VAR"
read_mount ".是否自动挂载U盘" && MOUNT_UDISK="$VAR"
read_mount "..是否挂载新硬盘" && MOUNT_DISK="$VAR"

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
                
                echo ""
                echo -n "....请输入设备名称 ${NUMBER} (例如:/dev/sdb${NUM}): "
                read MOUNT_DEVICE
                
                MOUNT_DEVICE=$(echo "$MOUNT_DEVICE" | sed "s/[ \t]//g")
                
                if [[ "$MOUNT_DEVICE" == "Q" ]] || [[ "$MOUNT_DEVICE" == "QUIT" ]] \
                || [[ "$MOUNT_DEVICE" == "q" ]] || [[ "$MOUNT_DEVICE" == "quit" ]]; then
                        break 1
                fi
                
                if ( ! echo "$MOUNT_DEVICE" | grep "^/dev/[A-Za-z][A-Za-z0-9/_\-]*$" &> ${NULL_TMP} ); then
                        echo_error
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

#### End
