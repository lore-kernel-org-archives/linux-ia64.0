From: Josh Aas <josha@sgi.com>
Date: Tue, 03 Aug 2004 17:53:53 +0000
Subject: Re: free bootmem feedback patch
Message-Id: <410FD131.4050809@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Are there any outstanding issues with Tony's second revision of the 
free_all_bootmem_core function? Do we still have the problem of making 
sure longwork in node_bootmem_map[] corresponds to an order 6 page with 
the right physical alignment? The second revision looks good to me. If I 
could get some more feedback on it I'll clean up any remaining issues so 
it can land sometime soon. I'll post test results (unpatched vs. 
patched) on a big machine later this afternoon.

wli - do you still want to see the memory map for my big test machine 
(512GB RAM)?

-Josh

Luck, Tony wrote:
>>>still be looking at a couple of minutes :-(  Since I only got a
>>>55% reduction, rather than a factor of 64 I expect that modifying
>>>to look an larger order pages may have diminishing returns.
>>
>>I'll work relative to this for the rest. I'd recommend using __ffs()
>>instead of the loop. Also, combining this with a specialized page
>>freeing function that doesn't e.g. fiddle with page references
> 
> 
> The returns to freeing larger pages do indeed diminish fast.  I
> added simple "look at the next word" and "look at the next
> three words" hacks to see what the times looked like with
> order=7 and order=8 ... and found that order 8 is only 1.8%
> faster than order 6.
> 
> 
>>The common case is the bitmap and mem_map[] starting at 0.
> 
> 
> Sadly not quite 0.  PG_reserved is set for each page structure
> and must be cleared ... so we have to touch every page structure
> at least once :-(  On a 4TB machine thats 0.25 billion cache
> misses (with a 16K page).
> 
> 
> 
>>remaining cases are pretty marginalized. This can actually be checked
>>at runtime by checking the alignment of ->node_boot_start, e.g. maybe
>>if  (!~v && !((__pa(bdata->node_boot_start) >> PAGE_SHIFT) & 
>>((1 << MAX_ORDER) - 1)))
>>instead of just !~v.
> 
> 
> That check can be done once (for each node) outside the loop. The
> exact expression used to set the "gofast" variable in my patch
> make need some tweaking
> 
> New patch attached.
> 
> -Tony

-- 
Josh Aas
Silicon Graphics, Inc. (SGI)
Linux System Software
651-683-3068
