From: William Lee Irwin III <wli@holomorphy.com>
Date: Wed, 14 Jul 2004 22:12:47 +0000
Subject: Re: free bootmem feedback patch
Message-Id: <20040714221247.GU3411@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

At some point in the past, I wrote:
>> Also, it may make more sense to speed this up by freeing higher-order
>> pages at a time.

On Wed, Jul 14, 2004 at 11:34:23AM -0700, Luck, Tony wrote:
> This looks like the most promising way to put a major dent in the
> time taken.  If you make sure that the bits in the bitmap line up
> correctly so that the physical addresses come out right, then you
> have an easy test for "if (v = ~0UL) {" to find larger order pages
> (5 on 32-bit systems, 6 on 64-bit).  A factor 64 speedup would
> turn your 5 minute hang into a 5 second pause :-).
> Some prefetches in that loop might help too (so you don't
> have to take a full L3 cache miss on every page structure).
> Another approach might be to just free enough pages on each node
> to get all the cpus up and running, and then have one cpu on each
> node free the remaining pages for the node. But this sounds like
> major surgery (and wouldn't help my hypothetical machine that has
> huge memory on just one node).

I'd even go so far as to suggest scanning the bitmap until the
maximally sized higher-order page to free at the cursor (determined
by cursor alignment and the first bit indicating a reserved page or
otherwise MAX_ORDER bits out from the cursor) is found. More ideally
(2.7) I'd prefer to rewrite the thing altogether and explicitly track
ranges at all times, so eliminating all linear scans but the final one,
which is then very natural to arrange to free maximally sized higher-
order pages and has far fewer degenerate cases than the bitmaps.

Parallelization sounds very interesting, but something I don't have the
machine and other resources to address. I suspect as node initialization
is rearranged for the purpose of hotplugging memory this will become
easier, but have no specific ideas (or even knowledge of what's going on)
about the hotplug memory and/or bootmem parallelization topic, apart
from believing it's a good idea.


-- wli
