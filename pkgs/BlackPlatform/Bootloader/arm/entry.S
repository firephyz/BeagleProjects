
	.global _ModuleEntryPoint
	.section .text._ModuleEntryPoint, "ax"
	.type _ModuleEntryPoint, %function
_ModuleEntryPoint:	
	ldr pc, =CEntryPoint
