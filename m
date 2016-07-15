From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 15 Jul 2016 21:12:15 +0000
Subject: [patch] [IA64] fix SN_DMA_ADDRTYPE() condition
Message-Id: <20160715211215.GD19522@mwanda>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Mark Maule <maule@sgi.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

The parentheses are in the wrong place so it causes a static checker
warning.  It means we don't mask away the high bits of dma_flags before
doing the comparison.

Fixes: 83821d3f558d ('[PATCH] PCI: altix: msi support')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/arch/ia64/sn/pci/pcibr/pcibr_dma.c b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
index 1e863b2..71c9bf3 100644
--- a/arch/ia64/sn/pci/pcibr/pcibr_dma.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
@@ -82,7 +82,7 @@ pcibr_dmamap_ate32(struct pcidev_info *info,
 	if (IS_PCIX(pcibus_info))
 		ate_flags &= ~(PCI32_ATE_PREF);
 
-	if (SN_DMA_ADDRTYPE(dma_flags = SN_DMA_ADDR_PHYS))
+	if (SN_DMA_ADDRTYPE(dma_flags) = SN_DMA_ADDR_PHYS)
 		xio_addr = IS_PIC_SOFT(pcibus_info) ? PHYS_TO_DMA(paddr) :
 	    					      PHYS_TO_TIODMA(paddr);
 	else
