#include <algorithm>

#include "general_types.h"

extern "C" {
  extern u8 _stack_top[];
  extern void (*_init_array_base)();
  extern void (*_init_array_top)();

  extern int main();

  __attribute__((section(".start"), naked))
  void _start() {
    asm("mov sp, %0" : : "r" (_stack_top));
    std::for_each(&_init_array_base, &_init_array_top, [](auto init_func) {
      (*init_func)();
    });
    main();
    while (1) {}
  }
}
