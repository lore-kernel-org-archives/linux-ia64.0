From: Jes Sorensen <jes@wildopensource.com>
Date: Tue, 09 Sep 2003 02:38:09 +0000
Subject: [patch] sn2 dma_mask fix
Message-Id: <marc-linux-ia64-106307548016361@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David,

Here's a pretty trivial one fixing the SN2 code to set the DMA mask
correctly when using the dma_ API.

Cheers,
Jes

--- old/arch/ia64/sn/io/machvec/pci_dma.c~	Fri Aug 22 16:53:45 2003
+++ linux/arch/ia64/sn/io/machvec/pci_dma.c	Thu Sep  4 11:46:54 2003
@@ -597,7 +597,7 @@
 	if (!sn_dma_supported(dev, dma_mask))
 		return 0;
 
-	dev->dma_mask = dma_mask;
+	*dev->dma_mask = dma_mask;
 	return 1;
 }
 EXPORT_SYMBOL(sn_dma_set_mask);
