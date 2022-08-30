From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Tue, 30 Aug 2022 16:52:09 +0000
Subject: Re: [PATCH] hugetlb: simplify hugetlb handling in follow_page_mask
Message-Id: <Yw5AOZ/Kc5f3UP+s@monkey>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220829234053.159158-1-mike.kravetz@oracle.com>
 <608934d4-466d-975e-6458-34a91ccb4669@redhat.com>
In-Reply-To: <608934d4-466d-975e-6458-34a91ccb4669@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, inuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, Baolin Wang <baolin.wang@linux.alibaba.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, Michael Ellerman <mpe@ellerman.id.au>, Muchun Song <songmuchun@bytedance.com>, Andrew Morton <akpm@linux-foundation.org>

On 08/30/22 10:11, David Hildenbrand wrote:
> On 30.08.22 01:40, Mike Kravetz wrote:
> > During discussions of this series [1], it was suggested that hugetlb
> > handling code in follow_page_mask could be simplified.  At the beginning
> 
> Feel free to use a Suggested-by if you consider it appropriate.
> 
> > of follow_page_mask, there currently is a call to follow_huge_addr which
> > 'may' handle hugetlb pages.  ia64 is the only architecture which provides
> > a follow_huge_addr routine that does not return error.  Instead, at each
> > level of the page table a check is made for a hugetlb entry.  If a hugetlb
> > entry is found, a call to a routine associated with that entry is made.
> > 
> > Currently, there are two checks for hugetlb entries at each page table
> > level.  The first check is of the form:
> > 	if (p?d_huge())
> > 		page = follow_huge_p?d();
> > the second check is of the form:
> > 	if (is_hugepd())
> > 		page = follow_huge_pd().
> 
> BTW, what about all this hugepd stuff in mm/pagewalk.c?
> 
> Isn't this all dead code as we're essentially routing all hugetlb VMAs
> via walk_hugetlb_range? [yes, all that hugepd stuff in generic code that
> overcomplicates stuff has been annoying me for a long time]

I am 'happy' to look at cleaning up that code next.  Perhaps I will just
create a cleanup series.

I just wanted to focus on eliminating the two callouts in generic code mentioned
above: follow_huge_p?d() and follow_huge_pd().

Really looking for input from Aneesh and Naoya as they added much of the
code that is being removed here.

> > 
> > We can replace these checks, as well as the special handling routines
> > such as follow_huge_p?d() and follow_huge_pd() with a single routine to
> > handle hugetlb vmas.
> > 
> > A new routine hugetlb_follow_page_mask is called for hugetlb vmas at the
> > beginning of follow_page_mask.  hugetlb_follow_page_mask will use the
> > existing routine huge_pte_offset to walk page tables looking for hugetlb
> > entries.  huge_pte_offset can be overwritten by architectures, and already
> > handles special cases such as hugepd entries.
> > 
> > [1] https://lore.kernel.org/linux-mm/cover.1661240170.git.baolin.wang@linux.alibaba.com/
> > Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> 
> [...]
> 
> > +static struct page *hugetlb_follow_page_mask(struct vm_area_struct *vma,
> > +				unsigned long address, unsigned int flags)
> > +{
> > +	/* should never happen, but do not want to BUG */
> > +	return ERR_PTR(-EINVAL);
> 
> Should there be a WARN_ON_ONCE() instead or could we use a BUILD_BUG_ON()?
> 

Ok, I will look into adding one of these.  Prefer a BUILD_BUG_ON().

> > +}
> 
> 
> [...]
> 
> > @@ -851,10 +814,15 @@ static struct page *follow_page_mask(struct vm_area_struct *vma,
> >  
> >  	ctx->page_mask = 0;
> >  
> > -	/* make this handle hugepd */
> > -	page = follow_huge_addr(mm, address, flags & FOLL_WRITE);
> > -	if (!IS_ERR(page)) {
> > -		WARN_ON_ONCE(flags & (FOLL_GET | FOLL_PIN));
> > +	/*
> > +	 * Call hugetlb_follow_page_mask for hugetlb vmas as it will use
> > +	 * special hugetlb page table walking code.  This eliminates the
> > +	 * need to check for hugetlb entries in the general walking code.
> > +	 */
> 
> Maybe also comment that ordinary GUP never ends up in here and instead
> directly uses follow_hugetlb_page(). This is for follow_page() handling
> only.
> 
> [me suggestion to rename follow_hugetlb_page() still stands ;) ]

Will update the comment in v2.

I think renaming follow_hugetlb_page() would be in a separate patch.  Perhaps,
included in a larger cleanup series.  I will not forget. :)

> 
> Numbers speak for themselves.
> 
> Acked-by: David Hildenbrand <david@redhat.com>
> 

Thanks,
-- 
Mike Kravetz
