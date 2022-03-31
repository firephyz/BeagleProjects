[Defines]
  PLATFORM_NAME             = Beagle
  PLATFORM_VERSION          = 0.1
  FLASH_DEFINITION          = BeaglePlatform/Beagle.fdf
  PLATFORM_GUID             = E28A8401-5E3B-9D0E-8A61-7F8E68FC099B
  SUPPORTED_ARCHITECTURES   = ARM
  BUILD_TARGETS             = DEBUG|RELEASE

  DSC_SPECIFICATION         = 1.28

# [BuildOptions]
#   *_GCC5_ARM_CC_FLAGS = -lgcc

[PcdsFixedAtBuild]
  gBeaglePlatform.FdImageBaseAddr|0x0
  gBeaglePlatform.FdImageSize|0x0

[LibraryClasses]
  # Beagle|BeaglePlatform/Beagle.inf
# !include BootPkg/BootArmPei.dsc.inc

[Components]
  # BeaglePlatform/Beagle.inf
  # BeaglePlatform/BootPkg/Bootloader.inf
