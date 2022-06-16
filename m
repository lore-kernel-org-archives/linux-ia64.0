From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Thu, 16 Jun 2022 21:05:15 +0000
Subject: [PATCH 1/4] hugetlb: skip to end of PT page mapping when pte not present
Message-Id: <20220616210518.125287-2-mike.kravetz@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220616210518.125287-1-mike.kravetz@oracle.com>
In-Reply-To: <20220616210518.125287-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: Muchun Song <songmuchun@bytedance.com>, Baolin Wang <baolin.wang@linux.alibaba.com>, Michal Hocko <mhocko@suse.com>, Peter Xu <peterx@redhat.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, James Houghton <jthoughton@google.com>, Mina Almasry <almasrymina@google.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <anshuman.khandual@arm.com>, Paul Walmsley <paul.walmsley@sifive.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, catalin.marinas@arm.com, will@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

HugeTLB address ranges are linearly scanned during fork, unmap and
remap operations.  If a non-present entry is encountered, the code
currently continues to the next huge page aligned address.  However,
a non-present entry implies that the page table page for that entry
is not present.  Therefore, the linear scan can skip to the end of
range mapped by the page table page.  This can speed operations on
large sparsely populated hugetlb mappings.

Create a new routine hugetlb_mask_last_page() that will return an
address mask.  When the mask is ORed with an address, the result
will be the address of the last huge page mapped by the associated
page table page.  Use this mask to update addresses in routines which
linearly scan hugetlb address ranges when a non-present pte is
encountered.

hugetlb_mask_last_page is related to the implementation of
huge_pte_offset as hugetlb_mask_last_page is called when huge_pte_offset
returns NULL.  This patch only provides a complete hugetlb_mask_last_page
implementation when CONFIG_ARCH_WANT_GENERAL_HUGETLB is defined.
Architectures which provide their own versions of huge_pte_offset can also
provide their own version of hugetlb_mask_last_page.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Tested-by: Baolin Wang <baolin.wang@linux.alibaba.com>
Reviewed-by: Baolin Wang <baolin.wang@linux.alibaba.com>
---
 include/linux/hugetlb.h |  1 +
 mm/hugetlb.c            | 62 +++++++++++++++++++++++++++++++++++++----
 2 files changed, 58 insertions(+), 5 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 642a39016f9a..e37465e830fe 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -197,6 +197,7 @@ pte_t *huge_pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long addr, unsigned long sz);
 pte_t *huge_pte_offset(struct mm_struct *mm,
 		       unsigned long addr, unsigned long sz);
+unsigned long hugetlb_mask_last_page(struct hstate *h);
 int huge_pmd_unshare(struct mm_struct *mm, struct vm_area_struct *vma,
 				unsigned long *addr, pte_t *ptep);
 void adjust_range_if_pmd_sharing_possible(struct vm_area_struct *vma,
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 259b9c41892f..7c4a82848603 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4740,6 +4740,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	unsigned long npages = pages_per_huge_page(h);
 	struct address_space *mapping = src_vma->vm_file->f_mapping;
 	struct mmu_notifier_range range;
+	unsigned long last_addr_mask;
 	int ret = 0;
 
 	if (cow) {
@@ -4759,11 +4760,14 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 		i_mmap_lock_read(mapping);
 	}
 
+	last_addr_mask = hugetlb_mask_last_page(h);
 	for (addr = src_vma->vm_start; addr < src_vma->vm_end; addr += sz) {
 		spinlock_t *src_ptl, *dst_ptl;
 		src_pte = huge_pte_offset(src, addr, sz);
-		if (!src_pte)
+		if (!src_pte) {
+			addr |= last_addr_mask;
 			continue;
+		}
 		dst_pte = huge_pte_alloc(dst, dst_vma, addr, sz);
 		if (!dst_pte) {
 			ret = -ENOMEM;
@@ -4780,8 +4784,10 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 		 * after taking the lock below.
 		 */
 		dst_entry = huge_ptep_get(dst_pte);
-		if ((dst_pte = src_pte) || !huge_pte_none(dst_entry))
+		if ((dst_pte = src_pte) || !huge_pte_none(dst_entry)) {
+			addr |= last_addr_mask;
 			continue;
+		}
 
 		dst_ptl = huge_pte_lock(h, dst, dst_pte);
 		src_ptl = huge_pte_lockptr(h, src, src_pte);
@@ -4942,6 +4948,7 @@ int move_hugetlb_page_tables(struct vm_area_struct *vma,
 	unsigned long sz = huge_page_size(h);
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long old_end = old_addr + len;
+	unsigned long last_addr_mask;
 	unsigned long old_addr_copy;
 	pte_t *src_pte, *dst_pte;
 	struct mmu_notifier_range range;
@@ -4957,12 +4964,16 @@ int move_hugetlb_page_tables(struct vm_area_struct *vma,
 	flush_cache_range(vma, range.start, range.end);
 
 	mmu_notifier_invalidate_range_start(&range);
+	last_addr_mask = hugetlb_mask_last_page(h);
 	/* Prevent race with file truncation */
 	i_mmap_lock_write(mapping);
 	for (; old_addr < old_end; old_addr += sz, new_addr += sz) {
 		src_pte = huge_pte_offset(mm, old_addr, sz);
-		if (!src_pte)
+		if (!src_pte) {
+			old_addr |= last_addr_mask;
+			new_addr |= last_addr_mask;
 			continue;
+		}
 		if (huge_pte_none(huge_ptep_get(src_pte)))
 			continue;
 
@@ -5007,6 +5018,7 @@ static void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct
 	struct hstate *h = hstate_vma(vma);
 	unsigned long sz = huge_page_size(h);
 	struct mmu_notifier_range range;
+	unsigned long last_addr_mask;
 	bool force_flush = false;
 
 	WARN_ON(!is_vm_hugetlb_page(vma));
@@ -5027,11 +5039,14 @@ static void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct
 				end);
 	adjust_range_if_pmd_sharing_possible(vma, &range.start, &range.end);
 	mmu_notifier_invalidate_range_start(&range);
+	last_addr_mask = hugetlb_mask_last_page(h);
 	address = start;
 	for (; address < end; address += sz) {
 		ptep = huge_pte_offset(mm, address, sz);
-		if (!ptep)
+		if (!ptep) {
+			address |= last_addr_mask;
 			continue;
+		}
 
 		ptl = huge_pte_lock(h, mm, ptep);
 		if (huge_pmd_unshare(mm, vma, &address, ptep)) {
@@ -6305,6 +6320,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	unsigned long pages = 0, psize = huge_page_size(h);
 	bool shared_pmd = false;
 	struct mmu_notifier_range range;
+	unsigned long last_addr_mask;
 	bool uffd_wp = cp_flags & MM_CP_UFFD_WP;
 	bool uffd_wp_resolve = cp_flags & MM_CP_UFFD_WP_RESOLVE;
 
@@ -6321,12 +6337,15 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	flush_cache_range(vma, range.start, range.end);
 
 	mmu_notifier_invalidate_range_start(&range);
+	last_addr_mask = hugetlb_mask_last_page(h);
 	i_mmap_lock_write(vma->vm_file->f_mapping);
 	for (; address < end; address += psize) {
 		spinlock_t *ptl;
 		ptep = huge_pte_offset(mm, address, psize);
-		if (!ptep)
+		if (!ptep) {
+			address |= last_addr_mask;
 			continue;
+		}
 		ptl = huge_pte_lock(h, mm, ptep);
 		if (huge_pmd_unshare(mm, vma, &address, ptep)) {
 			/*
@@ -6877,6 +6896,39 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
 	return (pte_t *)pmd;
 }
 
+/*
+ * Return a mask that can be used to update an address to the last huge
+ * page in a page table page mapping size.  Used to skip non-present
+ * page table entries when linearly scanning address ranges.  Architectures
+ * with unique huge page to page table relationships can define their own
+ * version of this routine.
+ */
+unsigned long hugetlb_mask_last_page(struct hstate *h)
+{
+	unsigned long hp_size = huge_page_size(h);
+
+	switch (hp_size) {
+	case P4D_SIZE:
+		return PGDIR_SIZE - P4D_SIZE;
+	case PUD_SIZE:
+		return P4D_SIZE - PUD_SIZE;
+	case PMD_SIZE:
+		return PUD_SIZE - PMD_SIZE;
+	default:
+		break; /* Should never happen */
+	}
+
+	return ~(0UL);
+}
+
+#else
+
+/* See description above.  Architectures can provide their own version. */
+__weak unsigned long hugetlb_mask_last_page(struct hstate *h)
+{
+	return ~(0UL);
+}
+
 #endif /* CONFIG_ARCH_WANT_GENERAL_HUGETLB */
 
 /*
-- 
2.35.3
