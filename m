From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 14 Aug 2003 21:42:51 +0000
Subject: [PATCH] GUID-identified vendor data resources
Message-Id: <marc-linux-ia64-106089762113972@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's a patch to add support for vendor data resources identified
by GUIDs.

The idea is to add a GUID and a subtype to the data in a vendor-
defined resource, so we can tell what sort of data the resource
contains.

HP ships firmware that uses this and is working to formally
incorporate this into the spec.  Unfortunately I don't think
there's a public document describing it yet, but it's pretty
trivial.  It just adds a header:

+struct acpi_vendor_descriptor {
+	u8				guid_id;
+	efi_guid_t			guid;
+};

at the beginning of the vendor-defined data area, and the
payload data starts after the header.

This applies to the current ACPI in both 2.4 and 2.5.  There
don't seem to be any prior references to GUIDs in ACPI, and
I'm not sure how to cleanly integrate it.  For now I just added
the "#include <linux/efi.h>" in aclinux.h, but I'm open to
suggestions.

Bjorn


--- 1.16/drivers/acpi/resources/rsxface.c	Thu Apr 24 12:22:45 2003
+++ edited/drivers/acpi/resources/rsxface.c	Thu Aug 14 16:12:49 2003
@@ -410,3 +410,100 @@
 
 	return (AE_OK);
 }
+
+struct acpi_vendor_info {
+	struct acpi_vendor_descriptor	*descriptor;
+	int				found;
+	u8				*data;
+	u32				length;
+};
+
+static acpi_status
+acpi_vendor_resource_match (
+	struct acpi_resource		*resource,
+	void				*context)
+{
+	struct acpi_vendor_info		*info = (struct acpi_vendor_info *) context;
+	struct acpi_resource_vendor	*vendor;
+	struct acpi_vendor_descriptor	*descriptor;
+
+	if (resource->id != ACPI_RSTYPE_VENDOR)
+		return AE_OK;
+
+	vendor = (struct acpi_resource_vendor *) &resource->data;
+	descriptor = (struct acpi_vendor_descriptor *) vendor->reserved;
+	if (vendor->length < sizeof(struct acpi_vendor_descriptor) ||
+	    descriptor->guid_id != info->descriptor->guid_id ||
+	    efi_guidcmp(descriptor->guid, info->descriptor->guid))
+		return AE_OK;
+
+	info->found = 1;
+	info->length = vendor->length - sizeof(struct acpi_vendor_descriptor);
+	if (!info->length)
+		return AE_CTRL_TERMINATE;	/* descriptor, but no payload */
+
+	info->data = acpi_os_allocate(info->length);
+	if (!info->data)
+		return AE_NO_MEMORY;
+
+	memcpy(info->data, vendor->reserved + sizeof(struct acpi_vendor_descriptor), info->length);
+	return AE_CTRL_TERMINATE;
+}
+
+
+/*******************************************************************************
+ *
+ * FUNCTION:    acpi_find_vendor_resource
+ *
+ * PARAMETERS:  device_handle   - a handle to the device object for the
+ *                                device we are querying
+ *              id		- a pointer to descriptor for desired
+ *				  vendor resource
+ *              data		- (out) a pointer to a pointer where payload
+ *                                data is returned
+ *              length		- (out) a pointer to the length of payload
+ *				  data
+ *
+ * RETURN:      Status
+ *
+ * DESCRIPTION: This function evaluates the object's _CRS method and
+ *		searches the result for a large vendor-defined resource
+ *		identified by the supplied GUID and subtype.  If such
+ *		a resource is found, a pointer to the payload data is
+ *		returned, along with the length of the payload data.
+ *
+ *		The caller is responsible for deallocating the buffer
+ *		returned in "data" with acpi_os_free().
+ *
+ *		If the function fails, "data" and "length" are
+ *		unchanged.
+ *
+ ******************************************************************************/
+
+acpi_status
+acpi_find_vendor_resource (
+	acpi_handle			device_handle,
+	struct acpi_vendor_descriptor	*id,
+	u8				**data,
+	u32				*length)
+{
+	struct acpi_vendor_info		info;
+	acpi_status			status;
+
+
+	ACPI_FUNCTION_TRACE ("acpi_find_vendor_resource");
+
+
+	info.descriptor = id;
+	info.found = 0;
+	info.data = 0;
+
+	status = acpi_walk_resources(device_handle, METHOD_NAME__CRS,
+		acpi_vendor_resource_match, &info);
+	if (ACPI_FAILURE(status) || !info.found)
+		return_ACPI_STATUS (AE_NOT_FOUND);
+
+	*data = info.data;
+	*length = info.length;
+	return_ACPI_STATUS (AE_OK);
+}
--- 1.23/include/acpi/acpixf.h	Fri May 23 17:01:52 2003
+++ edited/include/acpi/acpixf.h	Thu Aug 14 16:12:49 2003
@@ -412,6 +412,18 @@
 	struct acpi_resource            *resource,
 	struct acpi_resource_address64 *out);
 
+struct acpi_vendor_descriptor {
+	u8				guid_id;
+	efi_guid_t			guid;
+};
+
+acpi_status
+acpi_find_vendor_resource (
+	acpi_handle			obj,
+	struct acpi_vendor_descriptor	*id,
+	u8				**data,
+	u32				*length);
+
 /*
  * Hardware (ACPI device) interfaces
  */
--- 1.20/include/acpi/platform/aclinux.h	Tue Feb 18 16:32:35 2003
+++ edited/include/acpi/platform/aclinux.h	Thu Aug 14 16:12:49 2003
@@ -52,6 +52,7 @@
 #ifdef __KERNEL__
 
 #include <linux/config.h>
+#include <linux/efi.h>
 #include <linux/string.h>
 #include <linux/kernel.h>
 #include <linux/ctype.h>

