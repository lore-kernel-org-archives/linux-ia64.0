From: Matthew Wilcox <willy@debian.org>
Date: Mon, 07 Jul 2003 20:24:46 +0000
Subject: [PATCH] Use generic pci_scan_bus()
Message-Id: <marc-linux-ia64-105760950731729@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi David.  With the recent changes in 2.5.74-BK, ia64 can now use the
generic pci_scan_bus().

diff -urpN linux-2.5.73-pci/arch/ia64/pci/pci.c linux-2.5.73-willy/arch/ia64/pci/pci.c
--- linux-2.5.73-pci/arch/ia64/pci/pci.c	2003-07-04 11:34:39.000000000 -0600
+++ linux-2.5.73-willy/arch/ia64/pci/pci.c	2003-07-04 13:58:19.000000000 -0600
@@ -138,37 +138,6 @@ alloc_pci_controller (int seg)
 	return controller;
 }
 
-static struct pci_bus *
-scan_root_bus (int bus, struct pci_ops *ops, void *sysdata)
-{
-	struct pci_bus *b;
-
-	/*
-	 * We know this is a new root bus we haven't seen before, so
-	 * scan it, even if we've seen the same bus number in a different
-	 * segment.
-	 */
-	b = kmalloc(sizeof(*b), GFP_KERNEL);
-	if (!b)
-		return NULL;
-
-	memset(b, 0, sizeof(*b));
-	INIT_LIST_HEAD(&b->children);
-	INIT_LIST_HEAD(&b->devices);
-
-	list_add_tail(&b->node, &pci_root_buses);
-
-	b->number = b->secondary = bus;
-	b->resource[0] = &ioport_resource;
-	b->resource[1] = &iomem_resource;
-
-	b->sysdata = sysdata;
-	b->ops = ops;
-	b->subordinate = pci_do_scan_bus(b);
-
-	return b;
-}
-
 static int
 alloc_resource (char *name, struct resource *root, unsigned long start, unsigned long end, unsigned long flags)
 {
@@ -312,7 +281,7 @@ pci_acpi_scan_root (struct acpi_device *
 	info.name = name;
 	acpi_walk_resources(device->handle, METHOD_NAME__CRS, add_window, &info);
 
-	return scan_root_bus(bus, &pci_root_ops, controller);
+	return pci_scan_bus(bus, &pci_root_ops, controller);
 
 out3:
 	kfree(controller->window);

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
