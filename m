From: Matthew Wilcox <willy@debian.org>
Date: Sat, 12 Jul 2003 20:17:09 +0000
Subject: [PATCH] Add some devinits to pci.c
Message-Id: <marc-linux-ia64-105804121532660@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


These functions can all be devinit as they're all called from functions
which are themselves devinit.

diff -urpNX build-tools/dontdiff linux-2.5.75/arch/ia64/pci/pci.c linux-2.5.75-willy/arch/ia64/pci/pci.c
--- linux-2.5.75/arch/ia64/pci/pci.c	2003-07-10 14:08:53.000000000 -0600
+++ linux-2.5.75-willy/arch/ia64/pci/pci.c	2003-07-12 07:41:22.000000000 -0600
@@ -124,7 +124,7 @@ subsys_initcall(pci_acpi_init);
 
 /* Called by ACPI when it finds a new root bus.  */
 
-static struct pci_controller *
+static struct pci_controller * __devinit
 alloc_pci_controller (int seg)
 {
 	struct pci_controller *controller;
@@ -138,7 +138,7 @@ alloc_pci_controller (int seg)
 	return controller;
 }
 
-static int
+static int __devinit
 alloc_resource (char *name, struct resource *root, unsigned long start, unsigned long end, unsigned long flags)
 {
 	struct resource *res;
@@ -159,7 +159,7 @@ alloc_resource (char *name, struct resou
 	return 0;
 }
 
-static u64
+static u64 __devinit
 add_io_space (struct acpi_resource_address64 *addr)
 {
 	u64 offset;
@@ -190,7 +190,7 @@ add_io_space (struct acpi_resource_addre
 	return IO_SPACE_BASE(i);
 }
 
-static acpi_status
+static acpi_status __devinit
 count_window (struct acpi_resource *resource, void *data)
 {
 	unsigned int *windows = (unsigned int *) data;
@@ -211,7 +211,7 @@ struct pci_root_info {
 	char *name;
 };
 
-static acpi_status
+static acpi_status __devinit
 add_window (struct acpi_resource *res, void *data)
 {
 	struct pci_root_info *info = (struct pci_root_info *) data;
@@ -252,7 +252,7 @@ add_window (struct acpi_resource *res, v
 	return AE_OK;
 }
 
-struct pci_bus *
+struct pci_bus * __devinit
 pci_acpi_scan_root (struct acpi_device *device, int domain, int bus)
 {
 	struct pci_root_info info;

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
