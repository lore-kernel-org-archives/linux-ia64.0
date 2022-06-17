From: Peter Xu <peterx@redhat.com>
Date: Fri, 17 Jun 2022 14:15:34 +0000
Subject: Re: [PATCH 1/4] hugetlb: skip to end of PT page mapping when pte not present
Message-Id: <YqyMhmAjrQ4C+EyA@xz-m1.local>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220616210518.125287-1-mike.kravetz@oracle.com>
 <20220616210518.125287-2-mike.kravetz@oracle.com>
In-Reply-To: <20220616210518.125287-2-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Muchun Song <songmuchun@bytedance.com>, Baolin Wang <baolin.wang@linux.alibaba.com>, Michal Hocko <mhocko@suse.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, James Houghton <jthoughton@google.com>, Mina Almasry <almasrymina@google.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <anshuman.khandual@arm.com>, Paul Walmsley <paul.walmsley@sifive.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, catalin.marinas@arm.com, will@kernel.org, Andrew Morton <akpm@linux-foundation.org>

Hi, Mike,

On Thu, Jun 16, 2022 at 02:05:15PM -0700, Mike Kravetz wrote:
> @@ -6877,6 +6896,39 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
>  	return (pte_t *)pmd;
>  }
>  
> +/*
> + * Return a mask that can be used to update an address to the last huge
> + * page in a page table page mapping size.  Used to skip non-present
> + * page table entries when linearly scanning address ranges.  Architectures
> + * with unique huge page to page table relationships can define their own
> + * version of this routine.
> + */
> +unsigned long hugetlb_mask_last_page(struct hstate *h)
> +{
> +	unsigned long hp_size = huge_page_size(h);
> +
> +	switch (hp_size) {
> +	case P4D_SIZE:
> +		return PGDIR_SIZE - P4D_SIZE;
> +	case PUD_SIZE:
> +		return P4D_SIZE - PUD_SIZE;
> +	case PMD_SIZE:
> +		return PUD_SIZE - PMD_SIZE;
> +	default:

Should we add a WARN_ON_ONCE() if it should never trigger?

> +		break; /* Should never happen */
> +	}
> +
> +	return ~(0UL);
> +}
> +
> +#else
> +
> +/* See description above.  Architectures can provide their own version. */
> +__weak unsigned long hugetlb_mask_last_page(struct hstate *h)
> +{
> +	return ~(0UL);

I'm wondering whether it's better to return 0 rather than ~0 by default.
Could an arch with !CONFIG_ARCH_WANT_GENERAL_HUGETLB wrongly skip some
valid address ranges with ~0, or perhaps I misread?

Thanks,

-- 
Peter Xu
