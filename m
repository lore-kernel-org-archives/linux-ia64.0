From: Colin Ngam <cngam@sgi.com>
Date: Thu, 15 May 2003 22:14:11 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705851@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"David S. Miller" wrote:

>    From: Colin Ngam <cngam@sgi.com>
>    Date: Thu, 15 May 2003 08:17:58 -0500
>
>    Anyway, to make a long story short, we like to "extend" these
>    interfaces to return DMA addresses of 64 bits if and when the
>    driver has the full capabality to support DAC - via it's
>    DMA mask capability setting.
>
> All devices I am aware of do not support 64-bit addresses for their
> descriptors, only 32-bit.
>
> There is a huge difference between using a "64-bit address" and
> requiring to generate a DAC cycle, the latter of which is
> probably what you need and that is independant of what kind of
> address pci_alloc_consistent() is giving you.

David,

I am quite confuse with what you are saying.

pci_alloc_consistent(), as documented must return a 32bits DMA in the
dma mapped address in "dma_addr_t".

Right now, on our platform, the Upper 32 Bits of this address is always 0s
and the Lower 32 Bits has the IOMMU mapped DMA address.  When this
address is given to the card, SAC is generated because the Upper 32 Bits
are 0s - if the whole 64bits are given to the card.

Now, for PCI-X devices, we need to generate an IOMMU mapped DMA
address that  has the Upper 32 bits non 0s.  When the driver gives this
address to the card, it will generate a DAC for the DMA.

From what I understand from the pci_alloc_consistant() interface, we cannot
return a "dma_addr_t" that has the Upper 32bits NON 0s.  Is that TRUE?  If
it is, our platform cannot deal with this restriction .. therefore we are
requesting
for this extension.

Thanks.

colin


