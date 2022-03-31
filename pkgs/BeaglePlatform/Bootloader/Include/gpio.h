// enum class GpioOffset : UINT16 {
//   // @reset - 0x50600801
//   Revision           = 0x00,
//   SysConfig          = 0x10,
//   EOI                = 0x20,
//   IrqStatusRaw_0     = 0x24,
//   IrqStatusRaw_1     = 0x28,
//   IrqStatus_0        = 0x30,
//   IrqStatusSet_0     = 0x34,
//   IrqStatusSet_1     = 0x38,
//   IrqStatusClear_0   = 0x3C,
//   IrqStatusClear_1   = 0x40,
//   IrqWaken_0         = 0x44,
//   IrqWaken_1         = 0x48,
//   SysStatus          = 0x114,
//   Control            = 0x130,
//   OE                 = 0x134,
//   DataIn             = 0x138,
//   DataOut            = 0x13C,
//   LevelDetect_0      = 0x140,
//   LevelDetect_1      = 0x144,
//   RisingDetect       = 0x148,
//   FallingDetect      = 0x14C,
//   DebounceEnable     = 0x150,
//   DebouncingTime     = 0x154,
//   ClearDataOut       = 0x190,
//   SetDataOut         = 0x194,
// };

#include <cstdint>
#include <functional>
#include <array>

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
typedef int8_t s8;
typedef int16_t s16;
typedef int32_t s32;
typedef int64_t s64;

// struct _bit_map {};
// typedef void _bit_map;

class GpioBank;

// template<typename value_t, class bit_map>
class GpioRegister {
  static std::reference_wrapper<GpioBank>  bank {std::nullopt};
protected:
  using value_t = u32;
  // using bit_map = _bit_map;
public:
  // GpioBank<N> * parent;
  u32 offset;

  value_t reset_value;
  value_t read_value;
  
  // GpioRegister() = default;
  constexpr GpioRegister(u32 offset, value_t reset_value, std::array<u32> fields);

  void update() {
    this->read_value = *(GpioRegister::

  // GpioRegister<N>&& zeroed();
};

// class GpioRegisterRevision : public GpioRegister {
//   using bit_map = struct {
//     GpioRegister::value_t
//       minor  : 6,
//       custom : 2,
//       major  : 3,
//       rtl    : 5,
//       func   : 12, : 2,
//       scheme : 2;
//   };
// public:
//   // using bitf = GpioRegister : 6;
//   // bitf& minor;
//   // GpioRegister::value_t minor : 6;
//   decltype(bit_map::minor)& minor;
//   decltype(bit_map::custom)& custom;
//   decltype(bit_map::major)& major;
//   decltype(bit_map::rtl)& rtl;
//   decltype(bit_map::func)& func;
//   decltype(bit_map::scheme)& scheme;
  
//   // bit_map const& map;
//   constexpr GpioRegisterRevision()
//     : GpioRegister(0x0000, 0x50600801)
//     , minor(((bit_map&)this->read_value).minor)
//     , custom(((bit_map&)this->read_value).custom)
//     , major(((bit_map&)this->read_value).major)
//     , rtl(((bit_map&)this->read_value).rtl)
//     , func(((bit_map&)this->read_value).func)
//     , scheme(((bit_map&)this->read_value).scheme)
//     // , map((bit_map)this->read_value)
//     // , minor(this->read_value)
//     // , test(this->read_value)
//     // , minor(
//   {}
// };


// template<u32 N> class GpioBank;
// template<u32 N> class GpioRegister;
// class GpioBank;
// class GpioRegister;

class GpioBank {
public:
  u32 offset;

  std::array<GpioRegister, 2> regs {
    GpioRegister(0x0000, 0x50600801, {0, 6, 8, 11, 16, 28, 30}),
    // GpioRegister(0x20, 0x0),
    // GpioRegister {0x0010},
    // GpioRegister {0x0020},
    // GpioRegister {0x0024},
    // GpioRegister {0x0028},
    // GpioRegister {0x002C},
    // GpioRegister {0x0030},
  };

  GpioRegisterRevision& revision;
  // GpioRegister& sysconfig;
  
  constexpr GpioBank(u32 offset);
};

// template<u32 N>
// class GpioBankFull : GpioBank {
//   // static GpioBank * active_parent;
//   // static u32 reg_index;
//   static std::array<GpioRegister<N>, N> reg_store;
// public:
//   constexpr GpioBank(u32 offset);

//   void add_register(u32 offset);
// private:
//   constexpr GpioBank<N> * initialize_parent(GpioBank<N> * parent);
// };
