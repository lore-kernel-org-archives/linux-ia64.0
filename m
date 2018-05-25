From: Christoph Hellwig <hch@lst.de>
Date: Fri, 25 May 2018 14:35:12 +0000
Subject: [PATCH 7/7] x86: switch the VIA 32-bit DMA quirk to use the struct device flag
Message-Id: <20180525143512.1466-8-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180525143512.1466-1-hch@lst.de>
In-Reply-To: <20180525143512.1466-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: x86@kernel.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, netdev@vger.kernel.org

Instead of globally disabling > 32bit DMA using the arch_dma_supported
hook walk the PCI bus under the actually affected bridge and mark every
device with the dma_32bit_limit flag.  This also gets rid of the
arch_dma_supported hook entirely.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/x86/include/asm/dma-mapping.h |  3 ---
 arch/x86/kernel/pci-dma.c          | 27 ++++++++++-----------------
 include/linux/dma-mapping.h        | 11 -----------
 3 files changed, 10 insertions(+), 31 deletions(-)

diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
index 89ce4bfd241f..eb4e1352e403 100644
--- a/arch/x86/include/asm/dma-mapping.h
+++ b/arch/x86/include/asm/dma-mapping.h
@@ -30,9 +30,6 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return dma_ops;
 }
 
-int arch_dma_supported(struct device *dev, u64 mask);
-#define arch_dma_supported arch_dma_supported
-
 bool arch_dma_alloc_attrs(struct device **dev, gfp_t *gfp);
 #define arch_dma_alloc_attrs arch_dma_alloc_attrs
 
diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
index b5cbef974bd1..0d6fd0d1c14f 100644
--- a/arch/x86/kernel/pci-dma.c
+++ b/arch/x86/kernel/pci-dma.c
@@ -15,7 +15,7 @@
 #include <asm/x86_init.h>
 #include <asm/iommu_table.h>
 
-static int forbid_dac __read_mostly;
+static bool disable_dac_quirk __read_mostly;
 
 const struct dma_map_ops *dma_ops = &dma_direct_ops;
 EXPORT_SYMBOL(dma_ops);
@@ -129,7 +129,7 @@ static __init int iommu_setup(char *p)
 		if (!strncmp(p, "nodac", 5))
 			pr_warn("nodac option ignored.\n");
 		if (!strncmp(p, "usedac", 6)) {
-			forbid_dac = -1;
+			disable_dac_quirk = true;
 			return 1;
 		}
 #ifdef CONFIG_SWIOTLB
@@ -154,19 +154,6 @@ static __init int iommu_setup(char *p)
 }
 early_param("iommu", iommu_setup);
 
-int arch_dma_supported(struct device *dev, u64 mask)
-{
-#ifdef CONFIG_PCI
-	if (mask > 0xffffffff && forbid_dac > 0) {
-		dev_info(dev, "PCI: Disallowing DAC for device\n");
-		return 0;
-	}
-#endif
-
-	return 1;
-}
-EXPORT_SYMBOL(arch_dma_supported);
-
 static int __init pci_iommu_init(void)
 {
 	struct iommu_table_entry *p;
@@ -190,11 +177,17 @@ rootfs_initcall(pci_iommu_init);
 #ifdef CONFIG_PCI
 /* Many VIA bridges seem to corrupt data for DAC. Disable it here */
 
+static int via_no_dac_cb(struct pci_dev *pdev, void *data)
+{
+	pdev->dev.dma_32bit_limit = true;
+	return 0;
+}
+
 static void via_no_dac(struct pci_dev *dev)
 {
-	if (forbid_dac = 0) {
+	if (!disable_dac_quirk) {
 		dev_info(&dev->dev, "disabling DAC on VIA PCI bridge\n");
-		forbid_dac = 1;
+		pci_walk_bus(dev->subordinate, via_no_dac_cb, NULL);
 	}
 }
 DECLARE_PCI_FIXUP_CLASS_FINAL(PCI_VENDOR_ID_VIA, PCI_ANY_ID,
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index f8ab1c0f589e..0249bce7c5e7 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -572,14 +572,6 @@ static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 	return 0;
 }
 
-/*
- * This is a hack for the legacy x86 forbid_dac and iommu_sac_force. Please
- * don't use this in new code.
- */
-#ifndef arch_dma_supported
-#define arch_dma_supported(dev, mask)	(1)
-#endif
-
 static inline void dma_check_mask(struct device *dev, u64 mask)
 {
 	if (sme_active() && (mask < (((u64)sme_get_me_mask() << 1) - 1)))
@@ -592,9 +584,6 @@ static inline int dma_supported(struct device *dev, u64 mask)
 
 	if (!ops)
 		return 0;
-	if (!arch_dma_supported(dev, mask))
-		return 0;
-
 	if (!ops->dma_supported)
 		return 1;
 	return ops->dma_supported(dev, mask);
-- 
2.17.0

