From: Alex Chiang <achiang@hp.com>
Date: Wed, 16 Jul 2008 18:47:08 +0000
Subject: [PATCH] Avoid overflowing ia64_cpu_to_sapicid in acpi_map_lsapic()
Message-Id: <20080716184708.GC2304@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony,

This patch should probably go in, independent of that other
series I posted (re: cpu_enabled_map, etc.).

Thanks.

/ac

From: Alex Chiang <achiang@hp.com>

acpi_map_lsapic tries to stuff a long into ia64_cpu_to_sapicid[],
which can only hold ints, so let's fix that.

We need to update the signature of acpi_map_cpu2node() too.
    
Signed-off-by: Alex Chiang <achiang@hp.com>

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 43687cc..5d1eb7e 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -774,7 +774,7 @@ int acpi_gsi_to_irq(u32 gsi, unsigned int *irq)
  */
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
 static
-int acpi_map_cpu2node(acpi_handle handle, int cpu, long physid)
+int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 {
 #ifdef CONFIG_ACPI_NUMA
 	int pxm_id;
@@ -854,8 +854,7 @@ int acpi_map_lsapic(acpi_handle handle, int *pcpu)
 	union acpi_object *obj;
 	struct acpi_madt_local_sapic *lsapic;
 	cpumask_t tmp_map;
-	long physid;
-	int cpu;
+	int cpu, physid;
 
 	if (ACPI_FAILURE(acpi_evaluate_object(handle, "_MAT", NULL, &buffer)))
 		return -EINVAL;
