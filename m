From: Andreas Schwab <schwab@suse.de>
Date: Wed, 16 May 2001 10:28:22 +0000
Subject: Re: [Linux-ia64] Announcing efibootmgr-0.2.0
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-=-="
Message-Id: <marc-linux-ia64-105590693005587@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005585@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005585@msgid-missing>
To: linux-ia64@vger.kernel.org

--=-=-=
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable

Matt_Domsch@Dell.com writes:

|> Announcing efibootmgr-0.2.0, a Linux user-space application which intera=
cts
|> with the EFI Boot Manager.  It may be downloaded from
|> http://domsch.com/linux/ia64/efibootmgr-0.2.0.tar.gz.

Appended is a patch that removes the use of kernel headers (which have no
place in user level programs), and fixes the use of feature test macros.
There are also a few unaligned accesses which I haven't fixed.

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

--=-=-=
Content-Type: text/x-patch
Content-Disposition: attachment; filename=efibootmgr-0.2.0.dif

--- src/efibootmgr/efibootmgr.c
+++ src/efibootmgr/efibootmgr.c	2001/05/16 10:11:08
@@ -30,6 +30,8 @@
  
 */
 
+#define _GNU_SOURCE
+
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
@@ -39,7 +41,6 @@
 #include <fcntl.h>
 #include <dirent.h>
 #include <unistd.h>
-#define _GNU_SOURCE
 #include <getopt.h>
 #include "list.h"
 #include "efi.h"
@@ -53,7 +54,7 @@
 
 typedef struct _var_entry {
 	struct dirent   *name;
-	__u16            num;
+	uint16_t            num;
 	efi_variable_t   var_data;
 	struct list_head list;
 } var_entry_t;
@@ -65,7 +66,7 @@
 efibootmgr_opt_t opts;
 
 static inline void
-var_num_from_name(const char *pattern, char *name, __u16 *num)
+var_num_from_name(const char *pattern, char *name, uint16_t *num)
 {
 	sscanf(name, pattern, num);
 }
@@ -165,7 +166,7 @@
 compare(const void *a, const void *b)
 {
 	int rc = -1;
-	__u32 n1=*(__u32 *)a, n2=*(__u32 *)b;
+	uint32_t n1=*(uint32_t *)a, n2=*(uint32_t *)b;
 	if (n1 < n2) rc = -1;
 	if (n1 == n2) rc = 0;
 	if (n2 > n2) rc = 1;
@@ -181,22 +182,22 @@
 find_free_boot_var(struct list_head *boot_list)
 {
 	int num_vars=0, i=0, found;
-	__u16 *vars, free_number;
+	uint16_t *vars, free_number;
 	struct list_head *pos;
 	var_entry_t *boot;
 	list_for_each(pos, boot_list) {
 		num_vars++;
 	}
-	vars = malloc(sizeof(__u16) * num_vars);
+	vars = malloc(sizeof(uint16_t) * num_vars);
 	if (!vars) return -1;
-	memset(vars, 0, sizeof(__u16) * num_vars);
+	memset(vars, 0, sizeof(uint16_t) * num_vars);
 
 	list_for_each(pos, boot_list) {
 		boot = list_entry(pos, var_entry_t, list);
 		vars[i] = boot->num;
 			i++;
 	}
-	qsort(vars, i, sizeof(__u16), compare);
+	qsort(vars, i, sizeof(uint16_t), compare);
 	found = 1;
 
 	num_vars = i;
@@ -277,12 +278,12 @@
 
 
 static efi_status_t
-add_to_boot_order(__u16 num)
+add_to_boot_order(uint16_t num)
 {
 	efi_status_t status;
 	efi_variable_t boot_order;
-	__u64 new_data_size;
-	__u16 *new_data, *old_data;
+	uint64_t new_data_size;
+	uint16_t *new_data, *old_data;
 
 
 	status = read_boot_order(&boot_order);
@@ -292,8 +293,8 @@
 	/* We've now got an array (in boot_order.Data) of the
 	   boot order.  First add our entry, then copy the old array.
 	*/
-	old_data = (__u16 *)&(boot_order.Data);
-	new_data_size = boot_order.DataSize + sizeof(__u16);
+	old_data = (uint16_t *)&(boot_order.Data);
+	new_data_size = boot_order.DataSize + sizeof(uint16_t);
 	new_data = malloc(new_data_size);
 	
 	new_data[0] = num;
@@ -308,12 +309,12 @@
 
 
 static efi_status_t
-remove_from_boot_order(__u16 num)
+remove_from_boot_order(uint16_t num)
 {
 	efi_status_t status;
 	efi_variable_t boot_order;
-	__u64 new_data_size;
-	__u16 *new_data, *old_data;
+	uint64_t new_data_size;
+	uint16_t *new_data, *old_data;
 	int old_i,new_i;
 
 	read_boot_order(&boot_order);
@@ -326,12 +327,12 @@
 	   boot order.  Simply copy the array, skipping the
 	   entry we're deleting.
 	*/
-	old_data = (__u16 *)&(boot_order.Data);
+	old_data = (uint16_t *)&(boot_order.Data);
 	/* Start with the same size */
 	new_data_size = boot_order.DataSize;
 	new_data = malloc(new_data_size);
 	for (old_i=0,new_i=0;
-	     old_i < boot_order.DataSize / sizeof(__u16);
+	     old_i < boot_order.DataSize / sizeof(uint16_t);
 	     old_i++) {
 		if (old_data[old_i] != num) {
 				/* Copy this value */
@@ -341,7 +342,7 @@
 	}
 
 	/* Now new_data has what we need */
-	new_data_size = new_i * sizeof(__u16);
+	new_data_size = new_i * sizeof(uint16_t);
 	memset(&(boot_order.Data), 0, boot_order.DataSize);
 	memcpy(&(boot_order.Data), new_data, new_data_size);
 	boot_order.DataSize = new_data_size;
@@ -356,7 +357,7 @@
 	efi_variable_t boot_next;
 	efi_guid_t guid = EFI_GLOBAL_VARIABLE;
 	char boot_next_name[80], text_uuid[40];
-	__u16 *n = (__u16 *)(boot_next.Data);
+	uint16_t *n = (uint16_t *)(boot_next.Data);
 
 	efi_guid_unparse(&guid, text_uuid);
 
@@ -376,7 +377,7 @@
 	efi_variable_t boot_next;
 	efi_guid_t guid = EFI_GLOBAL_VARIABLE;
 	char boot_next_name[80], text_uuid[40];
-	__u16 *n = (__u16 *)(boot_next.Data);
+	uint16_t *n = (uint16_t *)(boot_next.Data);
 
 	efi_guid_unparse(&guid, text_uuid);
 
@@ -391,11 +392,11 @@
 
 
 static efi_status_t
-set_boot_next(__u16 num)
+set_boot_next(uint16_t num)
 {
 	efi_variable_t var;
 	efi_guid_t guid = EFI_GLOBAL_VARIABLE;
-	__u16 *n = (__u16 *)var.Data;
+	uint16_t *n = (uint16_t *)var.Data;
 
 	memset(&var, 0, sizeof(var));
 
@@ -403,7 +404,7 @@
 			  1024);
 	memcpy(&var.VendorGuid, &guid, sizeof(guid));
 	*n = num;
-	var.DataSize = sizeof(__u16);
+	var.DataSize = sizeof(uint16_t);
 	var.Attributes = EFI_VARIABLE_NON_VOLATILE 
 		| EFI_VARIABLE_BOOTSERVICE_ACCESS
 		| EFI_VARIABLE_RUNTIME_ACCESS;
@@ -426,7 +427,7 @@
 
 
 static efi_status_t
-delete_boot_var(__u16 num)
+delete_boot_var(uint16_t num)
 {
 	efi_status_t status;
 	efi_variable_t var;
@@ -564,7 +565,7 @@
 #endif	
 
 static void
-unparse_boot_order(__u16 *order, int length)
+unparse_boot_order(uint16_t *order, int length)
 {
 	int i;
 	printf("BootOrder: ");
@@ -577,7 +578,7 @@
 }
 
 static int
-parse_boot_order(char *buffer, __u16 *order, int length)
+parse_boot_order(char *buffer, uint16_t *order, int length)
 {
 	int i;
 	int num, rc;
@@ -598,7 +599,7 @@
 {
 	efi_variable_t var;
 	efi_guid_t guid = EFI_GLOBAL_VARIABLE;
-	__u16 *n = (__u16 *)var.Data;
+	uint16_t *n = (uint16_t *)var.Data;
 
 	if (!opts.bootorder) return EFI_SUCCESS;
 
@@ -611,7 +612,7 @@
 		| EFI_VARIABLE_BOOTSERVICE_ACCESS
 		| EFI_VARIABLE_RUNTIME_ACCESS;
 
-	var.DataSize = parse_boot_order(opts.bootorder, n, 1024/sizeof(__u16)) * sizeof(__u16);
+	var.DataSize = parse_boot_order(opts.bootorder, n, 1024/sizeof(uint16_t)) * sizeof(uint16_t);
 	return write_variable(&var);
 }
 
@@ -655,7 +656,7 @@
 {
 	efi_status_t status;
 	efi_variable_t boot_order;
-	__u16 *data;
+	uint16_t *data;
 
 	status = read_boot_order(&boot_order);
 	if (status != EFI_SUCCESS) return;
@@ -663,9 +664,9 @@
 	/* We've now got an array (in boot_order.Data) of the
 	   boot order.  First add our entry, then copy the old array.
 	*/
-	data = (__u16 *)&(boot_order.Data);
+	data = (uint16_t *)&(boot_order.Data);
 	if (boot_order.DataSize) 
-		unparse_boot_order(data, boot_order.DataSize / sizeof(__u16));
+		unparse_boot_order(data, boot_order.DataSize / sizeof(uint16_t));
 
 }
 
--- src/include/crc32.h
+++ src/include/crc32.h	2001/05/16 10:11:32
@@ -22,13 +22,13 @@
 #ifndef _CRC32_H
 #define _CRC32_H
 
-#include <linux/types.h>
+#include <stdint.h>
 
 /*
  * This computes a 32 bit CRC of the data in the buffer, and returns the CRC.
  * The polynomial used is 0xedb88320.
  */
 
-extern __u32 crc32 (const void *buf, unsigned long len, __u32 seed);
+extern uint32_t crc32 (const void *buf, unsigned long len, uint32_t seed);
 
 #endif /* _CRC32_H */
--- src/include/disk.h
+++ src/include/disk.h	2001/05/16 10:12:06
@@ -77,10 +77,10 @@
 		      unsigned char *part);
 
 int disk_get_partition_info (int fd, 
-			     __u32 num,
-			     __u64 *start, __u64 *size,
+			     uint32_t num,
+			     uint64_t *start, uint64_t *size,
 			     char *signature,
-			     __u8 *mbr_type, __u8 *signature_type);
+			     uint8_t *mbr_type, uint8_t *signature_type);
 
 
 int disk_get_size(int fd, long *size);
--- src/include/efi.h
+++ src/include/efi.h	2001/05/16 10:12:44
@@ -33,7 +33,7 @@
  * Copyright (C) 1999 Stephane Eranian <eranian@hpl.hp.com>
  * Copyright (C) 2001 Matt Domsch <Matt_Domsch@dell.com>
  */
-#include <linux/types.h>
+#include <stdint.h>
 
 #define EFI_SUCCESS		0
 #define EFI_LOAD_ERROR          (1L | (1L << 63))
@@ -75,88 +75,88 @@
 
 
 
-typedef __u64 efi_status_t;
-typedef __u8  efi_bool_t;
-typedef __u16 efi_char16_t;		/* UNICODE character */
+typedef uint64_t efi_status_t;
+typedef uint8_t  efi_bool_t;
+typedef uint16_t efi_char16_t;		/* UNICODE character */
 
 typedef struct {
-	__u32 data1;
-	__u16 data2;
-	__u16 data3;
-	__u8  data4[8];
+	uint32_t data1;
+	uint16_t data2;
+	uint16_t data3;
+	uint8_t  data4[8];
 } efi_guid_t;
 
 typedef struct _efi_variable_t {
         efi_char16_t  VariableName[1024/sizeof(efi_char16_t)];
         efi_guid_t    VendorGuid;
-        __u64         DataSize;
-        __u8          Data[1024];
+        uint64_t         DataSize;
+        uint8_t          Data[1024];
 	efi_status_t  Status;
-        __u32         Attributes;
+        uint32_t         Attributes;
 } __attribute__((packed)) efi_variable_t;
 
 
 
 typedef struct {
-	__u8  type;
-	__u8  subtype;
-	__u16 length;
-	__u8  data[1];
+	uint8_t  type;
+	uint8_t  subtype;
+	uint16_t length;
+	uint8_t  data[1];
 } __attribute__((packed)) EFI_DEVICE_PATH;
 
 typedef struct {
-	__u32 attributes;
-	__u16 file_path_list_length;
+	uint32_t attributes;
+	uint16_t file_path_list_length;
 	efi_char16_t description[1];
 	EFI_DEVICE_PATH _unused_file_path_list[1];
 } __attribute__((packed)) EFI_LOAD_OPTION;
 
 
 typedef struct {
-	__u8 type;
-	__u8 subtype;
-	__u16 length;
-	__u32 _HID;
-	__u32 _UID;
+	uint8_t type;
+	uint8_t subtype;
+	uint16_t length;
+	uint32_t _HID;
+	uint32_t _UID;
 } __attribute__((packed)) ACPI_DEVICE_PATH;
 
 typedef struct {
-	__u8 type;
-	__u8 subtype;
-	__u16 length;
+	uint8_t type;
+	uint8_t subtype;
+	uint16_t length;
 	efi_guid_t vendor_guid;
-	__u8 data[1];
+	uint8_t data[1];
 } __attribute__((packed)) VENDOR_DEVICE_PATH;
 
 typedef struct {
-	__u8 type;
-	__u8 subtype;
-	__u16 length;
-	__u8 function;
-	__u8 device;
+	uint8_t type;
+	uint8_t subtype;
+	uint16_t length;
+	uint8_t function;
+	uint8_t device;
 } __attribute__((packed)) PCI_DEVICE_PATH;
 
 typedef struct {
-	__u8 type;
-	__u8 subtype;
-	__u16 length;
-	__u8  socket;
+	uint8_t type;
+	uint8_t subtype;
+	uint16_t length;
+	uint8_t  socket;
 } __attribute__((packed)) PCCARD_DEVICE_PATH;
 
 typedef struct {
-	__u8 type;
-	__u8 subtype;
-	__u16 length;
-	__u32 memory_type;
-	__u64 start;
-	__u64 end;
+	uint8_t type;
+	uint8_t subtype;
+	uint16_t length;
+	uint32_t memory_type;
+	uint64_t start;
+	uint64_t end;
 } __attribute__((packed)) MEMORY_MAPPED_DEVICE_PATH;
 
 typedef struct {
-	__u8 type;
-	__u8 subtype;
-	__u16 length;
-	__u32 controller;
+	uint8_t type;
+	uint8_t subtype;
+	uint16_t length;
+	uint32_t controller;
 } __attribute__((packed)) CONTROLLER_DEVICE_PATH;
 
 
@@ -164,168 +164,168 @@
 
 
 typedef struct {
-	__u8 type;
-	__u8 subtype;
-	__u16 length;
-	__u16 id;
-	__u16 lun;
+	uint8_t type;
+	uint8_t subtype;
+	uint16_t length;
+	uint16_t id;
+	uint16_t lun;
 } __attribute__((packed)) SCSI_DEVICE_PATH;
 
 typedef struct {
-	__u8 type;
-	__u8 subtype;
-	__u16 length;
-	__u8  primary_secondary;
-	__u8  slave_master;
-	__u16 lun;
+	uint8_t type;
+	uint8_t subtype;
+	uint16_t length;
+	uint8_t  primary_secondary;
+	uint8_t  slave_master;
+	uint16_t lun;
 } __attribute__((packed)) ATAPI_DEVICE_PATH;
 
 typedef struct {
-	__u8 type;
-	__u8 subtype;
-	__u16 length;
-	__u32 reserved;
-	__u64 wwn;
-	__u64 lun;
+	uint8_t type;
+	uint8_t subtype;
+	uint16_t length;
+	uint32_t reserved;
+	uint64_t wwn;
+	uint64_t lun;
 } __attribute__((packed)) FIBRE_CHANNEL_DEVICE_PATH;
 
 typedef struct {
-	__u8 type;
-	__u8 subtype;
-	__u16 length;
-	__u32 reserved;
-	__u64 guid;
+	uint8_t type;
+	uint8_t subtype;
+	uint16_t length;
+	uint32_t reserved;
+	uint64_t guid;
 } __attribute__((packed)) I1394_DEVICE_PATH;
 
 typedef struct {
-	__u8 type;
-	__u8 subtype;
-	__u16 length;
-	__u8  port;
-	__u8  endpoint;
+	uint8_t type;
+	uint8_t subtype;
+	uint16_t length;
+	uint8_t  port;
+	uint8_t  endpoint;
 } __attribute__((packed)) USB_DEVICE_PATH;
 
 typedef struct {
-	__u8 type;
-	__u8 subtype;
-	__u16 length;
-	__u16 vendor;
-	__u16 product;
-	__u8  class;
-	__u8  subclass;
-	__u8  protocol;
+	uint8_t type;
+	uint8_t subtype;
+	uint16_t length;
+	uint16_t vendor;
+	uint16_t product;
+	uint8_t  class;
+	uint8_t  subclass;
+	uint8_t  protocol;
 } __attribute__((packed)) USB_CLASS_DEVICE_PATH;
 
 typedef struct {
-	__u8 type;
-	__u8 subtype;
-	__u16 length;
-	__u32 tid;
+	uint8_t type;
+	uint8_t subtype;
+	uint16_t length;
+	uint32_t tid;
 } __attribute__((packed)) I2O_DEVICE_PATH;
 
 typedef struct {
-	__u8 type;
-	__u8 subtype;
-	__u16 length;
-	__u8 macaddr[32];
-	__u8 iftype;
+	uint8_t type;
+	uint8_t subtype;
+	uint16_t length;
+	uint8_t macaddr[32];
+	uint8_t iftype;
 } __attribute__((packed)) MAC_ADDR_DEVICE_PATH;
 
 typedef struct {
-	__u8 type;
-	__u8 subtype;
-	__u16 length;
-	__u32 local_ip;
-	__u32 remote_ip;
-	__u16 local_port;
-	__u16 remote_port;
-	__u16 protocol;
-	__u8  static_addr;
+	uint8_t type;
+	uint8_t subtype;
+	uint16_t length;
+	uint32_t local_ip;
+	uint32_t remote_ip;
+	uint16_t local_port;
+	uint16_t remote_port;
+	uint16_t protocol;
+	uint8_t  static_addr;
 } __attribute__((packed)) IPv4_DEVICE_PATH;
 
 typedef struct {
-	__u8 type;
-	__u8 subtype;
-	__u16 length;
-	__u8  local_ip[16];
-	__u8  remote_ip[16];
-	__u16 local_port;
-	__u16 remote_port;
-	__u16 protocol;
-	__u8  static_addr;
+	uint8_t type;
+	uint8_t subtype;
+	uint16_t length;
+	uint8_t  local_ip[16];
+	uint8_t  remote_ip[16];
+	uint16_t local_port;
+	uint16_t remote_port;
+	uint16_t protocol;
+	uint8_t  static_addr;
 } __attribute__((packed)) IPv6_DEVICE_PATH;
 
 typedef struct {
-	__u8 type;
-	__u8 subtype;
-	__u16 length;
-	__u32 reserved;
-	__u64 node_guid;
-	__u64 ioc_guid;
-	__u64 id; 
+	uint8_t type;
+	uint8_t subtype;
+	uint16_t length;
+	uint32_t reserved;
+	uint64_t node_guid;
+	uint64_t ioc_guid;
+	uint64_t id; 
 } __attribute__((packed)) INFINIBAND_DEVICE_PATH;
 
 typedef struct {
-	__u8 type;
-	__u8 subtype;
-	__u16 length;
-	__u32 reserved;
-	__u64 baud_rate;
-	__u8  data_bits;
-	__u8  parity;
-	__u8  stop_bits;
+	uint8_t type;
+	uint8_t subtype;
+	uint16_t length;
+	uint32_t reserved;
+	uint64_t baud_rate;
+	uint8_t  data_bits;
+	uint8_t  parity;
+	uint8_t  stop_bits;
 } __attribute__((packed)) UART_DEVICE_PATH;
 
 
 typedef struct {
-	__u8 type;
-	__u8 subtype;
-	__u16 length;
-	__u32 part_num;
-	__u64 start;
-	__u64 size;
-	__u8  signature[16];
-	__u8  mbr_type;
-	__u8  signature_type;
+	uint8_t type;
+	uint8_t subtype;
+	uint16_t length;
+	uint32_t part_num;
+	uint64_t start;
+	uint64_t size;
+	uint8_t  signature[16];
+	uint8_t  mbr_type;
+	uint8_t  signature_type;
 } __attribute__((packed)) HARDDRIVE_DEVICE_PATH;
 
 typedef struct {
-	__u8 type;
-	__u8 subtype;
-	__u16 length;
-	__u32 boot_entry;
-	__u64 start;
-	__u64 size;
+	uint8_t type;
+	uint8_t subtype;
+	uint16_t length;
+	uint32_t boot_entry;
+	uint64_t start;
+	uint64_t size;
 } __attribute__((packed)) CDROM_DEVICE_PATH;
 
 typedef struct {
-	__u8 type;
-	__u8 subtype;
-	__u16 length;
+	uint8_t type;
+	uint8_t subtype;
+	uint16_t length;
 	efi_char16_t path_name[1];
 } __attribute__((packed)) FILE_PATH_DEVICE_PATH;
 
 
 typedef struct {
-	__u8 type;
-	__u8 subtype;
-	__u16 length;
+	uint8_t type;
+	uint8_t subtype;
+	uint16_t length;
 	efi_guid_t guid;
 } __attribute__((packed)) MEDIA_PROTOCOL_DEVICE_PATH;
 
 typedef struct {
-	__u8 type;
-	__u8 subtype;
-	__u16 length;
-	__u16 device_type;
-	__u16 status_flag;
-	__u8  description[1];
+	uint8_t type;
+	uint8_t subtype;
+	uint16_t length;
+	uint16_t device_type;
+	uint16_t status_flag;
+	uint8_t  description[1];
 } __attribute__((packed)) BIOS_BOOT_SPEC_DEVICE_PATH;
 
 typedef struct {
-	__u8  type;
-	__u8  subtype;
-	__u16 length;
+	uint8_t  type;
+	uint8_t  subtype;
+	uint16_t length;
 } __attribute__((packed)) END_DEVICE_PATH;
 
 	
--- src/include/efibootmgr.h
+++ src/include/efibootmgr.h	2001/05/16 10:12:55
@@ -26,7 +26,7 @@
 	char *loader;
 	char *label;
 	char *bootorder;
-	__u32 part;
+	uint32_t part;
 	int edd_version;
 	int edd10_devicenum;
 	int bootnum;
--- src/include/gpt.h
+++ src/include/gpt.h	2001/05/16 10:13:19
@@ -26,7 +26,7 @@
 #define _GPT_H
 
 
-#include <linux/types.h>
+#include <stdint.h>
 #include "efi.h"
 
 #define EFI_PMBR_OSTYPE_EFI 0xEF
@@ -61,34 +61,34 @@
     ((efi_guid_t) { 0x8da63339, 0x0007, 0x60c0, { 0xc4, 0x36, 0x08, 0x3a, 0xc8, 0x23, 0x09, 0x08 }})
 
 typedef struct _GuidPartitionTableHeader_t {
-	__u64 Signature;
-	__u32 Revision;
-	__u32 HeaderSize;
-	__u32 HeaderCRC32;
-	__u32 Reserved1;
-	__u64 MyLBA;
-	__u64 AlternateLBA;
-	__u64 FirstUsableLBA;
-	__u64 LastUsableLBA;
+	uint64_t Signature;
+	uint32_t Revision;
+	uint32_t HeaderSize;
+	uint32_t HeaderCRC32;
+	uint32_t Reserved1;
+	uint64_t MyLBA;
+	uint64_t AlternateLBA;
+	uint64_t FirstUsableLBA;
+	uint64_t LastUsableLBA;
 	efi_guid_t DiskGUID;
-	__u64 PartitionEntryLBA;
-	__u32 NumberOfPartitionEntries;
-	__u32 SizeOfPartitionEntry;
-	__u32 PartitionEntryArrayCRC32;
-	__u8 Reserved2[GPT_BLOCK_SIZE - 92];
+	uint64_t PartitionEntryLBA;
+	uint32_t NumberOfPartitionEntries;
+	uint32_t SizeOfPartitionEntry;
+	uint32_t PartitionEntryArrayCRC32;
+	uint8_t Reserved2[GPT_BLOCK_SIZE - 92];
 } __attribute__ ((packed)) GuidPartitionTableHeader_t;
 
 typedef struct _GuidPartitionEntryAttributes_t {
-	__u64 RequiredToFunction:1;
-	__u64 Reserved:47;
-        __u64 GuidSpecific:16;
+	uint64_t RequiredToFunction:1;
+	uint64_t Reserved:47;
+        uint64_t GuidSpecific:16;
 } __attribute__ ((packed)) GuidPartitionEntryAttributes_t;
 
 typedef struct _GuidPartitionEntry_t {
 	efi_guid_t PartitionTypeGuid;
 	efi_guid_t UniquePartitionGuid;
-	__u64 StartingLBA;
-	__u64 EndingLBA;
+	uint64_t StartingLBA;
+	uint64_t EndingLBA;
 	GuidPartitionEntryAttributes_t Attributes;
 	efi_char16_t PartitionName[72 / sizeof(efi_char16_t)];
 } __attribute__ ((packed)) GuidPartitionEntry_t;
@@ -110,20 +110,20 @@
 
 
 typedef struct _PartitionRecord_t {
-	__u8 BootIndicator;	/* Not used by EFI firmware. Set to 0x80 to indicate that this
+	uint8_t BootIndicator;	/* Not used by EFI firmware. Set to 0x80 to indicate that this
 				   is the bootable legacy partition. */
-	__u8 StartHead;		/* Start of partition in CHS address, not used by EFI firmware. */
-	__u8 StartSector;	/* Start of partition in CHS address, not used by EFI firmware. */
-	__u8 StartTrack;	/* Start of partition in CHS address, not used by EFI firmware. */
-	__u8 OSType;		/* OS type. A value of 0xEF defines an EFI system partition.
+	uint8_t StartHead;		/* Start of partition in CHS address, not used by EFI firmware. */
+	uint8_t StartSector;	/* Start of partition in CHS address, not used by EFI firmware. */
+	uint8_t StartTrack;	/* Start of partition in CHS address, not used by EFI firmware. */
+	uint8_t OSType;		/* OS type. A value of 0xEF defines an EFI system partition.
 				   Other values are reserved for legacy operating systems, and
 				   allocated independently of the EFI specification. */
-	__u8 EndHead;		/* End of partition in CHS address, not used by EFI firmware. */
-	__u8 EndSector;		/* End of partition in CHS address, not used by EFI firmware. */
-	__u8 EndTrack;		/* End of partition in CHS address, not used by EFI firmware. */
-	__u32 StartingLBA;	/* Starting LBA address of the partition on the disk. Used by
+	uint8_t EndHead;		/* End of partition in CHS address, not used by EFI firmware. */
+	uint8_t EndSector;		/* End of partition in CHS address, not used by EFI firmware. */
+	uint8_t EndTrack;		/* End of partition in CHS address, not used by EFI firmware. */
+	uint32_t StartingLBA;	/* Starting LBA address of the partition on the disk. Used by
 				   EFI firmware to define the start of the partition. */
-	__u32 SizeInLBA;	/* Size of partition in LBA. Used by EFI firmware to determine
+	uint32_t SizeInLBA;	/* Size of partition in LBA. Used by EFI firmware to determine
 				   the size of the partition. */
 } __attribute__ ((packed)) PartitionRecord_t;
 
@@ -132,11 +132,11 @@
 /* Needs to be packed because the u16s force misalignment. */
 
 typedef struct _LegacyMBR_t {
-	__u8 BootCode[440];
-	__u32 UniqueMBRSignature;
-	__u16 Unknown;
+	uint8_t BootCode[440];
+	uint32_t UniqueMBRSignature;
+	uint16_t Unknown;
 	PartitionRecord_t PartitionRecord[4];
-	__u16 Signature;
+	uint16_t Signature;
 } __attribute__ ((packed)) LegacyMBR_t;
 
 
@@ -146,10 +146,10 @@
 
 /* Functions */
 int gpt_disk_get_partition_info (int fd, 
-                                 __u32 num,
-                                 __u64 *start, __u64 *size,
+                                 uint32_t num,
+                                 uint64_t *start, uint64_t *size,
                                  char *signature,
-                                 __u8 *mbr_type, __u8 *signature_type);
+                                 uint8_t *mbr_type, uint8_t *signature_type);
 
 
 #endif
--- src/include/scsi_ioctls.h
+++ src/include/scsi_ioctls.h	2001/05/16 10:18:03
@@ -21,6 +21,7 @@
 #ifndef _SCSI_IOCTLS_H
 #define _SCSI_IOCTLS_H 
 
+#include <stdint.h>
 
 
 /* Snagged from linux/include/scsi/scsi.h */
@@ -28,8 +29,8 @@
 #define SCSI_IOCTL_GET_PCI   0x5387
 
 typedef struct scsi_idlun {
-	__u32 dev_id;
-	__u32 host_unique_id;
+	uint32_t dev_id;
+	uint32_t host_unique_id;
 } Scsi_Idlun;
 
 
--- src/include/unparse_path.h
+++ src/include/unparse_path.h	2001/05/16 10:13:57
@@ -21,14 +21,14 @@
 #ifndef _UNPARSE_PATH_H
 #define _UNPARSE_PATH_H
 
-#include <linux/types.h>
+#include <stdint.h>
 #include "efi.h"
 
 #define OFFSET_OF(struct_type, member)    \
     ((unsigned long) ((char *) &((struct_type*) 0)->member))
 
-__u64 unparse_path(char *buffer, EFI_DEVICE_PATH *path, __u16 pathsize);
-void dump_raw_data(void *data, __u64 length);
+uint64_t unparse_path(char *buffer, EFI_DEVICE_PATH *path, uint16_t pathsize);
+void dump_raw_data(void *data, uint64_t length);
 
 
 #endif
--- src/lib/crc32.c
+++ src/lib/crc32.c	2001/05/16 10:14:17
@@ -48,9 +48,9 @@
   /*                                                                        */
   /*  --------------------------------------------------------------------  */
 
-#include<linux/types.h>
+#include <stdint.h>
 
-static __u32 crc32_tab[] = {
+static uint32_t crc32_tab[] = {
       0x00000000L, 0x77073096L, 0xee0e612cL, 0x990951baL, 0x076dc419L,
       0x706af48fL, 0xe963a535L, 0x9e6495a3L, 0x0edb8832L, 0x79dcb8a4L,
       0xe0d5e91eL, 0x97d2d988L, 0x09b64c2bL, 0x7eb17cbdL, 0xe7b82d07L,
@@ -107,11 +107,11 @@
 
 /* Return a 32-bit CRC of the contents of the buffer. */
 
-__u32
-crc32(const void *buf, unsigned long len, __u32 seed)
+uint32_t
+crc32(const void *buf, unsigned long len, uint32_t seed)
 {
   unsigned long i;
-  register __u32 crc32val;
+  register uint32_t crc32val;
   const unsigned char *s = buf;
 
   crc32val = seed;
--- src/lib/disk.c
+++ src/lib/disk.c	2001/05/16 10:14:34
@@ -20,7 +20,7 @@
 
 #include <stdio.h>
 #include <string.h>
-#include <linux/types.h>
+#include <stdint.h>
 #include <sys/types.h>
 #include <sys/stat.h>
 #include <fcntl.h>
@@ -38,7 +38,7 @@
 {
 	struct stat buf;
 	int rc;
-	__u64 major;
+	uint64_t major;
 	unsigned char minor;
 	memset(&buf, 0, sizeof(struct stat));
 	rc = fstat(fd, &buf);
@@ -283,8 +283,8 @@
 
 static int
 msdos_disk_get_extended_partition_info (int fd, LegacyMBR_t *mbr,
-					__u32 num,
-					__u64 *start, __u64 *size)
+					uint32_t num,
+					uint64_t *start, uint64_t *size)
 {
         /* Until I can handle these... */
         fprintf(stderr, "Extended partition info not supported.\n");
@@ -306,17 +306,17 @@
 
 static int
 msdos_disk_get_partition_info (int fd, LegacyMBR_t *mbr,
-			       __u32 num,
-			       __u64 *start, __u64 *size,
+			       uint32_t num,
+			       uint64_t *start, uint64_t *size,
 			       char *signature,
-			       __u8 *mbr_type, __u8 *signature_type)
+			       uint8_t *mbr_type, uint8_t *signature_type)
 {	
 
 	long disk_size=0;
 
 	*mbr_type = 0x01;
 	*signature_type = 0x01;
-	*(__u32 *)signature = mbr->UniqueMBRSignature;
+	*(uint32_t *)signature = mbr->UniqueMBRSignature;
 
         if (num > 4) {
 		/* Extended partition */
@@ -356,10 +356,10 @@
 
 int
 disk_get_partition_info (int fd, 
-			 __u32 num,
-			 __u64 *start, __u64 *size,
+			 uint32_t num,
+			 uint64_t *start, uint64_t *size,
 			 char *signature,
-			 __u8 *mbr_type, __u8 *signature_type)
+			 uint8_t *mbr_type, uint8_t *signature_type)
 {
 	LegacyMBR_t mbr;
 	off_t offset;
--- src/lib/efi.c
+++ src/lib/efi.c	2001/05/16 10:16:03
@@ -18,6 +18,8 @@
     Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#define _FILE_OFFSET_BITS 64
+
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
@@ -25,7 +27,7 @@
 #include <sys/types.h>
 #include <sys/stat.h>
 #include <fcntl.h>
-#include <linux/limits.h>
+#include <limits.h>
 #include <unistd.h>
 #include "efi.h"
 #include "efichar.h"
@@ -33,16 +35,13 @@
 #include "disk.h"
 #include "efibootmgr.h"
 
-#define __USE_LARGEFILE64
-#define __USE_FILEOFFSET64
-
 EFI_DEVICE_PATH *
 load_option_path(EFI_LOAD_OPTION *option)
 {
 	char *p = (char *) option;
 	return (EFI_DEVICE_PATH *)
-		(p + sizeof(__u32) /* Attributes */
-		 + sizeof(__u16)   /* FilePathListLength*/
+		(p + sizeof(uint32_t) /* Attributes */
+		 + sizeof(uint16_t)   /* FilePathListLength*/
 		 + efichar_strsize(option->description)); /* Description */
 }
 
@@ -168,12 +167,12 @@
   EFI_DEVICE_PATH, 0x01 (Hardware), 0x04 (Vendor), length 0x0018
   This needs to know what EFI device has the boot device.
 */
-static __u16
-make_edd10_device_path(void *buffer, __u32 hardware_device)
+static uint16_t
+make_edd10_device_path(void *buffer, uint32_t hardware_device)
 {
 	VENDOR_DEVICE_PATH *hw = buffer;
 	efi_guid_t guid = EDD10_HARDWARE_VENDOR_PATH_GUID;
-	__u32 *data = (__u32 *)hw->data;
+	uint32_t *data = (uint32_t *)hw->data;
 	hw->type = 0x01; /* Hardware Device Path */
 	hw->subtype = 0x04; /* Vendor */
 	hw->length = 24;
@@ -184,7 +183,7 @@
 
 
 
-static __u16
+static uint16_t
 make_end_device_path(void *buffer)
 {
 	END_DEVICE_PATH *p = buffer;
@@ -195,8 +194,8 @@
 }
 
 
-static __u16
-make_acpi_device_path(void *buffer, __u32 _HID, __u32 _UID)
+static uint16_t
+make_acpi_device_path(void *buffer, uint32_t _HID, uint32_t _UID)
 {
 	ACPI_DEVICE_PATH *p = buffer;
 	p->type = 2;
@@ -207,8 +206,8 @@
 	return p->length;
 }
 
-static __u16
-make_pci_device_path(void *buffer, __u8 device, __u8 function)
+static uint16_t
+make_pci_device_path(void *buffer, uint8_t device, uint8_t function)
 {
 	PCI_DEVICE_PATH *p = buffer;
 	p->type = 1;
@@ -219,8 +218,8 @@
 	return p->length;
 }
 
-static __u16
-make_scsi_device_path(void *buffer, __u16 id, __u16 lun)
+static uint16_t
+make_scsi_device_path(void *buffer, uint16_t id, uint16_t lun)
 {
 	SCSI_DEVICE_PATH *p = buffer;
 	p->type = 3;
@@ -231,10 +230,10 @@
 	return p->length;
 }
 
-static __u16
-make_harddrive_device_path(void *buffer, __u32 num, __u64 start, __u64 size,
-			   __u8 *signature,
-			   __u8 mbr_type, __u8 signature_type)
+static uint16_t
+make_harddrive_device_path(void *buffer, uint32_t num, uint64_t start, uint64_t size,
+			   uint8_t *signature,
+			   uint8_t mbr_type, uint8_t signature_type)
 {
 	HARDDRIVE_DEVICE_PATH *p = buffer;
 	p->type = 4;
@@ -249,7 +248,7 @@
 	return p->length;
 }
 
-static __u16
+static uint16_t
 make_file_path_device_path(void *buffer, efi_char16_t *name)
 {
 	FILE_PATH_DEVICE_PATH *p = buffer;
@@ -303,8 +302,8 @@
 	efi_char16_t description[40];
 	efi_char16_t os_loader_path[40];
 	int rc, edd_version=0;
-	__u64 start=0, size=0;
-	__u8 mbr_type=0, signature_type=0;
+	uint64_t start=0, size=0;
+	uint8_t mbr_type=0, signature_type=0;
 	char signature[16];
 	long datasize=0;
 
@@ -314,9 +313,9 @@
 	if (opts.active) load_option->attributes = LOAD_OPTION_ACTIVE;
 	else             load_option->attributes = 0;
 
-	p += sizeof(__u32);
+	p += sizeof(uint32_t);
 	/* skip writing file_path_list_length */
-	p += sizeof(__u16);
+	p += sizeof(uint16_t);
 	/* Write description.  This is the text that appears on the screen for the load option. */
 	memset(description, 0, sizeof(description));
 	efichar_from_char(description, opts.label, sizeof(description));
@@ -366,7 +365,7 @@
 
 	load_option->file_path_list_length = p - q;
 
-	datasize = (__u8 *)p - (__u8 *)data;
+	datasize = (uint8_t *)p - (uint8_t *)data;
 	return datasize;
 }
 
--- src/lib/gpt.c
+++ src/lib/gpt.c	2001/05/16 10:18:19
@@ -26,7 +26,7 @@
 #include <stdio.h>
 #include <string.h>
 #include <stdlib.h>
-#include <linux/types.h>
+#include <stdint.h>
 #include <sys/stat.h>
 #include <sys/ioctl.h>
 #include <fcntl.h>
@@ -39,7 +39,7 @@
 #define BLKGETLASTSECT  _IO(0x12,108) /* get last sector of block device */
 #define BLKGETSIZE      _IO(0x12,96)  /* return device size */
 
-static struct blkdev_ioctl_param {
+struct blkdev_ioctl_param {
         unsigned int block;
         size_t content_length;
         char * block_contents;
@@ -59,7 +59,7 @@
  * but seeds the function with ~0, and xor's with ~0 at the end.
  ************************************************************/
 
-static inline __u32
+static inline uint32_t
 efi_crc32(const void *buf, unsigned long len)
 {
   return (crc32(buf, len, ~0L) ^ ~0L);
@@ -95,11 +95,11 @@
  *    blocks of 2. :(
  ************************************************************/
 
-static __u64
+static uint64_t
 LastLBA(int filedes)
 {
   int rc;
-  __u64 sectors = 0;
+  uint64_t sectors = 0;
   struct stat s;
   memset(&s, 0, sizeof(s));
   rc = fstat(filedes, &s);
@@ -141,7 +141,7 @@
 
 
 static inline int
-IsLBAValid(int fd, __u64 lba)
+IsLBAValid(int fd, uint64_t lba)
 {
 	return (lba <= LastLBA(fd));
 }
@@ -149,7 +149,7 @@
 
 
 static int
-read_lastoddsector(int fd, __u64 lba, void *buffer, size_t count)
+read_lastoddsector(int fd, uint64_t lba, void *buffer, size_t count)
 {
         int rc;
         struct blkdev_ioctl_param ioctl_param;
@@ -169,7 +169,7 @@
 
 
 static int
-ReadLBA(int fd, __u64 lba, void *buffer, size_t bytes)
+ReadLBA(int fd, uint64_t lba, void *buffer, size_t bytes)
 {
         off_t offset = lba * 512;
 
@@ -242,7 +242,7 @@
  ************************************************************/
 static GuidPartitionTableHeader_t *
 ReadGuidPartitionTableHeader(int fd,
-                             __u64 lba)
+                             uint64_t lba)
 {
 	GuidPartitionTableHeader_t *gpt;
 	gpt = (GuidPartitionTableHeader_t *)
@@ -275,12 +275,12 @@
 
 
 static int
-IsGuidPartitionTableValid(int fd, __u64 lba,
+IsGuidPartitionTableValid(int fd, uint64_t lba,
 			  GuidPartitionTableHeader_t ** gpt,
 			  GuidPartitionEntry_t ** ptes)
 {
 	int rc = 0;		/* default to not valid */
-	__u32 crc, origcrc;
+	uint32_t crc, origcrc;
         
         if (!gpt || !ptes) return rc;
 
@@ -366,7 +366,7 @@
 {
 	int rc = 0;
 	GuidPartitionEntry_t *pptes = NULL, *aptes = NULL;
-	__u64 lastlba;
+	uint64_t lastlba;
 
 
 	lastlba = LastLBA(fd);
@@ -424,10 +424,10 @@
 
 int
 gpt_disk_get_partition_info (int fd, 
-                             __u32 num,
-                             __u64 *start, __u64 *size,
+                             uint32_t num,
+                             uint64_t *start, uint64_t *size,
                              char *signature,
-                             __u8 *mbr_type, __u8 *signature_type)
+                             uint8_t *mbr_type, uint8_t *signature_type)
 {	
         GuidPartitionTableHeader_t * pgpt=NULL, * agpt=NULL, *gpt = NULL;
         GuidPartitionEntry_t       * ptes=NULL, *p;
--- src/lib/scsi_ioctls.c
+++ src/lib/scsi_ioctls.c	2001/05/16 10:17:19
@@ -19,10 +19,9 @@
  */
 
 #include <stdio.h>
-#include <pci/pci.h>
+#include <sys/pci.h>
 #include <sys/types.h>
 #include <sys/stat.h>
-#include <linux/types.h>
 #include <fcntl.h>
 #include <sys/ioctl.h>
 #include "scsi_ioctls.h"
--- src/lib/unparse_path.c
+++ src/lib/unparse_path.c	2001/05/16 10:17:36
@@ -19,7 +19,7 @@
  */
 
 #include <stdio.h>
-#include <linux/types.h>
+#include <stdint.h>
 #include <sys/types.h>
 #include <sys/stat.h>
 #include <fcntl.h>
@@ -33,12 +33,12 @@
 
 
 void
-dump_raw_data(void *data, __u64 length)
+dump_raw_data(void *data, uint64_t length)
 {
 	char buffer1[80], buffer2[80], *b1, *b2, c;
 	unsigned char *p = data;
 	unsigned long column=0;
-	__u64 length_printed = 0;
+	uint64_t length_printed = 0;
 	const char maxcolumn = 16;
 	while (length_printed < length) {
 		b1 = buffer1;
@@ -67,9 +67,9 @@
 
 
 static int
-unparse_raw(char *buffer, __u8 *p, __u64 length)
+unparse_raw(char *buffer, uint8_t *p, uint64_t length)
 {
-	__u64 i; unsigned char c;
+	uint64_t i; unsigned char c;
 	char *q = buffer;
 	for (i=0; i<length; i++) {
 		c = p[i];
@@ -99,7 +99,7 @@
 static int
 unparse_vendor_path(char *buffer, VENDOR_DEVICE_PATH *path)
 {
-	char text_guid[40], *p = buffer, *q = (__u8 *)path + 20;
+	char text_guid[40], *p = buffer, *q = (uint8_t *)path + 20;
 	efi_guid_unparse(&path->vendor_guid, text_guid);
 	p += sprintf(p, "Vendor(%s,", text_guid);
 	p += unparse_raw(p, q, path->length - 20);
@@ -188,7 +188,7 @@
 		sprintf(sig, "None");
 		break;
 	case 0x01:
-		sprintf(sig, "%08x", *(__u32 *)hd->signature);
+		sprintf(sig, "%08x", *(uint32_t *)hd->signature);
 		break;
 	case 0x02: /* GPT */
                 efi_guid_unparse((efi_guid_t *)hd->signature, sig);
@@ -243,7 +243,7 @@
 unparse_bios_path(char *buffer, EFI_DEVICE_PATH *path)
 {
 	BIOS_BOOT_SPEC_DEVICE_PATH *bios = (BIOS_BOOT_SPEC_DEVICE_PATH *)path;
-	char *p = buffer, *q = (__u8 *)path + 8;
+	char *p = buffer, *q = (uint8_t *)path + 8;
 	p += sprintf(p, "BIOS(%x,%x,",
 		     bios->device_type, bios->status_flag);
 	p += unparse_raw(p, q, path->length - 8);
@@ -252,10 +252,10 @@
 }
 
 
-__u64
-unparse_path(char *buffer, EFI_DEVICE_PATH *path, __u16 pathsize)
+uint64_t
+unparse_path(char *buffer, EFI_DEVICE_PATH *path, uint16_t pathsize)
 {
-	__u16 parsed_length = 0;
+	uint16_t parsed_length = 0;
 	char *p = buffer;
 	int exit_now = 0;
 
@@ -289,7 +289,7 @@
 		}
 //		p += sprintf(p, "\\");
 		parsed_length += path->length;
-		path = (EFI_DEVICE_PATH *) ((__u8 *)path + path->length);
+		path = (EFI_DEVICE_PATH *) ((uint8_t *)path + path->length);
 	}
 
 	return p - buffer;
@@ -311,14 +311,14 @@
 compare_hardware_path_pci(EFI_DEVICE_PATH *path,
 			  int device, int func)
 {
-	__u8 *p = ((void *)path) + OFFSET_OF(EFI_DEVICE_PATH, data);
-	__u8 path_device, path_func;
+	uint8_t *p = ((void *)path) + OFFSET_OF(EFI_DEVICE_PATH, data);
+	uint8_t path_device, path_func;
 
 	switch (path->subtype) {
 	case 1:
 		/* PCI */
-		path_func   = *(__u8 *)p;
-		path_device = *(__u8 *)(p+1);
+		path_func   = *(uint8_t *)p;
+		path_device = *(uint8_t *)(p+1);
 		
 		return !(path_func == func && path_device == device);
 		
@@ -332,14 +332,14 @@
 static int
 compare_hardware_path_scsi(EFI_DEVICE_PATH *path, int id, int lun)
 {
-	__u8 *p = ((void *)path) + OFFSET_OF(EFI_DEVICE_PATH, data);
-	__u16 path_id, path_lun;
+	uint8_t *p = ((void *)path) + OFFSET_OF(EFI_DEVICE_PATH, data);
+	uint16_t path_id, path_lun;
 
 	switch (path->subtype) {
 	case 2:
 		/* SCSI */
-		path_id   = *(__u16 *)p;
-		path_lun = *(__u16 *)(p+2);
+		path_id   = *(uint16_t *)p;
+		path_lun = *(uint16_t *)(p+2);
 		
 		return !(path_id == id && path_lun == lun);
 		break;
@@ -352,14 +352,14 @@
 static int
 compare_hardware_path_acpi(EFI_DEVICE_PATH *path, int bus)
 {
-	__u8 *p = ((void *)path) + OFFSET_OF(EFI_DEVICE_PATH, data);
-	__u32 _HID, _UID;
+	uint8_t *p = ((void *)path) + OFFSET_OF(EFI_DEVICE_PATH, data);
+	uint32_t _HID, _UID;
 
 	switch (path->subtype) {
 	case 1:
 		/* ACPI */
-		_HID = *(__u32 *)p;
-		_UID = *(__u32 *)(p+4);
+		_HID = *(uint32_t *)p;
+		_UID = *(uint32_t *)(p+4);
 		
 		/* FIXME: Need to convert _HID and _UID to bus number */
 
@@ -372,8 +372,8 @@
 }
 
 static int
-compare_media_path_harddrive(EFI_DEVICE_PATH *path, __u32 num,
-			     __u64 start, __u64 size)
+compare_media_path_harddrive(EFI_DEVICE_PATH *path, uint32_t num,
+			     uint64_t start, uint64_t size)
 {
 	HARDDRIVE_DEVICE_PATH *p = (HARDDRIVE_DEVICE_PATH *)path;
 	
@@ -397,11 +397,11 @@
 compare_pci_scsi_disk_blk(efi_variable_t *var,
 			  int bus, int device, int func,
 			  int host, int channel, int id, int lun,
-			  __u64 start, __u64 size)
+			  uint64_t start, uint64_t size)
 {
 
 	EFI_DEVICE_PATH *path = (EFI_DEVICE_PATH *) var->Data;
-	__u64 parsed_length = 0;
+	uint64_t parsed_length = 0;
 	int exit_now = 0;
 	int rc = 0;
 

--=-=-=--

