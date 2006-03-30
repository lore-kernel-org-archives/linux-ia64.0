From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 30 Mar 2006 17:48:18 +0000
Subject: RE: show_mem() for ia64 discontig takes a really long time on large systems.
Message-Id: <200603301747.k2UHlXg22156@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
In-Reply-To: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jack Steiner wrote on Thursday, March 30, 2006 9:29 AM
> > Time is wasted trying to fill the TLB entry for the vmem_map.  When it
> > fails, we show_mem() advances to the next page which repeats the sequence.
> > Jack had thrown out a couple suggestions.  One was essentially what
> > you proposed below.  The other was advance i to point the next page
> > of pfns.  He frowned when saying the second, but I don't recall exactly
> > why he frowned.
> 
> Advancing to the next page will be considerably faster but I wonder if
> it is fast enough.
> 
> There are huge gaps in the virtual vmem_map. On shub2, for example, it
> is possible to have 180GB of unpopulated memory in the holes
> between memory banks on a node (mode=0).
> 
> Assuming 56 bytes per struct_page, that gives:
> 	
> 	- 180GB = 11M pages 
> 	- 38000 pages of struct_page entries
> 	- 38000 TLB faults to scan the holes in a node
> 
> That is a lot of tlbmisses to scan a node. Multiply by 512 to
> get the number of faults to scan a full 512n system.
> 
> My gut feeling is that is not good enough. 

What about the earlier proposal of advancing at pmd and pud granule by
walking the page table?  There it can walk at 32MB/64GB step.

- Ken
