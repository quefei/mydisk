#!/bin/bash

set -ueo pipefail
#set -x

ROOTDIR="/$(pwd | cut -d/ -f 2)"

INSTALL_SCRIPT="${ROOTDIR}/mydisk/shell/install.sh"
INSTALL_LOG="${ROOTDIR}/install.log"

. ${INSTALL_SCRIPT} 2>&1 | tee ${INSTALL_LOG}
