From: Christoph Hellwig <hch@lst.de>
Date: Tue, 31 Jul 2018 17:20:31 +0000
Subject: [PATCH] ia64: fix barrier placement for write* / dma mapping
Message-Id: <20180731172031.4447-2-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180731172031.4447-1-hch@lst.de>
In-Reply-To: <20180731172031.4447-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Sinan Kaya <okaya@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org

memory-barriers.txt has been updated with the following requirement.

"When using writel(), a prior wmb() is not needed to guarantee that the
cache coherent memory writes have completed before writing to the MMIO
region."

The current writeX() and iowriteX() implementations on ia64 are not
satisfying this requirement as the barrier is after the register write.

This adds the missing memory barriers, and instead drops them from the
dma sync routine where they are misplaced (and were missing in the
more important map/unmap cases anyway).

All this doesn't affect the SN2 platform, which already has barrier
in the I/O accessors, and none in dma mapping (but then again
swiotlb doesn't have any either).

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/hp/common/sba_iommu.c     |  4 ----
 arch/ia64/include/asm/dma-mapping.h |  5 -----
 arch/ia64/include/asm/io.h          |  5 +++++
 arch/ia64/kernel/machvec.c          | 16 ----------------
 arch/ia64/kernel/pci-dma.c          |  5 -----
 5 files changed, 5 insertions(+), 30 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index ee5b652d320a..e8da6503ed2f 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -2207,10 +2207,6 @@ const struct dma_map_ops sba_dma_ops = {
 	.unmap_page		= sba_unmap_page,
 	.map_sg			= sba_map_sg_attrs,
 	.unmap_sg		= sba_unmap_sg_attrs,
-	.sync_single_for_cpu	= machvec_dma_sync_single,
-	.sync_sg_for_cpu	= machvec_dma_sync_sg,
-	.sync_single_for_device	= machvec_dma_sync_single,
-	.sync_sg_for_device	= machvec_dma_sync_sg,
 	.dma_supported		= sba_dma_supported,
 	.mapping_error		= sba_dma_mapping_error,
 };
diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
index 76e4d6632d68..2b8cd4a6d958 100644
--- a/arch/ia64/include/asm/dma-mapping.h
+++ b/arch/ia64/include/asm/dma-mapping.h
@@ -16,11 +16,6 @@ extern const struct dma_map_ops *dma_ops;
 extern struct ia64_machine_vector ia64_mv;
 extern void set_iommu_machvec(void);
 
-extern void machvec_dma_sync_single(struct device *, dma_addr_t, size_t,
-				    enum dma_data_direction);
-extern void machvec_dma_sync_sg(struct device *, struct scatterlist *, int,
-				enum dma_data_direction);
-
 static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 {
 	return platform_dma_get_ops(NULL);
diff --git a/arch/ia64/include/asm/io.h b/arch/ia64/include/asm/io.h
index fb0651961e2c..ba5523b67eaf 100644
--- a/arch/ia64/include/asm/io.h
+++ b/arch/ia64/include/asm/io.h
@@ -22,6 +22,7 @@
 
 #include <asm/unaligned.h>
 #include <asm/early_ioremap.h>
+#include <asm/barrier.h>
 
 /* We don't use IO slowdowns on the ia64, but.. */
 #define __SLOW_DOWN_IO	do { } while (0)
@@ -345,24 +346,28 @@ ___ia64_readq (const volatile void __iomem *addr)
 static inline void
 __writeb (unsigned char val, volatile void __iomem *addr)
 {
+	mb();
 	*(volatile unsigned char __force *) addr = val;
 }
 
 static inline void
 __writew (unsigned short val, volatile void __iomem *addr)
 {
+	mb();
 	*(volatile unsigned short __force *) addr = val;
 }
 
 static inline void
 __writel (unsigned int val, volatile void __iomem *addr)
 {
+	mb();
 	*(volatile unsigned int __force *) addr = val;
 }
 
 static inline void
 __writeq (unsigned long val, volatile void __iomem *addr)
 {
+	mb();
 	*(volatile unsigned long __force *) addr = val;
 }
 
diff --git a/arch/ia64/kernel/machvec.c b/arch/ia64/kernel/machvec.c
index 7bfe98859911..1b604d02250b 100644
--- a/arch/ia64/kernel/machvec.c
+++ b/arch/ia64/kernel/machvec.c
@@ -73,19 +73,3 @@ machvec_timer_interrupt (int irq, void *dev_id)
 {
 }
 EXPORT_SYMBOL(machvec_timer_interrupt);
-
-void
-machvec_dma_sync_single(struct device *hwdev, dma_addr_t dma_handle, size_t size,
-			enum dma_data_direction dir)
-{
-	mb();
-}
-EXPORT_SYMBOL(machvec_dma_sync_single);
-
-void
-machvec_dma_sync_sg(struct device *hwdev, struct scatterlist *sg, int n,
-		    enum dma_data_direction dir)
-{
-	mb();
-}
-EXPORT_SYMBOL(machvec_dma_sync_sg);
diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
index 3c2884bef3d4..2512aa3029f5 100644
--- a/arch/ia64/kernel/pci-dma.c
+++ b/arch/ia64/kernel/pci-dma.c
@@ -55,11 +55,6 @@ void __init pci_iommu_alloc(void)
 {
 	dma_ops = &intel_dma_ops;
 
-	intel_dma_ops.sync_single_for_cpu = machvec_dma_sync_single;
-	intel_dma_ops.sync_sg_for_cpu = machvec_dma_sync_sg;
-	intel_dma_ops.sync_single_for_device = machvec_dma_sync_single;
-	intel_dma_ops.sync_sg_for_device = machvec_dma_sync_sg;
-
 	/*
 	 * The order of these functions is important for
 	 * fall-back/fail-over reasons
-- 
2.18.0

