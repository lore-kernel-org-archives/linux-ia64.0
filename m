From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 18 Mar 2005 20:19:50 +0000
Subject: [PATCH] ACPI: implement UUID-labelled vendor-defined resources
Message-Id: <1111177190.13286.48.camel@eeyore>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ACPI List <acpi-devel@lists.sourceforge.net>, linux-ia64 <linux-ia64@vger.kernel.org>

ACPI 3.0 includes UUID-labelled vendor-defined resources (section 6.4.3.2),
so move the code that supports this from arch/ia64 into ACPI proper.

When the code was under arch/ia64, we used EFI GUID stuff, but this time I
defined acpi_uuid equivalents to avoid the need to depend on EFI.

Len, Tony, this touches both acpi and ia64.  Let me know if this is
a problem.

This patch may be used under either the GPL or the BSD license.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

=== arch/ia64/kernel/acpi-ext.c 1.5 vs edited ==--- 1.5/arch/ia64/kernel/acpi-ext.c	2004-10-05 12:19:50 -06:00
+++ edited/arch/ia64/kernel/acpi-ext.c	2005-03-18 11:29:18 -07:00
@@ -12,89 +12,35 @@
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/acpi.h>
-#include <linux/efi.h>
 
 #include <asm/acpi-ext.h>
 
-struct acpi_vendor_descriptor {
-	u8				guid_id;
-	efi_guid_t			guid;
-};
-
-struct acpi_vendor_info {
-	struct acpi_vendor_descriptor	*descriptor;
-	u8				*data;
-	u32				length;
-};
-
-acpi_status
-acpi_vendor_resource_match(struct acpi_resource *resource, void *context)
-{
-	struct acpi_vendor_info *info = (struct acpi_vendor_info *) context;
-	struct acpi_resource_vendor *vendor;
-	struct acpi_vendor_descriptor *descriptor;
-	u32 length;
-
-	if (resource->id != ACPI_RSTYPE_VENDOR)
-		return AE_OK;
-
-	vendor = (struct acpi_resource_vendor *) &resource->data;
-	descriptor = (struct acpi_vendor_descriptor *) vendor->reserved;
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
-	memcpy(info->data, vendor->reserved + sizeof(struct acpi_vendor_descriptor), length);
-	info->length = length;
-	return AE_CTRL_TERMINATE;
-}
-
-acpi_status
-acpi_find_vendor_resource(acpi_handle obj, struct acpi_vendor_descriptor *id,
-		u8 **data, u32 *length)
-{
-	struct acpi_vendor_info info;
-
-	info.descriptor = id;
-	info.data = NULL;
-
-	acpi_walk_resources(obj, METHOD_NAME__CRS, acpi_vendor_resource_match, &info);
-	if (!info.data)
-		return AE_NOT_FOUND;
-
-	*data = info.data;
-	*length = info.length;
-	return AE_OK;
-}
-
 struct acpi_vendor_descriptor hp_ccsr_descriptor = {
-	.guid_id = 2,
-	.guid    = EFI_GUID(0x69e9adf9, 0x924f, 0xab5f, 0xf6, 0x4a, 0x24, 0xd2, 0x01, 0x37, 0x0e, 0xad)
+	.uuid_subtype = 2,
+	.uuid    = ACPI_UUID(0x69e9adf9, 0x924f, 0xab5f, 0xf6, 0x4a, 0x24, 0xd2, 0x01, 0x37, 0x0e, 0xad)
 };
 
 acpi_status
 hp_acpi_csr_space(acpi_handle obj, u64 *csr_base, u64 *csr_length)
 {
-	acpi_status status;
-	u8 *data;
+	acpi_status status = AE_OK;
+	u8 *data = NULL;
 	u32 length;
 
-	status = acpi_find_vendor_resource(obj, &hp_ccsr_descriptor, &data, &length);
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
+out:
+	acpi_os_free(data);
+	return status;
 }
 
 EXPORT_SYMBOL(hp_acpi_csr_space);
=== drivers/acpi/resources/rsxface.c 1.22 vs edited ==--- 1.22/drivers/acpi/resources/rsxface.c	2005-01-20 22:17:54 -07:00
+++ edited/drivers/acpi/resources/rsxface.c	2005-03-18 12:24:34 -07:00
@@ -435,3 +435,90 @@
 }
 EXPORT_SYMBOL(acpi_resource_to_address64);
 
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
+	memcpy(info->data, vendor->reserved + sizeof(struct acpi_vendor_descriptor), length);
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
+acpi_find_vendor_resource(
+	acpi_handle			device_handle,
+	struct acpi_vendor_descriptor	*id,
+	u8				**data,
+	u32				*length)
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
+EXPORT_SYMBOL(acpi_find_vendor_resource);
=== include/acpi/acpixf.h 1.31 vs edited ==--- 1.31/include/acpi/acpixf.h	2005-01-20 22:17:55 -07:00
+++ edited/include/acpi/acpixf.h	2005-03-18 12:09:12 -07:00
@@ -425,10 +425,10 @@
 
 acpi_status
 acpi_walk_resources (
-	acpi_handle                             device_handle,
-	char                                    *path,
+	acpi_handle                     device_handle,
+	char                            *path,
 	ACPI_WALK_RESOURCE_CALLBACK     user_function,
-	void                                    *context);
+	void                            *context);
 
 acpi_status
 acpi_set_current_resources (
@@ -443,7 +443,14 @@
 acpi_status
 acpi_resource_to_address64 (
 	struct acpi_resource            *resource,
-	struct acpi_resource_address64 *out);
+	struct acpi_resource_address64  *out);
+
+acpi_status
+acpi_find_vendor_resource (
+	acpi_handle                     device_handle,
+	struct acpi_vendor_descriptor   *id,
+	u8                              **data,
+	u32                             *length);
 
 /*
  * Hardware (ACPI device) interfaces
=== include/acpi/actypes.h 1.41 vs edited ==--- 1.41/include/acpi/actypes.h	2005-01-20 22:17:55 -07:00
+++ edited/include/acpi/actypes.h	2005-03-18 11:23:21 -07:00
@@ -1045,6 +1045,16 @@
 #define ACPI_PRODUCER                   (u8) 0x00
 #define ACPI_CONSUMER                   (u8) 0x01
 
+struct acpi_uuid {
+	u8                              b[16];
+};
+
+#define ACPI_UUID(a,b,c,d0,d1,d2,d3,d4,d5,d6,d7) \
+((struct acpi_uuid) \
+{{ (a) & 0xff, ((a) >> 8) & 0xff, ((a) >> 16) & 0xff, ((a) >> 24) & 0xff, \
+  (b) & 0xff, ((b) >> 8) & 0xff, \
+  (c) & 0xff, ((c) >> 8) & 0xff, \
+  (d0), (d1), (d2), (d3), (d4), (d5), (d6), (d7) }})
 
 /*
  *  Structures used to describe device resources
@@ -1097,6 +1107,18 @@
 {
 	u32                                 length;
 	u8                                  reserved[1];
+};
+
+struct acpi_vendor_descriptor
+{
+	u8                                  uuid_subtype;
+	struct acpi_uuid                    uuid;
+};
+
+struct acpi_vendor_info {
+	struct acpi_vendor_descriptor       *descriptor;
+	u8                                  *data;
+	u32                                 length;
 };
 
 struct acpi_resource_end_tag


