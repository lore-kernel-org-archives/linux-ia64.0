From: Peter Xu <peterx@redhat.com>
Date: Sun, 30 Oct 2022 19:45:02 +0000
Subject: Re: [PATCH v4] hugetlb: simplify hugetlb handling in follow_page_mask
Message-Id: <Y17UPk9CBjPumcz6@x1n>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221028181108.119432-1-mike.kravetz@oracle.com>
In-Reply-To: <20221028181108.119432-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, Baolin Wang <baolin.wang@linux.alibaba.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, David Hildenbrand <david@redhat.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, Michael Ellerman <mpe@ellerman.id.au>, Muchun Song <songmuchun@bytedance.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Oct 28, 2022 at 11:11:08AM -0700, Mike Kravetz wrote:
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
> +retry:
> +	pte = huge_pte_offset(mm, haddr, huge_page_size(h));
> +	if (!pte)
> +		return NULL;
> +
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
> +			hugetlb_vma_unlock_read(vma);

Just noticed it when pulled the last mm-unstable: this line seems to be a
left-over of v3, while not needed now?

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

-- 
Peter Xu
