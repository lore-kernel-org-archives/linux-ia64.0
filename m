From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 18 Feb 2004 19:36:48 +0000
Subject: Re: PXM/Nid/SLIT patch
Message-Id: <20040218193648.GP13235@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40321CF7.5020301@hp.com>
In-Reply-To: <40321CF7.5020301@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 18, 2004 at 02:19:23PM -0500, Robert Picco wrote:
> Our HP default boot configuration has all memory  interleaved and 
> reported in NUMA SRAT PXM 255.  The
> other cell nodes (PXMs) don't have any memory.  This was totally 
> unexpected by the current NUMA code. There will be N-1 nids with CPUs 
> and no memory and 1 NID with all the memory.  Initialization crashes 
> very early.  The current code expects each node to have local memory.  

Oh, right, there's that... we could fix it to fallback to other nodes
though.  In fact, we should do the bootmem initialization earlier and
use alloc_bootmem_node for things instead of allocating stuff in
find_pernode_space.  If we fixed that your machine would work pretty
well I think.

> So, if we had a tool to configure CLM for all cells, there would be N-1 
> nids with CPU and local memory and 1 nid with just interleaved memory.  
> The current kernel code would work fine but the SLIT information would be
> wrong because PXM 255 isn't reported by the firmware in the SLIT table.  
> numa_slit isn't used  by non-machine dependent code for memory 
> allocation policy  but could be in the future for memory  allocations 
> when the current node's memory is exhausted. numa_slit would be used as 
> a measure of the best locality to make the allocation from (shortest path).

No, pgdat->zonelist is used instead.  It needs to be built better
though...

Jesse
