From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 15 Mar 2004 21:39:20 +0000
Subject: Re: [PATCH] move consistent_dma_mask to the generic device
Message-Id: <200403151439.20917.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The patch that moved and renamed consistent_dma_mask neglected
to fix up arch/ia64/hp/common/sba_iommu.c.  I think we need the
attached patch (booted, but not otherwise tested):

=== arch/ia64/hp/common/sba_iommu.c 1.38 vs edited ==--- 1.38/arch/ia64/hp/common/sba_iommu.c	Fri Feb 27 03:16:24 2004
+++ edited/arch/ia64/hp/common/sba_iommu.c	Mon Mar 15 14:29:15 2004
@@ -1055,13 +1055,13 @@
 	*dma_handle = virt_to_phys(addr);
 
 #ifdef ALLOW_IOV_BYPASS
-	ASSERT(to_pci_dev(dev)->consistent_dma_mask);
+	ASSERT(to_pci_dev(dev)->dev.coherent_dma_mask);
 	/*
  	** Check if the PCI device can DMA to ptr... if so, just return ptr
  	*/
-	if (likely((*dma_handle & ~to_pci_dev(dev)->consistent_dma_mask) = 0)) {
+	if (likely((*dma_handle & ~to_pci_dev(dev)->dev.coherent_dma_mask) = 0)) {
 		DBG_BYPASS("sba_alloc_coherent() bypass mask/addr: 0x%lx/0x%lx\n",
-		           to_pci_dev(dev)->consistent_dma_mask, *dma_handle);
+		           to_pci_dev(dev)->dev.coherent_dma_mask, *dma_handle);
 
 		return addr;
 	}

