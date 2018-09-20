From: Christoph Hellwig <hch@lst.de>
Date: Thu, 20 Sep 2018 07:26:56 +0000
Subject: [PATCH 5/9] ia64: remove the unused pci_iommu_shutdown function
Message-Id: <20180920072700.22396-6-hch@lst.de>
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
 arch/ia64/kernel/pci-dma.c    | 5 -----
 2 files changed, 6 deletions(-)

diff --git a/arch/ia64/include/asm/iommu.h b/arch/ia64/include/asm/iommu.h
index 156b9d8e1932..5397e5aa3704 100644
--- a/arch/ia64/include/asm/iommu.h
+++ b/arch/ia64/include/asm/iommu.h
@@ -5,7 +5,6 @@
 /* 10 seconds */
 #define DMAR_OPERATION_TIMEOUT (((cycles_t) local_cpu_data->itc_freq)*10)
 
-extern void pci_iommu_shutdown(void);
 extern void no_iommu_init(void);
 #ifdef	CONFIG_INTEL_IOMMU
 extern int force_iommu, no_iommu;
diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
index 924966e5aa25..936af0ec7f8f 100644
--- a/arch/ia64/kernel/pci-dma.c
+++ b/arch/ia64/kernel/pci-dma.c
@@ -37,11 +37,6 @@ static int __init pci_iommu_init(void)
 /* Must execute after PCI subsystem */
 fs_initcall(pci_iommu_init);
 
-void pci_iommu_shutdown(void)
-{
-	return;
-}
-
 void __init
 iommu_dma_init(void)
 {
-- 
2.18.0
