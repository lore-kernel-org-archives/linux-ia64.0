From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Tue, 21 Jun 2022 23:56:19 +0000
Subject: [PATCH v2 3/4] hugetlb: do not update address in huge_pmd_unshare
Message-Id: <20220621235620.291305-4-mike.kravetz@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220621235620.291305-1-mike.kravetz@oracle.com>
In-Reply-To: <20220621235620.291305-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: Muchun Song <songmuchun@bytedance.com>, Baolin Wang <baolin.wang@linux.alibaba.com>, Michal Hocko <mhocko@suse.com>, Peter Xu <peterx@redhat.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, James Houghton <jthoughton@google.com>, Mina Almasry <almasrymina@google.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <anshuman.khandual@arm.com>, Paul Walmsley <paul.walmsley@sifive.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, catalin.marinas@arm.com, will@kernel.org, Rolf Eike Beer <eike-kernel@sf-tec.de>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

As an optimization for loops sequentially processing hugetlb address
ranges, huge_pmd_unshare would update a passed address if it unshared a
pmd.  Updating a loop control variable outside the loop like this is
generally a bad idea.  These loops are now using hugetlb_mask_last_page
to optimize scanning when non-present ptes are discovered.  The same
can be done when huge_pmd_unshare returns 1 indicating a pmd was
unshared.

Remove address update from huge_pmd_unshare.  Change the passed argument
type and update all callers.  In loops sequentially processing addresses
use hugetlb_mask_last_page to update address if pmd is unshared.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Acked-by: Muchun Song <songmuchun@bytedance.com>
Reviewed-by: Baolin Wang <baolin.wang@linux.alibaba.com>
---
 include/linux/hugetlb.h |  4 ++--
 mm/hugetlb.c            | 46 +++++++++++++++++------------------------
 mm/rmap.c               |  4 ++--
 3 files changed, 23 insertions(+), 31 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index e37465e830fe..ee9a28ef26ee 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -199,7 +199,7 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
 		       unsigned long addr, unsigned long sz);
 unsigned long hugetlb_mask_last_page(struct hstate *h);
 int huge_pmd_unshare(struct mm_struct *mm, struct vm_area_struct *vma,
-				unsigned long *addr, pte_t *ptep);
+				unsigned long addr, pte_t *ptep);
 void adjust_range_if_pmd_sharing_possible(struct vm_area_struct *vma,
 				unsigned long *start, unsigned long *end);
 struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
@@ -246,7 +246,7 @@ static inline struct address_space *hugetlb_page_mapping_lock_write(
 
 static inline int huge_pmd_unshare(struct mm_struct *mm,
 					struct vm_area_struct *vma,
-					unsigned long *addr, pte_t *ptep)
+					unsigned long addr, pte_t *ptep)
 {
 	return 0;
 }
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 0e4877cea62e..2e4a92cebd9c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4945,7 +4945,6 @@ int move_hugetlb_page_tables(struct vm_area_struct *vma,
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long old_end = old_addr + len;
 	unsigned long last_addr_mask;
-	unsigned long old_addr_copy;
 	pte_t *src_pte, *dst_pte;
 	struct mmu_notifier_range range;
 	bool shared_pmd = false;
@@ -4973,14 +4972,10 @@ int move_hugetlb_page_tables(struct vm_area_struct *vma,
 		if (huge_pte_none(huge_ptep_get(src_pte)))
 			continue;
 
-		/* old_addr arg to huge_pmd_unshare() is a pointer and so the
-		 * arg may be modified. Pass a copy instead to preserve the
-		 * value in old_addr.
-		 */
-		old_addr_copy = old_addr;
-
-		if (huge_pmd_unshare(mm, vma, &old_addr_copy, src_pte)) {
+		if (huge_pmd_unshare(mm, vma, old_addr, src_pte)) {
 			shared_pmd = true;
+			old_addr |= last_addr_mask;
+			new_addr |= last_addr_mask;
 			continue;
 		}
 
@@ -5045,10 +5040,11 @@ static void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct
 		}
 
 		ptl = huge_pte_lock(h, mm, ptep);
-		if (huge_pmd_unshare(mm, vma, &address, ptep)) {
+		if (huge_pmd_unshare(mm, vma, address, ptep)) {
 			spin_unlock(ptl);
 			tlb_flush_pmd_range(tlb, address & PUD_MASK, PUD_SIZE);
 			force_flush = true;
+			address |= last_addr_mask;
 			continue;
 		}
 
@@ -6343,7 +6339,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 			continue;
 		}
 		ptl = huge_pte_lock(h, mm, ptep);
-		if (huge_pmd_unshare(mm, vma, &address, ptep)) {
+		if (huge_pmd_unshare(mm, vma, address, ptep)) {
 			/*
 			 * When uffd-wp is enabled on the vma, unshare
 			 * shouldn't happen at all.  Warn about it if it
@@ -6353,6 +6349,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 			pages++;
 			spin_unlock(ptl);
 			shared_pmd = true;
+			address |= last_addr_mask;
 			continue;
 		}
 		pte = huge_ptep_get(ptep);
@@ -6776,11 +6773,11 @@ pte_t *huge_pmd_share(struct mm_struct *mm, struct vm_area_struct *vma,
  *	    0 the underlying pte page is not shared, or it is the last user
  */
 int huge_pmd_unshare(struct mm_struct *mm, struct vm_area_struct *vma,
-					unsigned long *addr, pte_t *ptep)
+					unsigned long addr, pte_t *ptep)
 {
-	pgd_t *pgd = pgd_offset(mm, *addr);
-	p4d_t *p4d = p4d_offset(pgd, *addr);
-	pud_t *pud = pud_offset(p4d, *addr);
+	pgd_t *pgd = pgd_offset(mm, addr);
+	p4d_t *p4d = p4d_offset(pgd, addr);
+	pud_t *pud = pud_offset(p4d, addr);
 
 	i_mmap_assert_write_locked(vma->vm_file->f_mapping);
 	BUG_ON(page_count(virt_to_page(ptep)) = 0);
@@ -6790,14 +6787,6 @@ int huge_pmd_unshare(struct mm_struct *mm, struct vm_area_struct *vma,
 	pud_clear(pud);
 	put_page(virt_to_page(ptep));
 	mm_dec_nr_pmds(mm);
-	/*
-	 * This update of passed address optimizes loops sequentially
-	 * processing addresses in increments of huge page size (PMD_SIZE
-	 * in this case).  By clearing the pud, a PUD_SIZE area is unmapped.
-	 * Update address to the 'last page' in the cleared area so that
-	 * calling loop can move to first page past this area.
-	 */
-	*addr |= PUD_SIZE - PMD_SIZE;
 	return 1;
 }
 
@@ -6809,7 +6798,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, struct vm_area_struct *vma,
 }
 
 int huge_pmd_unshare(struct mm_struct *mm, struct vm_area_struct *vma,
-				unsigned long *addr, pte_t *ptep)
+				unsigned long addr, pte_t *ptep)
 {
 	return 0;
 }
@@ -6916,6 +6905,12 @@ unsigned long hugetlb_mask_last_page(struct hstate *h)
 /* See description above.  Architectures can provide their own version. */
 __weak unsigned long hugetlb_mask_last_page(struct hstate *h)
 {
+	unsigned long hp_size = huge_page_size(h);
+
+#ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
+	if (hp_size = PMD_SIZE)
+		return PUD_SIZE - PMD_SIZE;
+#endif
 	return 0UL;
 }
 
@@ -7142,14 +7137,11 @@ void hugetlb_unshare_all_pmds(struct vm_area_struct *vma)
 	mmu_notifier_invalidate_range_start(&range);
 	i_mmap_lock_write(vma->vm_file->f_mapping);
 	for (address = start; address < end; address += PUD_SIZE) {
-		unsigned long tmp = address;
-
 		ptep = huge_pte_offset(mm, address, sz);
 		if (!ptep)
 			continue;
 		ptl = huge_pte_lock(h, mm, ptep);
-		/* We don't want 'address' to be changed */
-		huge_pmd_unshare(mm, vma, &tmp, ptep);
+		huge_pmd_unshare(mm, vma, address, ptep);
 		spin_unlock(ptl);
 	}
 	flush_hugetlb_tlb_range(vma, start, end);
diff --git a/mm/rmap.c b/mm/rmap.c
index 04fac1af870b..1c22e5e1219a 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1559,7 +1559,7 @@ static bool try_to_unmap_one(struct folio *folio, struct vm_area_struct *vma,
 				 */
 				VM_BUG_ON(!(flags & TTU_RMAP_LOCKED));
 
-				if (huge_pmd_unshare(mm, vma, &address, pvmw.pte)) {
+				if (huge_pmd_unshare(mm, vma, address, pvmw.pte)) {
 					flush_tlb_range(vma, range.start, range.end);
 					mmu_notifier_invalidate_range(mm, range.start,
 								      range.end);
@@ -1923,7 +1923,7 @@ static bool try_to_migrate_one(struct folio *folio, struct vm_area_struct *vma,
 				 */
 				VM_BUG_ON(!(flags & TTU_RMAP_LOCKED));
 
-				if (huge_pmd_unshare(mm, vma, &address, pvmw.pte)) {
+				if (huge_pmd_unshare(mm, vma, address, pvmw.pte)) {
 					flush_tlb_range(vma, range.start, range.end);
 					mmu_notifier_invalidate_range(mm, range.start,
 								      range.end);
-- 
2.35.3
