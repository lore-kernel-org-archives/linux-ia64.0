From: William Lee Irwin III <wli@holomorphy.com>
Date: Fri, 16 Jul 2004 00:18:57 +0000
Subject: Re: free bootmem feedback patch
Message-Id: <20040716001857.GB3411@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

At some point in the past, I wrote:
>> I'll work relative to this for the rest. I'd recommend using __ffs()
>> instead of the loop. Also, combining this with a specialized page
>> freeing function that doesn't e.g. fiddle with page references

On Thu, Jul 15, 2004 at 04:53:33PM -0700, Luck, Tony wrote:
> The returns to freeing larger pages do indeed diminish fast.  I
> added simple "look at the next word" and "look at the next
> three words" hacks to see what the times looked like with
> order=7 and order=8 ... and found that order 8 is only 1.8%
> faster than order 6.

This is likely explained by the differences in remaining buddy bitmap
depth.


At some point in the past, I wrote:
>> The common case is the bitmap and mem_map[] starting at 0.

On Thu, Jul 15, 2004 at 04:53:33PM -0700, Luck, Tony wrote:
> Sadly not quite 0.  PG_reserved is set for each page structure
> and must be cleared ... so we have to touch every page structure
> at least once :-(  On a 4TB machine thats 0.25 billion cache
> misses (with a 16K page).

I had more in mind that PC's etc. had mem_map[]/etc. starting at 0.

Moving on, free_area_init_core() makes a rather pessimal assumption
and sets all pages reserved and all refcounts to 0. Setting the
refcounts to 0 is okay, but needs an entrypoint exported that can
free such pages, likely worth implementing in tandem with lockfree
freeing. In this arrangement, the entire bitmap needs iterating over
to mark the pages that aren't going to be freed reserved.


At some point in the past, I wrote:
>> remaining cases are pretty marginalized. This can actually be checked
>> at runtime by checking the alignment of ->node_boot_start, e.g. maybe
>> if  (!~v && !((__pa(bdata->node_boot_start) >> PAGE_SHIFT) & 
>> ((1 << MAX_ORDER) - 1)))
>> instead of just !~v.

On Thu, Jul 15, 2004 at 04:53:33PM -0700, Luck, Tony wrote:
> That check can be done once (for each node) outside the loop. The
> exact expression used to set the "gofast" variable in my patch
> make need some tweaking
> New patch attached.

I presumed enough compiler QOI for loop invariant hoisting, which I
suppose is a mistake with gcc.


-- wli
