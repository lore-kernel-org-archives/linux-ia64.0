From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 08 Sep 2004 21:47:38 +0000
Subject: [PATCH] general config option cleanup
Message-Id: <200409081447.38703.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_633PBZ5KnSD+M7F"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_633PBZ5KnSD+M7F
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

As threatened, here's a patch that unifies the ia64 memory init and memmap 
codepaths by unconditionalizing the CONFIG_VIRTUAL_MEM_MAP code and making 
CONFIG_DISCONTIGMEM required.  It also allows building with CONFIG_SMP=n 
and/or CONFIG_NUMA=n.  The end result should be easier to understand and hack 
on, and should make things like memory hotplug that much easier since people 
will only have to worry about one code path instead of every combination of 
the three options.

Boot tested on sn2 with:
CONFIG_IA64_SGI_SN=y
CONFIG_NUMA=y
CONFIG_SMP=y
CONFIG_PREEMPT=y
and
CONFIG_IA64_GENERIC=y
CONFIG_NUMA=n
CONFIG_SMP=n
CONFIG_PREEMPT=n

Anyone have a problem with this?  Is it a reasonable thing to do?  Assuming 
everyone is ok with it, there's a bit more I could do to make things easier 
to understand and hack on (and hopefully harder to break), like moving more 
stuff into numa.c and consolidating a header file or two.

 arch/ia64/mm/contig.c            |  300 ------------------------------------
 b/arch/ia64/Kconfig              |   24 ---
 b/arch/ia64/kernel/Makefile      |    1
 b/arch/ia64/kernel/acpi.c        |   24 ++-
 b/arch/ia64/kernel/ia64_ksyms.c  |    2
 b/arch/ia64/kernel/numa.c        |   57 +++++++
 b/arch/ia64/kernel/setup.c       |    2
 b/arch/ia64/kernel/smpboot.c     |   41 -----
 b/arch/ia64/mm/Makefile          |    3
 b/arch/ia64/mm/discontig.c       |   93 ++++++++----
 b/arch/ia64/mm/fault.c           |    5
 b/arch/ia64/mm/init.c            |    5
 b/arch/ia64/mm/numa.c            |    7
 b/arch/ia64/sn/kernel/setup.c    |    1
 b/drivers/acpi/Kconfig           |    1
 b/include/asm-ia64/acpi.h        |    1
 b/include/asm-ia64/meminit.h     |   18 --
 b/include/asm-ia64/mmzone.h      |    5
 b/include/asm-ia64/nodedata.h    |    4
 b/include/asm-ia64/numa.h        |    9 -
 b/include/asm-ia64/page.h        |   16 --
 b/include/asm-ia64/pgtable.h     |   18 --
 b/include/asm-ia64/processor.h   |    4
 b/include/asm-ia64/smp.h         |    1
 b/include/asm-ia64/sn/sn_cpuid.h |    4
 b/include/linux/acpi.h           |    4
 26 files changed, 165 insertions(+), 485 deletions(-)

Thanks,
Jesse


--Boundary-00=_633PBZ5KnSD+M7F
Content-Type: text/plain;
  charset="us-ascii";
  name="ia64-config-cleanup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="ia64-config-cleanup.patch"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/08 14:39:16-07:00 jbarnes@tomahawk.engr.sgi.com 
#   config cleanup
# 
# arch/ia64/kernel/numa.c
#   2004/09/08 14:39:06-07:00 jbarnes@tomahawk.engr.sgi.com +57 -0
# 
# include/linux/acpi.h
#   2004/09/08 14:39:06-07:00 jbarnes@tomahawk.engr.sgi.com +4 -0
#   config cleanup
# 
# include/asm-ia64/sn/sn_cpuid.h
#   2004/09/08 14:39:06-07:00 jbarnes@tomahawk.engr.sgi.com +0 -4
#   config cleanup
# 
# include/asm-ia64/smp.h
#   2004/09/08 14:39:06-07:00 jbarnes@tomahawk.engr.sgi.com +1 -0
#   config cleanup
# 
# include/asm-ia64/processor.h
#   2004/09/08 14:39:06-07:00 jbarnes@tomahawk.engr.sgi.com +1 -3
#   config cleanup
# 
# include/asm-ia64/pgtable.h
#   2004/09/08 14:39:06-07:00 jbarnes@tomahawk.engr.sgi.com +6 -12
#   config cleanup
# 
# include/asm-ia64/page.h
#   2004/09/08 14:39:06-07:00 jbarnes@tomahawk.engr.sgi.com +0 -16
#   config cleanup
# 
# include/asm-ia64/numa.h
#   2004/09/08 14:39:06-07:00 jbarnes@tomahawk.engr.sgi.com +1 -8
#   config cleanup
# 
# include/asm-ia64/nodedata.h
#   2004/09/08 14:39:06-07:00 jbarnes@tomahawk.engr.sgi.com +0 -4
#   config cleanup
# 
# include/asm-ia64/mmzone.h
#   2004/09/08 14:39:06-07:00 jbarnes@tomahawk.engr.sgi.com +0 -5
#   config cleanup
# 
# include/asm-ia64/meminit.h
#   2004/09/08 14:39:06-07:00 jbarnes@tomahawk.engr.sgi.com +6 -12
#   config cleanup
# 
# include/asm-ia64/acpi.h
#   2004/09/08 14:39:06-07:00 jbarnes@tomahawk.engr.sgi.com +1 -0
#   config cleanup
# 
# drivers/acpi/Kconfig
#   2004/09/08 14:39:06-07:00 jbarnes@tomahawk.engr.sgi.com +0 -1
#   config cleanup
# 
# arch/ia64/sn/kernel/setup.c
#   2004/09/08 14:39:06-07:00 jbarnes@tomahawk.engr.sgi.com +1 -0
#   config cleanup
# 
# arch/ia64/mm/numa.c
#   2004/09/08 14:39:06-07:00 jbarnes@tomahawk.engr.sgi.com +0 -7
#   config cleanup
# 
# arch/ia64/mm/init.c
#   2004/09/08 14:39:06-07:00 jbarnes@tomahawk.engr.sgi.com +0 -5
#   config cleanup
# 
# arch/ia64/mm/fault.c
#   2004/09/08 14:39:06-07:00 jbarnes@tomahawk.engr.sgi.com +1 -4
#   config cleanup
# 
# arch/ia64/kernel/numa.c
#   2004/09/08 14:39:06-07:00 jbarnes@tomahawk.engr.sgi.com +0 -0
#   BitKeeper file /home/jbarnes/working/linux-2.5-numa2/arch/ia64/kernel/numa.c
# 
# arch/ia64/mm/discontig.c
#   2004/09/08 14:39:05-07:00 jbarnes@tomahawk.engr.sgi.com +62 -31
#   config cleanup
# 
# arch/ia64/mm/Makefile
#   2004/09/08 14:39:05-07:00 jbarnes@tomahawk.engr.sgi.com +0 -3
#   config cleanup
# 
# arch/ia64/kernel/smpboot.c
#   2004/09/08 14:39:05-07:00 jbarnes@tomahawk.engr.sgi.com +0 -41
#   config cleanup
# 
# arch/ia64/kernel/setup.c
#   2004/09/08 14:39:05-07:00 jbarnes@tomahawk.engr.sgi.com +0 -2
#   config cleanup
# 
# arch/ia64/kernel/ia64_ksyms.c
#   2004/09/08 14:39:05-07:00 jbarnes@tomahawk.engr.sgi.com +0 -2
#   config cleanup
# 
# arch/ia64/kernel/acpi.c
#   2004/09/08 14:39:05-07:00 jbarnes@tomahawk.engr.sgi.com +21 -3
#   config cleanup
# 
# arch/ia64/kernel/Makefile
#   2004/09/08 14:39:05-07:00 jbarnes@tomahawk.engr.sgi.com +1 -0
#   config cleanup
# 
# arch/ia64/Kconfig
#   2004/09/08 14:39:05-07:00 jbarnes@tomahawk.engr.sgi.com +2 -22
#   config cleanup
# 
# BitKeeper/deleted/.del-contig.c~11b5d4e44ee69f76
#   2004/09/08 14:20:21-07:00 jbarnes@tomahawk.engr.sgi.com +0 -0
#   Delete: arch/ia64/mm/contig.c
# 
diff -Nru a/arch/ia64/Kconfig b/arch/ia64/Kconfig
--- a/arch/ia64/Kconfig	2004-09-08 14:39:48 -07:00
+++ b/arch/ia64/Kconfig	2004-09-08 14:39:48 -07:00
@@ -44,10 +44,6 @@
 
 config IA64_GENERIC
 	bool "generic"
-	select NUMA
-	select ACPI_NUMA
-	select VIRTUAL_MEM_MAP
-	select DISCONTIGMEM
 	help
 	  This selects the system type of your hardware.  A "generic" kernel
 	  will run on any supported IA-64 system.  However, if you configure
@@ -158,25 +154,9 @@
 	  Access).  This option is for configuring high-end multiprocessor
 	  server systems.  If in doubt, say N.
 
-config VIRTUAL_MEM_MAP
-	bool "Virtual mem map"
-	default y if !IA64_HP_SIM
-	help
-	  Say Y to compile the kernel with support for a virtual mem map.
-	  This code also only takes effect if a memory hole of greater than
-	  1 Gb is found during boot.  You must turn this option on if you
-	  require the DISCONTIGMEM option for your machine. If you are
-	  unsure, say Y.
-
 config DISCONTIGMEM
-	bool "Discontiguous memory support"
-	depends on (IA64_DIG || IA64_SGI_SN2 || IA64_GENERIC || IA64_HP_ZX1) && NUMA && VIRTUAL_MEM_MAP
-	default y if (IA64_SGI_SN2 || IA64_GENERIC) && NUMA
-	help
-	  Say Y to support efficient handling of discontiguous physical memory,
-	  for architectures which are either NUMA (Non-Uniform Memory Access)
-	  or have huge holes in the physical address space for other reasons.
-	  See <file:Documentation/vm/numa> for more.
+	bool
+	default y
 
 config IA64_CYCLONE
 	bool "Cyclone (EXA) Time Source support"
diff -Nru a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
--- a/arch/ia64/kernel/Makefile	2004-09-08 14:39:48 -07:00
+++ b/arch/ia64/kernel/Makefile	2004-09-08 14:39:48 -07:00
@@ -15,6 +15,7 @@
 obj-$(CONFIG_IOSAPIC)		+= iosapic.o
 obj-$(CONFIG_MODULES)		+= module.o
 obj-$(CONFIG_SMP)		+= smp.o smpboot.o
+obj-$(CONFIG_NUMA)		+= numa.o
 obj-$(CONFIG_PERFMON)		+= perfmon_default_smpl.o
 obj-$(CONFIG_IA64_CYCLONE)	+= cyclone.o
 
diff -Nru a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
--- a/arch/ia64/kernel/acpi.c	2004-09-08 14:39:48 -07:00
+++ b/arch/ia64/kernel/acpi.c	2004-09-08 14:39:48 -07:00
@@ -359,6 +359,17 @@
 /* maps to convert between proximity domain and logical node ID */
 int __initdata pxm_to_nid_map[MAX_PXM_DOMAINS];
 int __initdata nid_to_pxm_map[MAX_NUMNODES];
+
+/*
+ * The following structures are usually initialized by ACPI or
+ * similar mechanisms and describe the NUMA characteristics of the machine.
+ */
+int num_node_memblks;
+struct node_memblk_s node_memblk[NR_NODE_MEMBLKS];
+struct node_cpuid_s node_cpuid[NR_CPUS];
+
+#ifdef CONFIG_NUMA
+
 static struct acpi_table_slit __initdata *slit_table;
 
 /*
@@ -380,6 +391,7 @@
 	}
 	slit_table = slit;
 }
+#endif
 
 void __init
 acpi_numa_processor_affinity_init (struct acpi_table_processor_affinity *pa)
@@ -434,7 +446,10 @@
 void __init
 acpi_numa_arch_fixup (void)
 {
-	int i, j, node_from, node_to;
+	int i, j;
+#ifdef CONFIG_NUMA
+	int node_from, node_to;
+#endif
 
 	/* If there's no SRAT, fix the phys_id */
 	if (srat_num_cpus == 0) {
@@ -475,7 +490,7 @@
 
 	printk(KERN_INFO "Number of logical nodes in system = %d\n", numnodes);
 	printk(KERN_INFO "Number of memory chunks in system = %d\n", num_node_memblks);
-
+#ifdef CONFIG_NUMA
 	if (!slit_table) return;
 	memset(numa_slit, -1, sizeof(numa_slit));
 	for (i=0; i<slit_table->localities; i++) {
@@ -490,6 +505,7 @@
 				slit_table->entry[i*slit_table->localities + j];
 		}
 	}
+#endif
 
 #ifdef SLIT_DEBUG
 	printk("ACPI 2.0 SLIT locality table:\n");
@@ -624,8 +640,10 @@
 			if (smp_boot_data.cpu_phys_id[cpu] != hard_smp_processor_id())
 				node_cpuid[i++].phys_id = smp_boot_data.cpu_phys_id[cpu];
 	}
-	build_cpu_to_node_map();
 # endif
+#endif
+#ifdef CONFIG_NUMA
+	build_cpu_to_node_map();
 #endif
 	/* Make boot-up look pretty */
 	printk(KERN_INFO "%d CPUs available, %d CPUs total\n", available_cpus, total_cpus);
diff -Nru a/arch/ia64/kernel/ia64_ksyms.c b/arch/ia64/kernel/ia64_ksyms.c
--- a/arch/ia64/kernel/ia64_ksyms.c	2004-09-08 14:39:48 -07:00
+++ b/arch/ia64/kernel/ia64_ksyms.c	2004-09-08 14:39:48 -07:00
@@ -40,10 +40,8 @@
 #include <asm/page.h>
 EXPORT_SYMBOL(clear_page);
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
 #include <linux/bootmem.h>
 EXPORT_SYMBOL(max_low_pfn);	/* defined by bootmem.c, but not exported by generic code */
-#endif
 
 #include <asm/processor.h>
 EXPORT_SYMBOL(per_cpu__cpu_info);
diff -Nru a/arch/ia64/kernel/numa.c b/arch/ia64/kernel/numa.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/arch/ia64/kernel/numa.c	2004-09-08 14:39:48 -07:00
@@ -0,0 +1,57 @@
+/*
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ * ia64 kernel NUMA specific stuff
+ *
+ * Copyright (C) 2002 Erich Focht <efocht@ess.nec.de>
+ * Copyright (C) 2004 Silicon Graphics, Inc.
+ *   Jesse Barnes <jbarnes@sgi.com>
+ */
+#include <linux/config.h>
+#include <linux/topology.h>
+#include <linux/module.h>
+#include <asm/processor.h>
+#include <asm/smp.h>
+
+u8 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
+EXPORT_SYMBOL(cpu_to_node_map);
+
+cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
+
+/**
+ * build_cpu_to_node_map - setup cpu to node and node to cpumask arrays
+ *
+ * Build cpu to node mapping and initialize the per node cpu masks using
+ * info from the node_cpuid array handed to us by ACPI.
+ */
+void __init build_cpu_to_node_map(void)
+{
+	int cpu, i, node;
+
+	for(node=0; node < MAX_NUMNODES; node++)
+		cpus_clear(node_to_cpu_mask[node]);
+
+	for(cpu = 0; cpu < NR_CPUS; ++cpu) {
+		node = -1;
+		for (i = 0; i < NR_CPUS; ++i)
+			if (cpu_physical_id(cpu) == node_cpuid[i].phys_id) {
+				node = node_cpuid[i].nid;
+				break;
+			}
+		cpu_to_node_map[cpu] = (node >= 0) ? node : 0;
+		if (node >= 0)
+			cpu_set(cpu, node_to_cpu_mask[node]);
+	}
+}
diff -Nru a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
--- a/arch/ia64/kernel/setup.c	2004-09-08 14:39:48 -07:00
+++ b/arch/ia64/kernel/setup.c	2004-09-08 14:39:48 -07:00
@@ -317,11 +317,9 @@
 	machvec_init(acpi_get_sysname());
 #endif
 
-#ifdef CONFIG_SMP
 	/* If we register an early console, allow CPU 0 to printk */
 	if (!early_console_setup())
 		cpu_set(smp_processor_id(), cpu_online_map);
-#endif
 
 #ifdef CONFIG_ACPI_BOOT
 	/* Initialize the ACPI boot-time table parser */
diff -Nru a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
--- a/arch/ia64/kernel/smpboot.c	2004-09-08 14:39:48 -07:00
+++ b/arch/ia64/kernel/smpboot.c	2004-09-08 14:39:48 -07:00
@@ -478,47 +478,6 @@
 	}
 }
 
-#ifdef CONFIG_NUMA
-
-/* on which node is each logical CPU (one cacheline even for 64 CPUs) */
-u8 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
-EXPORT_SYMBOL(cpu_to_node_map);
-/* which logical CPUs are on which nodes */
-cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
-
-/*
- * Build cpu to node mapping and initialize the per node cpu masks.
- */
-void __init
-build_cpu_to_node_map (void)
-{
-	int cpu, i, node;
-
-	for(node=0; node<MAX_NUMNODES; node++)
-		cpus_clear(node_to_cpu_mask[node]);
-	for(cpu = 0; cpu < NR_CPUS; ++cpu) {
-		/*
-		 * All Itanium NUMA platforms I know use ACPI, so maybe we
-		 * can drop this ifdef completely.                    [EF]
-		 */
-#ifdef CONFIG_ACPI_NUMA
-		node = -1;
-		for (i = 0; i < NR_CPUS; ++i)
-			if (cpu_physical_id(cpu) == node_cpuid[i].phys_id) {
-				node = node_cpuid[i].nid;
-				break;
-			}
-#else
-#		error Fixme: Dunno how to build CPU-to-node map.
-#endif
-		cpu_to_node_map[cpu] = (node >= 0) ? node : 0;
-		if (node >= 0)
-			cpu_set(cpu, node_to_cpu_mask[node]);
-	}
-}
-
-#endif /* CONFIG_NUMA */
-
 /*
  * Cycle through the APs sending Wakeup IPIs to boot each.
  */
diff -Nru a/arch/ia64/mm/Makefile b/arch/ia64/mm/Makefile
--- a/arch/ia64/mm/Makefile	2004-09-08 14:39:48 -07:00
+++ b/arch/ia64/mm/Makefile	2004-09-08 14:39:48 -07:00
@@ -7,6 +7,3 @@
 obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
 obj-$(CONFIG_NUMA)	   += numa.o
 obj-$(CONFIG_DISCONTIGMEM) += discontig.o
-ifndef CONFIG_DISCONTIGMEM
-obj-y += contig.o
-endif
diff -Nru a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
--- a/arch/ia64/mm/contig.c	2004-09-08 14:39:48 -07:00
+++ /dev/null	Wed Dec 31 16:00:00 196900
@@ -1,300 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (C) 1998-2003 Hewlett-Packard Co
- *	David Mosberger-Tang <davidm@hpl.hp.com>
- *	Stephane Eranian <eranian@hpl.hp.com>
- * Copyright (C) 2000, Rohit Seth <rohit.seth@intel.com>
- * Copyright (C) 1999 VA Linux Systems
- * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
- * Copyright (C) 2003 Silicon Graphics, Inc. All rights reserved.
- *
- * Routines used by ia64 machines with contiguous (or virtually contiguous)
- * memory.
- */
-#include <linux/config.h>
-#include <linux/bootmem.h>
-#include <linux/efi.h>
-#include <linux/mm.h>
-#include <linux/swap.h>
-
-#include <asm/meminit.h>
-#include <asm/pgalloc.h>
-#include <asm/pgtable.h>
-#include <asm/sections.h>
-
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-static unsigned long num_dma_physpages;
-#endif
-
-/**
- * show_mem - display a memory statistics summary
- *
- * Just walks the pages in the system and describes where they're allocated.
- */
-void
-show_mem (void)
-{
-	int i, total = 0, reserved = 0;
-	int shared = 0, cached = 0;
-
-	printk("Mem-info:\n");
-	show_free_areas();
-
-	printk("Free swap:       %6ldkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
-	i = max_mapnr;
-	while (i-- > 0) {
-		if (!pfn_valid(i))
-			continue;
-		total++;
-		if (PageReserved(mem_map+i))
-			reserved++;
-		else if (PageSwapCache(mem_map+i))
-			cached++;
-		else if (page_count(mem_map + i))
-			shared += page_count(mem_map + i) - 1;
-	}
-	printk("%d pages of RAM\n", total);
-	printk("%d reserved pages\n", reserved);
-	printk("%d pages shared\n", shared);
-	printk("%d pages swap cached\n", cached);
-	printk("%ld pages in page table cache\n", pgtable_cache_size);
-}
-
-/* physical address where the bootmem map is located */
-unsigned long bootmap_start;
-
-/**
- * find_max_pfn - adjust the maximum page number callback
- * @start: start of range
- * @end: end of range
- * @arg: address of pointer to global max_pfn variable
- *
- * Passed as a callback function to efi_memmap_walk() to determine the highest
- * available page frame number in the system.
- */
-int
-find_max_pfn (unsigned long start, unsigned long end, void *arg)
-{
-	unsigned long *max_pfnp = arg, pfn;
-
-	pfn = (PAGE_ALIGN(end - 1) - PAGE_OFFSET) >> PAGE_SHIFT;
-	if (pfn > *max_pfnp)
-		*max_pfnp = pfn;
-	return 0;
-}
-
-/**
- * find_bootmap_location - callback to find a memory area for the bootmap
- * @start: start of region
- * @end: end of region
- * @arg: unused callback data
- *
- * Find a place to put the bootmap and return its starting address in
- * bootmap_start.  This address must be page-aligned.
- */
-int
-find_bootmap_location (unsigned long start, unsigned long end, void *arg)
-{
-	unsigned long needed = *(unsigned long *)arg;
-	unsigned long range_start, range_end, free_start;
-	int i;
-
-#if IGNORE_PFN0
-	if (start == PAGE_OFFSET) {
-		start += PAGE_SIZE;
-		if (start >= end)
-			return 0;
-	}
-#endif
-
-	free_start = PAGE_OFFSET;
-
-	for (i = 0; i < num_rsvd_regions; i++) {
-		range_start = max(start, free_start);
-		range_end   = min(end, rsvd_region[i].start & PAGE_MASK);
-
-		free_start = PAGE_ALIGN(rsvd_region[i].end);
-
-		if (range_end <= range_start)
-			continue; /* skip over empty range */
-
-		if (range_end - range_start >= needed) {
-			bootmap_start = __pa(range_start);
-			return -1;	/* done */
-		}
-
-		/* nothing more available in this segment */
-		if (range_end == end)
-			return 0;
-	}
-	return 0;
-}
-
-/**
- * find_memory - setup memory map
- *
- * Walk the EFI memory map and find usable memory for the system, taking
- * into account reserved areas.
- */
-void
-find_memory (void)
-{
-	unsigned long bootmap_size;
-
-	reserve_memory();
-
-	/* first find highest page frame number */
-	max_pfn = 0;
-	efi_memmap_walk(find_max_pfn, &max_pfn);
-
-	/* how many bytes to cover all the pages */
-	bootmap_size = bootmem_bootmap_pages(max_pfn) << PAGE_SHIFT;
-
-	/* look for a location to hold the bootmap */
-	bootmap_start = ~0UL;
-	efi_memmap_walk(find_bootmap_location, &bootmap_size);
-	if (bootmap_start == ~0UL)
-		panic("Cannot find %ld bytes for bootmap\n", bootmap_size);
-
-	bootmap_size = init_bootmem(bootmap_start >> PAGE_SHIFT, max_pfn);
-
-	/* Free all available memory, then mark bootmem-map as being in use. */
-	efi_memmap_walk(filter_rsvd_memory, free_bootmem);
-	reserve_bootmem(bootmap_start, bootmap_size);
-
-	find_initrd();
-}
-
-#ifdef CONFIG_SMP
-/**
- * per_cpu_init - setup per-cpu variables
- *
- * Allocate and setup per-cpu data areas.
- */
-void *
-per_cpu_init (void)
-{
-	void *cpu_data;
-	int cpu;
-
-	/*
-	 * get_free_pages() cannot be used before cpu_init() done.  BSP
-	 * allocates "NR_CPUS" pages for all CPUs to avoid that AP calls
-	 * get_zeroed_page().
-	 */
-	if (smp_processor_id() == 0) {
-		cpu_data = __alloc_bootmem(PERCPU_PAGE_SIZE * NR_CPUS,
-					   PERCPU_PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
-		for (cpu = 0; cpu < NR_CPUS; cpu++) {
-			memcpy(cpu_data, __phys_per_cpu_start, __per_cpu_end - __per_cpu_start);
-			__per_cpu_offset[cpu] = (char *) cpu_data - __per_cpu_start;
-			cpu_data += PERCPU_PAGE_SIZE;
-			per_cpu(local_per_cpu_offset, cpu) = __per_cpu_offset[cpu];
-		}
-	}
-	return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
-}
-#endif /* CONFIG_SMP */
-
-static int
-count_pages (u64 start, u64 end, void *arg)
-{
-	unsigned long *count = arg;
-
-	*count += (end - start) >> PAGE_SHIFT;
-	return 0;
-}
-
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-static int
-count_dma_pages (u64 start, u64 end, void *arg)
-{
-	unsigned long *count = arg;
-
-	if (end <= MAX_DMA_ADDRESS)
-		*count += (end - start) >> PAGE_SHIFT;
-	return 0;
-}
-#endif
-
-/*
- * Set up the page tables.
- */
-
-void
-paging_init (void)
-{
-	unsigned long max_dma;
-	unsigned long zones_size[MAX_NR_ZONES];
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-	unsigned long zholes_size[MAX_NR_ZONES];
-	unsigned long max_gap;
-#endif
-
-	/* initialize mem_map[] */
-
-	memset(zones_size, 0, sizeof(zones_size));
-
-	num_physpages = 0;
-	efi_memmap_walk(count_pages, &num_physpages);
-
-	max_dma = virt_to_phys((void *) MAX_DMA_ADDRESS) >> PAGE_SHIFT;
-
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-	memset(zholes_size, 0, sizeof(zholes_size));
-
-	num_dma_physpages = 0;
-	efi_memmap_walk(count_dma_pages, &num_dma_physpages);
-
-	if (max_low_pfn < max_dma) {
-		zones_size[ZONE_DMA] = max_low_pfn;
-		zholes_size[ZONE_DMA] = max_low_pfn - num_dma_physpages;
-	} else {
-		zones_size[ZONE_DMA] = max_dma;
-		zholes_size[ZONE_DMA] = max_dma - num_dma_physpages;
-		if (num_physpages > num_dma_physpages) {
-			zones_size[ZONE_NORMAL] = max_low_pfn - max_dma;
-			zholes_size[ZONE_NORMAL] =
-				((max_low_pfn - max_dma) -
-				 (num_physpages - num_dma_physpages));
-		}
-	}
-
-	max_gap = 0;
-	efi_memmap_walk(find_largest_hole, (u64 *)&max_gap);
-	if (max_gap < LARGE_GAP) {
-		vmem_map = (struct page *) 0;
-		free_area_init_node(0, &contig_page_data, zones_size, 0,
-				    zholes_size);
-		mem_map = contig_page_data.node_mem_map;
-	} else {
-		unsigned long map_size;
-
-		/* allocate virtual_mem_map */
-
-		map_size = PAGE_ALIGN(max_low_pfn * sizeof(struct page));
-		vmalloc_end -= map_size;
-		vmem_map = (struct page *) vmalloc_end;
-		efi_memmap_walk(create_mem_map_page_table, 0);
-
-		contig_page_data.node_mem_map = vmem_map;
-		free_area_init_node(0, &contig_page_data, zones_size,
-				    0, zholes_size);
-
-		mem_map = contig_page_data.node_mem_map;
-		printk("Virtual mem_map starts at 0x%p\n", mem_map);
-	}
-#else /* !CONFIG_VIRTUAL_MEM_MAP */
-	if (max_low_pfn < max_dma)
-		zones_size[ZONE_DMA] = max_low_pfn;
-	else {
-		zones_size[ZONE_DMA] = max_dma;
-		zones_size[ZONE_NORMAL] = max_low_pfn - max_dma;
-	}
-	free_area_init(zones_size);
-#endif /* !CONFIG_VIRTUAL_MEM_MAP */
-	zero_page_memmap_ptr = virt_to_page(ia64_imva(empty_zero_page));
-}
diff -Nru a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
--- a/arch/ia64/mm/discontig.c	2004-09-08 14:39:48 -07:00
+++ b/arch/ia64/mm/discontig.c	2004-09-08 14:39:48 -07:00
@@ -9,7 +9,7 @@
 /*
  * Platform initialization for Discontig Memory
  */
-
+#include <linux/config.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
 #include <linux/swap.h>
@@ -40,6 +40,7 @@
 
 static struct early_node_data mem_data[NR_NODES] __initdata;
 
+#ifdef CONFIG_NUMA
 /**
  * reassign_cpu_only_nodes - called from find_memory to move CPU-only nodes to a memory node
  *
@@ -161,13 +162,16 @@
 
 	return;
 }
+#else
+static void __init reassign_cpu_only_nodes(void) { }
+#endif /* CONFIG_NUMA */
 
 /*
  * To prevent cache aliasing effects, align per-node structures so that they
  * start at addresses that are strided by node number.
  */
-#define NODEDATA_ALIGN(addr, node)						\
-	((((addr) + 1024*1024-1) & ~(1024*1024-1)) + (node)*PERCPU_PAGE_SIZE)
+#define NODEDATA_ALIGN(addr, node) ((((addr) + 1024*1024-1) & \
+	~(1024*1024-1)) + (node)*PERCPU_PAGE_SIZE)
 
 /**
  * build_node_maps - callback to setup bootmem structs for each node
@@ -213,7 +217,7 @@
  * acpi_boot_init() (which builds the node_to_cpu_mask array) hasn't been
  * called yet.
  */
-static int early_nr_cpus_node(int node)
+static int __init early_nr_cpus_node(int node)
 {
 	int cpu, n = 0;
 
@@ -225,6 +229,33 @@
 }
 
 /**
+ * per_cpu_node_setup - setup per-cpu areas on each node
+ * @cpu_data: per-cpu area on this node
+ * @node: node to setup
+ *
+ * Copy the static per-cpu data into the region we just set aside and then
+ * setup __per_cpu_offset for each CPU on this node.  Return a pointer to
+ * the end of the area.
+ */
+static void __init *per_cpu_node_setup(void *cpu_data, int node)
+{
+#ifdef CONFIG_SMP
+	int cpu;
+
+	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+		if (node == node_cpuid[cpu].nid) {
+			memcpy(__va(cpu_data), __phys_per_cpu_start,
+			       __per_cpu_end - __per_cpu_start);
+			__per_cpu_offset[cpu] = (char*)__va(cpu_data) -
+				__per_cpu_start;
+			cpu_data += PERCPU_PAGE_SIZE;
+		}
+	}
+#endif
+	return cpu_data;
+}
+
+/**
  * find_pernode_space - allocate memory for memory map and per-node structures
  * @start: physical start of range
  * @len: length of range
@@ -255,7 +286,7 @@
 static int __init find_pernode_space(unsigned long start, unsigned long len,
 				     int node)
 {
-	unsigned long epfn, cpu, cpus;
+	unsigned long epfn, cpus;
 	unsigned long pernodesize = 0, pernode, pages, mapsize;
 	void *cpu_data;
 	struct bootmem_data *bdp = &mem_data[node].bootmem_data;
@@ -305,20 +336,7 @@
 		mem_data[node].pgdat->bdata = bdp;
 		pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
 
-		/*
-		 * Copy the static per-cpu data into the region we
-		 * just set aside and then setup __per_cpu_offset
-		 * for each CPU on this node.
-		 */
-		for (cpu = 0; cpu < NR_CPUS; cpu++) {
-			if (node == node_cpuid[cpu].nid) {
-				memcpy(__va(cpu_data), __phys_per_cpu_start,
-				       __per_cpu_end - __per_cpu_start);
-				__per_cpu_offset[cpu] = (char*)__va(cpu_data) -
-					__per_cpu_start;
-				cpu_data += PERCPU_PAGE_SIZE;
-			}
-		}
+		cpu_data = per_cpu_node_setup(cpu_data, node);
 	}
 
 	return 0;
@@ -384,8 +402,8 @@
  */
 static void __init initialize_pernode_data(void)
 {
-	int cpu, node;
 	pg_data_t *pgdat_list[NR_NODES];
+	int cpu, node;
 
 	for (node = 0; node < numnodes; node++)
 		pgdat_list[node] = mem_data[node].pgdat;
@@ -395,12 +413,22 @@
 		memcpy(mem_data[node].node_data->pg_data_ptrs, pgdat_list,
 		       sizeof(pgdat_list));
 	}
-
+#ifdef CONFIG_SMP
 	/* Set the node_data pointer for each per-cpu struct */
 	for (cpu = 0; cpu < NR_CPUS; cpu++) {
 		node = node_cpuid[cpu].nid;
 		per_cpu(cpu_info, cpu).node_data = mem_data[node].node_data;
 	}
+#else
+	{
+		struct cpuinfo_ia64 *cpu0_cpu_info;
+		cpu = 0;
+		node = node_cpuid[cpu].nid;
+		cpu0_cpu_info = (struct cpuinfo_ia64 *)(__phys_per_cpu_start +
+			((char *)&per_cpu__cpu_info - __per_cpu_start));
+		cpu0_cpu_info->node_data = mem_data[node].node_data;
+	}
+#endif /* CONFIG_SMP */
 }
 
 /**
@@ -464,25 +492,26 @@
 	find_initrd();
 }
 
+#ifdef CONFIG_SMP
 /**
  * per_cpu_init - setup per-cpu variables
  *
  * find_pernode_space() does most of this already, we just need to set
  * local_per_cpu_offset
  */
-void *per_cpu_init(void)
+void __init *per_cpu_init(void)
 {
 	int cpu;
 
-	if (smp_processor_id() == 0) {
-		for (cpu = 0; cpu < NR_CPUS; cpu++) {
-			per_cpu(local_per_cpu_offset, cpu) =
-				__per_cpu_offset[cpu];
-		}
-	}
+	if (smp_processor_id() != 0)
+		return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
+
+	for (cpu = 0; cpu < NR_CPUS; cpu++)
+		per_cpu(local_per_cpu_offset, cpu) = __per_cpu_offset[cpu];
 
 	return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
 }
+#endif /* CONFIG_SMP */
 
 /**
  * show_mem - give short summary of memory stats
@@ -533,7 +562,8 @@
  * Take this opportunity to round the start address up and the end address
  * down to page boundaries.
  */
-void call_pernode_memory(unsigned long start, unsigned long len, void *arg)
+void __init call_pernode_memory(unsigned long start, unsigned long len,
+				void *arg)
 {
 	unsigned long rs, re, end = start + len;
 	void (*func)(unsigned long, unsigned long, int);
@@ -577,7 +607,8 @@
  * for each piece of usable memory and will setup these values for each node.
  * Very similar to build_maps().
  */
-static int count_node_pages(unsigned long start, unsigned long len, int node)
+static int __init count_node_pages(unsigned long start, unsigned long len,
+				   int node)
 {
 	unsigned long end = start + len;
 
@@ -602,7 +633,7 @@
  * paging_init() sets up the page tables for each node of the system and frees
  * the bootmem allocator memory for general use.
  */
-void paging_init(void)
+void __init paging_init(void)
 {
 	unsigned long max_dma;
 	unsigned long zones_size[MAX_NR_ZONES];
diff -Nru a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
--- a/arch/ia64/mm/fault.c	2004-09-08 14:39:48 -07:00
+++ b/arch/ia64/mm/fault.c	2004-09-08 14:39:48 -07:00
@@ -85,7 +85,6 @@
 	if (in_atomic() || !mm)
 		goto no_context;
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
 	/*
 	 * If fault is in region 5 and we are in the kernel, we may already
 	 * have the mmap_sem (pfn_valid macro is called during mmap). There
@@ -95,7 +94,6 @@
 
 	if ((REGION_NUMBER(address) == 5) && !user_mode(regs))
 		goto bad_area_no_up;
-#endif
 
 	down_read(&mm->mmap_sem);
 
@@ -178,9 +176,8 @@
 
   bad_area:
 	up_read(&mm->mmap_sem);
-#ifdef CONFIG_VIRTUAL_MEM_MAP
+
   bad_area_no_up:
-#endif
 	if ((isr & IA64_ISR_SP)
 	    || ((isr & IA64_ISR_NA) && (isr & IA64_ISR_CODE_MASK) == IA64_ISR_CODE_LFETCH))
 	{
diff -Nru a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
--- a/arch/ia64/mm/init.c	2004-09-08 14:39:48 -07:00
+++ b/arch/ia64/mm/init.c	2004-09-08 14:39:48 -07:00
@@ -43,12 +43,10 @@
 
 unsigned long MAX_DMA_ADDRESS = PAGE_OFFSET + 0x100000000UL;
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
 unsigned long vmalloc_end = VMALLOC_END_INIT;
 EXPORT_SYMBOL(vmalloc_end);
 struct page *vmem_map;
 EXPORT_SYMBOL(vmem_map);
-#endif
 
 static int pgt_cache_water[2] = { 25, 50 };
 
@@ -360,8 +358,6 @@
 	ia64_mca_tlb_list[cpu].ptce_stride[1] = local_cpu_data->ptce_stride[1];
 }
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-
 int
 create_mem_map_page_table (u64 start, u64 end, void *arg)
 {
@@ -480,7 +476,6 @@
 	last_end = end;
 	return 0;
 }
-#endif /* CONFIG_VIRTUAL_MEM_MAP */
 
 static int
 count_reserved_pages (u64 start, u64 end, void *arg)
diff -Nru a/arch/ia64/mm/numa.c b/arch/ia64/mm/numa.c
--- a/arch/ia64/mm/numa.c	2004-09-08 14:39:48 -07:00
+++ b/arch/ia64/mm/numa.c	2004-09-08 14:39:48 -07:00
@@ -24,13 +24,6 @@
 static struct cpu *sysfs_cpus;
 
 /*
- * The following structures are usually initialized by ACPI or
- * similar mechanisms and describe the NUMA characteristics of the machine.
- */
-int num_node_memblks;
-struct node_memblk_s node_memblk[NR_NODE_MEMBLKS];
-struct node_cpuid_s node_cpuid[NR_CPUS];
-/*
  * This is a matrix with "distances" between nodes, they should be
  * proportional to the memory access latency ratios.
  */
diff -Nru a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
--- a/arch/ia64/sn/kernel/setup.c	2004-09-08 14:39:48 -07:00
+++ b/arch/ia64/sn/kernel/setup.c	2004-09-08 14:39:48 -07:00
@@ -29,6 +29,7 @@
 #include <linux/sched.h>
 #include <linux/root_dev.h>
 
+#include <asm/acpi.h>
 #include <asm/io.h>
 #include <asm/sal.h>
 #include <asm/machvec.h>
diff -Nru a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
--- a/drivers/acpi/Kconfig	2004-09-08 14:39:48 -07:00
+++ b/drivers/acpi/Kconfig	2004-09-08 14:39:48 -07:00
@@ -142,7 +142,6 @@
 config ACPI_NUMA
 	bool "NUMA support"
 	depends on ACPI_INTERPRETER
-	depends on NUMA
 	depends on IA64
 	default y if IA64_GENERIC || IA64_SGI_SN2
 
diff -Nru a/include/asm-ia64/acpi.h b/include/asm-ia64/acpi.h
--- a/include/asm-ia64/acpi.h	2004-09-08 14:39:48 -07:00
+++ b/include/asm-ia64/acpi.h	2004-09-08 14:39:48 -07:00
@@ -30,6 +30,7 @@
 
 #ifdef __KERNEL__
 
+#include <linux/config.h>
 #include <linux/init.h>
 #include <linux/numa.h>
 #include <asm/system.h>
diff -Nru a/include/asm-ia64/meminit.h b/include/asm-ia64/meminit.h
--- a/include/asm-ia64/meminit.h	2004-09-08 14:39:48 -07:00
+++ b/include/asm-ia64/meminit.h	2004-09-08 14:39:48 -07:00
@@ -41,20 +41,14 @@
 #define GRANULEROUNDUP(n)	(((n)+IA64_GRANULE_SIZE-1) & ~(IA64_GRANULE_SIZE-1))
 #define ORDERROUNDDOWN(n)	((n) & ~((PAGE_SIZE<<MAX_ORDER)-1))
 
-#ifdef CONFIG_DISCONTIGMEM
-  extern void call_pernode_memory (unsigned long start, unsigned long len, void *func);
-#else
-# define call_pernode_memory(start, len, func)	(*func)(start, len, 0)
-#endif
+extern void call_pernode_memory (unsigned long start, unsigned long len, void *func);
 
 #define IGNORE_PFN0	1	/* XXX fix me: ignore pfn 0 until TLB miss handler is updated... */
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-# define LARGE_GAP	0x40000000 /* Use virtual mem map if hole is > than this */
-  extern unsigned long vmalloc_end;
-  extern struct page *vmem_map;
-  extern int find_largest_hole (u64 start, u64 end, void *arg);
-  extern int create_mem_map_page_table (u64 start, u64 end, void *arg);
-#endif
+#define LARGE_GAP	0x40000000 /* Use virtual mem map if hole is > than this */
+extern unsigned long vmalloc_end;
+extern struct page *vmem_map;
+extern int find_largest_hole (u64 start, u64 end, void *arg);
+extern int create_mem_map_page_table (u64 start, u64 end, void *arg);
 
 #endif /* meminit_h */
diff -Nru a/include/asm-ia64/mmzone.h b/include/asm-ia64/mmzone.h
--- a/include/asm-ia64/mmzone.h	2004-09-08 14:39:48 -07:00
+++ b/include/asm-ia64/mmzone.h	2004-09-08 14:39:48 -07:00
@@ -15,8 +15,6 @@
 #include <asm/page.h>
 #include <asm/meminit.h>
 
-#ifdef CONFIG_DISCONTIGMEM
-
 #ifdef CONFIG_IA64_DIG /* DIG systems are small */
 # define MAX_PHYSNODE_ID	8
 # define NR_NODES		8
@@ -33,7 +31,4 @@
 #define page_to_pfn(page)	((unsigned long) (page - vmem_map))
 #define pfn_to_page(pfn)	(vmem_map + (pfn))
 
-#else /* CONFIG_DISCONTIGMEM */
-# define NR_NODE_MEMBLKS	4
-#endif /* CONFIG_DISCONTIGMEM */
 #endif /* _ASM_IA64_MMZONE_H */
diff -Nru a/include/asm-ia64/nodedata.h b/include/asm-ia64/nodedata.h
--- a/include/asm-ia64/nodedata.h	2004-09-08 14:39:48 -07:00
+++ b/include/asm-ia64/nodedata.h	2004-09-08 14:39:48 -07:00
@@ -17,8 +17,6 @@
 #include <asm/percpu.h>
 #include <asm/mmzone.h>
 
-#ifdef CONFIG_DISCONTIGMEM
-
 /*
  * Node Data. One of these structures is located on each node of a NUMA system.
  */
@@ -46,7 +44,5 @@
  *		  completes.
  */
 #define NODE_DATA(nid)		(local_node_data->pg_data_ptrs[nid])
-
-#endif /* CONFIG_DISCONTIGMEM */
 
 #endif /* _ASM_IA64_NODEDATA_H */
diff -Nru a/include/asm-ia64/numa.h b/include/asm-ia64/numa.h
--- a/include/asm-ia64/numa.h	2004-09-08 14:39:48 -07:00
+++ b/include/asm-ia64/numa.h	2004-09-08 14:39:48 -07:00
@@ -12,9 +12,6 @@
 #define _ASM_IA64_NUMA_H
 
 #include <linux/config.h>
-
-#ifdef CONFIG_NUMA
-
 #include <linux/cache.h>
 #include <linux/cpumask.h>
 #include <linux/numa.h>
@@ -58,17 +55,13 @@
  * proportional to the memory access latency ratios.
  */
 
+#ifdef CONFIG_NUMA
 extern u8 numa_slit[MAX_NUMNODES * MAX_NUMNODES];
 #define node_distance(from,to) (numa_slit[(from) * numnodes + (to)])
-
 extern int paddr_to_nid(unsigned long paddr);
-
 #define local_nodeid (cpu_to_node_map[smp_processor_id()])
-
 #else /* !CONFIG_NUMA */
-
 #define paddr_to_nid(addr)	0
-
 #endif /* CONFIG_NUMA */
 
 #endif /* _ASM_IA64_NUMA_H */
diff -Nru a/include/asm-ia64/page.h b/include/asm-ia64/page.h
--- a/include/asm-ia64/page.h	2004-09-08 14:39:48 -07:00
+++ b/include/asm-ia64/page.h	2004-09-08 14:39:48 -07:00
@@ -77,23 +77,7 @@
 
 #define virt_addr_valid(kaddr)	pfn_valid(__pa(kaddr) >> PAGE_SHIFT)
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
 extern int ia64_pfn_valid (unsigned long pfn);
-#else
-# define ia64_pfn_valid(pfn) 1
-#endif
-
-#ifndef CONFIG_DISCONTIGMEM
-# ifdef CONFIG_VIRTUAL_MEM_MAP
-extern struct page *vmem_map;
-#  define pfn_valid(pfn)       (((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
-#  define page_to_pfn(page)    ((unsigned long) (page - vmem_map))
-#  define pfn_to_page(pfn)     (vmem_map + (pfn))
-# endif
-#define pfn_valid(pfn)		(((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
-#define page_to_pfn(page)	((unsigned long) (page - mem_map))
-#define pfn_to_page(pfn)	(mem_map + (pfn))
-#endif /* CONFIG_DISCONTIGMEM */
 
 #define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
diff -Nru a/include/asm-ia64/pgtable.h b/include/asm-ia64/pgtable.h
--- a/include/asm-ia64/pgtable.h	2004-09-08 14:39:48 -07:00
+++ b/include/asm-ia64/pgtable.h	2004-09-08 14:39:48 -07:00
@@ -207,13 +207,9 @@
 #define RGN_KERNEL	7
 
 #define VMALLOC_START		0xa000000200000000
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-# define VMALLOC_END_INIT	(0xa000000000000000 + (1UL << (4*PAGE_SHIFT - 9)))
-# define VMALLOC_END		vmalloc_end
-  extern unsigned long vmalloc_end;
-#else
-# define VMALLOC_END		(0xa000000000000000 + (1UL << (4*PAGE_SHIFT - 9)))
-#endif
+#define VMALLOC_END_INIT	(0xa000000000000000 + (1UL << (4*PAGE_SHIFT - 9)))
+#define VMALLOC_END		vmalloc_end
+extern unsigned long vmalloc_end;
 
 /* fs/proc/kcore.c */
 #define	kc_vaddr_to_offset(v) ((v) - 0xa000000000000000)
@@ -517,12 +513,10 @@
 	ptep_establish(__vma, __addr, __ptep, __entry)
 #endif
 
-#  ifdef CONFIG_VIRTUAL_MEM_MAP
   /* arch mem_map init routine is needed due to holes in a virtual mem_map */
-#   define __HAVE_ARCH_MEMMAP_INIT
-    extern void memmap_init (unsigned long size, int nid, unsigned long zone,
-			     unsigned long start_pfn);
-#  endif /* CONFIG_VIRTUAL_MEM_MAP */
+#define __HAVE_ARCH_MEMMAP_INIT
+extern void memmap_init (unsigned long size, int nid, unsigned long zone,
+			 unsigned long start_pfn);
 # endif /* !__ASSEMBLY__ */
 
 /*
diff -Nru a/include/asm-ia64/processor.h b/include/asm-ia64/processor.h
--- a/include/asm-ia64/processor.h	2004-09-08 14:39:48 -07:00
+++ b/include/asm-ia64/processor.h	2004-09-08 14:39:48 -07:00
@@ -88,9 +88,7 @@
 #include <asm/rse.h>
 #include <asm/unwind.h>
 #include <asm/atomic.h>
-#ifdef CONFIG_NUMA
 #include <asm/nodedata.h>
-#endif
 
 /* like above but expressed as bitfields for more efficient access: */
 struct ia64_psr {
@@ -168,7 +166,7 @@
 	__u8 archrev;
 	char vendor[16];
 
-#ifdef CONFIG_NUMA
+#ifdef CONFIG_DISCONTIGMEM
 	struct ia64_node_data *node_data;
 #endif
 };
diff -Nru a/include/asm-ia64/smp.h b/include/asm-ia64/smp.h
--- a/include/asm-ia64/smp.h	2004-09-08 14:39:48 -07:00
+++ b/include/asm-ia64/smp.h	2004-09-08 14:39:48 -07:00
@@ -126,6 +126,7 @@
 #else
 
 #define cpu_logical_id(cpuid)		0
+#define cpu_physical_id(i)	((ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff)
 
 #endif /* CONFIG_SMP */
 #endif /* _ASM_IA64_SMP_H */
diff -Nru a/include/asm-ia64/sn/sn_cpuid.h b/include/asm-ia64/sn/sn_cpuid.h
--- a/include/asm-ia64/sn/sn_cpuid.h	2004-09-08 14:39:48 -07:00
+++ b/include/asm-ia64/sn/sn_cpuid.h	2004-09-08 14:39:48 -07:00
@@ -83,10 +83,6 @@
  *
  */
 
-#ifndef CONFIG_SMP
-#define cpu_physical_id(cpuid)			((ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff)
-#endif
-
 /*
  * macros for some of these exist in sn/addrs.h & sn/arch.h, etc. However, 
  * trying #include these files here causes circular dependencies.
diff -Nru a/include/linux/acpi.h b/include/linux/acpi.h
--- a/include/linux/acpi.h	2004-09-08 14:39:48 -07:00
+++ b/include/linux/acpi.h	2004-09-08 14:39:48 -07:00
@@ -391,7 +391,11 @@
 void acpi_table_print_srat_entry (acpi_table_entry_header *srat);
 
 /* the following four functions are architecture-dependent */
+#ifdef CONFIG_NUMA
 void acpi_numa_slit_init (struct acpi_table_slit *slit);
+#else
+static inline void acpi_numa_slit_init(struct acpi_table_slit *slit) { }
+#endif
 void acpi_numa_processor_affinity_init (struct acpi_table_processor_affinity *pa);
 void acpi_numa_memory_affinity_init (struct acpi_table_memory_affinity *ma);
 void acpi_numa_arch_fixup(void);

--Boundary-00=_633PBZ5KnSD+M7F--
