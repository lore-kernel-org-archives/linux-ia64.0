From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 15 Mar 2005 18:21:45 +0000
Subject: Re: flush_icache_range
Message-Id: <16951.10169.541077.375136@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 15 Mar 2005 13:40:21 +0100, Zoltan Menyhart <Zoltan.Menyhart@bull.net> said:

  Zoltan> Apparently, the function flush_icache_range() flushes the
  Zoltan> caches 32 by 32 bytes.
  Zoltan> According to some measures on a Tiger box, an "fc" instruction
  Zoltan> costs 200 nanosec. if no other CPU has the line its cache,
  Zoltan> there is no traffic on the bus, everything is ideal.
  Zoltan> If all the others CPUs have the line in their caches, they post
  Zoltan> bus transactions, then the cost of an "fc" instruction is 5
  Zoltan> microsec.
  Zoltan> To flush a full page of 64 Kbytes, it can take 400 microsec. to
  Zoltan> 10 millisec.

  Zoltan> Cannot we test at the boot time the characteristics of the
  Zoltan> CPUs and select the optimal flush_icache_range() ? E.g.:
  Zoltan> - if the CPU has 64 bytes / L1 lines =>
  Zoltan> flush by use of 64 byte steps
  Zoltan> - if the CPU implements the "fc.i" instruction =>
  Zoltan> flush the I-caches only

Does it actually make any difference?  The expensive part of "fc" is
when it's causing write-backs and you end up being memory-bandwidth
limited.  With a 64-byte stride, the CPU would do less work, but you'd
still be bottlenecked by the write-back speed.

64-byte stride would help a bit when the cache is clean already.
IIRC, it didn't make much of a difference when I measured it last,
though.

OTOH, if it's really a performance-advantage, we could relatively
easily do a runtime patch of the stride in the flush-icache routine.

As far fc vs fc.i: I submitted a patch to Tony for that a few
days/weeks ago.  In practice, it's not going to make a difference on
current CPUs because fc.i is just an alias for fc.

	--david
