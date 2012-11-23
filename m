From: Shuah Khan <shuah.khan@hp.com>
Date: Fri, 23 Nov 2012 21:37:22 +0000
Subject: [PATCH 8/9] sparc: dma_debug: add debug_dma_mapping_error support
Message-Id: <1353706642.5270.104.camel@lorien2>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

Add dma-debug interface debug_dma_mapping_error() to debug drivers that fail
to check dma mapping errors on addresses returned by dma_map_single() and
dma_map_page() interfaces.

Signed-off-by: Shuah Khan <shuah.khan@hp.com>
Acked-by: David S. Miller <davem@davemloft.net>
---
 arch/sparc/include/asm/dma-mapping.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/sparc/include/asm/dma-mapping.h b/arch/sparc/include/asm/dma-mapping.h
index 8493fd3..05fe53f 100644
--- a/arch/sparc/include/asm/dma-mapping.h
+++ b/arch/sparc/include/asm/dma-mapping.h
@@ -59,6 +59,7 @@ static inline void dma_free_attrs(struct device *dev, size_t size,
 
 static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 {
+	debug_dma_mapping_error(dev, dma_addr);
 	return (dma_addr = DMA_ERROR_CODE);
 }
 
-- 
1.7.9.5




