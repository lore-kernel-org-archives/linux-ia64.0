From: okaya@codeaurora.org
Date: Wed, 01 Aug 2018 06:41:23 +0000
Subject: Re: [PATCH] ia64: fix barrier placement for write* / dma mapping
Message-Id: <c7ecb31e9a79d26ce9edb15f58e0880f@codeaurora.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180731172031.4447-1-hch@lst.de>
 <20180731172031.4447-2-hch@lst.de>
In-Reply-To: <20180731172031.4447-2-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, okaya@kernel.org

+ my new email

On 2018-07-31 10:20, Christoph Hellwig wrote:
> memory-barriers.txt has been updated with the following requirement.
> 
> "When using writel(), a prior wmb() is not needed to guarantee that the
> cache coherent memory writes have completed before writing to the MMIO
> region."
> 
> The current writeX() and iowriteX() implementations on ia64 are not
> satisfying this requirement as the barrier is after the register write.
> 

I asked this question to Tony Luck before. If I remember right,
his answer was:

CPU guarantees outstanding writes to be flushed when a register write
instruction is executed and an additional barrier instruction is not
needed.

> This adds the missing memory barriers, and instead drops them from the
> dma sync routine where they are misplaced (and were missing in the
> more important map/unmap cases anyway).
> 
> All this doesn't affect the SN2 platform, which already has barrier
> in the I/O accessors, and none in dma mapping (but then again
> swiotlb doesn't have any either).
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
