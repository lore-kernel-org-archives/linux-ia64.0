From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 20 Jun 2003 18:49:33 +0000
Subject: Re: 2.5.72 for ia64 released
Message-Id: <marc-linux-ia64-105613498320378@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105605890319553@msgid-missing>
In-Reply-To: <marc-linux-ia64-105605890319553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 20 Jun 2003 11:45:19 -0700, jbarnes@sgi.com (Jesse Barnes) said:

  >> I thought the DISCONTIGMEM support is making assumptions about the
  >> physical memory layout.  If this is still true, DISCONTIGMEM and
  >> GENERIC cannot go together.

  Jesse> No, the discontig patch I posted earlier should allow this.  We've
  Jesse> tested it quite a bit in 2.4.

I'm not questioning whether it works on SGI, what I'm asking is
whether it will work on _all_ possible NUMA architectures, or just on
SN2.

  >> I suspect it would be more preferable if you could make it possible
  >> for a non-NUMA kernel to boot on your machine.

  Jesse> That might be nice, but I'd rather have CONFIG_GENERIC turn on
  Jesse> CONFIG_NUMA.  It shouldn't get in the way of non-NUMA machines...

What I worry about is that some distributions may end up shipping
GENERIC kernels, with no easy way to build an optimized kernel.  It's
reasonable to expect highend customers to build their own kernels, but
I don't think that's quite as reasonable to expect the same from
someone who buys a workstation.

	--david
