From: Christoph Hellwig <hch@lst.de>
Date: Fri, 14 Dec 2018 14:24:35 +0000
Subject: Re: [PATCH 15/15] dma-mapping: bypass indirect calls for dma-direct
Message-Id: <20181214142435.GA18448@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de> <CGME20181207190927epcas1p457ae0498c01d1730723889bc7c9ed40d@epcas1p4.samsung.com> <20181207190720.18517-16-hch@lst.de> <edef688d-da7b-d42d-2890-7cf1ec415ac5@samsung.com>
In-Reply-To: <edef688d-da7b-d42d-2890-7cf1ec415ac5@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, Toke =?iso-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Fri, Dec 14, 2018 at 03:11:37PM +0100, Marek Szyprowski wrote:
> Hi Christoph,
> 
> On 2018-12-07 20:07, Christoph Hellwig wrote:
> > Avoid expensive indirect calls in the fast path DMA mapping
> > operations by directly calling the dma_direct_* ops if we are using
> > the directly mapped DMA operations.
> >
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> This breaks direct DMA on ARM64 (also todays linux-next). NULL
> dev->dma_ops fallbacks to get_arch_dma_ops(), which in turn returns
> non-functional &dma_dummy_ops on ARM64...

Yeah, fallback from direct (NULL) dev->dma_ops to something else won't
work with NULL as the indicator.

Fortunately we shouldn't even need that thanks to the patch from Robin
that explicitly set the dummy ops where needed.

Can you try the patch below?

diff --git a/arch/arm64/include/asm/dma-mapping.h b/arch/arm64/include/asm/dma-mapping.h
index 273e778f7de2..95dbf3ef735a 100644
--- a/arch/arm64/include/asm/dma-mapping.h
+++ b/arch/arm64/include/asm/dma-mapping.h
@@ -26,11 +26,7 @@
 
 static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 {
-	/*
-	 * We expect no ISA devices, and all other DMA masters are expected to
-	 * have someone call arch_setup_dma_ops at device creation time.
-	 */
-	return &dma_dummy_ops;
+	return NULL;
 }
 
 void arch_setup_dma_ops(struct device *dev, u64 dma_base, u64 size,
