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











#### End
read_tail "ivan"