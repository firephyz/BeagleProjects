#!/bin/bash

# MAP_FILE=/home/kyle/o/beagle/edk2/Build/BeagleBone/DEBUG_GCC5/ARM/MdeModulePkg/Core/Pei/PeiMain/DEBUG/PeiCore.map
MAP_FILE=$1
cat ${MAP_FILE} | sed -n ':b0;/END GROUP/b b1;d;b b0;:b1;n;/DISCARD/q;p;b b1;'
