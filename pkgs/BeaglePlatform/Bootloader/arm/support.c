#include "support.h"

#include <Library/ArmLib.h>

const UINT16 ARM_REG_MIDR_PRIM_ALT_ENC_MASK = 0xF00;
const UINT16 ARM_REG_MIDR_METADATA_ALT_ENC = 0x01;

ARM_REG_MIDR_SUMMARY ArmRegMidrSummary() {
  UINT32 midr = ArmReadMidr();
  ARM_REG_MIDR_SUMMARY summary = {
    .ARM_REG_MIDR_IMP = ((midr >> 24) & 0x0),
    .ARM_REG_MIDR_VAR = ((midr >> 20) & 0xF),
    .ARM_REG_MIDR_ARCH = ((midr >> 16) & 0xF),
    .ARM_REG_MIDR_PRIM = ((midr >> 4) & 0xFFF),
    .ARM_REG_MIDR_REV = ((midr >> 0) & 0xF),
    .metadata = 0x0,
  };

  // Check for ARMv4 and ARMv5 querks in the ARM_REG_MIDR_PRIM field.
  if (summary.ARM_REG_MIDR_PRIM & ARM_REG_MIDR_PRIM_ALT_ENC_MASK) {
    summary.metadata |= ARM_REG_MIDR_METADATA_ALT_ENC;
  }

  return summary;
}
