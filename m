From: Christoph Hellwig <hch@lst.de>
Date: Fri, 16 Jun 2017 18:10:25 +0000
Subject: [PATCH 10/44] ia64: remove DMA_ERROR_CODE
Message-Id: <20170616181059.19206-11-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170616181059.19206-1-hch@lst.de>
In-Reply-To: <20170616181059.19206-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: x86@kernel.org, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, openrisc@lists.librecores.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org, linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

All ia64 dma_mapping_ops instances already have a mapping_error member.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/include/asm/dma-mapping.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
index 73ec3c6f4cfe..3ce5ab4339f3 100644
--- a/arch/ia64/include/asm/dma-mapping.h
+++ b/arch/ia64/include/asm/dma-mapping.h
@@ -12,8 +12,6 @@
 
 #define ARCH_HAS_DMA_GET_REQUIRED_MASK
 
-#define DMA_ERROR_CODE 0
-
 extern const struct dma_map_ops *dma_ops;
 extern struct ia64_machine_vector ia64_mv;
 extern void set_iommu_machvec(void);
-- 
2.11.0

