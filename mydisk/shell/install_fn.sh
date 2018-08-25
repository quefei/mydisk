#!/bin/bash

set -ueo pipefail
#set -x

# echo_head "arg1"
echo_head()
{
        clear
        echo "$1"
        echo ""
}

# echo_error
echo_error()
{
        echo ""
        echo "Error: 输入错误, 请重新输入!"
}

# read_tail "arg1"
read_tail()
{
        echo ""
        echo ""
        read -n1 -p "请按任意键${1}... "
}

# read_command "arg1"        $READ_VAR
read_command()
{
        echo ""
        echo -n "....${1}: "
        read READ_VAR
        
        READ_VAR=$(echo "$READ_VAR" | sed "s/[ \t]//g")
}

# config_centos "arg1" "arg2" "arg3" "arg4" "arg5"        $READ_VAR
config_centos()
{
        for NUM in $(seq ${READ_MAX}); do
                read_command "${1} (默认:${2})"
                
                if [[ -z "$READ_VAR" ]]; then
                        READ_VAR="$2"
                fi
                
                if ( echo "$READ_VAR" | grep "$3" &> ${NULL} ); then
                        "$4"
                else
                        "$5"
                fi
        done
}

# use_mount "arg1"        $READ_VAR
use_mount()
{
        read_command "${1} [Y/N]"
        
        READ_VAR=$(echo "$READ_VAR" | tr "[a-z]" "[A-Z]")
        
        if [[ "$READ_VAR" == "YES" ]]; then
                READ_VAR="Y"
        fi
}

# config_disk "arg1" "arg2"        $READ_VAR
config_disk()
{
        read_command "${1} ${NUMBER} (例如:${2}${NUM})"
        
        if ( echo "$READ_VAR" | grep -iE "^quit$|^exit$|^q$" &> ${NULL} ); then
                READ_VAR="Q"
        fi
}
