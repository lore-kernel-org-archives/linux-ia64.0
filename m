From: Christoph Hellwig <hch@lst.de>
Date: Thu, 20 Aug 2020 05:15:12 +0000
Subject: Re: [PATCH 19/28] dma-mapping: replace DMA_ATTR_NON_CONSISTENT with dma_{alloc, free}_pages
Message-Id: <20200820051512.GA5141@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200819065555.1802761-1-hch@lst.de> <20200819065555.1802761-20-hch@lst.de> <CAAFQd5Bbp-eAVKS1MKS8xtrT4ZoOmBPfZyw9mys=eOmDb6r8Lw@mail.gmail.com>
In-Reply-To: <CAAFQd5Bbp-eAVKS1MKS8xtrT4ZoOmBPfZyw9mys=eOmDb6r8Lw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tomasz Figa <tfiga@chromium.org>
Cc: Christoph Hellwig <hch@lst.de>, Mauro Carvalho Chehab <mchehab@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Joonyoung Shim <jy0922.shim@samsung.com>, Seung-Woo Kim <sw0312.kim@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Ben Skeggs <bskeggs@redhat.com>, Pawel Osciak <pawel@osciak.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Matt Porter <mporter@kernel.crashing.org>, "list@263.net:IOMMU DRIVERS <iommu@lists.linux-foundation.org>, Joerg
        Roedel <joro@8bytes.org>," <iommu@lists.linux-foundation.org>, Tom Lendacky <thomas.lendacky@amd.com>, alsa-devel@alsa-project.org, linux-samsung-soc <linux-samsung-soc@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-scsi@vger.kernel.org, linux-parisc@vger.kernel.org, Linux Doc Mailing List <linux-doc@vger.kernel.org>, nouveau@lists.freedesktop.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvme@lists.infradead.org, linux-mips@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, "list@263.net:IOMMU DRIVERS <iommu@lists.linux-foundation.org>, Joerg
        Roedel <joro@8bytes.org>," <linux-arm-kernel@lists.infradead.org>, Linux Media Mailing List <linux-media@vger.kernel.org>

On Wed, Aug 19, 2020 at 05:03:52PM +0200, Tomasz Figa wrote:
> >
> > -Warning: These pieces of the DMA API should not be used in the
> > -majority of cases, since they cater for unlikely corner cases that
> > -don't belong in usual drivers.
> > +These APIs allow to allocate pages that can be used like normal pages
> > +in the kernel direct mapping, but are guaranteed to be DMA addressable.
> 
> Could we elaborate a bit more on what "like normal pages in kernel
> direct mapping" mean from the driver perspective?

It mostly means you can call virt_to_page and then do anything you'd
do with a page struct.  Unlike dma_alloc_attrs that just return an
opaque virtual address that the caller is not allowed to poke into.

> There is one aspect that the existing dma_alloc_attrs() handles, but
> this new function doesn't: IOMMU support. The function will always
> allocate a physically-contiguous block memory, which is a costly
> operation and not even guaranteed to succeed, even if enough free
> memory is available.
> 
> Modern SoCs employ IOMMUs to avoid the need to allocate
> physically-contiguous memory and those happen to be also the devices
> that could benefit from non-coherent allocations a lot. One of the
> tasks of the DMA API was making it possible to allocate suitable
> memory for a given device, without having the driver know about the
> SoC integration details, such as the presence of an IOMMU.

This is completely out of scope for this API exactly because it
guarantees a page in the direct mapping.  But see my previous mail
in reply to Robin on how you can implement the funtionality you
want right now without any help from the dma-mapping subsystem.
