From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 06 Jul 2004 23:45:07 +0000
Subject: Re: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <16619.14724.1660.14476@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 30 Jun 2004 11:11:04 -0700, Jesse Barnes <jbarnes@engr.sgi.com> said:

  >> Looks like there are more places where kernel does "virt -> phys -> virt".
  >> And conversion from phys to virt is setting 3 msb to 1.

  Jesse> Yep, that looks like a problem.  The kernel hangs right after
  Jesse> the local_flush_tlb_all in ia64_tlb_init, and if I comment it
  Jesse> out I get a "Unable to handle kernel paging request at
  Jesse> virtual address a000003004289f70" which, on sn2, looks like a
  Jesse> virt -> phys -> virt conversion (i.e. 0x3004289f70 is a valid
  Jesse> physical address).

I'm not sure this is related.  local_flush_tlb_all() simply flushes
the entire tlb it doesn't touch the "current" pointer in any shape or
fashion.  Not doing that flush will leave the kernel with stale TLB
entries, so all bets are off.

	--david
