From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 26 May 2005 17:21:46 +0000
Subject: Re: flush_icache_range
Message-Id: <17046.1450.646329.186968@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 23 May 2005 15:43:16 +0200, Zoltan Menyhart <Zoltan.Menyhart@bull.net> said:

  Zoltan> The Itanium 2 processor Reference Manual for SW development
  Zoltan> & optimization (May 2004) says in the chapter 5.8:

  Zoltan> "In Itanium 2 processor, each fc will invalidate 128 bytes
  Zoltan> corresponding to the L3 cache line size. Since both the L1I
  Zoltan> and L1D have line sizes of 64 bytes, a single fc instruction
  Zoltan> can invalidate two lines."

  Zoltan> Can someone please confirm that an equivalent statement is
  Zoltan> true for the "fc.i", too ?  Say:

  Zoltan> "In Itanium 2 processor, each fc.i instruction will ensure
  Zoltan> that 128 bytes (corresponding to the L3 cache line size) of
  Zoltan> the I-cache(s) be coherent with the data caches. Since the
  Zoltan> L1I cache has line sizes of 64 bytes, a single fc.i
  Zoltan> instruction can make coherent two lines."

On Itanium 2, fc.i maps to fc, so I'd say by definition it is true
that fc.i has the same effect.

BTW: I would prefer if we picked up the stride from the PAL info.
That way, we don't have to add ugly #ifdef's and hope that we get the
right stride.  I just checked on a Madison and, indeed it reports:

Data Cache level 1:
        Size           : 16384 bytes
        Attributes     : WriteThrough
        Associativity  : 4
        Line size      : 64 bytes
        Stride         : 128 bytes
	   :

Note that the "Stride" is 128 bytes.  The PAL manual defines the
stride as:

	the most effective stride in bytes for flushing the cache

So, what we could do is walk through the PAL cache-info, determine the
minimum stride and store the min. stride in a per-CPU variable.

  Zoltan> Modified in d-cache:
  Zoltan> cycles = 19,164 time = 14.782 usec
  Zoltan>	[snip...]

  Zoltan> Can these results be real?

Can you remind me how much data you flushed?

	--david
