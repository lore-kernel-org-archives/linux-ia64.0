From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 15 Mar 2004 23:51:16 +0000
Subject: DMA API fixup
Message-Id: <200403151651.16684.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We also need the following patch to build the generic_defconfig
after the DMA API change:
    http://linux.bkbits.net:8080/linux-2.5/cset@405490e15inT3T0H2x887j9SaMkYRQ

=== include/asm-ia64/machvec.h 1.19 vs edited ==--- 1.19/include/asm-ia64/machvec.h	Sat Mar 13 23:54:58 2004
+++ edited/include/asm-ia64/machvec.h	Mon Mar 15 15:53:54 2004
@@ -154,10 +154,10 @@
 	ia64_mv_dma_unmap_single *dma_unmap_single;
 	ia64_mv_dma_map_sg *dma_map_sg;
 	ia64_mv_dma_unmap_sg *dma_unmap_sg;
-	ia64_mv_dma_sync_single *dma_sync_single_for_cpu;
-	ia64_mv_dma_sync_sg *dma_sync_sg_for_cpu;
-	ia64_mv_dma_sync_single *dma_sync_single_for_device;
-	ia64_mv_dma_sync_sg *dma_sync_sg_for_device;
+	ia64_mv_dma_sync_single_for_cpu *dma_sync_single_for_cpu;
+	ia64_mv_dma_sync_sg_for_cpu *dma_sync_sg_for_cpu;
+	ia64_mv_dma_sync_single_for_device *dma_sync_single_for_device;
+	ia64_mv_dma_sync_sg_for_device *dma_sync_sg_for_device;
 	ia64_mv_dma_supported *dma_supported;
 	ia64_mv_irq_desc *irq_desc;
 	ia64_mv_irq_to_vector *irq_to_vector;

