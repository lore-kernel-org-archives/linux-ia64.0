From: Shuah Khan <shuah.khan@hp.com>
Date: Fri, 23 Nov 2012 21:31:09 +0000
Subject: [PATCH 1/9] ARM64: dma_debug: add debug_dma_mapping_error support
Message-Id: <1353706269.5270.96.camel@lorien2>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

Add dma-debug interface debug_dma_mapping_error() to debug drivers that fail
to check dma mapping errors on addresses returned by dma_map_single() and
dma_map_page() interfaces.

Signed-off-by: Shuah Khan <shuah.khan@hp.com>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
---
 arch/arm64/include/asm/dma-mapping.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm64/include/asm/dma-mapping.h b/arch/arm64/include/asm/dma-mapping.h
index 538f4b4..9947768 100644
--- a/arch/arm64/include/asm/dma-mapping.h
+++ b/arch/arm64/include/asm/dma-mapping.h
@@ -50,6 +50,7 @@ static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t dev_addr)
 static inline int dma_mapping_error(struct device *dev, dma_addr_t dev_addr)
 {
 	struct dma_map_ops *ops = get_dma_ops(dev);
+	debug_dma_mapping_error(dev, dev_addr);
 	return ops->mapping_error(dev, dev_addr);
 }
 
-- 
1.7.9.5





