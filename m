From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 03 Dec 2001 21:47:41 +0000
Subject: Re: [Linux-ia64] patch to no longer use ia64's software mmu
Message-Id: <marc-linux-ia64-105590698805588@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805585@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805585@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

  Arjan> Hi, The patch below (against 2.4.16) makes the ia64 port no
  Arjan> longer use the (VERY slow) software IO mmu but makes it use
  Arjan> the same mechanism the x86 PAE port uses: it lets the higher
  Arjan> layers take care of the proper bouncing of PCI-unreachable
  Arjan> memory. The implemenation is pretty simple; instead of having
  Arjan> a 4Gb GFP_DMA zone and a <rest of ram> GFP_KERNEL zone, the
  Arjan> ia64 port now has a 4Gb GFP_DMA zone and a <rest of ram>
  Arjan> GFP_HIGH zone.  Since the ia64 cpu can address all of this
  Arjan> memory directly, the kmap() and related functions are
  Arjan> basically nops.

  Arjan> The result: 100 mbit ethernet performance on a ia64 machine
  Arjan> with 32Gb of ram increased more than 4x (from 20 mbit to 95
  Arjan> mbit)....

  Arjan> The only downside is that the current kernel will always
  Arjan> bounce buffer disk IO even if the scsi card is 64 bit PCI
  Arjan> capable; Jens Axboe's block highmem patch fixes that downside
  Arjan> nicely though.

How soon will Jens' patch make it into the official tree?  I think
that would be a pre-requisite before switching to a highmem based
implementation.

Another concern I have is that, fundamentally, I dislike the idea of
penalizing all IA-64 platforms due to one chipset that is, shall we
say, "lacking" (i.e., doesn't have an I/O TLB).

Could someone comment on whether the 870 will have I/O TLB support
(private mail is fine, if you don't feel comfortable sending mail to
all the lists...).

Thanks,

	--david

