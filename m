From: Marek Szyprowski <m.szyprowski@samsung.com>
Date: Tue, 25 Aug 2020 11:30:41 +0000
Subject: Re: a saner API for allocating DMA addressable pages
Message-Id: <8fa1ce36-c783-1a02-6890-211eb504a33b@samsung.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CGME20200819065610eucas1p2fde88e81917071b1888e7cc01ba0f298@eucas1p2.samsung.com>
        <20200819065555.1802761-1-hch@lst.de>
In-Reply-To: <20200819065555.1802761-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, Mauro Carvalho Chehab <mchehab@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Joonyoung Shim <jy0922.shim@samsung.com>, Seung-Woo Kim <sw0312.kim@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Ben Skeggs <bskeggs@redhat.com>, Pawel Osciak <pawel@osciak.com>, Matt Porter <mporter@kernel.crashing.org>, iommu@lists.linux-foundation.org
Cc: Tom Lendacky <thomas.lendacky@amd.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-samsung-soc@vger.kernel.org, nouveau@lists.freedesktop.org, netdev@vger.kernel.org, linux-nvme@lists.infradead.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org, alsa-devel@alsa-project.org

Hi Christoph,

On 19.08.2020 08:55, Christoph Hellwig wrote:
> this series replaced the DMA_ATTR_NON_CONSISTENT flag to dma_alloc_attrs
> with a separate new dma_alloc_pages API, which is available on all
> platforms.  In addition to cleaning up the convoluted code path, this
> ensures that other drivers that have asked for better support for
> non-coherent DMA to pages with incurring bounce buffering over can finally
> be properly supported.
>
> I'm still a little unsure about the API naming, as alloc_pages sort of
> implies a struct page return value, but we return a kernel virtual
> address.  The other alternative would be to name the API
> dma_alloc_noncoherent, but the whole non-coherent naming seems to put
> people off.  As a follow up I plan to move the implementation of the
> DMA_ATTR_NO_KERNEL_MAPPING flag over to this framework as well, given
> that is also is a fundamentally non coherent allocation.  The replacement
> for that flag would then return a struct page, as it is allowed to
> actually return pages without a kernel mapping as the name suggested
> (although most of the time they will actually have a kernel mapping..)
>
> In addition to the conversions of the existing non-coherent DMA users
> the last three patches also convert the DMA coherent allocations in
> the NVMe driver to use this new framework through a dmapool addition.
> This was both to give me a good testing vehicle, but also because it
> should speed up the NVMe driver on platforms with non-coherent DMA
> nicely, without a downside on platforms with cache coherent DMA.

I really wonder what is the difference between this new API and 
alloc_pages(GFP_DMA, n). Is this API really needed? I thought that this 
is legacy thing to be removed one day...

Maybe it would make more sense to convert the few remaining drivers to 
regular dma_map_page()/dma_sync_*()/dma_unmap_page() or have I missed 
something?

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland
