#!/bin/bash

set -ueo pipefail
#set -x

ROOTDIR="/$(pwd | cut -d/ -f 2)"

SCRIPT_LOG="${ROOTDIR}/script.log"
SCRIPT_FILE="${ROOTDIR}/mydisk/shell/install.sh"

. ${SCRIPT_FILE} 2>&1 | tee ${SCRIPT_LOG}
