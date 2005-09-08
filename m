From: Martin Hicks <mort@sgi.com>
Date: Thu, 08 Sep 2005 15:26:30 +0000
Subject: Re: efi_memmapwalk re-write (please test)
Message-Id: <20050908152630.GC13449@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509062048.j86KmBPD004877@agluck-lia64.sc.intel.com>
In-Reply-To: <200509062048.j86KmBPD004877@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Wed, Sep 07, 2005 at 12:33:24PM -0700, Luck, Tony wrote:
> 
> >So its really close on sn2.  I'm not sure exactly what's going wrong,
> >but with the new efi_memmap_walk stuff something is getting clobbered, I think.
> 
> Martin,
> 
> Thanks for taking a look at this.
> 

Hi Tony,

Here's an update that is applied on top of your last patch that makes
this boot on sn2 again.  I also tested a zx1-based rx2600 machine.

I basically switched to doing all the page alignment right inside the
algorithm.

mh

-- 
Martin Hicks   ||   Silicon Graphics Inc.   ||   mort@sgi.com



Index: linux-2.6.13/arch/ia64/kernel/efi.c
=================================--- linux-2.6.13.orig/arch/ia64/kernel/efi.c	2005-09-08 07:48:06.000000000 -0700
+++ linux-2.6.13/arch/ia64/kernel/efi.c	2005-09-08 08:02:32.000000000 -0700
@@ -257,8 +257,8 @@ walk (efi_freemem_callback_t callback, v
 		if (k->attribute != attr)
 			continue;
 		start = (attr = EFI_MEMORY_WB) ? PAGE_OFFSET : __IA64_UNCACHED_OFFSET;
-		start += PAGE_ALIGN(k->start);
-		end = (start + (k->num_pages << EFI_PAGE_SHIFT)) & PAGE_MASK;
+		start += k->start;
+		end = start + (k->num_pages << EFI_PAGE_SHIFT);
 		if (start < end)
 			if ((*callback)(start, end, arg) < 0)
 				return;
@@ -712,7 +712,7 @@ efi_uart_console_only(void)
 static inline u64
 kmd_end(kern_memdesc_t *kmd)
 {
-	return (kmd->start + (kmd->num_pages << EFI_PAGE_SHIFT));
+	return kmd->start + efi_md_size(kmd);
 }
 
 static inline u64
@@ -831,7 +831,8 @@ efi_memmap_init(unsigned long *s, unsign
 	for (p = efi_map_start; p < efi_map_end; pmd = md, p += efi_desc_size) {
 		md = p;
 		if (!efi_wb(md)) {
-			if (efi_uc(md) && md->type = EFI_CONVENTIONAL_MEMORY) {
+			if (efi_uc(md) && (md->type = EFI_CONVENTIONAL_MEMORY ||
+				    	   md->type = EFI_BOOT_SERVICES_DATA)) {
 				k->attribute = EFI_MEMORY_UC;
 				k->start = md->phys_addr;
 				k->num_pages = md->num_pages;
@@ -909,13 +910,27 @@ efi_memmap_init(unsigned long *s, unsign
 			prev->num_pages += (ae - as) >> EFI_PAGE_SHIFT;
 			total_mem += ae - as;
 			continue;
+		} else if (prev) {
+			/*
+			 * Page align the end of the previous descriptor now
+			 * that we know no merging can be done.
+			 */
+			prev->num_pages = (efi_md_size(prev) & PAGE_MASK) >> EFI_PAGE_SHIFT;
+
+			/* Reuse negative- or zero-sized descriptors. */
+			if (kmd_end(prev) <= prev->start)
+				k--;
 		}
 		k->attribute = EFI_MEMORY_WB;
-		k->start = as;
-		k->num_pages = (ae - as) >> EFI_PAGE_SHIFT;
-		total_mem += ae - as;
+		k->start = PAGE_ALIGN(as);
+		k->num_pages = (ae - k->start) >> EFI_PAGE_SHIFT;
+		total_mem += ae - k->start;
 		prev = k++;
 	}
+
+	/* Get rid of the final descriptor if it is negative- or zero-sized. */
+	if (kmd_end(prev) <= prev->start)
+		k--;
 	k->start = ~0L; /* end-marker */
 
 	/* reserve the memory we are using for kern_memmap */
