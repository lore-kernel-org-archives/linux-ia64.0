From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Fri, 25 Apr 2003 18:36:40 +0000
Subject: [Linux-ia64] [PATCH] 2.5 vendor-specific ACPI resource cleanup
Message-Id: <marc-linux-ia64-105590723705610@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is to

  - handle _CRS with multiple vendor-specific resources
  - use acpi_walk_resources() instead of doing it by hand
  - make lookup of vendor resource by GUID generic
  - cleanup now-unused helper functions

(This depends on the previous IO port space patches, because
they removed the last of acpi_get_addr_space()).

My hope is that acpi_vendor_resource_match() and
acpi_find_vendor_resource() can someday move into ACPI,
but that probably depends on getting the idea of labelling
vendor resources with a GUID into the spec.  HP does this
and I think is working on putting it in the spec.

Bjorn


diff -u -r linux-2.5.67-ia64-030416-io5/arch/ia64/kernel/acpi-ext.c linux-2.5.67-ia64-030416-io6/arch/ia64/kernel/acpi-ext.c
--- linux-2.5.67-ia64-030416-io5/arch/ia64/kernel/acpi-ext.c	2003-04-24 10:10:58.000000000 -0600
+++ linux-2.5.67-ia64-030416-io6/arch/ia64/kernel/acpi-ext.c	2003-04-25 12:13:59.000000000 -0600
@@ -3,9 +3,9 @@
  *
  * Copyright (C) 2003 Hewlett-Packard
  * Copyright (C) Alex Williamson
+ * Copyright (C) Bjorn Helgaas
  *
- * Vendor specific extensions to ACPI.  These are used by both
- * HP and NEC.
+ * Vendor specific extensions to ACPI.
  */
 
 #include <linux/config.h>
@@ -16,58 +16,85 @@
 
 #include <asm/acpi-ext.h>
 
-/*
- * Note: Strictly speaking, this is only needed for HP and NEC machines.
- *	 However, NEC machines identify themselves as DIG-compliant, so there is
- *	 no easy way to #ifdef this out.
- */
+struct acpi_vendor_descriptor {
+	u8				guid_id;
+	efi_guid_t			guid;
+};
+
+struct acpi_vendor_info {
+	struct acpi_vendor_descriptor	*descriptor;
+	u8				*data;
+	u32				length;
+};
+
 acpi_status
-hp_acpi_csr_space (acpi_handle obj, u64 *csr_base, u64 *csr_length)
+acpi_vendor_resource_match(struct acpi_resource *resource, void *context)
 {
-	int i, offset = 0;
-	acpi_status status;
-	struct acpi_buffer buf;
-	struct acpi_resource_vendor *res;
-	struct acpi_hp_vendor_long *hp_res;
-	efi_guid_t vendor_guid;
-
-	*csr_base = 0;
-	*csr_length = 0;
-
-	status = acpi_get_crs(obj, &buf);
-	if (ACPI_FAILURE(status)) {
-		printk(KERN_ERR PREFIX "Unable to get _CRS data on object\n");
-		return status;
-	}
-
-	res = (struct acpi_resource_vendor *)acpi_get_crs_type(&buf, &offset, ACPI_RSTYPE_VENDOR);
-	if (!res) {
-		printk(KERN_ERR PREFIX "Failed to find config space for device\n");
-		acpi_dispose_crs(&buf);
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
+	    descriptor->guid_id != info->descriptor->guid_id ||
+	    efi_guidcmp(descriptor->guid, info->descriptor->guid))
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
+acpi_status
+acpi_find_vendor_resource(acpi_handle obj, struct acpi_vendor_descriptor *id,
+		u8 **data, u32 *length)
+{
+	struct acpi_vendor_info info;
+
+	info.descriptor = id;
+	info.data = 0;
+
+	acpi_walk_resources(obj, METHOD_NAME__CRS, acpi_vendor_resource_match, &info);
+	if (!info.data)
 		return AE_NOT_FOUND;
-	}
 
-	hp_res = (struct acpi_hp_vendor_long *)(res->reserved);
+	*data = info.data;
+	*length = info.length;
+	return AE_OK;
+}
+
+struct acpi_vendor_descriptor hp_ccsr_descriptor = {
+	.guid_id = 2,
+	.guid    = EFI_GUID(0x69e9adf9, 0x924f, 0xab5f, 0xf6, 0x4a, 0x24, 0xd2, 0x01, 0x37, 0x0e, 0xad)
+};
+
+acpi_status
+hp_acpi_csr_space(acpi_handle obj, u64 *csr_base, u64 *csr_length)
+{
+	acpi_status status;
+	u8 *data;
+	u32 length;
+	int i;
+
+	status = acpi_find_vendor_resource(obj, &hp_ccsr_descriptor, &data, &length);
+
+	if (ACPI_FAILURE(status) || length != 16)
+		return AE_NOT_FOUND;
 
-	if (res->length != HP_CCSR_LENGTH || hp_res->guid_id != HP_CCSR_TYPE) {
-		printk(KERN_ERR PREFIX "Unknown Vendor data\n");
-		acpi_dispose_crs(&buf);
-		return AE_TYPE; /* Revisit error? */
-	}
-
-	memcpy(&vendor_guid, hp_res->guid, sizeof(efi_guid_t));
-	if (efi_guidcmp(vendor_guid, HP_CCSR_GUID) != 0) {
-		printk(KERN_ERR PREFIX "Vendor GUID does not match\n");
-		acpi_dispose_crs(&buf);
-		return AE_TYPE; /* Revisit error? */
-	}
-
-	for (i = 0 ; i < 8 ; i++) {
-		*csr_base |= ((u64)(hp_res->csr_base[i]) << (i * 8));
-		*csr_length |= ((u64)(hp_res->csr_length[i]) << (i * 8));
-	}
+	memcpy(csr_base, data, sizeof(*csr_base));
+	memcpy(csr_length, data + 8, sizeof(*csr_length));
+	acpi_os_free(data);
 
-	acpi_dispose_crs(&buf);
 	return AE_OK;
 }
 
diff -u -r linux-2.5.67-ia64-030416-io5/arch/ia64/kernel/acpi.c linux-2.5.67-ia64-030416-io6/arch/ia64/kernel/acpi.c
--- linux-2.5.67-ia64-030416-io5/arch/ia64/kernel/acpi.c	2003-04-24 13:44:09.000000000 -0600
+++ linux-2.5.67-ia64-030416-io6/arch/ia64/kernel/acpi.c	2003-04-25 11:23:32.000000000 -0600
@@ -115,138 +115,6 @@
 #endif
 }
 
-#ifdef CONFIG_ACPI
-
-/**
- * acpi_get_crs - Return the current resource settings for a device
- * obj: A handle for this device
- * buf: A buffer to be populated by this call.
- *
- * Pass a valid handle, typically obtained by walking the namespace and a
- * pointer to an allocated buffer, and this function will fill in the buffer
- * with a list of acpi_resource structures.
- */
-acpi_status
-acpi_get_crs (acpi_handle obj, struct acpi_buffer *buf)
-{
-	acpi_status result;
-	buf->length = 0;
-	buf->pointer = NULL;
-
-	result = acpi_get_current_resources(obj, buf);
-	if (result != AE_BUFFER_OVERFLOW)
-		return result;
-	buf->pointer = kmalloc(buf->length, GFP_KERNEL);
-	if (!buf->pointer)
-		return -ENOMEM;
-
-	return acpi_get_current_resources(obj, buf);
-}
-
-struct acpi_resource *
-acpi_get_crs_next (struct acpi_buffer *buf, int *offset)
-{
-	struct acpi_resource *res;
-
-	if (*offset >= buf->length)
-		return NULL;
-
-	res = buf->pointer + *offset;
-
-	if (res->length <= 0)
-		return NULL;
-
-	*offset += res->length;
-	return res;
-}
-
-union acpi_resource_data *
-acpi_get_crs_type (struct acpi_buffer *buf, int *offset, int type)
-{
-	for (;;) {
-		struct acpi_resource *res = acpi_get_crs_next(buf, offset);
-		if (!res)
-			return NULL;
-		if (res->id = type)
-			return &res->data;
-	}
-}
-
-void
-acpi_dispose_crs (struct acpi_buffer *buf)
-{
-	kfree(buf->pointer);
-}
-
-void
-acpi_get_crs_addr (struct acpi_buffer *buf, int type, u64 *base, u64 *size, u64 *tra)
-{
-	int offset = 0;
-	struct acpi_resource_address16 *addr16;
-	struct acpi_resource_address32 *addr32;
-	struct acpi_resource_address64 *addr64;
-
-	for (;;) {
-		struct acpi_resource *res = acpi_get_crs_next(buf, &offset);
-		if (!res)
-			return;
-		switch (res->id) {
-			case ACPI_RSTYPE_ADDRESS16:
-				addr16 = (struct acpi_resource_address16 *) &res->data;
-
-				if (type = addr16->resource_type) {
-					*base = addr16->min_address_range;
-					*size = addr16->address_length;
-					*tra = addr16->address_translation_offset;
-					return;
-				}
-				break;
-			case ACPI_RSTYPE_ADDRESS32:
-				addr32 = (struct acpi_resource_address32 *) &res->data;
-				if (type = addr32->resource_type) {
-					*base = addr32->min_address_range;
-					*size = addr32->address_length;
-					*tra = addr32->address_translation_offset;
-					return;
-				}
-				break;
-			case ACPI_RSTYPE_ADDRESS64:
-				addr64 = (struct acpi_resource_address64 *) &res->data;
-				if (type = addr64->resource_type) {
-					*base = addr64->min_address_range;
-					*size = addr64->address_length;
-					*tra = addr64->address_translation_offset;
-					return;
-				}
-				break;
-		}
-	}
-}
-
-int
-acpi_get_addr_space(void *obj, u8 type, u64 *base, u64 *length, u64 *tra)
-{
-	acpi_status status;
-	struct acpi_buffer buf;
-
-	*base = 0;
-	*length = 0;
-	*tra = 0;
-
-	status = acpi_get_crs((acpi_handle)obj, &buf);
-	if (ACPI_FAILURE(status)) {
-		printk(KERN_ERR PREFIX "Unable to get _CRS data on object\n");
-		return status;
-	}
-
-	acpi_get_crs_addr(&buf, type, base, length, tra);
-
-	acpi_dispose_crs(&buf);
-
-	return AE_OK;
-}
-#endif /* CONFIG_ACPI */
-
 #ifdef CONFIG_ACPI_BOOT
 
 #define ACPI_MAX_PLATFORM_INTERRUPTS	256
diff -u -r linux-2.5.67-ia64-030416-io5/include/asm-ia64/acpi-ext.h linux-2.5.67-ia64-030416-io6/include/asm-ia64/acpi-ext.h
--- linux-2.5.67-ia64-030416-io5/include/asm-ia64/acpi-ext.h	2003-04-24 10:10:58.000000000 -0600
+++ linux-2.5.67-ia64-030416-io6/include/asm-ia64/acpi-ext.h	2003-04-25 11:40:08.000000000 -0600
@@ -3,30 +3,15 @@
  *
  * Copyright (C) 2003 Hewlett-Packard
  * Copyright (C) Alex Williamson
+ * Copyright (C) Bjorn Helgaas
  *
- * Vendor specific extensions to ACPI.  The HP-specific extensiosn are also used by NEC.
+ * Vendor specific extensions to ACPI.
  */
 #ifndef _ASM_IA64_ACPI_EXT_H
 #define _ASM_IA64_ACPI_EXT_H
 
 #include <linux/types.h>
 
-#define HP_CCSR_LENGTH	0x21
-#define HP_CCSR_TYPE	0x2
-#define HP_CCSR_GUID	EFI_GUID(0x69e9adf9, 0x924f, 0xab5f, \
-				 0xf6, 0x4a, 0x24, 0xd2, 0x01, 0x37, 0x0e, 0xad)
-
-struct acpi_hp_vendor_long {
-	u8      guid_id;
-	u8      guid[16];
-	u8      csr_base[8];
-	u8      csr_length[8];
-};
-
 extern acpi_status hp_acpi_csr_space (acpi_handle, u64 *base, u64 *length);
-extern acpi_status acpi_get_crs (acpi_handle, struct acpi_buffer *);
-extern struct acpi_resource *acpi_get_crs_next (struct acpi_buffer *, int *);
-extern union acpi_resource_data *acpi_get_crs_type (struct acpi_buffer *, int *, int);
-extern void acpi_dispose_crs (struct acpi_buffer *);
 
 #endif /* _ASM_IA64_ACPI_EXT_H */


