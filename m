From: "'David Gibson'" <david@gibson.dropbear.id.au>
Date: Fri, 16 Apr 2004 04:02:32 +0000
Subject: Re: hugetlb demand paging patch part [0/3]
Message-Id: <20040416040231.GA13552@zax>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040416033251.GH12735@zax> <200404160343.i3G3h8F13447@unix-os.sc.intel.com>
In-Reply-To: <200404160343.i3G3h8F13447@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, lse-tech@lists.sourceforge.net, raybry@sgi.com, 'Andy Whitcroft' <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>

On Thu, Apr 15, 2004 at 08:43:08PM -0700, Chen, Kenneth W wrote:
> David Gibson wrote on Thursday, April 15, 2004 8:33 PM
> > To unify even the non-ppc64 archs we already have to allow for the
> > hugepage pagetables to have different structure across archs - on i386
> > and ppc64 the hugePTEs lie in PMD slots, on sparc64 and sh they lie in
> > (normal) PTE slots and on IA64 they lie in the PTE slots of a special
> > set of pagetables.  Given that, it seems conceptually logical to me
> > that we also not assume the hugepage PTEs have the same layout as
> > normal PTEs.  It makes the handle_mm_fault function not the least more
> > complicated.
> 
> Correction: huge page pte on ia64 has the same format as a normal page pte.

Yes, the PTEs have the same format, but the page table layout is not
identical (it's almost the same, but the address is shifted right
before doing the lookup).

-- 
David Gibson			| For every complex problem there is a
david AT gibson.dropbear.id.au	| solution which is simple, neat and
				| wrong.
http://www.ozlabs.org/people/dgibson
