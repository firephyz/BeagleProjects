#!/bin/bash

source ~/.bashrc

shopt -s expand_aliases
set -e

function usage {
    printf "<script> [-nobackup] [-noupdate] [-keep-mount] [--help]\n"
}

UBOOT_PATH=/mnt/harddisk/beagle/u-boot
TFTP_ROOT=/mnt/harddisk/beagle/tftpboot
IMAGE_MOUNT=/run/media/kyle/UBOOT
BACKUP_PATH=$IMAGE_MOUNT/old/$(pdate)

# IMAGE_FILES="MLO u-boot.img uboot.env"
IMAGE_FILES="MLO u-boot.img uboot.env"
function image_files_with_path {
    echo $(eval echo $1/{$(echo $IMAGE_FILES | sed 's/ /,/g')})
}

function mkenv {
    ${UBOOT_PATH}/kbuild/tools/mkenvimage -s 4096 -o ${UBOOT_PATH}/kbuild/uboot.env ${UBOOT_PATH}/kbuild/default_env.txt
}

############################################################
# Parse Options
f_backup=y
f_update_image=y
f_force_update=
f_unmount=y
f_mode=mmc

skip=0
arg_target=
for flag in $@; do
    # Skip previously consumed atoms
    if [[ ${skip} > 0 ]]; then
        eval "${arg_target}=$flag"
	skip= && continue
    fi

    case $flag in
	--* )
	    case $flag in
		--help ) usage && exit 0;;
		* ) echo Unknown long flag $flag. && exit 1;;
	    esac
	    ;;
	-* )
	    case $flag in
		-mode )
		    arg_target=f_mode
		    skip=1
		    ;;
		-nobackup ) f_backup=;;
		-noupdate ) f_update_image=;;
		-force ) f_force_update=y;;
		-keep-mount ) f_unmount=;;
		* ) echo Unknown flag $flag. && exit 1;;
	    esac
	    ;;
	* ) echo Invalid flag form for $flag. && exit 1;;
    esac
done

if [[ ! $f_backup && $f_update_image && ! $f_force_update ]]; then
    echo Warning: old images would be overwritten with the update. Run without '-nobackup' or add '-force'. && exit 1;
fi

################################################################################
# Core functions

function load_mmc {
    test -d $IMAGE_MOUNT || (echo Couldn\'t find $IMAGE_MOUNT. Exiting... && exit 1)

    # Make sure we have env file
    mkenv
    # if [ -f ${UBOOT_PATH}/kbuild/u-boot-initial-env ]; then
    #     cp -v ${UBOOT_PATH}/kbuild/u-boot-initial-env ${UBOOT_PATH}/kbuild/uboot.env;
    # else
    #     echo Env file \'default.env\' not found in build directory. && exit 1
    # fi

    if [[ $f_backup ]]; then
	mkdir -v $BACKUP_PATH
	for f in $(image_files_with_path $(readlink -f ${IMAGE_MOUNT})); do
	    test -f $f && mv -v $f $BACKUP_PATH/
	done
    fi

    if [[ $f_update_image || $f_force_update ]]; then
	cp -v $(image_files_with_path ${UBOOT_PATH}/kbuild) $IMAGE_MOUNT/
    fi

    # Print sizes
    echo Image Sizes
    du -ha --apparent-size ${IMAGE_MOUNT}/ | grep -vE "UBOOT/(old|\$)" | sort | xargs -d '\n' -l printf "    %s\n"

    if [[ $f_unmount ]]; then
	sync -f $IMAGE_MOUNT
	udisksctl unmount -b $(lsblk -p | grep $IMAGE_MOUNT | sed -r s'/..([^ ]+).*/\1/')
    fi
}

function load_tftp {
    cp -v $(image_files_with_path ${UBOOT_PATH}/kbuild) $TFTP_ROOT/
}

################################################
## Start
case $f_mode in
    tftp ) load_tftp;;
    mmc )  load_mmc;;
    * ) echo Unknown script mode $f_mode. && exit 1;;
esac
