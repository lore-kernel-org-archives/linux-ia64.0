From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 24 Apr 2003 22:25:57 +0000
Subject: [Linux-ia64] [PATCH] 4/4 multi-ioport space support for 2.5
Message-Id: <marc-linux-ia64-105590723705602@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

diff -u -ur linux-2.5.67-ia64-030416-io3/arch/ia64/pci/pci.c linux-2.5.67-ia64-030416-io4/arch/ia64/pci/pci.c
--- linux-2.5.67-ia64-030416-io3/arch/ia64/pci/pci.c	2003-04-24 14:47:27.000000000 -0600
+++ linux-2.5.67-ia64-030416-io4/arch/ia64/pci/pci.c	2003-04-24 14:46:26.000000000 -0600
@@ -5,6 +5,7 @@
  *
  * Copyright (C) 2002 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
+ *	Bjorn Helgaas <bjorn_helgaas@hp.com>
  *
  * Note: Above list of copyright holders is incomplete...
  */
@@ -116,38 +117,10 @@
 
 subsys_initcall(pci_acpi_init);
 
-void __init
-pcibios_fixup_device_resources (struct pci_dev *dev, struct pci_bus *bus)
-{
-	struct pci_controller *controller = PCI_CONTROLLER(dev);
-	struct pci_window *window;
-	int i, j;
-
-	for (i = 0; i < PCI_NUM_RESOURCES; i++) {
-		if (!dev->resource[i].start)
-			continue;
-
-#define contains(win, res)	((res)->start >= (win)->start && \
-				 (res)->end   <= (win)->end)
-
-		for (j = 0; j < controller->windows; j++) {
-			window = &controller->window[j];
-			if (((dev->resource[i].flags & IORESOURCE_MEM &&
-			      window->resource.flags & IORESOURCE_MEM) ||
-			     (dev->resource[i].flags & IORESOURCE_IO &&
-			      window->resource.flags & IORESOURCE_IO)) &&
-			    contains(&window->resource, &dev->resource[i])) {
-				dev->resource[i].start += window->offset;
-				dev->resource[i].end   += window->offset;
-			}
-		}
-	}
-}
-
 /* Called by ACPI when it finds a new root bus.  */
 
 static struct pci_controller *
-alloc_pci_controller(int seg)
+alloc_pci_controller (int seg)
 {
 	struct pci_controller *controller;
 
@@ -160,8 +133,8 @@
 	return controller;
 }
 
-struct pci_bus *
-scan_root_bus(int bus, struct pci_ops *ops, void *sysdata)
+static struct pci_bus *
+scan_root_bus (int bus, struct pci_ops *ops, void *sysdata)
 {
 	struct pci_bus *b;
 
@@ -344,6 +317,34 @@
 	return NULL;
 }
 
+void __init
+pcibios_fixup_device_resources (struct pci_dev *dev, struct pci_bus *bus)
+{
+	struct pci_controller *controller = PCI_CONTROLLER(dev);
+	struct pci_window *window;
+	int i, j;
+
+	for (i = 0; i < PCI_NUM_RESOURCES; i++) {
+		if (!dev->resource[i].start)
+			continue;
+
+#define contains(win, res)	((res)->start >= (win)->start && \
+				 (res)->end   <= (win)->end)
+
+		for (j = 0; j < controller->windows; j++) {
+			window = &controller->window[j];
+			if (((dev->resource[i].flags & IORESOURCE_MEM &&
+			      window->resource.flags & IORESOURCE_MEM) ||
+			     (dev->resource[i].flags & IORESOURCE_IO &&
+			      window->resource.flags & IORESOURCE_IO)) &&
+			    contains(&window->resource, &dev->resource[i])) {
+				dev->resource[i].start += window->offset;
+				dev->resource[i].end   += window->offset;
+			}
+		}
+	}
+}
+
 /*
  *  Called after each bus is probed, but before its children are examined.
  */


