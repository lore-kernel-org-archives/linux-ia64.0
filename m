From: Christoph Hellwig <hch@lst.de>
Date: Fri, 29 Dec 2017 08:18:07 +0000
Subject: [PATCH 03/67] dma-mapping: take dma_pfn_offset into account in dma_max_pfn
Message-Id: <20171229081911.2802-4-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171229081911.2802-1-hch@lst.de>
In-Reply-To: <20171229081911.2802-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, Michal Simek <monstr@monstr.eu>, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, patches@groups.riscv.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

This makes sure the generic version can be used with architectures /
devices that have a DMA offset in the direct mapping.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/dma-mapping.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 81ed9b2d84dc..d84951865be7 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -692,7 +692,7 @@ static inline int dma_set_seg_boundary(struct device *dev, unsigned long mask)
 #ifndef dma_max_pfn
 static inline unsigned long dma_max_pfn(struct device *dev)
 {
-	return *dev->dma_mask >> PAGE_SHIFT;
+	return (*dev->dma_mask >> PAGE_SHIFT) + dev->dma_pfn_offset;
 }
 #endif
 
-- 
2.14.2

