From: Jonas Rabenstein <ve92mose@stud.informatik.uni-erlangen.de>
Date: Wed, 06 Apr 2016 23:13:01 +0000
Subject: [PATCH 3/3] ia64: remove unused asm/mc146818rtc.h
Message-Id: <ce86a01492882f0772ced22dd6fbda09f5e045f9.1459983613.git.jonas.rabenstein@studium.uni-erlangen.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1459983613.git.jonas.rabenstein@studium.uni-erlangen.de>
In-Reply-To: <cover.1459983613.git.jonas.rabenstein@studium.uni-erlangen.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jonas Rabenstein <jonas.rabenstein@studium.uni-erlangen.de>

From: Jonas Rabenstein <jonas.rabenstein@studium.uni-erlangen.de>

The file arch/ia64/include/asm/mc146818rtc.h is not used anymore. It
would be included by include/linuxmc146818rtc.h which in fact is
included by the following files:
* sound/core/rtctimer.c:
       depends on SND_RTCTIMER -> RTC -> !IA64
* drivers/char/nvram.c:
       depends on NVRAM -> X86
* drivers/char/rtc.c:
       depends on RTC -> !IA64
* drivers/block/floppy.c:
       depends on BLK_DEV_FD -> ARCH_MAY_HAVE_PC_FDC (not defined for IA64)
* drivers/firmware/dcdbas.c:
       depends on DCDBAS -> X86
* include/asm/generic/rtc.h:
  - drivers/rtc/rtc-cmos.c
       depends on RTC_DRV_CMOS -> (X86||ARM||M32R||PPC||MIPS||SPARC64)
  - drivers/acpi/acpi/acpi_cmos_rtc.c:
       depends on X86
  - drivers/rtc/rtc/mrst.c:
       depends on RTC_DRV_VRTC -> X86_INTEL_MID (not defined for IA64)
* drivers/char/mwave/smapi.c
       depends on MWAVE -> X86
* drivers/input/misc/wistron_btns.c:
       depends on CONFIG_WISTRON_BTNS -> X86_32
* drivers/scsi/gdth.c
       depends on SCSI_GDTH -> ISA_DMA_API (not defined for IA64)

Fixes: 7f30491ccd28 ("[IA64] Move include/asm-ia64 to arch/ia64/include/asm")
Signed-off-by: Jonas Rabenstein <jonas.rabenstein@studium.uni-erlangen.de>
---
 arch/ia64/include/asm/mc146818rtc.h | 10 ----------
 1 file changed, 10 deletions(-)
 delete mode 100644 arch/ia64/include/asm/mc146818rtc.h

diff --git a/arch/ia64/include/asm/mc146818rtc.h b/arch/ia64/include/asm/mc146818rtc.h
deleted file mode 100644
index 407787a2..0000000
--- a/arch/ia64/include/asm/mc146818rtc.h
+++ /dev/null
@@ -1,10 +0,0 @@
-#ifndef _ASM_IA64_MC146818RTC_H
-#define _ASM_IA64_MC146818RTC_H
-
-/*
- * Machine dependent access functions for RTC registers.
- */
-
-/* empty include file to satisfy the include in genrtc.c */
-
-#endif /* _ASM_IA64_MC146818RTC_H */
-- 
1.9.1

