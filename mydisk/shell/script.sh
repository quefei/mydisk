#!/bin/bash

set -ueo pipefail
#set -x

ROOTDIR="/$(pwd | cut -d/ -f 2)"
SCRIPT_LOG="${ROOTDIR}/script.log"
SOURCE_SCRIPT="${ROOTDIR}/mydisk/shell/install.sh"

. ${SOURCE_SCRIPT} 2>&1 | tee ${SCRIPT_LOG}
