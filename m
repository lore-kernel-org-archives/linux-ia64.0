From: Colin Ngam <cngam@sgi.com>
Date: Thu, 15 May 2003 13:17:58 +0000
Subject: [Linux-ia64] 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705821@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

The Altix PCI-X Bridge chipset expects devices that runs in
PCI-X mode to always be 64Bit DMA Address capable(DAC).  This
requirement is directly in conflict with both the
pci_alloc_consistent() and dma_alloc_coherent() interfaces.

The pci_alloc_consistent() interface is very clear that the mapped
dma address must be no bigger than 32 bits.  However, the
dma_alloc_coherent() interface is less clear:

"This routine allocates a region of <size> bytes of consistent memory.
it also returns a <dma_handle> which may be cast to an unsigned
integer the same width as the bus and used as the physical address
base of the region."

Anyway, to make a long story short, we like to "extend" these
interfaces to return DMA addresses of 64 bits if and when the
driver has the full capabality to support DAC - via it's
DMA mask capability setting.

This extention will not break current usages of these interface,
and as driver changes, this extension will enable platforms to
support all of it's Physical Memory via the above 2 Interfaces
without exhausting limited system mapping resources.

Thanks.

Colin Ngam



