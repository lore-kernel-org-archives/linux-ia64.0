From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 04 Dec 2001 19:55:55 +0000
Subject: Re: [Linux-ia64] patch to no longer use ia64's software mmu
Message-Id: <marc-linux-ia64-105590698805604@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805585@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805585@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 4 Dec 2001 09:36:33 +0000 (GMT), Alan Cox <alan@lxorguk.ukuu.org.uk> said:

  >> Another concern I have is that, fundamentally, I dislike the idea
  >> of penalizing all IA-64 platforms due to one chipset that is,
  >> shall we say, "lacking" (i.e., doesn't have an I/O TLB).

  Alan> Allow me to introduce to you the concept of CONFIG_ options 8)
  Alan> It makes a lot of sense to have a generic IA64 kernel, and an
  Alan> IA64 designed by people with a brain kernel.

I think the issue at hand is whether, longer term, it is desirable to
move all bounce buffer handling into the PCI DMA layer or whether
Linux should continue to make bounce buffer management visible to
drivers.  I'd be interested in hearing opinions.

	--david

