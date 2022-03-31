add-symbol-file /home/kyle/o/beagle/baremetal/build/test.elf

target remote :1234

define run-edk
  add-symbol-file /home/kyle/o/beagle/edk2/Build/BeagleBone/DEBUG_GCC5/ARM/BeaglePlatform/Bootloader/Bootloader/DEBUG/Bootloader.debug -o 0x100064
  add-symbol-file /home/kyle/o/beagle/edk2/Build/BeagleBone/DEBUG_GCC5/ARM/PeiCore.debug -o 0x000010408C
  add-symbol-file /home/kyle/o/beagle/edk2/Build/BeagleBone/DEBUG_GCC5/ARM/MemoryInit.debug -o 0x0000117CA0
  break _ModuleEntryPoint
  break PeiCoreEntryPoint.c:58
  break PeiMain.c:372
  
  break ArmPlatformPkg/MemoryInitPei/MemoryInitPeiLib.c:75
  break ArmPlatformPkg/MemoryInitPei/MemoryInitPeiLib.c:142
  
  target remote :1234
  continue
end

define trc
  target remote :1234
end
