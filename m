From: Christoph Hellwig <hch@lst.de>
Date: Wed, 10 Jan 2018 08:09:24 +0000
Subject: [PATCH 14/22] ia64: clean up swiotlb support
Message-Id: <20180110080932.14157-15-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080932.14157-1-hch@lst.de>
In-Reply-To: <20180110080932.14157-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>, Michal Simek <monstr@monstr.eu>, Guan Xuetao <gxt@mprc.pku.edu.cn>, =?UTF-8?q?Christian=20K=C3=B6nig?= <ckoenig.leichtzumerken@gmail.com>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Move the few remaining bits of swiotlb glue towards their callers,
and remove the pointless on ia64 swiotlb variable.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/include/asm/dma-mapping.h |  1 -
 arch/ia64/include/asm/swiotlb.h     | 18 ------------------
 arch/ia64/kernel/dma-mapping.c      |  9 +++++++++
 arch/ia64/kernel/pci-dma.c          | 12 ++++++++++--
 arch/ia64/kernel/pci-swiotlb.c      | 36 ------------------------------------
 drivers/iommu/intel-iommu.c         |  2 +-
 6 files changed, 20 insertions(+), 58 deletions(-)
 delete mode 100644 arch/ia64/include/asm/swiotlb.h
 delete mode 100644 arch/ia64/kernel/pci-swiotlb.c

diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
index eabee56d995c..76e4d6632d68 100644
--- a/arch/ia64/include/asm/dma-mapping.h
+++ b/arch/ia64/include/asm/dma-mapping.h
@@ -8,7 +8,6 @@
  */
 #include <asm/machvec.h>
 #include <linux/scatterlist.h>
-#include <asm/swiotlb.h>
 #include <linux/dma-debug.h>
 
 #define ARCH_HAS_DMA_GET_REQUIRED_MASK
diff --git a/arch/ia64/include/asm/swiotlb.h b/arch/ia64/include/asm/swiotlb.h
deleted file mode 100644
index 841e2c7d0b21..000000000000
--- a/arch/ia64/include/asm/swiotlb.h
+++ /dev/null
@@ -1,18 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 */
-#ifndef ASM_IA64__SWIOTLB_H
-#define ASM_IA64__SWIOTLB_H
-
-#include <linux/dma-mapping.h>
-#include <linux/swiotlb.h>
-
-#ifdef CONFIG_SWIOTLB
-extern int swiotlb;
-extern void pci_swiotlb_init(void);
-#else
-#define swiotlb 0
-static inline void pci_swiotlb_init(void)
-{
-}
-#endif
-
-#endif /* ASM_IA64__SWIOTLB_H */
diff --git a/arch/ia64/kernel/dma-mapping.c b/arch/ia64/kernel/dma-mapping.c
index 7a82c9259609..f2d57e66fd86 100644
--- a/arch/ia64/kernel/dma-mapping.c
+++ b/arch/ia64/kernel/dma-mapping.c
@@ -1,5 +1,6 @@
 // SPDX-License-Identifier: GPL-2.0
 #include <linux/dma-mapping.h>
+#include <linux/swiotlb.h>
 #include <linux/export.h>
 
 /* Set this to 1 if there is a HW IOMMU in the system */
@@ -23,3 +24,11 @@ const struct dma_map_ops *dma_get_ops(struct device *dev)
 	return dma_ops;
 }
 EXPORT_SYMBOL(dma_get_ops);
+
+#ifdef CONFIG_SWIOTLB
+void __init swiotlb_dma_init(void)
+{
+	dma_ops = &swiotlb_dma_ops;
+	swiotlb_init(1);
+}
+#endif
diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
index 3ba87c22dfbc..35e0cad33b7d 100644
--- a/arch/ia64/kernel/pci-dma.c
+++ b/arch/ia64/kernel/pci-dma.c
@@ -104,8 +104,16 @@ void __init pci_iommu_alloc(void)
 	detect_intel_iommu();
 
 #ifdef CONFIG_SWIOTLB
-	pci_swiotlb_init();
-#endif
+	if (!iommu_detected) {
+#ifdef CONFIG_IA64_GENERIC
+		printk(KERN_INFO "PCI-DMA: Re-initialize machine vector.\n");
+		machvec_init("dig");
+		swiotlb_dma_init();
+#else
+		panic("Unable to find Intel IOMMU");
+#endif /* CONFIG_IA64_GENERIC */
+	}
+#endif /* CONFIG_SWIOTLB */
 }
 
 #endif
diff --git a/arch/ia64/kernel/pci-swiotlb.c b/arch/ia64/kernel/pci-swiotlb.c
deleted file mode 100644
index 0f8d5fbd86bd..000000000000
--- a/arch/ia64/kernel/pci-swiotlb.c
+++ /dev/null
@@ -1,36 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/* Glue code to lib/swiotlb.c */
-
-#include <linux/pci.h>
-#include <linux/gfp.h>
-#include <linux/cache.h>
-#include <linux/module.h>
-#include <linux/dma-mapping.h>
-#include <linux/swiotlb.h>
-#include <asm/dma.h>
-#include <asm/iommu.h>
-#include <asm/machvec.h>
-
-int swiotlb __read_mostly;
-EXPORT_SYMBOL(swiotlb);
-
-void __init swiotlb_dma_init(void)
-{
-	dma_ops = &swiotlb_dma_ops;
-	swiotlb_init(1);
-}
-
-void __init pci_swiotlb_init(void)
-{
-	if (!iommu_detected) {
-#ifdef CONFIG_IA64_GENERIC
-		swiotlb = 1;
-		printk(KERN_INFO "PCI-DMA: Re-initialize machine vector.\n");
-		machvec_init("dig");
-		swiotlb_init(1);
-		dma_ops = &swiotlb_dma_ops;
-#else
-		panic("Unable to find Intel IOMMU");
-#endif
-	}
-}
diff --git a/drivers/iommu/intel-iommu.c b/drivers/iommu/intel-iommu.c
index 4a2de34895ec..a1373cf34326 100644
--- a/drivers/iommu/intel-iommu.c
+++ b/drivers/iommu/intel-iommu.c
@@ -4808,7 +4808,7 @@ int __init intel_iommu_init(void)
 	up_write(&dmar_global_lock);
 	pr_info("Intel(R) Virtualization Technology for Directed I/O\n");
 
-#ifdef CONFIG_SWIOTLB
+#if defined(CONFIG_X86) && defined(CONFIG_SWIOTLB)
 	swiotlb = 0;
 #endif
 	dma_ops = &intel_dma_ops;
-- 
2.14.2

