From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 28 Mar 2006 20:09:00 +0000
Subject: RE: show_mem() for ia64 discontig takes a really long time on large systems.
Message-Id: <200603282008.k2SK8Ng29399@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
In-Reply-To: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin Holt wrote on Tuesday, March 28, 2006 10:43 AM
> Recently, we ran a large system out of memory and the oom_kill() appeared
> to have frozen up.  When we looked at the backtraces, we noticed the cpu
> was making progress, but apparently not fast progress.  As a simple test,
> I did a 'echo m >/proc/sysrq-trigger' and that had not completed in more
> than a half-hour.
> 
> The system was a fully populated 512 node SGI machine.  The way that
> memory is physically layed out results in a single pgdat which covers
> the node with two holes in it.  This is new hardware with larger gaps
> between the chunks of memory that earlier version had.  As show_mem()
> is traversing the entire systems memory to print out stats on remaining
> memory, it takes faults while trying to look at holes in the array of
> struct pages.
> 
> At this point, I am looking for any sort of direction on what would be
> a reasonable fix.  Should show_mem() be made to skip to a page aligned
> point in the array when the fault fails?  Should we add the information
> about start and end of hole to the pgdat()?  Should we have one pgdat
> per chunk?  Are there other better ideas out there?  Any direction would
> be greatly appreciated.


Can you walk the vmem_map's page table and look for none-zero entry, sort
of implement something like find_next_valid_pfn? There you can walk at pud,
pmd's granule step.

- Ken
