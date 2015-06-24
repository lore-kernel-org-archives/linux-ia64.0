From: Lv Zheng <lv.zheng@intel.com>
Date: Wed, 24 Jun 2015 03:02:10 +0000
Subject: [PATCH v2 03/28] ACPICA: Hardware: Enable 64-bit firmware waking vector for selected FACS.
Message-Id: <7ca3239e4066d1a33c523b1ccb475bcbfa6448d3.1435114811.git.lv.zheng@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1434684719.git.lv.zheng@intel.com> <cover.1435114811.git.lv.zheng@intel.com>
In-Reply-To: <cover.1435114811.git.lv.zheng@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Len Brown <len.brown@intel.com>
Cc: Lv Zheng <lv.zheng@intel.com>, Lv Zheng <zetalog@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, Bob Moore <robert.moore@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

ACPICA commit 7aa598d711644ab0de5f70ad88f1e2de253115e4

The following commit is reported to have broken s2ram on some platforms:
 Commit: 0249ed2444d65d65fc3f3f64f398f1ad0b7e54cd
 ACPICA: Add option to favor 32-bit FADT addresses.
The platform reports 2 FACS tables (which is not allowed by ACPI
specification) and the new 32-bit address favor rule forces OSPMs to use
the FACS table reported via FADT's X_FIRMWARE_CTRL field.

The root cause of the reported bug might be one of the followings:
1. BIOS may favor the 64-bit firmware waking vector address when the
   version of the FACS is greater than 0 and Linux currently only supports
   resuming from the real mode, so the 64-bit firmware waking vector has
   never been set and might be invalid to BIOS while the commit enables
   higher version FACS.
2. BIOS may favor the FACS reported via the "FIRMWARE_CTRL" field in the
   FADT while the commit doesn't set the firmware waking vector address of
   the FACS reported by "FIRMWARE_CTRL", it only sets the firware waking
   vector address of the FACS reported by "X_FIRMWARE_CTRL".

This patch excludes the cases that can trigger the bugs caused by the root
cause 1.

ACPI specification says:
A. 32-bit FACS address (FIRMWARE_CTRL field in FADT):
   Physical memory address of the FACS, where OSPM and firmware exchange
   control information.
   If the X_FIRMWARE_CTRL field contains a non zero value then this field
   must be zero.
   A zero value indicates that no FACS is specified by this field.
B. 64-bit FACS address (X_FIRMWARE_CTRL field in FADT):
   64bit physical memory address of the FACS.
   This field is used when the physical address of the FACS is above 4GB.
   If the FIRMWARE_CTRL field contains a non zero value then this field
   must be zero.
   A zero value indicates that no FACS is specified by this field.
Thus the 32bit and 64bit firmware waking vector should indicate completely
different resuming environment - real mode (1MB addressable) and non real
mode (4GB+ addressable) and currently Linux only supports resuming from
real mode.

This patch enables 64-bit firmware waking vector for selected FACS via
acpi_set_firmware_waking_vector() so that it's up to OSPMs to determine which
resuming mode should be used by BIOS and ACPICA changes won't trigger the
bugs caused by the root cause 1. For example, Linux can pass
physical_address64=0 as the parameter of acpi_set_firmware_waking_vector() to
indicate no 64bit waking vector support. Lv Zheng.

This patch also updates acpi_set_firmware_waking_vector() invocations in
order to keep 32-bit firmware waking vector favor for Linux. 64-bit
firmware waking vector has never been enabled by Linux.  The
(acpi_physical_address)0 for 64-bit address can be used to force ACPICA to
set only 32-bit firmware waking vector for Linux.

Link: https://bugzilla.kernel.org/show_bug.cgi?idt021
Link: https://github.com/acpica/acpica/commit/7aa598d7
Cc: 3.14.1+ <stable@vger.kernel.org> # 3.14.1+
Reported-and-tested-by: Oswald Buddenhagen <ossi@kde.org>
Signed-off-by: Lv Zheng <lv.zheng@intel.com>
Signed-off-by: Bob Moore <robert.moore@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/include/asm/acpi.h    |    3 +-
 arch/ia64/kernel/acpi.c         |    2 --
 arch/x86/include/asm/acpi.h     |    3 +-
 drivers/acpi/acpica/hwxfsleep.c |   61 ++++++++++++---------------------------
 drivers/acpi/sleep.c            |    8 +++--
 include/acpi/acpixf.h           |   11 +++----
 6 files changed, 33 insertions(+), 55 deletions(-)

diff --git a/arch/ia64/include/asm/acpi.h b/arch/ia64/include/asm/acpi.h
index aa0fdf1..0ac4fab 100644
--- a/arch/ia64/include/asm/acpi.h
+++ b/arch/ia64/include/asm/acpi.h
@@ -79,7 +79,8 @@ int acpi_gsi_to_irq (u32 gsi, unsigned int *irq);
 /* Low-level suspend routine. */
 extern int acpi_suspend_lowlevel(void);
 
-extern unsigned long acpi_wakeup_address;
+#define acpi_wakeup_address	((acpi_physical_address)0)
+#define acpi_wakeup_address64	((acpi_physical_address)0)
 
 /*
  * Record the cpei override flag and current logical cpu. This is
diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index b1698bc..1b08d6f 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -60,8 +60,6 @@ int acpi_lapic;
 unsigned int acpi_cpei_override;
 unsigned int acpi_cpei_phys_cpuid;
 
-unsigned long acpi_wakeup_address = 0;
-
 #ifdef CONFIG_IA64_GENERIC
 static unsigned long __init acpi_find_rsdp(void)
 {
diff --git a/arch/x86/include/asm/acpi.h b/arch/x86/include/asm/acpi.h
index 3a45668..fc9608d 100644
--- a/arch/x86/include/asm/acpi.h
+++ b/arch/x86/include/asm/acpi.h
@@ -72,7 +72,8 @@ static inline void acpi_disable_pci(void)
 extern int (*acpi_suspend_lowlevel)(void);
 
 /* Physical address to resume after wakeup */
-#define acpi_wakeup_address ((unsigned long)(real_mode_header->wakeup_start))
+#define acpi_wakeup_address	((acpi_physical_address)(real_mode_header->wakeup_start))
+#define acpi_wakeup_address64	((acpi_physical_address)(0))
 
 /*
  * Check if the CPU can handle C2 and deeper
diff --git a/drivers/acpi/acpica/hwxfsleep.c b/drivers/acpi/acpica/hwxfsleep.c
index 82e310b..c67cd32 100644
--- a/drivers/acpi/acpica/hwxfsleep.c
+++ b/drivers/acpi/acpica/hwxfsleep.c
@@ -73,7 +73,6 @@ static struct acpi_sleep_functions acpi_sleep_dispatch[] = {
 /*
  * These functions are removed for the ACPI_REDUCED_HARDWARE case:
  *      acpi_set_firmware_waking_vector
- *      acpi_set_firmware_waking_vector64
  *      acpi_enter_sleep_state_s4bios
  */
 
@@ -83,15 +82,19 @@ static struct acpi_sleep_functions acpi_sleep_dispatch[] = {
  * FUNCTION:    acpi_set_firmware_waking_vector
  *
  * PARAMETERS:  physical_address    - 32-bit physical address of ACPI real mode
- *                                    entry point.
+ *                                    entry point
+ *              physical_address64  - 64-bit physical address of ACPI protected
+ *                                    entry point
  *
  * RETURN:      Status
  *
- * DESCRIPTION: Sets the 32-bit firmware_waking_vector field of the FACS
+ * DESCRIPTION: Sets the firmware_waking_vector fields of the FACS
  *
  ******************************************************************************/
 
-acpi_status acpi_set_firmware_waking_vector(u32 physical_address)
+acpi_status
+acpi_set_firmware_waking_vector(acpi_physical_address physical_address,
+				acpi_physical_address physical_address64)
 {
 	ACPI_FUNCTION_TRACE(acpi_set_firmware_waking_vector);
 
@@ -106,53 +109,27 @@ acpi_status acpi_set_firmware_waking_vector(u32 physical_address)
 
 	/* Set the 32-bit vector */
 
-	acpi_gbl_FACS->firmware_waking_vector = physical_address;
+	acpi_gbl_FACS->firmware_waking_vector = (u32)physical_address;
 
-	/* Clear the 64-bit vector if it exists */
+	if (acpi_gbl_FACS->length > 32) {
+		if (acpi_gbl_FACS->version >= 1) {
 
-	if ((acpi_gbl_FACS->length > 32) && (acpi_gbl_FACS->version >= 1)) {
-		acpi_gbl_FACS->xfirmware_waking_vector = 0;
-	}
-
-	return_ACPI_STATUS(AE_OK);
-}
-
-ACPI_EXPORT_SYMBOL(acpi_set_firmware_waking_vector)
-
-#if ACPI_MACHINE_WIDTH = 64
-/*******************************************************************************
- *
- * FUNCTION:    acpi_set_firmware_waking_vector64
- *
- * PARAMETERS:  physical_address    - 64-bit physical address of ACPI protected
- *                                    mode entry point.
- *
- * RETURN:      Status
- *
- * DESCRIPTION: Sets the 64-bit X_firmware_waking_vector field of the FACS, if
- *              it exists in the table. This function is intended for use with
- *              64-bit host operating systems.
- *
- ******************************************************************************/
-acpi_status acpi_set_firmware_waking_vector64(u64 physical_address)
-{
-	ACPI_FUNCTION_TRACE(acpi_set_firmware_waking_vector64);
+			/* Set the 64-bit vector */
 
-	/* Determine if the 64-bit vector actually exists */
+			acpi_gbl_FACS->xfirmware_waking_vector +			    physical_address64;
+		} else {
+			/* Clear the 64-bit vector if it exists */
 
-	if ((acpi_gbl_FACS->length <= 32) || (acpi_gbl_FACS->version < 1)) {
-		return_ACPI_STATUS(AE_NOT_EXIST);
+			acpi_gbl_FACS->xfirmware_waking_vector = 0;
+		}
 	}
 
-	/* Clear 32-bit vector, set the 64-bit X_ vector */
-
-	acpi_gbl_FACS->firmware_waking_vector = 0;
-	acpi_gbl_FACS->xfirmware_waking_vector = physical_address;
 	return_ACPI_STATUS(AE_OK);
 }
 
-ACPI_EXPORT_SYMBOL(acpi_set_firmware_waking_vector64)
-#endif
+ACPI_EXPORT_SYMBOL(acpi_set_firmware_waking_vector)
+
 /*******************************************************************************
  *
  * FUNCTION:    acpi_enter_sleep_state_s4bios
diff --git a/drivers/acpi/sleep.c b/drivers/acpi/sleep.c
index 2f0d4db..3a6a2eb 100644
--- a/drivers/acpi/sleep.c
+++ b/drivers/acpi/sleep.c
@@ -25,6 +25,8 @@
 #include "internal.h"
 #include "sleep.h"
 
+#define ACPI_NO_WAKING_VECTOR		((acpi_physical_address)0)
+
 static u8 sleep_states[ACPI_S_STATE_COUNT];
 
 static void acpi_sleep_tts_switch(u32 acpi_state)
@@ -61,7 +63,8 @@ static int acpi_sleep_prepare(u32 acpi_state)
 	if (acpi_state = ACPI_STATE_S3) {
 		if (!acpi_wakeup_address)
 			return -EFAULT;
-		acpi_set_firmware_waking_vector(acpi_wakeup_address);
+		acpi_set_firmware_waking_vector(acpi_wakeup_address,
+						acpi_wakeup_address64);
 
 	}
 	ACPI_FLUSH_CPU_CACHE();
@@ -410,7 +413,8 @@ static void acpi_pm_finish(void)
 	acpi_leave_sleep_state(acpi_state);
 
 	/* reset firmware waking vector */
-	acpi_set_firmware_waking_vector((acpi_physical_address) 0);
+	acpi_set_firmware_waking_vector(ACPI_NO_WAKING_VECTOR,
+					ACPI_NO_WAKING_VECTOR);
 
 	acpi_target_sleep_state = ACPI_STATE_S0;
 
diff --git a/include/acpi/acpixf.h b/include/acpi/acpixf.h
index d68f1cd..a68e4b9 100644
--- a/include/acpi/acpixf.h
+++ b/include/acpi/acpixf.h
@@ -814,13 +814,10 @@ ACPI_EXTERNAL_RETURN_STATUS(acpi_status
 ACPI_EXTERNAL_RETURN_STATUS(acpi_status acpi_leave_sleep_state(u8 sleep_state))
 
 ACPI_HW_DEPENDENT_RETURN_STATUS(acpi_status
-				acpi_set_firmware_waking_vector(u32
-								physical_address))
-#if ACPI_MACHINE_WIDTH = 64
-ACPI_HW_DEPENDENT_RETURN_STATUS(acpi_status
-				acpi_set_firmware_waking_vector64(u64
-								  physical_address))
-#endif
+				acpi_set_firmware_waking_vector
+				(acpi_physical_address physical_address,
+				 acpi_physical_address physical_address64))
+
 /*
  * ACPI Timer interfaces
  */
-- 
1.7.10

