From: Christoph Hellwig <hch@lst.de>
Date: Fri, 26 Sep 2003 10:17:50 +0000
Subject: [PATCH] simplify SN2 interrupt allocation
Message-Id: <marc-linux-ia64-106457149810700@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Same issues as the dma mapping code, but as SN2 interrupt handling is
totally static and all irqs are allocated on bootup an never freed it's
not a speed issue.

I really wonder what someone has to smoke to call a that expensive
dispatcher just to cast the data structure back to the lowlevel one
directly afterwards...



--- 1.10/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Mon Sep  8 14:12:36 2003
+++ edited/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Fri Sep 26 12:10:00 2003
@@ -426,7 +426,7 @@
 	struct pci_dev *device_dev = NULL;
 	struct sn_widget_sysdata *widget_sysdata;
 	struct sn_device_sysdata *device_sysdata;
-	pciio_intr_t intr_handle;
+	pcibr_intr_t intr_handle;
 	int cpuid;
 	vertex_hdl_t device_vertex;
 	pciio_intr_line_t lines;
@@ -545,17 +549,17 @@
 				     (unsigned char *)&lines);
 	 
 		irqpdaindr->curr = device_dev;
-		intr_handle = pciio_intr_alloc(device_vertex, NULL, lines, device_vertex);
+		intr_handle = pcibr_intr_alloc(device_vertex, NULL, lines, device_vertex);
 
-		irq = intr_handle->pi_irq;
+		irq = intr_handle->bi_irq;
 		irqpdaindr->device_dev[irq] = device_dev;
-		cpuid = intr_handle->pi_cpu;
-		pciio_intr_connect(intr_handle, (intr_func_t)0, (intr_arg_t)0);
+		cpuid = intr_handle->bi_cpu;
+		pcibr_intr_connect(intr_handle, (intr_func_t)0, (intr_arg_t)0);
 		device_dev->irq = irq;
-		register_pcibr_intr(irq, (pcibr_intr_t)intr_handle);
+		register_pcibr_intr(irq, intr_handle);
 
 		for (idx = 0; idx < PCI_ROM_RESOURCE; idx++) {
-			int ibits = ((pcibr_intr_t)intr_handle)->bi_ibits;
+			int ibits = intr_handle->bi_ibits;
 			int i;
 
 			size = device_dev->resource[idx].end -
