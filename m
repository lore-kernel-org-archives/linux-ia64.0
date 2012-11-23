From: Shuah Khan <shuah.khan@hp.com>
Date: Fri, 23 Nov 2012 21:34:56 +0000
Subject: [PATCH 5/9] mips: dma_debug: add debug_dma_mapping_error support
Message-Id: <1353706496.5270.101.camel@lorien2>
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
 arch/mips/include/asm/dma-mapping.h |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/mips/include/asm/dma-mapping.h b/arch/mips/include/asm/dma-mapping.h
index be39a12..006b43e 100644
--- a/arch/mips/include/asm/dma-mapping.h
+++ b/arch/mips/include/asm/dma-mapping.h
@@ -40,6 +40,8 @@ static inline int dma_supported(struct device *dev, u64 mask)
 static inline int dma_mapping_error(struct device *dev, u64 mask)
 {
 	struct dma_map_ops *ops = get_dma_ops(dev);
+
+	debug_dma_mapping_error(dev, mask);
 	return ops->mapping_error(dev, mask);
 }
 
-- 
1.7.9.5




