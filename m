From: Christoph Hellwig <hch@lst.de>
Date: Fri, 07 Dec 2018 19:07:13 +0000
Subject: [PATCH 08/15] dma-mapping: move dma_get_required_mask to kernel/dma
Message-Id: <20181207190720.18517-9-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de>
In-Reply-To: <20181207190720.18517-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, =?UTF-8?q?Toke=20H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

dma_get_required_mask should really be with the rest of the DMA mapping
implementation instead of in drivers/base as a lone outlier.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/base/platform.c | 31 -------------------------------
 kernel/dma/mapping.c    | 34 +++++++++++++++++++++++++++++++++-
 2 files changed, 33 insertions(+), 32 deletions(-)

diff --git a/drivers/base/platform.c b/drivers/base/platform.c
index 41b91af95afb..eae841935a45 100644
--- a/drivers/base/platform.c
+++ b/drivers/base/platform.c
@@ -1179,37 +1179,6 @@ int __init platform_bus_init(void)
 	return error;
 }
 
-#ifndef ARCH_HAS_DMA_GET_REQUIRED_MASK
-static u64 dma_default_get_required_mask(struct device *dev)
-{
-	u32 low_totalram = ((max_pfn - 1) << PAGE_SHIFT);
-	u32 high_totalram = ((max_pfn - 1) >> (32 - PAGE_SHIFT));
-	u64 mask;
-
-	if (!high_totalram) {
-		/* convert to mask just covering totalram */
-		low_totalram = (1 << (fls(low_totalram) - 1));
-		low_totalram += low_totalram - 1;
-		mask = low_totalram;
-	} else {
-		high_totalram = (1 << (fls(high_totalram) - 1));
-		high_totalram += high_totalram - 1;
-		mask = (((u64)high_totalram) << 32) + 0xffffffff;
-	}
-	return mask;
-}
-
-u64 dma_get_required_mask(struct device *dev)
-{
-	const struct dma_map_ops *ops = get_dma_ops(dev);
-
-	if (ops->get_required_mask)
-		return ops->get_required_mask(dev);
-	return dma_default_get_required_mask(dev);
-}
-EXPORT_SYMBOL_GPL(dma_get_required_mask);
-#endif
-
 static __initdata LIST_HEAD(early_platform_driver_list);
 static __initdata LIST_HEAD(early_platform_device_list);
 
diff --git a/kernel/dma/mapping.c b/kernel/dma/mapping.c
index dfbc3deb95cd..dfe29d18dba1 100644
--- a/kernel/dma/mapping.c
+++ b/kernel/dma/mapping.c
@@ -5,7 +5,7 @@
  * Copyright (c) 2006  SUSE Linux Products GmbH
  * Copyright (c) 2006  Tejun Heo <teheo@suse.de>
  */
-
+#include <linux/memblock.h> /* for max_pfn */
 #include <linux/acpi.h>
 #include <linux/dma-noncoherent.h>
 #include <linux/export.h>
@@ -262,3 +262,35 @@ int dma_common_mmap(struct device *dev, struct vm_area_struct *vma,
 #endif /* !CONFIG_ARCH_NO_COHERENT_DMA_MMAP */
 }
 EXPORT_SYMBOL(dma_common_mmap);
+
+#ifndef ARCH_HAS_DMA_GET_REQUIRED_MASK
+static u64 dma_default_get_required_mask(struct device *dev)
+{
+	u32 low_totalram = ((max_pfn - 1) << PAGE_SHIFT);
+	u32 high_totalram = ((max_pfn - 1) >> (32 - PAGE_SHIFT));
+	u64 mask;
+
+	if (!high_totalram) {
+		/* convert to mask just covering totalram */
+		low_totalram = (1 << (fls(low_totalram) - 1));
+		low_totalram += low_totalram - 1;
+		mask = low_totalram;
+	} else {
+		high_totalram = (1 << (fls(high_totalram) - 1));
+		high_totalram += high_totalram - 1;
+		mask = (((u64)high_totalram) << 32) + 0xffffffff;
+	}
+	return mask;
+}
+
+u64 dma_get_required_mask(struct device *dev)
+{
+	const struct dma_map_ops *ops = get_dma_ops(dev);
+
+	if (ops->get_required_mask)
+		return ops->get_required_mask(dev);
+	return dma_default_get_required_mask(dev);
+}
+EXPORT_SYMBOL_GPL(dma_get_required_mask);
+#endif
+
-- 
2.19.1
