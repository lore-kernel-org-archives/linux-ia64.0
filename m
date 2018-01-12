From: Christoph Hellwig <hch@lst.de>
Date: Fri, 12 Jan 2018 08:42:14 +0000
Subject: [PATCH 16/34] microblaze: rename dma_direct to dma_nommu
Message-Id: <20180112084232.2857-17-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180112084232.2857-1-hch@lst.de>
In-Reply-To: <20180112084232.2857-1-hch-jcswGhMUV9g@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Konrad Rzeszutek Wilk <konrad-Gq0aWv8utHQdnm+yROfE0A@public.gmane.org>, linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-snps-arc-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, linux-cris-kernel-VrBV9hrLPhE@public.gmane.org, linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, patches-q3qR2WxjNRFS9aJRtSZj7A@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

This frees the dma_direct_* namespace for a generic implementation.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/microblaze/include/asm/dma-mapping.h |  4 +--
 arch/microblaze/kernel/dma.c              | 48 +++++++++++++++----------------
 2 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/arch/microblaze/include/asm/dma-mapping.h b/arch/microblaze/include/asm/dma-mapping.h
index 6b9ea39405b8..add50c1373bf 100644
--- a/arch/microblaze/include/asm/dma-mapping.h
+++ b/arch/microblaze/include/asm/dma-mapping.h
@@ -18,11 +18,11 @@
 /*
  * Available generic sets of operations
  */
-extern const struct dma_map_ops dma_direct_ops;
+extern const struct dma_map_ops dma_nommu_ops;
 
 static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 {
-	return &dma_direct_ops;
+	return &dma_nommu_ops;
 }
 
 #endif	/* _ASM_MICROBLAZE_DMA_MAPPING_H */
diff --git a/arch/microblaze/kernel/dma.c b/arch/microblaze/kernel/dma.c
index 990bf9ea0ec6..450803e5731a 100644
--- a/arch/microblaze/kernel/dma.c
+++ b/arch/microblaze/kernel/dma.c
@@ -17,7 +17,7 @@
 
 #define NOT_COHERENT_CACHE
 
-static void *dma_direct_alloc_coherent(struct device *dev, size_t size,
+static void *dma_nommu_alloc_coherent(struct device *dev, size_t size,
 				       dma_addr_t *dma_handle, gfp_t flag,
 				       unsigned long attrs)
 {
@@ -42,7 +42,7 @@ static void *dma_direct_alloc_coherent(struct device *dev, size_t size,
 #endif
 }
 
-static void dma_direct_free_coherent(struct device *dev, size_t size,
+static void dma_nommu_free_coherent(struct device *dev, size_t size,
 				     void *vaddr, dma_addr_t dma_handle,
 				     unsigned long attrs)
 {
@@ -69,7 +69,7 @@ static inline void __dma_sync(unsigned long paddr,
 	}
 }
 
-static int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl,
+static int dma_nommu_map_sg(struct device *dev, struct scatterlist *sgl,
 			     int nents, enum dma_data_direction direction,
 			     unsigned long attrs)
 {
@@ -89,12 +89,12 @@ static int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl,
 	return nents;
 }
 
-static int dma_direct_dma_supported(struct device *dev, u64 mask)
+static int dma_nommu_dma_supported(struct device *dev, u64 mask)
 {
 	return 1;
 }
 
-static inline dma_addr_t dma_direct_map_page(struct device *dev,
+static inline dma_addr_t dma_nommu_map_page(struct device *dev,
 					     struct page *page,
 					     unsigned long offset,
 					     size_t size,
@@ -106,7 +106,7 @@ static inline dma_addr_t dma_direct_map_page(struct device *dev,
 	return page_to_phys(page) + offset;
 }
 
-static inline void dma_direct_unmap_page(struct device *dev,
+static inline void dma_nommu_unmap_page(struct device *dev,
 					 dma_addr_t dma_address,
 					 size_t size,
 					 enum dma_data_direction direction,
@@ -122,7 +122,7 @@ static inline void dma_direct_unmap_page(struct device *dev,
 }
 
 static inline void
-dma_direct_sync_single_for_cpu(struct device *dev,
+dma_nommu_sync_single_for_cpu(struct device *dev,
 			       dma_addr_t dma_handle, size_t size,
 			       enum dma_data_direction direction)
 {
@@ -136,7 +136,7 @@ dma_direct_sync_single_for_cpu(struct device *dev,
 }
 
 static inline void
-dma_direct_sync_single_for_device(struct device *dev,
+dma_nommu_sync_single_for_device(struct device *dev,
 				  dma_addr_t dma_handle, size_t size,
 				  enum dma_data_direction direction)
 {
@@ -150,7 +150,7 @@ dma_direct_sync_single_for_device(struct device *dev,
 }
 
 static inline void
-dma_direct_sync_sg_for_cpu(struct device *dev,
+dma_nommu_sync_sg_for_cpu(struct device *dev,
 			   struct scatterlist *sgl, int nents,
 			   enum dma_data_direction direction)
 {
@@ -164,7 +164,7 @@ dma_direct_sync_sg_for_cpu(struct device *dev,
 }
 
 static inline void
-dma_direct_sync_sg_for_device(struct device *dev,
+dma_nommu_sync_sg_for_device(struct device *dev,
 			      struct scatterlist *sgl, int nents,
 			      enum dma_data_direction direction)
 {
@@ -178,7 +178,7 @@ dma_direct_sync_sg_for_device(struct device *dev,
 }
 
 static
-int dma_direct_mmap_coherent(struct device *dev, struct vm_area_struct *vma,
+int dma_nommu_mmap_coherent(struct device *dev, struct vm_area_struct *vma,
 			     void *cpu_addr, dma_addr_t handle, size_t size,
 			     unsigned long attrs)
 {
@@ -204,20 +204,20 @@ int dma_direct_mmap_coherent(struct device *dev, struct vm_area_struct *vma,
 #endif
 }
 
-const struct dma_map_ops dma_direct_ops = {
-	.alloc		= dma_direct_alloc_coherent,
-	.free		= dma_direct_free_coherent,
-	.mmap		= dma_direct_mmap_coherent,
-	.map_sg		= dma_direct_map_sg,
-	.dma_supported	= dma_direct_dma_supported,
-	.map_page	= dma_direct_map_page,
-	.unmap_page	= dma_direct_unmap_page,
-	.sync_single_for_cpu		= dma_direct_sync_single_for_cpu,
-	.sync_single_for_device		= dma_direct_sync_single_for_device,
-	.sync_sg_for_cpu		= dma_direct_sync_sg_for_cpu,
-	.sync_sg_for_device		= dma_direct_sync_sg_for_device,
+const struct dma_map_ops dma_nommu_ops = {
+	.alloc			= dma_nommu_alloc_coherent,
+	.free			= dma_nommu_free_coherent,
+	.mmap			= dma_nommu_mmap_coherent,
+	.map_sg			= dma_nommu_map_sg,
+	.dma_supported		= dma_nommu_dma_supported,
+	.map_page		= dma_nommu_map_page,
+	.unmap_page		= dma_nommu_unmap_page,
+	.sync_single_for_cpu	= dma_nommu_sync_single_for_cpu,
+	.sync_single_for_device	= dma_nommu_sync_single_for_device,
+	.sync_sg_for_cpu	= dma_nommu_sync_sg_for_cpu,
+	.sync_sg_for_device	= dma_nommu_sync_sg_for_device,
 };
-EXPORT_SYMBOL(dma_direct_ops);
+EXPORT_SYMBOL(dma_nommu_ops);
 
 /* Number of entries preallocated for DMA-API debugging */
 #define PREALLOC_DMA_DEBUG_ENTRIES (1 << 16)
-- 
2.14.2

