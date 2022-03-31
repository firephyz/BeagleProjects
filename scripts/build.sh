#!/bin/bash

source /home/kyle/o/beagle/edk2/edksetup.sh
GCC5_ARM_PREFIX=/home/builder/rpmbuild/BUILDROOT/root/bin/arm-none-eabi- PACKAGES_PATH=/home/kyle/o/beagle/pkgs/ build -p ../pkgs/BeaglePlatform/BeaglePlatform.dsc
