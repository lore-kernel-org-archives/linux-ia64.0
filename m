From: Christoph Hellwig <hch@lst.de>
Date: Thu, 05 Jul 2018 19:38:46 +0000
Subject: Re: [RFC PATCH 2/2] dma-mapping: Clean up dma_get_required_mask() hooks
Message-Id: <20180705193846.GC28905@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <55ac9550c311f056dcfeed9b2c8265375f17b155.1530726467.git.robin.murphy@arm.com>
 <08256121f325ceed7f6b88c1a5d3cf949698787d.1530726467.git.robin.murphy@arm.com>
In-Reply-To: <08256121f325ceed7f6b88c1a5d3cf949698787d.1530726467.git.robin.murphy@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Murphy <robin.murphy@arm.com>
Cc: hch@lst.de, m.szyprowski@samsung.com, iommu@lists.linux-foundation.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Wed, Jul 04, 2018 at 06:50:12PM +0100, Robin Murphy wrote:
> As for the other mask-related hooks, standardise the arch override into
> a Kconfig option, and also pull the generic implementation into the DMA
> mapping code rather than having it hide away in the platform bus code.

Heh, I have a somewhat similar patch in my queue.  I didn't want it out
because dma_get_required_mask is rather ill defined at the moment and
I wanted to clean that up first.  But I guess I could apply this first
and clean up later.

I just fear you might be wanting to add an arm64 user, so I'd really like
to understand why and how.
