#ifndef __MMIO_INCLUDED

#include "general_types.h"

namespace MMIONamespace {

  class MMIORegisterBank;
  extern MMIORegisterBank * builder_bank;

  class MMIORegisterBank {
  public:
    u32 addr_base;

    MMIORegisterBank(u32 addr_base)
      : addr_base(addr_base)
    {
      MMIONamespace::builder_bank = this;
    }
  };

  template<typename base_type, typename bit_map>
  class MMIORegister {
  public:
    bit_map& reg;
    base_type reset_value;

    MMIORegister(u32 address, base_type reset_value)
      : reg(*(bit_map *)address)
      , reset_value(reset_value)
    {}

    bit_map load() { return this->reg; }
    void store(bit_map& value) { reg = value; } 
  };
}

#endif
