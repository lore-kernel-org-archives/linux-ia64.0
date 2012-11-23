From: Shuah Khan <shuah.khan@hp.com>
Date: Fri, 23 Nov 2012 21:33:42 +0000
Subject: [PATCH 4/9] microblaze: dma-mapping: support debug_dma_mapping_error
Message-Id: <1353706422.5270.99.camel@lorien2>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

Add support for debug_dma_mapping_error() call to avoid warning from
debug_dma_unmap() interface when it checks for mapping error checked
status. Without this patch, device driver failed to check map error
warning is generated.

Signed-off-by: Shuah Khan <shuah.khan@hp.com>
Acked-by: Michal Simek <monstr@monstr.eu>
---

This patch is already in linux-next. Including it in this series for
completeness. linux-next commit f229605441030bcd315c21d97b25889d63ed0130

-- shuah
---
 arch/microblaze/include/asm/dma-mapping.h |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/microblaze/include/asm/dma-mapping.h b/arch/microblaze/include/asm/dma-mapping.h
index 01d2282..46460f1 100644
--- a/arch/microblaze/include/asm/dma-mapping.h
+++ b/arch/microblaze/include/asm/dma-mapping.h
@@ -114,6 +114,8 @@ static inline void __dma_sync(unsigned long paddr,
 static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 {
 	struct dma_map_ops *ops = get_dma_ops(dev);
+
+	debug_dma_mapping_error(dev, dma_addr);
 	if (ops->mapping_error)
 		return ops->mapping_error(dev, dma_addr);
 
-- 
1.7.9.5




