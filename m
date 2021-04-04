From: Sergei Trofimovich <slyfox@gentoo.org>
Date: Sun, 04 Apr 2021 19:34:40 +0000
Subject: [PATCH] ia64: drop marked broken DISCONTIGMEM and VIRTUAL_MEM_MAP
Message-Id: <20210404193440.2615358-1-slyfox@gentoo.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Sergei Trofimovich <slyfox@gentoo.org>, linux-ia64@vger.kernel.org

DISCONTIGMEM was marked BROKEN in 5.11. Let's remove it.

Booted SPARSEMEM successfully on rx3600.

CC: Andrew Morton <akpm@linux-foundation.org>
CC: linux-ia64@vger.kernel.org
Signed-off-by: Sergei Trofimovich <slyfox@gentoo.org>
---
 arch/ia64/Kconfig                  |  23 ----
 arch/ia64/configs/bigsur_defconfig |   1 -
 arch/ia64/include/asm/meminit.h    |  11 --
 arch/ia64/include/asm/page.h       |  25 +---
 arch/ia64/include/asm/pgtable.h    |   5 -
 arch/ia64/kernel/Makefile          |   2 +-
 arch/ia64/kernel/ia64_ksyms.c      |  12 --
 arch/ia64/kernel/machine_kexec.c   |   2 +-
 arch/ia64/mm/Makefile              |   1 -
 arch/ia64/mm/contig.c              |   4 -
 arch/ia64/mm/discontig.c           |  21 ---
 arch/ia64/mm/fault.c               |  15 --
 arch/ia64/mm/init.c                | 213 -----------------------------
 13 files changed, 4 insertions(+), 331 deletions(-)
 delete mode 100644 arch/ia64/kernel/ia64_ksyms.c

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 2ad7a8d29fcc..81e2b893b1e7 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -286,15 +286,6 @@ config FORCE_CPEI_RETARGET
 config ARCH_SELECT_MEMORY_MODEL
 	def_bool y
 
-config ARCH_DISCONTIGMEM_ENABLE
-	def_bool y
-	depends on BROKEN
-	help
-	  Say Y to support efficient handling of discontiguous physical memory,
-	  for architectures which are either NUMA (Non-Uniform Memory Access)
-	  or have huge holes in the physical address space for other reasons.
-	  See <file:Documentation/vm/numa.rst> for more.
-
 config ARCH_FLATMEM_ENABLE
 	def_bool y
 
@@ -325,22 +316,8 @@ config NODES_SHIFT
 	  MAX_NUMNODES will be 2^(This value).
 	  If in doubt, use the default.
 
-# VIRTUAL_MEM_MAP and FLAT_NODE_MEM_MAP are functionally equivalent.
-# VIRTUAL_MEM_MAP has been retained for historical reasons.
-config VIRTUAL_MEM_MAP
-	bool "Virtual mem map"
-	depends on !SPARSEMEM && !FLATMEM
-	default y
-	help
-	  Say Y to compile the kernel with support for a virtual mem map.
-	  This code also only takes effect if a memory hole of greater than
-	  1 Gb is found during boot.  You must turn this option on if you
-	  require the DISCONTIGMEM option for your machine. If you are
-	  unsure, say Y.
-
 config HOLES_IN_ZONE
 	bool
-	default y if VIRTUAL_MEM_MAP
 
 config HAVE_ARCH_NODEDATA_EXTENSION
 	def_bool y
diff --git a/arch/ia64/configs/bigsur_defconfig b/arch/ia64/configs/bigsur_defconfig
index c409756b5396..0341a67cc1bf 100644
--- a/arch/ia64/configs/bigsur_defconfig
+++ b/arch/ia64/configs/bigsur_defconfig
@@ -9,7 +9,6 @@ CONFIG_SGI_PARTITION=y
 CONFIG_SMP=y
 CONFIG_NR_CPUS=2
 CONFIG_PREEMPT=y
-# CONFIG_VIRTUAL_MEM_MAP is not set
 CONFIG_IA64_PALINFO=y
 CONFIG_EFI_VARS=y
 CONFIG_BINFMT_MISC=m
diff --git a/arch/ia64/include/asm/meminit.h b/arch/ia64/include/asm/meminit.h
index e789c0818edb..6c47a239fc26 100644
--- a/arch/ia64/include/asm/meminit.h
+++ b/arch/ia64/include/asm/meminit.h
@@ -58,15 +58,4 @@ extern int reserve_elfcorehdr(u64 *start, u64 *end);
 
 extern int register_active_ranges(u64 start, u64 len, int nid);
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-  extern unsigned long VMALLOC_END;
-  extern struct page *vmem_map;
-  extern int create_mem_map_page_table(u64 start, u64 end, void *arg);
-  extern int vmemmap_find_next_valid_pfn(int, int);
-#else
-static inline int vmemmap_find_next_valid_pfn(int node, int i)
-{
-	return i + 1;
-}
-#endif
 #endif /* meminit_h */
diff --git a/arch/ia64/include/asm/page.h b/arch/ia64/include/asm/page.h
index b69a5499d75b..f4dc81fa7146 100644
--- a/arch/ia64/include/asm/page.h
+++ b/arch/ia64/include/asm/page.h
@@ -95,31 +95,10 @@ do {						\
 
 #define virt_addr_valid(kaddr)	pfn_valid(__pa(kaddr) >> PAGE_SHIFT)
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-extern int ia64_pfn_valid (unsigned long pfn);
-#else
-# define ia64_pfn_valid(pfn) 1
-#endif
-
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-extern struct page *vmem_map;
-#ifdef CONFIG_DISCONTIGMEM
-# define page_to_pfn(page)	((unsigned long) (page - vmem_map))
-# define pfn_to_page(pfn)	(vmem_map + (pfn))
-# define __pfn_to_phys(pfn)	PFN_PHYS(pfn)
-#else
-# include <asm-generic/memory_model.h>
-#endif
-#else
-# include <asm-generic/memory_model.h>
-#endif
+#include <asm-generic/memory_model.h>
 
 #ifdef CONFIG_FLATMEM
-# define pfn_valid(pfn)		(((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
-#elif defined(CONFIG_DISCONTIGMEM)
-extern unsigned long min_low_pfn;
-extern unsigned long max_low_pfn;
-# define pfn_valid(pfn)		(((pfn) >= min_low_pfn) && ((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))
+# define pfn_valid(pfn)		((pfn) < max_mapnr)
 #endif
 
 #define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
diff --git a/arch/ia64/include/asm/pgtable.h b/arch/ia64/include/asm/pgtable.h
index 9b4efe89e62d..8994514ebe91 100644
--- a/arch/ia64/include/asm/pgtable.h
+++ b/arch/ia64/include/asm/pgtable.h
@@ -223,10 +223,6 @@ ia64_phys_addr_valid (unsigned long addr)
 
 
 #define VMALLOC_START		(RGN_BASE(RGN_GATE) + 0x200000000UL)
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-# define VMALLOC_END_INIT	(RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 9)))
-extern unsigned long VMALLOC_END;
-#else
 #if defined(CONFIG_SPARSEMEM) && defined(CONFIG_SPARSEMEM_VMEMMAP)
 /* SPARSEMEM_VMEMMAP uses half of vmalloc... */
 # define VMALLOC_END		(RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 10)))
@@ -234,7 +230,6 @@ extern unsigned long VMALLOC_END;
 #else
 # define VMALLOC_END		(RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 9)))
 #endif
-#endif
 
 /* fs/proc/kcore.c */
 #define	kc_vaddr_to_offset(v) ((v) - RGN_BASE(RGN_GATE))
diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 78717819131c..08d4a2ba0652 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -9,7 +9,7 @@ endif
 
 extra-y	:= head.o vmlinux.lds
 
-obj-y := entry.o efi.o efi_stub.o gate-data.o fsys.o ia64_ksyms.o irq.o irq_ia64.o	\
+obj-y := entry.o efi.o efi_stub.o gate-data.o fsys.o irq.o irq_ia64.o	\
 	 irq_lsapic.o ivt.o pal.o patch.o process.o ptrace.o sal.o		\
 	 salinfo.o setup.o signal.o sys_ia64.o time.o traps.o unaligned.o \
 	 unwind.o mca.o mca_asm.o topology.o dma-mapping.o iosapic.o acpi.o \
diff --git a/arch/ia64/kernel/ia64_ksyms.c b/arch/ia64/kernel/ia64_ksyms.c
deleted file mode 100644
index f8150ee74f29..000000000000
--- a/arch/ia64/kernel/ia64_ksyms.c
+++ /dev/null
@@ -1,12 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * Architecture-specific kernel symbols
- */
-
-#if defined(CONFIG_VIRTUAL_MEM_MAP) || defined(CONFIG_DISCONTIGMEM)
-#include <linux/compiler.h>
-#include <linux/export.h>
-#include <linux/memblock.h>
-EXPORT_SYMBOL(min_low_pfn);	/* defined by bootmem.c, but not exported by generic code */
-EXPORT_SYMBOL(max_low_pfn);	/* defined by bootmem.c, but not exported by generic code */
-#endif
diff --git a/arch/ia64/kernel/machine_kexec.c b/arch/ia64/kernel/machine_kexec.c
index af310dc8a356..4db9ca144fa5 100644
--- a/arch/ia64/kernel/machine_kexec.c
+++ b/arch/ia64/kernel/machine_kexec.c
@@ -143,7 +143,7 @@ void machine_kexec(struct kimage *image)
 
 void arch_crash_save_vmcoreinfo(void)
 {
-#if defined(CONFIG_DISCONTIGMEM) || defined(CONFIG_SPARSEMEM)
+#if defined(CONFIG_SPARSEMEM)
 	VMCOREINFO_SYMBOL(pgdat_list);
 	VMCOREINFO_LENGTH(pgdat_list, MAX_NUMNODES);
 #endif
diff --git a/arch/ia64/mm/Makefile b/arch/ia64/mm/Makefile
index 99a35039b548..c03f63c62ac4 100644
--- a/arch/ia64/mm/Makefile
+++ b/arch/ia64/mm/Makefile
@@ -7,6 +7,5 @@ obj-y := init.o fault.o tlb.o extable.o ioremap.o
 
 obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
 obj-$(CONFIG_NUMA)	   += numa.o
-obj-$(CONFIG_DISCONTIGMEM) += discontig.o
 obj-$(CONFIG_SPARSEMEM)	   += discontig.o
 obj-$(CONFIG_FLATMEM)	   += contig.o
diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index 62fe80a16f42..42e025cfbd08 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -153,11 +153,7 @@ find_memory (void)
 	efi_memmap_walk(find_max_min_low_pfn, NULL);
 	max_pfn = max_low_pfn;
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-	efi_memmap_walk(filter_memory, register_active_ranges);
-#else
 	memblock_add_node(0, PFN_PHYS(max_low_pfn), 0);
-#endif
 
 	find_initrd();
 
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 03b3a02375ff..c570096770a2 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -585,25 +585,6 @@ void call_pernode_memory(unsigned long start, unsigned long len, void *arg)
 	}
 }
 
-static void __init virtual_map_init(void)
-{
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-	int node;
-
-	VMALLOC_END -= PAGE_ALIGN(ALIGN(max_low_pfn, MAX_ORDER_NR_PAGES) *
-		sizeof(struct page));
-	vmem_map = (struct page *) VMALLOC_END;
-	efi_memmap_walk(create_mem_map_page_table, NULL);
-	printk("Virtual mem_map starts at 0x%p\n", vmem_map);
-
-	for_each_online_node(node) {
-		unsigned long pfn_offset = mem_data[node].min_pfn;
-
-		NODE_DATA(node)->node_mem_map = vmem_map + pfn_offset;
-	}
-#endif
-}
-
 /**
  * paging_init - setup page tables
  *
@@ -619,8 +600,6 @@ void __init paging_init(void)
 
 	sparse_init();
 
-	virtual_map_init();
-
 	memset(max_zone_pfns, 0, sizeof(max_zone_pfns));
 	max_zone_pfns[ZONE_DMA32] = max_dma;
 	max_zone_pfns[ZONE_NORMAL] = max_low_pfn;
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index cd9766d2b6e0..02de2e70c587 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -84,18 +84,6 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 	if (faulthandler_disabled() || !mm)
 		goto no_context;
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-	/*
-	 * If fault is in region 5 and we are in the kernel, we may already
-	 * have the mmap_lock (pfn_valid macro is called during mmap). There
-	 * is no vma for region 5 addr's anyway, so skip getting the semaphore
-	 * and go directly to the exception handling code.
-	 */
-
-	if ((REGION_NUMBER(address) = 5) && !user_mode(regs))
-		goto bad_area_no_up;
-#endif
-
 	/*
 	 * This is to handle the kprobes on user space access instructions
 	 */
@@ -213,9 +201,6 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 
   bad_area:
 	mmap_read_unlock(mm);
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-  bad_area_no_up:
-#endif
 	if ((isr & IA64_ISR_SP)
 	    || ((isr & IA64_ISR_NA) && (isr & IA64_ISR_CODE_MASK) = IA64_ISR_CODE_LFETCH))
 	{
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 16d0d7d22657..58d9e8b9c181 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -43,13 +43,6 @@ extern void ia64_tlb_init (void);
 
 unsigned long MAX_DMA_ADDRESS = PAGE_OFFSET + 0x100000000UL;
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-unsigned long VMALLOC_END = VMALLOC_END_INIT;
-EXPORT_SYMBOL(VMALLOC_END);
-struct page *vmem_map;
-EXPORT_SYMBOL(vmem_map);
-#endif
-
 struct page *zero_page_memmap_ptr;	/* map entry for zero page */
 EXPORT_SYMBOL(zero_page_memmap_ptr);
 
@@ -373,212 +366,6 @@ void ia64_mmu_init(void *my_cpu_data)
 #endif
 }
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-int vmemmap_find_next_valid_pfn(int node, int i)
-{
-	unsigned long end_address, hole_next_pfn;
-	unsigned long stop_address;
-	pg_data_t *pgdat = NODE_DATA(node);
-
-	end_address = (unsigned long) &vmem_map[pgdat->node_start_pfn + i];
-	end_address = PAGE_ALIGN(end_address);
-	stop_address = (unsigned long) &vmem_map[pgdat_end_pfn(pgdat)];
-
-	do {
-		pgd_t *pgd;
-		p4d_t *p4d;
-		pud_t *pud;
-		pmd_t *pmd;
-		pte_t *pte;
-
-		pgd = pgd_offset_k(end_address);
-		if (pgd_none(*pgd)) {
-			end_address += PGDIR_SIZE;
-			continue;
-		}
-
-		p4d = p4d_offset(pgd, end_address);
-		if (p4d_none(*p4d)) {
-			end_address += P4D_SIZE;
-			continue;
-		}
-
-		pud = pud_offset(p4d, end_address);
-		if (pud_none(*pud)) {
-			end_address += PUD_SIZE;
-			continue;
-		}
-
-		pmd = pmd_offset(pud, end_address);
-		if (pmd_none(*pmd)) {
-			end_address += PMD_SIZE;
-			continue;
-		}
-
-		pte = pte_offset_kernel(pmd, end_address);
-retry_pte:
-		if (pte_none(*pte)) {
-			end_address += PAGE_SIZE;
-			pte++;
-			if ((end_address < stop_address) &&
-			    (end_address != ALIGN(end_address, 1UL << PMD_SHIFT)))
-				goto retry_pte;
-			continue;
-		}
-		/* Found next valid vmem_map page */
-		break;
-	} while (end_address < stop_address);
-
-	end_address = min(end_address, stop_address);
-	end_address = end_address - (unsigned long) vmem_map + sizeof(struct page) - 1;
-	hole_next_pfn = end_address / sizeof(struct page);
-	return hole_next_pfn - pgdat->node_start_pfn;
-}
-
-int __init create_mem_map_page_table(u64 start, u64 end, void *arg)
-{
-	unsigned long address, start_page, end_page;
-	struct page *map_start, *map_end;
-	int node;
-	pgd_t *pgd;
-	p4d_t *p4d;
-	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *pte;
-
-	map_start = vmem_map + (__pa(start) >> PAGE_SHIFT);
-	map_end   = vmem_map + (__pa(end) >> PAGE_SHIFT);
-
-	start_page = (unsigned long) map_start & PAGE_MASK;
-	end_page = PAGE_ALIGN((unsigned long) map_end);
-	node = paddr_to_nid(__pa(start));
-
-	for (address = start_page; address < end_page; address += PAGE_SIZE) {
-		pgd = pgd_offset_k(address);
-		if (pgd_none(*pgd)) {
-			p4d = memblock_alloc_node(PAGE_SIZE, PAGE_SIZE, node);
-			if (!p4d)
-				goto err_alloc;
-			pgd_populate(&init_mm, pgd, p4d);
-		}
-		p4d = p4d_offset(pgd, address);
-
-		if (p4d_none(*p4d)) {
-			pud = memblock_alloc_node(PAGE_SIZE, PAGE_SIZE, node);
-			if (!pud)
-				goto err_alloc;
-			p4d_populate(&init_mm, p4d, pud);
-		}
-		pud = pud_offset(p4d, address);
-
-		if (pud_none(*pud)) {
-			pmd = memblock_alloc_node(PAGE_SIZE, PAGE_SIZE, node);
-			if (!pmd)
-				goto err_alloc;
-			pud_populate(&init_mm, pud, pmd);
-		}
-		pmd = pmd_offset(pud, address);
-
-		if (pmd_none(*pmd)) {
-			pte = memblock_alloc_node(PAGE_SIZE, PAGE_SIZE, node);
-			if (!pte)
-				goto err_alloc;
-			pmd_populate_kernel(&init_mm, pmd, pte);
-		}
-		pte = pte_offset_kernel(pmd, address);
-
-		if (pte_none(*pte)) {
-			void *page = memblock_alloc_node(PAGE_SIZE, PAGE_SIZE,
-							 node);
-			if (!page)
-				goto err_alloc;
-			set_pte(pte, pfn_pte(__pa(page) >> PAGE_SHIFT,
-					     PAGE_KERNEL));
-		}
-	}
-	return 0;
-
-err_alloc:
-	panic("%s: Failed to allocate %lu bytes align=0x%lx nid=%d\n",
-	      __func__, PAGE_SIZE, PAGE_SIZE, node);
-	return -ENOMEM;
-}
-
-struct memmap_init_callback_data {
-	struct page *start;
-	struct page *end;
-	int nid;
-	unsigned long zone;
-};
-
-static int __meminit
-virtual_memmap_init(u64 start, u64 end, void *arg)
-{
-	struct memmap_init_callback_data *args;
-	struct page *map_start, *map_end;
-
-	args = (struct memmap_init_callback_data *) arg;
-	map_start = vmem_map + (__pa(start) >> PAGE_SHIFT);
-	map_end   = vmem_map + (__pa(end) >> PAGE_SHIFT);
-
-	if (map_start < args->start)
-		map_start = args->start;
-	if (map_end > args->end)
-		map_end = args->end;
-
-	/*
-	 * We have to initialize "out of bounds" struct page elements that fit completely
-	 * on the same pages that were allocated for the "in bounds" elements because they
-	 * may be referenced later (and found to be "reserved").
-	 */
-	map_start -= ((unsigned long) map_start & (PAGE_SIZE - 1)) / sizeof(struct page);
-	map_end += ((PAGE_ALIGN((unsigned long) map_end) - (unsigned long) map_end)
-		    / sizeof(struct page));
-
-	if (map_start < map_end)
-		memmap_init_range((unsigned long)(map_end - map_start),
-				 args->nid, args->zone, page_to_pfn(map_start), page_to_pfn(map_end),
-				 MEMINIT_EARLY, NULL, MIGRATE_MOVABLE);
-	return 0;
-}
-
-void __meminit memmap_init_zone(struct zone *zone)
-{
-	int nid = zone_to_nid(zone), zone_id = zone_idx(zone);
-	unsigned long start_pfn = zone->zone_start_pfn;
-	unsigned long size = zone->spanned_pages;
-
-	if (!vmem_map) {
-		memmap_init_range(size, nid, zone_id, start_pfn, start_pfn + size,
-				 MEMINIT_EARLY, NULL, MIGRATE_MOVABLE);
-	} else {
-		struct page *start;
-		struct memmap_init_callback_data args;
-
-		start = pfn_to_page(start_pfn);
-		args.start = start;
-		args.end = start + size;
-		args.nid = nid;
-		args.zone = zone_id;
-
-		efi_memmap_walk(virtual_memmap_init, &args);
-	}
-}
-
-int
-ia64_pfn_valid (unsigned long pfn)
-{
-	char byte;
-	struct page *pg = pfn_to_page(pfn);
-
-	return     (__get_user(byte, (char __user *) pg) = 0)
-		&& ((((u64)pg & PAGE_MASK) = (((u64)(pg + 1) - 1) & PAGE_MASK))
-			|| (__get_user(byte, (char __user *) (pg + 1) - 1) = 0));
-}
-EXPORT_SYMBOL(ia64_pfn_valid);
-
-#endif /* CONFIG_VIRTUAL_MEM_MAP */
-
 int __init register_active_ranges(u64 start, u64 len, int nid)
 {
 	u64 end = start + len;
-- 
2.31.1
