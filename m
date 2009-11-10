From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 10 Nov 2009 17:11:33 +0000
Subject: [PATCH v2 1/3] ACPI: pci_root: show entire downstream bus range
Message-Id: <20091110171133.10645.95957.stgit@bob.kio>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091110170802.10645.91272.stgit@bob.kio>
In-Reply-To: <20091110170802.10645.91272.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Len Brown <lenb@kernel.org>
Cc: linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-pci@vger.kernel.org

Previously, we only printed the immediately downstream bus number, but a
host bridge claims a range of bus numbers.  _CRS tells us the range, and
it helps understand the system topology, so let's show it.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
---
 drivers/acpi/pci_root.c |   33 ++++++++++++++++++---------------
 1 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/drivers/acpi/pci_root.c b/drivers/acpi/pci_root.c
index 1af8081..aa9eeee 100644
--- a/drivers/acpi/pci_root.c
+++ b/drivers/acpi/pci_root.c
@@ -152,7 +152,7 @@ EXPORT_SYMBOL_GPL(acpi_is_root_bridge);
 static acpi_status
 get_root_bridge_busnr_callback(struct acpi_resource *resource, void *data)
 {
-	int *busnr = data;
+	struct resource *res = data;
 	struct acpi_resource_address64 address;
 
 	if (resource->type != ACPI_RESOURCE_TYPE_ADDRESS16 &&
@@ -162,28 +162,27 @@ get_root_bridge_busnr_callback(struct acpi_resource *resource, void *data)
 
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
 
@@ -474,6 +473,7 @@ static int __devinit acpi_pci_root_add(struct acpi_device *device)
 	acpi_handle handle;
 	struct acpi_device *child;
 	u32 flags, base_flags;
+	struct resource secondary;
 
 	segment = 0;
 	status = acpi_evaluate_integer(device->handle, METHOD_NAME__SEG, NULL,
@@ -484,9 +484,11 @@ static int __devinit acpi_pci_root_add(struct acpi_device *device)
 	}
 
 	/* Check _CRS first, then _BBN.  If no _BBN, default to zero. */
-	bus = 0;
-	status = try_get_root_bridge_busnr(device->handle, &bus);
-	if (ACPI_FAILURE(status)) {
+	secondary.start = 0;
+	status = try_get_root_bridge_busnr(device->handle, &secondary);
+	if (ACPI_SUCCESS(status)) {
+		bus = secondary.start;
+	} else {
 		status = acpi_evaluate_integer(device->handle, METHOD_NAME__BBN,					       NULL, &bus);
 		if (ACPI_FAILURE(status) && status != AE_NOT_FOUND) {
 			printk(KERN_ERR PREFIX
@@ -521,9 +523,10 @@ static int __devinit acpi_pci_root_add(struct acpi_device *device)
 	/* TBD: Locking */
 	list_add_tail(&root->node, &acpi_pci_roots);
 
-	printk(KERN_INFO PREFIX "%s [%s] (%04x:%02x)\n",
+	printk(KERN_INFO PREFIX "%s [%s] (domain %04x [bus %02x-%02x])\n",
 	       acpi_device_name(device), acpi_device_bid(device),
-	       root->segment, root->bus_nr);
+	       root->segment,
+	       (unsigned int) secondary.start, (unsigned int) secondary.end);
 
 	/*
 	 * Scan the Root Bridge

