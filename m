From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Wed, 05 Aug 2020 22:41:21 +0000
Subject: Re: Regression in 543cea9a - was: Re: Kernel problem on rx2800 i2
Message-Id: <1c3e150d-6572-c53f-6b0d-f0c11fe9762a@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
In-Reply-To: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 8/5/20 11:27 PM, John Paul Adrian Glaubitz wrote:
> with the same result. That's on 4.19.137. Can try a newer kernel tomorrow.
Looking at the change [1], I noticed that the ia64-specific "ia64_swiotlb_alloc_coherent()"
contained an additional check whether the DMA_BIT_MASK is 64 bits, so I added that back into
swiotlb_alloc():

diff --git a/kernel/dma/swiotlb.c b/kernel/dma/swiotlb.c
index 2a8c41f12d45..e51654180189 100644
--- a/kernel/dma/swiotlb.c
+++ b/kernel/dma/swiotlb.c
@@ -1018,6 +1018,9 @@ void *swiotlb_alloc(struct device *dev, size_t size, dma_addr_t *dma_handle,
        if (gfp & __GFP_NOWARN)
                attrs |= DMA_ATTR_NO_WARN;
 
+       if (dev->coherent_dma_mask != DMA_BIT_MASK(64))
+               gfp |= GFP_DMA32;
+
        /*
         * Don't print a warning when the first allocation attempt fails.
         * swiotlb_alloc_coherent() will print a warning when the DMA memory

No success, unfortunately even though this additional check was the only ia64-specific
part in the old code. But I assume the problem is also that swiotlb_alloc_coherent()
got replaced by swiotlb_alloc()?

Adrian

> [1] https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit/?idT3cea9accd9804307541cb93d3ed7ec94b07237

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
