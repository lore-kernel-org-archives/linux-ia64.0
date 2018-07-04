From: Robin Murphy <robin.murphy@arm.com>
Date: Wed, 04 Jul 2018 17:50:12 +0000
Subject: [RFC PATCH 2/2] dma-mapping: Clean up dma_get_required_mask() hooks
Message-Id: <08256121f325ceed7f6b88c1a5d3cf949698787d.1530726467.git.robin.murphy@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <55ac9550c311f056dcfeed9b2c8265375f17b155.1530726467.git.robin.murphy@arm.com>
In-Reply-To: <55ac9550c311f056dcfeed9b2c8265375f17b155.1530726467.git.robin.murphy@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hch@lst.de, m.szyprowski@samsung.com
Cc: iommu@lists.linux-foundation.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

As for the other mask-related hooks, standardise the arch override into
a Kconfig option, and also pull the generic implementation into the DMA
mapping code rather than having it hide away in the platform bus code.

Signed-off-by: Robin Murphy <robin.murphy@arm.com>
---
 arch/ia64/Kconfig                   |  1 +
 arch/ia64/include/asm/dma-mapping.h |  2 --
 arch/powerpc/Kconfig                |  1 +
 arch/powerpc/include/asm/device.h   |  2 --
 drivers/base/platform.c             | 23 -----------------------
 drivers/pci/controller/vmd.c        |  4 ++--
 include/linux/dma-mapping.h         |  2 +-
 kernel/dma/Kconfig                  |  3 +++
 kernel/dma/mapping.c                | 23 +++++++++++++++++++++++
 9 files changed, 31 insertions(+), 30 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index ff861420b8f5..a6274e79b155 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -12,6 +12,7 @@ menu "Processor type and features"
 
 config IA64
 	bool
+	select ARCH_HAS_DMA_GET_REQUIRED_MASK
 	select ARCH_MIGHT_HAVE_PC_PARPORT
 	select ARCH_MIGHT_HAVE_PC_SERIO
 	select PCI if (!IA64_HP_SIM)
diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
index 76e4d6632d68..522745ae67bb 100644
--- a/arch/ia64/include/asm/dma-mapping.h
+++ b/arch/ia64/include/asm/dma-mapping.h
@@ -10,8 +10,6 @@
 #include <linux/scatterlist.h>
 #include <linux/dma-debug.h>
 
-#define ARCH_HAS_DMA_GET_REQUIRED_MASK
-
 extern const struct dma_map_ops *dma_ops;
 extern struct ia64_machine_vector ia64_mv;
 extern void set_iommu_machvec(void);
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 08d85412d783..3581c576c762 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -126,6 +126,7 @@ config PPC
 	# Please keep this list sorted alphabetically.
 	#
 	select ARCH_HAS_DEVMEM_IS_ALLOWED
+	select ARCH_HAS_DMA_GET_REQUIRED_MASK
 	select ARCH_HAS_DMA_SET_MASK
 	select ARCH_HAS_DMA_SET_COHERENT_MASK
 	select ARCH_HAS_ELF_RANDOMIZE
diff --git a/arch/powerpc/include/asm/device.h b/arch/powerpc/include/asm/device.h
index 0245bfcaac32..17cceab5ccf9 100644
--- a/arch/powerpc/include/asm/device.h
+++ b/arch/powerpc/include/asm/device.h
@@ -54,6 +54,4 @@ struct pdev_archdata {
 	u64 dma_mask;
 };
 
-#define ARCH_HAS_DMA_GET_REQUIRED_MASK
-
 #endif /* _ASM_POWERPC_DEVICE_H */
diff --git a/drivers/base/platform.c b/drivers/base/platform.c
index dff82a3c2caa..dae427a77b0a 100644
--- a/drivers/base/platform.c
+++ b/drivers/base/platform.c
@@ -16,7 +16,6 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/dma-mapping.h>
-#include <linux/bootmem.h>
 #include <linux/err.h>
 #include <linux/slab.h>
 #include <linux/pm_runtime.h>
@@ -1179,28 +1178,6 @@ int __init platform_bus_init(void)
 	return error;
 }
 
-#ifndef ARCH_HAS_DMA_GET_REQUIRED_MASK
-u64 dma_get_required_mask(struct device *dev)
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
-EXPORT_SYMBOL_GPL(dma_get_required_mask);
-#endif
-
 static __initdata LIST_HEAD(early_platform_driver_list);
 static __initdata LIST_HEAD(early_platform_device_list);
 
diff --git a/drivers/pci/controller/vmd.c b/drivers/pci/controller/vmd.c
index 942b64fc7f1f..9dd721d36783 100644
--- a/drivers/pci/controller/vmd.c
+++ b/drivers/pci/controller/vmd.c
@@ -393,7 +393,7 @@ static int vmd_dma_supported(struct device *dev, u64 mask)
 	return vmd_dma_ops(dev)->dma_supported(to_vmd_dev(dev), mask);
 }
 
-#ifdef ARCH_HAS_DMA_GET_REQUIRED_MASK
+#ifdef CONFIG_ARCH_HAS_DMA_GET_REQUIRED_MASK
 static u64 vmd_get_required_mask(struct device *dev)
 {
 	return vmd_dma_ops(dev)->get_required_mask(to_vmd_dev(dev));
@@ -439,7 +439,7 @@ static void vmd_setup_dma_ops(struct vmd_dev *vmd)
 	ASSIGN_VMD_DMA_OPS(source, dest, sync_sg_for_device);
 	ASSIGN_VMD_DMA_OPS(source, dest, mapping_error);
 	ASSIGN_VMD_DMA_OPS(source, dest, dma_supported);
-#ifdef ARCH_HAS_DMA_GET_REQUIRED_MASK
+#ifdef CONFIG_ARCH_HAS_DMA_GET_REQUIRED_MASK
 	ASSIGN_VMD_DMA_OPS(source, dest, get_required_mask);
 #endif
 	add_dma_domain(domain);
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 30fe0c900420..788d7a609dd8 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -130,7 +130,7 @@ struct dma_map_ops {
 			enum dma_data_direction direction);
 	int (*mapping_error)(struct device *dev, dma_addr_t dma_addr);
 	int (*dma_supported)(struct device *dev, u64 mask);
-#ifdef ARCH_HAS_DMA_GET_REQUIRED_MASK
+#ifdef CONFIG_ARCH_HAS_DMA_GET_REQUIRED_MASK
 	u64 (*get_required_mask)(struct device *dev);
 #endif
 };
diff --git a/kernel/dma/Kconfig b/kernel/dma/Kconfig
index 01001371d892..cb12bb2d270a 100644
--- a/kernel/dma/Kconfig
+++ b/kernel/dma/Kconfig
@@ -16,6 +16,9 @@ config ARCH_DMA_ADDR_T_64BIT
 config HAVE_GENERIC_DMA_COHERENT
 	bool
 
+config ARCH_HAS_DMA_GET_REQUIRED_MASK
+        bool
+
 config ARCH_HAS_DMA_SET_MASK
         bool
 
diff --git a/kernel/dma/mapping.c b/kernel/dma/mapping.c
index d2a92ddaac4d..fdadc9524cb2 100644
--- a/kernel/dma/mapping.c
+++ b/kernel/dma/mapping.c
@@ -7,6 +7,7 @@
  */
 
 #include <linux/acpi.h>
+#include <linux/bootmem.h>
 #include <linux/dma-mapping.h>
 #include <linux/export.h>
 #include <linux/gfp.h>
@@ -198,6 +199,28 @@ EXPORT_SYMBOL(dmam_release_declared_memory);
 
 #endif
 
+#ifndef CONFIG_ARCH_HAS_DMA_GET_REQUIRED_MASK
+u64 dma_get_required_mask(struct device *dev)
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
+EXPORT_SYMBOL_GPL(dma_get_required_mask);
+#endif
+
 /*
  * Create scatter-list for the already allocated DMA buffer.
  */
-- 
2.17.1.dirty

