From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Wed, 31 Aug 2022 23:56:03 +0000
Subject: Re: [PATCH] hugetlb: simplify hugetlb handling in follow_page_mask
Message-Id: <Yw/2CDbFDX5cnB2o@monkey>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220829234053.159158-1-mike.kravetz@oracle.com>
 <57c8f032-e48a-bacb-7922-3e2cc10dc0d2@linux.alibaba.com>
 <Yw4+YvdS9kJUnx1s@monkey>
 <Yw5ZTEqxZCAgEbK9@monkey>
 <0a8025eb-cf15-453a-7d7d-7c72d008889a@linux.alibaba.com>
In-Reply-To: <0a8025eb-cf15-453a-7d7d-7c72d008889a@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Baolin Wang <baolin.wang@linux.alibaba.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, inuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, David Hildenbrand <david@redhat.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, Michael Ellerman <mpe@ellerman.id.au>, Muchun Song <songmuchun@bytedance.com>, Andrew Morton <akpm@linux-foundation.org>

On 08/31/22 09:07, Baolin Wang wrote:
> 
> 
> On 8/31/2022 2:39 AM, Mike Kravetz wrote:
> > On 08/30/22 09:44, Mike Kravetz wrote:
> > > On 08/30/22 09:06, Baolin Wang wrote:
> > > > Hi Mike,
> > > > 
> > > > On 8/30/2022 7:40 AM, Mike Kravetz wrote:
> > > > > During discussions of this series [1], it was suggested that hugetlb
> > > > > handling code in follow_page_mask could be simplified.  At the beginning
> > > > > of follow_page_mask, there currently is a call to follow_huge_addr which
> > > > > 'may' handle hugetlb pages.  ia64 is the only architecture which provides
> > > > > a follow_huge_addr routine that does not return error.  Instead, at each
> > > > > level of the page table a check is made for a hugetlb entry.  If a hugetlb
> > > > > entry is found, a call to a routine associated with that entry is made.
> > > > > 
> > > > > Currently, there are two checks for hugetlb entries at each page table
> > > > > level.  The first check is of the form:
> > > > > 	if (p?d_huge())
> > > > > 		page = follow_huge_p?d();
> > > > > the second check is of the form:
> > > > > 	if (is_hugepd())
> > > > > 		page = follow_huge_pd().
> > > > > 
> > > > > We can replace these checks, as well as the special handling routines
> > > > > such as follow_huge_p?d() and follow_huge_pd() with a single routine to
> > > > > handle hugetlb vmas.
> > > > > 
> > > > > A new routine hugetlb_follow_page_mask is called for hugetlb vmas at the
> > > > > beginning of follow_page_mask.  hugetlb_follow_page_mask will use the
> > > > > existing routine huge_pte_offset to walk page tables looking for hugetlb
> > > > > entries.  huge_pte_offset can be overwritten by architectures, and already
> > > > > handles special cases such as hugepd entries.
> > > > 
> > > > Could you also mention that this patch will fix the lock issue for
> > > > CONT-PTE/PMD hugetlb by changing to use huge_pte_lock()? which will help
> > > > people to understand the issue.
> > > 
> > > Will update message in v2.  Thanks for taking a look!
> > > 
> > 
> > One additional thought, we 'may' need a separate patch to fix the locking
> > issues that can be easily backported.  Not sure this 'simplification' is
> > a good backport candidate.
> 
> Yes, that was my thought before, but David did not like adding more
> make-legacy-cruft-happy code.
> 
> So how about creating a series that contains 3 patches: picking up patch 1
> and patch 3 of my previous series [1], and your current patch? That means
> patch 1 and patch 2 in this series can fix the lock issue explicitly and be
> suitable to backport, meanwhile patch 3 (which is your current patch) will
> cleanup the legacy code.
> 

When I looked at patch 3, I was thinking the update follow_huge_pmd routine
would work for the PTE level with a few more modifications.  Perhaps, this is
too ugly but it is a smaller set of changes for backport.

Of course, this would be followed up with the simplification patch which
removes all this code.
-- 
Mike Kravetz


diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 852f911d676e..b2050d22d855 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -207,8 +207,8 @@ struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
 struct page *follow_huge_pd(struct vm_area_struct *vma,
 			    unsigned long address, hugepd_t hpd,
 			    int flags, int pdshift);
-struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-				pmd_t *pmd, int flags);
+struct page *follow_huge_pmd_pte(struct vm_area_struct *vma, unsigned long address,
+				int flags);
 struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
 				pud_t *pud, int flags);
 struct page *follow_huge_pgd(struct mm_struct *mm, unsigned long address,
@@ -319,8 +319,8 @@ static inline struct page *follow_huge_pd(struct vm_area_struct *vma,
 	return NULL;
 }
 
-static inline struct page *follow_huge_pmd(struct mm_struct *mm,
-				unsigned long address, pmd_t *pmd, int flags)
+static inline struct page *follow_huge_pmd_pte(struct vm_area_struct *vma,
+				unsigned long address, int flags)
 {
 	return NULL;
 }
diff --git a/mm/gup.c b/mm/gup.c
index 66d8619e02ad..fda980b436ed 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -530,6 +530,13 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 	if (WARN_ON_ONCE((flags & (FOLL_PIN | FOLL_GET)) =
 			 (FOLL_PIN | FOLL_GET)))
 		return ERR_PTR(-EINVAL);
+
+	if (is_vm_hugetlb_page(vma)) {
+		page = follow_huge_pmd_pte(vma, address, flags);
+		if (page)
+			return page;
+		return no_page_table(vma, flags);
+	}
 retry:
 	if (unlikely(pmd_bad(*pmd)))
 		return no_page_table(vma, flags);
@@ -662,7 +669,7 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 	if (pmd_none(pmdval))
 		return no_page_table(vma, flags);
 	if (pmd_huge(pmdval) && is_vm_hugetlb_page(vma)) {
-		page = follow_huge_pmd(mm, address, pmd, flags);
+		page = follow_huge_pmd_pte(vma, address, flags);
 		if (page)
 			return page;
 		return no_page_table(vma, flags);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index d0617d64d718..e2e54dc27b00 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -7155,13 +7155,23 @@ follow_huge_pd(struct vm_area_struct *vma,
 	return NULL;
 }
 
+/*
+ * Temporarily handles both PMDs and PTEs.
+ * How can there be hugetlb entries at the PTE level?  One such example is
+ * CONT_PTE on arm64.
+ *
+ * The hack of handling both PMDs and PTEs is made for a stable backports.
+ * A cleanup and removal of this code is made upstream.
+ */
 struct page * __weak
-follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-		pmd_t *pmd, int flags)
+follow_huge_pmd_pte(struct vm_area_struct *vma, unsigned long address,
+								int flags)
 {
+	struct hstate *h = hstate_vma(vma);
+	struct mm_struct *mm = vma->vm_mm;
 	struct page *page = NULL;
 	spinlock_t *ptl;
-	pte_t pte;
+	pte_t *ptep, pte;
 
 	/*
 	 * FOLL_PIN is not supported for follow_page(). Ordinary GUP goes via
@@ -7171,17 +7181,15 @@ follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 		return NULL;
 
 retry:
-	ptl = pmd_lockptr(mm, pmd);
-	spin_lock(ptl);
-	/*
-	 * make sure that the address range covered by this pmd is not
-	 * unmapped from other threads.
-	 */
-	if (!pmd_huge(*pmd))
+	ptep = huge_pte_offset(mm, address, huge_page_size(h));
+	if (!ptep)
 		goto out;
-	pte = huge_ptep_get((pte_t *)pmd);
+
+	ptl = huge_pte_lock(h, mm, ptep);
+	pte = huge_ptep_get(ptep);
 	if (pte_present(pte)) {
-		page = pmd_page(*pmd) + ((address & ~PMD_MASK) >> PAGE_SHIFT);
+		page = pte_page(pte) +
+			((address & ~huge_page_mask(h)) >> PAGE_SHIFT);
 		/*
 		 * try_grab_page() should always succeed here, because: a) we
 		 * hold the pmd (ptl) lock, and b) we've just checked that the
@@ -7197,7 +7205,7 @@ follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 	} else {
 		if (is_hugetlb_entry_migration(pte)) {
 			spin_unlock(ptl);
-			__migration_entry_wait_huge((pte_t *)pmd, ptl);
+			__migration_entry_wait_huge(ptep, ptl);
 			goto retry;
 		}
 		/*
