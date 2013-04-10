From: Hanjun Guo <guohanjun@huawei.com>
Date: Wed, 10 Apr 2013 10:23:01 +0000
Subject: [PATCH 4/4] ACPI: Only count valid srat memory structures
Message-Id: <1365589381-5624-5-git-send-email-guohanjun@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1365589381-5624-1-git-send-email-guohanjun@huawei.com>
In-Reply-To: <1365589381-5624-1-git-send-email-guohanjun@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kernel.openeuler@huawei.com
Cc: Toshi Kani <toshi.kani@hp.com>, Jiang Liu <jiang.liu@huawei.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

From: Thomas Renninger <trenn@suse.de>

mainline inclusion
from mainline-3.6
upstream commit 095adbb6441172985f5ddc3b9e88cb3191bdeac4
category: bugfix

If BIOS provide OS with SRAT table which contains only one disabled
memory affinity structure, this will trigger a WARN_ON.

This patch is based on the former one "ACPI: Untangle a return
statement for better readability".

--------------------------------------------------------

Otherwise you could run into:
WARN_ON in numa_register_memblks(), because node_possible_map is zero

References: https://bugzilla.novell.com/show_bug.cgi?idu7888

On this machine (ProLiant ML570 G3) the SRAT table contains:
  - No processor affinities
  - One memory affinity structure (which is set disabled)

CC: Per Jessen <per@opensuse.org>
CC: Andi Kleen <andi@firstfloor.org>
Signed-off-by: Thomas Renninger <trenn@suse.de>
Signed-off-by: Len Brown <len.brown@intel.com>
Integrated-by: Hanjun Guo <guohanjun@huawei.com>
---
 arch/ia64/kernel/acpi.c |    5 +++--
 arch/x86/mm/srat.c      |   16 +++++++++-------
 drivers/acpi/numa.c     |    8 +++++---
 include/linux/acpi.h    |    2 +-
 4 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 6f38b61..4405788 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -497,7 +497,7 @@ acpi_numa_processor_affinity_init(struct acpi_srat_cpu_affinity *pa)
 	srat_num_cpus++;
 }
 
-void __init
+int __init
 acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 {
 	unsigned long paddr, size;
@@ -512,7 +512,7 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 
 	/* Ignore disabled entries */
 	if (!(ma->flags & ACPI_SRAT_MEM_ENABLED))
-		return;
+		return -1;
 
 	/* record this node in proximity bitmap */
 	pxm_bit_set(pxm);
@@ -531,6 +531,7 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 	p->size = size;
 	p->nid = pxm;
 	num_node_memblks++;
+	return 0;
 }
 
 void __init acpi_numa_arch_fixup(void)
diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
index efb5b4b..db870ec 100644
--- a/arch/x86/mm/srat.c
+++ b/arch/x86/mm/srat.c
@@ -142,23 +142,23 @@ static inline int save_add_info(void) {return 0;}
 #endif
 
 /* Callback for parsing of the Proximity Domain <-> Memory Area mappings */
-void __init
+int __init
 acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 {
 	u64 start, end;
 	int node, pxm;
 
 	if (srat_disabled())
-		return;
+		return -1;
 	if (ma->header.length != sizeof(struct acpi_srat_mem_affinity)) {
 		bad_srat();
-		return;
+		return -1;
 	}
 	if ((ma->flags & ACPI_SRAT_MEM_ENABLED) = 0)
-		return;
+		return -1;
 
 	if ((ma->flags & ACPI_SRAT_MEM_HOT_PLUGGABLE) && !save_add_info())
-		return;
+		return -1;
 	start = ma->base_address;
 	end = start + ma->length;
 	pxm = ma->proximity_domain;
@@ -168,16 +168,18 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 	if (node < 0) {
 		printk(KERN_ERR "SRAT: Too many proximity domains.\n");
 		bad_srat();
-		return;
+		return -1;
 	}
 
 	if (numa_add_memblk(node, start, end) < 0) {
 		bad_srat();
-		return;
+		return -1;
 	}
 
 	printk(KERN_INFO "SRAT: Node %u PXM %u %Lx-%Lx\n", node, pxm,
 	       start, end);
+  
+	return 0;
 }
 
 void __init acpi_numa_arch_fixup(void) {}
diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 2a63993..cb31298 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -237,6 +237,8 @@ acpi_parse_processor_affinity(struct acpi_subtable_header *header,
 	return 0;
 }
 
+static int __initdata parsed_numa_memblks;
+
 static int __init
 acpi_parse_memory_affinity(struct acpi_subtable_header * header,
 			   const unsigned long end)
@@ -250,8 +252,8 @@ acpi_parse_memory_affinity(struct acpi_subtable_header * header,
 	acpi_table_print_srat_entry(header);
 
 	/* let architecture-dependent part to do it */
-	acpi_numa_memory_affinity_init(memory_affinity);
-
+	if (!acpi_numa_memory_affinity_init(memory_affinity))
+		parsed_numa_memblks++;
 	return 0;
 }
 
@@ -306,7 +308,7 @@ int __init acpi_numa_init(void)
 
 	if (cnt < 0)
 		return cnt;
-	else if (cnt = 0)
+	else if (!parsed_numa_memblks)
 		return -ENOENT;
 	return 0;
 }
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index f421dd8..8b88441 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -96,7 +96,7 @@ void acpi_table_print_madt_entry (struct acpi_subtable_header *madt);
 void acpi_numa_slit_init (struct acpi_table_slit *slit);
 void acpi_numa_processor_affinity_init (struct acpi_srat_cpu_affinity *pa);
 void acpi_numa_x2apic_affinity_init(struct acpi_srat_x2apic_cpu_affinity *pa);
-void acpi_numa_memory_affinity_init (struct acpi_srat_mem_affinity *ma);
+int acpi_numa_memory_affinity_init (struct acpi_srat_mem_affinity *ma);
 void acpi_numa_arch_fixup(void);
 
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
-- 
1.6.0.2


