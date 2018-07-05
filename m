From: Christoph Hellwig <hch@lst.de>
Date: Thu, 05 Jul 2018 19:37:38 +0000
Subject: Re: [RFC PATCH 1/2] dma-mapping: Clean up dma_set_*mask() hooks
Message-Id: <20180705193738.GB28905@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <55ac9550c311f056dcfeed9b2c8265375f17b155.1530726467.git.robin.murphy@arm.com>
In-Reply-To: <55ac9550c311f056dcfeed9b2c8265375f17b155.1530726467.git.robin.murphy@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Murphy <robin.murphy@arm.com>
Cc: hch@lst.de, m.szyprowski@samsung.com, iommu@lists.linux-foundation.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Wed, Jul 04, 2018 at 06:50:11PM +0100, Robin Murphy wrote:
> Arch-specific implementions for dma_set_{coherent_,}mask() currently
> rely on an inconsistent mix of arch-defined Kconfig symbols and macro
> overrides. Now that we have a nice centralised home for DMA API gubbins,
> let's consolidate these loose ends under consistent config options.
> 
> Signed-off-by: Robin Murphy <robin.murphy@arm.com>
> ---
> 
> Here's hoping the buildbot comes by to point out what I've inevitably
> missed, although I did check a cursory cross-compile of ppc64_defconfig
> to iron out the obvious howlers.

The patch looks sensible to me, although I was hoping to get rid of these
hooks in this or the next merge window as they are a horrible bad idea.

> The motivation here is that I'm looking at adding set_mask overrides
> for arm64, and having discovered a bit of a mess it seemed prudent to
> clean up before ingraining it any more.

What are you trying to do?  I really don't want to see more users of
the hooks as they are are a horribly bad idea.
