From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 15 Mar 2004 21:55:56 +0000
Subject: Re: [PATCH] move consistent_dma_mask to the generic device
Message-Id: <200403151455.56228.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403151439.20917.bjorn.helgaas@hp.com>
In-Reply-To: <200403151439.20917.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 15 March 2004 2:48 pm, James Bottomley wrote:
> erm, the patch is a bit redundant isn't it?
> 
> &to_pci_dev(dev)->dev = dev

Ah, ok, how about this:

=== arch/ia64/hp/common/sba_iommu.c 1.38 vs edited ==--- 1.38/arch/ia64/hp/common/sba_iommu.c	Fri Feb 27 03:16:24 2004
+++ edited/arch/ia64/hp/common/sba_iommu.c	Mon Mar 15 14:51:33 2004
@@ -1055,13 +1055,13 @@
 	*dma_handle = virt_to_phys(addr);
 
 #ifdef ALLOW_IOV_BYPASS
-	ASSERT(to_pci_dev(dev)->consistent_dma_mask);
+	ASSERT(dev->coherent_dma_mask);
 	/*
  	** Check if the PCI device can DMA to ptr... if so, just return ptr
  	*/
-	if (likely((*dma_handle & ~to_pci_dev(dev)->consistent_dma_mask) = 0)) {
+	if (likely((*dma_handle & ~dev->coherent_dma_mask) = 0)) {
 		DBG_BYPASS("sba_alloc_coherent() bypass mask/addr: 0x%lx/0x%lx\n",
-		           to_pci_dev(dev)->consistent_dma_mask, *dma_handle);
+		           dev->coherent_dma_mask, *dma_handle);
 
 		return addr;
 	}

