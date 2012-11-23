From: Shuah Khan <shuah.khan@hp.com>
Date: Fri, 23 Nov 2012 21:32:55 +0000
Subject: [PATCH 3/9] ia64: dma_debug: add debug_dma_mapping_error support
Message-Id: <1353706375.5270.98.camel@lorien2>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

Add dma-debug interface debug_dma_mapping_error() to debug drivers that fail
to check dma mapping errors on addresses returned by dma_map_single() and
dma_map_page() interfaces.

Signed-off-by: Shuah Khan <shuah.khan@hp.com>
---
 arch/ia64/include/asm/dma-mapping.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
index 4f5e814..cf3ab7e 100644
--- a/arch/ia64/include/asm/dma-mapping.h
+++ b/arch/ia64/include/asm/dma-mapping.h
@@ -58,6 +58,7 @@ static inline void dma_free_attrs(struct device *dev, size_t size,
 static inline int dma_mapping_error(struct device *dev, dma_addr_t daddr)
 {
 	struct dma_map_ops *ops = platform_dma_get_ops(dev);
+	debug_dma_mapping_error(dev, daddr);
 	return ops->mapping_error(dev, daddr);
 }
 
-- 
1.7.9.5





