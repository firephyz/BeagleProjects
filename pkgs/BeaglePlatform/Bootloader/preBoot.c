  /* IN CONST EFI_SEC_PEI_HAND_OFF        *SecCoreDataPtr, */
  /* IN CONST EFI_PEI_PPI_DESCRIPTOR      *PpiList, */
  /* IN VOID */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "support.h"

/* #include <Library/BaseLib.h> */
/* #include <PiPei.h> */
/* #include <Pi/PiFirmwareVolume.h> */
/* #include <PeiMain.h> */

volatile void ** buf;
/* int bootloader() { */
/*   const int MAX_NUM_FVS = 8; */
/*   void *fv_list[MAX_NUM_FVS]; */
/*   int num_fv = 0; */

/*   /\* uint32_t signature = (uint32_t)"_FVH"; *\/ */
/*   uint8_t signature[4] = "_FVH"; */
/*   void * base_addr = (void *)0x100000; */
/*   size_t scan_area_size = 0x31100; */
/*   for(void * p = base_addr; p < (base_addr + scan_area_size); ++p) { */
/*     if (!strncmp((char *)signature, p, 4)) { */
/*       fv_list[num_fv] = p; */
/*       ++num_fv; */
/*     } */

/*     if (num_fv == MAX_NUM_FVS) break; */
/*   } */

/*   for(int i = 0; i < num_fv; ++i) { */
/*     *buf = fv_list[i]; */
/*   } */

/*   return EFI_SUCCESS; */
/* } */

/* void * locate_sec_module() { */
/*   const GUID bootloaderModuleGuid = gEfiCallerIdGuid; */

/*   for(GUID * test_guid = (GUID *)0x100000; test_guid < (GUID *)0x101000; ++test_guid) { */
/*     if (memcmp(test_guid, &bootloaderModuleGuid, sizeof(GUID))) { */
/*       return (void *)test_guid; */
/*     } */
/*   } */
  
/*   return 0; */
/* } */

void * SEC_STACK_BASE = NULL;
size_t SEC_RAM_RESERVED_SIZE = 0;

void pei_handover() {
  EFI_SEC_PEI_HAND_OFF sec_pei_data = {
    .DataSize = 0,
    // First byte of PEI FV
    .BootFirmwareVolumeBase = (void *)(size_t)FixedPcdGet64(cFvPeiBaseAddress),
    .BootFirmwareVolumeSize = FixedPcdGet64(cFvPeiSize),
    // First byte of temporary ram
    .TemporaryRamBase = (void *)(size_t)FixedPcdGet64(cTempRamBase),
    .TemporaryRamSize = FixedPcdGet64(cTempRamSize),
    // Temporary RAM area for PEI
    .PeiTemporaryRamBase = (void *)(size_t)(FixedPcdGet64(cTempRamBase) + SEC_RAM_RESERVED_SIZE),
    .PeiTemporaryRamSize = FixedPcdGet64(cTempRamSize) - FixedPcdGet64(cTempStackSize) - SEC_RAM_RESERVED_SIZE,
    // Start of the stack and size
    .StackBase = SEC_STACK_BASE,
    .StackSize = FixedPcdGet64(cTempStackSize)
  };
  /* EFI_PEI_PPI_DESCRIPTOR ppi_list = { */
  /*   .Flags = EFI_PEI_PPI_DESCRIPTOR_TERMINATE_LIST, */
  /*   .Guid = NULL, */
  /*   .Ppi = NULL */
  /* }; */

  /* EFI_PEI_CORE_ENTRY_POINT  test = 1; */

  uint32_t * pei_reset_vector = (uint32_t *)FixedPcdGet64(cFvPeiBaseAddress);
  EFI_PEI_CORE_ENTRY_POINT * pei_core = (EFI_PEI_CORE_ENTRY_POINT *)(pei_reset_vector + 1);
  
  (*pei_core)(&sec_pei_data, NULL);
}

#include <Library/SerialPortLib.h>
#include <Library/ArmLib.h>

/* VOID */
/* EFIAPI */
/* ProcessLibraryConstructorList ( */
/*   VOID */
/* 			       ); */

UINT8 hi[] = "Hello world!\n";
const char clear_screen_sequence[] = "\033[2J\033[H";
char read_buf[256];

__attribute__((naked, noreturn))
void _ModuleEntryPoint() {
  SEC_STACK_BASE = (void *)(size_t)(FixedPcdGet64(cTempRamBase) + FixedPcdGet64(cTempRamSize));
  SEC_RAM_RESERVED_SIZE = (size_t)(FixedPcdGet64(cTempRamSize) / 2);
  asm("mov sp, %0" : : "r" (SEC_STACK_BASE));

  /* static UINT32 cpsr = CPSRRead(); */
  /* UINT32 arm_read_privilege_level(); */
  /* static UINT32 cpsr; */
  /* cpsr = arm_read_privilege_level(); */
  /* /\* asm("mov %0, cpsr" : "=r" (cpsr)); *\/ */
  /* static char cpsr_hex[3]; */
  /* cpsr_hex[0] = ((cpsr >> 0) & 0xF) + '0'; */
  /* cpsr_hex[1] = ((cpsr >> 4) & 0xF) + '0'; */
  /* cpsr_hex[2] = '\0'; */
  /* SerialPortWrite((UINT8 *)cpsr_hex, sizeof(cpsr_hex)); */

  /* UINT32 * vector = (UINT32 *)0xC; */
  /* extern void * test; */
  /* vector[0] = *((UINT32 *)test); */

  /* UINT32 pl_mask = 0x0000001F; */
  /* UINT32 pl_target = 0x1F; */
  /* asm("mrs %0, cpsr\n" */
  /*     "bic %0, %1\n" */
  /*     "orr %0, %2\n" */
  /*     "msr cpsr, %0\n" */
  /*     "isb\n" */
  /*     : "=r" (cpsr) */
  /*     : "r" (pl_mask), "r" (pl_target)); */
  /* void arm_set_privilege_level(UINT32); */
  /* arm_set_privilege_level(pl_target); */
  /* CPSRMaskInsert(0x0000_001F, 0x1F); */

  /* UINT8 * test = (UINT8 *)0x3F201000; */
  /* for(int i = 0; i < 0x30; ++i) { */
  /*   *test = 0xa5; */
  /* } */
  /* ProcessLibraryConstructorList(); */
  /* SerialPortWrite(hi, sizeof(hi)); */
  SerialPortWrite((UINT8 *)clear_screen_sequence, sizeof(clear_screen_sequence));

  /* while (1) { */
  /*   size_t read_cnt = 0; */
  /*   SerialPortWrite(hi, sizeof(hi)); */
  /*   for(int i = 0; i < 5000000; ++i) { */
  /*     if (SerialPortPoll()) { */
  /* 	static UINT8 has_data_str[] = "Has data!\n"; */
  /* 	SerialPortWrite(has_data_str, sizeof(has_data_str)); */
  /* 	static char mychar; */
  /* 	SerialPortRead((UINT8 *)&mychar, 1); */
  /* 	read_buf[read_cnt++] = mychar; */
  /*     } */
  /*   } */
  /*   SerialPortWrite((UINT8 *)&read_buf, read_cnt); */
  /*   for(int i = 0; i < 500000000; ++i) { */
  /*     asm("nop"); */
  /*   } */
  /* } */

  static ARM_REG_MIDR_SUMMARY midr;
  midr = ArmRegMidrSummary();
  asm("mov %0, %0" :: "r" (*(UINT8 *)&midr));

  /* bootloader(); */
  pei_handover();

  CpuDeadLoop();
}

