From: Robin Holt <holt@sgi.com>
Date: Fri, 17 Sep 2004 14:34:58 +0000
Subject: Re: Uncached memory allocator for ia64.
Message-Id: <20040917143458.GB25345@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040914151629.GA21118@lnx-holt.americas.sgi.com>
In-Reply-To: <20040914151629.GA21118@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I have done a little testing on the uncached.  I think the problem may
be bigger than I originally expected.

I made a simple driver.  On load, it allocated an entire granule and, I
think, correctly did all the flushes called for in the processor manual
including the PAL call.  A user could then mmap the entire chunk as
uncached and work with it.  I did not get any sort of MCAs from this run.

I then started the same app which referenced the first word of each page
uncached.  I added a timer interrupt which scanned all the page structs
on the node from which the granule was allocated and had a reference
to the page inside of an impossible if statement (next to impossible as
the machine would have to be up for a large number of years).  This, I
believe, resulted in the speculation of the cache line dirty.  By running
this test for about 8 minutes, I was able to cause an MCA due to having
both a cached and uncached reference to the same cache line on the FSB.

Note, I was running all the pages structs for the node and not just the
ones for this granule.

Based on this test, I was wondering if it is safe to reuse a granule and
leave the page structs in place.  Is this test representative of events
which could happen?  Can we destroy the page structs on a running system?

Thank you in advance for any direction anybody can give me.

Thanks,
Robin Holt
