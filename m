From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 04 Feb 2005 01:00:52 +0000
Subject: Re: [rfc] generic allocator and mspec driver
Message-Id: <16898.51524.380454.862495@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 03 Feb 2005 15:58:16 -0500, Jes Sorensen <jes@wildopensource.com> said:

  Jes> I hear your concerns! However, at the same time, if something
  Jes> within the kernel starts mocking with memory it doesn't own,
  Jes> thats a bug.

I'm not convinced of that.  Jack already mentioned lcrash...

  Jes> I was more concerned that there would be a case where
  Jes> prefetching or speculation would spill into a page in another
  Jes> granule and thereby cause a cacheable operation on the
  Jes> memory.

This is not an issue.  The AltTLB miss-handlers ignore misses
triggered by speculative accesses (including lfetch) or accesses
triggered by user-level.

  Jack> What prevents lcrash (or /dev/kmem or /proc/kcore) from
  Jack> referencing special memory being used for fetchops? Granted,
  Jack> this takes root privilege but the consequences of a bad
  Jack> reference can cause silent data corruption that is impossible
  Jack> to debug.  Should we add code to prohibit these area from
  Jack> referencing granules being used for mspec memory?

  Jes> I believe you will have the same problem with anyone messing
  Jes> with /dev/mem at random on the spill pages.

/dev/mem does check the memory attributes and accesses the memory
uncached if EFI_MEMORY_WB is _not_ set.  This probably needs to be
extended to check what the current usage of the page is (as opposed to
what the potential usages are).  Now that the kernel has it's own copy
of the memory-map, that's probably something we can do more easily.

OTOH, for pages which have a page-descriptor, a flag-bit would be the
most logical choice and that would make it possible to efficiently
check whether it is OK to access a page via a cacheable reference.

  Jes> Aha, I wasn't aware of this, I thought the region registers
  Jes> worked like some giant TLB. I'll add a flush for the granule
  Jes> when it's pulled into the allocator.

Don't you have to purge the all TLBs completely anyhow?

	--david
