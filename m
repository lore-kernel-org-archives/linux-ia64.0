From: Christoph Hellwig <hch@lst.de>
Date: Fri, 25 May 2018 14:35:10 +0000
Subject: [PATCH 5/7] x86: remove the experimental forcesac boot option
Message-Id: <20180525143512.1466-6-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180525143512.1466-1-hch@lst.de>
In-Reply-To: <20180525143512.1466-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: x86@kernel.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, netdev@vger.kernel.org

Limiting the dma mask to avoid PCI (pre-PCIe) DAC cycles while paying
the huge overhead of an IOMMU is rather pointless, and this seriously
gets in the way of dma mapping work.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 .../admin-guide/kernel-parameters.txt         |  1 -
 Documentation/x86/x86_64/boot-options.txt     |  4 +---
 arch/x86/kernel/pci-dma.c                     | 21 +------------------
 drivers/net/ethernet/sfc/efx.c                |  5 ++---
 drivers/net/ethernet/sfc/falcon/efx.c         |  5 ++---
 5 files changed, 6 insertions(+), 30 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index f2040d46f095..cc0ac035b8fe 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -1705,7 +1705,6 @@
 		nopanic
 		merge
 		nomerge
-		forcesac
 		soft
 		pt		[x86, IA-64]
 		nobypass	[PPC/POWERNV]
diff --git a/Documentation/x86/x86_64/boot-options.txt b/Documentation/x86/x86_64/boot-options.txt
index 153b3a57fba2..341588ec4e29 100644
--- a/Documentation/x86/x86_64/boot-options.txt
+++ b/Documentation/x86/x86_64/boot-options.txt
@@ -208,7 +208,7 @@ IOMMU (input/output memory management unit)
       Kernel boot message: "PCI-DMA: Using Calgary IOMMU"
 
  iommu=[<size>][,noagp][,off][,force][,noforce][,leak[=<nr_of_leak_pages>]
-	[,memaper[=<order>]][,merge][,forcesac][,fullflush][,nomerge]
+	[,memaper[=<order>]][,merge][,fullflush][,nomerge]
 	[,noaperture][,calgary]
 
   General iommu options:
@@ -235,8 +235,6 @@ IOMMU (input/output memory management unit)
                        (experimental).
     nomerge            Don't do scatter-gather (SG) merging.
     noaperture         Ask the IOMMU not to touch the aperture for AGP.
-    forcesac           Force single-address cycle (SAC) mode for masks <40bits
-                       (experimental).
     noagp              Don't initialize the AGP driver and use full aperture.
     allowdac           Allow double-address cycle (DAC) mode, i.e. DMA >4GB.
                        DAC is used with 32-bit PCI to push a 64-bit address in
diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
index 77625b60a510..91dff954b745 100644
--- a/arch/x86/kernel/pci-dma.c
+++ b/arch/x86/kernel/pci-dma.c
@@ -20,8 +20,6 @@ static int forbid_dac __read_mostly;
 const struct dma_map_ops *dma_ops = &dma_direct_ops;
 EXPORT_SYMBOL(dma_ops);
 
-static int iommu_sac_force __read_mostly;
-
 #ifdef CONFIG_IOMMU_DEBUG
 int panic_on_overflow __read_mostly = 1;
 int force_iommu __read_mostly = 1;
@@ -125,7 +123,7 @@ static __init int iommu_setup(char *p)
 		if (!strncmp(p, "nomerge", 7))
 			iommu_merge = 0;
 		if (!strncmp(p, "forcesac", 8))
-			iommu_sac_force = 1;
+			pr_warn("forcesac option ignored.\n");
 		if (!strncmp(p, "allowdac", 8))
 			forbid_dac = 0;
 		if (!strncmp(p, "nodac", 5))
@@ -165,23 +163,6 @@ int arch_dma_supported(struct device *dev, u64 mask)
 	}
 #endif
 
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
-		dev_info(dev, "Force SAC with mask %Lx\n", mask);
-		return 0;
-	}
-
 	return 1;
 }
 EXPORT_SYMBOL(arch_dma_supported);
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index a4ebd8715494..661828e8fdcf 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1289,9 +1289,8 @@ static int efx_init_io(struct efx_nic *efx)
 
 	pci_set_master(pci_dev);
 
-	/* Set the PCI DMA mask.  Try all possibilities from our
-	 * genuine mask down to 32 bits, because some architectures
-	 * (e.g. x86_64 with iommu_sac_force set) will allow 40 bit
+	/* Set the PCI DMA mask.  Try all possibilities from our genuine mask
+	 * down to 32 bits, because some architectures will allow 40 bit
 	 * masks event though they reject 46 bit masks.
 	 */
 	while (dma_mask > 0x7fffffffUL) {
diff --git a/drivers/net/ethernet/sfc/falcon/efx.c b/drivers/net/ethernet/sfc/falcon/efx.c
index 3d6c91e96589..dd5530a4f8c8 100644
--- a/drivers/net/ethernet/sfc/falcon/efx.c
+++ b/drivers/net/ethernet/sfc/falcon/efx.c
@@ -1242,9 +1242,8 @@ static int ef4_init_io(struct ef4_nic *efx)
 
 	pci_set_master(pci_dev);
 
-	/* Set the PCI DMA mask.  Try all possibilities from our
-	 * genuine mask down to 32 bits, because some architectures
-	 * (e.g. x86_64 with iommu_sac_force set) will allow 40 bit
+	/* Set the PCI DMA mask.  Try all possibilities from our genuine mask
+	 * down to 32 bits, because some architectures will allow 40 bit
 	 * masks event though they reject 46 bit masks.
 	 */
 	while (dma_mask > 0x7fffffffUL) {
-- 
2.17.0

