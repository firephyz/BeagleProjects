	.section .text._ModuleEntryPoint, "ax"
	.global _BootloaderImageBase
_BootloaderImageBase:	
	.global _ModuleEntryPoint
	.type _ModuleEntryPoint, %function
_ModuleEntryPoint:

	ldr sp, =0x100000
	ldr r1, CEntryPtr
	blx r1
CEntryPtr:
	.word CEntry
