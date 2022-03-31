#!/bin/bash

cd edk2
source edksetup.sh

# export ARM_PREFIX=/home/builder/rpmbuild/BUILDROOT/root/bin/arm-none-eabi-
export ARM_PREFIX=/home/builder/rpmbuild/BUILDROOT/tools/bin/arm-none-eabi-

export GCC5_ARM_PREFIX=${ARM_PREFIX}
export PACKAGES_PATH=/home/kyle/o/beagle/pkgs/:/home/kyle/o/beagle/edk2/

export DSC_FILE=/home/kyle/o/beagle/pkgs/BeaglePlatform/BeaglePlatform.dsc

