From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 11 Mar 2010 19:20:06 +0000
Subject: [PATCH v4 1/2] ACPI: pci_root: save downstream bus range
Message-Id: <20100311192005.17859.70724.stgit@bob.kio>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100311191936.17859.3619.stgit@bob.kio>
In-Reply-To: <20100311191936.17859.3619.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Len Brown <lenb@kernel.org>
Cc: linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>


Previously, we only saved the root bus number, i.e., the beginning of the
downstream bus range.  We now support IORESOURCE_BUS resources, so this
patch uses that to keep track of both the beginning and the end of the
downstream bus range.

It's important to know both the beginning and the end for supporting _CBA
(see PCI Firmware spec, rev 3.0, sec 4.1.3) and so we know the limits for
any possible PCI bus renumbering (we can't renumber downstream buses to be
outside the bus number range claimed by the host bridge).

It's clear from the spec that the bus range is supposed to be in _CRS, but
if we don't find it there, we'll assume [_BBN - 0xFF] or [0 - 0xFF].

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
Reviewed-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
---

 drivers/acpi/pci_root.c |   67 ++++++++++++++++++++++++++++-------------------
 include/acpi/acpi_bus.h |    2 +
 2 files changed, 41 insertions(+), 28 deletions(-)


diff --git a/drivers/acpi/pci_root.c b/drivers/acpi/pci_root.c
index d724736..bf476fe 100644
--- a/drivers/acpi/pci_root.c
+++ b/drivers/acpi/pci_root.c
@@ -119,7 +119,8 @@ acpi_handle acpi_get_pci_rootbridge_handle(unsigned int seg, unsigned int bus)
 	struct acpi_pci_root *root;
 	
 	list_for_each_entry(root, &acpi_pci_roots, node)
-		if ((root->segment = (u16) seg) && (root->bus_nr = (u16) bus))
+		if ((root->segment = (u16) seg) &&
+		    (root->secondary.start = (u16) bus))
 			return root->device->handle;
 	return NULL;		
 }
@@ -153,7 +154,7 @@ EXPORT_SYMBOL_GPL(acpi_is_root_bridge);
 static acpi_status
 get_root_bridge_busnr_callback(struct acpi_resource *resource, void *data)
 {
-	int *busnr = data;
+	struct resource *res = data;
 	struct acpi_resource_address64 address;
 
 	if (resource->type != ACPI_RESOURCE_TYPE_ADDRESS16 &&
@@ -163,28 +164,27 @@ get_root_bridge_busnr_callback(struct acpi_resource *resource, void *data)
 
 	acpi_resource_to_address64(resource, &address);
 	if ((address.address_length > 0) &&
-	    (address.resource_type = ACPI_BUS_NUMBER_RANGE))
-		*busnr = address.minimum;
+	    (address.resource_type = ACPI_BUS_NUMBER_RANGE)) {
+		res->start = address.minimum;
+		res->end = address.minimum + address.address_length - 1;
+	}
 
 	return AE_OK;
 }
 
 static acpi_status try_get_root_bridge_busnr(acpi_handle handle,
-					     unsigned long long *bus)
+					     struct resource *res)
 {
 	acpi_status status;
-	int busnum;
 
-	busnum = -1;
+	res->start = -1;
 	status  	    acpi_walk_resources(handle, METHOD_NAME__CRS,
-				get_root_bridge_busnr_callback, &busnum);
+				get_root_bridge_busnr_callback, res);
 	if (ACPI_FAILURE(status))
 		return status;
-	/* Check if we really get a bus number from _CRS */
-	if (busnum = -1)
+	if (res->start = -1)
 		return AE_ERROR;
-	*bus = busnum;
 	return AE_OK;
 }
 
@@ -428,34 +428,47 @@ static int __devinit acpi_pci_root_add(struct acpi_device *device)
 	struct acpi_device *child;
 	u32 flags, base_flags;
 
+	root = kzalloc(sizeof(struct acpi_pci_root), GFP_KERNEL);
+	if (!root)
+		return -ENOMEM;
+
 	segment = 0;
 	status = acpi_evaluate_integer(device->handle, METHOD_NAME__SEG, NULL,
 				       &segment);
 	if (ACPI_FAILURE(status) && status != AE_NOT_FOUND) {
 		printk(KERN_ERR PREFIX "can't evaluate _SEG\n");
-		return -ENODEV;
+		result = -ENODEV;
+		goto end;
 	}
 
 	/* Check _CRS first, then _BBN.  If no _BBN, default to zero. */
-	bus = 0;
-	status = try_get_root_bridge_busnr(device->handle, &bus);
+	root->secondary.flags = IORESOURCE_BUS;
+	status = try_get_root_bridge_busnr(device->handle, &root->secondary);
 	if (ACPI_FAILURE(status)) {
+		/*
+		 * We need both the start and end of the downstream bus range
+		 * to interpret _CBA (MMCONFIG base address), so it really is
+		 * supposed to be in _CRS.  If we don't find it there, all we
+		 * can do is assume [_BBN-0xFF] or [0-0xFF].
+		 */
+		root->secondary.end = 0xFF;
+		printk(KERN_WARNING FW_BUG PREFIX
+		       "no secondary bus range in _CRS\n");
 		status = acpi_evaluate_integer(device->handle, METHOD_NAME__BBN,					       NULL, &bus);
-		if (ACPI_FAILURE(status) && status != AE_NOT_FOUND) {
-			printk(KERN_ERR PREFIX
-			     "no bus number in _CRS and can't evaluate _BBN\n");
-			return -ENODEV;
+		if (ACPI_SUCCESS(status))
+			root->secondary.start = bus;
+		else if (status = AE_NOT_FOUND)
+			root->secondary.start = 0;
+		else {
+			printk(KERN_ERR PREFIX "can't evaluate _BBN\n");
+			result = -ENODEV;
+			goto end;
 		}
 	}
 
-	root = kzalloc(sizeof(struct acpi_pci_root), GFP_KERNEL);
-	if (!root)
-		return -ENOMEM;
-
 	INIT_LIST_HEAD(&root->node);
 	root->device = device;
 	root->segment = segment & 0xFFFF;
-	root->bus_nr = bus & 0xFF;
 	strcpy(acpi_device_name(device), ACPI_PCI_ROOT_DEVICE_NAME);
 	strcpy(acpi_device_class(device), ACPI_PCI_ROOT_CLASS);
 	device->driver_data = root;
@@ -474,9 +487,9 @@ static int __devinit acpi_pci_root_add(struct acpi_device *device)
 	/* TBD: Locking */
 	list_add_tail(&root->node, &acpi_pci_roots);
 
-	printk(KERN_INFO PREFIX "%s [%s] (%04x:%02x)\n",
+	printk(KERN_INFO PREFIX "%s [%s] (domain %04x %pR)\n",
 	       acpi_device_name(device), acpi_device_bid(device),
-	       root->segment, root->bus_nr);
+	       root->segment, &root->secondary);
 
 	/*
 	 * Scan the Root Bridge
@@ -485,11 +498,11 @@ static int __devinit acpi_pci_root_add(struct acpi_device *device)
 	 * PCI namespace does not get created until this call is made (and 
 	 * thus the root bridge's pci_dev does not exist).
 	 */
-	root->bus = pci_acpi_scan_root(device, segment, bus);
+	root->bus = pci_acpi_scan_root(device, segment, root->secondary.start);
 	if (!root->bus) {
 		printk(KERN_ERR PREFIX
 			    "Bus %04x:%02x not present in PCI namespace\n",
-			    root->segment, root->bus_nr);
+			    root->segment, (unsigned int)root->secondary.start);
 		result = -ENODEV;
 		goto end;
 	}
diff --git a/include/acpi/acpi_bus.h b/include/acpi/acpi_bus.h
index 7bf83dd..baacd98 100644
--- a/include/acpi/acpi_bus.h
+++ b/include/acpi/acpi_bus.h
@@ -373,7 +373,7 @@ struct acpi_pci_root {
 	struct acpi_pci_id id;
 	struct pci_bus *bus;
 	u16 segment;
-	u8 bus_nr;
+	struct resource secondary;	/* downstream bus range */
 
 	u32 osc_support_set;	/* _OSC state of support bits */
 	u32 osc_control_set;	/* _OSC state of control bits */

