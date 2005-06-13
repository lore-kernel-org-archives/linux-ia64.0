From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 13 Jun 2005 18:26:38 +0000
Subject: [PATCH] ia64: remove "pci=routeirq" option
Message-Id: <200506131226.38867.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Remove "pci=routeirq" option for ia64.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: linux-2.6/arch/ia64/pci/pci.c
=================================--- linux-2.6.orig/arch/ia64/pci/pci.c	2005-06-13 11:52:53.000000000 -0600
+++ linux-2.6/arch/ia64/pci/pci.c	2005-06-13 11:54:28.000000000 -0600
@@ -32,8 +32,6 @@
 #include <asm/hw_irq.h>
 
 
-static int pci_routeirq;
-
 /*
  * Low-level SAL-based PCI configuration access functions. Note that SAL
  * calls are already serialized (via sal_lock), so we don't need another
@@ -138,24 +136,8 @@
 static int __init
 pci_acpi_init (void)
 {
-	struct pci_dev *dev = NULL;
-
-	printk(KERN_INFO "PCI: Using ACPI for IRQ routing\n");
-
 	acpi_map_iosapics();
 
-	if (pci_routeirq) {
-		/*
-		 * PCI IRQ routing is set up by pci_enable_device(), but we
-		 * also do it here in case there are still broken drivers that
-		 * don't use pci_enable_device().
-		 */
-		printk(KERN_INFO "PCI: Routing interrupts for all devices because \"pci=routeirq\" specified\n");
-		for_each_pci_dev(dev)
-			acpi_pci_irq_enable(dev);
-	} else
-		printk(KERN_INFO "PCI: If a device doesn't work, try \"pci=routeirq\".  If it helps, post a report\n");
-
 	return 0;
 }
 
@@ -499,8 +481,6 @@
 char * __init
 pcibios_setup (char *str)
 {
-	if (!strcmp(str, "routeirq"))
-		pci_routeirq = 1;
 	return NULL;
 }
 
