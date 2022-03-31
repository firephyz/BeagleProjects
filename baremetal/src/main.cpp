#include "board.h"

volatile u32 a;

int main() {
  a = BeagleBoard::gpio1.revision.reg.major;

  auto x = BeagleBoard::gpio1.revision.load();
  x.rtl = 0x3;
  BeagleBoard::gpio1.revision.store(x);

  return 0;
}
