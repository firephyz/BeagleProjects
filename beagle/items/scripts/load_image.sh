#set -x

#python -c "import sys; uboot=open('u-boot.img','rb').read(); header=open('../MLO.header', 'rb').read(); uboot_size=uboot[0:4]; img=header[:512] + int.from_bytes(uboot_size, 'little').to_bytes(4, 'big') + 0x80000000.to_bytes(4,'little') + uboot[4:]; sys.stdout.buffer.write(img)" > u-boot.bin
PYTHON_CMD=$(cat <<EOF
import sys;
import os;
beagle_root = os.path.dirname(os.getcwd());
uboot=open('u-boot.img','rb').read();
toc_header=open('{}/items/MLO.toc_header'.format(beagle_root), 'rb').read();
uboot_size_bytes = int.from_bytes(uboot[0:4], 'little').to_bytes(4, 'big');
uboot_addr_bytes = int.from_bytes(uboot[4:8], 'little').to_bytes(4, 'big');
img=uboot_size_bytes + uboot_addr_bytes + uboot[8:];
sys.stdout.buffer.write(img)
EOF
)
PYTHON_CMD=$(echo "${PYTHON_CMD}" | xargs -d '\n' -L 1 printf "%s")
python -c "${PYTHON_CMD}" > u-boot.bin

MOUNT_PATH=$((udisksctl mount -b /dev/sda1 || exit 1) | sed -r 's/Mounted [^ ]+ at //')
#mount /dev/sda1 /mnt/block/2
cp u-boot.bin ${MOUNT_PATH}/MLO
cp ${MOUNT_PATH}/MLO u-boot.bin.readback
if [[ $(diff u-boot.bin{,.readback}) ]]; then
    echo Image readback failed... && READ_VAL=$?
fi
udisksctl unmount -b /dev/sda1

[ ${READ_VAL} ] && exit 1
#umount /mnt/block/2
