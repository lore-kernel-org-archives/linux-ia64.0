From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 09 Aug 2004 18:54:13 +0000
Subject: RE: Hugetlb demanding paging for -mm tree
Message-Id: <200408091854.i79IsCY12450@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20040807083613.GZ17188@holomorphy.com>
References: <200408051329.i75DT3Y26431@unix-os.sc.intel.com>
In-Reply-To: <200408051329.i75DT3Y26431@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'William Lee Irwin III' <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, "Seth, Rohit" <rohit.seth@intel.com>

William Lee Irwin III wrote on Saturday, August 07, 2004 1:36 AM
> On Thu, Aug 05, 2004 at 06:39:59AM -0700, Chen, Kenneth W wrote:
> > +static void scrub_one_pmd(pmd_t * pmd)
> > +{
> > +	struct page *page;
> > +
> > +	if (pmd && !pmd_none(*pmd) && !pmd_huge(*pmd)) {
> > +		page = pmd_page(*pmd);
> > +		pmd_clear(pmd);
> > +		dec_page_state(nr_page_table_pages);
> > +		page_cache_release(page);
> > +	}
> > +}
>
> This is needed because we're only freeing pagetables at pgd granularity
> at munmap() -time. It makes more sense to refine it to pmd granularity
> instead of this cleanup pass, as it's a memory leak beyond just hugetlb
> data structure corruption.
>

That would be nice and ease the pain on x86.  OTOH, leaving pte persistent
right now may help in mmap/munmap intensive workload since unmap_region()
only destroys all pte allocation at pgd granularity.


> I wonder why this bugfix was rolled into the demand paging patch instead
> of shipped separately. And for that matter, this fix applies to mainline.

The bug fix went into hugetlb_prefault() function in the mainline for the
prefaulting case.  It went to that function instead of huge_pte_alloc and huge_pte_offset is to avoid scrubbing at pte lookup time.
One thing we can
do for demand paging case is to scrub it at initial mmap hugetlb vma, so
the penalty is paid upfront instead of at every pte allocation/lookup time.


