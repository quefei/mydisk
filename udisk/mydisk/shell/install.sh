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

( echo ""
  echo "..........你的IP: ${IPADDR}"
  echo "........你的网关: ${GATEWAY}"
  echo ".........你的DNS: ${DNS}"
  
  echo ""
  echo "......你的主机名: ${HOSTNAME}"
  
  echo ""
  echo "........root密码: ${ROOT_PASSWORD}"
  echo ".......admin密码: ${ADMIN_PASSWORD}" ) | tee ${LOG}

if [[ "$MOUNT_UDISK" == "Y" ]]; then
        check_file "$UDISK"
        echo "" | tee -a ${LOG}
        
        nl -n rz -w 2 ${UDISK} | while read LINE; do
                NUMBER=$(echo "$LINE" | cut -f 1)
                
                UDISK_VID=$(echo "$LINE" | cut -d" " -f 2)
                UDISK_PID=$(echo "$LINE" | cut -d" " -f 4)
                UDISK_SN=$(echo "$LINE" | cut -d" " -f 6)
                
                echo "....U盘序列号 ${NUMBER}: ${UDISK_SN}" | tee -a ${LOG}
                
                sed -i "/##CUSTOM##ADD##/a\mount_udisk \"${UDISK_VID}\" \"${UDISK_PID}\" \"${UDISK_SN}\"" ${KS_DEST}
        done
fi

if [[ "$MOUNT_DISK" == "Y" ]]; then
        check_file "$DISK"
        COMPLETE="poweroff"
        
        nl -n rz -w 2 ${DISK} | while read LINE; do
                NUMBER=$(echo "$LINE" | cut -f 1)
                
                MOUNT_DEVICE=$(echo "$LINE" | cut -d" " -f 2)
                MOUNT_DIR=$(echo "$LINE" | cut -d" " -f 4)
                
                ( echo ""
                  echo ".....设备名称 ${NUMBER}: ${MOUNT_DEVICE}"
                  echo ".......挂载点 ${NUMBER}: ${MOUNT_DIR}" ) | tee -a ${LOG}
                
                sed -i "/##CUSTOM##ADD##/a\mount_disk \"${MOUNT_DIR}\" \"${MOUNT_DEVICE}\"" ${KS_DEST}
        done
fi

sed -i "/##CUSTOM##ADD##/a\echo '${ADMIN_PASSWORD}' | passwd --stdin admin" ${KS_DEST}
sed -i "/##CUSTOM##ADD##/a\echo '${ROOT_PASSWORD}'  | passwd --stdin root"  ${KS_DEST}

sed -i "s/##CUSTOM##IPADDR##/${IPADDR}/g"     ${KS_DEST}
sed -i "s/##CUSTOM##GATEWAY##/${GATEWAY}/g"   ${KS_DEST}
sed -i "s/##CUSTOM##DNS##/${DNS}/g"           ${KS_DEST}
sed -i "s/##CUSTOM##HOSTNAME##/${HOSTNAME}/g" ${KS_DEST}
sed -i "s/##CUSTOM##COMPLETE##/${COMPLETE}/g" ${KS_DEST}

read_tail "开始安装"

























#### End
