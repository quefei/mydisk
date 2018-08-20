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
NUMBER=
NUM=

#### Function
echo_error()
{
        echo ""
        echo "Error: 输入错误, 请重新输入!"
}

read_var()
{
        VAR="$1"
        
        for NUM in $(seq ${SEQ_MAX}); do
                echo ""
                echo -n "....${2} (默认:${3}): "
                read "$VAR"
                
                VALUE=$(eval echo '$'"$VAR")
                
                VALUE=$(echo "$VALUE" | sed "s/[ \t]//g")
                
                if [[ -z "$VALUE" ]]; then
                        VALUE="$3"
                fi
                
                if ( echo "$VALUE" | grep "$4" &> ${NULL_TMP} ); then
                        "$5"
                else
                        "$6"
                fi
        done
}

read_value()
{
        VAR="$1"
        
        echo ""
        echo -n "....${2} [Y/N]: "
        read "$VAR"
        
        VALUE=$(eval echo '$'"$VAR")
        
        VALUE=$(echo "$VALUE" | sed "s/[ \t]//g")
        VALUE=$(echo "$VALUE" | tr "[a-z]" "[A-Z]")
}

read_disk()
{
        VAR="$1"
        
        echo ""
        echo -n "....${2} ${NUMBER} (例如:${3}${NUM}): "
        read "$VAR"
        
        VALUE=$(eval echo '$'"$VAR")
        
        VALUE=$(echo "$VALUE" | sed "s/[ \t]//g")
        
        if [[ "$VALUE" == "Q" ]] || [[ "$VALUE" == "QUIT" ]] \
        || [[ "$VALUE" == "q" ]] || [[ "$VALUE" == "quit" ]]; then
                break 1
        fi
        
        if ( ! echo "$VALUE" | grep "$4" &> ${NULL_TMP} ); then
                echo_error
                continue 1
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

read_var   "IPADDR"         "....请输入你的IP" "192.168.1.5"     "$IP_FORMAT"                   "break"      "echo_error"
read_var   "GATEWAY"        "..请输入你的网关" "192.168.1.1"     "$IP_FORMAT"                   "break"      "echo_error"
read_var   "DNS"            "...请输入你的DNS" "114.114.114.114" "$IP_FORMAT"                   "break"      "echo_error"
read_var   "HOSTNAME"       "请输入你的主机名" "mydisk"          "^[A-Za-z_][A-Za-z0-9_\-\.]*$" "break"      "echo_error"
read_var   "ROOT_PASSWORD"  "..请输入root密码" "123456"          "'"                            "echo_error" "break"
read_var   "ADMIN_PASSWORD" ".请输入admin密码" "123456"          "'"                            "echo_error" "break"
read_value "MOUNT_UDISK"    ".是否自动挂载U盘"
read_value "MOUNT_DISK"     "..是否挂载新硬盘"

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
                
                read_disk "MOUNT_DEVICE" "请输入设备名称" "/dev/sdb" "^/dev/[A-Za-z][A-Za-z0-9/_\-]*$"
                read_disk "MOUNT_DIR"    "..请输入挂载点" "/mnt/dir" "^/[A-Za-z0-9_][A-Za-z0-9/_\-]*$"
                
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
history -c
