From: "David S. Miller" <davem@redhat.com>
Date: Tue, 04 Dec 2001 20:22:54 +0000
Subject: Re: [Linux-ia64] patch to no longer use ia64's software mmu
Message-Id: <marc-linux-ia64-105590698805608@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805585@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805585@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: David Mosberger <davidm@hpl.hp.com>
   Date: Tue, 4 Dec 2001 08:26:59 -0800
   
   I think the issue at hand is whether, longer term, it is desirable to
   move all bounce buffer handling into the PCI DMA layer or whether
   Linux should continue to make bounce buffer management visible to
   drivers.  I'd be interested in hearing opinions.

Well, this whole ia64 situation should be the example that shows that
for severely broken 64-bit platforms, like IA64, doing the bounce
buffering in the PCI DMA layer is a lose.  The HIGHMEM option is the
optimal one in this case, and I think that is fine.

If what you are asking is should we tweak the APIs again so that
situations like current IA64 can be done more sanely in the PCI DMA
layer, I say definitely no.

There really is no excuse for the current IA64 hardware situation,
there were probably well over 3 or 4 major 64-bit platforms from
competitors, whose PCI controllers were pretty well documented
publicly, from which Intel could have derived a working 64-bit
platform PCI controller design.

When a saner IA64 hardware implementation comes about (if ever), you
can make CONFIG_IA64_WHATEVER_PLATFORM which undoes the HIGHMEM stuff
and enables PCI DMA support code for those chipsets.  As Alan has
suggested.  That is a perfectly fine way of dealing with this.

Franks a lot,
David S. Miller
davem@redhat.com


