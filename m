From: Andrew Morton <akpm@osdl.org>
Date: Wed, 09 Mar 2005 19:32:27 +0000
Subject: Re: ia64 needs to shake memory from quicklists when there is memory
Message-Id: <20050309113227.3501fb76.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050309170915.GA1583@lnx-holt.americas.sgi.com>
In-Reply-To: <20050309170915.GA1583@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Holt <holt@sgi.com>
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mm@kvack.org

Robin Holt <holt@sgi.com> wrote:
>
> Andrew,
> 
> I am searching for some direction.  I am in the process of pushing
> changes to the ia64 page table cache (quicklist) code.  One result of
> the changes is I end up changing the algorithm for freeing pages from
> the quicklist being based on a boot-time calculation of a percentage of
> total system memory to a percentage of memory free on the node (whole
> system for non-numa) at the time the shrink call is made.
> 
> Right now, there are two places that the shrink is invoked.  One is
> from the tlb_finish_mmu() code which would be immediately after the only
> place that items are added to the list.  The other is from cpu_idle which
> appears to be a carry over from when x86 code was pulled over to ia64.
> The purpose for that appears to have been making the sysctl (which has
> been removed) take effect in situations where a cpu is never calling
> tlb_finish_mmu().
> 
> The "ideal" would be to have a node aware slab cache.  Since that
> is probably a long time coming, I was wondering if there would be
> any possibility of getting some sort of hook into wakeup_kswapd(),
> kswapd(), or balance_pgdat().  Since the quicklists are maintained per
> cpu, we would need to perform an smp_call_function_single() for other
> cpus on this node.  Is there some mechanism in place already to handle
> anything similar to this?  Is there a better way to accomplish this?
> Can you offer any suggestions?
> 

Suggest you hook into the existing set_shrinker() API.

Then, in the shrinker callback, perform reclaim of the calling CPU's
node's pages.

Try to return the right numbers from the shrinker callback so that
shrink_slab() will keep this cache balanced wrt all the other ones which it
is managing.
