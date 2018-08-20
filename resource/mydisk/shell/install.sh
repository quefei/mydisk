#!/bin/bash

set -eu

#### Variable
UDISK_ROOT="/$(pwd | cut -d/ -f 2)"
NULL_TMP="${UDISK_ROOT}/mydisk/tmp/null.tmp"
SEQ_MAX="100"
IP_FORMAT="^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$"

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

#### Operation
mkdir -p ${UDISK_ROOT}/mydisk/tmp

## screen 1
echo "正在配置 CentOS:"
echo ""

read_var "IPADDR"         "....请输入你的IP" "192.168.1.5"     "$IP_FORMAT"                   "break"      "echo_error"
read_var "GATEWAY"        "..请输入你的网关" "192.168.1.1"     "$IP_FORMAT"                   "break"      "echo_error"
read_var "DNS"            "...请输入你的DNS" "114.114.114.114" "$IP_FORMAT"                   "break"      "echo_error"
read_var "HOSTNAME"       "请输入你的主机名" "mydisk"          "^[A-Za-z_][A-Za-z0-9_\-\.]*$" "break"      "echo_error"
read_var "ROOT_PASSWORD"  "..请输入root密码" "123456"          "'"                            "echo_error" "break"
read_var "ADMIN_PASSWORD" ".请输入admin密码" "123456"          "'"                            "echo_error" "break"

#### End
