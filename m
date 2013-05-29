From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 29 May 2013 21:55:02 +0000
Subject: [PATCH] ia64/PCI: Remove unused fallback_dev
Message-Id: <20130529215502.4977.2759.stgit@bhelgaas-glaptop>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>
Cc: linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org

There are no users of fallback_dev, so remove it.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 arch/ia64/kernel/pci-dma.c |    9 ---------
 1 file changed, 9 deletions(-)

diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
index 1ddcfe5..992c109 100644
--- a/arch/ia64/kernel/pci-dma.c
+++ b/arch/ia64/kernel/pci-dma.c
@@ -33,15 +33,6 @@ int force_iommu __read_mostly;
 
 int iommu_pass_through;
 
-/* Dummy device used for NULL arguments (normally ISA). Better would
-   be probably a smaller DMA mask, but this is bug-to-bug compatible
-   to i386. */
-struct device fallback_dev = {
-	.init_name = "fallback device",
-	.coherent_dma_mask = DMA_BIT_MASK(32),
-	.dma_mask = &fallback_dev.coherent_dma_mask,
-};
-
 extern struct dma_map_ops intel_dma_ops;
 
 static int __init pci_iommu_init(void)

