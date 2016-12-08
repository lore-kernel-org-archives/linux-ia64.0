From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 08 Dec 2016 10:59:36 +0000
Subject: [patch] ia64: pci: Fix a condition in pcibr_dmamap_ate32()
Message-Id: <20161208105936.GB11382@elgon.mountain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kernel-janitors@vger.kernel.org

Smatch complains that probably this condition isn't correct because it
first does a comparison and then a mask.  Judging from the surrounding
code probably the parenthesis are in the wrong place.

The original code is equivalent to:

	if (dma_flags = SN_DMA_ADDR_PHYS)

And it's probably going to be true less often than my corrected version.

Fixes: 83821d3f558d ("[PATCH] PCI: altix: msi support")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/arch/ia64/sn/pci/pcibr/pcibr_dma.c b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
index 1e863b277ac9..71c9bf308adf 100644
--- a/arch/ia64/sn/pci/pcibr/pcibr_dma.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
@@ -82,7 +82,7 @@
 	if (IS_PCIX(pcibus_info))
 		ate_flags &= ~(PCI32_ATE_PREF);
 
-	if (SN_DMA_ADDRTYPE(dma_flags = SN_DMA_ADDR_PHYS))
+	if (SN_DMA_ADDRTYPE(dma_flags) = SN_DMA_ADDR_PHYS)
 		xio_addr = IS_PIC_SOFT(pcibus_info) ? PHYS_TO_DMA(paddr) :
 	    					      PHYS_TO_TIODMA(paddr);
 	else
