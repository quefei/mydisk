#!/bin/bash

set -eu

SCRIPT_LIST="var.sh func.sh"

for SCRIPT in ${SCRIPT_LIST}; do
        if [[ -s "$SCRIPT" ]]; then
                . "$SCRIPT"
        else
                read -n1 -p "Error: ${SCRIPT} not found"
                exit 1
        fi
done

#### Variable

#### Function

#### Operation

#### End
