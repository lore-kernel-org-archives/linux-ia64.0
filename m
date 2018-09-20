From: Christoph Hellwig <hch@lst.de>
Date: Thu, 20 Sep 2018 07:26:57 +0000
Subject: [PATCH 6/9] ia64: remove the unused iommu_dma_init function
Message-Id: <20180920072700.22396-7-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180920072700.22396-1-hch@lst.de>
In-Reply-To: <20180920072700.22396-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/include/asm/iommu.h | 1 -
 arch/ia64/kernel/pci-dma.c    | 6 ------
 2 files changed, 7 deletions(-)

diff --git a/arch/ia64/include/asm/iommu.h b/arch/ia64/include/asm/iommu.h
index 5397e5aa3704..7429a72f3f92 100644
--- a/arch/ia64/include/asm/iommu.h
+++ b/arch/ia64/include/asm/iommu.h
@@ -15,7 +15,6 @@ extern int iommu_detected;
 #define no_iommu		(1)
 #define iommu_detected		(0)
 #endif
-extern void iommu_dma_init(void);
 extern void machvec_init(const char *name);
 
 #endif
diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
index 936af0ec7f8f..afb43677f9ca 100644
--- a/arch/ia64/kernel/pci-dma.c
+++ b/arch/ia64/kernel/pci-dma.c
@@ -37,12 +37,6 @@ static int __init pci_iommu_init(void)
 /* Must execute after PCI subsystem */
 fs_initcall(pci_iommu_init);
 
-void __init
-iommu_dma_init(void)
-{
-	return;
-}
-
 void __init pci_iommu_alloc(void)
 {
 	dma_ops = &intel_dma_ops;
-- 
2.18.0
