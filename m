From: Peter Xu <peterx@redhat.com>
Date: Fri, 28 Oct 2022 15:57:59 +0000
Subject: Re: [PATCH v3] hugetlb: simplify hugetlb handling in follow_page_mask
Message-Id: <Y1v8B/6QYwt5hUgU@x1n>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="oZ7pR8BiPAaKWB7x"
List-Id: <linux-ia64.vger.kernel.org>
References: <20220919021348.22151-1-mike.kravetz@oracle.com>
 <Y1mtz7dFAlhGRsAd@x1n>
 <Y1nR/KToV44GKZ5G@monkey>
 <Y1rdVLMDD4PMt3s3@x1n>
 <Y1v0/Y4Xiut2FWx4@monkey>
In-Reply-To: <Y1v0/Y4Xiut2FWx4@monkey>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, Baolin Wang <baolin.wang@linux.alibaba.com>, David Hildenbrand <david@redhat.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, Michael Ellerman <mpe@ellerman.id.au>, Muchun Song <songmuchun@bytedance.com>, Andrew Morton <akpm@linux-foundation.org>


--oZ7pR8BiPAaKWB7x
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

On Fri, Oct 28, 2022 at 08:27:57AM -0700, Mike Kravetz wrote:
> On 10/27/22 15:34, Peter Xu wrote:
> > On Wed, Oct 26, 2022 at 05:34:04PM -0700, Mike Kravetz wrote:
> > > On 10/26/22 17:59, Peter Xu wrote:
> > 
> > If we want to use the vma read lock to protect here as the slow gup path,
> > then please check again with below [1] - I think we'll also need to protect
> > it with fast-gup (probably with trylock only, because fast-gup cannot
> > sleep) or it'll encounter the same race, iiuc.
> > 
> > Actually, instead of using vma lock, I really think this is another problem
> > and needs standalone fixing.  The problem is we allows huge_pte_offset() to
> > walk the process pgtable without any protection, while pmd unsharing can
> > drop a page anytime.  huge_pte_offset() is always facing use-after-free
> > when walking the PUD page.
> > 
> > We may want RCU lock to protect the pgtable pages from getting away when
> > huge_pte_offset() is walking it, it'll be safe then because pgtable pages
> > are released in RCU fashion only (e.g. in above example, process [2] will
> > munmap() and release the last ref to the "used to be shared" pmd and the
> > PUD that maps the shared pmds will be released only after a RCU grace
> > period), and afaict that's also what's protecting fast-gup from accessing
> > freed pgtable pages.
> > 
> > If with all huge_pte_offset() callers becoming RCU-safe, then IIUC we can
> > drop the vma lock in all GUP code, aka, in hugetlb_follow_page_mask() here,
> > because both slow and fast gup should be safe too in the same manner.
> > 
> > Thanks,
> > 
> > > > IIUC it's also the same as fast-gup - afaiu we don't take the read vma lock
> > > > in fast-gup too but I also think it's safe.  But I hope I didn't miss
> > > > something.
> > 
> > [1]
> 
> Thanks Peter!  I think the best thing would be to eliminate the vma_lock
> calls in this patch.  The code it is replacing/simplifying does not do any
> locking, so no real regression.

Agreed.

> 
> I think a scheme like you describe above is going to require some more
> thought/work.  It might be better as a follow on patch.

So above is only a thought, but if you think it's so far not very wrong and
worth trying, I can see what I can get from it by some upcoming patches.

It shouldn't need a lot of change, but basically looking after all
huge_pte_offset() to make sure they're safe regarding walking the PUD.  I'm
attaching an initial patch to just start to comment on the usage of
huge_pte_offset() first because that'll be the gust of the upcoming
patchset (if there'll be), further comments welcomed too.  Thanks.

-- 
Peter Xu

--oZ7pR8BiPAaKWB7x
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment;
	filename="0001-mm-hugetlb-Comment-huge_pte_offset-for-its-locking-r.patch"

From 186c56026ce8ccc555d3c7ebc0e7e8fd76e9e5c9 Mon Sep 17 00:00:00 2001
From: Peter Xu <peterx@redhat.com>
Date: Thu, 27 Oct 2022 17:41:11 -0400
Subject: [PATCH] mm/hugetlb: Comment huge_pte_offset() for its locking
 requirements
Content-type: text/plain

huge_pte_offset() is potentially a pgtable walker, looking up pte_t* for a
hugetlb address.

Normally, it's always safe to walk the pgtable as long as we're with the
mmap lock held for either read or write, because that guarantees the
pgtable pages will always be valid during the process.

But it's not true for hugetlbfs: hugetlbfs has the pmd sharing feature, it
means that even with mmap lock held, the PUD pgtable page can still go away
from under us if pmd unsharing is possible during the walk.

It's not always the case, e.g.:

  (1) If the mapping is private we're not prone to pmd sharing or
      unsharing, so it's okay.

  (2) If we're with the hugetlb vma lock held for either read/write, it's
      okay too because pmd unshare cannot happen at all.

Document all these explicitly for huge_pte_offset(), because it's really
not that obvious.  This also tells all the callers on what it needs to
guarantee huge_pte_offset() thread-safety.

Signed-off-by: Peter Xu <peterx@redhat.com>
---
 arch/arm64/mm/hugetlbpage.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index 35e9a468d13e..90f084643718 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -329,6 +329,35 @@ pte_t *huge_pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
 	return ptep;
 }
 
+/*
+ * huge_pte_offset(): Walk the hugetlb pgtable until the last level PTE.
+ * Returns the pte_t* if found, or NULL if the address is not mapped.
+ *
+ * NOTE: since this function will walk all the pgtable pages (including not
+ * only normal pgtable page, but also PUD that can be unshared concurrently
+ * for VM_SHARED), the caller of this function should be responsible of its
+ * thread safety.  One can follow this rule:
+ *
+ *  (1) For private mappings: pmd unsharing is not possible, so it'll
+ *      always be safe if we're with the mmap sem for either read or write.
+ *      This is normally always the case, so IOW we don't need to do
+ *      anything special.
+ *
+ *  (2) For shared mappings: pmd unsharing is possible (so PUD page can go
+ *      away from under us!  It can be done by a pmd unshare with a follow
+ *      up munmap() on the other process), then we need either:
+ *
+ *     (2.1) hugetlb vma lock read or write held, to make sure pmd unshare
+ *           won't happen upon the range, or,
+ *
+ *     (2.2) RCU read lock, to make sure even pmd unsharing happened, the
+ *           old shared PUD page won't get freed from under us, so even of
+ *           the pte_t* can be obsolete, at least it's still always safe to
+ *           access the PUD page.
+ *
+ * PS: from the regard of (2.2), it's the same logic of fast-gup being safe
+ * for generic mm, as long as RCU is used to free any pgtable page.
+ */
 pte_t *huge_pte_offset(struct mm_struct *mm,
 		       unsigned long addr, unsigned long sz)
 {
-- 
2.37.3


--oZ7pR8BiPAaKWB7x--
