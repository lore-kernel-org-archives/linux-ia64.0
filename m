From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 22 Mar 2004 18:30:53 +0000
Subject: Re: 2.6.5-rc2 lots of warnings for dma_error
Message-Id: <200403221130.53984.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5631.1079924674@kao2.melbourne.sgi.com>
In-Reply-To: <5631.1079924674@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 22 March 2004 2:36 am, Andrew Morton wrote:
> This adds the necessary stubs for ia64 and builds OK with my config, but it
> needs a double-check.

I needed the following additional patch to build the generic kernel:

diff -u -ur 2.6-mm/arch/ia64/sn/io/machvec/pci_dma.c 2.6/arch/ia64/sn/io/machvec/pci_dma.c
--- 2.6-mm/arch/ia64/sn/io/machvec/pci_dma.c	2004-03-22 11:26:22.000000000 -0700
+++ 2.6/arch/ia64/sn/io/machvec/pci_dma.c	2004-03-22 10:18:07.000000000 -0700
@@ -483,12 +483,6 @@
 	return;
 }
 
-int
-sn_dma_error(dma_addr_t dma_addr)
-{
-	return 0;
-}
-
 /**
  * sn_dma_supported - test a DMA mask
  * @hwdev: device to test
@@ -658,7 +652,7 @@
 }
 EXPORT_SYMBOL(sn_dma_sync_sg_for_device);
 
-void
+int
 sn_dma_error(dma_addr_t dma_addr)
 {
 	return 0;
diff -u -ur 2.6-mm/include/asm-ia64/machvec.h 2.6/include/asm-ia64/machvec.h
--- 2.6-mm/include/asm-ia64/machvec.h	2004-03-22 11:26:21.000000000 -0700
+++ 2.6/include/asm-ia64/machvec.h	2004-03-22 10:05:33.000000000 -0700
@@ -160,7 +160,7 @@
 	ia64_mv_dma_sync_sg_for_cpu *dma_sync_sg_for_cpu;
 	ia64_mv_dma_sync_single_for_device *dma_sync_single_for_device;
 	ia64_mv_dma_sync_sg_for_device *dma_sync_sg_for_device;
-	ia64_mv_dma_error *dma_error
+	ia64_mv_dma_error *dma_error;
 	ia64_mv_dma_supported *dma_supported;
 	ia64_mv_irq_desc *irq_desc;
 	ia64_mv_irq_to_vector *irq_to_vector;
