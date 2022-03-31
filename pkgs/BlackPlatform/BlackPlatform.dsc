[Defines]
  PLATFORM_NAME                = BeagleBoneBlackPlatform
  PLATFORM_GUID                = E9A834BF-3749-DAB9-946F-C747FAE65FBC
  PLATFORM_VERSION             = 0.1
  SUPPORTED_ARCHITECTURES      = ARM
  BUILD_TARGETS                = RELEASE|DEBUG
  FLASH_DEFINITION             = BlackPlatform/BlackPlatform.fdf

  DSC_SPECIFICATION            = 0x0001001C

[BuildOptions]
  GCC:*_*_*_CC_FLAGS = -mcpu=cortex-a8 -lgcc

[LibraryClasses]
  BaseLib|MdePkg/Library/BaseLib/BaseLib.inf

[Packages]
  BlackPlatform/BlackPlatform.dec

[Components]
  BlackPlatform/Bootloader/Bootloader.inf {
    <LibraryClasses>
      PrePeiUniCore|ArmPlatformPkg/PrePeiCore/PrePeiCoreUniCore.inf
  }
  ArmPlatformPkg/PrePeiCore/PrePeiCoreUniCore.inf {
    <LibraryClasses>
      ArmLib|ArmPkg/Library/ArmLib/ArmBaseLib.inf
      ArmPlatformLib|ArmPlatformPkg/Library/ArmPlatformLibNull/ArmPlatformLibNull.inf
      CacheMaintenanceLib|MdePkg/Library/BaseCacheMaintenanceLibNull/BaseCacheMaintenanceLibNull.inf
      DebugLib|MdePkg/Library/BaseDebugLibNull/BaseDebugLibNull.inf
      DebugAgentLib|MdeModulePkg/Library/DebugAgentLibNull/DebugAgentLibNull.inf
      IoLib|MdePkg/Library/BaseIoLibIntrinsic/BaseIoLibIntrinsic.inf
      PrintLib|MdePkg/Library/BasePrintLib/BasePrintLib.inf
      SerialPortLib|MdePkg/Library/BaseSerialPortLibNull/BaseSerialPortLibNull.inf
      PcdLib|MdePkg/Library/BasePcdLibNull/BasePcdLibNull.inf
      BaseMemoryLib|MdePkg/Library/BaseMemoryLib/BaseMemoryLib.inf
      RegisterFilterLib|MdePkg/Library/RegisterFilterLibNull/RegisterFilterLibNull.inf
  }