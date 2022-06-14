/* #include <asm/arch/sys_proto.h> */
#include <stdint.h>

extern char _stack_top[];
/* void * _stack_top = 0x402F0100; */

__attribute__((always_inline))
inline void delay(uint64_t count) {
  for(uint64_t i = 0; i < count; ++i) {
    asm(";");
  }
}

__attribute__((always_inline))
inline void disable_icache_and_mmu() {
  uint32_t cpsr_reg;
  asm volatile (".syntax unified\n"
      "mrc p15, 0, %[cpsr], c1, c0, 0\n"
      "bic %[cpsr], %[mask]\n"
      "mcr p15, 0, %[cpsr], c1, c0, 0\n"
      "isb\n"
    : [cpsr]"=&r" (cpsr_reg)
    : [mask]"r" (0x1001));
}

__attribute__((always_inline))
inline void disable_interrupts() {
  asm(".syntax unified\n"
      "mrc p15, 0, r2, c1, c0, 0\n"
      "ldr r3, =0x1001\n"
      "bic r2, r3\n"
      "mcr p15, 0, r2, c1, c0, 0\n"
      "isb\n"
      :  :  : "r2", "r3");
}

__attribute__((always_inline))
inline void set_stack_pointer() {
  asm(".syntax unified\n"
      "ldr sp, =%0"
      :  : "i" (_stack_top));
}

/* inline void delay(uint64_t count); */

__attribute__((optimize ("s")))
void blink() {
  const uint64_t BLINK_DELAY = 100000000;
  uint32_t * bank = (void *)0x4804C000;
  *(bank + 0x3C/4) = 0xFFFF;
  *(bank + 0x40/4) = 0xFFFF;
  *(bank + 0x44/4) = 0x0;
  *(bank + 0x48/4) = 0x0;
  *(bank + 0x130/4) = 0x0;
  *(bank + 0x134/4) = 0x0;
  *(bank + 0x140/4) = 0x0;
  *(bank + 0x144/4) = 0x0;
  *(bank + 0x148/4) = 0x0;
  *(bank + 0x14C/4) = 0x0;
  *(bank + 0x194/4) = (1 << 21);
  delay(BLINK_DELAY);
  *(bank + 0x190/4) = (1 << 21);
  *(bank + 0x194/4) = (1 << 22);
  delay(BLINK_DELAY);
  *(bank + 0x190/4) = (1 << 22);
  *(bank + 0x194/4) = (1 << 23);
  delay(BLINK_DELAY);
  *(bank + 0x190/4) = (1 << 23);
  *(bank + 0x194/4) = (1 << 24);
  delay(BLINK_DELAY);
  *(bank + 0x190/4) = (1 << 24);
}

__attribute__((naked))
void _start() {
  disable_interrupts();
  disable_icache_and_mmu();
  set_stack_pointer();
  blink();
  while (1) {}
}
