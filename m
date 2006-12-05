From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 05 Dec 2006 01:25:31 +0000
Subject: Fix pci.c kernel compilation breakage.
Message-Id: <17780.51851.142909.300507@croc.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



The recent change to convert the is_enabled flag in the PCI device to an
atomic count broke the IA64 compilation.

As pcibios_disable_device is only ever called if the reference count
is zero, convert the if to a BUG_ON.

Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>
---
 arch/ia64/pci/pci.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6-import/arch/ia64/pci/pci.c
=================================--- linux-2.6-import.orig/arch/ia64/pci/pci.c	2006-12-05 11:22:00.273987854 +1100
+++ linux-2.6-import/arch/ia64/pci/pci.c	2006-12-05 11:58:12.832925655 +1100
@@ -564,8 +564,8 @@ pcibios_enable_device (struct pci_dev *d
 void
 pcibios_disable_device (struct pci_dev *dev)
 {
-	if (dev->is_enabled)
-		acpi_pci_irq_disable(dev);
+	BUG_ON(atomic_read(&dev->enable_cnt));
+	acpi_pci_irq_disable(dev);
 }
 
 void

