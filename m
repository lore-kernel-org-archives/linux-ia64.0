From: Bob Picco <bob.picco@hp.com>
Date: Wed, 01 Jun 2005 01:37:41 +0000
Subject: Re: [patch 0/4] ia64 SPARSEMEM
Message-Id: <20050601013741.GO23448@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050523175031.GC2783@localhost.localdomain>
In-Reply-To: <20050523175031.GC2783@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dave Hansen wrote:	[Tue May 31 2005, 02:14:22PM EDT]
> On Tue, 2005-05-31 at 10:55 -0700, Luck, Tony wrote:
> > What are the other benefits of SPARSEMEM that I'm missing?
> 
> * The same implementation works everywhere, on every architecture.
> * It has good tlb behavior.
> * It is faster and has a lower icache footprint than existing
>   discontigmem implementations.
> * On a theoretical 16TB ppc64 system with 16MB sections, the overhead of
>   the mem_section[] table is 8MB.
> 
> Also, nothing seriously confines us to a flat array of mem_sections,
I started on this Friday.  The holiday weekend and two days of not
feeling well caused a delay. I should have it all worked out by tomorrow
or Thursday.  Hopefully it should eliminate the objections raised.
> that's just the only implementation right now.  The pagetables that are
> walked in the TLB miss handler (for vmem_map[]) could just as easily be
> a set of two-level mem_section tables that are walked in software.  That
> just adds an extra load to the pfn_to_page() path.  Plus, if somebody
> does this, all sparsemem architectures can benefit.
> 
> -- Dave
bob
