From: "David S. Miller" <davem@redhat.com>
Date: Wed, 24 Apr 2002 05:50:15 +0000
Subject: [Linux-ia64] Re: PCI DAC routines for SN
Message-Id: <marc-linux-ia64-105590701905507@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905493@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905493@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Jesse Barnes <jbarnes@sgi.com>
   Date: Tue, 23 Apr 2002 22:49:48 -0700

   > Therefore pci_alloc_consistent MUST provide SAC only addressing.
   > 
   > I was seeing patches where people would set the DMA mask for the
   > pci_dev around pci_alloc_consistent calls in order to accomplish
   > getting SAC addresses.  That is exactly the kind of crap I was
   > trying to avoid.
   
   Why would they need to do that?  If the driver sets its dma_mask to 64
   bits, why can't the platform choose to return a 64 bit DMA address?
   Obviously, if their device only supports 32 bits, then they'd set
   their dma_mask accordingly and only get SAC addresses back from
   alloc_consistent.  I'm obviously not understaning something...
   
NO!  They were doing this to workaround the IA64 broken behavior.

They wanted "dma_mask = DAC, but give me SAC for consistent
allocations" (ie. what the code should do automatically for them as
per Documentation/DMA-mapping.txt) and they were messing with the
dma_mask around the pci_alloc_consistent() calls because of IA64
not following the API.

   > Is this needed because you bozos don't have any physical memory below
   > 4GB on some weird ia64 system ___AND___ you lack a PCI IOMMU in the
   > controllers again?  This is getting rediculious if so, and I really
   > want to avoid crapping up the PCI DMA interfaces just because the ia64
   > PCI hardware folks keep making stupid design decisions.
   
   Not at all.  SGI Origin hardware has PCI bridges that can coherently
   access 64 bit DMA regions.  It can also map a limited number of 32 bit
   addresses into arbitrary 4 GB memory windows of system memory.  The
   number of mappings is somewhat limited however, since most devices are
   expected to use 64 bit addresses directly.
   
Bad expectation, most devices cannot do this.  Like I suspected, bad
hardware design decisions are behind this.

I keep my position that there is no legitimate need to add this
interface besides perhaps broken hardware.

4GB of SAC addressible RAM is enough to satisfy even the most
convoluted use of consisten allocations.

Furthermore, and the important part you are ignoring, using DAC for
consistent allocations will incur a performance penalty because every
address cycle emitted by the device for a transaction will require
more cycles than if SAC addresses were only used for consistent
memory.

You have totally failed to consider this issue.  All you can think
about is "my system can do it, why can't I have the interface" without
once considering if that interface makes any sense to use at all even
if you can do it.

