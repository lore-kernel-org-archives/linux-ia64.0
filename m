From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 26 Jul 2007 08:13:23 +0000
Subject: [PATCH] flush icache before set_pte on ia64 take3
Message-Id: <20070726171323.a9c17eda.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "tony.luck@intel.com" <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Zoltan.Menyhart@bull.net, nickpiggin@yahoo.com.au

This is a patch for flush icache for ia64 take3.
against 2.6.23-rc1. tested on ia64/NUMA.

Comments ? Should I add CONFIG_MONTECITO ?
(It seems header-file dependency is not clean..but...)

Thanks,
-Kame

=
[IA64] flush icache before setting pte

Changelog:
  - reviewed the whole patch again and avoid flush_icache which seems unnecessary
  - refleshed the whole patch description.

Current ia64 kernel flushes icache *after* set_pte() by lazy_mmu_prot_update().
This behavior is wrong. This patch removes lazy_mmu_prot_update() and implements flush_icache_page() and flush_cache_page() for ia64. By this, icache is flushed
before set_pte().

This patch fixes SIGILL problem on NFS caused by icache inconsistency.

Notes:
 - flush_(i)cache_page() just flushes executable pages by fc.i (if possible)
   This check uses VM_EXEC bit in vm_area_struct.

 - A page which is not neccessary to be flushed is marked as PG_arch_1.
   If a page is once flushed, it will be marked as PG_arch_1.

 - lazy_mmu_prot_update() flushed icache after set_pte(). this patch flushes
   icache befoer set_pte().

 - lazy_mmu_prot_update() checked pte's executable bit. This was because old
   Linux's anon page has executable bit. Current kernel doesn't set executable
   bit on anonymous pages.

 - Flushing icache by the kernel is necessary when the kernel fills contents
   of pages by instructions before mapping the page as executable mapping.

About details of lazy_mmu_prot_update() removals:

 - in do_wp_page() ..... flush_cache_page() is called.

 - in do_anonymous_page() ..... *newly* allocated *anon* page is zero-filled and
	contains no instruction...seems unnecessary to sync i-cache...

 - in do_fault()   ..... flush_icache_page() is called.

 - in handle_pte_fault() .....seems just update access bit.
        ptep_set_access_flags() may flush TLBs. But it seems there are nothing
        to do in cache layer.

 - in remove_migration() ..... inserted flush_icache_page() before inserting
	pte. This seems generic page migration bug ?

 - in chage_pte_range() ..... flush_cache_range() is called before here.

 - in page_mkclean_one() .... flush_cache_page() is called.

 - set_huge_ptep_writable() ..... nothing to do with icache.

 - hugetlb_change_protection() .... flush_cache_range() is called.


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---
 arch/ia64/mm/init.c           |   10 ++--------
 include/asm-generic/pgtable.h |    4 ----
 include/asm-ia64/cacheflush.h |   19 ++++++++++++++++---
 include/asm-ia64/pgtable.h    |    2 --
 include/linux/mm.h            |    5 +++++
 mm/hugetlb.c                  |    2 --
 mm/memory.c                   |    5 -----
 mm/migrate.c                  |    4 +++-
 mm/mprotect.c                 |    1 -
 mm/rmap.c                     |    1 -
 10 files changed, 26 insertions(+), 27 deletions(-)

Index: linux-2.6.23-rc1/arch/ia64/mm/init.c
=================================--- linux-2.6.23-rc1.orig/arch/ia64/mm/init.c
+++ linux-2.6.23-rc1/arch/ia64/mm/init.c
@@ -54,20 +54,14 @@ struct page *zero_page_memmap_ptr;	/* ma
 EXPORT_SYMBOL(zero_page_memmap_ptr);
 
 void
-lazy_mmu_prot_update (pte_t pte)
+__flush_icache_page_ia64 (struct page *page)
 {
 	unsigned long addr;
-	struct page *page;
 	unsigned long order;
 
-	if (!pte_exec(pte))
-		return;				/* not an executable page... */
-
-	page = pte_page(pte);
-	addr = (unsigned long) page_address(page);
-
 	if (test_bit(PG_arch_1, &page->flags))
 		return;				/* i-cache is already coherent with d-cache */
+	addr = (unsigned long) page_address(page);
 
 	if (PageCompound(page)) {
 		order = compound_order(page);
Index: linux-2.6.23-rc1/include/asm-ia64/cacheflush.h
=================================--- linux-2.6.23-rc1.orig/include/asm-ia64/cacheflush.h
+++ linux-2.6.23-rc1/include/asm-ia64/cacheflush.h
@@ -7,10 +7,11 @@
  */
 
 #include <linux/page-flags.h>
-
+#include <linux/mm.h> // for VM_EXEC
 #include <asm/bitops.h>
 #include <asm/page.h>
 
+extern void __flush_icache_page_ia64(struct page *page);
 /*
  * Cache flushing routines.  This is the kind of stuff that can be very expensive, so try
  * to avoid them whenever possible.
@@ -20,11 +21,23 @@
 #define flush_cache_mm(mm)			do { } while (0)
 #define flush_cache_dup_mm(mm)			do { } while (0)
 #define flush_cache_range(vma, start, end)	do { } while (0)
-#define flush_cache_page(vma, vmaddr, pfn)	do { } while (0)
-#define flush_icache_page(vma,page)		do { } while (0)
 #define flush_cache_vmap(start, end)		do { } while (0)
 #define flush_cache_vunmap(start, end)		do { } while (0)
 
+static inline void
+flush_icache_page(struct vm_area_struct *vma, unsigned long pfn) {
+	if ((vma->vm_flags & VM_EXEC) && pfn_valid(pfn))
+		__flush_icache_page_ia64(pfn_to_page(pfn));
+}
+
+static inline void
+flush_cache_page(struct vm_area_struct *vma,
+		 unsigned long vmaddr, unsigned long pfn)
+{
+	/* icache should be flushed if VM_EXEC.*/
+	flush_icache_page(vma, pfn);
+}
+
 #define flush_dcache_page(page)			\
 do {						\
 	clear_bit(PG_arch_1, &(page)->flags);	\
Index: linux-2.6.23-rc1/mm/memory.c
=================================--- linux-2.6.23-rc1.orig/mm/memory.c
+++ linux-2.6.23-rc1/mm/memory.c
@@ -1699,7 +1699,6 @@ static int do_wp_page(struct mm_struct *
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		if (ptep_set_access_flags(vma, address, page_table, entry,1)) {
 			update_mmu_cache(vma, address, entry);
-			lazy_mmu_prot_update(entry);
 		}
 		ret |= VM_FAULT_WRITE;
 		goto unlock;
@@ -1741,7 +1740,6 @@ gotten:
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-		lazy_mmu_prot_update(entry);
 		/*
 		 * Clear the pte entry and flush it first, before updating the
 		 * pte with the new entry. This will avoid a race condition
@@ -2286,7 +2284,6 @@ static int do_anonymous_page(struct mm_s
 
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, entry);
-	lazy_mmu_prot_update(entry);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	return 0;
@@ -2437,7 +2434,6 @@ static int __do_fault(struct mm_struct *
 
 		/* no need to invalidate: a not-present page won't be cached */
 		update_mmu_cache(vma, address, entry);
-		lazy_mmu_prot_update(entry);
 	} else {
 		if (anon)
 			page_cache_release(page);
@@ -2611,7 +2607,6 @@ static inline int handle_pte_fault(struc
 	entry = pte_mkyoung(entry);
 	if (ptep_set_access_flags(vma, address, pte, entry, write_access)) {
 		update_mmu_cache(vma, address, entry);
-		lazy_mmu_prot_update(entry);
 	} else {
 		/*
 		 * This is needed only for protection faults but the arch code
Index: linux-2.6.23-rc1/mm/migrate.c
=================================--- linux-2.6.23-rc1.orig/mm/migrate.c
+++ linux-2.6.23-rc1/mm/migrate.c
@@ -172,6 +172,9 @@ static void remove_migration_pte(struct 
 	pte = pte_mkold(mk_pte(new, vma->vm_page_prot));
 	if (is_write_migration_entry(entry))
 		pte = pte_mkwrite(pte);
+
+	flush_icache_page(vma, page_to_pfn(new));
+
 	set_pte_at(mm, addr, ptep, pte);
 
 	if (PageAnon(new))
@@ -181,7 +184,6 @@ static void remove_migration_pte(struct 
 
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, addr, pte);
-	lazy_mmu_prot_update(pte);
 
 out:
 	pte_unmap_unlock(ptep, ptl);
Index: linux-2.6.23-rc1/include/asm-generic/pgtable.h
=================================--- linux-2.6.23-rc1.orig/include/asm-generic/pgtable.h
+++ linux-2.6.23-rc1/include/asm-generic/pgtable.h
@@ -124,10 +124,6 @@ static inline void ptep_set_wrprotect(st
 #define pgd_offset_gate(mm, addr)	pgd_offset(mm, addr)
 #endif
 
-#ifndef __HAVE_ARCH_LAZY_MMU_PROT_UPDATE
-#define lazy_mmu_prot_update(pte)	do { } while (0)
-#endif
-
 #ifndef __HAVE_ARCH_MOVE_PTE
 #define move_pte(pte, prot, old_addr, new_addr)	(pte)
 #endif
Index: linux-2.6.23-rc1/include/asm-ia64/pgtable.h
=================================--- linux-2.6.23-rc1.orig/include/asm-ia64/pgtable.h
+++ linux-2.6.23-rc1/include/asm-ia64/pgtable.h
@@ -151,7 +151,6 @@
 
 #include <linux/sched.h>	/* for mm_struct */
 #include <asm/bitops.h>
-#include <asm/cacheflush.h>
 #include <asm/mmu_context.h>
 #include <asm/processor.h>
 
@@ -571,7 +570,6 @@ extern struct page *zero_page_memmap_ptr
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
 #define __HAVE_ARCH_PTE_SAME
 #define __HAVE_ARCH_PGD_OFFSET_GATE
-#define __HAVE_ARCH_LAZY_MMU_PROT_UPDATE
 
 #ifndef CONFIG_PGTABLE_4
 #include <asm-generic/pgtable-nopud.h>
Index: linux-2.6.23-rc1/mm/mprotect.c
=================================--- linux-2.6.23-rc1.orig/mm/mprotect.c
+++ linux-2.6.23-rc1/mm/mprotect.c
@@ -53,7 +53,6 @@ static void change_pte_range(struct mm_s
 			if (dirty_accountable && pte_dirty(ptent))
 				ptent = pte_mkwrite(ptent);
 			set_pte_at(mm, addr, pte, ptent);
-			lazy_mmu_prot_update(ptent);
 #ifdef CONFIG_MIGRATION
 		} else if (!pte_file(oldpte)) {
 			swp_entry_t entry = pte_to_swp_entry(oldpte);
Index: linux-2.6.23-rc1/mm/rmap.c
=================================--- linux-2.6.23-rc1.orig/mm/rmap.c
+++ linux-2.6.23-rc1/mm/rmap.c
@@ -436,7 +436,6 @@ static int page_mkclean_one(struct page 
 		entry = pte_wrprotect(entry);
 		entry = pte_mkclean(entry);
 		set_pte_at(mm, address, pte, entry);
-		lazy_mmu_prot_update(entry);
 		ret = 1;
 	}
 
Index: linux-2.6.23-rc1/mm/hugetlb.c
=================================--- linux-2.6.23-rc1.orig/mm/hugetlb.c
+++ linux-2.6.23-rc1/mm/hugetlb.c
@@ -352,7 +352,6 @@ static void set_huge_ptep_writable(struc
 	entry = pte_mkwrite(pte_mkdirty(*ptep));
 	if (ptep_set_access_flags(vma, address, ptep, entry, 1)) {
 		update_mmu_cache(vma, address, entry);
-		lazy_mmu_prot_update(entry);
 	}
 }
 
@@ -705,7 +704,6 @@ void hugetlb_change_protection(struct vm
 			pte = huge_ptep_get_and_clear(mm, address, ptep);
 			pte = pte_mkhuge(pte_modify(pte, newprot));
 			set_huge_pte_at(mm, address, ptep, pte);
-			lazy_mmu_prot_update(pte);
 		}
 	}
 	spin_unlock(&mm->page_table_lock);
Index: linux-2.6.23-rc1/include/linux/mm.h
=================================--- linux-2.6.23-rc1.orig/include/linux/mm.h
+++ linux-2.6.23-rc1/include/linux/mm.h
@@ -255,6 +255,11 @@ struct inode;
  */
 #include <linux/page-flags.h>
 
+/*
+ * Some architecture uses VM_xxx flags as a hint for flushing cache.
+ */
+#include <asm/cacheflush.h>
+
 #ifdef CONFIG_DEBUG_VM
 #define VM_BUG_ON(cond) BUG_ON(cond)
 #else

