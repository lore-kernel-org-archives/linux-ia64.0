From: William Lee Irwin III <wli@holomorphy.com>
Date: Sat, 07 Aug 2004 08:36:13 +0000
Subject: Re: Hugetlb demanding paging for -mm tree
Message-Id: <20040807083613.GZ17188@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040805133637.GG14358@holomorphy.com> <200408051340.i75De0Y26517@unix-os.sc.intel.com>
In-Reply-To: <200408051340.i75De0Y26517@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, "Seth, Rohit" <rohit.seth@intel.com>

On Thu, Aug 05, 2004 at 06:39:59AM -0700, Chen, Kenneth W wrote:
> +static void scrub_one_pmd(pmd_t * pmd)
> +{
> +	struct page *page;
> +
> +	if (pmd && !pmd_none(*pmd) && !pmd_huge(*pmd)) {
> +		page = pmd_page(*pmd);
> +		pmd_clear(pmd);
> +		dec_page_state(nr_page_table_pages);
> +		page_cache_release(page);
> +	}
> +}

This is needed because we're only freeing pagetables at pgd granularity
at munmap() -time. It makes more sense to refine it to pmd granularity
instead of this cleanup pass, as it's a memory leak beyond just hugetlb
data structure corruption.

I wonder why this bugfix was rolled into the demand paging patch instead
of shipped separately. And for that matter, this fix applies to mainline.


On Thu, Aug 05, 2004 at 06:39:59AM -0700, Chen, Kenneth W wrote:
> +int
> +handle_hugetlb_mm_fault(struct mm_struct *mm, struct vm_area_struct * vma,
> +	unsigned long addr, int write_access)
> +{
> +	hugepte_t *pte;
> +	struct page *page;
> +	struct address_space *mapping;
> +	int idx, ret;

Well, to go along with the general theme of this, using a hugepte_t
type and macros in generic code trivially defined to normal pte bits
for other arches could easily consolidate this fault handler with the
others. Of course, this much consolidation makes some rather limiting
assumptions that will either prevent other improvements or have to be
partially undone for other improvements.


-- wli
