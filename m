From: Zhen Lei <thunder.leizhen@huawei.com>
Date: Sun, 07 Apr 2019 12:41:45 +0000
Subject: [PATCH v4 4/6] s390/pci: use common boot option iommu.dma_mode
Message-Id: <20190407124147.13576-5-thunder.leizhen@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190407124147.13576-1-thunder.leizhen@huawei.com>
In-Reply-To: <20190407124147.13576-1-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, John Garry <john.garry@huawei.com>, Robin Murphy <robin.murphy@arm.com>, Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Jonathan Corbet <corbet@lwn.net>, linux-doc <linux-doc@vger.kernel.org>, Sebastian Ott <sebott@linux.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>, David Woodhouse <dwmw2@infradead.org>, iommu <iommu@lists.linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, x86 <x86@kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>
Cc: Zhen Lei <thunder.leizhen@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

s390_iommu=strict can be replaced with iommu.dma_mode=strict.

Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
---
 Documentation/admin-guide/kernel-parameters.txt |  7 -------
 arch/s390/pci/pci_dma.c                         | 20 +++++---------------
 drivers/iommu/Kconfig                           |  1 +
 3 files changed, 6 insertions(+), 22 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 60409ad23b2ac8b..a2df11945b33fc9 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -4095,13 +4095,6 @@
 
 	S		[KNL] Run init in single mode
 
-	s390_iommu=	[HW,S390]
-			Set s390 IOTLB flushing mode
-		strict
-			With strict flushing every unmap operation will result in
-			an IOTLB flush. Default is lazy flushing before reuse,
-			which is faster.
-
 	sa1100ir	[NET]
 			See drivers/net/irda/sa1100_ir.c.
 
diff --git a/arch/s390/pci/pci_dma.c b/arch/s390/pci/pci_dma.c
index 9e52d1527f71495..6f1615c16f33995 100644
--- a/arch/s390/pci/pci_dma.c
+++ b/arch/s390/pci/pci_dma.c
@@ -17,7 +17,6 @@
 
 static struct kmem_cache *dma_region_table_cache;
 static struct kmem_cache *dma_page_table_cache;
-static int s390_iommu_strict;
 
 static int zpci_refresh_global(struct zpci_dev *zdev)
 {
@@ -193,13 +192,13 @@ static int __dma_purge_tlb(struct zpci_dev *zdev, dma_addr_t dma_addr,
 		if (!zdev->tlb_refresh)
 			return 0;
 	} else {
-		if (!s390_iommu_strict)
+		if (IOMMU_DMA_MODE_IS_LAZY())
 			return 0;
 	}
 
 	ret = zpci_refresh_trans((u64) zdev->fh << 32, dma_addr,
 				 PAGE_ALIGN(size));
-	if (ret = -ENOMEM && !s390_iommu_strict) {
+	if (ret = -ENOMEM && IOMMU_DMA_MODE_IS_LAZY()) {
 		/* enable the hypervisor to free some resources */
 		if (zpci_refresh_global(zdev))
 			goto out;
@@ -278,7 +277,7 @@ static dma_addr_t dma_alloc_address(struct device *dev, int size)
 	spin_lock_irqsave(&zdev->iommu_bitmap_lock, flags);
 	offset = __dma_alloc_iommu(dev, zdev->next_bit, size);
 	if (offset = -1) {
-		if (!s390_iommu_strict) {
+		if (IOMMU_DMA_MODE_IS_LAZY()) {
 			/* global flush before DMA addresses are reused */
 			if (zpci_refresh_global(zdev))
 				goto out_error;
@@ -313,7 +312,7 @@ static void dma_free_address(struct device *dev, dma_addr_t dma_addr, int size)
 	if (!zdev->iommu_bitmap)
 		goto out;
 
-	if (s390_iommu_strict)
+	if (!IOMMU_DMA_MODE_IS_LAZY())
 		bitmap_clear(zdev->iommu_bitmap, offset, size);
 	else
 		bitmap_set(zdev->lazy_bitmap, offset, size);
@@ -584,7 +583,7 @@ int zpci_dma_init_device(struct zpci_dev *zdev)
 		rc = -ENOMEM;
 		goto free_dma_table;
 	}
-	if (!s390_iommu_strict) {
+	if (IOMMU_DMA_MODE_IS_LAZY()) {
 		zdev->lazy_bitmap = vzalloc(zdev->iommu_pages / 8);
 		if (!zdev->lazy_bitmap) {
 			rc = -ENOMEM;
@@ -671,12 +670,3 @@ void zpci_dma_exit(void)
 	/* dma_supported is unconditionally true without a callback */
 };
 EXPORT_SYMBOL_GPL(s390_pci_dma_ops);
-
-static int __init s390_iommu_setup(char *str)
-{
-	if (!strncmp(str, "strict", 6))
-		s390_iommu_strict = 1;
-	return 0;
-}
-
-__setup("s390_iommu=", s390_iommu_setup);
diff --git a/drivers/iommu/Kconfig b/drivers/iommu/Kconfig
index 19118cfdea1c335..d88dc44d60d88ea 100644
--- a/drivers/iommu/Kconfig
+++ b/drivers/iommu/Kconfig
@@ -77,6 +77,7 @@ config IOMMU_DEBUGFS
 choice
 	prompt "IOMMU dma mode"
 	depends on IOMMU_API
+	default IOMMU_DMA_MODE_LAZY if S390_IOMMU
 	default IOMMU_DMA_MODE_STRICT
 	help
 	  IOMMU dma mode, such as: passthrough, lazy, strict.
-- 
1.8.3

