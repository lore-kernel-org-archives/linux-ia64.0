From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 12 Apr 2007 19:15:40 +0000
Subject: [patch] EFI: warn only for pre-1.00 system tables
Message-Id: <200704121315.40754.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

We used to warn unless the EFI system table major revision was exactly 1.
But EFI 2.00 firmware is starting to appear, and the 2.00 changes don't
affect anything in Linux.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: w/include/linux/efi.h
=================================--- w.orig/include/linux/efi.h	2007-04-12 13:07:13.000000000 -0600
+++ w/include/linux/efi.h	2007-04-12 13:07:15.000000000 -0600
@@ -213,7 +213,6 @@
 } efi_config_table_t;
 
 #define EFI_SYSTEM_TABLE_SIGNATURE ((u64)0x5453595320494249ULL)
-#define EFI_SYSTEM_TABLE_REVISION  ((1 << 16) | 00)
 
 typedef struct {
 	efi_table_hdr_t hdr;
Index: w/arch/i386/kernel/efi.c
=================================--- w.orig/arch/i386/kernel/efi.c	2007-04-12 13:07:13.000000000 -0600
+++ w/arch/i386/kernel/efi.c	2007-04-12 13:07:15.000000000 -0600
@@ -349,14 +349,12 @@
 		printk(KERN_ERR PFX "Woah! Couldn't map the EFI system table.\n");
 	if (efi.systab->hdr.signature != EFI_SYSTEM_TABLE_SIGNATURE)
 		printk(KERN_ERR PFX "Woah! EFI system table signature incorrect\n");
-	if ((efi.systab->hdr.revision ^ EFI_SYSTEM_TABLE_REVISION) >> 16 != 0)
-		printk(KERN_ERR PFX
-		       "Warning: EFI system table major version mismatch: "
-		       "got %d.%02d, expected %d.%02d\n",
+	if ((efi.systab->hdr.revision >> 16) = 0)
+		printk(KERN_ERR PFX "Warning: EFI system table version "
+		       "%d.%02d, expected 1.00 or greater\n",
 		       efi.systab->hdr.revision >> 16,
-		       efi.systab->hdr.revision & 0xffff,
-		       EFI_SYSTEM_TABLE_REVISION >> 16,
-		       EFI_SYSTEM_TABLE_REVISION & 0xffff);
+		       efi.systab->hdr.revision & 0xffff);
+
 	/*
 	 * Grab some details from the system table
 	 */
Index: w/arch/ia64/kernel/efi.c
=================================--- w.orig/arch/ia64/kernel/efi.c	2007-04-12 13:07:13.000000000 -0600
+++ w/arch/ia64/kernel/efi.c	2007-04-12 13:07:15.000000000 -0600
@@ -448,11 +448,11 @@
 		panic("Woah! Can't find EFI system table.\n");
 	if (efi.systab->hdr.signature != EFI_SYSTEM_TABLE_SIGNATURE)
 		panic("Woah! EFI system table signature incorrect\n");
-	if ((efi.systab->hdr.revision ^ EFI_SYSTEM_TABLE_REVISION) >> 16 != 0)
-		printk(KERN_WARNING "Warning: EFI system table major version mismatch: "
-		       "got %d.%02d, expected %d.%02d\n",
-		       efi.systab->hdr.revision >> 16, efi.systab->hdr.revision & 0xffff,
-		       EFI_SYSTEM_TABLE_REVISION >> 16, EFI_SYSTEM_TABLE_REVISION & 0xffff);
+	if ((efi.systab->hdr.revision >> 16) = 0)
+		printk(KERN_WARNING "Warning: EFI system table version "
+		       "%d.%02d, expected 1.00 or greater\n",
+		       efi.systab->hdr.revision >> 16,
+		       efi.systab->hdr.revision & 0xffff);
 
 	config_tables = __va(efi.systab->tables);
 
Index: w/arch/ia64/hp/sim/boot/fw-emu.c
=================================--- w.orig/arch/ia64/hp/sim/boot/fw-emu.c	2007-04-12 13:07:13.000000000 -0600
+++ w/arch/ia64/hp/sim/boot/fw-emu.c	2007-04-12 13:07:15.000000000 -0600
@@ -287,7 +287,7 @@
 
 	memset(efi_systab, 0, sizeof(efi_systab));
 	efi_systab->hdr.signature = EFI_SYSTEM_TABLE_SIGNATURE;
-	efi_systab->hdr.revision  = EFI_SYSTEM_TABLE_REVISION;
+	efi_systab->hdr.revision  = ((1 << 16) | 00);
 	efi_systab->hdr.headersize = sizeof(efi_systab->hdr);
 	efi_systab->fw_vendor = __pa("H\0e\0w\0l\0e\0t\0t\0-\0P\0a\0c\0k\0a\0r\0d\0\0");
 	efi_systab->fw_revision = 1;
