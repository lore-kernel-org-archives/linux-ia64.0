From: "'David Gibson'" <david@gibson.dropbear.id.au>
Date: Fri, 24 Feb 2006 02:44:31 +0000
Subject: Re: [patch] fix ia64 hugetlb_free_pgd_range
Message-Id: <20060224024431.GC28368@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <200602240145.k1O1jEg05475@unix-os.sc.intel.com>
In-Reply-To: <200602240145.k1O1jEg05475@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Hugh Dickins' <hugh@veritas.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Feb 23, 2006 at 05:45:14PM -0800, Chen, Kenneth W wrote:
> I've looked at hugetlb_free_pgd_range() right side up, right side
> down, up side up, up side down.  And it just doesn't look correct
> to me at all.
> 
> In that function, we do address transformation before calling
> free_pgd_range, so the generic function can traverse to right set
> of page table page.  There is no need to do any range check.

I think you're right - the range check is bogus.  Probably someone
just used it because the range check gave the right answer - but only
by accident in a sense.

However... I suspect in fact that the transformations should be
unconditional.  The whole address scaling thing that ia64 does for
hugepages is extremely confusing, but since floor and ceiling are just
used for bounds checking on the inner functions, shouldn't they be
transformed to the same scale as addr and end, even if that's not
actually a true address (hugepage or otherwise).

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson
