From: Christoph Hellwig <hch@lst.de>
Date: Fri, 07 Dec 2018 19:07:17 +0000
Subject: [PATCH 12/15] dma-mapping: factor out dummy DMA ops
Message-Id: <20181207190720.18517-13-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de>
In-Reply-To: <20181207190720.18517-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, =?UTF-8?q?Toke=20H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

From: Robin Murphy <robin.murphy@arm.com>

The dummy DMA ops are currently used by arm64 for any device which has
an invalid ACPI description and is thus barred from using DMA due to not
knowing whether is is cache-coherent or not. Factor these out into
general dma-mapping code so that they can be referenced from other
common code paths. In the process, we can prune all the optional
callbacks which just do the same thing as the default behaviour, and
fill in .map_resource for completeness.

Signed-off-by: Robin Murphy <robin.murphy@arm.com>
[hch: moved to a separate source file]
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/arm64/include/asm/dma-mapping.h |  4 +-
 arch/arm64/mm/dma-mapping.c          | 86 ----------------------------
 include/linux/dma-mapping.h          |  1 +
 kernel/dma/Makefile                  |  2 +-
 kernel/dma/dummy.c                   | 39 +++++++++++++
 5 files changed, 42 insertions(+), 90 deletions(-)
 create mode 100644 kernel/dma/dummy.c

diff --git a/arch/arm64/include/asm/dma-mapping.h b/arch/arm64/include/asm/dma-mapping.h
index c41f3fb1446c..273e778f7de2 100644
--- a/arch/arm64/include/asm/dma-mapping.h
+++ b/arch/arm64/include/asm/dma-mapping.h
@@ -24,15 +24,13 @@
 #include <xen/xen.h>
 #include <asm/xen/hypervisor.h>
 
-extern const struct dma_map_ops dummy_dma_ops;
-
 static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 {
 	/*
 	 * We expect no ISA devices, and all other DMA masters are expected to
 	 * have someone call arch_setup_dma_ops at device creation time.
 	 */
-	return &dummy_dma_ops;
+	return &dma_dummy_ops;
 }
 
 void arch_setup_dma_ops(struct device *dev, u64 dma_base, u64 size,
diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
index e4effbb243b1..ab1e417204d0 100644
--- a/arch/arm64/mm/dma-mapping.c
+++ b/arch/arm64/mm/dma-mapping.c
@@ -89,92 +89,6 @@ static int __swiotlb_mmap_pfn(struct vm_area_struct *vma,
 }
 #endif /* CONFIG_IOMMU_DMA */
 
-/********************************************
- * The following APIs are for dummy DMA ops *
- ********************************************/
-
-static void *__dummy_alloc(struct device *dev, size_t size,
-			   dma_addr_t *dma_handle, gfp_t flags,
-			   unsigned long attrs)
-{
-	return NULL;
-}
-
-static void __dummy_free(struct device *dev, size_t size,
-			 void *vaddr, dma_addr_t dma_handle,
-			 unsigned long attrs)
-{
-}
-
-static int __dummy_mmap(struct device *dev,
-			struct vm_area_struct *vma,
-			void *cpu_addr, dma_addr_t dma_addr, size_t size,
-			unsigned long attrs)
-{
-	return -ENXIO;
-}
-
-static dma_addr_t __dummy_map_page(struct device *dev, struct page *page,
-				   unsigned long offset, size_t size,
-				   enum dma_data_direction dir,
-				   unsigned long attrs)
-{
-	return DMA_MAPPING_ERROR;
-}
-
-static void __dummy_unmap_page(struct device *dev, dma_addr_t dev_addr,
-			       size_t size, enum dma_data_direction dir,
-			       unsigned long attrs)
-{
-}
-
-static int __dummy_map_sg(struct device *dev, struct scatterlist *sgl,
-			  int nelems, enum dma_data_direction dir,
-			  unsigned long attrs)
-{
-	return 0;
-}
-
-static void __dummy_unmap_sg(struct device *dev,
-			     struct scatterlist *sgl, int nelems,
-			     enum dma_data_direction dir,
-			     unsigned long attrs)
-{
-}
-
-static void __dummy_sync_single(struct device *dev,
-				dma_addr_t dev_addr, size_t size,
-				enum dma_data_direction dir)
-{
-}
-
-static void __dummy_sync_sg(struct device *dev,
-			    struct scatterlist *sgl, int nelems,
-			    enum dma_data_direction dir)
-{
-}
-
-static int __dummy_dma_supported(struct device *hwdev, u64 mask)
-{
-	return 0;
-}
-
-const struct dma_map_ops dummy_dma_ops = {
-	.alloc                  = __dummy_alloc,
-	.free                   = __dummy_free,
-	.mmap                   = __dummy_mmap,
-	.map_page               = __dummy_map_page,
-	.unmap_page             = __dummy_unmap_page,
-	.map_sg                 = __dummy_map_sg,
-	.unmap_sg               = __dummy_unmap_sg,
-	.sync_single_for_cpu    = __dummy_sync_single,
-	.sync_single_for_device = __dummy_sync_single,
-	.sync_sg_for_cpu        = __dummy_sync_sg,
-	.sync_sg_for_device     = __dummy_sync_sg,
-	.dma_supported          = __dummy_dma_supported,
-};
-EXPORT_SYMBOL(dummy_dma_ops);
-
 static int __init arm64_dma_init(void)
 {
 	WARN_TAINT(ARCH_DMA_MINALIGN < cache_line_size(),
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 0f0078490df4..269ee27fc3d9 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -136,6 +136,7 @@ struct dma_map_ops {
 
 extern const struct dma_map_ops dma_direct_ops;
 extern const struct dma_map_ops dma_virt_ops;
+extern const struct dma_map_ops dma_dummy_ops;
 
 #define DMA_BIT_MASK(n)	(((n) = 64) ? ~0ULL : ((1ULL<<(n))-1))
 
diff --git a/kernel/dma/Makefile b/kernel/dma/Makefile
index a626f643cd63..72ff6e46aa86 100644
--- a/kernel/dma/Makefile
+++ b/kernel/dma/Makefile
@@ -1,6 +1,6 @@
 # SPDX-License-Identifier: GPL-2.0
 
-obj-$(CONFIG_HAS_DMA)			+= mapping.o direct.o
+obj-$(CONFIG_HAS_DMA)			+= mapping.o direct.o dummy.o
 obj-$(CONFIG_DMA_CMA)			+= contiguous.o
 obj-$(CONFIG_HAVE_GENERIC_DMA_COHERENT) += coherent.o
 obj-$(CONFIG_DMA_VIRT_OPS)		+= virt.o
diff --git a/kernel/dma/dummy.c b/kernel/dma/dummy.c
new file mode 100644
index 000000000000..05607642c888
--- /dev/null
+++ b/kernel/dma/dummy.c
@@ -0,0 +1,39 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Dummy DMA ops that always fail.
+ */
+#include <linux/dma-mapping.h>
+
+static int dma_dummy_mmap(struct device *dev, struct vm_area_struct *vma,
+		void *cpu_addr, dma_addr_t dma_addr, size_t size,
+		unsigned long attrs)
+{
+	return -ENXIO;
+}
+
+static dma_addr_t dma_dummy_map_page(struct device *dev, struct page *page,
+		unsigned long offset, size_t size, enum dma_data_direction dir,
+		unsigned long attrs)
+{
+	return DMA_MAPPING_ERROR;
+}
+
+static int dma_dummy_map_sg(struct device *dev, struct scatterlist *sgl,
+		int nelems, enum dma_data_direction dir,
+		unsigned long attrs)
+{
+	return 0;
+}
+
+static int dma_dummy_supported(struct device *hwdev, u64 mask)
+{
+	return 0;
+}
+
+const struct dma_map_ops dma_dummy_ops = {
+	.mmap                   = dma_dummy_mmap,
+	.map_page               = dma_dummy_map_page,
+	.map_sg                 = dma_dummy_map_sg,
+	.dma_supported          = dma_dummy_supported,
+};
+EXPORT_SYMBOL(dma_dummy_ops);
-- 
2.19.1
