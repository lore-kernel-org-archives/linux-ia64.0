From: Colin Ngam <cngam@sgi.com>
Date: Thu, 15 May 2003 22:44:57 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705853@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

James Bottomley wrote:

> On Thu, 2003-05-15 at 17:14, Colin Ngam wrote:
> > Right now, on our platform, the Upper 32 Bits of this address is always 0s
> > and the Lower 32 Bits has the IOMMU mapped DMA address.  When this
> > address is given to the card, SAC is generated because the Upper 32 Bits
> > are 0s - if the whole 64bits are given to the card.
> >
> > Now, for PCI-X devices, we need to generate an IOMMU mapped DMA
> > address that  has the Upper 32 bits non 0s.  When the driver gives this
> > address to the card, it will generate a DAC for the DMA.
> >
> > >From what I understand from the pci_alloc_consistant() interface, we cannot
> > return a "dma_addr_t" that has the Upper 32bits NON 0s.  Is that TRUE?  If
> > it is, our platform cannot deal with this restriction .. therefore we are
> > requesting
> > for this extension.
>
> OK, now you've confused me.  I thought you were saying that your PCI
> hardware generates two type of addresses: one for DAC that *doesn't* go
> through the IOMMU and one for SAC that does?

Yes, you are correct .. we have the capability to generate a SAC or DAC address
in PCI Mode only.

>
>
> In which case, SAC should be able to go through the IOMMU to reach
> anwhere in memory, and thus pci_alloc_consistent should work for you
> now.
>
> Or are you saying it's more efficient to go via the DAC non-iommu cycle
> and you'd like to do that preferentially if you could (which is a
> feature request, not a hard requirement)?

However, in PCI-X mode, we do not have the capability to generate SAC addresses.
And yes, you are also correct that it is very much efficient on our architecture
to generate DAC for all(PCI/PCI-X)

So, it is a hard requirement to have DAC for PCI-X devices and not PCI devices.

Hope that is clear ..

Thanks.

colin

>
>
> James


