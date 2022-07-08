	.syntax unified

	.macro cp15_op op_mode, a0, a1, a2, a3, value, wide_mode=no
	mrc p15, \a0, r1, \a1, \a2, \a3
	.ifc \op_mode,write
  	  .ifc \wide_mode,wide
	    mov r1, \value
	  .else
	    mov r1, \value
	  .endif
	.else
	  .ifc \op_mode,set
  	    .ifc \wide_mode,wide
	      mov r2, \value
              orr r1, r2
	    .else
	      orr r1, \value
	    .endif
	  .else
	    .ifc \op_mode,clear
  	      .ifc \wide_mode,wide
	        mov r2, \value
                bic r1, r2
	      .else
	        bic r1, \value
	      .endif
	    .else
	      .error "Invalid macro cp15_op op_mode \op_mode"
	    .endif
	  .endif
	.endif
	mcr p15, \a0, r1, \a1, \a2, \a3
	isb
	nop
	nop
	.endm

#include <armv7.h>
	
	.section .text.early_asm, "ax"
	.global set_scr
set_scr:
// 	cp15_op set,   0, c1, c1, 0, SCR_NS // set non-secure state
// 	cp15_op set,   0, c1, c1, 0, (SCR_AW | SCR_FW) // enable nonsec exception masking
// 	cp15_op clear, 0, c1, c1, 0, (SCR_EA | SCR_FIQ | SCR_IRQ) // disable exception rerouting to secure state
	mov pc, lr

	.global disable_interrupts
disable_interrupts:
	// mask interrupt sources
	cpsid aif

	// set vector base address
	ldr r2, =_user_vectors
	dsb
	cp15_op write, 0, c12, c0, 0, r2
	cp15_op clear, 0, c1, c0, 0, SCTLR_V  //select vectored interrupts
	mov pc, lr

	.global disable_cache_and_mmu
disable_cache_and_mmu:
	isb
	//cp15_op clear, 0, c1, c0, 0, (SCTLR_I | SCTLR_C | SCTLR_M), wide
	// 	cp15_op clear, 0, c1, c0, 0, SCTLR_C
	cp15_op clear, 0, c1, c0, 0, (SCTLR_C | SCTLR_Z | SCTLR_M), wide
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	mrc p15, 0, r0, c1, c0, 0
	mov pc, lr

	.global set_stack
set_stack:
	ldr sp, =_stack_top
	mov pc, lr

	.section .text.vectors, "ax"
	.align 5
_user_vectors:
	b _start              // reset
	b _interrupt_handler  // undef. instr.
	b _interrupt_handler  // supervisor
	b _interrupt_handler  // prefetch abort
	b _interrupt_handler  // data abort
	b _interrupt_handler  // hyp trap
	b _interrupt_handler  // irq
	b _interrupt_handler  // fiq
	
