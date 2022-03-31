# The tcp backend for the guest serial port connects as a client. Use socat to establish a connection between
# the tcp socket and the socat stdio.
#   Socat command:
#     socat tcp-listen:4444,fork,max-children=1,reuseaddr stdout
#
#     fork ensures socat does the binding and remains connected even when no client is listening.
#
# Build command
# build -p BeaglePlatform/BeaglePlatform.dsc -n 1 -d 15
#
# sudo ifconfig enp0s20f0u4u1 10.0.2.0 netmask 255.255.255.0 up
# sudo ifconfig enp0s20f0u4u1 10.0.2.0 netmask 255.255.255.0 up && sudo dhcpd -f -tf dhcpd.log
#
# /etc/dhcp/dhcpcd.conf

WAIT_DEBUG_FLAGS=${NOWAIT_DBG-"-s -S"}
PORT=${PORT_OVERRIDE-"4444"}
echo ${WAIT_DEBUG_FLAGS}

# FD_FILE=/home/kyle/o/beagle/edk2/Build/BeagleBone/DEBUG_GCC5/FV/BEAGLEBOOT.fd
# FD_FILE=/home/kyle/o/beagle/test.bin
FD_FILE=/home/kyle/o/beagle/baremetal/build/test.bin
DEBUG_LOG="-d int,cpu_reset,unimp,guest_errors"
qemu-system-arm -machine raspi2 \
		-m 1G -cpu cortex-a8 \
		-device loader,file=${FD_FILE},addr=0x100000,cpu-num=0,force-raw=on \
		-device loader,file=/home/kyle/o/beagle/loop.bin,addr=0x400,cpu-num=1,force-raw=on \
		-device loader,file=/home/kyle/o/beagle/loop.bin,addr=0x800,cpu-num=2,force-raw=on \
		-device loader,file=/home/kyle/o/beagle/loop.bin,addr=0xc00,cpu-num=3,force-raw=on \
		-serial tcp:127.0.0.1:${PORT} \
		-monitor stdio \
		${WAIT_DEBUG_FLAGS} \
		-nographic \
		# -d int,unimp,guest_errors,in_asm,op
		# -d mmu,guest_errors,op_opt

		# -chardev socket,host=127.0.0.1,id=inout,port=4444,mux=on \

                # -serial tcp:127.0.0.1:4444 \
#		-serial file:/dev/tty10 \
#		-chardev serial,id=test,path=qemu.inout
#		-monitor stdio \
#		-accel tcg,tb-size=256,thread=single \
