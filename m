From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 27 Jul 2007 04:39:36 +0000
Subject: [PATCH] flush cache fixes for ia64 [2/2] sync icache dcache
Message-Id: <20070727133936.36b047cd.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070727133657.8c9c6803.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070727133657.8c9c6803.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, Zoltan.Menyhart@bull.net, Christoph Lameter <clameter@sgi.com>

flush icache for ia64 take4.
This patch is against 2.6.23-rc1.

Changes v3 -> v4:
  - avoid implementing flush_(i)cache_pages().
  - added sync_icache_dcache() call.
  - change Documentation/cachetlb.txt

Current ia64 kernel flushes icache by lazy_mmu_prot_update() *after*
set_pte(). This is wrong. This patch removes lazy_mmu_prot_update and
add sync_icache_dcache(). sync_icache_dcache() is called before set_pte()
if necessary and synchronize icache with dcache (fc.i instruction).

This patch fixes SIGILL problem on NFS/ia64.

About Icache-Dcache inconsistency in ia64
 - When the cache line is modified, Icache and Dcache are purged.

 - When I-cache misses, I-cache will access just the lower layer cache(memory).
   Then, If the lower_layer_cache is not up-to-date, I-cache will see
   old information. For avoiding this case, Icache-Dcache synchronization(fc.i)
   is necessary. (Icache-Dcache synchronization means making Dcache and lower
   layer unified cache(memory) consistent.)

Details:
 - In general, cache flushing macro are used for virtually tagged caches.
   IA64 has physically tagged caches but doesn't guarantee consistency 
   between Icache and Dcache. So, new macro, sync_icache_dcache() is added.
   This is NO-OP in other archs.
 - sync_icache_dcache() only works if pte is executable.
 - sync_icache_dcache must be called before set_pte().
 - A page which is consistent is marked as PG_arch_1.

About changes in generic codes:
 - do_wp_page() ....need to sync newly-installed page.

 - do_anonymous_page() .... newly installed anon pages doesn't contains
   any instruction when set_pte() is executed, icache-dcache synchronization
   is not necessary.

 - __do_fault() .... need to sync newly-installed page.

 - handle_pte_fault() .... just changes access bit...then, no need to sync.

 - remove_migration_pte().... need to sync newly-installed page.

 
 - change_pte_range() .... need to sync icache-dcache. When a user writes
		instruction into the page and mod fies protection to be	
		executable, it should be synced.

 - hugetlb_change_protection() .... Maybe cache will be expired...but
	                  it is safe to sync Icache before set_pte().

 - page_mkclean_one() .... no need to sync icache-dcache. There is no page
                           contents modification. And there is no protection 
			   change.

Thanks to Zoltan Menyhart for his advices.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 Documentation/cachetlb.txt    |   11 +++++++----
 arch/ia64/mm/init.c           |    6 ++----
 include/asm-generic/pgtable.h |    8 ++++----
 include/asm-ia64/pgtable.h    |   15 ++++++++++-----
 mm/hugetlb.c                  |    3 +--
 mm/memory.c                   |    8 +++-----
 mm/migrate.c                  |    2 +-
 mm/mprotect.c                 |    2 +-
 mm/rmap.c                     |    1 -
 9 files changed, 29 insertions(+), 27 deletions(-)

Index: linux-2.6.23-rc1.test/include/asm-generic/pgtable.h
=================================--- linux-2.6.23-rc1.test.orig/include/asm-generic/pgtable.h
+++ linux-2.6.23-rc1.test/include/asm-generic/pgtable.h
@@ -124,14 +124,14 @@ static inline void ptep_set_wrprotect(st
 #define pgd_offset_gate(mm, addr)	pgd_offset(mm, addr)
 #endif
 
-#ifndef __HAVE_ARCH_LAZY_MMU_PROT_UPDATE
-#define lazy_mmu_prot_update(pte)	do { } while (0)
-#endif
-
 #ifndef __HAVE_ARCH_MOVE_PTE
 #define move_pte(pte, prot, old_addr, new_addr)	(pte)
 #endif
 
+#ifndef __HAVE_ARCH_SYNC_ICACHE_DCACHE
+#define sync_icache_dcache(pte)		do {} while (0)
+#endif
+
 /*
  * A facility to provide lazy MMU batching.  This allows PTE updates and
  * page invalidations to be delayed until a call to leave lazy MMU mode
Index: linux-2.6.23-rc1.test/include/asm-ia64/pgtable.h
=================================--- linux-2.6.23-rc1.test.orig/include/asm-ia64/pgtable.h
+++ linux-2.6.23-rc1.test/include/asm-ia64/pgtable.h
@@ -484,11 +484,17 @@ extern struct page *zero_page_memmap_ptr
 #endif
 
 /*
- * IA-64 doesn't have any external MMU info: the page tables contain all the necessary
- * information.  However, we use this routine to take care of any (delayed) i-cache
- * flushing that may be necessary.
+ * IA-64 doesn't guarantee Icache is consistent with Dcache. For ensure
+ * Icache consistency, we have to synchronize them before setting pte
+ * as an executable pte.
  */
-extern void lazy_mmu_prot_update (pte_t pte);
+extern void __sync_icache_dcache(pte_t pte);
+static inline void sync_icache_dcache(pte_t pte) {
+	if (pte_exec(pte))
+		__sync_icache_dcache(pte);
+}
+#define __HAVE_ARCH_SYNC_ICACHE_DCACHE
+
 
 #define __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
 /*
@@ -578,7 +584,6 @@ extern void lazy_mmu_prot_update (pte_t 
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
 #define __HAVE_ARCH_PTE_SAME
 #define __HAVE_ARCH_PGD_OFFSET_GATE
-#define __HAVE_ARCH_LAZY_MMU_PROT_UPDATE
 
 #ifndef CONFIG_PGTABLE_4
 #include <asm-generic/pgtable-nopud.h>
Index: linux-2.6.23-rc1.test/Documentation/cachetlb.txt
=================================--- linux-2.6.23-rc1.test.orig/Documentation/cachetlb.txt
+++ linux-2.6.23-rc1.test/Documentation/cachetlb.txt
@@ -133,11 +133,14 @@ changes occur:
 	The ia64 sn2 platform is one example of a platform
 	that uses this interface.
 
-8) void lazy_mmu_prot_update(pte_t pte)
-	This interface is called whenever the protection on
-	any user PTEs change.  This interface provides a notification
-	to architecture specific code to take appropriate action.
+8) void sync_icache_dcache(pte_t pte)
+	This interface is used for synchronize icache and dcache.
+	Even if the cache is physically tagged, some archs doesn't
+	guarantee consistency between I-cache and D-cache. In such arch,
+	we need to synchronize I-cache and D-cache before installing
+	executable pages.
 
+	This is used only for ia64 now.
 
 Next, we have the cache flushing interfaces.  In general, when Linux
 is changing an existing virtual-->physical mapping to a new value,
Index: linux-2.6.23-rc1.test/mm/memory.c
=================================--- linux-2.6.23-rc1.test.orig/mm/memory.c
+++ linux-2.6.23-rc1.test/mm/memory.c
@@ -1697,9 +1697,9 @@ static int do_wp_page(struct mm_struct *
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = pte_mkyoung(orig_pte);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		sync_icache_dcache(entry);
 		if (ptep_set_access_flags(vma, address, page_table, entry,1)) {
 			update_mmu_cache(vma, address, entry);
-			lazy_mmu_prot_update(entry);
 		}
 		ret |= VM_FAULT_WRITE;
 		goto unlock;
@@ -1741,7 +1741,7 @@ gotten:
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-		lazy_mmu_prot_update(entry);
+		sync_icache_dcache(entry);
 		/*
 		 * Clear the pte entry and flush it first, before updating the
 		 * pte with the new entry. This will avoid a race condition
@@ -2286,7 +2286,6 @@ static int do_anonymous_page(struct mm_s
 
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, entry);
-	lazy_mmu_prot_update(entry);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	return 0;
@@ -2419,6 +2418,7 @@ static int __do_fault(struct mm_struct *
 	if (likely(pte_same(*page_table, orig_pte))) {
 		flush_icache_page(vma, page);
 		entry = mk_pte(page, vma->vm_page_prot);
+		sync_icache_dcache(entry);
 		if (flags & FAULT_FLAG_WRITE)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		set_pte_at(mm, address, page_table, entry);
@@ -2437,7 +2437,6 @@ static int __do_fault(struct mm_struct *
 
 		/* no need to invalidate: a not-present page won't be cached */
 		update_mmu_cache(vma, address, entry);
-		lazy_mmu_prot_update(entry);
 	} else {
 		if (anon)
 			page_cache_release(page);
@@ -2611,7 +2610,6 @@ static inline int handle_pte_fault(struc
 	entry = pte_mkyoung(entry);
 	if (ptep_set_access_flags(vma, address, pte, entry, write_access)) {
 		update_mmu_cache(vma, address, entry);
-		lazy_mmu_prot_update(entry);
 	} else {
 		/*
 		 * This is needed only for protection faults but the arch code
Index: linux-2.6.23-rc1.test/mm/migrate.c
=================================--- linux-2.6.23-rc1.test.orig/mm/migrate.c
+++ linux-2.6.23-rc1.test/mm/migrate.c
@@ -173,6 +173,7 @@ static void remove_migration_pte(struct 
 	if (is_write_migration_entry(entry))
 		pte = pte_mkwrite(pte);
 	flush_icache_page(vma, new);
+	sync_icache_dcache(pte);
 	set_pte_at(mm, addr, ptep, pte);
 
 	if (PageAnon(new))
@@ -182,7 +183,6 @@ static void remove_migration_pte(struct 
 
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, addr, pte);
-	lazy_mmu_prot_update(pte);
 
 out:
 	pte_unmap_unlock(ptep, ptl);
Index: linux-2.6.23-rc1.test/mm/hugetlb.c
=================================--- linux-2.6.23-rc1.test.orig/mm/hugetlb.c
+++ linux-2.6.23-rc1.test/mm/hugetlb.c
@@ -352,7 +352,6 @@ static void set_huge_ptep_writable(struc
 	entry = pte_mkwrite(pte_mkdirty(*ptep));
 	if (ptep_set_access_flags(vma, address, ptep, entry, 1)) {
 		update_mmu_cache(vma, address, entry);
-		lazy_mmu_prot_update(entry);
 	}
 }
 
@@ -704,8 +703,8 @@ void hugetlb_change_protection(struct vm
 		if (!pte_none(*ptep)) {
 			pte = huge_ptep_get_and_clear(mm, address, ptep);
 			pte = pte_mkhuge(pte_modify(pte, newprot));
+			sync_icache_dcache(pte);
 			set_huge_pte_at(mm, address, ptep, pte);
-			lazy_mmu_prot_update(pte);
 		}
 	}
 	spin_unlock(&mm->page_table_lock);
Index: linux-2.6.23-rc1.test/arch/ia64/mm/init.c
=================================--- linux-2.6.23-rc1.test.orig/arch/ia64/mm/init.c
+++ linux-2.6.23-rc1.test/arch/ia64/mm/init.c
@@ -54,15 +54,13 @@ struct page *zero_page_memmap_ptr;	/* ma
 EXPORT_SYMBOL(zero_page_memmap_ptr);
 
 void
-lazy_mmu_prot_update (pte_t pte)
+__sync_icache_dcache (pte_t pte)
 {
 	unsigned long addr;
 	struct page *page;
 	unsigned long order;
 
-	if (!pte_exec(pte))
-		return;				/* not an executable page... */
-
+	BUG_ON(!pte_exec(pte));
 	page = pte_page(pte);
 	addr = (unsigned long) page_address(page);
 
Index: linux-2.6.23-rc1.test/mm/mprotect.c
=================================--- linux-2.6.23-rc1.test.orig/mm/mprotect.c
+++ linux-2.6.23-rc1.test/mm/mprotect.c
@@ -52,8 +52,8 @@ static void change_pte_range(struct mm_s
 			 */
 			if (dirty_accountable && pte_dirty(ptent))
 				ptent = pte_mkwrite(ptent);
+			sync_icache_dcache(ptent);
 			set_pte_at(mm, addr, pte, ptent);
-			lazy_mmu_prot_update(ptent);
 #ifdef CONFIG_MIGRATION
 		} else if (!pte_file(oldpte)) {
 			swp_entry_t entry = pte_to_swp_entry(oldpte);
Index: linux-2.6.23-rc1.test/mm/rmap.c
=================================--- linux-2.6.23-rc1.test.orig/mm/rmap.c
+++ linux-2.6.23-rc1.test/mm/rmap.c
@@ -436,7 +436,6 @@ static int page_mkclean_one(struct page 
 		entry = pte_wrprotect(entry);
 		entry = pte_mkclean(entry);
 		set_pte_at(mm, address, pte, entry);
-		lazy_mmu_prot_update(entry);
 		ret = 1;
 	}
 


