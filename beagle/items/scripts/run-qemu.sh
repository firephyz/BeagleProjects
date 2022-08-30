#!/bin/bash

# DEBUG=y
# MON_ON_STDIO=y

# MACHINE="-machine virt -machine virtualization=on -machine secure=on -cpu cortex-a15 -smp cpus=1,cores=1,maxcpus=4"
# # MACHINE="-machine xilinx-zynq-a9 -smp cpus=1,cores=4,maxcpus=4"

# LOADER_ADDR=0x42000000
# LOADER_LOOP_ADDR=0x42000000
# CPU_LOOP_LOADERS=""
# # CPU_LOOP_LOADERS="\
# # -device loader,addr=${LOADER_LOOP_ADDR},file=start.bin,cpu-num=1,force-raw=on \
# # -device loader,addr=${LOADER_LOOP_ADDR},file=start.bin,cpu-num=2,force-raw=on \
# # -device loader,addr=${LOADER_LOOP_ADDR},file=start.bin,cpu-num=3,force-raw=on"

# old_qemu_pid=$(ps -e | grep qemu | head -n 1 | sed -r 's/[ ]*([^ ]+).*/\1/')
# if [[ ! -z $old_qemu_pid ]]; then
#     kill -s KILL $old_qemu_pid;
# fi

# #		--trace "events=trace-events.txt,file=trace" \

# test $MON_ON_STDIO = y && QEMU_MON_ARGS="-mon chardev=iocon" || QEMU_MON_ARGS=
# test $DEBUG = y && QEMU_DEBUG_ARGS="-s -S" || QEMU_DEBUG_ARGS=

# QEMU_ARGS=$(echo -display none -audiodev none,id=nullaudio \
# 		${QEMU_DEBUG_ARGS} \
# 		${MACHINE} \
# 		-chardev stdio,id=iocon,mux=on \
# 		${QEMU_MON_ARGS} \
# 		-device loader,addr=${LOADER_ADDR},file=gpio.bin,cpu-num=0,force-raw=on \
# 		${CPU_LOOP_LOADERS})
# qemu-system-arm ${QEMU_ARGS}

# eval $QEMU_CMD

qemu-system-arm -nographic \
		-bios u-boot.bin \
		-machine virt \
		-smp cpus=1,cores=1,maxcpus=4 \
		-chardev stdio,id=serialcon \
		-chardev socket,id=moncon,host=localhost,port=1235,server=on,wait=off \
		-serial chardev:serialcon \
		-mon moncon -device virtio-net-device,netdev=qnet,mac=34:12:34:12:34:12 \
		-netdev socket,id=qnet,connect=localhost:1236
