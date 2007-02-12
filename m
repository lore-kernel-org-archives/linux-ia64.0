From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Date: Mon, 12 Feb 2007 06:12:01 +0000
Subject: [PATCH] pci_get_legacy_ide_irq should return
Message-Id: <1171260721.2978.4.camel@ymzhang>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Function pci_get_legacy_ide_irq is incorrect on ia64. It should return
irq vector instead of GSI. The fixed number 14 and 15 are just GSI.

Below patch against kernel 2.6.20 fixes it.

Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>

---

diff -Nraup linux-2.6.20/include/asm-ia64/pci.h linux-2.6.20_fix/include/asm-ia64/pci.h
--- linux-2.6.20/include/asm-ia64/pci.h	2007-02-08 02:13:44.000000000 -0500
+++ linux-2.6.20_fix/include/asm-ia64/pci.h	2007-02-11 16:39:08.000000000 -0500
@@ -9,6 +9,7 @@
 
 #include <asm/io.h>
 #include <asm/scatterlist.h>
+#include <asm/hw_irq.h>
 
 /*
  * Can be used to override the logic in pci_scan_bus for skipping already-configured bus
@@ -170,7 +171,7 @@ pcibios_select_root(struct pci_dev *pdev
 #define HAVE_ARCH_PCI_GET_LEGACY_IDE_IRQ
 static inline int pci_get_legacy_ide_irq(struct pci_dev *dev, int channel)
 {
-	return channel ? 15 : 14;
+	return channel ? isa_irq_to_vector(15) : isa_irq_to_vector(14);
 }
 
 #endif /* _ASM_IA64_PCI_H */
