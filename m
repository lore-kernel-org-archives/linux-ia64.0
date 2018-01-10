From: Christoph Hellwig <hch@lst.de>
Date: Wed, 10 Jan 2018 08:00:08 +0000
Subject: [PATCH 14/33] powerpc: rename dma_direct_ to dma_nommu_
Message-Id: <20180110080027.13879-15-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080027.13879-1-hch@lst.de>
In-Reply-To: <20180110080027.13879-1-hch-jcswGhMUV9g@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Konrad Rzeszutek Wilk <konrad-Gq0aWv8utHQdnm+yROfE0A@public.gmane.org>, linux-snps-arc-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org, patches-q3qR2WxjNRFS9aJRtSZj7A@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-cris-kernel-VrBV9hrLPhE@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org

We want to use the dma_direct_ namespace for a generic implementation,
so rename powerpc to the second best choice: dma_nommu_.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/include/asm/dma-mapping.h    |  8 ++--
 arch/powerpc/kernel/dma-iommu.c           |  2 +-
 arch/powerpc/kernel/dma-swiotlb.c         |  6 +--
 arch/powerpc/kernel/dma.c                 | 68 +++++++++++++++----------------
 arch/powerpc/kernel/pci-common.c          |  2 +-
 arch/powerpc/kernel/setup-common.c        |  2 +-
 arch/powerpc/platforms/cell/iommu.c       | 28 ++++++-------
 arch/powerpc/platforms/pasemi/iommu.c     |  2 +-
 arch/powerpc/platforms/pasemi/setup.c     |  2 +-
 arch/powerpc/platforms/powernv/pci-ioda.c |  4 +-
 arch/powerpc/platforms/pseries/iommu.c    |  2 +-
 arch/powerpc/platforms/pseries/vio.c      |  2 +-
 arch/powerpc/sysdev/dart_iommu.c          |  4 +-
 arch/powerpc/sysdev/fsl_pci.c             |  2 +-
 drivers/misc/cxl/vphb.c                   |  2 +-
 15 files changed, 68 insertions(+), 68 deletions(-)

diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index f6ab51205a85..8fa394520af6 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -19,13 +19,13 @@
 #include <asm/swiotlb.h>
 
 /* Some dma direct funcs must be visible for use in other dma_ops */
-extern void *__dma_direct_alloc_coherent(struct device *dev, size_t size,
+extern void *__dma_nommu_alloc_coherent(struct device *dev, size_t size,
 					 dma_addr_t *dma_handle, gfp_t flag,
 					 unsigned long attrs);
-extern void __dma_direct_free_coherent(struct device *dev, size_t size,
+extern void __dma_nommu_free_coherent(struct device *dev, size_t size,
 				       void *vaddr, dma_addr_t dma_handle,
 				       unsigned long attrs);
-extern int dma_direct_mmap_coherent(struct device *dev,
+extern int dma_nommu_mmap_coherent(struct device *dev,
 				    struct vm_area_struct *vma,
 				    void *cpu_addr, dma_addr_t handle,
 				    size_t size, unsigned long attrs);
@@ -73,7 +73,7 @@ static inline unsigned long device_to_mask(struct device *dev)
 #ifdef CONFIG_PPC64
 extern struct dma_map_ops dma_iommu_ops;
 #endif
-extern const struct dma_map_ops dma_direct_ops;
+extern const struct dma_map_ops dma_nommu_ops;
 
 static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 {
diff --git a/arch/powerpc/kernel/dma-iommu.c b/arch/powerpc/kernel/dma-iommu.c
index 66f33e7f8d40..f9fe2080ceb9 100644
--- a/arch/powerpc/kernel/dma-iommu.c
+++ b/arch/powerpc/kernel/dma-iommu.c
@@ -114,7 +114,7 @@ int dma_iommu_mapping_error(struct device *dev, dma_addr_t dma_addr)
 struct dma_map_ops dma_iommu_ops = {
 	.alloc			= dma_iommu_alloc_coherent,
 	.free			= dma_iommu_free_coherent,
-	.mmap			= dma_direct_mmap_coherent,
+	.mmap			= dma_nommu_mmap_coherent,
 	.map_sg			= dma_iommu_map_sg,
 	.unmap_sg		= dma_iommu_unmap_sg,
 	.dma_supported		= dma_iommu_dma_supported,
diff --git a/arch/powerpc/kernel/dma-swiotlb.c b/arch/powerpc/kernel/dma-swiotlb.c
index d0ea7860e02b..f1e99b9cee97 100644
--- a/arch/powerpc/kernel/dma-swiotlb.c
+++ b/arch/powerpc/kernel/dma-swiotlb.c
@@ -47,9 +47,9 @@ static u64 swiotlb_powerpc_get_required(struct device *dev)
  * for everything else.
  */
 const struct dma_map_ops swiotlb_dma_ops = {
-	.alloc = __dma_direct_alloc_coherent,
-	.free = __dma_direct_free_coherent,
-	.mmap = dma_direct_mmap_coherent,
+	.alloc = __dma_nommu_alloc_coherent,
+	.free = __dma_nommu_free_coherent,
+	.mmap = dma_nommu_mmap_coherent,
 	.map_sg = swiotlb_map_sg_attrs,
 	.unmap_sg = swiotlb_unmap_sg_attrs,
 	.dma_supported = swiotlb_dma_supported,
diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
index 4194bbbbdb10..6d5d04ccf3b4 100644
--- a/arch/powerpc/kernel/dma.c
+++ b/arch/powerpc/kernel/dma.c
@@ -40,7 +40,7 @@ static u64 __maybe_unused get_pfn_limit(struct device *dev)
 	return pfn;
 }
 
-static int dma_direct_dma_supported(struct device *dev, u64 mask)
+static int dma_nommu_dma_supported(struct device *dev, u64 mask)
 {
 #ifdef CONFIG_PPC64
 	u64 limit = get_dma_offset(dev) + (memblock_end_of_DRAM() - 1);
@@ -62,7 +62,7 @@ static int dma_direct_dma_supported(struct device *dev, u64 mask)
 #endif
 }
 
-void *__dma_direct_alloc_coherent(struct device *dev, size_t size,
+void *__dma_nommu_alloc_coherent(struct device *dev, size_t size,
 				  dma_addr_t *dma_handle, gfp_t flag,
 				  unsigned long attrs)
 {
@@ -119,7 +119,7 @@ void *__dma_direct_alloc_coherent(struct device *dev, size_t size,
 #endif
 }
 
-void __dma_direct_free_coherent(struct device *dev, size_t size,
+void __dma_nommu_free_coherent(struct device *dev, size_t size,
 				void *vaddr, dma_addr_t dma_handle,
 				unsigned long attrs)
 {
@@ -130,7 +130,7 @@ void __dma_direct_free_coherent(struct device *dev, size_t size,
 #endif
 }
 
-static void *dma_direct_alloc_coherent(struct device *dev, size_t size,
+static void *dma_nommu_alloc_coherent(struct device *dev, size_t size,
 				       dma_addr_t *dma_handle, gfp_t flag,
 				       unsigned long attrs)
 {
@@ -139,8 +139,8 @@ static void *dma_direct_alloc_coherent(struct device *dev, size_t size,
 	/* The coherent mask may be smaller than the real mask, check if
 	 * we can really use the direct ops
 	 */
-	if (dma_direct_dma_supported(dev, dev->coherent_dma_mask))
-		return __dma_direct_alloc_coherent(dev, size, dma_handle,
+	if (dma_nommu_dma_supported(dev, dev->coherent_dma_mask))
+		return __dma_nommu_alloc_coherent(dev, size, dma_handle,
 						   flag, attrs);
 
 	/* Ok we can't ... do we have an iommu ? If not, fail */
@@ -154,15 +154,15 @@ static void *dma_direct_alloc_coherent(struct device *dev, size_t size,
 				    dev_to_node(dev));
 }
 
-static void dma_direct_free_coherent(struct device *dev, size_t size,
+static void dma_nommu_free_coherent(struct device *dev, size_t size,
 				     void *vaddr, dma_addr_t dma_handle,
 				     unsigned long attrs)
 {
 	struct iommu_table *iommu;
 
-	/* See comments in dma_direct_alloc_coherent() */
-	if (dma_direct_dma_supported(dev, dev->coherent_dma_mask))
-		return __dma_direct_free_coherent(dev, size, vaddr, dma_handle,
+	/* See comments in dma_nommu_alloc_coherent() */
+	if (dma_nommu_dma_supported(dev, dev->coherent_dma_mask))
+		return __dma_nommu_free_coherent(dev, size, vaddr, dma_handle,
 						  attrs);
 	/* Maybe we used an iommu ... */
 	iommu = get_iommu_table_base(dev);
@@ -175,7 +175,7 @@ static void dma_direct_free_coherent(struct device *dev, size_t size,
 	iommu_free_coherent(iommu, size, vaddr, dma_handle);
 }
 
-int dma_direct_mmap_coherent(struct device *dev, struct vm_area_struct *vma,
+int dma_nommu_mmap_coherent(struct device *dev, struct vm_area_struct *vma,
 			     void *cpu_addr, dma_addr_t handle, size_t size,
 			     unsigned long attrs)
 {
@@ -193,7 +193,7 @@ int dma_direct_mmap_coherent(struct device *dev, struct vm_area_struct *vma,
 			       vma->vm_page_prot);
 }
 
-static int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl,
+static int dma_nommu_map_sg(struct device *dev, struct scatterlist *sgl,
 			     int nents, enum dma_data_direction direction,
 			     unsigned long attrs)
 {
@@ -213,13 +213,13 @@ static int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl,
 	return nents;
 }
 
-static void dma_direct_unmap_sg(struct device *dev, struct scatterlist *sg,
+static void dma_nommu_unmap_sg(struct device *dev, struct scatterlist *sg,
 				int nents, enum dma_data_direction direction,
 				unsigned long attrs)
 {
 }
 
-static u64 dma_direct_get_required_mask(struct device *dev)
+static u64 dma_nommu_get_required_mask(struct device *dev)
 {
 	u64 end, mask;
 
@@ -231,7 +231,7 @@ static u64 dma_direct_get_required_mask(struct device *dev)
 	return mask;
 }
 
-static inline dma_addr_t dma_direct_map_page(struct device *dev,
+static inline dma_addr_t dma_nommu_map_page(struct device *dev,
 					     struct page *page,
 					     unsigned long offset,
 					     size_t size,
@@ -246,7 +246,7 @@ static inline dma_addr_t dma_direct_map_page(struct device *dev,
 	return page_to_phys(page) + offset + get_dma_offset(dev);
 }
 
-static inline void dma_direct_unmap_page(struct device *dev,
+static inline void dma_nommu_unmap_page(struct device *dev,
 					 dma_addr_t dma_address,
 					 size_t size,
 					 enum dma_data_direction direction,
@@ -255,7 +255,7 @@ static inline void dma_direct_unmap_page(struct device *dev,
 }
 
 #ifdef CONFIG_NOT_COHERENT_CACHE
-static inline void dma_direct_sync_sg(struct device *dev,
+static inline void dma_nommu_sync_sg(struct device *dev,
 		struct scatterlist *sgl, int nents,
 		enum dma_data_direction direction)
 {
@@ -266,7 +266,7 @@ static inline void dma_direct_sync_sg(struct device *dev,
 		__dma_sync_page(sg_page(sg), sg->offset, sg->length, direction);
 }
 
-static inline void dma_direct_sync_single(struct device *dev,
+static inline void dma_nommu_sync_single(struct device *dev,
 					  dma_addr_t dma_handle, size_t size,
 					  enum dma_data_direction direction)
 {
@@ -274,24 +274,24 @@ static inline void dma_direct_sync_single(struct device *dev,
 }
 #endif
 
-const struct dma_map_ops dma_direct_ops = {
-	.alloc				= dma_direct_alloc_coherent,
-	.free				= dma_direct_free_coherent,
-	.mmap				= dma_direct_mmap_coherent,
-	.map_sg				= dma_direct_map_sg,
-	.unmap_sg			= dma_direct_unmap_sg,
-	.dma_supported			= dma_direct_dma_supported,
-	.map_page			= dma_direct_map_page,
-	.unmap_page			= dma_direct_unmap_page,
-	.get_required_mask		= dma_direct_get_required_mask,
+const struct dma_map_ops dma_nommu_ops = {
+	.alloc				= dma_nommu_alloc_coherent,
+	.free				= dma_nommu_free_coherent,
+	.mmap				= dma_nommu_mmap_coherent,
+	.map_sg				= dma_nommu_map_sg,
+	.unmap_sg			= dma_nommu_unmap_sg,
+	.dma_supported			= dma_nommu_dma_supported,
+	.map_page			= dma_nommu_map_page,
+	.unmap_page			= dma_nommu_unmap_page,
+	.get_required_mask		= dma_nommu_get_required_mask,
 #ifdef CONFIG_NOT_COHERENT_CACHE
-	.sync_single_for_cpu 		= dma_direct_sync_single,
-	.sync_single_for_device 	= dma_direct_sync_single,
-	.sync_sg_for_cpu 		= dma_direct_sync_sg,
-	.sync_sg_for_device 		= dma_direct_sync_sg,
+	.sync_single_for_cpu 		= dma_nommu_sync_single,
+	.sync_single_for_device 	= dma_nommu_sync_single,
+	.sync_sg_for_cpu 		= dma_nommu_sync_sg,
+	.sync_sg_for_device 		= dma_nommu_sync_sg,
 #endif
 };
-EXPORT_SYMBOL(dma_direct_ops);
+EXPORT_SYMBOL(dma_nommu_ops);
 
 int dma_set_coherent_mask(struct device *dev, u64 mask)
 {
@@ -302,7 +302,7 @@ int dma_set_coherent_mask(struct device *dev, u64 mask)
 		 * is no dma_op->set_coherent_mask() so we have to do
 		 * things the hard way:
 		 */
-		if (get_dma_ops(dev) != &dma_direct_ops ||
+		if (get_dma_ops(dev) != &dma_nommu_ops ||
 		    get_iommu_table_base(dev) = NULL ||
 		    !dma_iommu_dma_supported(dev, mask))
 			return -EIO;
diff --git a/arch/powerpc/kernel/pci-common.c b/arch/powerpc/kernel/pci-common.c
index 0ac7aa346c69..590f4d0a6cb1 100644
--- a/arch/powerpc/kernel/pci-common.c
+++ b/arch/powerpc/kernel/pci-common.c
@@ -60,7 +60,7 @@ resource_size_t isa_mem_base;
 EXPORT_SYMBOL(isa_mem_base);
 
 
-static const struct dma_map_ops *pci_dma_ops = &dma_direct_ops;
+static const struct dma_map_ops *pci_dma_ops = &dma_nommu_ops;
 
 void set_pci_dma_ops(const struct dma_map_ops *dma_ops)
 {
diff --git a/arch/powerpc/kernel/setup-common.c b/arch/powerpc/kernel/setup-common.c
index 9d213542a48b..9b89df1e71ab 100644
--- a/arch/powerpc/kernel/setup-common.c
+++ b/arch/powerpc/kernel/setup-common.c
@@ -791,7 +791,7 @@ void arch_setup_pdev_archdata(struct platform_device *pdev)
 {
 	pdev->archdata.dma_mask = DMA_BIT_MASK(32);
 	pdev->dev.dma_mask = &pdev->archdata.dma_mask;
- 	set_dma_ops(&pdev->dev, &dma_direct_ops);
+ 	set_dma_ops(&pdev->dev, &dma_nommu_ops);
 }
 
 static __init void print_system_info(void)
diff --git a/arch/powerpc/platforms/cell/iommu.c b/arch/powerpc/platforms/cell/iommu.c
index 4b91ad08eefd..12352a58072a 100644
--- a/arch/powerpc/platforms/cell/iommu.c
+++ b/arch/powerpc/platforms/cell/iommu.c
@@ -541,7 +541,7 @@ static struct cbe_iommu *cell_iommu_for_node(int nid)
 	return NULL;
 }
 
-static unsigned long cell_dma_direct_offset;
+static unsigned long cell_dma_nommu_offset;
 
 static unsigned long dma_iommu_fixed_base;
 
@@ -580,7 +580,7 @@ static void *dma_fixed_alloc_coherent(struct device *dev, size_t size,
 					    device_to_mask(dev), flag,
 					    dev_to_node(dev));
 	else
-		return dma_direct_ops.alloc(dev, size, dma_handle, flag,
+		return dma_nommu_ops.alloc(dev, size, dma_handle, flag,
 					    attrs);
 }
 
@@ -592,7 +592,7 @@ static void dma_fixed_free_coherent(struct device *dev, size_t size,
 		iommu_free_coherent(cell_get_iommu_table(dev), size, vaddr,
 				    dma_handle);
 	else
-		dma_direct_ops.free(dev, size, vaddr, dma_handle, attrs);
+		dma_nommu_ops.free(dev, size, vaddr, dma_handle, attrs);
 }
 
 static dma_addr_t dma_fixed_map_page(struct device *dev, struct page *page,
@@ -601,7 +601,7 @@ static dma_addr_t dma_fixed_map_page(struct device *dev, struct page *page,
 				     unsigned long attrs)
 {
 	if (iommu_fixed_is_weak = (attrs & DMA_ATTR_WEAK_ORDERING))
-		return dma_direct_ops.map_page(dev, page, offset, size,
+		return dma_nommu_ops.map_page(dev, page, offset, size,
 					       direction, attrs);
 	else
 		return iommu_map_page(dev, cell_get_iommu_table(dev), page,
@@ -614,7 +614,7 @@ static void dma_fixed_unmap_page(struct device *dev, dma_addr_t dma_addr,
 				 unsigned long attrs)
 {
 	if (iommu_fixed_is_weak = (attrs & DMA_ATTR_WEAK_ORDERING))
-		dma_direct_ops.unmap_page(dev, dma_addr, size, direction,
+		dma_nommu_ops.unmap_page(dev, dma_addr, size, direction,
 					  attrs);
 	else
 		iommu_unmap_page(cell_get_iommu_table(dev), dma_addr, size,
@@ -626,7 +626,7 @@ static int dma_fixed_map_sg(struct device *dev, struct scatterlist *sg,
 			   unsigned long attrs)
 {
 	if (iommu_fixed_is_weak = (attrs & DMA_ATTR_WEAK_ORDERING))
-		return dma_direct_ops.map_sg(dev, sg, nents, direction, attrs);
+		return dma_nommu_ops.map_sg(dev, sg, nents, direction, attrs);
 	else
 		return ppc_iommu_map_sg(dev, cell_get_iommu_table(dev), sg,
 					nents, device_to_mask(dev),
@@ -638,7 +638,7 @@ static void dma_fixed_unmap_sg(struct device *dev, struct scatterlist *sg,
 			       unsigned long attrs)
 {
 	if (iommu_fixed_is_weak = (attrs & DMA_ATTR_WEAK_ORDERING))
-		dma_direct_ops.unmap_sg(dev, sg, nents, direction, attrs);
+		dma_nommu_ops.unmap_sg(dev, sg, nents, direction, attrs);
 	else
 		ppc_iommu_unmap_sg(cell_get_iommu_table(dev), sg, nents,
 				   direction, attrs);
@@ -661,8 +661,8 @@ static void cell_dma_dev_setup(struct device *dev)
 {
 	if (get_pci_dma_ops() = &dma_iommu_ops)
 		set_iommu_table_base(dev, cell_get_iommu_table(dev));
-	else if (get_pci_dma_ops() = &dma_direct_ops)
-		set_dma_offset(dev, cell_dma_direct_offset);
+	else if (get_pci_dma_ops() = &dma_nommu_ops)
+		set_dma_offset(dev, cell_dma_nommu_offset);
 	else
 		BUG();
 }
@@ -810,14 +810,14 @@ static int __init cell_iommu_init_disabled(void)
 	unsigned long base = 0, size;
 
 	/* When no iommu is present, we use direct DMA ops */
-	set_pci_dma_ops(&dma_direct_ops);
+	set_pci_dma_ops(&dma_nommu_ops);
 
 	/* First make sure all IOC translation is turned off */
 	cell_disable_iommus();
 
 	/* If we have no Axon, we set up the spider DMA magic offset */
 	if (of_find_node_by_name(NULL, "axon") = NULL)
-		cell_dma_direct_offset = SPIDER_DMA_OFFSET;
+		cell_dma_nommu_offset = SPIDER_DMA_OFFSET;
 
 	/* Now we need to check to see where the memory is mapped
 	 * in PCI space. We assume that all busses use the same dma
@@ -851,13 +851,13 @@ static int __init cell_iommu_init_disabled(void)
 		return -ENODEV;
 	}
 
-	cell_dma_direct_offset += base;
+	cell_dma_nommu_offset += base;
 
-	if (cell_dma_direct_offset != 0)
+	if (cell_dma_nommu_offset != 0)
 		cell_pci_controller_ops.dma_dev_setup = cell_pci_dma_dev_setup;
 
 	printk("iommu: disabled, direct DMA offset is 0x%lx\n",
-	       cell_dma_direct_offset);
+	       cell_dma_nommu_offset);
 
 	return 0;
 }
diff --git a/arch/powerpc/platforms/pasemi/iommu.c b/arch/powerpc/platforms/pasemi/iommu.c
index 7fec04de27fc..78b80cbd9768 100644
--- a/arch/powerpc/platforms/pasemi/iommu.c
+++ b/arch/powerpc/platforms/pasemi/iommu.c
@@ -186,7 +186,7 @@ static void pci_dma_dev_setup_pasemi(struct pci_dev *dev)
 	 */
 	if (dev->vendor = 0x1959 && dev->device = 0xa007 &&
 	    !firmware_has_feature(FW_FEATURE_LPAR)) {
-		dev->dev.dma_ops = &dma_direct_ops;
+		dev->dev.dma_ops = &dma_nommu_ops;
 		/*
 		 * Set the coherent DMA mask to prevent the iommu
 		 * being used unnecessarily
diff --git a/arch/powerpc/platforms/pasemi/setup.c b/arch/powerpc/platforms/pasemi/setup.c
index c4a3e93dc324..d0b8ae53660d 100644
--- a/arch/powerpc/platforms/pasemi/setup.c
+++ b/arch/powerpc/platforms/pasemi/setup.c
@@ -363,7 +363,7 @@ static int pcmcia_notify(struct notifier_block *nb, unsigned long action,
 		return 0;
 
 	/* We use the direct ops for localbus */
-	dev->dma_ops = &dma_direct_ops;
+	dev->dma_ops = &dma_nommu_ops;
 
 	return 0;
 }
diff --git a/arch/powerpc/platforms/powernv/pci-ioda.c b/arch/powerpc/platforms/powernv/pci-ioda.c
index 749055553064..9582aeb1fe4c 100644
--- a/arch/powerpc/platforms/powernv/pci-ioda.c
+++ b/arch/powerpc/platforms/powernv/pci-ioda.c
@@ -1850,7 +1850,7 @@ static int pnv_pci_ioda_dma_set_mask(struct pci_dev *pdev, u64 dma_mask)
 
 	if (bypass) {
 		dev_info(&pdev->dev, "Using 64-bit DMA iommu bypass\n");
-		set_dma_ops(&pdev->dev, &dma_direct_ops);
+		set_dma_ops(&pdev->dev, &dma_nommu_ops);
 	} else {
 		/*
 		 * If the device can't set the TCE bypass bit but still wants
@@ -1868,7 +1868,7 @@ static int pnv_pci_ioda_dma_set_mask(struct pci_dev *pdev, u64 dma_mask)
 				return rc;
 			/* 4GB offset bypasses 32-bit space */
 			set_dma_offset(&pdev->dev, (1ULL << 32));
-			set_dma_ops(&pdev->dev, &dma_direct_ops);
+			set_dma_ops(&pdev->dev, &dma_nommu_ops);
 		} else if (dma_mask >> 32 && dma_mask != DMA_BIT_MASK(64)) {
 			/*
 			 * Fail the request if a DMA mask between 32 and 64 bits
diff --git a/arch/powerpc/platforms/pseries/iommu.c b/arch/powerpc/platforms/pseries/iommu.c
index 69921f72e2da..eaa11334fc8c 100644
--- a/arch/powerpc/platforms/pseries/iommu.c
+++ b/arch/powerpc/platforms/pseries/iommu.c
@@ -1231,7 +1231,7 @@ static int dma_set_mask_pSeriesLP(struct device *dev, u64 dma_mask)
 			if (dma_offset != 0) {
 				dev_info(dev, "Using 64-bit direct DMA at offset %llx\n", dma_offset);
 				set_dma_offset(dev, dma_offset);
-				set_dma_ops(dev, &dma_direct_ops);
+				set_dma_ops(dev, &dma_nommu_ops);
 				ddw_enabled = true;
 			}
 		}
diff --git a/arch/powerpc/platforms/pseries/vio.c b/arch/powerpc/platforms/pseries/vio.c
index d86938260a86..49e04ec19238 100644
--- a/arch/powerpc/platforms/pseries/vio.c
+++ b/arch/powerpc/platforms/pseries/vio.c
@@ -618,7 +618,7 @@ static u64 vio_dma_get_required_mask(struct device *dev)
 static const struct dma_map_ops vio_dma_mapping_ops = {
 	.alloc             = vio_dma_iommu_alloc_coherent,
 	.free              = vio_dma_iommu_free_coherent,
-	.mmap		   = dma_direct_mmap_coherent,
+	.mmap		   = dma_nommu_mmap_coherent,
 	.map_sg            = vio_dma_iommu_map_sg,
 	.unmap_sg          = vio_dma_iommu_unmap_sg,
 	.map_page          = vio_dma_iommu_map_page,
diff --git a/arch/powerpc/sysdev/dart_iommu.c b/arch/powerpc/sysdev/dart_iommu.c
index 3573d54b2770..a6198d4f0f03 100644
--- a/arch/powerpc/sysdev/dart_iommu.c
+++ b/arch/powerpc/sysdev/dart_iommu.c
@@ -402,7 +402,7 @@ static int dart_dma_set_mask(struct device *dev, u64 dma_mask)
 	 */
 	if (dart_device_on_pcie(dev) && dma_mask >= DMA_BIT_MASK(40)) {
 		dev_info(dev, "Using 64-bit DMA iommu bypass\n");
-		set_dma_ops(dev, &dma_direct_ops);
+		set_dma_ops(dev, &dma_nommu_ops);
 	} else {
 		dev_info(dev, "Using 32-bit DMA via iommu\n");
 		set_dma_ops(dev, &dma_iommu_ops);
@@ -446,7 +446,7 @@ void __init iommu_init_early_dart(struct pci_controller_ops *controller_ops)
 	controller_ops->dma_bus_setup = NULL;
 
 	/* Setup pci_dma ops */
-	set_pci_dma_ops(&dma_direct_ops);
+	set_pci_dma_ops(&dma_nommu_ops);
 }
 
 #ifdef CONFIG_PM
diff --git a/arch/powerpc/sysdev/fsl_pci.c b/arch/powerpc/sysdev/fsl_pci.c
index 22d98057f773..e4d0133bbeeb 100644
--- a/arch/powerpc/sysdev/fsl_pci.c
+++ b/arch/powerpc/sysdev/fsl_pci.c
@@ -135,7 +135,7 @@ static int fsl_pci_dma_set_mask(struct device *dev, u64 dma_mask)
 	 * mapping that allows addressing any RAM address from across PCI.
 	 */
 	if (dev_is_pci(dev) && dma_mask >= pci64_dma_offset * 2 - 1) {
-		set_dma_ops(dev, &dma_direct_ops);
+		set_dma_ops(dev, &dma_nommu_ops);
 		set_dma_offset(dev, pci64_dma_offset);
 	}
 
diff --git a/drivers/misc/cxl/vphb.c b/drivers/misc/cxl/vphb.c
index 512a4897dbf6..7fd0bdc1436a 100644
--- a/drivers/misc/cxl/vphb.c
+++ b/drivers/misc/cxl/vphb.c
@@ -54,7 +54,7 @@ static bool cxl_pci_enable_device_hook(struct pci_dev *dev)
 		return false;
 	}
 
-	set_dma_ops(&dev->dev, &dma_direct_ops);
+	set_dma_ops(&dev->dev, &dma_nommu_ops);
 	set_dma_offset(&dev->dev, PAGE_OFFSET);
 
 	return _cxl_pci_associate_default_context(dev, afu);
-- 
2.14.2

