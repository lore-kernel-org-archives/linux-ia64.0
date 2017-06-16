From: Christoph Hellwig <hch@lst.de>
Date: Fri, 16 Jun 2017 18:10:27 +0000
Subject: [PATCH 12/44] microblaze: remove DMA_ERROR_CODE
Message-Id: <20170616181059.19206-13-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170616181059.19206-1-hch@lst.de>
In-Reply-To: <20170616181059.19206-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: x86@kernel.org, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, openrisc@lists.librecores.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org, linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

microblaze does not return errors for dma_map_page.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/microblaze/include/asm/dma-mapping.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/arch/microblaze/include/asm/dma-mapping.h b/arch/microblaze/include/asm/dma-mapping.h
index 3fad5e722a66..e15cd2f76e23 100644
--- a/arch/microblaze/include/asm/dma-mapping.h
+++ b/arch/microblaze/include/asm/dma-mapping.h
@@ -28,8 +28,6 @@
 #include <asm/io.h>
 #include <asm/cacheflush.h>
 
-#define DMA_ERROR_CODE		(~(dma_addr_t)0x0)
-
 #define __dma_alloc_coherent(dev, gfp, size, handle)	NULL
 #define __dma_free_coherent(size, addr)		((void)0)
 
-- 
2.11.0

