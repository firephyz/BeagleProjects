LINKER_SCRIPT=/home/kyle/o/beagle/link.ld

SYSROOT=/home/builder/rpmbuild/BUILDROOT/tools

_objc=$(SYSROOT)/bin/arm-none-eabi-objcopy
_gcc =$(SYSROOT)/bin/arm-none-eabi-gcc
_g++ =$(SYSROOT)/bin/arm-none-eabi-g++
_ld  =$(SYSROOT)/bin/arm-none-eabi-ld

ARCH_FLAGS=-mfloat-abi=soft -mcpu=cortex-a8
INCLUDES=-Ipkgs/BeaglePlatform/Bootloader/Include
SOURCE=pkgs/BeaglePlatform/Bootloader/gpio.cpp

GCC_LIB_PATH=$(SYSROOT)/lib/gcc/arm-none-eabi/10.1.0/$(shell $(_gcc) $(ARCH_FLAGS) --print-multi-directory)

all: binary

install: binary
	cp -v test.bin /home/kyle/o/beagle/edk2/Build/BeagleBone/DEBUG_GCC5/ARM/test.bin

binary: elf
	$(_objc) -O binary -S test.elf test.bin

#$(GCC_LIB_PATH)/crti.o
elf: obj
	$(_ld) -T $(LINKER_SCRIPT) -o test.elf --start-group test.o --end-group

obj: $(SOURCE) link.ld
	$(_g++) $(ARCH_FLAGS) $(INCLUDES) -std=c++20 -g -c -Os -o test.o $(SOURCE)

clean:
	rm -vf test.elf test.o test.bin
