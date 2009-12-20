From: Alex Chiang <achiang@hp.com>
Date: Sun, 20 Dec 2009 19:19:24 +0000
Subject: [PATCH 04/11] ACPI: processor: factor out common _PDC settings
Message-Id: <20091220191924.4274.27963.stgit@bob.kio>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091220190434.4274.67855.stgit@bob.kio>
In-Reply-To: <20091220190434.4274.67855.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: venkatesh.pallipadi@intel.com, lenb@kernel.org
Cc: Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

Both x86 and ia64 initialize _PDC with mostly common bit settings.

Factor out the common settings and leave the arch-specific ones alone.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Signed-off-by: Alex Chiang <achiang@hp.com>
---

 arch/ia64/kernel/acpi-processor.c |   10 +---------
 arch/x86/kernel/acpi/processor.c  |   10 +---------
 drivers/acpi/processor_pdc.c      |   11 +++++++++++
 3 files changed, 13 insertions(+), 18 deletions(-)

diff --git a/arch/ia64/kernel/acpi-processor.c b/arch/ia64/kernel/acpi-processor.c
index ab72d46..ebe23f5 100644
--- a/arch/ia64/kernel/acpi-processor.c
+++ b/arch/ia64/kernel/acpi-processor.c
@@ -18,15 +18,7 @@ static void init_intel_pdc(struct acpi_processor *pr)
 {
 	u32 *buf = (u32 *)pr->pdc->pointer->buffer.pointer;
 
-	buf[0] = ACPI_PDC_REVISION_ID;
-	buf[1] = 1;
-	buf[2] = ACPI_PDC_EST_CAPABILITY_SMP;
-	/*
-	 * The default of PDC_SMP_T_SWCOORD bit is set for IA64 cpu so
-	 * that OSPM is capable of native ACPI throttling software
-	 * coordination using BIOS supplied _TSD info.
-	 */
-	buf[2] |= ACPI_PDC_SMP_T_SWCOORD;
+	buf[2] |= ACPI_PDC_EST_CAPABILITY_SMP;
 
 	return;
 }
diff --git a/arch/x86/kernel/acpi/processor.c b/arch/x86/kernel/acpi/processor.c
index 967860b..d722ca8 100644
--- a/arch/x86/kernel/acpi/processor.c
+++ b/arch/x86/kernel/acpi/processor.c
@@ -16,16 +16,8 @@ static void init_intel_pdc(struct acpi_processor *pr, struct cpuinfo_x86 *c)
 {
 	u32 *buf = (u32 *)pr->pdc->pointer->buffer.pointer;
 
-	buf[0] = ACPI_PDC_REVISION_ID;
-	buf[1] = 1;
-	buf[2] = ACPI_PDC_C_CAPABILITY_SMP;
+	buf[2] |= ACPI_PDC_C_CAPABILITY_SMP;
 
-	/*
-	 * The default of PDC_SMP_T_SWCOORD bit is set for intel x86 cpu so
-	 * that OSPM is capable of native ACPI throttling software
-	 * coordination using BIOS supplied _TSD info.
-	 */
-	buf[2] |= ACPI_PDC_SMP_T_SWCOORD;
 	if (cpu_has(c, X86_FEATURE_EST))
 		buf[2] |= ACPI_PDC_EST_CAPABILITY_SWSMP;
 
diff --git a/drivers/acpi/processor_pdc.c b/drivers/acpi/processor_pdc.c
index 87946b6..ccda7c9 100644
--- a/drivers/acpi/processor_pdc.c
+++ b/drivers/acpi/processor_pdc.c
@@ -33,6 +33,15 @@ static struct dmi_system_id __cpuinitdata processor_idle_dmi_table[] = {
 	{},
 };
 
+static void acpi_set_pdc_bits(u32 *buf)
+{
+	buf[0] = ACPI_PDC_REVISION_ID;
+	buf[1] = 1;
+
+	/* Enable coordination with firmware's _TSD info */
+	buf[2] = ACPI_PDC_SMP_T_SWCOORD;
+}
+
 static void acpi_processor_init_pdc(struct acpi_processor *pr)
 {
 	struct acpi_object_list *obj_list;
@@ -63,6 +72,8 @@ static void acpi_processor_init_pdc(struct acpi_processor *pr)
 		return;
 	}
 
+	acpi_set_pdc_bits(buf);
+
 	obj->type = ACPI_TYPE_BUFFER;
 	obj->buffer.length = 12;
 	obj->buffer.pointer = (u8 *) buf;

