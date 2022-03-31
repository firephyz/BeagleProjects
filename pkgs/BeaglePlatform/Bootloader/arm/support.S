	.section .text, "ax"
	.thumb

	.global arm_set_privilege_level
arm_set_privilege_level:
	push {lr}
	sub sp, #0x4
	str r4, [sp, #0x0]
	mov r4, sp
	
	mrs r2, cpsr
	ldr r3, =0x0000001F
	bic r2, r2, r3
	orr r2, r2, r0
	msr cpsr, r2
	isb
	dsb

	mov sp, r4
	ldr r4, [sp, #0x0]
	ldr r3, [sp, #0x4]
	mov lr, r3
	add sp, #0x8
	bx lr

	.global arm_read_privilege_level
arm_read_privilege_level:
	mrs r2, cpsr
	ldr r3, =0x1F
	and r2, r2, r3
	mov r0, r2
	bx lr
/*

	.section .text_test, "ax"
	.org 0x0
	
	.global test
test:
	ldr pc, =0x400
*/
