From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 14 Jul 2004 18:34:23 +0000
Subject: RE: free bootmem feedback patch
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01A5D4FA@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There are certainly some opportunities to speed up the code in
free_all_bootmem_core() ... only one cpu is running, so using
atomic operations to "ClearPageReserved(page)" is overkill. As
is calling __free_page() [Which promptly tests that this isn't
a reserved page, and does more atomic ops to decrement the count
from 1 (which we just set it to) to zero.   What a waste of time!]


>Also, it may make more sense to speed this up by freeing higher-order
>pages at a time.

This looks like the most promising way to put a major dent in the
time taken.  If you make sure that the bits in the bitmap line up
correctly so that the physical addresses come out right, then you
have an easy test for "if (v = ~0UL) {" to find larger order pages
(5 on 32-bit systems, 6 on 64-bit).  A factor 64 speedup would
turn your 5 minute hang into a 5 second pause :-).

Some prefetches in that loop might help too (so you don't
have to take a full L3 cache miss on every page structure).

Another approach might be to just free enough pages on each node
to get all the cpus up and running, and then have one cpu on each
node free the remaining pages for the node. But this sounds like
major surgery (and wouldn't help my hypothetical machine that has
huge memory on just one node).

-Tony
