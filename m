From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Thu, 01 Sep 2022 16:19:30 +0000
Subject: Re: [PATCH] hugetlb: simplify hugetlb handling in follow_page_mask
Message-Id: <YxDbkvCy9+Opm0ns@monkey>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220829234053.159158-1-mike.kravetz@oracle.com>
In-Reply-To: <20220829234053.159158-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, inuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org
Cc: Baolin Wang <baolin.wang@linux.alibaba.com>, David Hildenbrand <david@redhat.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, Michael Ellerman <mpe@ellerman.id.au>, Muchun Song <songmuchun@bytedance.com>, Andrew Morton <akpm@linux-foundation.org>

On 08/29/22 16:40, Mike Kravetz wrote:
> A new routine hugetlb_follow_page_mask is called for hugetlb vmas at the
> beginning of follow_page_mask.  hugetlb_follow_page_mask will use the
> existing routine huge_pte_offset to walk page tables looking for hugetlb
> entries.  huge_pte_offset can be overwritten by architectures, and already
> handles special cases such as hugepd entries.
> 
<snip>
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

I can't believe I forgot about huge pmd sharing as described here!!!
https://lore.kernel.org/linux-mm/20220824175757.20590-1-mike.kravetz@oracle.com/

The above series is in Andrew's tree, and we should add 'vma locking' calls
to this routine.

Do note that the existing page walking code can race with pmd unsharing.
I would NOT suggest trying to address this in stable releases.  To date,
I am unaware of any issues caused by races with pmd unsharing.  Trying
to take this into account in 'generic page walking code', could get ugly.
Since hugetlb_follow_page_mask will be a special callout for hugetlb page
table walking, we can easily add the required locking and address the
potential race issue.  This will be in v2.

Still hoping to get some feedback from Aneesh and Naoya about this approach.
-- 
Mike Kravetz

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
> -struct page * __weak
> -follow_huge_addr(struct mm_struct *mm, unsigned long address,
> -			      int write)
> -{
> -	return ERR_PTR(-EINVAL);
> -}
> -
> -struct page * __weak
> -follow_huge_pd(struct vm_area_struct *vma,
> -	       unsigned long address, hugepd_t hpd, int flags, int pdshift)
> -{
> -	WARN(1, "hugepd follow called with no support for hugepage directory format\n");
> -	return NULL;
> -}
> -
> -struct page * __weak
> -follow_huge_pmd(struct mm_struct *mm, unsigned long address,
> -		pmd_t *pmd, int flags)
> -{
> -	struct page *page = NULL;
> -	spinlock_t *ptl;
> -	pte_t pte;
> -
> -	/*
> -	 * FOLL_PIN is not supported for follow_page(). Ordinary GUP goes via
> -	 * follow_hugetlb_page().
> -	 */
> -	if (WARN_ON_ONCE(flags & FOLL_PIN))
> -		return NULL;
> -
> -retry:
> -	ptl = pmd_lockptr(mm, pmd);
> -	spin_lock(ptl);
> -	/*
> -	 * make sure that the address range covered by this pmd is not
> -	 * unmapped from other threads.
> -	 */
> -	if (!pmd_huge(*pmd))
> -		goto out;
> -	pte = huge_ptep_get((pte_t *)pmd);
> -	if (pte_present(pte)) {
> -		page = pmd_page(*pmd) + ((address & ~PMD_MASK) >> PAGE_SHIFT);
> -		/*
> -		 * try_grab_page() should always succeed here, because: a) we
> -		 * hold the pmd (ptl) lock, and b) we've just checked that the
> -		 * huge pmd (head) page is present in the page tables. The ptl
> -		 * prevents the head page and tail pages from being rearranged
> -		 * in any way. So this page must be available at this point,
> -		 * unless the page refcount overflowed:
> -		 */
> -		if (WARN_ON_ONCE(!try_grab_page(page, flags))) {
> -			page = NULL;
> -			goto out;
> -		}
> -	} else {
> -		if (is_hugetlb_entry_migration(pte)) {
> -			spin_unlock(ptl);
> -			__migration_entry_wait_huge((pte_t *)pmd, ptl);
> -			goto retry;
> -		}
> -		/*
> -		 * hwpoisoned entry is treated as no_page_table in
> -		 * follow_page_mask().
> -		 */
> -	}
> -out:
> -	spin_unlock(ptl);
> -	return page;
> -}
> -
> -struct page * __weak
> -follow_huge_pud(struct mm_struct *mm, unsigned long address,
> -		pud_t *pud, int flags)
> -{
> -	struct page *page = NULL;
> -	spinlock_t *ptl;
> -	pte_t pte;
> -
> -	if (WARN_ON_ONCE(flags & FOLL_PIN))
> -		return NULL;
> -
> -retry:
> -	ptl = huge_pte_lock(hstate_sizelog(PUD_SHIFT), mm, (pte_t *)pud);
> -	if (!pud_huge(*pud))
> -		goto out;
> -	pte = huge_ptep_get((pte_t *)pud);
> -	if (pte_present(pte)) {
> -		page = pud_page(*pud) + ((address & ~PUD_MASK) >> PAGE_SHIFT);
> -		if (WARN_ON_ONCE(!try_grab_page(page, flags))) {
> -			page = NULL;
> -			goto out;
> -		}
> -	} else {
> -		if (is_hugetlb_entry_migration(pte)) {
> -			spin_unlock(ptl);
> -			__migration_entry_wait(mm, (pte_t *)pud, ptl);
> -			goto retry;
> -		}
> -		/*
> -		 * hwpoisoned entry is treated as no_page_table in
> -		 * follow_page_mask().
> -		 */
> -	}
> -out:
> -	spin_unlock(ptl);
> -	return page;
> -}
> -
> -struct page * __weak
> -follow_huge_pgd(struct mm_struct *mm, unsigned long address, pgd_t *pgd, int flags)
> -{
> -	if (flags & (FOLL_GET | FOLL_PIN))
> -		return NULL;
> -
> -	return pte_page(*(pte_t *)pgd) + ((address & ~PGDIR_MASK) >> PAGE_SHIFT);
> -}
> -
>  int isolate_hugetlb(struct page *page, struct list_head *list)
>  {
>  	int ret = 0;
> -- 
> 2.37.1
> 
