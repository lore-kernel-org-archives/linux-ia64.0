From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 08 Sep 2003 19:19:44 +0000
Subject: [PATCH] misc. sn2 updates
Message-Id: <marc-linux-ia64-106304956024421@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix a couple of sn2 files.

Jesse

diff -Nru a/arch/ia64/sn/io/machvec/pci_dma.c b/arch/ia64/sn/io/machvec/pci_dma.c
--- a/arch/ia64/sn/io/machvec/pci_dma.c	Mon Sep  8 12:13:26 2003
+++ b/arch/ia64/sn/io/machvec/pci_dma.c	Mon Sep  8 12:13:26 2003
@@ -597,7 +597,7 @@
 	if (!sn_dma_supported(dev, dma_mask))
 		return 0;
 
-	dev->dma_mask = dma_mask;
+	*dev->dma_mask = dma_mask;
 	return 1;
 }
 EXPORT_SYMBOL(sn_dma_set_mask);
diff -Nru a/include/asm-ia64/sn/hcl.h b/include/asm-ia64/sn/hcl.h
--- a/include/asm-ia64/sn/hcl.h	Mon Sep  8 12:13:26 2003
+++ b/include/asm-ia64/sn/hcl.h	Mon Sep  8 12:13:26 2003
@@ -10,6 +10,7 @@
 #define _ASM_IA64_SN_HCL_H
 
 #include <asm/sn/sgi.h>
+#include <asm/sn/invent.h>
 
 extern vertex_hdl_t hwgraph_root;
 extern vertex_hdl_t linux_busnum;
diff -Nru a/include/asm-ia64/sn/pci/pciio.h b/include/asm-ia64/sn/pci/pciio.h
--- a/include/asm-ia64/sn/pci/pciio.h	Mon Sep  8 12:13:26 2003
+++ b/include/asm-ia64/sn/pci/pciio.h	Mon Sep  8 12:13:26 2003
@@ -695,5 +695,39 @@
 extern int              pciio_error_handler(vertex_hdl_t, int, ioerror_mode_t, ioerror_t *);
 extern int		pciio_dma_enabled(vertex_hdl_t);
 
+/**
+ * sn_pci_set_vchan - Set the requested Virtual Channel bits into the mapped DMA
+ *                    address.
+ * @pci_dev: pci device pointer
+ * @addr: mapped dma address
+ * @vchan: Virtual Channel to use 0 or 1.
+ *
+ * Set the Virtual Channel bit in the mapped dma address.
+ */
+
+static inline int
+sn_pci_set_vchan(struct pci_dev *pci_dev,
+		 dma_addr_t *addr,
+		 int vchan)
+{
+	if (vchan > 1) {
+		return -1;
+	}
+
+	if (!(*addr >> 32))     /* Using a mask here would be cleaner */
+		return 0;       /* but this generates better code */
+
+	if (vchan = 1) {
+		/* Set Bit 57 */
+		*addr |= (1UL << 57);
+	}
+	else {
+		/* Clear Bit 57 */
+		*addr &= ~(1UL << 57);
+	}
+
+	return 0;
+}
+
 #endif				/* C or C++ */
 #endif				/* _ASM_SN_PCI_PCIIO_H */
diff -Nru a/include/asm-ia64/sn/sn2/intr.h b/include/asm-ia64/sn/sn2/intr.h
--- a/include/asm-ia64/sn/sn2/intr.h	Mon Sep  8 12:13:26 2003
+++ b/include/asm-ia64/sn/sn2/intr.h	Mon Sep  8 12:13:26 2003
@@ -17,10 +17,11 @@
 #define SGI_II_ERROR			(0x31)
 #define SGI_XBOW_ERROR			(0x32)
 #define SGI_PCIBR_ERROR			(0x33)
+#define SGI_ACPI_SCI_INT		(0x34)
 #define SGI_XPC_NOTIFY			(0xe7)
 
 #define IA64_SN2_FIRST_DEVICE_VECTOR	(0x34)
-#define IA64_SN2_LAST_DEVICE_VECTOR	(0xe6)
+#define IA64_SN2_LAST_DEVICE_VECTOR	(0xe7)
 
 #define SN2_IRQ_RESERVED        (0x1)
 #define SN2_IRQ_CONNECTED       (0x2)
