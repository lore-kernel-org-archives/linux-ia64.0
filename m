From: Bob Picco <bob.picco@hp.com>
Date: Wed, 25 May 2005 15:14:11 +0000
Subject: [patch 3/4] V2 ia64 SPARSEMEM - conditional changes for SPARSEMEM
Message-Id: <20050525151411.GE23448@localhost.localdomain>
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


 meminit.h   |    2 +-
 mmzone.h    |    6 +++---
 nodedata.h  |    4 ++--
 page.h      |   12 +++++++++---
 sparsemem.h |   28 ++++++++++++++++++++++++++++
 5 files changed, 43 insertions(+), 9 deletions(-)


Index: linux-2.6.12-rc4-mm2-broken/include/asm-ia64/meminit.h
=================================--- linux-2.6.12-rc4-mm2-broken.orig/include/asm-ia64/meminit.h	2004-12-24 16:34:30.000000000 -0500
+++ linux-2.6.12-rc4-mm2-broken/include/asm-ia64/meminit.h	2005-05-17 15:21:54.000000000 -0400
@@ -41,7 +41,7 @@ extern int filter_rsvd_memory (unsigned 
 #define GRANULEROUNDUP(n)	(((n)+IA64_GRANULE_SIZE-1) & ~(IA64_GRANULE_SIZE-1))
 #define ORDERROUNDDOWN(n)	((n) & ~((PAGE_SIZE<<MAX_ORDER)-1))
 
-#ifdef CONFIG_DISCONTIGMEM
+#if defined(CONFIG_DISCONTIGMEM) || defined(CONFIG_SPARSEMEM)
   extern void call_pernode_memory (unsigned long start, unsigned long len, void *func);
 #else
 # define call_pernode_memory(start, len, func)	(*func)(start, len, 0)
Index: linux-2.6.12-rc4-mm2-broken/include/asm-ia64/mmzone.h
=================================--- linux-2.6.12-rc4-mm2-broken.orig/include/asm-ia64/mmzone.h	2005-05-16 11:26:00.000000000 -0400
+++ linux-2.6.12-rc4-mm2-broken/include/asm-ia64/mmzone.h	2005-05-17 15:21:54.000000000 -0400
@@ -15,7 +15,7 @@
 #include <asm/page.h>
 #include <asm/meminit.h>
 
-#ifdef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_NUMA
 
 #ifdef CONFIG_IA64_DIG /* DIG systems are small */
 # define MAX_PHYSNODE_ID	8
@@ -25,8 +25,8 @@
 # define NR_NODE_MEMBLKS	(MAX_NUMNODES * 4)
 #endif
 
-#else /* CONFIG_DISCONTIGMEM */
+#else /* CONFIG_NUMA */
 # define NR_NODE_MEMBLKS	(MAX_NUMNODES * 4)
-#endif /* CONFIG_DISCONTIGMEM */
+#endif /* CONFIG_NUMA */
 
 #endif /* _ASM_IA64_MMZONE_H */
Index: linux-2.6.12-rc4-mm2-broken/include/asm-ia64/nodedata.h
=================================--- linux-2.6.12-rc4-mm2-broken.orig/include/asm-ia64/nodedata.h	2005-05-16 11:26:00.000000000 -0400
+++ linux-2.6.12-rc4-mm2-broken/include/asm-ia64/nodedata.h	2005-05-17 15:21:54.000000000 -0400
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
Index: linux-2.6.12-rc4-mm2-broken/include/asm-ia64/page.h
=================================--- linux-2.6.12-rc4-mm2-broken.orig/include/asm-ia64/page.h	2005-05-16 11:26:24.000000000 -0400
+++ linux-2.6.12-rc4-mm2-broken/include/asm-ia64/page.h	2005-05-23 14:28:14.000000000 -0400
@@ -90,15 +90,15 @@ do {						\
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 extern int ia64_pfn_valid (unsigned long pfn);
-#else
+#elif CONFIG_FLATMEM
 # define ia64_pfn_valid(pfn) 1
 #endif
 
-#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_FLATMEM
 # define pfn_valid(pfn)		(((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
 # define page_to_pfn(page)	((unsigned long) (page - mem_map))
 # define pfn_to_page(pfn)	(mem_map + (pfn))
-#else
+#elif CONFIG_DISCONTIGMEM
 extern struct page *vmem_map;
 extern unsigned long max_low_pfn;
 # define pfn_valid(pfn)		(((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))
@@ -106,6 +106,10 @@ extern unsigned long max_low_pfn;
 # define pfn_to_page(pfn)	(vmem_map + (pfn))
 #endif
 
+#ifdef CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID	
+extern int early_pfn_to_nid(unsigned long pfn);
+#endif
+
 #define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
 
@@ -127,6 +131,8 @@ typedef union ia64_va {
 #define __pa(x)		({ia64_va _v; _v.l = (long) (x); _v.f.reg = 0; _v.l;})
 #define __va(x)		({ia64_va _v; _v.l = (long) (x); _v.f.reg = -1; _v.p;})
 
+#define pfn_to_kaddr(pfn) 	__va((pfn) << PAGE_SHIFT)
+
 #define REGION_NUMBER(x)	({ia64_va _v; _v.l = (long) (x); _v.f.reg;})
 #define REGION_OFFSET(x)	({ia64_va _v; _v.l = (long) (x); _v.f.off;})
 
Index: linux-2.6.12-rc4-mm2-broken/include/asm-ia64/sparsemem.h
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.12-rc4-mm2-broken/include/asm-ia64/sparsemem.h	2005-05-23 15:14:13.000000000 -0400
@@ -0,0 +1,28 @@
+#ifndef _ASM_IA64_SPARSEMEM_H
+#define _ASM_IA64_SPARSEMEM_H
+
+#ifdef CONFIG_SPARSEMEM
+ /*
+ * SECTION_SIZE_BITS            2^N: how big each section will be
+ * MAX_PHYSADDR_BITS            2^N: how much physical address space we have
+ * MAX_PHYSMEM_BITS             2^N: how much memory we can have in that space
+ */
+
+#define SECTION_SIZE_BITS       CONFIG_SECTION_BITS
+
+/*
+ * If FORCE_MAX_ORDER is used, then check and possibly enforce the boundary
+ * condition on SECTION_SIZE_BITS's magnitude.
+ */
+#ifdef CONFIG_FORCE_MAX_ZONEORDER
+#if ((CONFIG_FORCE_MAX_ZONEORDER - 1 + PAGE_SHIFT) > SECTION_SIZE_BITS)
+#undef SECTION_SIZE_BITS
+#define SECTION_SIZE_BITS	(CONFIG_FORCE_MAX_ZONEORDER - 1 + PAGE_SHIFT)
+#endif
+#endif
+
+#define MAX_PHYSADDR_BITS       CONFIG_PHYSICAL_MEMORY_BITS
+#define MAX_PHYSMEM_BITS        CONFIG_PHYSICAL_MEMORY_BITS
+#endif /* CONFIG_SPARSEMEM */
+
+#endif /* _ASM_IA64_SPARSEMEM_H */
