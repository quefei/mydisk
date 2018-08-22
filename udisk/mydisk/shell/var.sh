#!/bin/bash

VERSION="1804"

CENTOS="CentOS-7-x86_64-Minimal-${VERSION}.iso"
CENTOS_MD5="fabdc67ff3a1674a489953effa285dfd"
CENTOS_SRC="${ROOTDIR}/mydisk/resource/${CENTOS}"
CENTOS_DEST="${ROOTDIR}/${CENTOS}"

MYDISK="Mydisk-${VERSION}.iso"
MYDISK_MD5="810f146cb8119457c34b04f64d490894"
MYDISK_SRC="${ROOTDIR}/mydisk/resource/${MYDISK}"
MYDISK_DEST="${ROOTDIR}/LMT/${MYDISK}"
MYDISK_URL="https://github.com/quefei/mydisk/raw/master/ol/lfs/${MYDISK}"

KS_SRC="${ROOTDIR}/mydisk/resource/ks.cfg.default"
KS_DEST="${ROOTDIR}/ks.cfg"

DOWNLOAD_DEST="${ROOTDIR}/mydisk/tmp/download.tmp"
DOWNLOAD_URL="https://gitee.com/quefei/mydisk/raw/master/ol/resource/${CENTOS}.download"
