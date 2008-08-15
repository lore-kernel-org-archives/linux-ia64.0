From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 15 Aug 2008 22:37:48 +0000
Subject: [PATCH] ia64 pci_acpi_scan_root cleanup
Message-Id: <200808152237.m7FMbmFQ011273@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The code walks all the acpi _CRS methods to see how many windows
to allocate.  It then scans them all again to insert_resource()
for each *even if the first scan found that there were none*.

Move the second scan inside the "if (windows)" clause.

Signed-off-by: Tony Luck <tony.luck@intel.com>

---

Looks obvious ... but throwing this out for review just in
case I'm missing something subtle.  My tiger system does have
a root bus with no windows, so this isn't a no-op.

diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 77b15f8..7545037 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -324,7 +324,6 @@ pcibios_setup_root_windows(struct pci_bus *bus, struct pci_controller *ctrl)
 struct pci_bus * __devinit
 pci_acpi_scan_root(struct acpi_device *device, int domain, int bus)
 {
-	struct pci_root_info info;
 	struct pci_controller *controller;
 	unsigned int windows = 0;
 	struct pci_bus *pbus;
@@ -346,22 +345,24 @@ pci_acpi_scan_root(struct acpi_device *device, int domain, int bus)
 	acpi_walk_resources(device->handle, METHOD_NAME__CRS, count_window,
 			&windows);
 	if (windows) {
+		struct pci_root_info info;
+
 		controller->window  			kmalloc_node(sizeof(*controller->window) * windows,
 				     GFP_KERNEL, controller->node);
 		if (!controller->window)
 			goto out2;
-	}
 
-	name = kmalloc(16, GFP_KERNEL);
-	if (!name)
-		goto out3;
+		name = kmalloc(16, GFP_KERNEL);
+		if (!name)
+			goto out3;
 
-	sprintf(name, "PCI Bus %04x:%02x", domain, bus);
-	info.controller = controller;
-	info.name = name;
-	acpi_walk_resources(device->handle, METHOD_NAME__CRS, add_window,
-			&info);
+		sprintf(name, "PCI Bus %04x:%02x", domain, bus);
+		info.controller = controller;
+		info.name = name;
+		acpi_walk_resources(device->handle, METHOD_NAME__CRS,
+			add_window, &info);
+	}
 	/*
 	 * See arch/x86/pci/acpi.c.
 	 * The desired pci bus might already be scanned in a quirk. We
