#ifndef __GPIO_INCLUDED

#include "general_types.h"
#include "mmio.h"

namespace GpioNamespace {

  using base_type = u32;

  template<typename bit_map>
  class GpioRegister : public MMIONamespace::MMIORegister<base_type, bit_map>{
  public:
    GpioRegister(u32 offset, GpioNamespace::base_type reset_value)
      : MMIONamespace::MMIORegister<GpioNamespace::base_type, bit_map>(MMIONamespace::builder_bank->addr_base + offset, reset_value)
    {}
  };

  class GpioRegisterBank : public MMIONamespace::MMIORegisterBank {
    using GpioRevisionBitmap = struct {
      base_type
        minor  :6,
	custom :2,
	major  :3,
	rtl    :5,
	func   :12, :2,
	scheme :2;
    };
    using GpioSysconfigBitmap = struct {
      base_type
        autoidle   :1,
	soft_reset :1,
	en_wakeup  :1,
	idle_mode  :2,
	:27;
    };

    using GpioEndOfInterruptBitMap = struct {
      base_type dma_ack :1, :31;
    };

    using GpioIrqStatRaw0BitMap = struct {
      base_type intline :32;
    };

    using GpioIrqStatRaw1BitMap = struct {
      base_type intline :32;
    };

    using GpioIrqStat0BitMap = struct {
      base_type intline :32;
    };

    using GpioIrqStat1BitMap = struct {
      base_type intline :32;
    };

    using GpioIrqStatSet0BitMap = struct {
      base_type intline :32;
    };

    using GpioIrqStatSet1BitMap = struct {
      base_type intline :32;
    };

    using GpioIrqStatClear0BitMap = struct {
      base_type intline :32;
    };

    using GpioIrqStatClear1BitMap = struct {
      base_type intline :32;
    };

    using GpioIrqWaken0BitMap = struct {
      base_type intline :32;
    };

    using GpioIrqWaken1BitMap = struct {
      base_type intline :32;
    };

    using GpioSysStatusBitMap = struct {
      base_type reset_done :1, :31;
    };

    using GpioControlBitMap = struct {
      base_type
        disable_module :1,
	gating_ratio :2, :29;
    };

    using GpioOutputEnableBitMap = struct {
      base_type output_enable :32;
    };

    using GpioDataInBitMap = struct {
      base_type data_in :32;
    };

    using GpioDataOutBitMap = struct {
      base_type data_out :32;
    };

    using GpioLevelDetect0BitMap = struct {
      base_type level_detect :32;
    };

    using GpioLevelDetect1BitMap = struct {
      base_type level_detect :32;
    };

    using GpioRisingDetectBitMap = struct {
      base_type rising_detect :32;
    };

    using GpioFallingDetectBitMap = struct {
      base_type falling_detect :32;
    };

    using GpioDebounceEnableBitMap = struct {
      base_type debounce_enable :32;
    };

    using GpioDebounceTimeBitMap = struct {
      base_type debounce_time :8, :24;
    };

    using GpioClearDataOutBitMap = struct {
      base_type intline :32;
    };

    using GpioSetDataOutBitMap = struct {
      base_type intline :32;
    };
  
  public:
    GpioRegister<GpioRevisionBitmap>             revision            {0x0000, 0x50600801};
    GpioRegister<GpioSysconfigBitmap>            sysconfig           {0x0010, 0x00000000};
    GpioRegister<GpioEndOfInterruptBitMap>       eoi                 {0x0020, 0x00000000};
    GpioRegister<GpioIrqStatRaw0BitMap>          irq_raw_0           {0x0024, 0x00000000};
    GpioRegister<GpioIrqStatRaw1BitMap>          irq_raw_1           {0x0028, 0x00000000};
    GpioRegister<GpioIrqStat0BitMap>             irq_stat_0          {0x002C, 0x00000000};
    GpioRegister<GpioIrqStat1BitMap>             irq_stat_1          {0x0030, 0x00000000};
    GpioRegister<GpioIrqStatSet0BitMap>          irq_set_0           {0x0034, 0x00000000};
    GpioRegister<GpioIrqStatSet1BitMap>          irq_set_1           {0x0038, 0x00000000};
    GpioRegister<GpioIrqStatClear0BitMap>        irq_clear_0         {0x003C, 0x00000000};
    GpioRegister<GpioIrqStatClear1BitMap>        irq_clear_1         {0x0040, 0x00000000};
    GpioRegister<GpioIrqWaken0BitMap>            irq_waken_0         {0x0044, 0x00000000};
    GpioRegister<GpioIrqWaken1BitMap>            irq_waken_1         {0x0048, 0x00000000};
    GpioRegister<GpioSysStatusBitMap>            sys_status          {0x0114, 0x00000000};
    GpioRegister<GpioControlBitMap>              control             {0x0130, 0x00000000};
    GpioRegister<GpioOutputEnableBitMap>         output_enable       {0x0134, 0xFFFFFFFF};
    GpioRegister<GpioDataInBitMap>               data_in             {0x0138, 0x00000000};
    GpioRegister<GpioDataOutBitMap>              data_out            {0x013C, 0x00000000};
    GpioRegister<GpioLevelDetect0BitMap>         level_detect_0      {0x0140, 0x00000000};
    GpioRegister<GpioLevelDetect1BitMap>         level_detect_1      {0x0144, 0x00000000};
    GpioRegister<GpioRisingDetectBitMap>         rising_detect       {0x0148, 0x00000000};
    GpioRegister<GpioFallingDetectBitMap>        falling_detect      {0x014C, 0x00000000};
    GpioRegister<GpioDebounceEnableBitMap>       debounce_enable     {0x0150, 0x00000000};
    GpioRegister<GpioDebounceTimeBitMap>         debounce_time       {0x0154, 0x00000000};
    GpioRegister<GpioClearDataOutBitMap>         clear_data_out      {0x0190, 0x00000000};
    GpioRegister<GpioSetDataOutBitMap>           set_data_out        {0x0194, 0x00000000};

    GpioRegisterBank(u32 address)
      : MMIORegisterBank(address)
    {}
  };
}

#endif
