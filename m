From: "David S. Miller" <davem@redhat.com>
Date: Thu, 15 May 2003 23:39:40 +0000
Subject: Re: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent
Message-Id: <marc-linux-ia64-105590723705856@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Matthew Wilcox <willy@debian.org>
   Date: Thu, 15 May 2003 22:29:18 +0100
   
   From the way he's talking,

My main point is that device attributes belong IN THE DEVICE
not in some umpteenth new parameter to the DMA interfaces.

Just put consistent_dma_mask into the device struct next to
the existing dma_mask, voila problem solved.

I have two major problems with the generic DMA interfaces
and how they are being handled in general:

1) Their use is entirely inappropriate in unary-bus devices.
   There is no way someone can justify some PCI driver continually
   asking itself whether it is a PCI device or not on each DMA
   API call.

2) Additions to the parameters in the interfaces is not given
   enough thought.  Each new parameter you add is a discrete failure
   of the API.  It was built to be simple, and new parameters do
   nothing but add complexity.

   I cannot even fathom that someone would suggest to pass device
   attributes into the DMA interfaces.  That is just garbage and
   unnecessary bloat.

Finally, I see nobody tackling the real hard bugs we have in the DMA
API.  These should be fixed first before adding random DMA behaviorial
attributes.  For example, pci_dma_sync_*() sucks because it only syncs
in one direction, device to cpu, there is nothing available to sync
things back from cpu-->device.  This prevents MIPS from using the
devices that need to do syncs without unmaps (eepro100 is but one
example, USB host controller drivers want this too).

