From: Martin Hicks <mort@wildopensource.com>
Date: Tue, 22 Apr 2003 18:23:31 +0000
Subject: [Linux-ia64] [PATCH] move mmu_gathers into local_cpu_data
Message-Id: <marc-linux-ia64-105590723705585@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

This is a patch that moves mmu_gathers into local_cpu_data on IA64 NUMA.
I'm not exactly sure where to push this patch, because it does touch
include/asm-generic/tlb.h although it has no effect on non ia64 arches.

The main reason for making this change is that the mmu_gathers array
gets very large as the number of processors increases.

mh

-- 
Wild Open Source Inc.                  mort@wildopensource.com


diff -X /home/mort/diffex -uNr linux-2.4.21-pre5.pristine/arch/ia64/kernel/setup.c linux-2.4.21-pre5/arch/ia64/kernel/setup.c
--- linux-2.4.21-pre5.pristine/arch/ia64/kernel/setup.c	Sun Mar 30 17:31:07 2003
+++ linux-2.4.21-pre5/arch/ia64/kernel/setup.c	Tue Apr 22 13:22:48 2003
@@ -566,6 +566,8 @@
 		for (cpu = 1; cpu < NR_CPUS; ++cpu)
 			memcpy(my_cpu_data->cpu_data[cpu]->cpu_data,
 			       my_cpu_data->cpu_data, sizeof(my_cpu_data->cpu_data));
+		my_cpu_data->mmu_gathers = alloc_bootmem_pages_node(BOOT_NODE_DATA(boot_get_local_cnodeid()),
+								    sizeof(mmu_gather_t));
 	} else {
 		order = get_order(sizeof(struct cpuinfo_ia64));
 		my_cpu_data = page_address(alloc_pages_node(numa_node_id(), GFP_KERNEL, order));
@@ -575,6 +577,10 @@
 			     order);
 		for (cpu = 0; cpu < NR_CPUS; ++cpu)
 			boot_cpu_data->cpu_data[cpu]->cpu_data[smp_processor_id()] = my_cpu_data;
+
+		my_cpu_data->mmu_gathers = page_address(boot_alloc_pages_node(boot_get_local_cnodeid(),
+									      GFP_KERNEL,
+									      get_order(sizeof(mmu_gather_t)));
 	}
 #else
 	my_cpu_data = cpu_data(smp_processor_id());
diff -X /home/mort/diffex -uNr linux-2.4.21-pre5.pristine/arch/ia64/mm/init.c linux-2.4.21-pre5/arch/ia64/mm/init.c
--- linux-2.4.21-pre5.pristine/arch/ia64/mm/init.c	Sun Mar 30 17:31:07 2003
+++ linux-2.4.21-pre5/arch/ia64/mm/init.c	Tue Apr 22 13:22:48 2003
@@ -28,7 +28,9 @@
 #include <asm/uaccess.h>
 #include <asm/tlb.h>
 
+#ifndef CONFIG_NUMA
 mmu_gather_t mmu_gathers[NR_CPUS];
+#endif
 
 /* References to section boundaries: */
 extern char _stext, _etext, _edata, __init_begin, __init_end;
diff -X /home/mort/diffex -uNr linux-2.4.21-pre5.pristine/include/asm-generic/tlb.h linux-2.4.21-pre5/include/asm-generic/tlb.h
--- linux-2.4.21-pre5.pristine/include/asm-generic/tlb.h	Fri Aug  2 18:39:45 2002
+++ linux-2.4.21-pre5/include/asm-generic/tlb.h	Tue Apr 22 13:24:36 2003
@@ -31,15 +31,18 @@
 	pte_t	ptes[FREE_PTE_NR];
 } mmu_gather_t;
 
+#ifndef local_mmu_gathers
 /* Users of the generic TLB shootdown code must declare this storage space. */
 extern mmu_gather_t	mmu_gathers[NR_CPUS];
+#define local_mmu_gathers	&mmu_gathers[smp_processor_id()]
+#endif
 
 /* tlb_gather_mmu
  *	Return a pointer to an initialized mmu_gather_t.
  */
 static inline mmu_gather_t *tlb_gather_mmu(struct mm_struct *mm)
 {
-	mmu_gather_t *tlb = &mmu_gathers[smp_processor_id()];
+	mmu_gather_t *tlb = local_mmu_gathers;
 
 	tlb->mm = mm;
 	/* Use fast mode if there is only one user of this mm (this process) */
diff -X /home/mort/diffex -uNr linux-2.4.21-pre5.pristine/include/asm-ia64/processor.h linux-2.4.21-pre5/include/asm-ia64/processor.h
--- linux-2.4.21-pre5.pristine/include/asm-ia64/processor.h	Wed Apr 16 17:41:04 2003
+++ linux-2.4.21-pre5/include/asm-ia64/processor.h	Tue Apr 22 13:38:58 2003
@@ -189,6 +189,7 @@
 	void *node_directory;
 	int numa_node_id;
 	struct cpuinfo_ia64 *cpu_data[NR_CPUS];
+        void *mmu_gathers;
 #endif
 	/* Platform specific word.  MUST BE LAST IN STRUCT */
 	__u64 platform_specific;
diff -X /home/mort/diffex -uNr linux-2.4.21-pre5.pristine/include/asm-ia64/tlb.h linux-2.4.21-pre5/include/asm-ia64/tlb.h
--- linux-2.4.21-pre5.pristine/include/asm-ia64/tlb.h	Fri Apr 11 17:56:37 2003
+++ linux-2.4.21-pre5/include/asm-ia64/tlb.h	Tue Apr 22 13:38:59 2003
@@ -1 +1,6 @@
+
+#ifdef CONFIG_NUMA
+#define local_mmu_gathers local_cpu_data->mmu_gathers
+#endif
+
 #include <asm-generic/tlb.h>

