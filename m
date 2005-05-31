From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 31 May 2005 21:58:22 +0000
Subject: RE: [patch 0/4] ia64 SPARSEMEM
Message-Id: <1117576702.20180.70.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050523175031.GC2783@localhost.localdomain>
In-Reply-To: <20050523175031.GC2783@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2005-05-31 at 14:41 -0700, Luck, Tony wrote:
> >* It has good tlb behavior.
> True ... definitely better than VIRTUAL_MEM_MAP. But what effect does
> this have on system level performance?

It slightly improves performance on everything I've run it on, at least
compared to discontigmem.  That means a few ppc64 configurations, x86
summit, and NUMAQ.

> >* It is faster and has a lower icache footprint than existing
> >  discontigmem implementations.
> Did I miss some benchmark results?

I've posted them a few times.  The gain is somewhere in the 1-2% on
NUMAQ.  Nothing substantial.

I can dig the results up again, but they're going to mean close to
nothing on your hardware.  I'd suggest running it yourself, and seeing
exactly how it behaves.

> >* On a theoretical 16TB ppc64 system with 16MB sections, the overhead of
> >  the mem_section[] table is 8MB.
> Back to the "somewhat sparse" arguments of point #1. In fact this theoretical
> system isn't "sparse" at all!

Well, the overhead is still 8MB, even if the system only has 32MB:
16MB@0 and 16MB@(1TB-16MB).  That's pretty sparse.

In any case, I agree that the current code isn't optimal across all ia64
platforms.  But, I don't think we're seriously tied to that single, flat
array.  It's just the easiest way to do it for now.

> >Also, nothing seriously confines us to a flat array of mem_sections,
> >that's just the only implementation right now.  The pagetables that are
> >walked in the TLB miss handler (for vmem_map[]) could just as easily be
> >a set of two-level mem_section tables that are walked in software.  That
> >just adds an extra load to the pfn_to_page() path.  Plus, if somebody
>  ^^^^^^^^^^^^^^^^^^^^^^^
> >does this, all sparsemem architectures can benefit.
> 
> What would the performance impacts of this extra load be? pfn_to_page()
> appears to be a pretty common operation.

On a normal, x86 flatmem system there's a single load to do
pfn_to_page() from *mem_map.  With today's sparsemem, that goes to two
loads (page->flags and mem_section[section]).  I haven't been able to
measure the effect of this extra load on any macro-benchmarks.

-- Dave

