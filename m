From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Fri, 10 Feb 2006 14:21:17 +0000
Subject: [RFC/PATCH: 006/010] Memory hotplug for new nodes with pgdat allocation. (NODE_DATA array initalize
Message-Id: <20060210224517.C53C.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>, "Luck, Tony" <tony.luck@intel.com>, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>
Cc: Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, x86-64 Discuss <discuss@x86-64.org>

This is to register NODE_DATA() macro for ia64.
Ia64's node_data[] arrays are copied ON EACH NODES,
So, they must be updated all at once.
This use stop_machine_run() for safety update of them.

Other archtecture doen't need like this code....

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: pgdat2/arch/ia64/mm/discontig.c
=================================--- pgdat2.orig/arch/ia64/mm/discontig.c	2006-02-10 17:22:18.000000000 +0900
+++ pgdat2/arch/ia64/mm/discontig.c	2006-02-10 19:54:57.000000000 +0900
@@ -21,6 +21,7 @@
 #include <linux/acpi.h>
 #include <linux/efi.h>
 #include <linux/nodemask.h>
+#include <linux/stop_machine.h>
 #include <asm/pgalloc.h>
 #include <asm/tlb.h>
 #include <asm/meminit.h>
@@ -114,11 +115,12 @@ static int __init early_nr_cpus_node(int
  * compute_pernodesize - compute size of pernode data
  * @node: the node id.
  */
-static unsigned long __init compute_pernodesize(int node)
+static unsigned long __meminit compute_pernodesize(int node)
 {
-	unsigned long pernodesize = 0, cpus;
+	unsigned long pernodesize = 0, cpus = 0;
 
-	cpus = early_nr_cpus_node(node);
+	if (system_state = SYSTEM_BOOTING)
+		cpus = early_nr_cpus_node(node);
 	pernodesize += PERCPU_PAGE_SIZE * cpus;
 	pernodesize += node * L1_CACHE_BYTES;
 	pernodesize += L1_CACHE_ALIGN(sizeof(pg_data_t));
@@ -753,3 +755,71 @@ void __init paging_init(void)
 
 	zero_page_memmap_ptr = virt_to_page(ia64_imva(empty_zero_page));
 }
+
+#ifdef CONFIG_MEMORY_HOTPLUG
+unsigned long arch_pernode_size(int nid)
+{
+	return compute_pernodesize(nid);
+}
+
+/*
+ *     NODE_DATA() array is replicated on each node as pg_data_ptrs[].
+ *     So, all of them must be updated.
+ *     This update is done when other cpu is stopped.
+ */
+static int __set_node_data_array(void *_pgdat)
+{
-- 
Yasunori Goto 


