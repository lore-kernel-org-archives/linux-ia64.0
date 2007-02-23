From: John Keller <jpk@sgi.com>
Date: Fri, 23 Feb 2007 22:24:16 +0000
Subject: [PATCH 1/1] -  Altix: cannot register acpi bus driver before bus scan
Message-Id: <20070223222416.10849.61333.sendpatchset@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-acpi@vger.kernel.org
Cc: ayoung@sgi.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, John Keller <jpk@sgi.com>

SN code to initialize the Hub/TIO infrastructure needs to
execute before bus scanning. This is currently done by an
early call to acpi_bus_register_driver(). With the latest
ACPI changes to the driver model, a driver cannot be registered
this early. Make changes to have the init routines invoked via
calls to acpi_get_devices().

Signed-off-by: John Keller <jpk@sgi.com>
---

 arch/ia64/sn/kernel/io_acpi_init.c |   44 +++++++++++++--------------
 1 file changed, 22 insertions(+), 22 deletions(-)


Index: release/arch/ia64/sn/kernel/io_acpi_init.c
=================================--- release.orig/arch/ia64/sn/kernel/io_acpi_init.c	2007-02-23 15:21:21.070216119 -0600
+++ release/arch/ia64/sn/kernel/io_acpi_init.c	2007-02-23 15:22:04.255545247 -0600
@@ -53,12 +53,15 @@ sal_ioif_init(u64 *result)
 }
 
 /*
- * sn_hubdev_add - The 'add' function of the acpi_sn_hubdev_driver.
- *		   Called for every "SGIHUB" or "SGITIO" device defined
- *		   in the ACPI namespace.
+ * sn_acpi_hubdev_init() - This function is called by acpi_ns_get_device_callback()
+ *			   for all SGIHUB and SGITIO acpi devices defined in the
+ *			   DSDT. It obtains the hubdev_info pointer from the
+ *			   ACPI vendor resource, which the PROM setup, and sets up the
+ *			   hubdev_info in the pda.
  */
-static int __init
-sn_hubdev_add(struct acpi_device *device)
+
+static acpi_status __init
+sn_acpi_hubdev_init(acpi_handle handle, u32 depth, void *context, void **ret)
 {
 	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
 	u64 addr;
@@ -67,18 +70,19 @@ sn_hubdev_add(struct acpi_device *device
 	int i;
 	u64 nasid;
 	struct acpi_resource *resource;
-	int ret = 0;
 	acpi_status status;
 	struct acpi_resource_vendor_typed *vendor;
 	extern void sn_common_hubdev_init(struct hubdev_info *);
 
-	status = acpi_get_vendor_resource(device->handle, METHOD_NAME__CRS,
+	status = acpi_get_vendor_resource(handle, METHOD_NAME__CRS,
 					  &sn_uuid, &buffer);
 	if (ACPI_FAILURE(status)) {
 		printk(KERN_ERR
-		       "sn_hubdev_add: acpi_get_vendor_resource() failed: %d\n",
-		        status);
-		return 1;
+		       "sn_acpi_hubdev_init: acpi_get_vendor_resource() "
+		       "(0x%x) failed for: ", status);
+		acpi_ns_print_node_pathname(handle, NULL);
+		printk("\n");
+		return AE_OK;		/* Continue walking namespace */
 	}
 
 	resource = buffer.pointer;
@@ -86,9 +90,10 @@ sn_hubdev_add(struct acpi_device *device
 	if ((vendor->byte_length - sizeof(struct acpi_vendor_uuid)) ! 	    sizeof(struct hubdev_info *)) {
 		printk(KERN_ERR
-		       "sn_hubdev_add: Invalid vendor data length: %d\n",
+		       "sn_acpi_hubdev_init: Invalid vendor data length: %d for: ",
 		        vendor->byte_length);
-		ret = 1;
+		acpi_ns_print_node_pathname(handle, NULL);
+		printk("\n");
 		goto exit;
 	}
 
@@ -103,7 +108,7 @@ sn_hubdev_add(struct acpi_device *device
 
 exit:
 	kfree(buffer.pointer);
-	return ret;
+	return AE_OK;		/* Continue walking namespace */
 }
 
 /*
@@ -441,14 +446,6 @@ sn_acpi_slot_fixup(struct pci_dev *dev)
 
 EXPORT_SYMBOL(sn_acpi_slot_fixup);
 
-static struct acpi_driver acpi_sn_hubdev_driver = {
-	.name = "SGI HUBDEV Driver",
-	.ids = "SGIHUB,SGITIO",
-	.ops = {
-		.add = sn_hubdev_add,
-		},
-};
-
 
 /*
  * sn_acpi_bus_fixup -  Perform SN specific setup of software structs
@@ -492,7 +489,10 @@ sn_io_acpi_init(void)
 	/* SN Altix does not follow the IOSAPIC IRQ routing model */
 	acpi_irq_model = ACPI_IRQ_MODEL_PLATFORM;
 
-	acpi_bus_register_driver(&acpi_sn_hubdev_driver);
+	/* Setup hubdev_info for all SGIHUB/SGITIO devices */
+	acpi_get_devices("SGIHUB", sn_acpi_hubdev_init, NULL, NULL);
+	acpi_get_devices("SGITIO", sn_acpi_hubdev_init, NULL, NULL);
+
 	status = sal_ioif_init(&result);
 	if (status || result)
 		panic("sal_ioif_init failed: [%lx] %s\n",
