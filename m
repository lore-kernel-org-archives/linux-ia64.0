From: "'David Gibson'" <david@gibson.dropbear.id.au>
Date: Thu, 02 Mar 2006 23:14:21 +0000
Subject: Re: hugepage: Fix hugepage logic in free_pgtables()
Message-Id: <20060302231421.GB23766@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.61.0603021836090.22007@goblin.wat.veritas.com> <200603021942.k22JgFg13221@unix-os.sc.intel.com>
In-Reply-To: <200603021942.k22JgFg13221@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Hugh Dickins' <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, William Irwin <wli@holomorphy.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Mar 02, 2006 at 11:42:15AM -0800, Chen, Kenneth W wrote:
> Hugh Dickins wrote on Thursday, March 02, 2006 10:53 AM
> > On Thu, 2 Mar 2006, 'David Gibson' wrote:
> > > free_pgtables() has special logic to call hugetlb_free_pgd_range()
> > > instead of the normal free_pgd_range() on hugepage VMAs.  However, the
> > > test it uses to do so is incorrect: it calls is_hugepage_only_range on
> > > a hugepage sized range at the start of the vma.
> > > is_hugepage_only_range() will return true if the given range has any
> > > intersection with a hugepage address region, and in this case the
> > > given region need not be hugepage aligned.  So, for example, this test
> > > can return true if called on, say, a 4k VMA immediately preceding a
> > > (nicely aligned) hugepage VMA.
> > > 
> > > At present we get away with this because the powerpc version of
> > > hugetlb_free_pgd_range() is just a call to free_pgd_range().  On ia64
> > > (the only other arch with a non-trivial is_hugepage_only_range()) we
> > > get away with it for a different reason; the hugepage area is not
> > > contiguous with the rest of the user address space, and VMAs are not
> > > permitted in between, so the test can't return a false positive there.
> > > 
> > > Nonetheless this should be fixed.  We do that in the patch below by
> > > replacing the is_hugepage_only_range() test with an explicit test of
> > > the VMA using is_vm_hugetlb_page().
> > > 
> > Yes, okay, you can add my
> > 
> > Acked-by: Hugh Dickins <hugh@veritas.com>
> > 
> > (ARCH_HAS... and HAVE_ARCH... have fallen into disfavour, but I
> > don't think you're doing wrong by splitting the old one into two.)
> > 
> > But let me emphasize again, in case Andrew wonders, that no current bug
> > is fixed by this (as indeed you indicate in your "we get away with this"
> > comments).
> 
> I've double checked that David's patch is OK for ia64.

Speaking of checking things on ia64, it would be really nice if
someone could see if libhugetlbfs and its testsuite can be made to
work on ia64.  It should be easy for at least the basics - I just have
no machine to try on.  Full support will mean hacking up linker
scripts which will be a bit tricker.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson
