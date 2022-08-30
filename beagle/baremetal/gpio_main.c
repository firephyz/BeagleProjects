/* #include <asm/arch/sys_proto.h> */
#include <stdint.h>
#include <armv7.h>

// Assume non-secure supervisor entry

/* extern char _stack_top[]; */
/* void * _stack_top = 0x402F0100; */
/* extern char _user_vectors[]; */

/* #define GET_FIRST(a,...) a
 * #define GET_SECOND(a,...) GET_FIRST(__VA_ARGS__)
 * #define _ASM_REG_OP_CLEAR(regname, mask) "bic "#regname", "#mask"\n"
 * #define _ASM_REG_OP_SET(regname, mask) "orr "#regname", "#mask"\n"
 * #define __CP15_OP_REG_OP(x) _ASM_REG_OP_ ## x
 * #define _CP15_OP_REG_OP(x) __CP15_OP_REG_OP(x)
 * #define _CP15_OP(a0, a1, a2, a3, ...) \
 *   {uint32_t __cp_reg__; \
 *   asm volatile ( \
 *       "mrc p15, "#a0", %[_cp_reg], "#a1", "#a2", "#a3"\n" \
 *       _CP15_OP_REG_OP(GET_SECOND(__VA_ARGS__))(%[_cp_reg], %[_mask]) \
 *       "mcr p15, "#a0", %[_cp_reg], "#a1", "#a2", "#a3"\n" \
 *       "isb\n" \
 *     : [_cp_reg]"=&r" (__cp_reg__) \
 *       : [_mask]"i" (GET_FIRST(__VA_ARGS__)));}
 * #define SET_SCTLR(val, op) _CP15_OP(0, c1, c0, 0, val, op) */

// Defer argument expansion until after substituted to obtain correct order of concatenation and expansion
/* #define JOIN_INNER(x,y) x ## y
 * #define JOIN(x,y) JOIN_INNER(x,y) */

/* __attribute__((always_inline))
 * inline void set_scr_ns_bit(uint32_t val) {
 *   uint32_t scr_reg;
 *   asm volatile (
 *       "mrc p15, 0, %[scr_reg], c1, c1, 0\n"
 *       "bic %[scr_reg], %[_ns_mask]\n"
 *       "orr %[scr_reg], %[_ns_value]\n"
 *       "mcr p15, 0, %[scr_reg], c1, c1, 0\n"
 *       "isb\n"
 *       "nop\n"
 *       "nop\n"
 *       "nop\n"
 *       : [scr_reg]"=&r"(scr_reg)
 *       : [_ns_mask]"i"((uint32_t)0x1), [_ns_value]"r"(val));
 * } */

__attribute__((always_inline))
inline void delay(uint64_t count) {
  for(uint64_t i = 0; i < count; ++i) {
    asm(";");
  }
}

__attribute__((noinline))
void test_func1() {
/*   extern char _stack_top[];
 *   volatile uint32_t * a = (uint32_t *)(_stack_top + 0x10);
 *   for(int i = 0;i < 3; ++i) {*a = i;} */
  asm volatile("nop");
}

__attribute__((noinline))
int test_func() {
/*   extern char _stack_top[];
 *   volatile uint32_t * a = (uint32_t *)(_stack_top + 0x10);
 *   for(int i = 0;i < 3; ++i) {*a = i;} */
  asm volatile("nop");
  test_func1();
}

__attribute__((optimize ("s")))
void blink() {
  const uint64_t BLINK_DELAY = 100000000;
  //  44E0_7000
  uint32_t * bank = (void *)0x4804C000;
/*   test_func(); */
  *(bank + 0x10/4) = 0x0008;
  *(bank + 0x3C/4) = 0xFFFFFFFF; // irq disable
  *(bank + 0x40/4) = 0xFFFFFFFF;
  *(bank + 0x44/4) = 0x0;        // disable wakeup
  *(bank + 0x48/4) = 0x0;
  *(bank + 0x130/4) = 0x0;       // configure module gate and clocks
  *(bank + 0x134/4) = 0x0;       // set all GPIO as output
  *(bank + 0x140/4) = 0x0;       // disable level-detect irq
  *(bank + 0x144/4) = 0x0;
  *(bank + 0x148/4) = 0x0;       // disable rising detect irq
  *(bank + 0x14C/4) = 0x0;       // disable falling detect irq
  asm volatile("mcr p15, 0, r0, c7, c10, 4");
  *(bank + 0x194/4) = (1 << 21);
  asm volatile("mcr p15, 0, r0, c7, c10, 4");
  delay(BLINK_DELAY);
  *(bank + 0x190/4) = (1 << 21);
  asm volatile("mcr p15, 0, r0, c7, c10, 4");
  *(bank + 0x194/4) = (1 << 22);
  asm volatile("mcr p15, 0, r0, c7, c10, 4");
  delay(BLINK_DELAY);
  *(bank + 0x190/4) = (1 << 22);
  asm volatile("mcr p15, 0, r0, c7, c10, 4");
  *(bank + 0x194/4) = (1 << 23);
  asm volatile("mcr p15, 0, r0, c7, c10, 4");
  delay(BLINK_DELAY);
  *(bank + 0x190/4) = (1 << 23);
  asm volatile("mcr p15, 0, r0, c7, c10, 4");
  *(bank + 0x194/4) = (1 << 24);
  asm volatile("mcr p15, 0, r0, c7, c10, 4");
  delay(BLINK_DELAY);
  *(bank + 0x190/4) = (1 << 24);
  asm volatile("mcr p15, 0, r0, c7, c10, 4");
}

__attribute__((interrupt ("swi")))
void _interrupt_handler() {
/*   while (1) { asm volatile("wfe"); }
 *   void _start();
 *   asm volatile (		
 *     "ldr lr, =%[_start_entry]\n"
 *     : : [_start_entry]"i"(_start)); */
}

__attribute__((section (".start"), naked))
void _start() {
/*   void set_scr();
 *   void disable_interrupts();
 *   void disable_cache_and_mmu();
 *   void set_stack(); */

/*   set_scr();
 *   disable_interrupts();
 *   disable_cache_and_mmu();
 *   set_stack(); */
/*   asm volatile ("svc 0");
 *   asm volatile ("udf"); */
  *((uint32_t *)0x4804C000 + 0x194/4) = (1 << 21);
  blink();
  while (1) { asm volatile("wfe"); }
}
