/*
Output sections may be "loadable" or "allocable" or neither. Allocable sections don't load any contents into memory
  but they are allocated space (filled with some value). Sections with neither of those attibutes (no content to
  load and no space to allocate) are usually debug info sections or other misc data.
Output section addressing schemes:
  VMA (virtual memory address) - the address the section when have when the code is run.
  LMA (load memory address) - the address the section is loaded at

  These are most often the same except when shadowing the LMA contents into some other address space at runtime
    and specified by the VMA.

Executable 'entry' is defined with the following precedence rules:
  - first, any -e options passed into 'ld'
  - any ENTRY(...) statements in the linker script
  - target-specific entry-point (default I think is _start)
  - the start of the .text output section
  - address 0x0

Object files search order:
  - (sysroot if using an INPUT statement and you specified the sysroot)
  - searches directory containing linker script
  - searches current directory
  - searches the library search path

Commands
  File related commands
    INCLUDE - includes specified linker script
    INPUT(...) - uses the given file as an input object file to ld
    GROUP(...) - like INPUT but given a list of archives to repeatedly search over for dependencies
    AS_NEEDED(...) - used inside INPUT or GROUP commands; brings in a specified ELF shared library only
      when necessary.
    OUTPUT(...) - output filename
    SEARCH_DIR(...) - directory to add to the library search path. command line -L options take precedence
    STARTUP(...) - makes the given file to be the first object file processed (like it were specified first
      in the object file list)
  Regions
    REGION_ALIAS(<alias>, <region>) - allows providing an alias to a given memory region

  Other
    ASSERT(<expression>, <message>)
      - asserts that expression is non-zero, otherwise exit linker with error message.
    EXTERN(<symbols)
      - forces symbol to be undefined (and thereby require pulling in a library of something).
    FORCE_COMMON_ALLOCATION
      - make ld assign space to common symbols; same as '-d' (force common symbols to be defined)
        even if relocable output is being produced
    INHIBIT_COMMON_ALLOCATION
      - prohibits ld from assigning addresses to common symbols even if producing non-relocatable
        output. Same as '--no-define-common'.
    FORCE_GROUP_ALLOCATION
      - (removes a group?) and places the sections 'normally'
    INSERT [ AFTER | BEFORE ] output_section
      - used to retroactively place the previous linker script statements so far encountered after
        or before a given output section. Happens after input sections are (all?) mapped to
        output sections.
    
Symbols
  Relative (when inside an OUTPUT section) vs absolute symbols. There are some naunces between the use of
    these two in expressions.
  May be assigned throughout the script (in and out of SECTIONS, regardless of input or output).
  HIDDEN(<assignment>)
    - makes that symbol assignment hidden from outside the unit. Won't be exported.
  PROVIDE(<symbol>)
    - "a back-up define" for symbols that are referenced but not defined. Allows link stage to auto-provide
      a needed symbol.
    - common symbols are already considered defined (and therefore aren't "PROVIDED"?)
  PROVIDE_HIDDEN
    - on ELF, similar to PROVIDE but not exported
  
  A symbol functions as an address.
    - In C, it is allocated memory space for the value and the address of that is the actual
    'value' of the linker symbol in the generated symbol table.

  *** Location Counter ***
    A '.' is the location counter symbol (refering to a location in OUTPUT sections). It may be assigned in
      order to move the location counter.
      - backward assignments are permitted inside an output section but are not peritted outside of an output
        section if that results in LMA-overlapping output sections.
    Assignments to the location counter "bind" themselves to the next functional statement (and anything in
      between them and that statement).
      - you can use this to counteract some indeterminent behavior (like auto-placing orphan sections).
    The location counter acts as a relative address when stored in a symbol inside an output section statement.
      When used in an expression however, the '.' symbol directly acts as an absolute symbol.

Functions
  ABSOLUTE(exp)
    - Returns the absolute address of a given item; the non-relocatable version.
  ADDR(section)
    - returns the VMA of the named section
  ALIGN(align)
  ALIGN(exp,align)
    - returns the aligned value (ALIGN(align) <=> ALIGN(ABSOLUTE(.), align)). If no expression is given, it will use
      the location counter.
  ALIGNOF(section)
    - Returns the alignment of an already allocated section (if not allocated, then error).
  DATA_SEGMENT_ALIGN(maxpagesize, commonpagesize)
  DATA_SEGMENT_END(exp)
  DATA_SEGMENT_RELRO_END(offset, exp)
  DEFINED(symbol)
    - returns 1 if the symbol is defined before the statement.
      Ex: begin = DEFINED(begin) ? begin : . ;
  LENGTH(memory)
    - return the length of the memory region
  LOADADDR(section)
    - return the absolute LMA
  LOG2CEIL(exp)
  MAX(exp1, exp2)
  MIN(exp1, exp2)
  NEXT(exp)
    - nearly equivelent to ALIGN. Returns the next "unallocated" address though, not just a math function... See
      its use with discontinuous MEMORYies.
  ORIGIN(memory)
    - return the origin of the memory region
  SIZEOF(section)
    - return the size in bytes of the named section, if that section has been allocated
  SIZEOF_HEADERS
    - returns the size in bytes of the output file's headers.

Memory
  MEMORY {
      <name> [(<attr>)] : ORIGIN = <origin>, LENGTH = <len>
      …
  }

  Memory attr is one of:
    R - read-only
    W - read/write
    X - executable
    a - allocatable
    I - initialized section
    ! - inverts all those attributes which follow it

Sections
  SECTIONS {
    <ENTRY|Symbol-assignment|Output section|Overlay>
    ...
  }

  <Output section>:
    section [address] [(type)] :
      [AT(lma)]
      [ALIGN(section-align)|ALIGN_WITH_INPUT]
      [SUBALIGN(subsection-align)]
      [constraint]
    {
      <symbol-assignment>|<input-section>|<data-values>|<KEYWORD>
      ...
    } [>region] [AT>lma_region] [:phdr :phdr ...] [=fillexp] [,]

  <data-value>:
    BYTE|SHORT|LONG|QUAD - 1, 2, 4, 8 bytes respectively
    |SQUAD - sign-extended version of QUAD for 32-bit targets that have expressions defaulting to 32-bits
  <KEYWORD>:
    CREATE_OBJECT_SYMBOLS - create a symbol for the name of each input file
    CONSTRUCTORS - place C++ ctor and dtor information here in a particular OUTPUT section
  <type>: NOLOAD

  ALIGN_WITH_INPUT: specifies that the VMA and LMA separation must be the same for all input <-> output sections
    in an output section command.
  Most recent FILL statements take precedence over any [=fillexp] expression which may follow an OUTPUT section
    declaration.
  If no output section address is specified, then it is automatically placed with the strictly alignment requirement
    of the input sections which compose it. If no address is provided, the placement hieristic is:
    - the next MEMORY location available according to the MEMORY assigned to this output section
    - the next MEMORY location which has the right attributes to hold this section
    - placed based on the current value of the location counter
  Empty output sections are generally not placed in the output file.
    - unless a non-zero assignment to '.' occurs
    - symbols defined within a discarded output section are still evaluated... to some value.

  Input Section
    EXCLUDE_FILE(<exclude-pattern> ) <object-pattern>(<input-section-pattern>)
      - excludes the files in the <exclude-pattern> from the list of object files from which
        to extract input sections.
  '/DISCARD/' output section name may be used to discard input sections


* input section : https://sourceware.org/binutils/docs/ld/Input-Section.html
* output section attributes : https://sourceware.org/binutils/docs/ld/Output-Section-Attributes.html
* overlays : https://sourceware.org/binutils/docs/ld/SECTIONS.html

PROVIDES - inside sections don't take effect in that area so assertions fail; declare the PROVIDE outside of the
           section to resolve the symbol.

*/

MEMORY {
  /* AM335x */
  am335x_gpmc       (!RWXAI) : ORIGIN = 0x00000000, LENGTH = 0x20000000 /* General Purpose Memory Controller */
  am335x_boot_rom   (RXI!WA) : ORIGIN = 0x40000000, LENGTH =    0x2C000 /* Boot Rom */
  am335x_isram      (WXA!RI) : ORIGIN = 0x402F0000, LENGTH =    0x10000 /* Internal SRAM */
  am335x_ocmc       (WXA!RI) : ORIGIN = 0x40300000, LENGTH =    0x10000 /* On-Chip Memory Controller */
  am335x_emif       (!RWXAI) : ORIGIN = 0x80000000, LENGTH = 0x40000000 /* Async External Memory Interface */

  /* Abstracted Memories */
  am335x_public_rom (RXI!WA) : ORIGIN = ORIGIN(am335x_boot_rom) + 0x20000, LENGTH = LENGTH(am335x_boot_rom) - 0x20000 /* Public Exposed ROM */
  am335x_load_image (WXA!RI) : ORIGIN = ORIGIN(am335x_isram) + 0x400, LENGTH = LENGTH(am335x_isram) - 0x400 /* Image download location */

  /* Beagle Bone Black */
  beagle_bone_black_sdram    (WXA!RI) : ORIGIN = 0x80000000, LENGTH = 0x20000000 /* EMIF SDRAM */
}

MEMORY {
  qemu_ram        (wxa!ri) : ORIGIN = 0x00000000, LENGTH = 0x40000000
  qemu_load_image (wxa!ri) : ORIGIN =   0x100000, LENGTH = LENGTH(qemu_ram) - ORIGIN(qemu_load_image)
}

/* REGION_ALIAS(load_image, am335x_load_image) */
REGION_ALIAS("load_image", qemu_load_image);

SECTIONS {
  .text : AT(0x0) {
    *(.start)
    *(.text*)
  } >load_image

  .data : {
    *(.data*)

    _init_array_base = ABSOLUTE(.);
    *(.init_array)
    _init_array_top = ABSOLUTE(.);
  } >load_image

  .bss (NOLOAD): {
    *(.bss*)
    . = ABSOLUTE(0x200000);
  } >load_image
  _stack_top = .;

  .rodata : {
    *(.rodata*)
  } >load_image

  /DISCARD/ : {
    *(.ARM*)
    *(.comment*)
  }
}
