From: Alex Chiang <achiang@hp.com>
Date: Sun, 20 Dec 2009 19:19:19 +0000
Subject: [PATCH 03/11] ACPI: processor: unify arch_acpi_processor_init_pdc
Message-Id: <20091220191919.4274.59621.stgit@bob.kio>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091220190434.4274.67855.stgit@bob.kio>
In-Reply-To: <20091220190434.4274.67855.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: venkatesh.pallipadi@intel.com, lenb@kernel.org
Cc: Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

The x86 and ia64 implementations of arch_acpi_processor_init_pdc()
are almost exactly the same. The only difference is in what bits
they set in obj_list buffer.

Combine the boilerplate memory management code, and leave the
arch-specific bit twiddling in separate implementations.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Signed-off-by: Alex Chiang <achiang@hp.com>
---

 arch/ia64/kernel/acpi-processor.c |   34 +---------------------------
 arch/x86/kernel/acpi/processor.c  |   34 +---------------------------
 drivers/acpi/processor_pdc.c      |   45 ++++++++++++++++++++++++++++++++++++-
 3 files changed, 46 insertions(+), 67 deletions(-)

diff --git a/arch/ia64/kernel/acpi-processor.c b/arch/ia64/kernel/acpi-processor.c
index dbda7bd..ab72d46 100644
--- a/arch/ia64/kernel/acpi-processor.c
+++ b/arch/ia64/kernel/acpi-processor.c
@@ -16,31 +16,7 @@
 
 static void init_intel_pdc(struct acpi_processor *pr)
 {
-	struct acpi_object_list *obj_list;
-	union acpi_object *obj;
-	u32 *buf;
-
-	/* allocate and initialize pdc. It will be used later. */
-	obj_list = kmalloc(sizeof(struct acpi_object_list), GFP_KERNEL);
-	if (!obj_list) {
-		printk(KERN_ERR "Memory allocation error\n");
-		return;
-	}
-
-	obj = kmalloc(sizeof(union acpi_object), GFP_KERNEL);
-	if (!obj) {
-		printk(KERN_ERR "Memory allocation error\n");
-		kfree(obj_list);
-		return;
-	}
-
-	buf = kmalloc(12, GFP_KERNEL);
-	if (!buf) {
-		printk(KERN_ERR "Memory allocation error\n");
-		kfree(obj);
-		kfree(obj_list);
-		return;
-	}
+	u32 *buf = (u32 *)pr->pdc->pointer->buffer.pointer;
 
 	buf[0] = ACPI_PDC_REVISION_ID;
 	buf[1] = 1;
@@ -52,20 +28,12 @@ static void init_intel_pdc(struct acpi_processor *pr)
 	 */
 	buf[2] |= ACPI_PDC_SMP_T_SWCOORD;
 
-	obj->type = ACPI_TYPE_BUFFER;
-	obj->buffer.length = 12;
-	obj->buffer.pointer = (u8 *) buf;
-	obj_list->count = 1;
-	obj_list->pointer = obj;
-	pr->pdc = obj_list;
-
 	return;
 }
 
 /* Initialize _PDC data based on the CPU vendor */
 void arch_acpi_processor_init_pdc(struct acpi_processor *pr)
 {
-	pr->pdc = NULL;
 	init_intel_pdc(pr);
 	return;
 }
diff --git a/arch/x86/kernel/acpi/processor.c b/arch/x86/kernel/acpi/processor.c
index bcb6efe..967860b 100644
--- a/arch/x86/kernel/acpi/processor.c
+++ b/arch/x86/kernel/acpi/processor.c
@@ -14,31 +14,7 @@
 
 static void init_intel_pdc(struct acpi_processor *pr, struct cpuinfo_x86 *c)
 {
-	struct acpi_object_list *obj_list;
-	union acpi_object *obj;
-	u32 *buf;
-
-	/* allocate and initialize pdc. It will be used later. */
-	obj_list = kmalloc(sizeof(struct acpi_object_list), GFP_KERNEL);
-	if (!obj_list) {
-		printk(KERN_ERR "Memory allocation error\n");
-		return;
-	}
-
-	obj = kmalloc(sizeof(union acpi_object), GFP_KERNEL);
-	if (!obj) {
-		printk(KERN_ERR "Memory allocation error\n");
-		kfree(obj_list);
-		return;
-	}
-
-	buf = kmalloc(12, GFP_KERNEL);
-	if (!buf) {
-		printk(KERN_ERR "Memory allocation error\n");
-		kfree(obj);
-		kfree(obj_list);
-		return;
-	}
+	u32 *buf = (u32 *)pr->pdc->pointer->buffer.pointer;
 
 	buf[0] = ACPI_PDC_REVISION_ID;
 	buf[1] = 1;
@@ -62,13 +38,6 @@ static void init_intel_pdc(struct acpi_processor *pr, struct cpuinfo_x86 *c)
 	if (!cpu_has(c, X86_FEATURE_MWAIT))
 		buf[2] &= ~(ACPI_PDC_C_C2C3_FFH);
 
-	obj->type = ACPI_TYPE_BUFFER;
-	obj->buffer.length = 12;
-	obj->buffer.pointer = (u8 *) buf;
-	obj_list->count = 1;
-	obj_list->pointer = obj;
-	pr->pdc = obj_list;
-
 	return;
 }
 
@@ -78,7 +47,6 @@ void arch_acpi_processor_init_pdc(struct acpi_processor *pr)
 {
 	struct cpuinfo_x86 *c = &cpu_data(pr->id);
 
-	pr->pdc = NULL;
 	init_intel_pdc(pr, c);
 
 	return;
diff --git a/drivers/acpi/processor_pdc.c b/drivers/acpi/processor_pdc.c
index 931e735..87946b6 100644
--- a/drivers/acpi/processor_pdc.c
+++ b/drivers/acpi/processor_pdc.c
@@ -33,6 +33,49 @@ static struct dmi_system_id __cpuinitdata processor_idle_dmi_table[] = {
 	{},
 };
 
+static void acpi_processor_init_pdc(struct acpi_processor *pr)
+{
+	struct acpi_object_list *obj_list;
+	union acpi_object *obj;
+	u32 *buf;
+
+	pr->pdc = NULL;
+
+	/* allocate and initialize pdc. It will be used later. */
+	obj_list = kmalloc(sizeof(struct acpi_object_list), GFP_KERNEL);
+	if (!obj_list) {
+		printk(KERN_ERR "Memory allocation error\n");
+		return;
+	}
+
+	obj = kmalloc(sizeof(union acpi_object), GFP_KERNEL);
+	if (!obj) {
+		printk(KERN_ERR "Memory allocation error\n");
+		kfree(obj_list);
+		return;
+	}
+
+	buf = kmalloc(12, GFP_KERNEL);
+	if (!buf) {
+		printk(KERN_ERR "Memory allocation error\n");
+		kfree(obj);
+		kfree(obj_list);
+		return;
+	}
+
+	obj->type = ACPI_TYPE_BUFFER;
+	obj->buffer.length = 12;
+	obj->buffer.pointer = (u8 *) buf;
+	obj_list->count = 1;
+	obj_list->pointer = obj;
+	pr->pdc = obj_list;
+
+	/* Now let the arch do the bit-twiddling to buf[] */
+	arch_acpi_processor_init_pdc(pr);
+
+	return;
+}
+
 /*
  * _PDC is required for a BIOS-OS handshake for most of the newer
  * ACPI processor features.
@@ -72,7 +115,7 @@ void acpi_processor_set_pdc(struct acpi_processor *pr)
 	if (arch_has_acpi_pdc() = false)
 		return;
 
-	arch_acpi_processor_init_pdc(pr);
+	acpi_processor_init_pdc(pr);
 	acpi_processor_eval_pdc(pr);
 	arch_acpi_processor_cleanup_pdc(pr);
 }

