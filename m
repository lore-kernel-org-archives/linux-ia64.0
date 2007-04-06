From: Mike Habeck <habeck@sgi.com>
Date: Fri, 06 Apr 2007 17:04:39 +0000
Subject: [PATCH] SGI Altix : fix pcibr_dmamap_ate32() bug
Message-Id: <20070406170439.24071.57637.75833@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On a SGI Altix TIOCP based PCI bus we need to include the ATE_PIO attribute 
bit if we're mapping a 32bit MSI address.  

Signed-off-by: Mike Habeck <habeck@sgi.com>

---

This fixes the problem Andreas Schwab saw while using MSI with the sata-vsc 
driver on a SGI Prism.  The patch is based off the aegl/linux-2.6.git tree.

 arch/ia64/sn/pci/pcibr/pcibr_dma.c   |    8 ++++++--
 include/asm-ia64/sn/pcibr_provider.h |    5 +++--
 2 files changed, 9 insertions(+), 4 deletions(-)


Index: linux-2.6/arch/ia64/sn/pci/pcibr/pcibr_dma.c
=================================--- linux-2.6.orig/arch/ia64/sn/pci/pcibr/pcibr_dma.c	2007-04-05 16:20:38.000000000 -0500
+++ linux-2.6/arch/ia64/sn/pci/pcibr/pcibr_dma.c	2007-04-05 17:11:32.867619640 -0500
@@ -96,10 +96,14 @@ pcibr_dmamap_ate32(struct pcidev_info *i
 	}
 
 	/*
-	 * If we're mapping for MSI, set the MSI bit in the ATE
+	 * If we're mapping for MSI, set the MSI bit in the ATE.  If it's a
+	 * TIOCP based pci bus, we also need to set the PIO bit in the ATE.
 	 */
-	if (dma_flags & SN_DMA_MSI)
+	if (dma_flags & SN_DMA_MSI) {
 		ate |= PCI32_ATE_MSI;
+		if (IS_TIOCP_SOFT(pcibus_info))
+			ate |= PCI32_ATE_PIO;
+	}
 
 	ate_write(pcibus_info, ate_index, ate_count, ate);
 
Index: linux-2.6/include/asm-ia64/sn/pcibr_provider.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/pcibr_provider.h	2007-04-05 16:20:51.000000000 -0500
+++ linux-2.6/include/asm-ia64/sn/pcibr_provider.h	2007-04-05 17:00:31.802388638 -0500
@@ -21,6 +21,7 @@
 #define IS_PCI_BRIDGE_ASIC(asic) (asic = PCIIO_ASIC_TYPE_PIC || \
                 asic = PCIIO_ASIC_TYPE_TIOCP)
 #define IS_PIC_SOFT(ps)     (ps->pbi_bridge_type = PCIBR_BRIDGETYPE_PIC)
+#define IS_TIOCP_SOFT(ps)   (ps->pbi_bridge_type = PCIBR_BRIDGETYPE_TIOCP)
 
 
 /*
@@ -53,8 +54,8 @@
  * Bridge PMU Address Transaltion Entry Attibutes
  */
 #define PCI32_ATE_V                     (0x1 << 0)
-#define PCI32_ATE_CO                    (0x1 << 1)
-#define PCI32_ATE_PREC                  (0x1 << 2)
+#define PCI32_ATE_CO                    (0x1 << 1)	/* PIC ASIC ONLY */
+#define PCI32_ATE_PIO                   (0x1 << 1)	/* TIOCP ASIC ONLY */
 #define PCI32_ATE_MSI                   (0x1 << 2)
 #define PCI32_ATE_PREF                  (0x1 << 3)
 #define PCI32_ATE_BAR                   (0x1 << 4)
