From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 15 May 2003 17:18:49 +0000
Subject: Re: [Linux-ia64] [PATCH] move mmu_gathers into local_cpu_data
Message-Id: <marc-linux-ia64-105590723705834@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705585@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705585@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 22 April 2003 12:23 pm, Martin Hicks wrote:
> This is a patch that moves mmu_gathers into local_cpu_data on IA64 NUMA.
> I'm not exactly sure where to push this patch, because it does touch
> include/asm-generic/tlb.h although it has no effect on non ia64 arches.

I applied this for 2.4, with a couple minor changes:
	- moved the static mmu_gathers[] declaration to setup.c,
	  so all the mmu_gather stuff is together
	- moved the cpuinfo change outside CONFIG_NUMA,
	  so we can just use the same local_mmu_gathers
	  #define all the time

I'd actually like to see the dynamic mmu_gather allocation done
in the non-NUMA case as well.  Non-NUMA SMP kernels are statically
allocating 128K (NR_CPUS = 32, 4K per mmu_gather_t), but typical
machines will only use 8K or 16K of that.

Here's the actual patch I applied.

#### AUTHOR mort@wildopensource.com
#### COMMENT START
### Comments for ChangeSet
Move mmu_gathers[] to local_cpu_data on ia64.

This is a patch that moves mmu_gathers into local_cpu_data on IA64 NUMA.
I'm not exactly sure where to push this patch, because it does touch
include/asm-generic/tlb.h although it has no effect on non ia64 arches.

The main reason for making this change is that the mmu_gathers array
gets very large as the number of processors increases.
### Comments for include/asm-generic/tlb.h
(local_mmu_gathers): Use if defined.
### Comments for include/asm-ia64/tlb.h
(local_mmu_gathers): Define.
### Comments for arch/ia64/kernel/setup.c
(mmu_gathers[]): Allocate statically for non-NUMA, per present CPU for NUMA.
### Comments for arch/ia64/mm/init.c
(mmu_gathers[]): move to kernel/setup.c alongside NUMA allocation.
### Comments for include/asm-ia64/processor.h
(mmu_gathers): Add to cpuinfo_ia64.
#### COMMENT END

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1145  -> 1.1146 
#	include/asm-generic/tlb.h	1.2     -> 1.3    
#	arch/ia64/kernel/setup.c	1.11    -> 1.12   
#	include/asm-ia64/processor.h	1.16    -> 1.17   
#	include/asm-ia64/tlb.h	1.1     -> 1.2    
#	 arch/ia64/mm/init.c	1.11    -> 1.12   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/05/15	bjorn_helgaas@hp.com	1.1146
# Move mmu_gathers into per cpu area.
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
--- a/arch/ia64/kernel/setup.c	Thu May 15 10:44:50 2003
+++ b/arch/ia64/kernel/setup.c	Thu May 15 10:44:50 2003
@@ -40,6 +40,7 @@
 #include <asm/system.h>
 #include <asm/mca.h>
 #include <asm/smp.h>
+#include <asm/tlb.h>
 
 #ifdef CONFIG_BLK_DEV_RAM
 # include <linux/blk.h>
@@ -58,6 +59,7 @@
  struct cpuinfo_ia64 *boot_cpu_data;
 #else
  struct cpuinfo_ia64 _cpu_data[NR_CPUS] __attribute__ ((section ("__special_page_section")));
+ mmu_gather_t mmu_gathers[NR_CPUS];
 #endif
 
 unsigned long ia64_cycles_per_usec;
@@ -567,6 +569,8 @@
 		for (cpu = 1; cpu < NR_CPUS; ++cpu)
 			memcpy(my_cpu_data->cpu_data[cpu]->cpu_data,
 			       my_cpu_data->cpu_data, sizeof(my_cpu_data->cpu_data));
+		my_cpu_data->mmu_gathers = alloc_bootmem_pages_node(BOOT_NODE_DATA(boot_get_local_cnodeid()),
+								    sizeof(mmu_gather_t));
 	} else {
 		order = get_order(sizeof(struct cpuinfo_ia64));
 		my_cpu_data = page_address(alloc_pages_node(numa_node_id(), GFP_KERNEL, order));
@@ -576,9 +580,14 @@
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
+	my_cpu_data->mmu_gathers = &mmu_gathers[smp_processor_id()];
 #endif
 
 	/*
diff -Nru a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
--- a/arch/ia64/mm/init.c	Thu May 15 10:44:50 2003
+++ b/arch/ia64/mm/init.c	Thu May 15 10:44:50 2003
@@ -26,9 +26,6 @@
 #include <asm/sal.h>
 #include <asm/system.h>
 #include <asm/uaccess.h>
-#include <asm/tlb.h>
-
-mmu_gather_t mmu_gathers[NR_CPUS];
 
 /* References to section boundaries: */
 extern char _stext, _etext, _edata, __init_begin, __init_end;
diff -Nru a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
--- a/include/asm-generic/tlb.h	Thu May 15 10:44:50 2003
+++ b/include/asm-generic/tlb.h	Thu May 15 10:44:50 2003
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
diff -Nru a/include/asm-ia64/processor.h b/include/asm-ia64/processor.h
--- a/include/asm-ia64/processor.h	Thu May 15 10:44:50 2003
+++ b/include/asm-ia64/processor.h	Thu May 15 10:44:50 2003
@@ -168,6 +168,7 @@
 	__u32 ptce_count[2];
 	__u32 ptce_stride[2];
 	struct task_struct *ksoftirqd;	/* kernel softirq daemon for this CPU */
+	void *mmu_gathers;
 # ifdef CONFIG_PERFMON
 	unsigned long pfm_syst_info;
 # endif
diff -Nru a/include/asm-ia64/tlb.h b/include/asm-ia64/tlb.h
--- a/include/asm-ia64/tlb.h	Thu May 15 10:44:50 2003
+++ b/include/asm-ia64/tlb.h	Thu May 15 10:44:50 2003
@@ -1 +1,3 @@
+#define local_mmu_gathers local_cpu_data->mmu_gathers
+
 #include <asm-generic/tlb.h>


