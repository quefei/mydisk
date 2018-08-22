#!/bin/bash

set -eu

#### Variable
SH_LIST="var.sh func.sh"

#### Function

#### Operation
for SH in ${SH_LIST}; do
        if [[ -s "./${SH}" ]]; then
                . ./${SH}
        else
                read -n1 -p "Error: ${SH} not found"
                exit
        fi
done

#### End
