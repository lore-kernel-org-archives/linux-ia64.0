From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 27 Feb 2004 00:06:07 +0000
Subject: Re: Excessive time to handle interrupts
Message-Id: <16446.35311.804555.191942@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16446.34009.722204.259663@wombat.chubb.wattle.id.au>
In-Reply-To: <16446.34009.722204.259663@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 27 Feb 2004 10:44:25 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
  Peter> low32 = readl(addr + IOSAPIC_WINDOW);
  Peter> low32 &= ~(1 << IOSAPIC_MASK_SHIFT);    /* set only the mask bit */
  Peter> writel(low32, addr + IOSAPIC_WINDOW);

  Peter> I don't know enough about the hardware to say for sure

See:

  http://www.intel.com/design/itanium/downloads/25135001.pdf

  Peter> is it feasible to keep a soft copy of the register rather
  Peter> than do the read all the time?  If that's not going to break
  Peter> the hardware, I'll code it up and see if interrupt latencies
  Peter> go down.

AFAIR, the I/O SAPIC interrupt masking is entirely under control of
the CPU (i.e., the hw never changes the mask of its own) so caching
sounds like a good idea.

FYI: I'm planning to do a q-syscollect enhancement which would let you
get at least a flat profile for code which disables interrupts (or
even interrupt collection).

	--david
