From: William Lee Irwin III <wli@holomorphy.com>
Date: Thu, 15 Jul 2004 23:16:38 +0000
Subject: Re: free bootmem feedback patch
Message-Id: <20040715231638.GY3411@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jul 15, 2004 at 12:11:07PM -0700, Luck, Tony wrote:
> Attached is my version that just frees pages in O(log2(BITS_PER_LONG))
> pieces ... because I'm too lazy to figure out all the boundary
> conditions to implement wli's excellent suggestion.
> On my 2G machine, this reduced the time to free all the bootmem
> from 41ms to 18.1ms ... so it should shave some minutes off the
> monster SGI box that started this thread, but perhaps not enough
> to avoid the "looks like the system is hung" problem as you will
> still be looking at a couple of minutes :-(  Since I only got a
> 55% reduction, rather than a factor of 64 I expect that modifying
> to look an larger order pages may have diminishing returns.

I'll work relative to this for the rest. I'd recommend using __ffs()
instead of the loop. Also, combining this with a specialized page
freeing function that doesn't e.g. fiddle with page references


On Thu, Jul 15, 2004 at 12:11:07PM -0700, Luck, Tony wrote:
> Notes and Caveats:
> 1) Is there a define someplace for log2(BITS_PER_LONG)?  I couldn't
> find one, which is why I calculate the "order" in this patch.

Unfortunately no. It would be nice to have one.


On Thu, Jul 15, 2004 at 12:11:07PM -0700, Luck, Tony wrote:
> 2) On ia64 it looks like the pages and the bitmap are nicely aligned
> so that a longword in node_bootmem_map[] corresponds to an order 6
> page with the right physical alignment.  This may not be true on other
> architectures, and mm/bootmem.c is generic code.  Before this patch
> can go into the base, someone would have to check all the other
> architectures (some of which might not care to change ... if they
> only support 4G or less, then the benefits of saving a few milliseconds
> during boot may not inspire them to mess with the boot code).  For
> this reason I'm not adding a "Signed-off-by" to this patch because
> I don't want the flack for breaking other architectures ... but by
> all means take this patch and try it out.

The common case is the bitmap and mem_map[] starting at 0. The
remaining cases are pretty marginalized. This can actually be checked
at runtime by checking the alignment of ->node_boot_start, e.g. maybe
if  (!~v && !((__pa(bdata->node_boot_start) >> PAGE_SHIFT) & ((1 << MAX_ORDER) - 1)))
instead of just !~v.


-- wli
