From: Matthew Wilcox <willy@debian.org>
Date: Tue, 24 Jun 2003 21:31:19 +0000
Subject: Re: [PATCH] pcibios_scan_acpi()
Message-Id: <marc-linux-ia64-105649029007877@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105639496518100@msgid-missing>
In-Reply-To: <marc-linux-ia64-105639496518100@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jun 23, 2003 at 02:39:05PM -0700, Greg KH wrote:
> > How about acpi_scan_pci_bus_root()?
> 
> I agree, that sounds better.

I think it's too long ... so unless anyone has a better idea, I'm going with
pci_acpi_scan_root().  Here's the patch, presented in patch -p1 format to
make greg's scripts happy ;-)

ia64 needs to be passed the pci domain and the acpi handle corresponding
to each root bus.  Rather than change pcibios_scan_root to take additional
arguments, this patch introduces pci_acpi_scan_root().

Index: arch/i386/pci/acpi.c
=================================RCS file: /var/cvs/linux-2.5/arch/i386/pci/acpi.c,v
retrieving revision 1.3
diff -u -p -r1.3 acpi.c
--- a/arch/i386/pci/acpi.c	8 Oct 2002 22:46:09 -0000	1.3
+++ b/arch/i386/pci/acpi.c	24 Jun 2003 21:16:47 -0000
@@ -3,6 +3,16 @@
 #include <linux/init.h>
 #include "pci.h"
 
+struct pci_bus * __devinit pci_acpi_scan_root(struct acpi_device *device, int domain, int busnum)
+{
+	if (domain != 0) {
+		printk(KERN_WARNING "PCI: Multiple domains not supported\n");
+		return NULL;
+	}
+
+	return pcibios_scan_root(busnum);
+}
+
 static int __init pci_acpi_init(void)
 {
 	if (pcibios_scanned)
Index: arch/ia64/pci/pci.c
=================================RCS file: /var/cvs/linux-2.5/arch/ia64/pci/pci.c,v
retrieving revision 1.9
diff -u -p -r1.9 pci.c
--- a/arch/ia64/pci/pci.c	23 Jun 2003 03:30:02 -0000	1.9
+++ b/arch/ia64/pci/pci.c	24 Jun 2003 21:16:48 -0000
@@ -284,21 +284,21 @@ add_window (struct acpi_resource *res, v
 }
 
 struct pci_bus *
-pcibios_scan_root (void *handle, int seg, int bus)
+pci_acpi_scan_root (struct acpi_device *device, int domain, int bus)
 {
 	struct pci_root_info info;
 	struct pci_controller *controller;
 	unsigned int windows = 0;
 	char *name;
 
-	printk("PCI: Probing PCI hardware on bus (%02x:%02x)\n", seg, bus);
-	controller = alloc_pci_controller(seg);
+	printk("PCI: Probing PCI hardware on bus (%04x:%02x)\n", domain, bus);
+	controller = alloc_pci_controller(domain);
 	if (!controller)
 		goto out1;
 
-	controller->acpi_handle = handle;
+	controller->acpi_handle = device->handle;
 
-	acpi_walk_resources(handle, METHOD_NAME__CRS, count_window, &windows);
+	acpi_walk_resources(device->handle, METHOD_NAME__CRS, count_window, &windows);
 	controller->window = kmalloc(sizeof(*controller->window) * windows, GFP_KERNEL);
 	if (!controller->window)
 		goto out2;
@@ -307,10 +307,10 @@ pcibios_scan_root (void *handle, int seg
 	if (!name)
 		goto out3;
 
-	sprintf(name, "PCI Bus %02x:%02x", seg, bus);
+	sprintf(name, "PCI Bus %04x:%02x", domain, bus);
 	info.controller = controller;
 	info.name = name;
-	acpi_walk_resources(handle, METHOD_NAME__CRS, add_window, &info);
+	acpi_walk_resources(device->handle, METHOD_NAME__CRS, add_window, &info);
 
 	return scan_root_bus(bus, &pci_root_ops, controller);
 
Index: drivers/acpi/pci_root.c
=================================RCS file: /var/cvs/linux-2.5/drivers/acpi/pci_root.c,v
retrieving revision 1.8
diff -u -p -r1.8 pci_root.c
--- a/drivers/acpi/pci_root.c	23 Jun 2003 03:30:15 -0000	1.8
+++ b/drivers/acpi/pci_root.c	24 Jun 2003 21:16:50 -0000
@@ -246,8 +246,6 @@ acpi_pci_root_add (
 	switch (status) {
 	case AE_OK:
 		root->id.segment = (u16) value;
-		printk("_SEG exists! Unsupported. Abort.\n");
-		BUG();
 		break;
 	case AE_NOT_FOUND:
 		ACPI_DEBUG_PRINT((ACPI_DB_INFO, 
@@ -309,7 +306,7 @@ acpi_pci_root_add (
 	 * PCI namespace does not get created until this call is made (and 
 	 * thus the root bridge's pci_dev does not exist).
 	 */
-	root->bus = pcibios_scan_root(root->id.bus);
+	root->bus = pci_acpi_scan_root(device, root->id.segment, root->id.bus);
 	if (!root->bus) {
 		ACPI_DEBUG_PRINT((ACPI_DB_ERROR, 
 			"Bus %02x:%02x not present in PCI namespace\n", 
Index: include/acpi/acpi_drivers.h
=================================RCS file: /var/cvs/linux-2.5/include/acpi/acpi_drivers.h,v
retrieving revision 1.3
diff -u -p -r1.3 acpi_drivers.h
--- a/include/acpi/acpi_drivers.h	15 Feb 2003 03:48:35 -0000	1.3
+++ b/include/acpi/acpi_drivers.h	24 Jun 2003 21:16:55 -0000
@@ -73,6 +73,10 @@ struct pci_bus;
 int acpi_pci_bind (struct acpi_device *device);
 int acpi_pci_bind_root (struct acpi_device *device, struct acpi_pci_id *id, struct pci_bus *bus);
 
+/* Arch-defined function to add a bus to the system */
+
+struct pci_bus *pci_acpi_scan_root(struct acpi_device *device, int domain, int bus);
+
 #endif /*CONFIG_ACPI_PCI*/
 
 
Index: include/asm-ia64/pci.h
=================================RCS file: /var/cvs/linux-2.5/include/asm-ia64/pci.h,v
retrieving revision 1.9
diff -u -p -r1.9 pci.h
--- a/include/asm-ia64/pci.h	23 Jun 2003 03:30:47 -0000	1.9
+++ b/include/asm-ia64/pci.h	24 Jun 2003 21:16:56 -0000
@@ -21,7 +21,6 @@
 #define PCIBIOS_MIN_MEM		0x10000000
 
 void pcibios_config_init(void);
-struct pci_bus * pcibios_scan_root(void *acpi_handle, int segment, int bus);
 
 struct pci_dev;
 

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
