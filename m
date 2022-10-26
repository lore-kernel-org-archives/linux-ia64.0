From: Peter Xu <peterx@redhat.com>
Date: Wed, 26 Oct 2022 21:59:43 +0000
Subject: Re: [PATCH v3] hugetlb: simplify hugetlb handling in follow_page_mask
Message-Id: <Y1mtz7dFAlhGRsAd@x1n>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220919021348.22151-1-mike.kravetz@oracle.com>
In-Reply-To: <20220919021348.22151-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, Baolin Wang <baolin.wang@linux.alibaba.com>, David Hildenbrand <david@redhat.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, Michael Ellerman <mpe@ellerman.id.au>, Muchun Song <songmuchun@bytedance.com>, Andrew Morton <akpm@linux-foundation.org>

Hi, Mike,

On Sun, Sep 18, 2022 at 07:13:48PM -0700, Mike Kravetz wrote:
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
> +	/*
> +	 * vma lock prevents racing with another thread doing a pmd unshare.
> +	 * This keeps pte as returned by huge_pte_offset valid.
> +	 */
> +	hugetlb_vma_lock_read(vma);

I'm not sure whether it's okay to take a rwsem here, as the code can be
called by e.g. FOLL_NOWAIT?

I'm wondering whether it's fine to just drop this anyway, just always walk
it lockless.  IIUC gup callers should be safe here because the worst case
is the caller will fetch a wrong page, but then it should be invalidated
very soon with mmu notifiers.  One thing worth mention is that pmd unshare
should never free a pgtable page.

IIUC it's also the same as fast-gup - afaiu we don't take the read vma lock
in fast-gup too but I also think it's safe.  But I hope I didn't miss
something.

-- 
Peter Xu
