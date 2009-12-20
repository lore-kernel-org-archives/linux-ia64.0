From: Alex Chiang <achiang@hp.com>
Date: Sun, 20 Dec 2009 19:23:16 +0000
Subject: [PATCH 2/3] ACPI: processor: change acpi_processor_set_pdc() interface
Message-Id: <20091220192316.5438.22920.stgit@bob.kio>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091220190434.4274.67855.stgit@bob.kio>
In-Reply-To: <20091220190434.4274.67855.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: venkatesh.pallipadi@intel.com, lenb@kernel.org
Cc: linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

When calling _PDC, we really only need the handle to the processor
to call the method; we don't look at any other parts of the
struct acpi_processor * given to us.

In the early path, when we walk the namespace, we are given the
handle directly, so just pass it through to acpi_processor_set_pdc()
without stuffing it into a wasteful struct acpi_processor allocated
on the stack each time

This saves 2834 bytes of stack.

Update the interface accordingly.

Signed-off-by: Alex Chiang <achiang@hp.com>
---

 drivers/acpi/processor_core.c |    2 +-
 drivers/acpi/processor_pdc.c  |   18 +++---------------
 include/acpi/processor.h      |    2 +-
 3 files changed, 5 insertions(+), 17 deletions(-)

diff --git a/drivers/acpi/processor_core.c b/drivers/acpi/processor_core.c
index a19a4ff..9863c98 100644
--- a/drivers/acpi/processor_core.c
+++ b/drivers/acpi/processor_core.c
@@ -763,7 +763,7 @@ static int __cpuinit acpi_processor_add(struct acpi_device *device)
 	}
 
 	/* _PDC call should be done before doing anything else (if reqd.). */
-	acpi_processor_set_pdc(pr);
+	acpi_processor_set_pdc(pr->handle);
 
 #ifdef CONFIG_CPU_FREQ
 	acpi_processor_ppc_has_changed(pr, 0);
diff --git a/drivers/acpi/processor_pdc.c b/drivers/acpi/processor_pdc.c
index deeba22..30e4dc0 100644
--- a/drivers/acpi/processor_pdc.c
+++ b/drivers/acpi/processor_pdc.c
@@ -125,7 +125,7 @@ acpi_processor_eval_pdc(acpi_handle handle, struct acpi_object_list *pdc_in)
 	return status;
 }
 
-void acpi_processor_set_pdc(struct acpi_processor *pr)
+void acpi_processor_set_pdc(acpi_handle handle)
 {
 	struct acpi_object_list *obj_list;
 
@@ -136,7 +136,7 @@ void acpi_processor_set_pdc(struct acpi_processor *pr)
 	if (!obj_list)
 		return;
 
-	acpi_processor_eval_pdc(pr->handle, obj_list);
+	acpi_processor_eval_pdc(handle, obj_list);
 
 	kfree(obj_list->pointer->buffer.pointer);
 	kfree(obj_list->pointer);
@@ -147,19 +147,7 @@ EXPORT_SYMBOL_GPL(acpi_processor_set_pdc);
 static acpi_status
 early_init_pdc(acpi_handle handle, u32 lvl, void *context, void **rv)
 {
-	struct acpi_processor pr;
-
-	pr.handle = handle;
-
-	/* x86 implementation looks at pr.id to determine some
-	 * CPU capabilites. We can just hard code to 0 since we're
-	 * assuming the CPUs in the system are homogenous and all
-	 * have the same capabilities.
-	 */
-	pr.id = 0;
-
-	acpi_processor_set_pdc(&pr);
-
+	acpi_processor_set_pdc(handle);
 	return AE_OK;
 }
 
diff --git a/include/acpi/processor.h b/include/acpi/processor.h
index 0873cd5..7cc433d 100644
--- a/include/acpi/processor.h
+++ b/include/acpi/processor.h
@@ -323,7 +323,7 @@ static inline int acpi_processor_get_bios_limit(int cpu, unsigned int *limit)
 #endif				/* CONFIG_CPU_FREQ */
 
 /* in processor_pdc.c */
-void acpi_processor_set_pdc(struct acpi_processor *pr);
+void acpi_processor_set_pdc(acpi_handle handle);
 
 /* in processor_throttling.c */
 int acpi_processor_tstate_has_changed(struct acpi_processor *pr);

