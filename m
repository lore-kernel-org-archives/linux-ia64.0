From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 04 May 2004 16:17:13 +0000
Subject: [PATCH] default to serial console when possible
Message-Id: <200405041017.13247.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This adds efi_uart_console_only() so we can default to using a serial
console if the EFI console path only contains UARTs.

(This applies on top of Alex Williamson's recent HCDP patch.)

--- linux-2.5/drivers/serial/8250_hcdp.c	2004-05-04 09:57:24.008205103 -0600
+++ 2.6/drivers/serial/8250_hcdp.c	2004-05-04 09:06:35.390078386 -0600
@@ -11,6 +11,7 @@
  */
 
 #include <linux/config.h>
+#include <linux/console.h>
 #include <linux/kernel.h>
 #include <linux/efi.h>
 #include <linux/init.h>
@@ -44,6 +45,7 @@
 	unsigned long iobase;
 	hcdp_t hcdp;
 	int gsi, nr;
+	static char options[16];
 #if 0
 	static int shift_once = 1;
 #endif
@@ -210,6 +212,12 @@
 			memset(&port, 0, sizeof(port));
 			continue;
 		}
+
+		if (efi_uart_console_only()) {
+			snprintf(options, sizeof(options), "%lun%d",
+				hcdp_dev->baud, hcdp_dev->bits);
+			add_preferred_console("ttyS", port.line, options);
+		}
 		break;
 	}
 
=== arch/ia64/kernel/efi.c 1.32 vs edited ==--- 1.32/arch/ia64/kernel/efi.c	Mon Apr 26 23:07:41 2004
+++ edited/arch/ia64/kernel/efi.c	Mon May  3 17:27:40 2004
@@ -733,3 +733,47 @@
 	return 0;
 }
 
+int __init
+efi_uart_console_only(void)
+{
+	efi_status_t status;
+	char *s, name[] = "ConOut";
+	efi_guid_t guid = EFI_GLOBAL_VARIABLE_GUID;
+	efi_char16_t *utf16, name_utf16[32];
+	unsigned char data[1024];
+	unsigned long size = sizeof(data);
+	struct efi_generic_dev_path *hdr, *end_addr;
+	int uart = 0;
+
+	/* Convert to UTF-16 */
+	utf16 = name_utf16;
+	s = name;
+	while (*s)
+		*utf16++ = *s++ & 0x7f;
+	*utf16 = 0;
+
+	status = efi.get_variable(name_utf16, &guid, NULL, &size, data);
+	if (status != EFI_SUCCESS) {
+		printk(KERN_ERR "No EFI %s variable?\n", name);
+		return 0;
+	}
+
+	hdr = (struct efi_generic_dev_path *) data;
+	end_addr = (struct efi_generic_dev_path *) ((u8 *) data + size);
+	while (hdr < end_addr) {
+		if (hdr->type = EFI_DEV_MSG &&
+		    hdr->sub_type = EFI_DEV_MSG_UART)
+			uart = 1;
+		else if (hdr->type = EFI_DEV_END_PATH ||
+			  hdr->type = EFI_DEV_END_PATH2) {
+			if (!uart)
+				return 0;
+			if (hdr->sub_type = EFI_DEV_END_ENTIRE)
+				return 1;
+			uart = 0;
+		}
+		hdr = (struct efi_generic_dev_path *) ((u8 *) hdr + hdr->length);
+	}
+	printk(KERN_ERR "Malformed %s value\n", name);
+	return 0;
+}
=== include/linux/efi.h 1.7 vs edited ==--- 1.7/include/linux/efi.h	Tue Feb  3 22:29:14 2004
+++ edited/include/linux/efi.h	Mon May  3 17:26:46 2004
@@ -212,6 +212,9 @@
 #define UGA_IO_PROTOCOL_GUID \
     EFI_GUID(  0x61a4d49e, 0x6f68, 0x4f1b, 0xb9, 0x22, 0xa8, 0x6e, 0xed, 0xb, 0x7, 0xa2 )
 
+#define EFI_GLOBAL_VARIABLE_GUID \
+    EFI_GUID(  0x8be4df61, 0x93ca, 0x11d2, 0xaa, 0x0d, 0x00, 0xe0, 0x98, 0x03, 0x2b, 0x8c )
+
 typedef struct {
 	efi_guid_t guid;
 	unsigned long table;
@@ -294,6 +297,7 @@
 extern u64 efi_get_iobase (void);
 extern u32 efi_mem_type (unsigned long phys_addr);
 extern u64 efi_mem_attributes (unsigned long phys_addr);
+extern int __init efi_uart_console_only (void);
 extern void efi_initialize_iomem_resources(struct resource *code_resource,
 					struct resource *data_resource);
 extern efi_status_t phys_efi_get_time(efi_time_t *tm, efi_time_cap_t *tc);
@@ -322,6 +326,49 @@
 #define EFI_VARIABLE_BOOTSERVICE_ACCESS 0x0000000000000002
 #define EFI_VARIABLE_RUNTIME_ACCESS     0x0000000000000004
 
+/*
+ * EFI Device Path information
+ */
+#define EFI_DEV_HW			0x01
+#define  EFI_DEV_PCI				 1
+#define  EFI_DEV_PCCARD				 2
+#define  EFI_DEV_MEM_MAPPED			 3
+#define  EFI_DEV_VENDOR				 4
+#define  EFI_DEV_CONTROLLER			 5
+#define EFI_DEV_ACPI			0x02
+#define   EFI_DEV_BASIC_ACPI			 1
+#define   EFI_DEV_EXPANDED_ACPI			 2
+#define EFI_DEV_MSG			0x03
+#define   EFI_DEV_MSG_ATAPI			 1
+#define   EFI_DEV_MSG_SCSI			 2
+#define   EFI_DEV_MSG_FC			 3
+#define   EFI_DEV_MSG_1394			 4
+#define   EFI_DEV_MSG_USB			 5
+#define   EFI_DEV_MSG_USB_CLASS			15
+#define   EFI_DEV_MSG_I20			 6
+#define   EFI_DEV_MSG_MAC			11
+#define   EFI_DEV_MSG_IPV4			12
+#define   EFI_DEV_MSG_IPV6			13
+#define   EFI_DEV_MSG_INFINIBAND		 9
+#define   EFI_DEV_MSG_UART			14
+#define   EFI_DEV_MSG_VENDOR			10
+#define EFI_DEV_MEDIA			0x04
+#define   EFI_DEV_MEDIA_HARD_DRIVE		 1
+#define   EFI_DEV_MEDIA_CDROM			 2
+#define   EFI_DEV_MEDIA_VENDOR			 3
+#define   EFI_DEV_MEDIA_FILE			 4
+#define   EFI_DEV_MEDIA_PROTOCOL		 5
+#define EFI_DEV_BIOS_BOOT		0x05
+#define EFI_DEV_END_PATH		0x7F
+#define EFI_DEV_END_PATH2		0xFF
+#define   EFI_DEV_END_INSTANCE			0x01
+#define   EFI_DEV_END_ENTIRE			0xFF
+
+struct efi_generic_dev_path {
+	u8 type;
+	u8 sub_type;
+	u16 length;
+} __attribute ((packed));
 
 /*
  * efi_dir is allocated in arch/ia64/kernel/efi.c.
