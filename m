From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 23 Sep 2005 17:39:07 +0000
Subject: [PATCH] ia64: respect ACPI producer/consumer flag for PCI root bridges
Message-Id: <200509231139.07720.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org, acpi-devel@lists.sourceforge.net

Address space resources for ACPI devices have a producer/consumer
flag.  All devices "consume" the indicated address space.  If the
resource is marked as a "producer", the range is also passed on
to child devices.

We currently ignore this flag when setting up MMIO and I/O port
windows for PCI root bridges, so we could mistakenly interpret
a "consumed-only" range, like CSR space for the device itself,
as a window that is routed to children.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work-vga2/arch/ia64/pci/pci.c
=================================--- work-vga2.orig/arch/ia64/pci/pci.c	2005-09-23 10:11:45.000000000 -0600
+++ work-vga2/arch/ia64/pci/pci.c	2005-09-23 10:15:56.000000000 -0600
@@ -168,6 +168,29 @@
 	return IO_SPACE_BASE(i);
 }
 
+static acpi_status __devinit resource_to_window(struct acpi_resource *resource,
+	struct acpi_resource_address64 *addr)
+{
+	acpi_status status;
+
+	/*
+	 * We're only interested in _CRS descriptors that are
+	 *	- address space descriptors for memory or I/O space
+	 *	- non-zero size
+	 *	- producers, i.e., the address space is routed downstream,
+	 *	  not consumed by the bridge itself
+	 */
+	status = acpi_resource_to_address64(resource, addr);
+	if (ACPI_SUCCESS(status) &&
+	    (addr->resource_type = ACPI_MEMORY_RANGE ||
+	     addr->resource_type = ACPI_IO_RANGE) &&
+	    addr->address_length &&
+	    addr->producer_consumer = ACPI_PRODUCER)
+		return AE_OK;
+
+	return AE_ERROR;
+}
+
 static acpi_status __devinit
 count_window (struct acpi_resource *resource, void *data)
 {
@@ -175,11 +198,9 @@
 	struct acpi_resource_address64 addr;
 	acpi_status status;
 
-	status = acpi_resource_to_address64(resource, &addr);
+	status = resource_to_window(resource, &addr);
 	if (ACPI_SUCCESS(status))
-		if (addr.resource_type = ACPI_MEMORY_RANGE ||
-		    addr.resource_type = ACPI_IO_RANGE)
-			(*windows)++;
+		(*windows)++;
 
 	return AE_OK;
 }
@@ -198,13 +219,11 @@
 	unsigned long flags, offset = 0;
 	struct resource *root;
 
-	status = acpi_resource_to_address64(res, &addr);
+	/* Return AE_OK for non-window resources to keep scanning for more */
+	status = resource_to_window(res, &addr);
 	if (!ACPI_SUCCESS(status))
 		return AE_OK;
 
-	if (!addr.address_length)
-		return AE_OK;
-
 	if (addr.resource_type = ACPI_MEMORY_RANGE) {
 		flags = IORESOURCE_MEM;
 		root = &iomem_resource;
