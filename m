From: Christoph Hellwig <hch@lst.de>
Date: Wed, 01 Aug 2018 16:02:45 +0000
Subject: [PATCH 2/9] ia64: remove the dead iommu_sac_force variable
Message-Id: <20180801160252.25629-3-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180801160252.25629-1-hch@lst.de>
In-Reply-To: <20180801160252.25629-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org

Looks like copy and paste from x86 that never actually got used.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/kernel/pci-dma.c | 19 -------------------
 1 file changed, 19 deletions(-)

diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
index b5df084c0af4..50b6ad282a90 100644
--- a/arch/ia64/kernel/pci-dma.c
+++ b/arch/ia64/kernel/pci-dma.c
@@ -18,8 +18,6 @@
 dma_addr_t bad_dma_address __read_mostly;
 EXPORT_SYMBOL(bad_dma_address);
 
-static int iommu_sac_force __read_mostly;
-
 int no_iommu __read_mostly;
 #ifdef CONFIG_IOMMU_DEBUG
 int force_iommu __read_mostly = 1;
@@ -61,23 +59,6 @@ int iommu_dma_supported(struct device *dev, u64 mask)
 	if (mask < DMA_BIT_MASK(24))
 		return 0;
 
-	/* Tell the device to use SAC when IOMMU force is on.  This
-	   allows the driver to use cheaper accesses in some cases.
-
-	   Problem with this is that if we overflow the IOMMU area and
-	   return DAC as fallback address the device may not handle it
-	   correctly.
-
-	   As a special case some controllers have a 39bit address
-	   mode that is as efficient as 32bit (aic79xx). Don't force
-	   SAC for these.  Assume all masks <= 40 bits are of this
-	   type. Normally this doesn't make any difference, but gives
-	   more gentle handling of IOMMU overflow. */
-	if (iommu_sac_force && (mask >= DMA_BIT_MASK(40))) {
-		dev_info(dev, "Force SAC with mask %llx\n", mask);
-		return 0;
-	}
-
 	return 1;
 }
 EXPORT_SYMBOL(iommu_dma_supported);
-- 
2.18.0

