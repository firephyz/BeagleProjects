	.syntax unified

// 	.set CPSR_SWP_BIT, 0x400
// 	.set nCPSR_SWP_BIT, 0xFFFFFFFF ^ CPSR_SWP_BIT

	.text
#ifdef _IDLE_LOOP
	.section .sect_loop,"ax"

	.global _start
_start:	b _start
#else
	.global _start
_start:
// //	bl _disable_branch_pred
// 	ldr ip, =swp_addr
// 	ldr r5, =0x4321
// 	mrc p15, 0, r1, c1, c0, 0
// 	orr r1, r1, CPSR_SWP_BIT
// 	mcr p15, 0, r1, c1, c0, 0
// 	isb
// 	swp r5, r5, [ip]
// 	nop
// // 	ldr r5, =swp_addr
// 	swp r5, r5, [ip]
// 	mrc p15, 0, r1, c1, c0, 0
// 	ldr r2, =nCPSR_SWP_BIT
// 	and r1, r2
// 	mcr p15, 0, r1, c1, c0, 0
// 	isb
// 	swp r5, r5, [ip]
	bl _disable_icache
	bl _disable_mmu
	b _done
// 	mrc p15, 0, r1, c0, c0, 0 /* MIDR Main ID reg */
// 	mrc p15, 0, r2, c0, c0, 6 /* REVIDR Rev ID reg */
// //	mrc p15, 0, <Rt>, c0, c0, 2 /* TCMTR TCM type reg

// // 	// Disable use of branch predictor
// // _disable_branch_pred:
// // 	mrc p15, 0, r1, c1, c0, 0
// // 	bic r1, r1, #0x800
// // 	mcr p15, 0, r1, c1, c0, 0
// // 	isb
// // 	mov pc, lr
// swp_addr:
// 	.word 0xa5a55a5a

	// Disable use of instruction cache
_disable_icache:
	mrc p15, 0, r1, c1, c0, 0
	bic r1, r1, 0x1000
	mcr p15, 0, r1, c1, c0, 0
//	mcr p15, 0, r0, c7, c5, 0 // invalid icache
	isb
	mov pc, lr

	// Disable stage 1 MMU. Must make sure current code region is ready for the change
	// of address mapping if necessary.
_disable_mmu:
	mrc p15, 0, r1, c1, c0, 0
	bic r1, r1, 0x1
	mcr p15, 0, r1, c1, c0, 0
	isb
	mov pc, lr

// _start:	mrs r0, cpsr
// 	mrs r1, apsr
// 	mrs r2, spsr
// 	mrc p15, 0, r3, c0, c1, 1

// 	ldr ip, spsr_inst
// 	ldr r2, [ip]
// 	mov r3, 0x00100000
// 	eor r2, r2, r3
// 	str r2, [ip]
// 	nop
// 	nop
// 	nop
// spsr_inst:
_done:	
	b _done
#endif
