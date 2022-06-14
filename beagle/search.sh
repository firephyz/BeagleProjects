#!/bin/bash

UBOOT_PREFIX=/home/kyle/dev/beagle/u-boot

case $1 in
  board )
    grep -rnw ".*$2.*" ${UBOOT_PREFIX}/arch/arm/mach-omap2
    grep -rnw ".*$2.*" ${UBOOT_PREFIX}/board/ti
    ;;
  path )
    grep -rnw ".*$3.*" ${UBOOT_PREFIX}/$2
    ;;
  all )
    grep -rnw ".*$2.*" ${UBOOT_PREFIX}
    ;;
esac
