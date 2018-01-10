From: Christoph Hellwig <hch@lst.de>
Date: Wed, 10 Jan 2018 08:00:00 +0000
Subject: [PATCH 06/33] m32r: remove the unused dma_capable helper
Message-Id: <20180110080027.13879-7-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080027.13879-1-hch@lst.de>
In-Reply-To: <20180110080027.13879-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, Michal Simek <monstr@monstr.eu>, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, patches@groups.riscv.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/m32r/include/asm/dma-mapping.h | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/arch/m32r/include/asm/dma-mapping.h b/arch/m32r/include/asm/dma-mapping.h
index 336ffe60814b..8967fb659691 100644
--- a/arch/m32r/include/asm/dma-mapping.h
+++ b/arch/m32r/include/asm/dma-mapping.h
@@ -14,11 +14,4 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return &dma_noop_ops;
 }
 
-static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
-{
-	if (!dev->dma_mask)
-		return false;
-	return addr + size - 1 <= *dev->dma_mask;
-}
-
 #endif /* _ASM_M32R_DMA_MAPPING_H */
-- 
2.14.2

