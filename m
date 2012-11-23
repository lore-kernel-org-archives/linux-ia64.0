From: Shuah Khan <shuah.khan@hp.com>
Date: Fri, 23 Nov 2012 21:37:54 +0000
Subject: [PATCH 9/9] tile: dma_debug: add debug_dma_mapping_error support
Message-Id: <1353706674.5270.105.camel@lorien2>
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
 arch/tile/include/asm/dma-mapping.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/tile/include/asm/dma-mapping.h b/arch/tile/include/asm/dma-mapping.h
index 4b6247d..f2ff191 100644
--- a/arch/tile/include/asm/dma-mapping.h
+++ b/arch/tile/include/asm/dma-mapping.h
@@ -72,6 +72,7 @@ static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 static inline int
 dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 {
+	debug_dma_mapping_error(dev, dma_addr);
 	return get_dma_ops(dev)->mapping_error(dev, dma_addr);
 }
 
-- 
1.7.9.5




