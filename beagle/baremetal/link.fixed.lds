/* SEARCH_DIR(/home/kyle/dev/beagle/u-boot) */

/* GROUP(arch/arm/cpu/built-in.o) */

/* STARTUP(gpio_main.o) */

MEMORY {
  sram (wx)        : ORIGIN = 0x402f0400, LENGTH = 128K
  emif0_sdram (wx) : ORIGIN = 0x80000000, LENGTH = 512M

  qemu_sram (wx)   : ORIGIN = 0x42000000, LENGTH = 32M
}

REGION_ALIAS("LOAD_REGION", qemu_sram)
/* REGION_ALIAS("LOAD_REGION", emif0_sdram) */
/* REGION_ALIAS("LOAD_REGION", sram) */

ENTRY(_start)

SECTIONS {
  . = 0x0;
  .skip (NOLOAD) : {
    . = . + 0x400; /* Skip first 1K */
  } >sram

  .text : ALIGN(0x10) {
    *(.text)
    *(.text.*)
  } >LOAD_REGION

  .data : {
    *(.data)
    *(.data.*)
  } >LOAD_REGION

  .bss (NOLOAD) : {
    *(.bss)
    *(.bss.*)

    _stack_bottom = .;
    . = . + _STACK_SIZE;
    PROVIDE(_stack_top = .);
  } >LOAD_REGION

  .rodata : {
    *(.rodata)
    *(.rodata.*)
  } >LOAD_REGION
  
  /DISCARD/ : {
    *(*)
  }
}
