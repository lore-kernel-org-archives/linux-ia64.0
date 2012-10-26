From: Shuah Khan <shuah.khan@hp.com>
Date: Fri, 26 Oct 2012 15:45:08 +0000
Subject: [PATCH RFT RESEND linux-next] ia64: dma-mapping: support debug_dma_mapping_error
Message-Id: <1351266308.4013.5.camel@lorien2>
List-Id: <linux-ia64.vger.kernel.org>
References: <1351207286.6851.13.camel@lorien2>
In-Reply-To: <1351207286.6851.13.camel@lorien2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com, m.szyprowski@samsung.com, arnd@arndb.de, andrzej.p@samsung.com, kyungmin.park@samsung.com
Cc: linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, shuahkhan@gmail.com

Add support for debug_dma_mapping_error() call to avoid warning from
debug_dma_unmap() interface when it checks for mapping error checked
status. Without this patch, device driver failed to check map error
warning is generated.

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



