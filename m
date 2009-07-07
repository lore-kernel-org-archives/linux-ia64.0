From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Tue, 07 Jul 2009 08:42:26 +0000
Subject: [PATCH] IA64: fix CONFIG_DMA_API_DEBUG support
Message-Id: <20090707171456H.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

The commit 9916219579d078c80377dd3988c2cc213536d868 was supposed to
add CONFIG_DMA_API_DEBUG support to IA64 however I forgot to add
dma_debug_init().

Signed-off-by: fujita <fujita@tulip.osrg.net>
---
 arch/ia64/kernel/dma-mapping.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/dma-mapping.c b/arch/ia64/kernel/dma-mapping.c
index 086a2ae..b45e155 100644
--- a/arch/ia64/kernel/dma-mapping.c
+++ b/arch/ia64/kernel/dma-mapping.c
@@ -6,6 +6,14 @@ int iommu_detected __read_mostly;
 struct dma_map_ops *dma_ops;
 EXPORT_SYMBOL(dma_ops);
 
+#define PREALLOC_DMA_DEBUG_ENTRIES (1 << 16)
+
+static int __init dma_init(void)
+{
+	dma_debug_init(PREALLOC_DMA_DEBUG_ENTRIES);
+}
+fs_initcall(dma_init);
+
 struct dma_map_ops *dma_get_ops(struct device *dev)
 {
 	return dma_ops;
-- 
1.5.6.5

