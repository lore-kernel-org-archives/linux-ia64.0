From: Bob Picco <bob.picco@hp.com>
Date: Tue, 04 Oct 2005 19:13:50 +0000
Subject: [PATCH 3/5] V5 ia64 SPARSEMEM - conditional changes for SPARSEMEM
Message-Id: <20051004191350.GS25483@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch introduces the conditional changes required for the three
memory models.  With [patch 1/4] there are three memory models; FLATMEM, 
DISCONTIG and SPARSEMEM.  Also a new arch include file sparemem.h is
introduced for defining SPARSEMEM parameters.

Signed-off-by: Bob Picco <bob.picco@hp.com>

 include/asm-ia64/meminit.h   |    2 +-
 include/asm-ia64/mmzone.h    |   10 +++++++---
 include/asm-ia64/nodedata.h  |    4 ++--
 include/asm-ia64/page.h      |    6 +++---
 include/asm-ia64/sparsemem.h |   20 ++++++++++++++++++++
 5 files changed, 33 insertions(+), 9 deletions(-)

Index: linux-2.6.14-rc2/include/asm-ia64/meminit.h
=================================--- linux-2.6.14-rc2.orig/include/asm-ia64/meminit.h	2005-10-03 19:57:15.000000000 -0400
+++ linux-2.6.14-rc2/include/asm-ia64/meminit.h	2005-10-03 19:57:27.000000000 -0400
@@ -41,7 +41,7 @@ extern int filter_rsvd_memory (unsigned 
 #define GRANULEROUNDUP(n)	(((n)+IA64_GRANULE_SIZE-1) & ~(IA64_GRANULE_SIZE-1))
 #define ORDERROUNDDOWN(n)	((n) & ~((PAGE_SIZE<<MAX_ORDER)-1))
 
-#ifdef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_NUMA
   extern void call_pernode_memory (unsigned long start, unsigned long len, void *func);
 #else
 # define call_pernode_memory(start, len, func)	(*func)(start, len, 0)
Index: linux-2.6.14-rc2/include/asm-ia64/mmzone.h
=================================--- linux-2.6.14-rc2.orig/include/asm-ia64/mmzone.h	2005-10-03 19:57:15.000000000 -0400
+++ linux-2.6.14-rc2/include/asm-ia64/mmzone.h	2005-10-03 19:57:27.000000000 -0400
@@ -15,7 +15,7 @@
 #include <asm/page.h>
 #include <asm/meminit.h>
 
-#ifdef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_NUMA
 
 static inline int pfn_to_nid(unsigned long pfn)
 {
@@ -31,6 +31,10 @@ static inline int pfn_to_nid(unsigned lo
 #endif
 }
 
+#ifdef CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
+extern int early_pfn_to_nid(unsigned long pfn);
+#endif
+
 #ifdef CONFIG_IA64_DIG /* DIG systems are small */
 # define MAX_PHYSNODE_ID	8
 # define NR_NODE_MEMBLKS	(MAX_NUMNODES * 8)
@@ -39,8 +43,8 @@ static inline int pfn_to_nid(unsigned lo
 # define NR_NODE_MEMBLKS	(MAX_NUMNODES * 4)
 #endif
 
-#else /* CONFIG_DISCONTIGMEM */
+#else /* CONFIG_NUMA */
 # define NR_NODE_MEMBLKS	(MAX_NUMNODES * 4)
-#endif /* CONFIG_DISCONTIGMEM */
+#endif /* CONFIG_NUMA */
 
 #endif /* _ASM_IA64_MMZONE_H */
Index: linux-2.6.14-rc2/include/asm-ia64/nodedata.h
=================================--- linux-2.6.14-rc2.orig/include/asm-ia64/nodedata.h	2005-10-03 19:57:15.000000000 -0400
+++ linux-2.6.14-rc2/include/asm-ia64/nodedata.h	2005-10-03 19:57:27.000000000 -0400
@@ -17,7 +17,7 @@
 #include <asm/percpu.h>
 #include <asm/mmzone.h>
 
-#ifdef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_NUMA
 
 /*
  * Node Data. One of these structures is located on each node of a NUMA system.
@@ -47,6 +47,6 @@ struct ia64_node_data {
  */
 #define NODE_DATA(nid)		(local_node_data->pg_data_ptrs[nid])
 
-#endif /* CONFIG_DISCONTIGMEM */
+#endif /* CONFIG_NUMA */
 
 #endif /* _ASM_IA64_NODEDATA_H */
Index: linux-2.6.14-rc2/include/asm-ia64/page.h
=================================--- linux-2.6.14-rc2.orig/include/asm-ia64/page.h	2005-10-03 19:57:15.000000000 -0400
+++ linux-2.6.14-rc2/include/asm-ia64/page.h	2005-10-03 19:57:27.000000000 -0400
@@ -102,15 +102,15 @@ do {						\
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 extern int ia64_pfn_valid (unsigned long pfn);
-#else
+#elif defined(CONFIG_FLATMEM)
 # define ia64_pfn_valid(pfn) 1
 #endif
 
-#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_FLATMEM
 # define pfn_valid(pfn)		(((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
 # define page_to_pfn(page)	((unsigned long) (page - mem_map))
 # define pfn_to_page(pfn)	(mem_map + (pfn))
-#else
+#elif defined(CONFIG_DISCONTIGMEM)
 extern struct page *vmem_map;
 extern unsigned long max_low_pfn;
 # define pfn_valid(pfn)		(((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))
Index: linux-2.6.14-rc2/include/asm-ia64/sparsemem.h
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.14-rc2/include/asm-ia64/sparsemem.h	2005-10-03 19:57:27.000000000 -0400
@@ -0,0 +1,20 @@
+#ifndef _ASM_IA64_SPARSEMEM_H
+#define _ASM_IA64_SPARSEMEM_H
+
+#ifdef CONFIG_SPARSEMEM
+/*
+ * SECTION_SIZE_BITS            2^N: how big each section will be
+ * MAX_PHYSMEM_BITS             2^N: how much memory we can have in that space
+ */
+
+#define SECTION_SIZE_BITS	(30)
+#define MAX_PHYSMEM_BITS	(50)
+#ifdef CONFIG_FORCE_MAX_ZONEORDER
+#if ((CONFIG_FORCE_MAX_ZONEORDER - 1 + PAGE_SHIFT) > SECTION_SIZE_BITS)
+#undef SECTION_SIZE_BITS
+#define SECTION_SIZE_BITS (CONFIG_FORCE_MAX_ZONEORDER - 1 + PAGE_SHIFT)
+#endif
+#endif
+
+#endif /* CONFIG_SPARSEMEM */
+#endif /* _ASM_IA64_SPARSEMEM_H */
