ARM_SYSROOT ?= /home/builder/rpmbuild/BUILDROOT/tools 
ARM_PREFIX  ?= $(join $(ARM_SYSROOT),/bin/arm-none-eabi-)

GNU_CC     :=$(ARM_PREFIX)gcc
GNU_CPP    :=$(ARM_PREFIX)g++
GNU_AS     :=$(ARM_PREFIX)as
GNU_LD     :=$(ARM_PREFIX)ld
GNU_OBJC   :=$(ARM_PREFIX)objcopy

define objs_from_sources
	$(shell echo $(1) | sed -r 's/src\/([^.]+)\.(cpp|c)/build\/\1.o/g')
endef

OPT_LEVEL  ?= s
# WITH_DEBUG ?=

ARCH_FLAGS :=-mcpu=cortex-a8 -mfloat-abi=soft
CFLAGS     := $(ARCH_FLAGS) -std=c++20\
              -I$(CURDIR)/include \
              $(if $(OPT_LEVEL),$(join -O,$(OPT_LEVEL)),-O0) \
              $(if $(WITH_DEBUG),-g)

test_BINARY := test.bin
test_SRCS   := $(shell find src/ -regextype posix-extended -regex ".*\.(cpp|c)")
test_OBJS   := $(call objs_from_sources,$(test_SRCS))
test_LINK_SCRIPT := /home/kyle/o/beagle/link.ld

.SECONDARY:;
.SECONDEXPANSION:;
test: $$($$@_BINARY);

%.bin: $$*.elf;
	$(GNU_OBJC) -S -O binary build/$< build/$@

%.elf: $$($$*_LINK_SCRIPT) $$($$*_OBJS)
	echo $($*_OBJS)
	echo $(test_SRCS)
	$(GNU_LD) -T $($*_LINK_SCRIPT) -o build/$*.elf $($*_OBJS)

build/%.o: src/$$*.cpp
	mkdir -p build/$(*D)
	$(GNU_CPP) $(CFLAGS) -c -o $@ $^

build/%.o: src/$$*.c
	$(GNU_CC) $(CFLAGS) -c -o $@ $^

# build-prep:;
# 	mkdir -p build
