MMC_SERIAL := 20090815198100000

BEAGLE_ROOT := /home/kyle/o/beagle/beagle
ARCH_FLAGS := -mcpu=cortex-a8 -mfloat-abi=hard -marm
CFLAGS := -isystem . -masm-syntax-unified -ffunction-sections -O2 -g

IMAGE_MODE:=file #file (as FAT file), raw (as raw binary image on MMC)
override LOAD_MEM:=$(LOAD_MEM:external=emif0_sdram)
override LOAD_MEM:=$(if ifeq ($(LOAD_MEM),),sram,$(LOAD_MEM))
$(info $(LOAD_MEM))
# LOAD_MEM ?= sram
# LOAD_MEM ?= emif0_sdram
# LOAD_MEM ?= qemu_sram
MEM_ADDRS := sram=0x402f0400 emif0_sdram=0x80000000 qemu_sram=0x42000000
LOAD_ADDR := $(shell echo $(filter $(LOAD_MEM)%,$(MEM_ADDRS)) | sed -r 's/.*?=//')
# LOAD_ADDR := $(if $(LOAD_MEM) eq sram,0x402f0400,$(if $(LOAD_MEM) eq 

MKIMAGE := $(BEAGLE_ROOT)/items/scripts/beagle-gp-image.py
override TI_IMAGE_RAW:=$(TI_IMAGE_RAW:y=-raw)

OBJS := gpio_main.o asm.o 

.ONESHELL:;
.SECONDEXPANSION:;

%.o: $$*.c
	arm-none-eabi-gcc $(ARCH_FLAGS) $(CFLAGS) -c -o $@ $*.c
%.o: $$*.S
	arm-none-eabi-gcc $(ARCH_FLAGS) $(CFLAGS) -c -o $@ $*.S

.compile: $(OBJS)
	touch .compile

link.fixed.lds: link.lds
	sed -i.old -r 's/MEM_XXX/$(LOAD_MEM)/' link.lds
	mv -v link.lds link.fixed.lds
	mv -v link.lds.old link.lds

gpio.elf: link.fixed.lds .compile
	arm-none-eabi-ld --gc-sections --defsym _STACK_SIZE=0x1000 -Map gpio.map -T link.fixed.lds -n -o gpio.elf --start-group $(OBJS) --end-group

start.bin: link.fixed.lds init.S
	arm-none-eabi-gcc $(ARCH_FLAGS) -masm=unified -g -c -o start.o init.S
	arm-none-eabi-ld --gc-sections -Map start.map -T link.fixed.lds -n -o start.elf start.o
	arm-none-eabi-objcopy -O binary start.elf start.bin

loop.bin: link.fixed.lds init.S
	arm-none-eabi-gcc $(ARCH_FLAGS) -masm=unified -g -D_IDLE_LOOP -c -o init.o init.S
	arm-none-eabi-objcopy --add-section .sect_loop=init.o --rename-section .sect_loop=.text init.o loop.o
	arm-none-eabi-ld --gc-sections -Map loop.map -T link.fixed.lds -n -o loop.elf loop.o
	arm-none-eabi-objcopy -O binary loop.elf loop.bin
#	rm -v init.o
#	rm -v loop.o
#	rm -v loop.elf

qemu_targets: start.bin loop.bin


.image: $(MKIMAGE) gpio.elf
	arm-none-eabi-objcopy -O binary gpio.elf gpio.bin
	echo $(TI_IMAGE_RAW)
	$(MKIMAGE) gpio.bin $(LOAD_ADDR) $(TI_IMAGE_RAW)
	@touch .image

load: .image
	@SERIAL_COL=$$(($$(lsblk -l -p -O | head -n 1 | sed 's/SERIAL.*//' | wc | sed -r 's/([ ]+[^ ]+){2}[ ]+//') - 1))
	@NAME_COL_LEN=$$(($$(lsblk -l -p -O | head -n 1 | sed -r 's/([^ ]+[ ]+).*/\1/' | wc | sed -r 's/([ ]+[^ ]+){2}[ ]+//') - 1))
# echo 's/((.){'$${NAME_COL_LEN}'})(.){'$$(($${SERIAL_COL} - $${NAME_COL_LEN} - 1))'}/\1/'
	@MMC_DEV=$$(lsblk -l -p -O | sed -r 's/((.){'$${NAME_COL_LEN}'})(.){'$$(($${SERIAL_COL} - $${NAME_COL_LEN} - 1))'}/\1/' | grep $(MMC_SERIAL) | sed -r 's/[ ]+.*//')
#	cp -v fat12.img mmc.img
#	losetup -f -P mmc.img
#	mount /dev/loop0p1 /mnt/tmp0
#	cp gpio.bin /mnt/tmp0/MLO
#	umount /mnt/tmp0
#	dd if=mmc.img of=$${MMC_DEV} bs=4096 status=progress
#	dd if=$${MMC_DEV} of=u-boot.img.readback bs=4096 count=$$((2**21 / 4096)) status=progress
	if [[ -z "$${MMC_DEV}" ]]; then
	  echo MMC not found...;
	  exit 1;
	fi
	case $(IMAGE_MODE) in
	  file )
	    FAT_PARTITION=$${MMC_DEV}1
	    MOUNT_PATH=$$((udisksctl mount -b $${FAT_PARTITION} || exit 1) | sed -r 's/Mounted [^ ]+ at //')
	    cp -v u-boot.img $${MOUNT_PATH}/MLO
	    cp $${MOUNT_PATH}/MLO u-boot.img.readback
	    udisksctl unmount -b $${FAT_PARTITION} || exit 1
	    ;;
	  raw )
	    dd if=u-boot.img of=$${MMC_DEV} bs=4096 status=progress
	    dd if=$${MMC_DEV} of=u-boot.img.readback bs=4096 count=$$((2**17 / 4096)) status=progress
	    ;;
	  * )
	    echo Invalid file mode $(FILE_MODE).
	    exit 1
	    ;;
	esac
	if [[ $$(diff u-boot.img u-boot.img.readback) ]]; then
	  echo Writing image failed...;
	else
	  echo Write success.
	fi
	rm -f u-boot.img.readback

all: image

clean:
	rm -f $(OBJS)
	rm -f link.fixed.lds
	rm -f gpio.elf
	rm -f gpio.bin
	rm -f u-boot.img
