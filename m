From: Alex Chiang <achiang@hp.com>
Date: Sun, 20 Dec 2009 19:19:29 +0000
Subject: [PATCH 05/11] ACPI: processor: finish unifying
Message-Id: <20091220191929.4274.88803.stgit@bob.kio>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091220190434.4274.67855.stgit@bob.kio>
In-Reply-To: <20091220190434.4274.67855.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: venkatesh.pallipadi@intel.com, lenb@kernel.org
Cc: Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

The only thing arch-specific about calling _PDC is what bits get
set in the input obj_list buffer.

There's no need for several levels of indirection to twiddle those
bits. Additionally, since we're just messing around with a buffer,
we can simplify the interface; no need to pass around the entire
struct acpi_processor * just to get at the buffer.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Signed-off-by: Alex Chiang <achiang@hp.com>
---

 arch/ia64/include/asm/acpi.h      |    4 ++++
 arch/ia64/kernel/acpi-processor.c |   18 ------------------
 arch/x86/include/asm/acpi.h       |   19 +++++++++++++++++++
 arch/x86/kernel/acpi/processor.c  |   34 ----------------------------------
 drivers/acpi/processor_pdc.c      |    6 +++---
 include/acpi/processor.h          |    1 -
 6 files changed, 26 insertions(+), 56 deletions(-)

diff --git a/arch/ia64/include/asm/acpi.h b/arch/ia64/include/asm/acpi.h
index 3b78882..7ae5889 100644
--- a/arch/ia64/include/asm/acpi.h
+++ b/arch/ia64/include/asm/acpi.h
@@ -133,6 +133,10 @@ extern int __initdata nid_to_pxm_map[MAX_NUMNODES];
 #endif
 
 static inline bool arch_has_acpi_pdc(void) { return true; }
+static inline void arch_acpi_set_pdc_bits(u32 *buf)
+{
+	buf[2] |= ACPI_PDC_EST_CAPABILITY_SMP;
+}
 
 #define acpi_unlazy_tlb(x)
 
diff --git a/arch/ia64/kernel/acpi-processor.c b/arch/ia64/kernel/acpi-processor.c
index ebe23f5..7ba5acc 100644
--- a/arch/ia64/kernel/acpi-processor.c
+++ b/arch/ia64/kernel/acpi-processor.c
@@ -14,24 +14,6 @@
 #include <acpi/processor.h>
 #include <asm/acpi.h>
 
-static void init_intel_pdc(struct acpi_processor *pr)
-{
-	u32 *buf = (u32 *)pr->pdc->pointer->buffer.pointer;
-
-	buf[2] |= ACPI_PDC_EST_CAPABILITY_SMP;
-
-	return;
-}
-
-/* Initialize _PDC data based on the CPU vendor */
-void arch_acpi_processor_init_pdc(struct acpi_processor *pr)
-{
-	init_intel_pdc(pr);
-	return;
-}
-
-EXPORT_SYMBOL(arch_acpi_processor_init_pdc);
-
 void arch_acpi_processor_cleanup_pdc(struct acpi_processor *pr)
 {
 	if (pr->pdc) {
diff --git a/arch/x86/include/asm/acpi.h b/arch/x86/include/asm/acpi.h
index d787e6e..56f462c 100644
--- a/arch/x86/include/asm/acpi.h
+++ b/arch/x86/include/asm/acpi.h
@@ -149,6 +149,25 @@ static inline bool arch_has_acpi_pdc(void)
 		c->x86_vendor = X86_VENDOR_CENTAUR);
 }
 
+static inline void arch_acpi_set_pdc_bits(u32 *buf)
+{
+	struct cpuinfo_x86 *c = &cpu_data(0);
+
+	buf[2] |= ACPI_PDC_C_CAPABILITY_SMP;
+
+	if (cpu_has(c, X86_FEATURE_EST))
+		buf[2] |= ACPI_PDC_EST_CAPABILITY_SWSMP;
+
+	if (cpu_has(c, X86_FEATURE_ACPI))
+		buf[2] |= ACPI_PDC_T_FFH;
+
+	/*
+	 * If mwait/monitor is unsupported, C2/C3_FFH will be disabled
+	 */
+	if (!cpu_has(c, X86_FEATURE_MWAIT))
+		buf[2] &= ~(ACPI_PDC_C_C2C3_FFH);
+}
+
 #else /* !CONFIG_ACPI */
 
 #define acpi_lapic 0
diff --git a/arch/x86/kernel/acpi/processor.c b/arch/x86/kernel/acpi/processor.c
index d722ca8..0f57307 100644
--- a/arch/x86/kernel/acpi/processor.c
+++ b/arch/x86/kernel/acpi/processor.c
@@ -12,40 +12,6 @@
 #include <acpi/processor.h>
 #include <asm/acpi.h>
 
-static void init_intel_pdc(struct acpi_processor *pr, struct cpuinfo_x86 *c)
-{
-	u32 *buf = (u32 *)pr->pdc->pointer->buffer.pointer;
-
-	buf[2] |= ACPI_PDC_C_CAPABILITY_SMP;
-
-	if (cpu_has(c, X86_FEATURE_EST))
-		buf[2] |= ACPI_PDC_EST_CAPABILITY_SWSMP;
-
-	if (cpu_has(c, X86_FEATURE_ACPI))
-		buf[2] |= ACPI_PDC_T_FFH;
-
-	/*
-	 * If mwait/monitor is unsupported, C2/C3_FFH will be disabled
-	 */
-	if (!cpu_has(c, X86_FEATURE_MWAIT))
-		buf[2] &= ~(ACPI_PDC_C_C2C3_FFH);
-
-	return;
-}
-
-
-/* Initialize _PDC data based on the CPU vendor */
-void arch_acpi_processor_init_pdc(struct acpi_processor *pr)
-{
-	struct cpuinfo_x86 *c = &cpu_data(pr->id);
-
-	init_intel_pdc(pr, c);
-
-	return;
-}
-
-EXPORT_SYMBOL(arch_acpi_processor_init_pdc);
-
 void arch_acpi_processor_cleanup_pdc(struct acpi_processor *pr)
 {
 	if (pr->pdc) {
diff --git a/drivers/acpi/processor_pdc.c b/drivers/acpi/processor_pdc.c
index ccda7c9..48df08e 100644
--- a/drivers/acpi/processor_pdc.c
+++ b/drivers/acpi/processor_pdc.c
@@ -40,6 +40,9 @@ static void acpi_set_pdc_bits(u32 *buf)
 
 	/* Enable coordination with firmware's _TSD info */
 	buf[2] = ACPI_PDC_SMP_T_SWCOORD;
+
+	/* Twiddle arch-specific bits needed for _PDC */
+	arch_acpi_set_pdc_bits(buf);
 }
 
 static void acpi_processor_init_pdc(struct acpi_processor *pr)
@@ -81,9 +84,6 @@ static void acpi_processor_init_pdc(struct acpi_processor *pr)
 	obj_list->pointer = obj;
 	pr->pdc = obj_list;
 
-	/* Now let the arch do the bit-twiddling to buf[] */
-	arch_acpi_processor_init_pdc(pr);
-
 	return;
 }
 
diff --git a/include/acpi/processor.h b/include/acpi/processor.h
index a1b748a..50edd73 100644
--- a/include/acpi/processor.h
+++ b/include/acpi/processor.h
@@ -257,7 +257,6 @@ int acpi_processor_notify_smm(struct module *calling_module);
 DECLARE_PER_CPU(struct acpi_processor *, processors);
 extern struct acpi_processor_errata errata;
 
-void arch_acpi_processor_init_pdc(struct acpi_processor *pr);
 void arch_acpi_processor_cleanup_pdc(struct acpi_processor *pr);
 
 #ifdef ARCH_HAS_POWER_INIT

