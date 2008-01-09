From: Aron Griffis <aron@hp.com>
Date: Wed, 09 Jan 2008 03:29:37 +0000
Subject: [PATCH 2 of 3] Spelling/punctuation fixes
Message-Id: <bc50f0946b69ca50acc9.1199849377@jenkins.nashua>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

1 file changed, 8 insertions(+), 8 deletions(-)
arch/ia64/kernel/efi.c |   16 ++++++++--------


Incorporates the suggestions from Peter Chubb the last time I submitted
this.  This called for using the same verb tense in the couple of preceding
comments as well.

Signed-off-by: Aron Griffis <aron@hp.com>

diff -r 75e99ef90c59 -r bc50f0946b69 arch/ia64/kernel/efi.c
--- a/arch/ia64/kernel/efi.c	Tue Jan 08 22:29:29 2008 -0500
+++ b/arch/ia64/kernel/efi.c	Tue Jan 08 22:29:33 2008 -0500
@@ -311,7 +311,7 @@ walk (efi_freemem_callback_t callback, v
 }
 
 /*
- * Walks the EFI memory map and calls CALLBACK once for each EFI memory
+ * Walk the EFI memory map and call CALLBACK once for each EFI memory
  * descriptor that has memory that is available for OS use.
  */
 void
@@ -321,7 +321,7 @@ efi_memmap_walk (efi_freemem_callback_t 
 }
 
 /*
- * Walks the EFI memory map and calls CALLBACK once for each EFI memory
+ * Walk the EFI memory map and call CALLBACK once for each EFI memory
  * descriptor that has memory that is available for uncached allocator.
  */
 void
@@ -331,7 +331,7 @@ efi_memmap_walk_uc (efi_freemem_callback
 }
 
 /*
- * Look for the PAL_CODE region reported by EFI and maps it using an
+ * Look for the PAL_CODE region reported by EFI and map it using an
  * ITR to enable safe PAL calls in virtual mode.  See IA-64 Processor
  * Abstraction Layer chapter 11 in ADAG
  */
@@ -385,7 +385,7 @@ efi_get_pal_addr (void)
 		}
 
 		if (efi_md_size(md) > IA64_GRANULE_SIZE)
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
@@ -1195,7 +1195,7 @@ efi_initialize_iomem_resources(struct re
 		if ((res = kzalloc(sizeof(struct resource),
 				   GFP_KERNEL)) = NULL) {
 			printk(KERN_ERR 
-			       "failed to alocate resource for iomem\n");
+			       "failed to allocate resource for iomem\n");
 			return;
 		}
 


