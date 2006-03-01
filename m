From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 01 Mar 2006 23:57:55 +0000
Subject: [PATCH] ia64: update HP CSR space discovery via ACPI
Message-Id: <200603011657.55501.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[This is post-2.6.16 material]

Get rid of the manual search of _CRS, in favor of acpi_get_vendor_resource()
which is now provided by the ACPI CA.  And fall back to searching for a
consumer-only address space descriptor if no vendor-defined resource is found.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work-mm4/arch/ia64/kernel/acpi-ext.c
=================================--- work-mm4.orig/arch/ia64/kernel/acpi-ext.c	2006-02-01 16:24:45.000000000 -0700
+++ work-mm4/arch/ia64/kernel/acpi-ext.c	2006-02-22 09:27:53.000000000 -0700
@@ -1,105 +1,104 @@
 /*
- * arch/ia64/kernel/acpi-ext.c
+ * (c) Copyright 2003, 2006 Hewlett-Packard Development Company, L.P.
+ *	Alex Williamson <alex.williamson@hp.com>
+ *	Bjorn Helgaas <bjorn.helgaas@hp.com>
  *
- * Copyright (C) 2003 Hewlett-Packard
- * Copyright (C) Alex Williamson
- * Copyright (C) Bjorn Helgaas
- *
- * Vendor specific extensions to ACPI.
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
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
+/*
+ * Device CSRs that do not appear in PCI config space should be described
+ * via ACPI.  This would normally be done with Address Space Descriptors
+ * marked as "consumer-only," but old versions of Windows and Linux ignore
+ * the producer/consumer flag, so HP invented a vendor-defined resource to
+ * describe the location and size of CSR space.
+ */
 
-struct acpi_vendor_info {
-	struct acpi_vendor_descriptor *descriptor;
-	u8 *data;
-	u32 length;
+struct acpi_vendor_uuid hp_ccsr_uuid = {
+	.subtype = 2,
+	.data = { 0xf9, 0xad, 0xe9, 0x69, 0x4f, 0x92, 0x5f, 0xab, 0xf6, 0x4a,
+	    0x24, 0xd2, 0x01, 0x37, 0x0e, 0xad },
 };
 
-acpi_status
-acpi_vendor_resource_match(struct acpi_resource *resource, void *context)
+static acpi_status hp_ccsr_locate(acpi_handle obj, u64 *base, u64 *length)
 {
-	struct acpi_vendor_info *info = (struct acpi_vendor_info *)context;
-	struct acpi_resource_vendor *vendor;
-	struct acpi_vendor_descriptor *descriptor;
-	u32 byte_length;
-
-	if (resource->type != ACPI_RESOURCE_TYPE_VENDOR)
-		return AE_OK;
-
-	vendor = (struct acpi_resource_vendor *)&resource->data;
-	descriptor = (struct acpi_vendor_descriptor *)vendor->byte_data;
-	if (vendor->byte_length <= sizeof(*info->descriptor) ||
-	    descriptor->guid_id != info->descriptor->guid_id ||
-	    efi_guidcmp(descriptor->guid, info->descriptor->guid))
-		return AE_OK;
-
-	byte_length = vendor->byte_length - sizeof(struct acpi_vendor_descriptor);
-	info->data = acpi_os_allocate(byte_length);
-	if (!info->data)
-		return AE_NO_MEMORY;
-
-	memcpy(info->data,
-	       vendor->byte_data + sizeof(struct acpi_vendor_descriptor),
-	       byte_length);
-	info->length = byte_length;
-	return AE_CTRL_TERMINATE;
+	acpi_status status;
+	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
+	struct acpi_resource *resource;
+	struct acpi_resource_vendor_typed *vendor;
+
+	status = acpi_get_vendor_resource(obj, METHOD_NAME__CRS, &hp_ccsr_uuid,
+		&buffer);
+
+	resource = buffer.pointer;
+	vendor = &resource->data.vendor_typed;
+
+	if (ACPI_FAILURE(status) || vendor->byte_length < 16) {
+		status = AE_NOT_FOUND;
+		goto exit;
+	}
+
+	memcpy(base, vendor->byte_data, sizeof(*base));
+	memcpy(length, vendor->byte_data + 8, sizeof(*length));
+
+  exit:
+	acpi_os_free(buffer.pointer);
+	return status;
 }
 
-acpi_status
-acpi_find_vendor_resource(acpi_handle obj, struct acpi_vendor_descriptor * id,
-			  u8 ** data, u32 * byte_length)
+struct csr_space {
+	u64	base;
+	u64	length;
+};
+
+static acpi_status find_csr_space(struct acpi_resource *resource, void *data)
 {
-	struct acpi_vendor_info info;
+	struct csr_space *space = data;
+	struct acpi_resource_address64 addr;
+	acpi_status status;
+
+	status = acpi_resource_to_address64(resource, &addr);
+	if (ACPI_SUCCESS(status) &&
+	    addr.resource_type = ACPI_MEMORY_RANGE &&
+	    addr.address_length &&
+	    addr.producer_consumer = ACPI_CONSUMER) {
+		space->base = addr.minimum;
+		space->length = addr.address_length;
+		return AE_CTRL_TERMINATE;
+	}
+	return AE_OK;		/* keep looking */
+}
 
-	info.descriptor = id;
-	info.data = NULL;
+static acpi_status hp_crs_locate(acpi_handle obj, u64 *base, u64 *length)
+{
+	struct csr_space space = { 0, 0 };
 
-	acpi_walk_resources(obj, METHOD_NAME__CRS, acpi_vendor_resource_match,
-			    &info);
-	if (!info.data)
+	acpi_walk_resources(obj, METHOD_NAME__CRS, find_csr_space, &space);
+	if (!space.length)
 		return AE_NOT_FOUND;
 
-	*data = info.data;
-	*byte_length = info.length;
+	*base = space.base;
+	*length = space.length;
 	return AE_OK;
 }
 
-struct acpi_vendor_descriptor hp_ccsr_descriptor = {
-	.guid_id = 2,
-	.guid -	    EFI_GUID(0x69e9adf9, 0x924f, 0xab5f, 0xf6, 0x4a, 0x24, 0xd2, 0x01,
-		     0x37, 0x0e, 0xad)
-};
-
-acpi_status hp_acpi_csr_space(acpi_handle obj, u64 * csr_base, u64 * csr_length)
+acpi_status hp_acpi_csr_space(acpi_handle obj, u64 *csr_base, u64 *csr_length)
 {
 	acpi_status status;
-	u8 *data;
-	u32 length;
 
-	status -	    acpi_find_vendor_resource(obj, &hp_ccsr_descriptor, &data, &length);
+	status = hp_ccsr_locate(obj, csr_base, csr_length);
+	if (ACPI_SUCCESS(status))
+		return status;
 
-	if (ACPI_FAILURE(status) || length != 16)
-		return AE_NOT_FOUND;
-
-	memcpy(csr_base, data, sizeof(*csr_base));
-	memcpy(csr_length, data + 8, sizeof(*csr_length));
-	acpi_os_free(data);
-
-	return AE_OK;
+	return hp_crs_locate(obj, csr_base, csr_length);
 }
-
 EXPORT_SYMBOL(hp_acpi_csr_space);
Index: work-mm4/include/asm-ia64/acpi-ext.h
=================================--- work-mm4.orig/include/asm-ia64/acpi-ext.h	2006-01-02 20:21:10.000000000 -0700
+++ work-mm4/include/asm-ia64/acpi-ext.h	2006-02-08 14:37:52.000000000 -0700
@@ -1,12 +1,15 @@
 /*
- * ia64/platform/hp/common/hp_acpi.h
+ * (c) Copyright 2003, 2006 Hewlett-Packard Development Company, L.P.
+ *	Alex Williamson <alex.williamson@hp.com>
+ *	Bjorn Helgaas <bjorn.helgaas@hp.com>
  *
- * Copyright (C) 2003 Hewlett-Packard
- * Copyright (C) Alex Williamson
- * Copyright (C) Bjorn Helgaas
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
  *
  * Vendor specific extensions to ACPI.
  */
+
 #ifndef _ASM_IA64_ACPI_EXT_H
 #define _ASM_IA64_ACPI_EXT_H
 
