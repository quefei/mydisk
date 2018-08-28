#!/bin/bash

set -ueo pipefail

. ${ROOTDIR}/mydisk/shell/install_var.sh
. ${ROOTDIR}/mydisk/shell/install_fn.sh

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

if [[ "$MOUNT_UDISK" == "Y" ]]; then
        use_mount "是否自动执行脚本" && EXEC_SCRIPT="$READ_VAR"
fi

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
                        break
                fi
                
                if ( ! echo "$MOUNT_DEVICE" | grep "$DEVICE_REGEXP" &> ${NULL} ); then
                        echo_error
                        continue
                fi
                
                if [[ -s "$DISK" ]] && ( grep " ${MOUNT_DEVICE} " ${DISK} &> ${NULL} ); then
                        echo_error
                        continue
                fi
                
                config_disk "..请输入挂载点" "/mnt/dir" && MOUNT_DIR="$READ_VAR"
                
                if [[ "$MOUNT_DIR" == "Q" ]]; then
                        break
                fi
                
                if ( ! echo "$MOUNT_DIR" | grep "$DIR_REGEXP" &> ${NULL} ) \
                || (   echo "$MOUNT_DIR" | grep -E "^/dev/|^/dev$" &> ${NULL} ); then
                        echo_error
                        continue
                fi
                
                if [[ -s "$DISK" ]] && ( grep " ${MOUNT_DIR}$" ${DISK} &> ${NULL} ); then
                        echo_error
                        continue
                fi
                
                echo "DEVICE: ${MOUNT_DEVICE} DIR: ${MOUNT_DIR}" >> ${DISK}
        done
fi

## display 3
echo_head "配置完成!"

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

if [[ "$MOUNT_UDISK" == "Y" ]]; then
        sed -i "s/\r$//g" ${UDISK}
        echo ""
        
        nl -n rz -w 2 ${UDISK} | while read LINE; do
                NUMBER=$(echo "$LINE" | cut -f 1)
                
                UDISK_VID=$(echo "$LINE" | cut -d" " -f 2)
                UDISK_PID=$(echo "$LINE" | cut -d" " -f 4)
                UDISK_SN=$(echo "$LINE" | cut -d" " -f 6)
                
                echo "....U盘序列号 ${NUMBER}: ${UDISK_SN}"
                
                sed -i "/##CUSTOM##ADD##/a\mount_udisk \"${UDISK_VID}\" \"${UDISK_PID}\" \"${UDISK_SN}\"" ${KS_DEST}
        done
fi

if [[ "$MOUNT_DISK" == "Y" ]] && [[ -s "$DISK" ]]; then
        COMPLETE="poweroff"
        
        nl -n rz -w 2 ${DISK} | while read LINE; do
                NUMBER=$(echo "$LINE" | cut -f 1)
                
                MOUNT_DEVICE=$(echo "$LINE" | cut -d" " -f 2)
                MOUNT_DIR=$(echo "$LINE" | cut -d" " -f 4)
                
                echo ""
                echo ".....设备名称 ${NUMBER}: ${MOUNT_DEVICE}"
                echo ".......挂载点 ${NUMBER}: ${MOUNT_DIR}"
                
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

## display 4
echo_head "正在安装 请稍后..."

mv ${MYDISK_SRC} ${MYDISK_DEST}

for NUM in $(seq ${CURL_MAX}); do
        if [[ -s "$CENTOS_DEST" ]] && [[ "$CENTOS_MD5" == "$(md5sum ${CENTOS_DEST} | cut -d' ' -f 1)" ]]; then
                break
        elif [[ -s "$CENTOS_SRC" ]]; then
                mv ${CENTOS_SRC} ${CENTOS_DEST}
        else
                curl -sSo ${DOWNLOAD_DEST} ${DOWNLOAD_URL}
                CENTOS_URL=$(head -1 ${DOWNLOAD_DEST})
                curl -o ${CENTOS_DEST} ${CENTOS_URL}
        fi
done

if [[ "$NUM" == "$CURL_MAX" ]]; then
        read -n1 -p "Error: ${CENTOS} 下载失败! "
        exit 1
fi

## display 5
echo_head "安装完成!"

read_tail "退出"

exit 0
