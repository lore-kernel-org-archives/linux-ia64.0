From: "KOCHI, Takayoshi" <t-kouchi@mvf.biglobe.ne.jp>
Date: Fri, 23 Aug 2002 04:52:40 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.19)
Message-Id: <marc-linux-ia64-105590701905977@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Bjorn,

I have comments on arch/ia64/kernel/acpi.c:

 o acpi_get_current_resources
   After some version (around Apr. 2002), ACPI CA has automatic memory
   allocation functionality.  If acpi_buffer's length is
   ACPI_ALLOCATE_BUFFER, memory is allocated automatically.
   So independent acpi_get_crs makes less sense, we can use
   acpi_get_current_resources directly.  Returning -ENOMEM
   as acpi_status is also wrong.

 o void * as a pointer to byte array
   I was taught that this is a gcc extension, can to do any arithmetic
   operation and should be avoided.
   I'm not sure this is still true in C99.
   Maybe you reject this because original is simpler and works anyway.

-	res = buf->pointer + *offset;
+	res = (acpi_resource *)((char *) buf->pointer + *offset);

 o acpi_resource's id and length
   It is really counter-intuitive, but you can't count on length
   member of acpi_resource:(  In acpi_get_crs_addr(), there's a
   corner case that resource doesn't have any memory resource
   records.  In that case, it will go into infinite loop.
   If you encounter ACPI_RSTYPE_END_TAG, it's the end
   of resources.

+			case ACPI_RSTYPE_END_TAG:
+				return;
+				break;

  o I made some functions static

  o rewrite acpi_dispose_crs with acpi_os_free
    It's not important:)

Index: lia64-2.4/arch/ia64/kernel/acpi.c
diff -u lia64-2.4/arch/ia64/kernel/acpi.c:1.1.1.15 lia64-2.4/arch/ia64/kernel/acpi.c:1.1.1.15.4.1
--- lia64-2.4/arch/ia64/kernel/acpi.c:1.1.1.15	Thu Aug 22 10:39:56 2002
+++ lia64-2.4/arch/ia64/kernel/acpi.c	Thu Aug 22 20:55:08 2002
@@ -112,33 +112,7 @@
 
 #ifdef CONFIG_ACPI
 
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
-acpi_get_crs (acpi_handle obj, acpi_buffer *buf)
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
-acpi_resource *
+static acpi_resource *
 acpi_get_crs_next (acpi_buffer *buf, int *offset)
 {
 	acpi_resource *res;
@@ -146,12 +120,12 @@
 	if (*offset >= buf->length)
 		return NULL;
 
-	res = buf->pointer + *offset;
+	res = (acpi_resource *)((char *) buf->pointer + *offset);
 	*offset += res->length;
 	return res;
 }
 
-acpi_resource_data *
+static acpi_resource_data *
 acpi_get_crs_type (acpi_buffer *buf, int *offset, int type)
 {
 	for (;;) {
@@ -163,12 +137,6 @@
 	}
 }
 
-void
-acpi_dispose_crs (acpi_buffer *buf)
-{
-	kfree(buf->pointer);
-}
-
 static void
 acpi_get_crs_addr (acpi_buffer *buf, int type, u64 *base, u64 *length, u64 *tra)
 {
@@ -210,6 +178,9 @@
 					return;
 				}
 				break;
+			case ACPI_RSTYPE_END_TAG:
+				return;
+				break;
 		}
 	}
 }
@@ -218,13 +189,14 @@
 acpi_get_addr_space(acpi_handle obj, u8 type, u64 *base, u64 *length, u64 *tra)
 {
 	acpi_status status;
-	acpi_buffer buf;
+	acpi_buffer buf = { .length =  ACPI_ALLOCATE_BUFFER,
+			    .pointer = NULL };
 
 	*base = 0;
 	*length = 0;
 	*tra = 0;
 
-	status = acpi_get_crs(obj, &buf);
+	status = acpi_get_current_resources(obj, &buf);
 	if (ACPI_FAILURE(status)) {
 		printk(KERN_ERR PREFIX "Unable to get _CRS data on object\n");
 		return status;
@@ -232,7 +204,7 @@
 
 	acpi_get_crs_addr(&buf, type, base, length, tra);
 
-	acpi_dispose_crs(&buf);
+	acpi_os_free(buf.pointer);
 
 	return AE_OK;
 }
@@ -254,7 +226,8 @@
 {
 	int i, offset = 0;
 	acpi_status status;
-	acpi_buffer buf;
+	acpi_buffer buf = { .length =  ACPI_ALLOCATE_BUFFER,
+			    .pointer = NULL };
 	acpi_resource_vendor *res;
 	acpi_hp_vendor_long *hp_res;
 	efi_guid_t vendor_guid;
@@ -262,7 +235,7 @@
 	*csr_base = 0;
 	*csr_length = 0;
 
-	status = acpi_get_crs(obj, &buf);
+	status = acpi_get_current_resources(obj, &buf);
 	if (ACPI_FAILURE(status)) {
 		printk(KERN_ERR PREFIX "Unable to get _CRS data on object\n");
 		return status;
@@ -271,7 +244,7 @@
 	res = (acpi_resource_vendor *)acpi_get_crs_type(&buf, &offset, ACPI_RSTYPE_VENDOR);
 	if (!res) {
 		printk(KERN_ERR PREFIX "Failed to find config space for device\n");
-		acpi_dispose_crs(&buf);
+		acpi_os_free(buf.pointer);
 		return AE_NOT_FOUND;
 	}
 
@@ -279,14 +252,14 @@
 
 	if (res->length != HP_CCSR_LENGTH || hp_res->guid_id != HP_CCSR_TYPE) {
 		printk(KERN_ERR PREFIX "Unknown Vendor data\n");
-		acpi_dispose_crs(&buf);
+		acpi_os_free(buf.pointer);
 		return AE_TYPE; /* Revisit error? */
 	}
 
 	memcpy(&vendor_guid, hp_res->guid, sizeof(efi_guid_t));
 	if (efi_guidcmp(vendor_guid, HP_CCSR_GUID) != 0) {
 		printk(KERN_ERR PREFIX "Vendor GUID does not match\n");
-		acpi_dispose_crs(&buf);
+		acpi_os_free(buf.pointer);
 		return AE_TYPE; /* Revisit error? */
 	}
 
@@ -295,7 +268,7 @@
 		*csr_length |= ((u64)(hp_res->csr_length[i]) << (i * 8));
 	}
 
-	acpi_dispose_crs(&buf);
+	acpi_os_free(buf.pointer);
 
 	return AE_OK;
 }

Thanks,
-- 
KOCHI, Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>


