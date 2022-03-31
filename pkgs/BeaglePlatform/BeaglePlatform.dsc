[Defines]
  PLATFORM_NAME                = BeagleBone
  PLATFORM_GUID                = E9A834BF-3749-DAB9-946F-C747FAE65FBC
  PLATFORM_VERSION             = 0.1
  SUPPORTED_ARCHITECTURES      = ARM
  BUILD_TARGETS                = RELEASE|DEBUG
  FLASH_DEFINITION             = BeaglePlatform/BeaglePlatform.fdf
  DSC_SPECIFICATION            = 0x0001001C

  DEFINE MMC_IMAGE_BASE      = 0x000000
  DEFINE MMC_IMAGE_SIZE      = 0x100000
  DEFINE SYS_MEM_BASE        = 0x00000000
  DEFINE SYS_MEM_SIZE        = 0x3F000000
  DEFINE MMC_TEMP_STACK_BASE = $(MMC_IMAGE_BASE)
  DEFINE MMC_TEMP_STACK_SIZE = 0x10000

[BuildOptions]
  GCC:*_*_*_CC_FLAGS = -mcpu=cortex-a8 -mfloat-abi=soft
  GCC:*_*_*_ASM_FLAGS = -mcpu=cortex-a8 -mthumb
  #  -lgcc -lc

[LibraryClasses.common]
  RegisterFilterLib|MdePkg/Library/RegisterFilterLibNull/RegisterFilterLibNull.inf

[LibraryClasses]
  # Patch BaseLib to require these intrinsics this to replace libgcc
  CompilerIntrinsicsLib|ArmPkg/Library/CompilerIntrinsicsLib/CompilerIntrinsicsLib.inf
  BaseLib|MdePkg/Library/BaseLib/BaseLib.inf

  CacheMaintenanceLib|ArmPkg/Library/ArmCacheMaintenanceLib/ArmCacheMaintenanceLib.inf
    # MdePkg/Library/BaseCacheMaintenanceLibNull/BaseCacheMaintenanceLibNull.inf
    # MdePkg/Library/BaseCacheMaintenanceLib/BaseCacheMaintenanceLib.inf
      # Seems to mostly default assert(FALSE)
    # ArmPkg/Library/ArmCacheMaintenanceLib/ArmCacheMaintenanceLib.inf
  BaseMemoryLib|MdePkg/Library/BaseMemoryLib/BaseMemoryLib.inf
  CpuExceptionHandlerLib|MdeModulePkg/Library/CpuExceptionHandlerLibNull/CpuExceptionHandlerLibNull.inf
  # CpuExceptionHandlerLib
    # MdeModulePkg/Library/CpuExceptionHandlerLibNull/CpuExceptionHandlerLibNull.inf
    # UefiCpuPkg/Library/CpuExceptionHandlerLib/PeiCpuExceptionHandlerLib.inf
    # UefiCpuPkg/Library/CpuExceptionHandlerLib/DxeCpuExceptionHandlerLib.inf
    # ArmPkg/Library/ArmExceptionLib/ArmExceptionLib.inf

  PcdLib|MdePkg/Library/BasePcdLibNull/BasePcdLibNull.inf
    # MdePkg/Library/BasePcdLibNull/BasePcdLibNull.inf
    # MdePkg/Library/PeiPcdLib/PeiPcdLib.inf
    # MdePkg/Library/DxePcdLib/DxePcdLib.inf
  HobLib|MdePkg/Library/PeiHobLib/PeiHobLib.inf
    # MdeModulePkg/Library/BaseHobLibNull/BaseHobLibNull.inf
    # MdePkg/Library/PeiHobLib/PeiHobLib.inf
    # MdePkg/Library/DxeCoreHobLib/DxeCoreHobLib.inf
    # MdePkg/Library/DxeHobLib/DxeHobLib.inf
    # UefiPayloadPkg/Library/DxeHobLib/DxeHobLib.inf
    # UefiPayloadPkg/Library/PayloadEntryHobLib/HobLib.inf
    # EmbeddedPkg/Library/PrePiHobLib/PrePiHobLib.inf

  UefiDecompressLib|MdePkg/Library/BaseUefiDecompressLib/BaseUefiDecompressLib.inf
  PeCoffLib|MdePkg/Library/BasePeCoffLib/BasePeCoffLib.inf
  MemoryAllocationLib|MdePkg/Library/PeiMemoryAllocationLib/PeiMemoryAllocationLib.inf
    # MdeModulePkg/Library/BaseMemoryAllocationLibNull/BaseMemoryAllocationLibNull.inf
    # MdePkg/Library/PeiMemoryAllocationLib/PeiMemoryAllocationLib.inf
    # MdeModulePkg/Library/DxeCoreMemoryAllocationLib/DxeCoreMemoryAllocationLib.inf
    # MdePkg/Library/UefiMemoryAllocationLib/UefiMemoryAllocationLib.inf
  DevicePathLib|MdePkg/Library/UefiDevicePathLib/UefiDevicePathLib.inf
  ReportStatusCodeLib|MdePkg/Library/BaseReportStatusCodeLibNull/BaseReportStatusCodeLibNull.inf
    # MdePkg/Library/BaseReportStatusCodeLibNull/BaseReportStatusCodeLibNull.inf
    # MdeModulePkg/Library/PeiReportStatusCodeLib/PeiReportStatusCodeLib.inf
    # MdeModulePkg/Library/DxeReportStatusCodeLib/DxeReportStatusCodeLib.inf

  DebugLib|MdePkg/Library/BaseDebugLibSerialPort/BaseDebugLibSerialPort.inf
  # DebugLib|MdePkg/Library/BaseDebugLibNull/BaseDebugLibNull.inf
    # MdeModulePkg/Library/PeiDebugLibDebugPpi/PeiDebugLibDebugPpi.inf
    #   PEIM instance of DebugLib
    # MdePkg/Library/BaseDebugLibNull/BaseDebugLibNull.inf
    # MdePkg/Library/BaseDebugLibSerialPort/BaseDebugLibSerialPort.inf
    # MdePkg/Library/DxeRuntimeDebugLibSerialPort/DxeRuntimeDebugLibSerialPort.inf
  DebugAgentLib|MdeModulePkg/Library/DebugAgentLibNull/DebugAgentLibNull.inf
  PrintLib|MdePkg/Library/BasePrintLib/BasePrintLib.inf

  PerformanceLib|MdePkg/Library/BasePerformanceLibNull/BasePerformanceLibNull.inf
  UefiLib|MdePkg/Library/UefiLib/UefiLib.inf
  UefiBootServicesTableLib|MdePkg/Library/UefiBootServicesTableLib/UefiBootServicesTableLib.inf
  DxeServicesLib|MdePkg/Library/DxeServicesLib/DxeServicesLib.inf
  # UefiRuntimeServicesTableLib|MdePkg/Library/UefiRuntimeServicesTableLib/UefiRuntimeServicesTableLib.inf

  DxeCoreEntryPoint|MdePkg/Library/DxeCoreEntryPoint/DxeCoreEntryPoint.inf
  PeCoffGetEntryPointLib|MdePkg/Library/BasePeCoffGetEntryPointLib/BasePeCoffGetEntryPointLib.inf
  PeCoffExtraActionLib|MdePkg/Library/BasePeCoffExtraActionLibNull/BasePeCoffExtraActionLibNull.inf
  ExtractGuidedSectionLib|MdePkg/Library/BaseExtractGuidedSectionLib/BaseExtractGuidedSectionLib.inf

  PeiServicesLib|MdePkg/Library/PeiServicesLib/PeiServicesLib.inf
  PeiCoreEntryPoint|MdePkg/Library/PeiCoreEntryPoint/PeiCoreEntryPoint.inf
  PeiServicesTablePointerLib|MdePkg/Library/PeiServicesTablePointerLib/PeiServicesTablePointerLib.inf
    # MdePkg/Library/PeiServicesTablePointerLib/PeiServicesTablePointerLib.inf
    # ArmPkg/Library/PeiServicesTablePointerLib/PeiServicesTablePointerLib.inf

  # SerialPortLib|MdeModulePkg/Library/BaseSerialPortLib16550/BaseSerialPortLib16550.inf
  SerialPortLib|ArmPlatformPkg/Library/PL011SerialPortLib/PL011SerialPortLib.inf
    # MdePkg/Library/BaseSerialPortLibNull/BaseSerialPortLibNull.inf
    # MdeModulePkg/Library/BaseSerialPortLib16550/BaseSerialPortLib16550.inf
    # ArmPlatformPkg/Library/PL011SerialPortLib/PL011SerialPortLib.inf

  DebugPrintErrorLevelLib|MdePkg/Library/BaseDebugPrintErrorLevelLib/BaseDebugPrintErrorLevelLib.inf
    # MdePkg/Library/BaseDebugPrintErrorLevelLib/BaseDebugPrintErrorLevelLib.inf
    # MdeModulePkg/Library/DxeDebugPrintErrorLevelLib/DxeDebugPrintErrorLevelLib.inf

  IoLib|MdePkg/Library/BaseIoLibIntrinsic/BaseIoLibIntrinsic.inf
    # MdePkg/Library/BaseIoLibIntrinsic/BaseIoLibIntrinsic.inf
    # MdePkg/Library/PeiIoLibCpuIo/PeiIoLibCpuIo.inf
    # MdePkg/Library/DxeIoLibCpuIo2/DxeIoLibCpuIo2.inf
    # MdePkg/Library/BaseS3IoLib/BaseS3IoLib.inf

  PlatformHookLib|MdeModulePkg/Library/BasePlatformHookLibNull/BasePlatformHookLibNull.inf
    # MdeModulePkg/Library/BasePlatformHookLibNull/BasePlatformHookLibNull.inf
    # MdeModulePkg/Library/PlatformHookLibSerialPortPpi/PlatformHookLibSerialPortPpi.inf
    # #  for use with the PEIM version of SerialPortLib, that provides its Ppi
    # UefiPayloadPkg/Library/PlatformHookLib/PlatformHookLib.inf

  # PciLib|MdePkg/Library/PeiPciLibPciCfg2/PeiPciLibPciCfg2.inf
  PciLib|MdePkg/Library/BasePciLibPciExpress/BasePciLibPciExpress.inf
    # MdePkg/Library/UefiPciLibPciRootBridgeIo/UefiPciLibPciRootBridgeIo.inf
    #   # binds to a pci root bridge IO protocol
    # MdePkg/Library/BasePciLibPciExpress/BasePciLibPciExpress.inf
    #   # rides off of the PCIe driver
    # MdePkg/Library/PeiPciLibPciCfg2/PeiPciLibPciCfg2.inf
    #   # uses a single segment pci configuration ppi to access PCI
    # MdePkg/Library/BasePciLibCf8/BasePciLibCf8.inf
    #   # uses the x86 IO space to read/write PCI address space

  PciExpressLib|MdePkg/Library/BasePciExpressLib/BasePciExpressLib.inf
    # MdePkg/Library/BasePciExpressLib/BasePciExpressLib.inf
    # MdePkg/Library/DxeRuntimePciExpressLib/DxeRuntimePciExpressLib.inf

  PeimEntryPoint|MdePkg/Library/PeimEntryPoint/PeimEntryPoint.inf

  UefiRuntimeServicesTableLib|MdePkg/Library/UefiRuntimeServicesTableLib/UefiRuntimeServicesTableLib.inf

[LibraryClasses]
  PL011UartClockLib|ArmPlatformPkg/Library/PL011UartClockLib/PL011UartClockLib.inf
  PL011UartLib|ArmPlatformPkg/Library/PL011UartLib/PL011UartLib.inf

[LibraryClasses.ARM]
  MemoryInitPeiLib|ArmPlatformPkg/MemoryInitPei/MemoryInitPeiLib.inf
  ArmMmuLib|ArmPkg/Library/ArmMmuLib/ArmMmuBaseLib.inf
  ArmPlatformLib|ArmPlatformPkg/Library/ArmPlatformLibNull/ArmPlatformLibNull.inf
  ArmLib|ArmPkg/Library/ArmLib/ArmBaseLib.inf

[Packages]
  BeaglePlatform/BeaglePlatform.dec

[Components]
  BeaglePlatform/Bootloader/Bootloader.inf {
    <LibraryClasses>
      MemoryAllocationLib|MdeModulePkg/Library/BaseMemoryAllocationLibNull/BaseMemoryAllocationLibNull.inf
  }
  MdeModulePkg/Core/Pei/PeiMain.inf
  # ArmPlatformPkg/MemoryInitPei/MemoryInitPeim.inf
  # MdeModulePkg/Core/Dxe/DxeMain.inf
  MdeModulePkg/Core/Dxe/DxeMain.inf {
    <LibraryClasses>
      HobLib|MdePkg/Library/DxeCoreHobLib/DxeCoreHobLib.inf
      MemoryAllocationLib|MdeModulePkg/Library/DxeCoreMemoryAllocationLib/DxeCoreMemoryAllocationLib.inf
  }

[PcdsFeatureFlag]
  # Pei Core
  # MdeModulePkg
  gEfiMdeModulePkgTokenSpaceGuid.PcdPeiCoreImageLoaderSearchTeSectionFirst|True

[PcdsFixedAtBuild]
  # Platform
  gBeaglePlatformTSG.cTempRamBase|$(MMC_IMAGE_BASE)
  gBeaglePlatformTSG.cTempRamSize|0x00100000
  gBeaglePlatformTSG.cRamBase|$(SYS_MEM_BASE)
  gBeaglePlatformTSG.cRamSize|$(SYS_MEM_SIZE)
  gBeaglePlatformTSG.cTempStackSize|0x4000

  # DebugLib
  # gEfiMdePkgTokenSpaceGuid.PcdDebugClearMemoryValue
  gEfiMdePkgTokenSpaceGuid.PcdDebugPropertyMask|0x3f
  #   configures the use of certain runtime config options
  # gEfiMdePkgTokenSpaceGuid.PcdFixedDebugPrintErrorLevel
  #   default has all enabled, many options

  # Pei Core
    # MdeModulePkg
    gEfiMdeModulePkgTokenSpaceGuid.PcdPeiCoreMaxPeiStackSize|0x10000
    gEfiMdeModulePkgTokenSpaceGuid.PcdInitValueInTempStack|0x11001100              
    # gEfiMdeModulePkgTokenSpaceGuid.PcdLoadModuleAtFixAddressEnable|True
    # gEfiMdeModulePkgTokenSpaceGuid.PcdLoadFixAddressPeiCodePageNumber         ## SOMETIMES_CONSUMES
    # gEfiMdeModulePkgTokenSpaceGuid.PcdLoadFixAddressBootTimeCodePageNumber    ## SOMETIMES_CONSUMES
    # gEfiMdeModulePkgTokenSpaceGuid.PcdLoadFixAddressRuntimeCodePageNumber     ## SOMETIMES_CONSUMES
    # gEfiMdeModulePkgTokenSpaceGuid.PcdShadowPeimOnBoot
    # gEfiMdeModulePkgTokenSpaceGuid.PcdShadowPeimOnS3Boot
    # gEfiMdeModulePkgTokenSpaceGuid.PcdMigrateTemporaryRamFirmwareVolumes
    #   Migrates all items to permanent RAM I think (check not just FVs...)

  # SerialPrintLib
    gEfiMdeModulePkgTokenSpaceGuid.PcdSerialRegisterAccessWidth|32
    gEfiMdeModulePkgTokenSpaceGuid.PcdSerialUseMmio|True
    # gEfiMdeModulePkgTokenSpaceGuid.PcdSerialUseHardwareFlowControl
      # Support not pinned out on Beagle Bone Black
    # gEfiMdeModulePkgTokenSpaceGuid.PcdSerialDetectCable
    gEfiMdeModulePkgTokenSpaceGuid.PcdSerialRegisterBase|0x3F201000
      # 0x3F201000 QEMU serial0
      # 0x44E09000 BBB UART0
    # gEfiMdeModulePkgTokenSpaceGuid.PcdSerialBaudRate
    #   BBB ROM defaults to 115200
    # gEfiMdeModulePkgTokenSpaceGuid.PcdSerialLineControl
    #   default = 0x3: no parity, 0 stop bits, 8 data bits
    # gEfiMdeModulePkgTokenSpaceGuid.PcdSerialFifoControl
    gEfiMdeModulePkgTokenSpaceGuid.PcdSerialClockRate|48000000
    # gEfiMdeModulePkgTokenSpaceGuid.PcdSerialPciDeviceInfo
    #   device defaults to 0xff to signal PCI info is empty and doesn't apply
    # gEfiMdeModulePkgTokenSpaceGuid.PcdSerialExtendedTxFifoSize
    gEfiMdeModulePkgTokenSpaceGuid.PcdSerialRegisterStride|4
    #  BBB has 32bit access mode

  # DebugPrinErrorLevelLib
    gEfiMdePkgTokenSpaceGuid.PcdDebugPrintErrorLevel|0xFFFFFFFF

  # PciExpressLib
    gEfiMdePkgTokenSpaceGuid.PcdPciExpressBaseAddress|0x0
    gEfiMdePkgTokenSpaceGuid.PcdPciExpressBaseSize|0x0

    # gEfiMdePkgTokenSpaceGuid.PcdUartDefaultBaudRate
    # gEfiMdePkgTokenSpaceGuid.PcdUartDefaultDataBits
    # gEfiMdePkgTokenSpaceGuid.PcdUartDefaultParity
    # gEfiMdePkgTokenSpaceGuid.PcdUartDefaultStopBits
    # gEfiMdePkgTokenSpaceGuid.PcdUartDefaultReceiveFifoDepth|64
    gArmPlatformTokenSpaceGuid.PL011UartClkInHz|48000000
    # gArmPlatformTokenSpaceGuid.PL011UartInteger|0
    # gArmPlatformTokenSpaceGuid.PL011UartFractional
    # gArmPlatformTokenSpaceGuid.PL011UartRegOffsetVariant


# MemoryInitLib
[PcdsFeatureFlag]
  gEmbeddedTokenSpaceGuid.PcdPrePiProduceMemoryTypeInformationHob|True

[PcdsFixedAtBuild]
  gArmTokenSpaceGuid.PcdSystemMemoryBase|$(SYS_MEM_BASE)
  gArmTokenSpaceGuid.PcdSystemMemorySize|$(SYS_MEM_SIZE)

  gArmPlatformTokenSpaceGuid.PcdSystemMemoryUefiRegionSize|0x00400000

  # For ARM mmu
  # gArmTokenSpaceGuid.PcdNormalMemoryNonshareableOverride