From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 24 Sep 2003 23:53:14 +0000
Subject: [PATCH] always print note when trimming EFI memory map
Message-Id: <marc-linux-ia64-106444761123807@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I think it would be a good idea to always print a note when trimming
the EFI memory map, even if it's not "available" memory.

I just debugged a problem where we trimmed out some memory that
contained ACPI tables.  When we went to look at a table later,
we used the wrong attribute because we couldn't find its address
in the EFI memory map.  This caused an MCA (uncached access to
memory).  Straightforward to debug, but the note would have
made it quicker.

This patch is against 2.5.

Bjorn

=== arch/ia64/kernel/efi.c 1.23 vs edited ==--- 1.23/arch/ia64/kernel/efi.c	Wed Aug 27 10:47:27 2003
+++ edited/arch/ia64/kernel/efi.c	Wed Sep 24 20:14:01 2003
@@ -249,11 +249,10 @@
 	if (num_skipped_pages > md->num_pages)
 		num_skipped_pages = md->num_pages;
 
-	if (is_available_memory(md))
-		printk(KERN_NOTICE "efi.%s: ignoring %luKB of memory at 0x%lx due to granule hole "
-		       "at 0x%lx\n", __FUNCTION__,
-		       (num_skipped_pages << EFI_PAGE_SHIFT) >> 10,
-		       md->phys_addr, start_addr - IA64_GRANULE_SIZE);
+	printk(KERN_NOTICE "efi.%s: ignoring %luKB of memory at 0x%lx due to granule hole "
+	       "at 0x%lx\n", __FUNCTION__,
+	       (num_skipped_pages << EFI_PAGE_SHIFT) >> 10,
+	       md->phys_addr, start_addr - IA64_GRANULE_SIZE);
 	/*
 	 * NOTE: Don't set md->phys_addr to START_ADDR because that could cause the memory
 	 * descriptor list to become unsorted.  In such a case, md->num_pages will be
@@ -277,11 +276,10 @@
 	if (num_dropped_pages > md->num_pages)
 		num_dropped_pages = md->num_pages;
 
-	if (is_available_memory(md))
-		printk(KERN_NOTICE "efi.%s: ignoring %luKB of memory at 0x%lx due to granule hole "
-		       "at 0x%lx\n", __FUNCTION__,
-		       (num_dropped_pages << EFI_PAGE_SHIFT) >> 10,
-		       md->phys_addr, end_addr);
+	printk(KERN_NOTICE "efi.%s: ignoring %luKB of memory at 0x%lx due to granule hole "
+	       "at 0x%lx\n", __FUNCTION__,
+	       (num_dropped_pages << EFI_PAGE_SHIFT) >> 10,
+	       md->phys_addr, end_addr);
 	md->num_pages -= num_dropped_pages;
 }
 

