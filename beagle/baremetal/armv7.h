#ifndef _ARMV7_INCLUDED
#define _ARMV7_INCLUDED

#define CPSR_CN        0x80000000 /* Condition neg */
#define CPSR_NZ        0x40000000 /* Condition zero */
#define CPSR_CC        0x20000000 /* Condition carry */
#define CPSR_CV        0x10000000 /* Condition overflow */
#define CPSR_CQ        0x08000000 /* Condition saturation */
#define CPSR_J         0x01000000 /* Jazelle state (ISETSTATE.J) */
#define CPSR_GE        0x000F0000 /* Greater than or equal for SIMD arith. */
#define CPSR_IT        0x0600FC00 /* If-Then block execution bits */
#define CPSR_E         0x00000200 /* Endianess */
#define CPSR_A         0x00000100 /* Asynch. abort mask */
#define CPSR_I         0x00000080 /* IRQ mask */
#define CPSR_F         0x00000040 /* FIQ mask */
#define CPSR_T         0x00000020 /* Thumb execution state (ISETSTATE.I) */
#define CPSR_M         0x0000001F /* Processor mode */

#define SCTLR_TE       0x40000000 /* Thumb exceptions (defaults ARM) */
#define SCTLR_AFE      0x20000000 /* Access flag enable */
#define SCTLR_TRE      0x10000000 /* TEX remap enable */
#define SCTLR_NMFI     0x08000000 /* Non-maskable FIQ support (RO) */
#define SCTLR_EE       0x02000000 /* Exception (and TLB) endianess */
#define SCTLR_VE       0x01000000 /* Interrupt Vectors enable */
#define SCTLR_FI       0x00200000 /* Fast Interrupts config. enable */
#define SCTLR_UWXN     0x00100000 /* Unpriv. write perm. region implies PL1 execution */
#define SCTLR_WXN      0x00080000 /* Write perm. region implies PL1 execution */
#define SCTLR_HA       0x00020000 /* Hardware management of access flag enable */
#define SCTLR_RR       0x00004000 /* Round robin cache enable (as opposed to random) */
#define SCTLR_V        0x00002000 /* Vectors select bit */
#define SCTLR_I        0x00001000 /* I-cache enable */
#define SCTLR_Z        0x00000800 /* Branch prediction enable */
#define SCTLR_SW       0x00000400 /* Swap instr. enable */
#define SCTLR_CP15BEN  0x00000020 /* CP15 Barriers Enable (if disabled, they are undefined) */
#define SCTLR_C        0x00000004 /* Cache enable */
#define SCTLR_A        0x00000002 /* Alignment check enable */
#define SCTLR_M        0x00000001 /* MMU enable */

#define SCR_SIF        0x00000200 /* Disable secure instruction fetch from non-secure memory */
#define SCR_HCE        0x00000100 /* Enable HVC instruction */
#define SCR_SCD        0x00000080 /* Disable interpretation of SMC while in non-secure mode */
#define SCR_NET        0x00000040 /* Disable early-termination optimization of instructions (enable constant execution time) */
#define SCR_AW         0x00000020 /* A-bit nonsec writable enable (or reroute disable (nonsec mask enable) when secure ext.) */
#define SCR_FW         0x00000010 /* F-bit nonsec writable eanble (or reroute disable (nonsec mask enable) when secure ext.) */
#define SCR_EA         0x00000008 /* External aborts taken to monitor mode enable */
#define SCR_FIQ        0x00000004 /* FIQ taken to monitor mode enable */
#define SCR_IRQ        0x00000002 /* IRQ taken to monitor mode enable */
#define SCR_NS         0x00000001 /* Non-secure state enable */

#endif
