From: "Lee, Jung-Ik" <jung-ik.lee@intel.com>
Date: Fri, 18 Oct 2002 11:10:56 +0000
Subject: [Linux-ia64] PCI hotplug changes for 2.5.39 or later
Message-Id: <marc-linux-ia64-105590709805194@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following patch fixes ia64 kernel dump on Hot-Add of PCI bridge cards.

	pcibios_fixup_bus();
	pci_do_scan_bus();
	on Hot-Add of bridge adapter;

Thanks,
J.I.

======================================
diff -urN linux-2.5.39-ia64-020928/arch/ia64/pci/pci.c
linux-2.5.39-phpv-src/arch/ia64/pci/pci.c
--- linux-2.5.39-ia64-020928/arch/ia64/pci/pci.c	Fri Sep 27 14:49:51
2002
+++ linux-2.5.39-phpv-src/arch/ia64/pci/pci.c	Fri Oct 18 02:39:00 2002
@@ -141,13 +141,13 @@
 /*
  *  Called after each bus is probed, but before its children are examined.
  */
-void __init
+void __devinit
 pcibios_fixup_bus (struct pci_bus *b)
 {
 	return;
 }
 
-void __init
+void __devinit
 pcibios_update_resource (struct pci_dev *dev, struct resource *root,
 			 struct resource *res, int resource)
 {
@@ -163,7 +163,7 @@
 	/* ??? FIXME -- record old value for shutdown.  */
 }
 
-void __init
+void __devinit
 pcibios_update_irq (struct pci_dev *dev, int irq)
 {
 	pci_write_config_byte(dev, PCI_INTERRUPT_LINE, irq);
@@ -171,7 +171,7 @@
 	/* ??? FIXME -- record old value for shutdown.  */
 }
 
-void __init
+void __devinit
 pcibios_fixup_pbus_ranges (struct pci_bus * bus, struct
pbus_set_ranges_data * ranges)
 {
 }

