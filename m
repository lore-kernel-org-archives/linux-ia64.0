From: Peter Xu <peterx@redhat.com>
Date: Thu, 27 Oct 2022 19:34:44 +0000
Subject: Re: [PATCH v3] hugetlb: simplify hugetlb handling in follow_page_mask
Message-Id: <Y1rdVLMDD4PMt3s3@x1n>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220919021348.22151-1-mike.kravetz@oracle.com>
 <Y1mtz7dFAlhGRsAd@x1n>
 <Y1nR/KToV44GKZ5G@monkey>
In-Reply-To: <Y1nR/KToV44GKZ5G@monkey>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, Baolin Wang <baolin.wang@linux.alibaba.com>, David Hildenbrand <david@redhat.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, Michael Ellerman <mpe@ellerman.id.au>, Muchun Song <songmuchun@bytedance.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Oct 26, 2022 at 05:34:04PM -0700, Mike Kravetz wrote:
> On 10/26/22 17:59, Peter Xu wrote:
> > Hi, Mike,
> > 
> > On Sun, Sep 18, 2022 at 07:13:48PM -0700, Mike Kravetz wrote:
> > > +struct page *hugetlb_follow_page_mask(struct vm_area_struct *vma,
> > > +				unsigned long address, unsigned int flags)
> > > +{
> > > +	struct hstate *h = hstate_vma(vma);
> > > +	struct mm_struct *mm = vma->vm_mm;
> > > +	unsigned long haddr = address & huge_page_mask(h);
> > > +	struct page *page = NULL;
> > > +	spinlock_t *ptl;
> > > +	pte_t *pte, entry;
> > > +
> > > +	/*
> > > +	 * FOLL_PIN is not supported for follow_page(). Ordinary GUP goes via
> > > +	 * follow_hugetlb_page().
> > > +	 */
> > > +	if (WARN_ON_ONCE(flags & FOLL_PIN))
> > > +		return NULL;
> > > +
> > > +retry:
> > > +	/*
> > > +	 * vma lock prevents racing with another thread doing a pmd unshare.
> > > +	 * This keeps pte as returned by huge_pte_offset valid.
> > > +	 */
> > > +	hugetlb_vma_lock_read(vma);
> > 
> > I'm not sure whether it's okay to take a rwsem here, as the code can be
> > called by e.g. FOLL_NOWAIT?
> 
> I think you are right.  This is possible even thought not called this
> way today,
> 
> > I'm wondering whether it's fine to just drop this anyway, just always walk
> > it lockless.  IIUC gup callers should be safe here because the worst case
> > is the caller will fetch a wrong page, but then it should be invalidated
> > very soon with mmu notifiers.  One thing worth mention is that pmd unshare
> > should never free a pgtable page.
> 
> You are correct in that pmd unshare will not directly free a pgtable page.
> However, I think a 'very worst case' race could be caused by two threads(1,2)
> in the same process A, and another process B.  Processes A and B share a PMD.
> - Process A thread 1 gets a *ptep via huge_pte_offset and gets scheduled out.
> - Process A thread 2 calls mprotect to change protection and unshares
>   the PMD shared with process B.
> - Process B then unmaps the PMD shared with process A and the PMD page
>   gets deleted.

[2]

> - The *ptep in Process A thread 1 then points into a freed page.
> This is VERY unlikely, but I do think it is possible and is the reason I
> may be overcautious about protecting against races with pmd unshare.

Yes this is possible, I just realized that actually huge_pte_offset() is a
soft pgtable walker too.  Thanks for pointing that out.

If we want to use the vma read lock to protect here as the slow gup path,
then please check again with below [1] - I think we'll also need to protect
it with fast-gup (probably with trylock only, because fast-gup cannot
sleep) or it'll encounter the same race, iiuc.

Actually, instead of using vma lock, I really think this is another problem
and needs standalone fixing.  The problem is we allows huge_pte_offset() to
walk the process pgtable without any protection, while pmd unsharing can
drop a page anytime.  huge_pte_offset() is always facing use-after-free
when walking the PUD page.

We may want RCU lock to protect the pgtable pages from getting away when
huge_pte_offset() is walking it, it'll be safe then because pgtable pages
are released in RCU fashion only (e.g. in above example, process [2] will
munmap() and release the last ref to the "used to be shared" pmd and the
PUD that maps the shared pmds will be released only after a RCU grace
period), and afaict that's also what's protecting fast-gup from accessing
freed pgtable pages.

If with all huge_pte_offset() callers becoming RCU-safe, then IIUC we can
drop the vma lock in all GUP code, aka, in hugetlb_follow_page_mask() here,
because both slow and fast gup should be safe too in the same manner.

Thanks,

> > IIUC it's also the same as fast-gup - afaiu we don't take the read vma lock
> > in fast-gup too but I also think it's safe.  But I hope I didn't miss
> > something.

[1]

-- 
Peter Xu
