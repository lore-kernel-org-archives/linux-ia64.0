From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 26 Sep 2003 21:07:44 +0000
Subject: Re: [PATCH] always print note when trimming EFI memory map
Message-Id: <marc-linux-ia64-106461078423482@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106444761123807@msgid-missing>
In-Reply-To: <marc-linux-ia64-106444761123807@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 26 September 2003 2:32 pm, David Mosberger wrote:
> The intention was to give the user an idea how much real & available
> memory is lost due to the trimming.  When reporting unavailable
> memory, you'll lose that info.  However, maybe we should be more
> verbose if EFI_DEBUG is enabled?

How about something like the following?  It still always prints a
note when trimming, but identifies "reserved" memory to distinguish
it from the normal case.

This is the second or third time I've had to debug the problem,
and the failure mode doesn't obviously point to EFI_DEBUG.  It
just MCAs because you try to access main memory with a UC access.
In fact, I think on most boxes you don't even get an MCA; it
just appears to work, even though it introduces attribute
aliasing.

=== arch/ia64/kernel/efi.c 1.23 vs edited ==--- 1.23/arch/ia64/kernel/efi.c	Wed Aug 27 10:47:27 2003
+++ edited/arch/ia64/kernel/efi.c	Fri Sep 26 17:33:36 2003
@@ -249,11 +249,11 @@
 	if (num_skipped_pages > md->num_pages)
 		num_skipped_pages = md->num_pages;
 
-	if (is_available_memory(md))
-		printk(KERN_NOTICE "efi.%s: ignoring %luKB of memory at 0x%lx due to granule hole "
-		       "at 0x%lx\n", __FUNCTION__,
-		       (num_skipped_pages << EFI_PAGE_SHIFT) >> 10,
-		       md->phys_addr, start_addr - IA64_GRANULE_SIZE);
+	printk(KERN_NOTICE "efi.%s: ignoring %luKB of %smemory at 0x%lx due to granule hole "
+	       "at 0x%lx\n", __FUNCTION__,
+	       (num_skipped_pages << EFI_PAGE_SHIFT) >> 10,
+	       is_available_memory(md) ? "" : "reserved ",
+	       md->phys_addr, start_addr - IA64_GRANULE_SIZE);
 	/*
 	 * NOTE: Don't set md->phys_addr to START_ADDR because that could cause the memory
 	 * descriptor list to become unsorted.  In such a case, md->num_pages will be
@@ -277,11 +277,11 @@
 	if (num_dropped_pages > md->num_pages)
 		num_dropped_pages = md->num_pages;
 
-	if (is_available_memory(md))
-		printk(KERN_NOTICE "efi.%s: ignoring %luKB of memory at 0x%lx due to granule hole "
-		       "at 0x%lx\n", __FUNCTION__,
-		       (num_dropped_pages << EFI_PAGE_SHIFT) >> 10,
-		       md->phys_addr, end_addr);
+	printk(KERN_NOTICE "efi.%s: ignoring %luKB of %smemory at 0x%lx due to granule hole "
+	       "at 0x%lx\n", __FUNCTION__,
+	       (num_dropped_pages << EFI_PAGE_SHIFT) >> 10,
+	       is_available_memory(md) ? "" : "reserved ",
+	       md->phys_addr, end_addr);
 	md->num_pages -= num_dropped_pages;
 }
 

