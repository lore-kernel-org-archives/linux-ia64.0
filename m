From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 24 Sep 2003 18:17:57 +0000
Subject: [PATCH] allocate page tables on the right node
Message-Id: <marc-linux-ia64-106442750600527@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Small patch that shouldn't affect anybody right now, but will help when
CONFIG_DISCONTIGMEM and CONFIG_VIRTUAL_MEM_MAP learn to play nice
together.  Allocates the page tables on the node they belong to,
minimizing off-node references.

Thanks,
Jesse

diff -Nru a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
--- a/arch/ia64/mm/init.c	Wed Sep 24 11:16:21 2003
+++ b/arch/ia64/mm/init.c	Wed Sep 24 11:16:21 2003
@@ -24,6 +24,7 @@
 #include <asm/ia32.h>
 #include <asm/io.h>
 #include <asm/machvec.h>
+#include <asm/numa.h>
 #include <asm/patch.h>
 #include <asm/pgalloc.h>
 #include <asm/sal.h>
@@ -342,6 +343,7 @@
 {
 	unsigned long address, start_page, end_page;
 	struct page *map_start, *map_end;
+	int node;
 	pgd_t *pgd;
 	pmd_t *pmd;
 	pte_t *pte;
@@ -351,19 +353,20 @@
 
 	start_page = (unsigned long) map_start & PAGE_MASK;
 	end_page = PAGE_ALIGN((unsigned long) map_end);
+	node = paddr_to_nid(__pa(start));
 
 	for (address = start_page; address < end_page; address += PAGE_SIZE) {
 		pgd = pgd_offset_k(address);
 		if (pgd_none(*pgd))
-			pgd_populate(&init_mm, pgd, alloc_bootmem_pages(PAGE_SIZE));
+			pgd_populate(&init_mm, pgd, alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
 		pmd = pmd_offset(pgd, address);
 
 		if (pmd_none(*pmd))
-			pmd_populate_kernel(&init_mm, pmd, alloc_bootmem_pages(PAGE_SIZE));
+			pmd_populate_kernel(&init_mm, pmd, alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
 		pte = pte_offset_kernel(pmd, address);
 
 		if (pte_none(*pte))
-			set_pte(pte, pfn_pte(__pa(alloc_bootmem_pages(PAGE_SIZE)) >> PAGE_SHIFT,
+			set_pte(pte, pfn_pte(__pa(alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE)) >> PAGE_SHIFT,
 					     PAGE_KERNEL));
 	}
 	return 0;
diff -Nru a/include/asm-ia64/numa.h b/include/asm-ia64/numa.h
--- a/include/asm-ia64/numa.h	Wed Sep 24 11:16:21 2003
+++ b/include/asm-ia64/numa.h	Wed Sep 24 11:16:21 2003
@@ -67,6 +67,12 @@
 
 #define local_nodeid (cpu_to_node_map[smp_processor_id()])
 
+#else /* !CONFIG_NUMA */
+
+#define node_distance(from,to)	10
+#define paddr_to_nid(addr)	0
+#define local_nodeid		0
+
 #endif /* CONFIG_NUMA */
 
 #endif /* _ASM_IA64_NUMA_H */
