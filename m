From: Khalid Aziz <khalid_aziz@hp.com>
Date: Sat, 08 Jan 2005 00:00:52 +0000
Subject: [PATCH] Rewrite of EFI memory map walk code
Message-Id: <1105142452.22767.12.camel@lyra.fc.hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-yB2965R8KALofTo5NNyc"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--=-yB2965R8KALofTo5NNyc
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

In an attempt to simplify EFI emmory range management and EFI memory map
walk, I have rewritten how EFI memory map is managed in the kernel. Here
is how I have approached this code. I am walking the EFI memory map and
from there I am constructing a linked list of valid memory ranges for
kernel to use. To find space to store this linked list in, from within
reserve_memory(), I walk the EFI memory map and look for the smallest
granule aligned block that will be sufficient to hold the linked list.
Amount of space I am allocating for linked list is the number of entries
in efi_memmap + another few for safety margin. I then mark this memory
reserved.

I have added two new functions - efi_gather_memory() which walks the EFI
memory map and builds a linked list of kernel usable memory map, and
efi_trim_memory() which applies the "max_addr=" and "mem=" restrictions
by splitting the linked list of kernel uable memory ranges
appropriately. Each node in this linked list has a field called
"ignore". To trim a memory range, I can split the list at approrpiate
point and mark every node in the list from that point onwards as ignored
by setting this field.

I rewrote efi_memmap_walk() to use the new kern_memmap list. I have also
replaced occurences of "md->num_pages << EFI_PAGE_SHIFT" with a macro.

One issue I have not been able to come up with a good solution for is
what to do if I fail to allocate memory for the linked list of memory
ranges. The only time this will happen is if I can not find a single
memory range that is larger than granule size. If that were to happen, I
do not see how the machine will boot even if we did not need space for
EFI memory map. So for now I have shelved this issue and simply do a
machine_restart() if this were to happen ever.

Tony, please apply.

-- 
Khalid

====================================================================
Khalid Aziz                                Linux and Open Source Lab
(970)898-9214                                        Hewlett-Packard
khalid_aziz@hp.com                                  Fort Collins, CO

"The Linux kernel is subject to relentless development" 
				- Alessandro Rubini


--=-yB2965R8KALofTo5NNyc
Content-Disposition: attachment; filename=efi_memmapwalk_rewrite.patch
Content-Type: text/x-patch; name=efi_memmapwalk_rewrite.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit

diff -urNp linux-2.6.10/arch/ia64/kernel/efi.c linux-2.6.10-efimemmap/arch/ia64/kernel/efi.c
--- linux-2.6.10/arch/ia64/kernel/efi.c	2004-12-24 14:33:50.000000000 -0700
+++ linux-2.6.10-efimemmap/arch/ia64/kernel/efi.c	2005-01-07 16:49:31.212763442 -0700
@@ -17,6 +17,10 @@
  *
  * Goutham Rao: <goutham.rao@intel.com>
  *	Skip non-WB memory and ignore empty memory ranges.
+ *
+ * Rewrote efi_memap_walk() to create a linked list of available 
+ * memory regions instead of editing EFI memory map in place 
+ * 				- Khalid Aziz <khalid.aziz@hp.com>
  */
 #include <linux/config.h>
 #include <linux/module.h>
@@ -35,12 +39,17 @@
 
 #define EFI_DEBUG	0
 
+#define efi_md_size(md)	(md->num_pages << EFI_PAGE_SHIFT)
+
 extern efi_status_t efi_call_phys (void *, ...);
 
 struct efi efi;
 EXPORT_SYMBOL(efi);
 static efi_runtime_services_t *runtime;
 static unsigned long mem_limit = ~0UL, max_addr = ~0UL;
+static kern_memdesc_t *kern_memmap = NULL;
+static unsigned long efi_total_mem = 0UL;
+kern_memdesc_t *memdesc_area, *memdesc_end;
 
 #define efi_call_virt(f, args...)	(*(f))(args)
 
@@ -222,60 +231,43 @@ efi_gettimeofday (struct timespec *ts)
 	ts->tv_nsec = tm.nanosecond;
 }
 
-static int
-is_available_memory (efi_memory_desc_t *md)
-{
-	if (!(md->attribute & EFI_MEMORY_WB))
-		return 0;
-
-	switch (md->type) {
-	      case EFI_LOADER_CODE:
-	      case EFI_LOADER_DATA:
-	      case EFI_BOOT_SERVICES_CODE:
-	      case EFI_BOOT_SERVICES_DATA:
-	      case EFI_CONVENTIONAL_MEMORY:
-		return 1;
-	}
-	return 0;
-}
-
 /*
  * Trim descriptor MD so its starts at address START_ADDR.  If the descriptor covers
  * memory that is normally available to the kernel, issue a warning that some memory
  * is being ignored.
  */
 static void
-trim_bottom (efi_memory_desc_t *md, u64 start_addr)
+granule_align_bottom (kern_memdesc_t *md, u64 start_addr)
 {
 	u64 num_skipped_pages;
 
-	if (md->phys_addr >= start_addr || !md->num_pages)
+	if (md->start >= start_addr || !md->num_pages)
 		return;
 
-	num_skipped_pages = (start_addr - md->phys_addr) >> EFI_PAGE_SHIFT;
+	num_skipped_pages = (start_addr - md->start) >> EFI_PAGE_SHIFT;
 	if (num_skipped_pages > md->num_pages)
 		num_skipped_pages = md->num_pages;
 
 	if (is_available_memory(md))
-		printk(KERN_NOTICE "efi.%s: ignoring %luKB of memory at 0x%lx due to granule hole "
-		       "at 0x%lx\n", __FUNCTION__,
-		       (num_skipped_pages << EFI_PAGE_SHIFT) >> 10,
-		       md->phys_addr, start_addr - IA64_GRANULE_SIZE);
+		printk(KERN_NOTICE "efi.%s: ignoring %luKB of memory at "
+			"0x%lx due to granule hole at 0x%lx\n", __FUNCTION__,
+			(num_skipped_pages << EFI_PAGE_SHIFT) >> 10,
+			md->start, start_addr - IA64_GRANULE_SIZE);
 	/*
-	 * NOTE: Don't set md->phys_addr to START_ADDR because that could cause the memory
-	 * descriptor list to become unsorted.  In such a case, md->num_pages will be
-	 * zero, so the Right Thing will happen.
+	 * NOTE: Don't set md->start to start_addr because that could 
+	 * cause the memory descriptor list to become unsorted.  In such 
+	 * a case, md->num_pages will be zero, so the Right Thing will happen.
 	 */
-	md->phys_addr += num_skipped_pages << EFI_PAGE_SHIFT;
+	md->start += num_skipped_pages << EFI_PAGE_SHIFT;
 	md->num_pages -= num_skipped_pages;
 }
 
 static void
-trim_top (efi_memory_desc_t *md, u64 end_addr)
+granule_align_top (kern_memdesc_t *md, u64 end_addr)
 {
 	u64 num_dropped_pages, md_end_addr;
 
-	md_end_addr = md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT);
+	md_end_addr = md->start + efi_md_size(md);
 
 	if (md_end_addr <= end_addr || !md->num_pages)
 		return;
@@ -288,124 +280,228 @@ trim_top (efi_memory_desc_t *md, u64 end
 		printk(KERN_NOTICE "efi.%s: ignoring %luKB of memory at 0x%lx due to granule hole "
 		       "at 0x%lx\n", __FUNCTION__,
 		       (num_dropped_pages << EFI_PAGE_SHIFT) >> 10,
-		       md->phys_addr, end_addr);
+		       md->start, end_addr);
 	md->num_pages -= num_dropped_pages;
 }
 
+/* 
+ * Allocate a node for kernel memory descriptor. These allocations are never
+ * freed.
+ */
+static kern_memdesc_t  *
+memdesc_alloc (void)
+{
+	if (memdesc_area >= memdesc_end)
+		return(-1UL);
+	return(memdesc_area++);
+}
+
 /*
- * Walks the EFI memory map and calls CALLBACK once for each EFI memory descriptor that
- * has memory that is available for OS use.
+ * Walks the EFI memory map and calls CALLBACK once for each EFI 
+ * memory descriptor that has memory that is available for OS use.
  */
 void
 efi_memmap_walk (efi_freemem_callback_t callback, void *arg)
 {
-	int prev_valid = 0;
-	struct range {
-		u64 start;
-		u64 end;
-	} prev, curr;
+	kern_memdesc_t *memnode;
+	u64 start, end;
+
+	memnode = kern_memmap;
+
+	while (memnode != NULL) {
+		if (!is_available_memory(memnode) || memnode->ignore) {
+			memnode = memnode->next;
+			continue;
+		}
+		start = PAGE_OFFSET + memnode->start;
+		end = (start + efi_md_size(memnode)) & PAGE_MASK;
+
+		if ((*callback)(start, end, arg) < 0)
+			return;
+		memnode = memnode->next;
+	}
+}
+
+/*
+ * Trim memory size in accordance with "mem=" and "max_addr=" parameters
+ */
+void
+efi_trim_memory (void)
+{
+	kern_memdesc_t *memnode, *newnode;
+	unsigned long total_mem = 0UL;
+	unsigned long new_pages;
+
+	/* Do we have a memory size limit? If not, we are done */
+	if ((mem_limit == ~0UL) && (max_addr == ~0UL))
+		return;
+
+	/* 
+	 * walk the memory map to find where the limit kicks in
+	 */
+	memnode = kern_memmap;
+	while (memnode != NULL) {
+		total_mem += efi_md_size(memnode);
+
+		if (memnode->start + efi_md_size(memnode) > max_addr) {
+			new_pages = (max_addr - memnode->start) >> EFI_PAGE_SHIFT;
+			break;
+		} 
+		if (total_mem > mem_limit) {
+			new_pages = memnode->num_pages - 
+				((total_mem - mem_limit) >> EFI_PAGE_SHIFT);
+			break;
+		}
+		memnode = memnode->next;
+	}
+
+	/* Check for the case where the limit is larger than available mem */
+	if (memnode == NULL)
+		return;
+
+	if (new_pages == 0) {
+		memnode->ignore = 1;	/* trim the whole range */
+		memnode = memnode->next;
+	}
+	else {
+		/* Allocate a new node that will hold split range */
+		if ((newnode = memdesc_alloc()) == -1UL) {
+			/*
+			 * Print an error message and throw away the split
+			 * range. Not the best option, but we do not have 
+			 * many choices here.
+			 */
+			printk(KERN_ERR "ERROR: Failed to allocate space to split memory map for max_addr/mem\n");
+			memnode->num_pages = new_pages;
+			memnode = memnode->next;
+		}
+		else {
+			newnode->start = memnode->start + (new_pages << EFI_PAGE_SHIFT);
+			newnode->num_pages = memnode->num_pages - new_pages;
+			newnode->type = memnode->type;
+			newnode->ignore = 1;
+			memnode->num_pages = new_pages;
+			newnode->prev = memnode;
+			newnode->next = memnode->next;
+			memnode->next = newnode;
+			newnode->next->prev = newnode;
+			memnode = newnode->next;
+		}
+	}
+
+	/* Now walk the rest of the ranges and mark them ignored */
+	while (memnode != NULL) {
+		memnode->ignore = 1;
+		memnode = memnode->next;
+	}
+}
+
+/*
+ * Walk the EFI memory map and gather all memory available for kernel 
+ * to use. 
+ */
+void
+efi_gather_memory (void)
+{
 	void *efi_map_start, *efi_map_end, *p, *q;
 	efi_memory_desc_t *md, *check_md;
-	u64 efi_desc_size, start, end, granule_addr, last_granule_addr, first_non_wb_addr = 0;
-	unsigned long total_mem = 0;
+	u64 efi_desc_size, granule_addr, last_granule_addr, prev_end;
+	u64 first_non_wb_addr = 0;
+	int no_allocate = 0;
+	kern_memdesc_t *newnode, *prevnode;
 
 	efi_map_start = __va(ia64_boot_param->efi_memmap);
 	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
 	efi_desc_size = ia64_boot_param->efi_memdesc_size;
+	prevnode = newnode = NULL;
 
 	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
 		md = p;
 
-		/* skip over non-WB memory descriptors; that's all we're interested in... */
 		if (!(md->attribute & EFI_MEMORY_WB))
 			continue;
 
+		if (!no_allocate && (newnode = memdesc_alloc()) == NULL) {
+			printk(KERN_ERR "ERROR: Failed to allocate node for kernel memory descriptor\n");
+			printk(KERN_ERR "       Continuing with limited memory\n");
+			break;
+		}
+		newnode->type = md->type;
+		newnode->ignore = 0;
+		newnode->start = md->phys_addr;
+		newnode->num_pages = md->num_pages;
+		newnode->next = newnode->prev = NULL;
+		if (kern_memmap == NULL)
+			kern_memmap = newnode;
+
 		/*
+		 * Do we need to granule align?
 		 * granule_addr is the base of md's first granule.
 		 * [granule_addr - first_non_wb_addr) is guaranteed to
 		 * be contiguous WB memory.
 		 */
-		granule_addr = GRANULEROUNDDOWN(md->phys_addr);
+		granule_addr = GRANULEROUNDDOWN(newnode->start);
 		first_non_wb_addr = max(first_non_wb_addr, granule_addr);
 
-		if (first_non_wb_addr < md->phys_addr) {
-			trim_bottom(md, granule_addr + IA64_GRANULE_SIZE);
-			granule_addr = GRANULEROUNDDOWN(md->phys_addr);
+		if (first_non_wb_addr < newnode->start) {
+			granule_align_bottom(newnode, granule_addr + IA64_GRANULE_SIZE);
+			granule_addr = GRANULEROUNDDOWN(newnode->start);
 			first_non_wb_addr = max(first_non_wb_addr, granule_addr);
 		}
 
-		for (q = p; q < efi_map_end; q += efi_desc_size) {
+		if (newnode->start == first_non_wb_addr)
+			first_non_wb_addr += efi_md_size(newnode);
+
+		for (q = p+efi_desc_size; q < efi_map_end; q += efi_desc_size) {
 			check_md = q;
 
 			if ((check_md->attribute & EFI_MEMORY_WB) &&
-			    (check_md->phys_addr == first_non_wb_addr))
-				first_non_wb_addr += check_md->num_pages << EFI_PAGE_SHIFT;
+			    (check_md->phys_addr == first_non_wb_addr)) {
+				first_non_wb_addr += efi_md_size(check_md);
+			}
 			else
-				break;		/* non-WB or hole */
+				break;	/* non-WB or hole */
 		}
 
 		last_granule_addr = GRANULEROUNDDOWN(first_non_wb_addr);
-		if (last_granule_addr < md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT))
-			trim_top(md, last_granule_addr);
+		if (last_granule_addr < newnode->start + efi_md_size(newnode))
+			granule_align_top(newnode, last_granule_addr);
 
-		if (is_available_memory(md)) {
-			if (md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) >= max_addr) {
-				if (md->phys_addr >= max_addr)
-					continue;
-				md->num_pages = (max_addr - md->phys_addr) >> EFI_PAGE_SHIFT;
-				first_non_wb_addr = max_addr;
-			}
-
-			if (total_mem >= mem_limit)
-				continue;
-
-			if (total_mem + (md->num_pages << EFI_PAGE_SHIFT) > mem_limit) {
-				unsigned long limit_addr = md->phys_addr;
 
-				limit_addr += mem_limit - total_mem;
-				limit_addr = GRANULEROUNDDOWN(limit_addr);
-
-				if (md->phys_addr > limit_addr)
-					continue;
-
-				md->num_pages = (limit_addr - md->phys_addr) >>
-				                EFI_PAGE_SHIFT;
-				first_non_wb_addr = max_addr = md->phys_addr +
-				              (md->num_pages << EFI_PAGE_SHIFT);
-			}
-			total_mem += (md->num_pages << EFI_PAGE_SHIFT);
+		/* 
+		 * Are we left with any pages after all the alignment? 
+		 * If not, we will simply reuse the node we just allocated
+		 * and not allocate a new one.
+		 */
+		if (!newnode->num_pages) {
+			no_allocate = 1;
+			continue;
+		} else
+			no_allocate = 0;
 
-			if (md->num_pages == 0)
+		/*
+		 * Can we coalesce this memory range with previous one 
+		 */
+		if (prevnode) {
+			prev_end = prevnode->start + efi_md_size(prevnode);
+			if ((prev_end == newnode->start) && 
+			    (is_available_memory(newnode)) &&
+			    (is_available_memory(prevnode))) {
+				prevnode->num_pages += newnode->num_pages;
+				no_allocate = 1;
+				efi_total_mem += efi_md_size(newnode);
 				continue;
-
-			curr.start = PAGE_OFFSET + md->phys_addr;
-			curr.end   = curr.start + (md->num_pages << EFI_PAGE_SHIFT);
-
-			if (!prev_valid) {
-				prev = curr;
-				prev_valid = 1;
-			} else {
-				if (curr.start < prev.start)
-					printk(KERN_ERR "Oops: EFI memory table not ordered!\n");
-
-				if (prev.end == curr.start) {
-					/* merge two consecutive memory ranges */
-					prev.end = curr.end;
-				} else {
-					start = PAGE_ALIGN(prev.start);
-					end = prev.end & PAGE_MASK;
-					if ((end > start) && (*callback)(start, end, arg) < 0)
-						return;
-					prev = curr;
-				}
 			}
 		}
-	}
-	if (prev_valid) {
-		start = PAGE_ALIGN(prev.start);
-		end = prev.end & PAGE_MASK;
-		if (end > start)
-			(*callback)(start, end, arg);
+		if (is_available_memory(newnode))
+			efi_total_mem += efi_md_size(newnode);
+
+		/* Link this node in the list */
+		if (prevnode != NULL) {
+			newnode->prev = prevnode;
+			prevnode->next = newnode;
+		}
+		prevnode = newnode;
 	}
 }
 
@@ -464,14 +560,14 @@ efi_map_pal_code (void)
 			continue;
 		}
 
-		if (md->num_pages << EFI_PAGE_SHIFT > IA64_GRANULE_SIZE)
+		if (efi_md_size(md) > IA64_GRANULE_SIZE)
 			panic("Woah!  PAL code size bigger than a granule!");
 
 		mask  = ~((1 << IA64_GRANULE_SHIFT) - 1);
 #if EFI_DEBUG
 		printk(KERN_INFO "CPU %d: mapping PAL code [0x%lx-0x%lx) into [0x%lx-0x%lx)\n",
 		       smp_processor_id(), md->phys_addr,
-		       md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT),
+		       md->phys_addr + efi_md_size(md),
 		       vaddr & mask, (vaddr & mask) + IA64_GRANULE_SIZE);
 #endif
 
@@ -604,7 +700,7 @@ efi_init (void)
 			md = p;
 			printk("mem%02u: type=%u, attr=0x%lx, range=[0x%016lx-0x%016lx) (%luMB)\n",
 			       i, md->type, md->attribute, md->phys_addr,
-			       md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT),
+			       md->phys_addr + efi_md_size(md),
 			       md->num_pages >> (20 - EFI_PAGE_SHIFT));
 		}
 	}
@@ -725,7 +821,7 @@ efi_mem_type (unsigned long phys_addr)
 	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
 		md = p;
 
-		if (phys_addr - md->phys_addr < (md->num_pages << EFI_PAGE_SHIFT))
+		if (phys_addr - md->phys_addr < efi_md_size(md))
 			 return md->type;
 	}
 	return 0;
@@ -745,7 +841,7 @@ efi_mem_attributes (unsigned long phys_a
 	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
 		md = p;
 
-		if (phys_addr - md->phys_addr < (md->num_pages << EFI_PAGE_SHIFT))
+		if (phys_addr - md->phys_addr < efi_md_size(md))
 			return md->attribute;
 	}
 	return 0;
@@ -765,12 +861,12 @@ valid_phys_addr_range (unsigned long phy
 	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
 		md = p;
 
-		if (phys_addr - md->phys_addr < (md->num_pages << EFI_PAGE_SHIFT)) {
+		if (phys_addr - md->phys_addr < efi_md_size(md)) {
 			if (!(md->attribute & EFI_MEMORY_WB))
 				return 0;
 
-			if (*size > md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) - phys_addr)
-				*size = md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) - phys_addr;
+			if (*size > md->phys_addr + efi_md_size(md) - phys_addr)
+				*size = md->phys_addr + efi_md_size(md) - phys_addr;
 			return 1;
 		}
 	}
diff -urNp linux-2.6.10/arch/ia64/kernel/setup.c linux-2.6.10-efimemmap/arch/ia64/kernel/setup.c
--- linux-2.6.10/arch/ia64/kernel/setup.c	2004-12-24 14:34:00.000000000 -0700
+++ linux-2.6.10-efimemmap/arch/ia64/kernel/setup.c	2005-01-07 16:49:43.859247662 -0700
@@ -74,6 +74,9 @@ EXPORT_SYMBOL(ia64_iobase);
 struct io_space io_space[MAX_IO_SPACES];
 EXPORT_SYMBOL(io_space);
 unsigned int num_io_spaces;
+extern kern_memdesc_t *memdesc_area;
+extern kern_memdesc_t *memdesc_end;
+
 
 unsigned char aux_device_present = 0xaa;        /* XXX remove this when legacy I/O is gone */
 
@@ -156,6 +159,79 @@ sort_regions (struct rsvd_region *rsvd_r
 	}
 }
 
+#define MEM_DESC_SAFETY_MARGIN	8
+
+static int
+find_memmap_space (int *marker)
+{
+	void *efi_map_start, *efi_map_end, *p, *q;
+	u64 efi_desc_size, space_needed;
+	u64 smallest_block = UINT_MAX;
+	u64 small_block_addr, block_size;
+	efi_memory_desc_t *md, *check_md;
+
+	/*
+	 * Look for the first granule aligned memory descriptor memory 
+	 * that is big enough to hold EFI memory map. Make sure this 
+	 * descriptor is atleast granule sized so it does not get trimmed
+	 */
+	efi_map_start = __va(ia64_boot_param->efi_memmap);
+	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size = ia64_boot_param->efi_memdesc_size;
+
+	/*
+	 * We will allocate enough memory to hold as many nodes as 
+	 * there are in EFI memory map. We will then allocate another 
+	 * MEM_DESC_SAFETY_MARGIN for safety margin in case we have to 
+	 * split some of the memory ranges and thus create new nodes
+	 */
+	space_needed = sizeof(kern_memdesc_t)*(ia64_boot_param->efi_memmap_size/efi_desc_size + MEM_DESC_SAFETY_MARGIN);
+
+	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
+		md = p;
+
+		/* skip over non-WB and non-available memory descriptors */
+		if ((!(md->attribute & EFI_MEMORY_WB)) || 
+			(!is_available_memory(md)))
+			continue;
+		block_size = md->num_pages << EFI_PAGE_SHIFT;
+
+		/* Look for any contiguous blocks of memory */
+		for (q = p+efi_desc_size; q < efi_map_end; q += efi_desc_size) {
+			check_md = q;
+
+			if ((check_md->attribute & EFI_MEMORY_WB) &&
+			    (check_md->phys_addr == md->phys_addr+block_size) &&
+			    is_available_memory(check_md)) {
+				block_size += check_md->num_pages << EFI_PAGE_SHIFT;
+				p += efi_desc_size;
+			}
+			else
+				break;
+		}
+
+		if ((block_size < smallest_block) && 
+			(block_size >= space_needed &&
+			 (block_size >= IA64_GRANULE_SIZE))) {
+			smallest_block = block_size;
+			small_block_addr = md->phys_addr;
+		}
+
+	}
+
+	/* 
+	 * We will allocate a chunk of memory from the smallest block
+	 * of memory we found.
+	 */
+	rsvd_region[*marker].start = small_block_addr;
+	rsvd_region[*marker].end = memdesc_end = 
+		small_block_addr + space_needed;
+	memdesc_area = __va(small_block_addr);
+	memdesc_end = memdesc_area + space_needed;
+	(*marker)++;
+	return 0;
+}
+
 /**
  * reserve_memory - setup reserved memory areas
  *
@@ -196,6 +272,11 @@ reserve_memory (void)
 	}
 #endif
 
+	if (find_memmap_space(&n) != 0) {
+		printk(KERN_EMERG "Failed to find space to build kernel EFI memory map");
+		 machine_restart(NULL);
+	}
+
 	/* end of memory marker */
 	rsvd_region[n].start = ~0UL;
 	rsvd_region[n].end   = ~0UL;
diff -urNp linux-2.6.10/arch/ia64/mm/contig.c linux-2.6.10-efimemmap/arch/ia64/mm/contig.c
--- linux-2.6.10/arch/ia64/mm/contig.c	2004-12-24 14:34:30.000000000 -0700
+++ linux-2.6.10-efimemmap/arch/ia64/mm/contig.c	2005-01-05 09:14:15.000000000 -0700
@@ -146,6 +146,9 @@ find_memory (void)
 
 	reserve_memory();
 
+	efi_gather_memory();
+	efi_trim_memory();
+
 	/* first find highest page frame number */
 	max_pfn = 0;
 	efi_memmap_walk(find_max_pfn, &max_pfn);
diff -urNp linux-2.6.10/arch/ia64/mm/discontig.c linux-2.6.10-efimemmap/arch/ia64/mm/discontig.c
--- linux-2.6.10/arch/ia64/mm/discontig.c	2004-12-24 14:35:25.000000000 -0700
+++ linux-2.6.10-efimemmap/arch/ia64/mm/discontig.c	2005-01-05 09:14:15.000000000 -0700
@@ -429,6 +429,9 @@ void __init find_memory(void)
 
 	reserve_memory();
 
+	efi_gather_memory();
+	efi_trim_memory();
+
 	if (numnodes == 0) {
 		printk(KERN_ERR "node info missing!\n");
 		numnodes = 1;
diff -urNp linux-2.6.10/include/asm-ia64/meminit.h linux-2.6.10-efimemmap/include/asm-ia64/meminit.h
--- linux-2.6.10/include/asm-ia64/meminit.h	2004-12-24 14:34:30.000000000 -0700
+++ linux-2.6.10-efimemmap/include/asm-ia64/meminit.h	2005-01-07 15:20:01.000000000 -0700
@@ -16,10 +16,11 @@
  * 	- initrd (optional)
  * 	- command line string
  * 	- kernel code & data
+ * 	- Kernel memory map built from EFI memory map
  *
  * More could be added if necessary
  */
-#define IA64_MAX_RSVD_REGIONS 5
+#define IA64_MAX_RSVD_REGIONS 6
 
 struct rsvd_region {
 	unsigned long start;	/* virtual address of beginning of element */
@@ -29,6 +30,14 @@ struct rsvd_region {
 extern struct rsvd_region rsvd_region[IA64_MAX_RSVD_REGIONS + 1];
 extern int num_rsvd_regions;
 
+typedef struct kern_memdesc {
+	u32 ignore;
+	u32 type;
+	u64 start;
+	u64 num_pages;
+	struct kern_memdesc *next, *prev;
+} kern_memdesc_t;
+
 extern void find_memory (void);
 extern void reserve_memory (void);
 extern void find_initrd (void);
@@ -57,4 +66,10 @@ extern int filter_rsvd_memory (unsigned 
   extern int create_mem_map_page_table (u64 start, u64 end, void *arg);
 #endif
 
+#define is_available_memory(md) ((md->type == EFI_LOADER_CODE)? 1: \
+				  ((md->type == EFI_LOADER_DATA)? 1: \
+				   ((md->type == EFI_BOOT_SERVICES_CODE)? 1: \
+				    ((md->type == EFI_BOOT_SERVICES_DATA)? 1: \
+				     ((md->type == EFI_CONVENTIONAL_MEMORY)? 1:0)))))
+
 #endif /* meminit_h */

--=-yB2965R8KALofTo5NNyc--

