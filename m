From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 30 Aug 2005 17:58:03 +0000
Subject: [patch 2.6.13] swiotlb: add swiotlb_sync_single_range_for_{cpu,device}
Message-Id: <20050830175803.GC18998@tuxdriver.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050829200916.GI3716@tuxdriver.com> <200508292254.53476.ak@suse.de> <20050829214828.GA6314@tuxdriver.com> <200508300314.35177.ak@suse.de> <20050830175436.GB18998@tuxdriver.com>
In-Reply-To: <20050830175436.GB18998@tuxdriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Andi Kleen <ak@suse.de>, discuss@x86-64.org, tony.luck@intel.com, linux-ia64@vger.kernel.org

Add swiotlb_sync_single_range_for_{cpu,device} implementations.  This is
used to support implementation of dma_sync_single_range_for_{cpu,device}
on x86_64.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 arch/ia64/lib/swiotlb.c      |   33 +++++++++++++++++++++++++++++++++
 include/asm-x86_64/swiotlb.h |    8 ++++++++
 2 files changed, 41 insertions(+)

diff --git a/arch/ia64/lib/swiotlb.c b/arch/ia64/lib/swiotlb.c
--- a/arch/ia64/lib/swiotlb.c
+++ b/arch/ia64/lib/swiotlb.c
@@ -522,6 +522,37 @@ swiotlb_sync_single_for_device(struct de
 }
 
 /*
+ * Same as above, but for a sub-range of the mapping.
+ */
+void
+swiotlb_sync_single_range_for_cpu(struct device *hwdev, dma_addr_t dev_addr,
+				  unsigned long offset, size_t size, int dir)
+{
+	char *dma_addr = phys_to_virt(dev_addr) + offset;
+
+	if (dir = DMA_NONE)
+		BUG();
+	if (dma_addr >= io_tlb_start && dma_addr < io_tlb_end)
+		sync_single(hwdev, dma_addr, size, dir);
+	else if (dir = DMA_FROM_DEVICE)
+		mark_clean(dma_addr, size);
+}
+
+void
+swiotlb_sync_single_range_for_device(struct device *hwdev, dma_addr_t dev_addr,
+				     unsigned long offset, size_t size, int dir)
+{
+	char *dma_addr = phys_to_virt(dev_addr) + offset;
+
+	if (dir = DMA_NONE)
+		BUG();
+	if (dma_addr >= io_tlb_start && dma_addr < io_tlb_end)
+		sync_single(hwdev, dma_addr, size, dir);
+	else if (dir = DMA_FROM_DEVICE)
+		mark_clean(dma_addr, size);
+}
+
+/*
  * Map a set of buffers described by scatterlist in streaming mode for DMA.
  * This is the scatter-gather version of the above swiotlb_map_single
  * interface.  Here the scatter gather list elements are each tagged with the
@@ -650,6 +681,8 @@ EXPORT_SYMBOL(swiotlb_map_sg);
 EXPORT_SYMBOL(swiotlb_unmap_sg);
 EXPORT_SYMBOL(swiotlb_sync_single_for_cpu);
 EXPORT_SYMBOL(swiotlb_sync_single_for_device);
+EXPORT_SYMBOL_GPL(swiotlb_sync_single_range_for_cpu);
+EXPORT_SYMBOL_GPL(swiotlb_sync_single_range_for_device);
 EXPORT_SYMBOL(swiotlb_sync_sg_for_cpu);
 EXPORT_SYMBOL(swiotlb_sync_sg_for_device);
 EXPORT_SYMBOL(swiotlb_dma_mapping_error);
diff --git a/include/asm-x86_64/swiotlb.h b/include/asm-x86_64/swiotlb.h
--- a/include/asm-x86_64/swiotlb.h
+++ b/include/asm-x86_64/swiotlb.h
@@ -15,6 +15,14 @@ extern void swiotlb_sync_single_for_cpu(
 extern void swiotlb_sync_single_for_device(struct device *hwdev,
 					    dma_addr_t dev_addr,
 					    size_t size, int dir);
+extern void swiotlb_sync_single_range_for_cpu(struct device *hwdev,
+					      dma_addr_t dev_addr,
+					      unsigned long offset,
+					      size_t size, int dir);
+extern void swiotlb_sync_single_range_for_device(struct device *hwdev,
+						 dma_addr_t dev_addr,
+						 unsigned long offset,
+						 size_t size, int dir);
 extern void swiotlb_sync_sg_for_cpu(struct device *hwdev,
 				     struct scatterlist *sg, int nelems,
 				     int dir);
-- 
John W. Linville
linville@tuxdriver.com
