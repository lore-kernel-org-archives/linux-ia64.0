From: Robin Holt <holt@sgi.com>
Date: Thu, 09 Sep 2004 16:36:38 +0000
Subject: [RFC 0/4] Add SN2 Special Memory driver.
Message-Id: <20040909163638.GA23178@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This driver provides three different devices for mmap'ing pages which
are not visible to the kernel.

sgi_fetchops) atomic operations performed by the SN2 memory controller.
	These operations are performed using uncached memory
	references with an offset of the address specifying the
	operation (add, sub) to perform.

sgi_uncached) Provides a device which supports mapping pages which
	will only be referenced uncached.  These use the Intel ia64
	write combining feature.  These need to be in a separate
	granule from regular memory to prevent the FSB from having
	both a cached and an uncached reference to a memory location.

sgi_cached) Provides a device which support cached operations from the
	processor and uncached from processors outside the coherence
	domain.  This provides rapid read access to the 16 words in the
	cache line to data that was written uncached by remote processors.


All of these devices require addresses that have no kernel tlb entry.
The fetchop and uncached driver because the CPU does not allow both cached
and uncached references to the same cache line on the FSB at the same
time and kernel speculation is possible whenever there is a tlb entry.

The cached driver suffers from the other part of that problem.  The kernel
will occasionally have an lfetch.excl with the operation on that address
being predicated.  The processor will prefetch the cache line, never
actually put any data in it, but still consider it dirty and then write
the line back.  This would result in clobbering the data.

All of this is avoided by this driver by handling the pages with physical
addresses only.

Thank you,
Robin Holt
