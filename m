From: Shuah Khan <shuah.khan@hp.com>
Date: Fri, 23 Nov 2012 21:32:06 +0000
Subject: [PATCH 2/9] c6x: dma_debug: add debug_dma_mapping_error support
Message-Id: <1353706326.5270.97.camel@lorien2>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

Add dma-debug interface debug_dma_mapping_error() to debug drivers that fail
to check dma mapping errors on addresses returned by dma_map_single() and
dma_map_page() interfaces.

Signed-off-by: Shuah Khan <shuah.khan@hp.com>
Acked-by: Mark Salter <msalter@redhat.com>
---
 arch/c6x/include/asm/dma-mapping.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/c6x/include/asm/dma-mapping.h b/arch/c6x/include/asm/dma-mapping.h
index 03579fd..3c69406 100644
--- a/arch/c6x/include/asm/dma-mapping.h
+++ b/arch/c6x/include/asm/dma-mapping.h
@@ -32,6 +32,7 @@ static inline int dma_set_mask(struct device *dev, u64 dma_mask)
  */
 static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 {
+	debug_dma_mapping_error(dev, dma_addr);
 	return dma_addr = ~0;
 }
 
-- 
1.7.9.5





