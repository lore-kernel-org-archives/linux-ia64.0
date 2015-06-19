From: Lv Zheng <lv.zheng@intel.com>
Date: Fri, 19 Jun 2015 03:38:34 +0000
Subject: [PATCH 04/32] ACPI: sleep: Update acpi_set_firmware_waking_vector() invocations to favor 32-bit firm
Message-Id: <2f708d4ee4100bd1b64ca1ea00b678d5f5b2135a.1434684719.git.lv.zheng@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1434684719.git.lv.zheng@intel.com>
In-Reply-To: <cover.1434684719.git.lv.zheng@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Len Brown <len.brown@intel.com>
Cc: Lv Zheng <lv.zheng@intel.com>, Lv Zheng <zetalog@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

This patch updates acpi_set_firmware_waking_vector() invocations in order
to keep 32-bit firmware waking vector favor for Linux.

64-bit firmware waking vector has never been enabled by Linux.  The
(acpi_physical_address)0 for 64-bit address can be used to force ACPICA to
set only 32-bit firmware waking vector for Linux.

Reference: https://bugzilla.kernel.org/show_bug.cgi?idt021
Reported-and-tested-by: Oswald Buddenhagen <ossi@kde.org>
Signed-off-by: Lv Zheng <lv.zheng@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/include/asm/acpi.h |    3 ++-
 arch/ia64/kernel/acpi.c      |    2 --
 arch/x86/include/asm/acpi.h  |    3 ++-
 drivers/acpi/sleep.c         |    8 ++++++--
 4 files changed, 10 insertions(+), 6 deletions(-)

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
 
-- 
1.7.10

