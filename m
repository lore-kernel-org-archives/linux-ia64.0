From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 16 Sep 2005 17:41:16 +0000
Subject: [PATCH] ACPI: implement UUID-labelled vendor-defined resources
Message-Id: <200509161141.16206.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Len Brown <len.brown@intel.com>
Cc: Alex Williamson <alex.williamson@hp.com>, acpi-devel@lists.sourceforge.net, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

ACPI 3.0 includes UUID-labelled vendor-defined resources (section 6.4.3.2),
so move the code that supports this from arch/ia64 into ACPI proper.

Len, Tony, this touches both acpi and ia64.  Probably easiest
if Tony acks it and Len decides whether to apply it.

HP owns all the copyrights on the code being moved, and we agree
that the code being moved into the ACPI CA may be used under either
the GPL or the BSD-style license used by the ACPI CA.

(There should be something in Documentation/acpi about how to
contribute to the ACPI CA.  It's a royal pain in the rear :-)).

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

=== arch/ia64/kernel/acpi-ext.c 1.5 vs edited ==Index: work-vga2/arch/ia64/kernel/acpi-ext.c
=================================--- work-vga2.orig/arch/ia64/kernel/acpi-ext.c	2005-09-14 09:28:07.000000000 -0600
+++ work-vga2/arch/ia64/kernel/acpi-ext.c	2005-09-15 14:52:33.000000000 -0600
@@ -1,105 +1,45 @@
 /*
- * arch/ia64/kernel/acpi-ext.c
+ * Vendor specific extensions to ACPI.
  *
- * Copyright (C) 2003 Hewlett-Packard
+ * (c) Copyright 2003, 2005 Hewlett-Packard Development Company, L.P.
  * Copyright (C) Alex Williamson
  * Copyright (C) Bjorn Helgaas
- *
- * Vendor specific extensions to ACPI.
  */
 
 #include <linux/config.h>
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/acpi.h>
-#include <linux/efi.h>
 
 #include <asm/acpi-ext.h>
 
-struct acpi_vendor_descriptor {
-	u8 guid_id;
-	efi_guid_t guid;
-};
-
-struct acpi_vendor_info {
-	struct acpi_vendor_descriptor *descriptor;
-	u8 *data;
-	u32 length;
-};
-
-acpi_status
-acpi_vendor_resource_match(struct acpi_resource *resource, void *context)
-{
-	struct acpi_vendor_info *info = (struct acpi_vendor_info *)context;
-	struct acpi_resource_vendor *vendor;
-	struct acpi_vendor_descriptor *descriptor;
-	u32 length;
-
-	if (resource->id != ACPI_RSTYPE_VENDOR)
-		return AE_OK;
-
-	vendor = (struct acpi_resource_vendor *)&resource->data;
-	descriptor = (struct acpi_vendor_descriptor *)vendor->reserved;
-	if (vendor->length <= sizeof(*info->descriptor) ||
-	    descriptor->guid_id != info->descriptor->guid_id ||
-	    efi_guidcmp(descriptor->guid, info->descriptor->guid))
-		return AE_OK;
-
-	length = vendor->length - sizeof(struct acpi_vendor_descriptor);
-	info->data = acpi_os_allocate(length);
-	if (!info->data)
-		return AE_NO_MEMORY;
-
-	memcpy(info->data,
-	       vendor->reserved + sizeof(struct acpi_vendor_descriptor),
-	       length);
-	info->length = length;
-	return AE_CTRL_TERMINATE;
-}
-
-acpi_status
-acpi_find_vendor_resource(acpi_handle obj, struct acpi_vendor_descriptor * id,
-			  u8 ** data, u32 * length)
-{
-	struct acpi_vendor_info info;
-
-	info.descriptor = id;
-	info.data = NULL;
-
-	acpi_walk_resources(obj, METHOD_NAME__CRS, acpi_vendor_resource_match,
-			    &info);
-	if (!info.data)
-		return AE_NOT_FOUND;
-
-	*data = info.data;
-	*length = info.length;
-	return AE_OK;
-}
 
 struct acpi_vendor_descriptor hp_ccsr_descriptor = {
-	.guid_id = 2,
-	.guid -	    EFI_GUID(0x69e9adf9, 0x924f, 0xab5f, 0xf6, 0x4a, 0x24, 0xd2, 0x01,
-		     0x37, 0x0e, 0xad)
+	.uuid_subtype = 2,
+	.uuid = ACPI_UUID(0x69e9adf9, 0x924f, 0xab5f, 0xf6, 0x4a, 0x24, 0xd2,
+			  0x01, 0x37, 0x0e, 0xad)
 };
 
 acpi_status hp_acpi_csr_space(acpi_handle obj, u64 * csr_base, u64 * csr_length)
 {
-	acpi_status status;
-	u8 *data;
+	acpi_status status = AE_OK;
+	u8 *data = NULL;
 	u32 length;
 
-	status -	    acpi_find_vendor_resource(obj, &hp_ccsr_descriptor, &data, &length);
+	status = acpi_find_vendor_resource(obj, &hp_ccsr_descriptor, &data,
+		&length);
 
-	if (ACPI_FAILURE(status) || length != 16)
-		return AE_NOT_FOUND;
+	if (ACPI_FAILURE(status) || length != 16) {
+		status = AE_NOT_FOUND;
+		goto out;
+	}
 
 	memcpy(csr_base, data, sizeof(*csr_base));
 	memcpy(csr_length, data + 8, sizeof(*csr_length));
-	acpi_os_free(data);
 
-	return AE_OK;
+ out:
+	acpi_os_free(data);
+	return status;
 }
 
 EXPORT_SYMBOL(hp_acpi_csr_space);
Index: work-vga2/drivers/acpi/resources/rsxface.c
=================================--- work-vga2.orig/drivers/acpi/resources/rsxface.c	2005-09-14 09:28:10.000000000 -0600
+++ work-vga2/drivers/acpi/resources/rsxface.c	2005-09-15 14:29:02.000000000 -0600
@@ -410,3 +410,90 @@
 }
 
 EXPORT_SYMBOL(acpi_resource_to_address64);
+
+static inline int
+acpi_uuidcmp (struct acpi_uuid left, struct acpi_uuid right)
+{
+	return memcmp(&left, &right, sizeof(left));
+}
+
+static acpi_status
+acpi_vendor_resource_match(struct acpi_resource *resource, void *context)
+{
+	struct acpi_vendor_info *info = (struct acpi_vendor_info *) context;
+	struct acpi_resource_vendor *vendor;
+	struct acpi_vendor_descriptor *descriptor;
+	u32 length;
+
+	if (resource->id != ACPI_RSTYPE_VENDOR)
+		return AE_OK;
+
+	vendor = (struct acpi_resource_vendor *) &resource->data;
+	descriptor = (struct acpi_vendor_descriptor *) vendor->reserved;
+	if (vendor->length <= sizeof(*info->descriptor) ||
+	    descriptor->uuid_subtype != info->descriptor->uuid_subtype ||
+	    acpi_uuidcmp(descriptor->uuid, info->descriptor->uuid))
+		return AE_OK;
+
+	length = vendor->length - sizeof(struct acpi_vendor_descriptor);
+	info->data = acpi_os_allocate(length);
+	if (!info->data)
+		return AE_NO_MEMORY;
+
+	memcpy(info->data, vendor->reserved +
+		sizeof(struct acpi_vendor_descriptor), length);
+	info->length = length;
+	return AE_CTRL_TERMINATE;
+}
+
+/*******************************************************************************
+ *
+ * FUNCTION:    acpi_find_vendor_resource
+ *
+ * PARAMETERS:  device_handle   - a handle to the device object for the
+ *                                device we are querying
+ *              id              - a pointer to the acpi_vendor_descriptor
+ *                                for the UUID-identified vendor-defined
+ *                                resource we want
+ *              data            - a pointer to a pointer where the address
+ *                                of the vendor data will be stored
+ *              length          - a pointer to an integer where the length
+ *                                of the vendor data will be stored
+ *
+ * RETURN:      Status
+ *
+ * DESCRIPTION: This function walks the current resources for the specified
+ *              device and looks for a vendor-defined resource that matches
+ *              the supplied UUID and subtype.
+ *
+ *              If the desired resource is found, a buffer is allocated for
+ *              the vendor-defined data (excluding the UUID and other headers),
+ *              and the address and size of the buffer are returned in *data
+ *              and *length.  The caller is responsible for deallocating
+ *              the buffer with acpi_os_free().
+ *
+ *              If the function fails, AE_NOT_FOUND will be returned and
+ *              the values of *data and *length are unchanged.
+ *
+ ******************************************************************************/
+
+acpi_status
+acpi_find_vendor_resource(acpi_handle device_handle,
+	struct acpi_vendor_descriptor *id, u8 **data, u32 *length)
+{
+	struct acpi_vendor_info info;
+
+	info.descriptor = id;
+	info.data = NULL;
+
+	acpi_walk_resources(device_handle, METHOD_NAME__CRS,
+		acpi_vendor_resource_match, &info);
+	if (!info.data)
+		return AE_NOT_FOUND;
+
+	*data = info.data;
+	*length = info.length;
+	return AE_OK;
+}
+
+EXPORT_SYMBOL(acpi_find_vendor_resource);
Index: work-vga2/include/acpi/acpixf.h
=================================--- work-vga2.orig/include/acpi/acpixf.h	2005-09-14 09:29:10.000000000 -0600
+++ work-vga2/include/acpi/acpixf.h	2005-09-15 14:30:59.000000000 -0600
@@ -295,6 +295,11 @@
 acpi_resource_to_address64(struct acpi_resource *resource,
 			   struct acpi_resource_address64 *out);
 
+acpi_status
+acpi_find_vendor_resource (acpi_handle device_handle,
+			   struct acpi_vendor_descriptor *id,
+			   u8 **data, u32 *length);
+
 /*
  * Hardware (ACPI device) interfaces
  */
Index: work-vga2/include/acpi/actypes.h
=================================--- work-vga2.orig/include/acpi/actypes.h	2005-09-14 09:29:11.000000000 -0600
+++ work-vga2/include/acpi/actypes.h	2005-09-15 14:33:06.000000000 -0600
@@ -974,6 +974,17 @@
 #define ACPI_PRODUCER                   (u8) 0x00
 #define ACPI_CONSUMER                   (u8) 0x01
 
+struct acpi_uuid {
+	u8                              b[16];
+};
+
+#define ACPI_UUID(a,b,c,d0,d1,d2,d3,d4,d5,d6,d7) \
+    ((struct acpi_uuid) \
+    {{ (a) & 0xff, ((a) >> 8) & 0xff, ((a) >> 16) & 0xff, ((a) >> 24) & 0xff, \
+      (b) & 0xff, ((b) >> 8) & 0xff, \
+      (c) & 0xff, ((c) >> 8) & 0xff, \
+      (d0), (d1), (d2), (d3), (d4), (d5), (d6), (d7) }})
+
 /*
  *  Structures used to describe device resources
  */
@@ -1021,6 +1032,18 @@
 	u8 reserved[1];
 };
 
+struct acpi_vendor_descriptor
+{
+	u8 uuid_subtype;
+	struct acpi_uuid uuid;
+};
+
+struct acpi_vendor_info {
+	struct acpi_vendor_descriptor *descriptor;
+	u8 *data;
+	u32 length;
+};
+
 struct acpi_resource_end_tag {
 	u8 checksum;
 };
