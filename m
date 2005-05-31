From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 31 May 2005 21:41:36 +0000
Subject: RE: [patch 0/4] ia64 SPARSEMEM
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0395C434@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050523175031.GC2783@localhost.localdomain>
In-Reply-To: <20050523175031.GC2783@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dave Hansen wrote:
>* The same implementation works everywhere, on every architecture.
Truth in advertising might require that this patch be renamed as
"SOMEWHATSPARSE", as it breaks down for extremely sparse physical
address space machines.  It looks like the existing SGI Altix is at
the ragged edge of what can be practically supported.

>* It has good tlb behavior.
True ... definitely better than VIRTUAL_MEM_MAP. But what effect does
this have on system level performance?

>* It is faster and has a lower icache footprint than existing
>  discontigmem implementations.
Did I miss some benchmark results?

>* On a theoretical 16TB ppc64 system with 16MB sections, the overhead of
>  the mem_section[] table is 8MB.
Back to the "somewhat sparse" arguments of point #1. In fact this theoretical
system isn't "sparse" at all!

>Also, nothing seriously confines us to a flat array of mem_sections,
>that's just the only implementation right now.  The pagetables that are
>walked in the TLB miss handler (for vmem_map[]) could just as easily be
>a set of two-level mem_section tables that are walked in software.  That
>just adds an extra load to the pfn_to_page() path.  Plus, if somebody
 ^^^^^^^^^^^^^^^^^^^^^^^
>does this, all sparsemem architectures can benefit.

What would the performance impacts of this extra load be? pfn_to_page()
appears to be a pretty common operation.


Overall the SPARSEMEM patch is a good clean-up to an area of code that is
unspeakably complex (because of all the interactions between NUMA, DISCONTIG,
and VIRT_MEM_MAP).  So I'm in full agreement that something needs to be done.
I'm just not convinced yet that the existing form of the SPARSEMEM patch is
the greatest thing since sliced bread.

-Tony
