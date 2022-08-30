From: David Hildenbrand <david@redhat.com>
Date: Tue, 30 Aug 2022 08:11:49 +0000
Subject: Re: [PATCH] hugetlb: simplify hugetlb handling in follow_page_mask
Message-Id: <608934d4-466d-975e-6458-34a91ccb4669@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220829234053.159158-1-mike.kravetz@oracle.com>
In-Reply-To: <20220829234053.159158-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, inuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org
Cc: Baolin Wang <baolin.wang@linux.alibaba.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, Michael Ellerman <mpe@ellerman.id.au>, Muchun Song <songmuchun@bytedance.com>, Andrew Morton <akpm@linux-foundation.org>

On 30.08.22 01:40, Mike Kravetz wrote:
> During discussions of this series [1], it was suggested that hugetlb
> handling code in follow_page_mask could be simplified.  At the beginning

Feel free to use a Suggested-by if you consider it appropriate.

> of follow_page_mask, there currently is a call to follow_huge_addr which
> 'may' handle hugetlb pages.  ia64 is the only architecture which provides
> a follow_huge_addr routine that does not return error.  Instead, at each
> level of the page table a check is made for a hugetlb entry.  If a hugetlb
> entry is found, a call to a routine associated with that entry is made.
> 
> Currently, there are two checks for hugetlb entries at each page table
> level.  The first check is of the form:
> 	if (p?d_huge())
> 		page = follow_huge_p?d();
> the second check is of the form:
> 	if (is_hugepd())
> 		page = follow_huge_pd().

BTW, what about all this hugepd stuff in mm/pagewalk.c?

Isn't this all dead code as we're essentially routing all hugetlb VMAs
via walk_hugetlb_range? [yes, all that hugepd stuff in generic code that
overcomplicates stuff has been annoying me for a long time]

> 
> We can replace these checks, as well as the special handling routines
> such as follow_huge_p?d() and follow_huge_pd() with a single routine to
> handle hugetlb vmas.
> 
> A new routine hugetlb_follow_page_mask is called for hugetlb vmas at the
> beginning of follow_page_mask.  hugetlb_follow_page_mask will use the
> existing routine huge_pte_offset to walk page tables looking for hugetlb
> entries.  huge_pte_offset can be overwritten by architectures, and already
> handles special cases such as hugepd entries.
> 
> [1] https://lore.kernel.org/linux-mm/cover.1661240170.git.baolin.wang@linux.alibaba.com/
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

[...]

> +static struct page *hugetlb_follow_page_mask(struct vm_area_struct *vma,
> +				unsigned long address, unsigned int flags)
> +{
> +	/* should never happen, but do not want to BUG */
> +	return ERR_PTR(-EINVAL);

Should there be a WARN_ON_ONCE() instead or could we use a BUILD_BUG_ON()?

> +}


[...]

> @@ -851,10 +814,15 @@ static struct page *follow_page_mask(struct vm_area_struct *vma,
>  
>  	ctx->page_mask = 0;
>  
> -	/* make this handle hugepd */
> -	page = follow_huge_addr(mm, address, flags & FOLL_WRITE);
> -	if (!IS_ERR(page)) {
> -		WARN_ON_ONCE(flags & (FOLL_GET | FOLL_PIN));
> +	/*
> +	 * Call hugetlb_follow_page_mask for hugetlb vmas as it will use
> +	 * special hugetlb page table walking code.  This eliminates the
> +	 * need to check for hugetlb entries in the general walking code.
> +	 */

Maybe also comment that ordinary GUP never ends up in here and instead
directly uses follow_hugetlb_page(). This is for follow_page() handling
only.

[me suggestion to rename follow_hugetlb_page() still stands ;) ]

> +	if (is_vm_hugetlb_page(vma)) {
> +		page = hugetlb_follow_page_mask(vma, address, flags);
> +		if (!page)
> +			page = no_page_table(vma, flags);
>  		return page;
>  	}
>  
> @@ -863,21 +831,6 @@ static struct page *follow_page_mask(struct vm_area_struct *vma,
>  	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
>  		return no_page_table(vma, flags);
>  
> -	if (pgd_huge(*pgd)) {
> -		page = follow_huge_pgd(mm, address, pgd, flags);
> -		if (page)
> -			return page;
> -		return no_page_table(vma, flags);
> -	}
> -	if (is_hugepd(__hugepd(pgd_val(*pgd)))) {
> -		page = follow_huge_pd(vma, address,
> -				      __hugepd(pgd_val(*pgd)), flags,
> -				      PGDIR_SHIFT);
> -		if (page)
> -			return page;
> -		return no_page_table(vma, flags);
> -	}
> -
>  	return follow_p4d_mask(vma, address, pgd, flags, ctx);
>  }
>  
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index d0617d64d718..b3da421ba5be 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -6190,6 +6190,62 @@ static inline bool __follow_hugetlb_must_fault(unsigned int flags, pte_t *pte,
>  	return false;
>  }
>  
> +struct page *hugetlb_follow_page_mask(struct vm_area_struct *vma,
> +				unsigned long address, unsigned int flags)
> +{
> +	struct hstate *h = hstate_vma(vma);
> +	struct mm_struct *mm = vma->vm_mm;
> +	unsigned long haddr = address & huge_page_mask(h);
> +	struct page *page = NULL;
> +	spinlock_t *ptl;
> +	pte_t *pte, entry;
> +
> +	/*
> +	 * FOLL_PIN is not supported for follow_page(). Ordinary GUP goes via
> +	 * follow_hugetlb_page().
> +	 */
> +	if (WARN_ON_ONCE(flags & FOLL_PIN))
> +		return NULL;
> +
> +	pte = huge_pte_offset(mm, haddr, huge_page_size(h));
> +	if (!pte)
> +		return NULL;
> +
> +retry:
> +	ptl = huge_pte_lock(h, mm, pte);
> +	entry = huge_ptep_get(pte);
> +	if (pte_present(entry)) {
> +		page = pte_page(entry) +
> +				((address & ~huge_page_mask(h)) >> PAGE_SHIFT);
> +		/*
> +		 * Note that page may be a sub-page, and with vmemmap
> +		 * optimizations the page struct may be read only.
> +		 * try_grab_page() will increase the ref count on the
> +		 * head page, so this will be OK.
> +		 *
> +		 * try_grab_page() should always succeed here, because we hold
> +		 * the ptl lock and have verified pte_present().
> +		 */
> +		if (WARN_ON_ONCE(!try_grab_page(page, flags))) {
> +			page = NULL;
> +			goto out;
> +		}
> +	} else {
> +		if (is_hugetlb_entry_migration(entry)) {
> +			spin_unlock(ptl);
> +			__migration_entry_wait_huge(pte, ptl);
> +			goto retry;
> +		}
> +		/*
> +		 * hwpoisoned entry is treated as no_page_table in
> +		 * follow_page_mask().
> +		 */
> +	}
> +out:
> +	spin_unlock(ptl);
> +	return page;
> +}
> +
>  long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  			 struct page **pages, struct vm_area_struct **vmas,
>  			 unsigned long *position, unsigned long *nr_pages,
> @@ -7140,123 +7196,6 @@ __weak unsigned long hugetlb_mask_last_page(struct hstate *h)
>   * These functions are overwritable if your architecture needs its own
>   * behavior.
>   */

[...]

Numbers speak for themselves.

Acked-by: David Hildenbrand <david@redhat.com>

-- 
Thanks,

David / dhildenb
