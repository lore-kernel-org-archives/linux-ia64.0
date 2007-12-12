From: Aron Griffis <aron@hp.com>
Date: Wed, 12 Dec 2007 15:07:49 +0000
Subject: [PATCH 2 of 4] Spelling/punctuation fixes
Message-Id: <049467433cda01769d2f.1197472069@jenkins.nashua>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

# HG changeset patch
# User Aron Griffis <aron@hp.com>
# Date 1197470463 18000
# Node ID 049467433cda01769d2f8c276fcfeb7d216658d7
# Parent  1161690ae81590dec4e97c52f07cf1798c11a97b
Spelling/punctuation fixes

Woah is not a word ;-)

diff -r 1161690ae815 -r 049467433cda arch/ia64/kernel/efi.c
--- a/arch/ia64/kernel/efi.c	Tue Dec 11 21:53:55 2007 -0500
+++ b/arch/ia64/kernel/efi.c	Wed Dec 12 09:41:03 2007 -0500
@@ -331,7 +331,7 @@ efi_memmap_walk_uc (efi_freemem_callback
 }
 
 /*
- * Look for the PAL_CODE region reported by EFI and maps it using an
+ * Looks for the PAL_CODE region reported by EFI and maps it using an
  * ITR to enable safe PAL calls in virtual mode.  See IA-64 Processor
  * Abstraction Layer chapter 11 in ADAG
  */
@@ -372,7 +372,7 @@ efi_get_pal_addr (void)
 		 * PAL code is guaranteed to be aligned on a power of 2 between
 		 * 4k and 256KB and that only one ITR is needed to map it. This
 		 * implies that the PAL code is always aligned on its size,
-		 * i.e., the closest matching page size supported by the TLB.
+		 * i.e. the closest matching page size supported by the TLB.
 		 * Therefore PAL code is guaranteed never to cross a 64MB unless
 		 * it is bigger than 64MB (very unlikely!).  So for now the
 		 * following test is enough to determine whether or not we need
@@ -385,7 +385,7 @@ efi_get_pal_addr (void)
 		}
 
 		if (md->num_pages << EFI_PAGE_SHIFT > IA64_GRANULE_SIZE)
-			panic("Woah!  PAL code size bigger than a granule!");
+			panic("Whoa!  PAL code size bigger than a granule!");
 
 #if EFI_DEBUG
 		mask  = ~((1 << IA64_GRANULE_SHIFT) - 1);
@@ -435,7 +435,7 @@ efi_init (void)
 	int i;
 
 	/*
-	 * it's too early to be able to use the standard kernel command line
+	 * It's too early to be able to use the standard kernel command line
 	 * support...
 	 */
 	for (cp = boot_command_line; *cp; ) {
@@ -465,9 +465,9 @@ efi_init (void)
 	 * Verify the EFI Table
 	 */
 	if (efi.systab = NULL)
-		panic("Woah! Can't find EFI system table.\n");
+		panic("Whoa! Can't find EFI system table.\n");
 	if (efi.systab->hdr.signature != EFI_SYSTEM_TABLE_SIGNATURE)
-		panic("Woah! EFI system table signature incorrect\n");
+		panic("Whoa! EFI system table signature incorrect\n");
 	if ((efi.systab->hdr.revision >> 16) = 0)
 		printk(KERN_WARNING "Warning: EFI system table version "
 		       "%d.%02d, expected 1.00 or greater\n",
@@ -1201,7 +1201,7 @@ efi_initialize_iomem_resources(struct re
 		if ((res = kzalloc(sizeof(struct resource),
 				   GFP_KERNEL)) = NULL) {
 			printk(KERN_ERR 
-			       "failed to alocate resource for iomem\n");
+			       "failed to allocate resource for iomem\n");
 			return;
 		}
 


