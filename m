From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 09 Aug 2007 04:57:21 +0000
Subject: [PATCH] flush icache before set_pte() on ia64  take9 [2/2] flush
Message-Id: <20070809135721.08841cd7.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070809135311.0676a947.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070809135311.0676a947.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, davem@davemloft.net, "Zoltan.Menyhart@bull.net" <Zoltan.Menyhart@bull.net>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>

flush icache before set_pte() for ia64 take 9.

The whole code was changed. This is a new trial.

Changelog v8 -> v9.
 - removed sync_icache_dcache().
 - modified set_pte() rather than adding new complexed macro.

Old stories
 - For synching icache and dcache before set_pte(), I added a new macro for
   ia64, sync_icache_dcache(). I inserted it in proper places.
   Comments from reviewer was negative becasue ia64 specific codes are
   scattered over vm codes and it will not be able to be maintained.
   An advice was hide all in set_pte() because flush_xxx_cache cannot pass
   enough information to arch.

Current ia64 kernel flushes icache by lazy_mmu_prot_update() *after*
set_pte(). This is too late. This patch removes lazy_mmu_prot_update and
add modfied set_pte() for flushing if necessary.

This patch flush icache of a page when
	new pte has exec bit.
	&& new pte has present bit
	&& new pte is user's page.
	&& (old *ptep is not present 
            || new pte's pfn is not same to old *ptep's ptn)
	&& new pte's page has no Pg_arch_1 bit.
	   Pg_arch_1 is set when a page is cache consistent.

I think this condition checks are much easier to understand than considering
"Where sync_icache_dcache() should be inserted ?".


pte_user() for ia64 was removed by http://lkml.org/lkml/2007/6/12/67 as
clean-up. So, I added it again.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 Documentation/cachetlb.txt    |    6 ------
 arch/ia64/mm/init.c           |    5 ++---
 include/asm-generic/pgtable.h |    4 ----
 include/asm-ia64/pgtable.h    |   38 +++++++++++++++++++++++++-------------
 mm/hugetlb.c                  |    2 --
 mm/memory.c                   |    8 +-------
 mm/migrate.c                  |    1 -
 mm/mprotect.c                 |    1 -
 mm/rmap.c                     |    1 -
 9 files changed, 28 insertions(+), 38 deletions(-)

Index: linux-2.6.23-rc2.test/arch/ia64/mm/init.c
=================================--- linux-2.6.23-rc2.test.orig/arch/ia64/mm/init.c
+++ linux-2.6.23-rc2.test/arch/ia64/mm/init.c
@@ -54,14 +54,13 @@ struct page *zero_page_memmap_ptr;	/* ma
 EXPORT_SYMBOL(zero_page_memmap_ptr);
 
 void
-lazy_mmu_prot_update (pte_t pte)
+__ia64_sync_icache_dcache (pte_t pte)
 {
 	unsigned long addr;
 	struct page *page;
 	unsigned long order;
 
-	if (!pte_exec(pte))
-		return;				/* not an executable page... */
+	BUG_ON(!pte_exec(pte));
 
 	page = pte_page(pte);
 	addr = (unsigned long) page_address(page);
Index: linux-2.6.23-rc2.test/include/asm-ia64/pgtable.h
=================================--- linux-2.6.23-rc2.test.orig/include/asm-ia64/pgtable.h
+++ linux-2.6.23-rc2.test/include/asm-ia64/pgtable.h
@@ -223,12 +223,6 @@ ia64_phys_addr_valid (unsigned long addr
  * page table.
  */
 
-/*
- * On some architectures, special things need to be done when setting
- * the PTE in a page table.  Nothing special needs to be on IA-64.
- */
-#define set_pte(ptep, pteval)	(*(ptep) = (pteval))
-#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
 
 #define VMALLOC_START		(RGN_BASE(RGN_GATE) + 0x200000000UL)
 #ifdef CONFIG_VIRTUAL_MEM_MAP
@@ -297,6 +291,7 @@ ia64_phys_addr_valid (unsigned long addr
 /*
  * The following have defined behavior only work if pte_present() is true.
  */
+#define pte_user(pte)	((pte_val(pte) & _PAGE_PL_MASK) = _PAGE_PL_3)
 #define pte_write(pte)	((unsigned) (((pte_val(pte) & _PAGE_AR_MASK) >> _PAGE_AR_SHIFT) - 2) <= 4)
 #define pte_exec(pte)		((pte_val(pte) & _PAGE_AR_RX) != 0)
 #define pte_dirty(pte)		((pte_val(pte) & _PAGE_D) != 0)
@@ -315,6 +310,30 @@ ia64_phys_addr_valid (unsigned long addr
 #define pte_mkhuge(pte)		(__pte(pte_val(pte)))
 
 /*
+ * Because ia64's Icache and Dcache is not coherent (on a cpu), we need to
+ * sync icache and dcache when we insert *new* executable page.
+ *  __ia64_sync_icache_dcache() check Pg_arch_1 bit and flush icache
+ * if necessary.
+ *
+ *  set_pte() is also called by the kernel, but we can expect that the kernel
+ *  flushes icache explicitly if necessary.
+ */
+extern void __ia64_sync_icache_dcache(pte_t pteval);
+static inline void set_pte(pte_t *ptep, pte_t pteval)
+{
+	if (pte_exec(pteval) &&    // flush only new executable page.
+	    pte_present(pteval) && // swap out ?
+	    pte_user(pteval) &&    // ignore kernel page
+	    (!pte_present(*ptep) ||// do_no_page or swap in, migration,
+		pte_pfn(*ptep) != pte_pfn(pteval))) // do_wp_page(), page copy
+		/* load_module() calles flush_icache_range() explicitly*/
+		__ia64_sync_icache_dcache(pteval);
+	*ptep = pteval;
+}
+
+#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
+
+/*
  * Make page protection values cacheable, uncacheable, or write-
  * combining.  Note that "protection" is really a misnomer here as the
  * protection value contains the memory attribute bits, dirty bits, and
@@ -483,12 +502,6 @@ extern struct page *zero_page_memmap_ptr
 #define HUGETLB_PGDIR_MASK	(~(HUGETLB_PGDIR_SIZE-1))
 #endif
 
-/*
- * IA-64 doesn't have any external MMU info: the page tables contain all the necessary
- * information.  However, we use this routine to take care of any (delayed) i-cache
- * flushing that may be necessary.
- */
-extern void lazy_mmu_prot_update (pte_t pte);
 
 #define __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
 /*
@@ -578,7 +591,7 @@ extern void lazy_mmu_prot_update (pte_t 
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
 #define __HAVE_ARCH_PTE_SAME
 #define __HAVE_ARCH_PGD_OFFSET_GATE
-#define __HAVE_ARCH_LAZY_MMU_PROT_UPDATE
+
 
 #ifndef CONFIG_PGTABLE_4
 #include <asm-generic/pgtable-nopud.h>
Index: linux-2.6.23-rc2.test/include/asm-generic/pgtable.h
=================================--- linux-2.6.23-rc2.test.orig/include/asm-generic/pgtable.h
+++ linux-2.6.23-rc2.test/include/asm-generic/pgtable.h
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
Index: linux-2.6.23-rc2.test/mm/hugetlb.c
=================================--- linux-2.6.23-rc2.test.orig/mm/hugetlb.c
+++ linux-2.6.23-rc2.test/mm/hugetlb.c
@@ -353,7 +353,6 @@ static void set_huge_ptep_writable(struc
 	entry = pte_mkwrite(pte_mkdirty(*ptep));
 	if (ptep_set_access_flags(vma, address, ptep, entry, 1)) {
 		update_mmu_cache(vma, address, entry);
-		lazy_mmu_prot_update(entry);
 	}
 }
 
@@ -706,7 +705,6 @@ void hugetlb_change_protection(struct vm
 			pte = huge_ptep_get_and_clear(mm, address, ptep);
 			pte = pte_mkhuge(pte_modify(pte, newprot));
 			set_huge_pte_at(mm, address, ptep, pte);
-			lazy_mmu_prot_update(pte);
 		}
 	}
 	spin_unlock(&mm->page_table_lock);
Index: linux-2.6.23-rc2.test/mm/memory.c
=================================--- linux-2.6.23-rc2.test.orig/mm/memory.c
+++ linux-2.6.23-rc2.test/mm/memory.c
@@ -1697,10 +1697,8 @@ static int do_wp_page(struct mm_struct *
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = pte_mkyoung(orig_pte);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-		if (ptep_set_access_flags(vma, address, page_table, entry,1)) {
+		if (ptep_set_access_flags(vma, address, page_table, entry,1))
 			update_mmu_cache(vma, address, entry);
-			lazy_mmu_prot_update(entry);
-		}
 		ret |= VM_FAULT_WRITE;
 		goto unlock;
 	}
@@ -1741,7 +1739,6 @@ gotten:
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-		lazy_mmu_prot_update(entry);
 		/*
 		 * Clear the pte entry and flush it first, before updating the
 		 * pte with the new entry. This will avoid a race condition
@@ -2286,7 +2283,6 @@ static int do_anonymous_page(struct mm_s
 
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, entry);
-	lazy_mmu_prot_update(entry);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	return 0;
@@ -2437,7 +2433,6 @@ static int __do_fault(struct mm_struct *
 
 		/* no need to invalidate: a not-present page won't be cached */
 		update_mmu_cache(vma, address, entry);
-		lazy_mmu_prot_update(entry);
 	} else {
 		if (anon)
 			page_cache_release(page);
@@ -2611,7 +2606,6 @@ static inline int handle_pte_fault(struc
 	entry = pte_mkyoung(entry);
 	if (ptep_set_access_flags(vma, address, pte, entry, write_access)) {
 		update_mmu_cache(vma, address, entry);
-		lazy_mmu_prot_update(entry);
 	} else {
 		/*
 		 * This is needed only for protection faults but the arch code
Index: linux-2.6.23-rc2.test/mm/migrate.c
=================================--- linux-2.6.23-rc2.test.orig/mm/migrate.c
+++ linux-2.6.23-rc2.test/mm/migrate.c
@@ -181,7 +181,6 @@ static void remove_migration_pte(struct 
 
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, addr, pte);
-	lazy_mmu_prot_update(pte);
 
 out:
 	pte_unmap_unlock(ptep, ptl);
Index: linux-2.6.23-rc2.test/mm/mprotect.c
=================================--- linux-2.6.23-rc2.test.orig/mm/mprotect.c
+++ linux-2.6.23-rc2.test/mm/mprotect.c
@@ -53,7 +53,6 @@ static void change_pte_range(struct mm_s
 			if (dirty_accountable && pte_dirty(ptent))
 				ptent = pte_mkwrite(ptent);
 			set_pte_at(mm, addr, pte, ptent);
-			lazy_mmu_prot_update(ptent);
 #ifdef CONFIG_MIGRATION
 		} else if (!pte_file(oldpte)) {
 			swp_entry_t entry = pte_to_swp_entry(oldpte);
Index: linux-2.6.23-rc2.test/mm/rmap.c
=================================--- linux-2.6.23-rc2.test.orig/mm/rmap.c
+++ linux-2.6.23-rc2.test/mm/rmap.c
@@ -436,7 +436,6 @@ static int page_mkclean_one(struct page 
 		entry = pte_wrprotect(entry);
 		entry = pte_mkclean(entry);
 		set_pte_at(mm, address, pte, entry);
-		lazy_mmu_prot_update(entry);
 		ret = 1;
 	}
 
Index: linux-2.6.23-rc2.test/Documentation/cachetlb.txt
=================================--- linux-2.6.23-rc2.test.orig/Documentation/cachetlb.txt
+++ linux-2.6.23-rc2.test/Documentation/cachetlb.txt
@@ -133,12 +133,6 @@ changes occur:
 	The ia64 sn2 platform is one example of a platform
 	that uses this interface.
 
-8) void lazy_mmu_prot_update(pte_t pte)
-	This interface is called whenever the protection on
-	any user PTEs change.  This interface provides a notification
-	to architecture specific code to take appropriate action.
-
-
 Next, we have the cache flushing interfaces.  In general, when Linux
 is changing an existing virtual-->physical mapping to a new value,
 the sequence will be in one of the following forms:

