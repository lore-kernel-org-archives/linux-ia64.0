From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 10 Mar 2004 19:48:54 +0000
Subject: Re: Virtual memory leaking through IA32 emulation layer for mmap
Message-Id: <200403101948.i2AJmsYH002407@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
In-Reply-To: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 10 Mar 2004 11:31:50 -0800, Arun Sharma <arun.sharma@intel.com> said:

  Arun> Yes, I'd really like to see this problem fixed. I think, the
  Arun> patch needs to be as memory efficient as possible - we're
  Arun> using non-pageable kernel memory. So some numbers on the two
  Arun> level bitmap scheme vs keeping lists of head/tail pages for
  Arun> common ia32 workloads would be good.

Agreed.  The good news is that the track is only needed for parially
allocated pages, so the overhead should, in the worst-case, be
proportional to the number of vmareas, not to the amount of memory
mapped.

	--david
