From: "'David Gibson'" <david@gibson.dropbear.id.au>
Date: Fri, 03 Mar 2006 05:26:02 +0000
Subject: Re: hugepage: Fix hugepage logic in free_pgtables() harder
Message-Id: <20060303052602.GL23766@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060303010408.GG23766@localhost.localdomain> <Pine.LNX.4.61.0603030508470.5446@goblin.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.61.0603030508470.5446@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, William Irwin <wli@holomorphy.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Mar 03, 2006 at 05:18:51AM +0000, Hugh Dickins wrote:
> On Fri, 3 Mar 2006, 'David Gibson' wrote:
> 
> > Sigh.  Turns out the hugepage logic in free_pgtables() was doubly
> > broken.  The loop coalescing multiple normal page VMAs into one call
> > to free_pgd_range() had an off by one error, which could mean it would
> > coalesce one hugepage VMA into the same bundle (checking 'vma' not
> > 'next' in the loop).  I transferred this bug into the new
> > is_vm_hugetlb_page() based version.  Here's the fix.
> > 
> > This one didn't bite on powerpc previously for the same reason the
> > is_hugepage_only_range() problem didn't: powerpc's
> > hugetlb_free_pgd_range() is identical to free_pgd_range().  It didn't
> > bite on ia64 because the hugepage region is distant enough from any
> > other region that the separated PMD_SIZE distance test would always
> > prevent coalescing the two together.
> 
> I agree with your patch, but not with your comment: it's just a fix
> to your earlier patch, there's no such off-by-one in the mainline
> free_pgtables.  Probably you were misled by my use of "vma->vm_mm"
> rather than  "next->vm_mm", equal but admittedly confusing, when
> looking at the "next" vma.

Ah, yes, indeed.  The bug's all my fault, but it's still a bug.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson
