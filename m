From: Hanjun Guo <hanjun.guo@linaro.org>
Date: Mon, 02 Sep 2013 03:57:35 +0000
Subject: [PATCH v2 2/6] ACPI / processor: use apic_id and remove duplicated _MAT evaluation
Message-Id: <1378094259-5922-3-git-send-email-hanjun.guo@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1378094259-5922-1-git-send-email-hanjun.guo@linaro.org>
In-Reply-To: <1378094259-5922-1-git-send-email-hanjun.guo@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@redhat.com>, Jiang Liu <jiang.liu@huawei.com>, linux-acpi@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, patches@linaro.org, linaro-kernel@lists.linaro.org, linaro-acpi@lists.linaro.org, Hanjun Guo <hanjun.guo@linaro.org>

From: Jiang Liu <jiang.liu@huawei.com>

Since APIC id is saved in processor struct, just use it and
remove the duplicated _MAT evaluation.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Signed-off-by: Hanjun Guo <hanjun.guo@linaro.org>
---
 arch/ia64/kernel/acpi.c       |   38 ++++----------------------------------
 arch/x86/kernel/acpi/boot.c   |   38 +++-----------------------------------
 drivers/acpi/acpi_processor.c |    2 +-
 include/linux/acpi.h          |    2 +-
 4 files changed, 9 insertions(+), 71 deletions(-)

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 5eb71d2..59d52e3 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -882,40 +882,10 @@ __init void prefill_possible_map(void)
 		set_cpu_possible(i, true);
 }
 
-static int _acpi_map_lsapic(acpi_handle handle, int *pcpu)
+static int _acpi_map_lsapic(acpi_handle handle, int physid, int *pcpu)
 {
-	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
-	union acpi_object *obj;
-	struct acpi_madt_local_sapic *lsapic;
 	cpumask_t tmp_map;
-	int cpu, physid;
-
-	if (ACPI_FAILURE(acpi_evaluate_object(handle, "_MAT", NULL, &buffer)))
-		return -EINVAL;
-
-	if (!buffer.length || !buffer.pointer)
-		return -EINVAL;
-
-	obj = buffer.pointer;
-	if (obj->type != ACPI_TYPE_BUFFER)
-	{
-		kfree(buffer.pointer);
-		return -EINVAL;
-	}
-
-	lsapic = (struct acpi_madt_local_sapic *)obj->buffer.pointer;
-
-	if ((lsapic->header.type != ACPI_MADT_TYPE_LOCAL_SAPIC) ||
-	    (!(lsapic->lapic_flags & ACPI_MADT_ENABLED))) {
-		kfree(buffer.pointer);
-		return -EINVAL;
-	}
-
-	physid = ((lsapic->id << 8) | (lsapic->eid));
-
-	kfree(buffer.pointer);
-	buffer.length = ACPI_ALLOCATE_BUFFER;
-	buffer.pointer = NULL;
+	int cpu;
 
 	cpumask_complement(&tmp_map, cpu_present_mask);
 	cpu = cpumask_first(&tmp_map);
@@ -934,9 +904,9 @@ static int _acpi_map_lsapic(acpi_handle handle, int *pcpu)
 }
 
 /* wrapper to silence section mismatch warning */
-int __ref acpi_map_lsapic(acpi_handle handle, int *pcpu)
+int __ref acpi_map_lsapic(acpi_handle handle, int physid, int *pcpu)
 {
-	return _acpi_map_lsapic(handle, pcpu);
+	return _acpi_map_lsapic(handle, physid, pcpu);
 }
 EXPORT_SYMBOL(acpi_map_lsapic);
 
diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index 2627a81..3e186d1 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -620,44 +620,12 @@ static void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 #endif
 }
 
-static int _acpi_map_lsapic(acpi_handle handle, int *pcpu)
+static int _acpi_map_lsapic(acpi_handle handle, int physid, int *pcpu)
 {
-	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
-	union acpi_object *obj;
-	struct acpi_madt_local_apic *lapic;
 	cpumask_var_t tmp_map, new_map;
-	u8 physid;
 	int cpu;
 	int retval = -ENOMEM;
 
-	if (ACPI_FAILURE(acpi_evaluate_object(handle, "_MAT", NULL, &buffer)))
-		return -EINVAL;
-
-	if (!buffer.length || !buffer.pointer)
-		return -EINVAL;
-
-	obj = buffer.pointer;
-	if (obj->type != ACPI_TYPE_BUFFER ||
-	    obj->buffer.length < sizeof(*lapic)) {
-		kfree(buffer.pointer);
-		return -EINVAL;
-	}
-
-	lapic = (struct acpi_madt_local_apic *)obj->buffer.pointer;
-
-	if (lapic->header.type != ACPI_MADT_TYPE_LOCAL_APIC ||
-	    !(lapic->lapic_flags & ACPI_MADT_ENABLED)) {
-		kfree(buffer.pointer);
-		return -EINVAL;
-	}
-
-	physid = lapic->id;
-
-	kfree(buffer.pointer);
-	buffer.length = ACPI_ALLOCATE_BUFFER;
-	buffer.pointer = NULL;
-	lapic = NULL;
-
 	if (!alloc_cpumask_var(&tmp_map, GFP_KERNEL))
 		goto out;
 
@@ -695,9 +663,9 @@ out:
 }
 
 /* wrapper to silence section mismatch warning */
-int __ref acpi_map_lsapic(acpi_handle handle, int *pcpu)
+int __ref acpi_map_lsapic(acpi_handle handle, int physid, int *pcpu)
 {
-	return _acpi_map_lsapic(handle, pcpu);
+	return _acpi_map_lsapic(handle, physid, pcpu);
 }
 EXPORT_SYMBOL(acpi_map_lsapic);
 
diff --git a/drivers/acpi/acpi_processor.c b/drivers/acpi/acpi_processor.c
index f89f914..66c9b70 100644
--- a/drivers/acpi/acpi_processor.c
+++ b/drivers/acpi/acpi_processor.c
@@ -181,7 +181,7 @@ static int acpi_processor_hotadd_init(struct acpi_processor *pr)
 	cpu_maps_update_begin();
 	cpu_hotplug_begin();
 
-	ret = acpi_map_lsapic(pr->handle, &pr->id);
+	ret = acpi_map_lsapic(pr->handle, pr->apic_id, &pr->id);
 	if (ret)
 		goto out;
 
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index a5db4ae..3bc7414 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -116,7 +116,7 @@ void acpi_numa_arch_fixup(void);
 
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
 /* Arch dependent functions for cpu hotplug support */
-int acpi_map_lsapic(acpi_handle handle, int *pcpu);
+int acpi_map_lsapic(acpi_handle handle, int physid, int *pcpu);
 int acpi_unmap_lsapic(int cpu);
 #endif /* CONFIG_ACPI_HOTPLUG_CPU */
 
-- 
1.7.9.5

