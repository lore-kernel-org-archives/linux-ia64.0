From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Sun, 30 Oct 2022 22:58:25 +0000
Subject: [PATCH v5] hugetlb: simplify hugetlb handling in follow_page_mask
Message-Id: <20221030225825.40872-1-mike.kravetz@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org
Cc: Peter Xu <peterx@redhat.com>, Baolin Wang <baolin.wang@linux.alibaba.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, David Hildenbrand <david@redhat.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, Michael Ellerman <mpe@ellerman.id.au>, Muchun Song <songmuchun@bytedance.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

During discussions of this series [1], it was suggested that hugetlb
handling code in follow_page_mask could be simplified.  At the beginning
of follow_page_mask, there currently is a call to follow_huge_addr which
'may' handle hugetlb pages.  ia64 is the only architecture which provides
a follow_huge_addr routine that does not return error.  Instead, at each
level of the page table a check is made for a hugetlb entry.  If a hugetlb
entry is found, a call to a routine associated with that entry is made.

Currently, there are two checks for hugetlb entries at each page table
level.  The first check is of the form:
        if (p?d_huge())
                page = follow_huge_p?d();
the second check is of the form:
        if (is_hugepd())
                page = follow_huge_pd().

We can replace these checks, as well as the special handling routines
such as follow_huge_p?d() and follow_huge_pd() with a single routine to
handle hugetlb vmas.

A new routine hugetlb_follow_page_mask is called for hugetlb vmas at the
beginning of follow_page_mask.  hugetlb_follow_page_mask will use the
existing routine huge_pte_offset to walk page tables looking for hugetlb
entries.  huge_pte_offset can be overwritten by architectures, and already
handles special cases such as hugepd entries.

[1] https://lore.kernel.org/linux-mm/cover.1661240170.git.baolin.wang@linux.alibaba.com/

Suggested-by: David Hildenbrand <david@redhat.com>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
v5 -	Remove left over hugetlb_vma_unlock_read
v4 -    Remove vma (pmd sharing) locking as this can be called with
        FOLL_NOWAIT. Peter
v3 -    Change WARN_ON_ONCE() to BUILD_BUG() as reminded by Christophe Leroy
v2 -    Added WARN_ON_ONCE() and updated comment as suggested by David
        Fixed build issue found by kernel test robot
        Added vma (pmd sharing) locking to hugetlb_follow_page_mask
        ReBased on Baolin's patch to fix issues with CONT_* entries

 arch/ia64/mm/hugetlbpage.c    |  15 ---
 arch/powerpc/mm/hugetlbpage.c |  37 --------
 include/linux/hugetlb.h       |  50 ++--------
 mm/gup.c                      |  80 +++-------------
 mm/hugetlb.c                  | 172 +++++++++++-----------------------
 5 files changed, 76 insertions(+), 278 deletions(-)

diff --git a/arch/ia64/mm/hugetlbpage.c b/arch/ia64/mm/hugetlbpage.c
index f993cb36c062..380d2f3966c9 100644
--- a/arch/ia64/mm/hugetlbpage.c
+++ b/arch/ia64/mm/hugetlbpage.c
@@ -91,21 +91,6 @@ int prepare_hugepage_range(struct file *file,
 	return 0;
 }
 
-struct page *follow_huge_addr(struct mm_struct *mm, unsigned long addr, int write)
-{
-	struct page *page;
-	pte_t *ptep;
-
-	if (REGION_NUMBER(addr) != RGN_HPAGE)
-		return ERR_PTR(-EINVAL);
-
-	ptep = huge_pte_offset(mm, addr, HPAGE_SIZE);
-	if (!ptep || pte_none(*ptep))
-		return NULL;
-	page = pte_page(*ptep);
-	page += ((addr & ~HPAGE_MASK) >> PAGE_SHIFT);
-	return page;
-}
 int pmd_huge(pmd_t pmd)
 {
 	return 0;
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 5852a86d990d..f1ba8d1e8c1a 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -506,43 +506,6 @@ void hugetlb_free_pgd_range(struct mmu_gather *tlb,
 	} while (addr = next, addr != end);
 }
 
-struct page *follow_huge_pd(struct vm_area_struct *vma,
-			    unsigned long address, hugepd_t hpd,
-			    int flags, int pdshift)
-{
-	pte_t *ptep;
-	spinlock_t *ptl;
-	struct page *page = NULL;
-	unsigned long mask;
-	int shift = hugepd_shift(hpd);
-	struct mm_struct *mm = vma->vm_mm;
-
-retry:
-	/*
-	 * hugepage directory entries are protected by mm->page_table_lock
-	 * Use this instead of huge_pte_lockptr
-	 */
-	ptl = &mm->page_table_lock;
-	spin_lock(ptl);
-
-	ptep = hugepte_offset(hpd, address, pdshift);
-	if (pte_present(*ptep)) {
-		mask = (1UL << shift) - 1;
-		page = pte_page(*ptep);
-		page += ((address & mask) >> PAGE_SHIFT);
-		if (flags & FOLL_GET)
-			get_page(page);
-	} else {
-		if (is_hugetlb_entry_migration(*ptep)) {
-			spin_unlock(ptl);
-			__migration_entry_wait(mm, ptep, ptl);
-			goto retry;
-		}
-	}
-	spin_unlock(ptl);
-	return page;
-}
-
 bool __init arch_hugetlb_valid_size(unsigned long size)
 {
 	int shift = __ffs(size);
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 8b4f93e84868..4a76c0fc6bbf 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -149,6 +149,8 @@ int move_hugetlb_page_tables(struct vm_area_struct *vma,
 			     unsigned long len);
 int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *,
 			    struct vm_area_struct *, struct vm_area_struct *);
+struct page *hugetlb_follow_page_mask(struct vm_area_struct *vma,
+				unsigned long address, unsigned int flags);
 long follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *,
 			 struct page **, struct vm_area_struct **,
 			 unsigned long *, unsigned long *, long, unsigned int,
@@ -209,17 +211,6 @@ int huge_pmd_unshare(struct mm_struct *mm, struct vm_area_struct *vma,
 				unsigned long addr, pte_t *ptep);
 void adjust_range_if_pmd_sharing_possible(struct vm_area_struct *vma,
 				unsigned long *start, unsigned long *end);
-struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
-			      int write);
-struct page *follow_huge_pd(struct vm_area_struct *vma,
-			    unsigned long address, hugepd_t hpd,
-			    int flags, int pdshift);
-struct page *follow_huge_pmd_pte(struct vm_area_struct *vma, unsigned long address,
-				 int flags);
-struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
-				pud_t *pud, int flags);
-struct page *follow_huge_pgd(struct mm_struct *mm, unsigned long address,
-			     pgd_t *pgd, int flags);
 
 void hugetlb_vma_lock_read(struct vm_area_struct *vma);
 void hugetlb_vma_unlock_read(struct vm_area_struct *vma);
@@ -272,6 +263,12 @@ static inline void adjust_range_if_pmd_sharing_possible(
 {
 }
 
+static inline struct page *hugetlb_follow_page_mask(struct vm_area_struct *vma,
+				unsigned long address, unsigned int flags)
+{
+	BUILD_BUG(); /* should never be compiled in if !CONFIG_HUGETLB_PAGE*/
+}
+
 static inline long follow_hugetlb_page(struct mm_struct *mm,
 			struct vm_area_struct *vma, struct page **pages,
 			struct vm_area_struct **vmas, unsigned long *position,
@@ -282,12 +279,6 @@ static inline long follow_hugetlb_page(struct mm_struct *mm,
 	return 0;
 }
 
-static inline struct page *follow_huge_addr(struct mm_struct *mm,
-					unsigned long address, int write)
-{
-	return ERR_PTR(-EINVAL);
-}
-
 static inline int copy_hugetlb_page_range(struct mm_struct *dst,
 					  struct mm_struct *src,
 					  struct vm_area_struct *dst_vma,
@@ -320,31 +311,6 @@ static inline void hugetlb_show_meminfo_node(int nid)
 {
 }
 
-static inline struct page *follow_huge_pd(struct vm_area_struct *vma,
-				unsigned long address, hugepd_t hpd, int flags,
-				int pdshift)
-{
-	return NULL;
-}
-
-static inline struct page *follow_huge_pmd_pte(struct vm_area_struct *vma,
-				unsigned long address, int flags)
-{
-	return NULL;
-}
-
-static inline struct page *follow_huge_pud(struct mm_struct *mm,
-				unsigned long address, pud_t *pud, int flags)
-{
-	return NULL;
-}
-
-static inline struct page *follow_huge_pgd(struct mm_struct *mm,
-				unsigned long address, pgd_t *pgd, int flags)
-{
-	return NULL;
-}
-
 static inline int prepare_hugepage_range(struct file *file,
 				unsigned long addr, unsigned long len)
 {
diff --git a/mm/gup.c b/mm/gup.c
index fe195d47de74..6b16aecf5d2c 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -537,18 +537,6 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 	if (WARN_ON_ONCE((flags & (FOLL_PIN | FOLL_GET)) =
 			 (FOLL_PIN | FOLL_GET)))
 		return ERR_PTR(-EINVAL);
-
-	/*
-	 * Considering PTE level hugetlb, like continuous-PTE hugetlb on
-	 * ARM64 architecture.
-	 */
-	if (is_vm_hugetlb_page(vma)) {
-		page = follow_huge_pmd_pte(vma, address, flags);
-		if (page)
-			return page;
-		return no_page_table(vma, flags);
-	}
-
 retry:
 	if (unlikely(pmd_bad(*pmd)))
 		return no_page_table(vma, flags);
@@ -680,20 +668,6 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 	pmdval = READ_ONCE(*pmd);
 	if (pmd_none(pmdval))
 		return no_page_table(vma, flags);
-	if (pmd_huge(pmdval) && is_vm_hugetlb_page(vma)) {
-		page = follow_huge_pmd_pte(vma, address, flags);
-		if (page)
-			return page;
-		return no_page_table(vma, flags);
-	}
-	if (is_hugepd(__hugepd(pmd_val(pmdval)))) {
-		page = follow_huge_pd(vma, address,
-				      __hugepd(pmd_val(pmdval)), flags,
-				      PMD_SHIFT);
-		if (page)
-			return page;
-		return no_page_table(vma, flags);
-	}
 retry:
 	if (!pmd_present(pmdval)) {
 		/*
@@ -783,20 +757,6 @@ static struct page *follow_pud_mask(struct vm_area_struct *vma,
 	pud = pud_offset(p4dp, address);
 	if (pud_none(*pud))
 		return no_page_table(vma, flags);
-	if (pud_huge(*pud) && is_vm_hugetlb_page(vma)) {
-		page = follow_huge_pud(mm, address, pud, flags);
-		if (page)
-			return page;
-		return no_page_table(vma, flags);
-	}
-	if (is_hugepd(__hugepd(pud_val(*pud)))) {
-		page = follow_huge_pd(vma, address,
-				      __hugepd(pud_val(*pud)), flags,
-				      PUD_SHIFT);
-		if (page)
-			return page;
-		return no_page_table(vma, flags);
-	}
 	if (pud_devmap(*pud)) {
 		ptl = pud_lock(mm, pud);
 		page = follow_devmap_pud(vma, address, pud, flags, &ctx->pgmap);
@@ -816,7 +776,6 @@ static struct page *follow_p4d_mask(struct vm_area_struct *vma,
 				    struct follow_page_context *ctx)
 {
 	p4d_t *p4d;
-	struct page *page;
 
 	p4d = p4d_offset(pgdp, address);
 	if (p4d_none(*p4d))
@@ -825,14 +784,6 @@ static struct page *follow_p4d_mask(struct vm_area_struct *vma,
 	if (unlikely(p4d_bad(*p4d)))
 		return no_page_table(vma, flags);
 
-	if (is_hugepd(__hugepd(p4d_val(*p4d)))) {
-		page = follow_huge_pd(vma, address,
-				      __hugepd(p4d_val(*p4d)), flags,
-				      P4D_SHIFT);
-		if (page)
-			return page;
-		return no_page_table(vma, flags);
-	}
 	return follow_pud_mask(vma, address, p4d, flags, ctx);
 }
 
@@ -870,10 +821,18 @@ static struct page *follow_page_mask(struct vm_area_struct *vma,
 
 	ctx->page_mask = 0;
 
-	/* make this handle hugepd */
-	page = follow_huge_addr(mm, address, flags & FOLL_WRITE);
-	if (!IS_ERR(page)) {
-		WARN_ON_ONCE(flags & (FOLL_GET | FOLL_PIN));
+	/*
+	 * Call hugetlb_follow_page_mask for hugetlb vmas as it will use
+	 * special hugetlb page table walking code.  This eliminates the
+	 * need to check for hugetlb entries in the general walking code.
+	 *
+	 * hugetlb_follow_page_mask is only for follow_page() handling here.
+	 * Ordinary GUP uses follow_hugetlb_page for hugetlb processing.
+	 */
+	if (is_vm_hugetlb_page(vma)) {
+		page = hugetlb_follow_page_mask(vma, address, flags);
+		if (!page)
+			page = no_page_table(vma, flags);
 		return page;
 	}
 
@@ -882,21 +841,6 @@ static struct page *follow_page_mask(struct vm_area_struct *vma,
 	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
 		return no_page_table(vma, flags);
 
-	if (pgd_huge(*pgd)) {
-		page = follow_huge_pgd(mm, address, pgd, flags);
-		if (page)
-			return page;
-		return no_page_table(vma, flags);
-	}
-	if (is_hugepd(__hugepd(pgd_val(*pgd)))) {
-		page = follow_huge_pd(vma, address,
-				      __hugepd(pgd_val(*pgd)), flags,
-				      PGDIR_SHIFT);
-		if (page)
-			return page;
-		return no_page_table(vma, flags);
-	}
-
 	return follow_p4d_mask(vma, address, pgd, flags, ctx);
 }
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 546df97c31e4..0af18c1e4b31 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -6209,6 +6209,62 @@ static inline bool __follow_hugetlb_must_fault(unsigned int flags, pte_t *pte,
 	return false;
 }
 
+struct page *hugetlb_follow_page_mask(struct vm_area_struct *vma,
+				unsigned long address, unsigned int flags)
+{
+	struct hstate *h = hstate_vma(vma);
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long haddr = address & huge_page_mask(h);
+	struct page *page = NULL;
+	spinlock_t *ptl;
+	pte_t *pte, entry;
+
+	/*
+	 * FOLL_PIN is not supported for follow_page(). Ordinary GUP goes via
+	 * follow_hugetlb_page().
+	 */
+	if (WARN_ON_ONCE(flags & FOLL_PIN))
+		return NULL;
+
+retry:
+	pte = huge_pte_offset(mm, haddr, huge_page_size(h));
+	if (!pte)
+		return NULL;
+
+	ptl = huge_pte_lock(h, mm, pte);
+	entry = huge_ptep_get(pte);
+	if (pte_present(entry)) {
+		page = pte_page(entry) +
+				((address & ~huge_page_mask(h)) >> PAGE_SHIFT);
+		/*
+		 * Note that page may be a sub-page, and with vmemmap
+		 * optimizations the page struct may be read only.
+		 * try_grab_page() will increase the ref count on the
+		 * head page, so this will be OK.
+		 *
+		 * try_grab_page() should always succeed here, because we hold
+		 * the ptl lock and have verified pte_present().
+		 */
+		if (WARN_ON_ONCE(!try_grab_page(page, flags))) {
+			page = NULL;
+			goto out;
+		}
+	} else {
+		if (is_hugetlb_entry_migration(entry)) {
+			spin_unlock(ptl);
+			__migration_entry_wait_huge(pte, ptl);
+			goto retry;
+		}
+		/*
+		 * hwpoisoned entry is treated as no_page_table in
+		 * follow_page_mask().
+		 */
+	}
+out:
+	spin_unlock(ptl);
+	return page;
+}
+
 long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			 struct page **pages, struct vm_area_struct **vmas,
 			 unsigned long *position, unsigned long *nr_pages,
@@ -7201,122 +7257,6 @@ __weak unsigned long hugetlb_mask_last_page(struct hstate *h)
  * These functions are overwritable if your architecture needs its own
  * behavior.
  */
-struct page * __weak
-follow_huge_addr(struct mm_struct *mm, unsigned long address,
-			      int write)
-{
-	return ERR_PTR(-EINVAL);
-}
-
-struct page * __weak
-follow_huge_pd(struct vm_area_struct *vma,
-	       unsigned long address, hugepd_t hpd, int flags, int pdshift)
-{
-	WARN(1, "hugepd follow called with no support for hugepage directory format\n");
-	return NULL;
-}
-
-struct page * __weak
-follow_huge_pmd_pte(struct vm_area_struct *vma, unsigned long address, int flags)
-{
-	struct hstate *h = hstate_vma(vma);
-	struct mm_struct *mm = vma->vm_mm;
-	struct page *page = NULL;
-	spinlock_t *ptl;
-	pte_t *ptep, pte;
-
-	/*
-	 * FOLL_PIN is not supported for follow_page(). Ordinary GUP goes via
-	 * follow_hugetlb_page().
-	 */
-	if (WARN_ON_ONCE(flags & FOLL_PIN))
-		return NULL;
-
-retry:
-	ptep = huge_pte_offset(mm, address, huge_page_size(h));
-	if (!ptep)
-		return NULL;
-
-	ptl = huge_pte_lock(h, mm, ptep);
-	pte = huge_ptep_get(ptep);
-	if (pte_present(pte)) {
-		page = pte_page(pte) +
-			((address & ~huge_page_mask(h)) >> PAGE_SHIFT);
-		/*
-		 * try_grab_page() should always succeed here, because: a) we
-		 * hold the pmd (ptl) lock, and b) we've just checked that the
-		 * huge pmd (head) page is present in the page tables. The ptl
-		 * prevents the head page and tail pages from being rearranged
-		 * in any way. So this page must be available at this point,
-		 * unless the page refcount overflowed:
-		 */
-		if (WARN_ON_ONCE(!try_grab_page(page, flags))) {
-			page = NULL;
-			goto out;
-		}
-	} else {
-		if (is_hugetlb_entry_migration(pte)) {
-			spin_unlock(ptl);
-			__migration_entry_wait_huge(ptep, ptl);
-			goto retry;
-		}
-		/*
-		 * hwpoisoned entry is treated as no_page_table in
-		 * follow_page_mask().
-		 */
-	}
-out:
-	spin_unlock(ptl);
-	return page;
-}
-
-struct page * __weak
-follow_huge_pud(struct mm_struct *mm, unsigned long address,
-		pud_t *pud, int flags)
-{
-	struct page *page = NULL;
-	spinlock_t *ptl;
-	pte_t pte;
-
-	if (WARN_ON_ONCE(flags & FOLL_PIN))
-		return NULL;
-
-retry:
-	ptl = huge_pte_lock(hstate_sizelog(PUD_SHIFT), mm, (pte_t *)pud);
-	if (!pud_huge(*pud))
-		goto out;
-	pte = huge_ptep_get((pte_t *)pud);
-	if (pte_present(pte)) {
-		page = pud_page(*pud) + ((address & ~PUD_MASK) >> PAGE_SHIFT);
-		if (WARN_ON_ONCE(!try_grab_page(page, flags))) {
-			page = NULL;
-			goto out;
-		}
-	} else {
-		if (is_hugetlb_entry_migration(pte)) {
-			spin_unlock(ptl);
-			__migration_entry_wait(mm, (pte_t *)pud, ptl);
-			goto retry;
-		}
-		/*
-		 * hwpoisoned entry is treated as no_page_table in
-		 * follow_page_mask().
-		 */
-	}
-out:
-	spin_unlock(ptl);
-	return page;
-}
-
-struct page * __weak
-follow_huge_pgd(struct mm_struct *mm, unsigned long address, pgd_t *pgd, int flags)
-{
-	if (flags & (FOLL_GET | FOLL_PIN))
-		return NULL;
-
-	return pte_page(*(pte_t *)pgd) + ((address & ~PGDIR_MASK) >> PAGE_SHIFT);
-}
-
 int isolate_hugetlb(struct page *page, struct list_head *list)
 {
 	int ret = 0;
-- 
2.37.3
