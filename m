From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 04 Dec 2001 19:56:33 +0000
Subject: Re: [Linux-ia64] patch to no longer use ia64's software mmu
Message-Id: <marc-linux-ia64-105590698805606@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805585@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805585@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 4 Dec 2001 17:18:17 +0000 (GMT), Alan Cox <alan@lxorguk.ukuu.org.uk> said:

  >> I think the issue at hand is whether, longer term, it is
  >> desirable to move all bounce buffer handling into the PCI DMA
  >> layer or whether Linux should continue to make bounce buffer
  >> management visible to drivers.  I'd be interested in hearing
  >> opinions.

  Alan> I think the performance figures we see currently answer that
  Alan> already.

The numbers I have seen so far don't make this obvious.  Tony Luck
reports 95Mbps with a CPU load of 20% after a fixing a performance bug
in the software I/O TLB.  Arjan reported the same 95Mbps figure with
the highmem approach.  Arjan didn't report the CPU load and neither
Tony nor Arjan specified the test environment they were using.

  Alan> IA64 also needs to correct its GFP_DMA to mean "low 16Mb" for
  Alan> ISA DMA. While there is no ISA DMA on ia64 (thankfully) many
  Alan> PCI cards have 26-31 bit limits.

We could do this if we there was a GFP_4GB zone.  Now that 2.5 is open
for business, it won't be long, right?

	--david

