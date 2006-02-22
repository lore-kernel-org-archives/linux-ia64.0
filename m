From: "'David Gibson'" <david@gibson.dropbear.id.au>
Date: Wed, 22 Feb 2006 02:15:10 +0000
Subject: Re: IA64 non-contiguous memory space bugs
Message-Id: <20060222021510.GC23574@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060222001359.GA23574@localhost.localdomain> <200602220132.k1M1Vxg09552@unix-os.sc.intel.com>
In-Reply-To: <200602220132.k1M1Vxg09552@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Feb 21, 2006 at 05:31:59PM -0800, Chen, Kenneth W wrote:
> David Gibson wrote on Tuesday, February 21, 2006 4:14 PM
> > Second problem is in the hugepage logic in free_pgtables()
> > (mm/memory.c).  As far as I can tell it's complete crap, and only
> > works by accident, for different accidental reasons on ppc64 and ia64,
> > the only archs that have a non-trivial is_hugepage_only_range().
> > Except that I'm not sure it does entirely work by accident on ia64:
> > suppose a process has a hugepage mapping that begins some way after
> > the beginning of the hugepage address range.  Before
> > hugetlb_free_pgd_range() gets called on that area, it will be called
> > on the next normal page VMA down - but with an end address at the
> > beginning of the hugepage VMA and so extending into the hugepage
> > address range.  I don't really understand the ia64 pagetable mapping
> > stuff well enough to tell if that's dangerous or not.
> 
> I don't see any problem in the ia64 code.  The start and end address is
> what the vma specified.  Floor and ceiling is just a hint for free_pgtables()
> to free any left over page tables between vma holes (to prev and next).
> As far as I can tell, the code looks fine.

Ah, yes, I see now.  free_pgd_range() only iterates through to end,
not ceiling so it should be fine.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson
