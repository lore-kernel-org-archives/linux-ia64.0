From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 16 Apr 2004 03:43:08 +0000
Subject: RE: hugetlb demand paging patch part [0/3]
Message-Id: <200404160343.i3G3h8F13447@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20040416033251.GH12735@zax>
References: <200404132317.i3DNH4F21162@unix-os.sc.intel.com>
In-Reply-To: <200404132317.i3DNH4F21162@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'David Gibson' <david@gibson.dropbear.id.au>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, lse-tech@lists.sourceforge.net, raybry@sgi.com, 'Andy Whitcroft' <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>

David Gibson wrote on Thursday, April 15, 2004 8:33 PM
> To unify even the non-ppc64 archs we already have to allow for the
> hugepage pagetables to have different structure across archs - on i386
> and ppc64 the hugePTEs lie in PMD slots, on sparc64 and sh they lie in
> (normal) PTE slots and on IA64 they lie in the PTE slots of a special
> set of pagetables.  Given that, it seems conceptually logical to me
> that we also not assume the hugepage PTEs have the same layout as
> normal PTEs.  It makes the handle_mm_fault function not the least more
> complicated.

Correction: huge page pte on ia64 has the same format as a normal page pte.


