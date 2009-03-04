From: akpm@linux-foundation.org
Date: Wed, 04 Mar 2009 20:09:46 +0000
Subject: [patch for 2.6.29? 1/1] ia64: fix PCI DMA flag propagation on SN (Altix) with PICs
Message-Id: <200903042009.n24K9kpC029740@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Jeremy Higdon <jeremy@sgi.com>

We recently discovered a problem with passing of DMA attributes on SN
systems with the older PIC chips.

[akpm@linux-foundation.org: coding-style fixes]
Signed-off-by: Jeremy Higdon <jeremy@sgi.com>
Cc: <habeck@sgi.com>
Cc: "Luck, Tony" <tony.luck@intel.com>
Cc: Jesse Barnes <jbarnes@virtuousgeek.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/sn/pci/pcibr/pcibr_dma.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff -puN arch/ia64/sn/pci/pcibr/pcibr_dma.c~ia64-fix-pci-dma-flag-propagation-on-sn-altix-with-pics arch/ia64/sn/pci/pcibr/pcibr_dma.c
--- a/arch/ia64/sn/pci/pcibr/pcibr_dma.c~ia64-fix-pci-dma-flag-propagation-on-sn-altix-with-pics
+++ a/arch/ia64/sn/pci/pcibr/pcibr_dma.c
@@ -135,11 +135,10 @@ pcibr_dmatrans_direct64(struct pcidev_in
 	if (SN_DMA_ADDRTYPE(dma_flags) = SN_DMA_ADDR_PHYS)
 		pci_addr = IS_PIC_SOFT(pcibus_info) ?
 				PHYS_TO_DMA(paddr) :
-		    		PHYS_TO_TIODMA(paddr) | dma_attributes;
+				PHYS_TO_TIODMA(paddr);
 	else
-		pci_addr = IS_PIC_SOFT(pcibus_info) ?
-				paddr :
-				paddr | dma_attributes;
+		pci_addr = paddr;
+	pci_addr |= dma_attributes;
 
 	/* Handle Bus mode */
 	if (IS_PCIX(pcibus_info))
_
