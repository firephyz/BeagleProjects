#include "gpio.h"

#include <algorithm>
#include <array>

// GpioBank<25> bank(0x4804C000);
GpioBank bank(0x4804C000);

// template<u32 N>
// constexpr void
// init_reg_store() {
//   std::array<GpioRegister<N>, N> GpioBank<N>::reg_store;
// }

// template<u32 N> GpioBank<N> * GpioBank<N>::active_parent = nullptr;
// template<u32 N> u32 GpioBank<N>::reg_index = 0;
// template<u32 N> std::array<GpioRegister<N>, N> GpioBank<N>::reg_store;

constexpr
GpioBank::GpioBank(u32 offset)
  : offset{offset}
  , revision((GpioRegisterRevision&)regs[0])
  // , sysconfig(regs[1])
{
  // GpioBank::initialize_parent(this);
}

// template<u32 N>
// constexpr GpioBank<N> *
// GpioBank<N>::initialize_parent(GpioBank<N> * parent) {
//   if (GpioBank<N>::active_parent != nullptr) {
//     // Error, constructors in use, need to finish a bank
//     return nullptr;
//   }
//   return parent;
// }

constexpr
GpioRegister::GpioRegister(u32 offset, value_t reset_value, std::array<u32> fields)
  : offset {offset}
  , reset_value {reset_value}
  , fields(fields)
{}

// template<u32 N>
// void
// GpioBank<N>::add_register(u32 offset) {
//   this->reg_store[GpioBank<N>::reg_index] = GpioRegister<N>(this, offset);
//   GpioBank<N>::reg_index += 1;
// }



// GpioRegister&&
// GpioRegister::zeroed() {
//   GpioRegister reg;
// }

// extern void (*_init)();

extern u8 _init_array_base[];
extern u8 _init_array_size[];
extern u8 _stack_top[];

volatile u32 a;
volatile u32 b;

extern "C" {
  __attribute__((naked))
  void _start() {
    asm("mov sp, %0" : : "r" (_stack_top));

    for(int i = 0; i < (u32)_init_array_size / sizeof(void *); ++i) {
      ((void (**)())&_init_array_base)[i]();
    }

    // volatile static struct {
    //   u32 a : 4,
    // 	b : 2,
    // 	:2,
    // 	c : 6;
    // } test;

    // a = test.a;
    // a = test.b;
    // a = test.c;

    // a = bank.offset;
    // a = bank.revision.offset;
    // b = bank.revision.minor;
    // b = bank.revision.rtl;
    // std::for_each(bank.regs.begin(), bank.regs.end(), [](auto& reg) {
    //   b = reg.offset;
    // });
    while (1) {}
  }
}
