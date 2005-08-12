From: Khalid Aziz <khalid_aziz@hp.com>
Date: Fri, 12 Aug 2005 23:05:53 +0000
Subject: RE: efi_memmapwalk re-write
Message-Id: <1123887953.29568.18.camel@lyra.fc.hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-MUkoHr1/bREAlwxQsiJl"
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F040F73E2@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F040F73E2@scsmsx401.amr.corp.intel.com>
To: linux-ia64@vger.kernel.org


--=-MUkoHr1/bREAlwxQsiJl
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Tony,

Here is the updated patch. It incorporates your suggestions. I have left
kern_memdesc as a linked list as opposed to array. Linked list is little
more versatile structure and the cost is minimal over an array. Unless
you feel strongly about using arrays instead of linked list, I would
prefer to leave it this way.

-- 
Khalid

====================================================================
Khalid Aziz                       Open Source and Linux Organization
(970)898-9214                                        Hewlett-Packard
khalid.aziz@hp.com                                  Fort Collins, CO

"The Linux kernel is subject to relentless development" 
                                - Alessandro Rubini

--=-MUkoHr1/bREAlwxQsiJl
Content-Disposition: attachment; filename=efi_memmapwalk_2.6.13rc3.patch
Content-Type: text/x-patch; name=efi_memmapwalk_2.6.13rc3.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit

diff -urNp linux-2.6.13-rc3/arch/ia64/kernel/efi.c linux-2.6.13-rc3-efimemmap/arch/ia64/kernel/efi.c
--- linux-2.6.13-rc3/arch/ia64/kernel/efi.c	2005-07-28 13:37:40.000000000 -0600
+++ linux-2.6.13-rc3-efimemmap/arch/ia64/kernel/efi.c	2005-08-12 16:56:48.000000000 -0600
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
 
@@ -222,190 +231,232 @@ efi_gettimeofday (struct timespec *ts)
 	ts->tv_nsec = tm.nanosecond;
 }
 
-static int
-is_available_memory (efi_memory_desc_t *md)
+#define is_usable_memory(md)	((md->type == EFI_LOADER_CODE)? 1: \
+				 ((md->type == EFI_BOOT_SERVICES_CODE)? 1: \
+				  ((md->type == EFI_BOOT_SERVICES_DATA)? 1: \
+				   ((md->type == EFI_CONVENTIONAL_MEMORY)? 1:0))))
+
+static inline int
+efi_wb(efi_memory_desc_t *md)
 {
-	if (!(md->attribute & EFI_MEMORY_WB))
-		return 0;
+	return (md->attribute & EFI_MEMORY_WB);
+}
 
-	switch (md->type) {
-	      case EFI_LOADER_CODE:
-	      case EFI_LOADER_DATA:
-	      case EFI_BOOT_SERVICES_CODE:
-	      case EFI_BOOT_SERVICES_DATA:
-	      case EFI_CONVENTIONAL_MEMORY:
-		return 1;
-	}
-	return 0;
+static inline u64
+kern_end(kern_memdesc_t *kmd)
+{
+	return (kmd->start + (kmd->num_pages << EFI_PAGE_SHIFT));
 }
 
-/*
- * Trim descriptor MD so its starts at address START_ADDR.  If the descriptor covers
- * memory that is normally available to the kernel, issue a warning that some memory
- * is being ignored.
- */
-static void
-trim_bottom (efi_memory_desc_t *md, u64 start_addr)
+int
+find_memmap_space (struct rsvd_region *rsvd_rgn)
 {
-	u64 num_skipped_pages;
+	void *efi_map_start, *efi_map_end, *p, *q;
+	u64 efi_desc_size, space_needed;
+	u64 smallest_block = UINT_MAX;
+	u64 small_block_addr = -1UL;
+	u64 block_size;
+	efi_memory_desc_t *md, *check_md;
 
-	if (md->phys_addr >= start_addr || !md->num_pages)
-		return;
+	/*
+	 * Look for the first granule aligned memory descriptor memory 
+	 * that is big enough to hold EFI memory map. Make sure this 
+	 * descriptor is atleast granule sized so it does not get trimmed
+	 */
+	efi_map_start = __va(ia64_boot_param->efi_memmap);
+	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size = ia64_boot_param->efi_memdesc_size;
 
-	num_skipped_pages = (start_addr - md->phys_addr) >> EFI_PAGE_SHIFT;
-	if (num_skipped_pages > md->num_pages)
-		num_skipped_pages = md->num_pages;
-
-	if (is_available_memory(md))
-		printk(KERN_NOTICE "efi.%s: ignoring %luKB of memory at 0x%lx due to granule hole "
-		       "at 0x%lx\n", __FUNCTION__,
-		       (num_skipped_pages << EFI_PAGE_SHIFT) >> 10,
-		       md->phys_addr, start_addr - IA64_GRANULE_SIZE);
 	/*
-	 * NOTE: Don't set md->phys_addr to START_ADDR because that could cause the memory
-	 * descriptor list to become unsorted.  In such a case, md->num_pages will be
-	 * zero, so the Right Thing will happen.
+	 * We will allocate enough memory to hold as many nodes as 
+	 * there are in EFI memory map and a null node. 
 	 */
-	md->phys_addr += num_skipped_pages << EFI_PAGE_SHIFT;
-	md->num_pages -= num_skipped_pages;
+	space_needed = sizeof(kern_memdesc_t)*((ia64_boot_param->efi_memmap_size/efi_desc_size) + 1);
+
+	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
+		md = p;
+
+		/* skip over non-WB and non-available memory descriptors */
+		if ((!efi_wb(md)) || (!is_usable_memory(md)))
+			continue;
+		block_size = efi_md_size(md);
+
+		/* Look for any contiguous blocks of memory */
+		for (q = p+efi_desc_size; q < efi_map_end; q += efi_desc_size) {
+			check_md = q;
+
+			if (efi_wb(check_md) &&
+			    (check_md->phys_addr == md->phys_addr+block_size) &&
+			    is_usable_memory(check_md)) {
+				block_size += efi_md_size(check_md);
+				p += efi_desc_size;
+			}
+			else
+				break;
+		}
+
+		if ((block_size < smallest_block) && 
+			(block_size >= space_needed) &&
+			 (block_size >= IA64_GRANULE_SIZE)) {
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
+	rsvd_rgn->start = small_block_addr;
+	rsvd_rgn->end = small_block_addr + space_needed;
+	memdesc_area = __va(small_block_addr);
+	memdesc_end = memdesc_area + space_needed;
+	return 0;
+}
+
+/* 
+ * Allocate a node for kernel memory descriptor. These allocations are never
+ * freed.
+ */
+static inline kern_memdesc_t  *
+memdesc_alloc (void)
+{
+	if (memdesc_area >= memdesc_end)
+		return((kern_memdesc_t  *)-1UL);
+	return((kern_memdesc_t  *)memdesc_area++);
 }
 
-static void
-trim_top (efi_memory_desc_t *md, u64 end_addr)
+/*
+ * Walks the EFI memory map and calls CALLBACK once for each EFI 
+ * memory descriptor that has memory that is available for OS use.
+ */
+void
+efi_memmap_walk (efi_freemem_callback_t callback, void *arg)
 {
-	u64 num_dropped_pages, md_end_addr;
+	kern_memdesc_t *memnode;
+	u64 start, end;
 
-	md_end_addr = md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT);
+	memnode = kern_memmap;
 
-	if (md_end_addr <= end_addr || !md->num_pages)
-		return;
+	while (memnode != NULL) {
+		start = PAGE_OFFSET + memnode->start;
+		end = (start + efi_md_size(memnode)) & PAGE_MASK;
+
+		if ((*callback)(start, end, arg) < 0)
+			return;
+		memnode = memnode->next;
+	}
+}
 
-	num_dropped_pages = (md_end_addr - end_addr) >> EFI_PAGE_SHIFT;
-	if (num_dropped_pages > md->num_pages)
-		num_dropped_pages = md->num_pages;
-
-	if (is_available_memory(md))
-		printk(KERN_NOTICE "efi.%s: ignoring %luKB of memory at 0x%lx due to granule hole "
-		       "at 0x%lx\n", __FUNCTION__,
-		       (num_dropped_pages << EFI_PAGE_SHIFT) >> 10,
-		       md->phys_addr, end_addr);
-	md->num_pages -= num_dropped_pages;
+static inline u64
+efi_end(efi_memory_desc_t *md)
+{
+	return (md->phys_addr + efi_md_size(md));
 }
 
 /*
- * Walks the EFI memory map and calls CALLBACK once for each EFI memory descriptor that
- * has memory that is available for OS use.
+ * Walk the EFI memory map and gather all memory available for kernel 
+ * to use. 
  */
 void
-efi_memmap_walk (efi_freemem_callback_t callback, void *arg)
+efi_gather_memory (void)
 {
-	int prev_valid = 0;
-	struct range {
-		u64 start;
-		u64 end;
-	} prev, curr;
 	void *efi_map_start, *efi_map_end, *p, *q;
-	efi_memory_desc_t *md, *check_md;
-	u64 efi_desc_size, start, end, granule_addr, last_granule_addr, first_non_wb_addr = 0;
-	unsigned long total_mem = 0;
+	efi_memory_desc_t *md, *check_md, *pmd = NULL;
+	u64 efi_desc_size;
+	u64 contig_low=0, contig_high=0, range_end;
+	int no_allocate = 0;
+	kern_memdesc_t *newnode, *prevnode = NULL;
 
 	efi_map_start = __va(ia64_boot_param->efi_memmap);
 	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
 	efi_desc_size = ia64_boot_param->efi_memdesc_size;
 
-	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
+	for (p = efi_map_start; p < efi_map_end; pmd=md, p += efi_desc_size) {
 		md = p;
 
-		/* skip over non-WB memory descriptors; that's all we're interested in... */
-		if (!(md->attribute & EFI_MEMORY_WB))
+		if (!efi_wb(md) || !is_available_memory(md))
 			continue;
 
+		if (!no_allocate && (newnode = memdesc_alloc()) == NULL) {
+			printk(KERN_ERR "ERROR: Failed to allocate node for kernel memory descriptor\n");
+			printk(KERN_ERR "       Continuing with limited memory\n");
+			break;
+		}
+		no_allocate = 0;
+		newnode->start = md->phys_addr;
+		newnode->num_pages = md->num_pages;
+		newnode->next = newnode->prev = NULL;
+		if (kern_memmap == NULL)
+			kern_memmap = newnode;
+
 		/*
-		 * granule_addr is the base of md's first granule.
-		 * [granule_addr - first_non_wb_addr) is guaranteed to
-		 * be contiguous WB memory.
+		 * Granule align and coalesce contiguous ranges 
 		 */
-		granule_addr = GRANULEROUNDDOWN(md->phys_addr);
-		first_non_wb_addr = max(first_non_wb_addr, granule_addr);
-
-		if (first_non_wb_addr < md->phys_addr) {
-			trim_bottom(md, granule_addr + IA64_GRANULE_SIZE);
-			granule_addr = GRANULEROUNDDOWN(md->phys_addr);
-			first_non_wb_addr = max(first_non_wb_addr, granule_addr);
+		if (pmd == NULL || !efi_wb(pmd) || efi_end(pmd) != md->phys_addr) {
+			contig_low = GRANULEROUNDUP(newnode->start);
+			contig_high = efi_end(md);
+			for (q = p+efi_desc_size; q < efi_map_end; q += efi_desc_size) {
+				check_md = q;
+
+				if (!efi_wb(check_md) || 
+					(check_md->phys_addr != contig_high)) {
+					break;
+				}
+				contig_high = efi_end(check_md);
+			}
+			contig_high = GRANULEROUNDDOWN(contig_high);
 		}
+		if (!is_available_memory(md))
+			continue;
 
-		for (q = p; q < efi_map_end; q += efi_desc_size) {
-			check_md = q;
+		newnode->start = max(contig_low, md->phys_addr);
+		range_end = min(contig_high, efi_end(md));
 
-			if ((check_md->attribute & EFI_MEMORY_WB) &&
-			    (check_md->phys_addr == first_non_wb_addr))
-				first_non_wb_addr += check_md->num_pages << EFI_PAGE_SHIFT;
-			else
-				break;		/* non-WB or hole */
+		/* Apply max_addr= limit */
+		range_end = min(range_end, max_addr);
+		if (range_end <= newnode->start) {
+			no_allocate = 1;
+			continue;
 		}
 
-		last_granule_addr = GRANULEROUNDDOWN(first_non_wb_addr);
-		if (last_granule_addr < md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT))
-			trim_top(md, last_granule_addr);
-
-		if (is_available_memory(md)) {
-			if (md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) >= max_addr) {
-				if (md->phys_addr >= max_addr)
-					continue;
-				md->num_pages = (max_addr - md->phys_addr) >> EFI_PAGE_SHIFT;
-				first_non_wb_addr = max_addr;
-			}
-
-			if (total_mem >= mem_limit)
+		/* Enforce mem= limit */
+		if ((efi_total_mem + range_end - newnode->start) > mem_limit)
+			range_end -= (efi_total_mem + range_end - 
+					newnode->start) - mem_limit;
+
+		if (range_end <= newnode->start)
+			newnode->num_pages = 0;
+		else {
+			/* Can we merge this range with previous one */
+			if (prevnode && kern_end(prevnode) == md->phys_addr) {
+				prevnode->num_pages += (range_end - newnode->start) >> EFI_PAGE_SHIFT;
+				efi_total_mem += range_end - newnode->start;
+				no_allocate = 1;
 				continue;
-
-			if (total_mem + (md->num_pages << EFI_PAGE_SHIFT) > mem_limit) {
-				unsigned long limit_addr = md->phys_addr;
-
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
 			}
-			total_mem += (md->num_pages << EFI_PAGE_SHIFT);
-
-			if (md->num_pages == 0)
-				continue;
+			else
+				newnode->num_pages = (range_end - newnode->start) >> EFI_PAGE_SHIFT;
+		}
+		/* 
+		 * Are we left with any pages after all the alignment? 
+		 * If not, we will simply reuse the node we just allocated
+		 * and not allocate a new one.
+		 */
+		if (!newnode->num_pages) {
+			no_allocate = 1;
+			continue;
+		} 
 
-			curr.start = PAGE_OFFSET + md->phys_addr;
-			curr.end   = curr.start + (md->num_pages << EFI_PAGE_SHIFT);
+		efi_total_mem += efi_md_size(newnode);
 
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
-			}
+		/* Link this node in the list */
+		if (prevnode != NULL) {
+			newnode->prev = prevnode;
+			prevnode->next = newnode;
 		}
-	}
-	if (prev_valid) {
-		start = PAGE_ALIGN(prev.start);
-		end = prev.end & PAGE_MASK;
-		if (end > start)
-			(*callback)(start, end, arg);
+		prevnode = newnode;
 	}
 }
 
@@ -644,7 +695,7 @@ efi_init (void)
 			md = p;
 			printk("mem%02u: type=%u, attr=0x%lx, range=[0x%016lx-0x%016lx) (%luMB)\n",
 			       i, md->type, md->attribute, md->phys_addr,
-			       md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT),
+			       md->phys_addr + efi_md_size(md),
 			       md->num_pages >> (20 - EFI_PAGE_SHIFT));
 		}
 	}
@@ -673,7 +724,7 @@ efi_enter_virtual_mode (void)
 			 * Some descriptors have multiple bits set, so the order of
 			 * the tests is relevant.
 			 */
-			if (md->attribute & EFI_MEMORY_WB) {
+			if (efi_wb(md)) {
 				md->virt_addr = (u64) __va(md->phys_addr);
 			} else if (md->attribute & EFI_MEMORY_UC) {
 				md->virt_addr = (u64) ioremap(md->phys_addr, 0);
@@ -765,7 +816,7 @@ efi_mem_type (unsigned long phys_addr)
 	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
 		md = p;
 
-		if (phys_addr - md->phys_addr < (md->num_pages << EFI_PAGE_SHIFT))
+		if (phys_addr - md->phys_addr < efi_md_size(md))
 			 return md->type;
 	}
 	return 0;
@@ -785,7 +836,7 @@ efi_mem_attributes (unsigned long phys_a
 	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
 		md = p;
 
-		if (phys_addr - md->phys_addr < (md->num_pages << EFI_PAGE_SHIFT))
+		if (phys_addr - md->phys_addr < efi_md_size(md))
 			return md->attribute;
 	}
 	return 0;
@@ -806,12 +857,12 @@ valid_phys_addr_range (unsigned long phy
 	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
 		md = p;
 
-		if (phys_addr - md->phys_addr < (md->num_pages << EFI_PAGE_SHIFT)) {
-			if (!(md->attribute & EFI_MEMORY_WB))
+		if (phys_addr - md->phys_addr < efi_md_size(md)) {
+			if (!efi_wb(md))
 				return 0;
 
-			if (*size > md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) - phys_addr)
-				*size = md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) - phys_addr;
+			if (*size > md->phys_addr + efi_md_size(md) - phys_addr)
+				*size = md->phys_addr + efi_md_size(md) - phys_addr;
 			return 1;
 		}
 	}
diff -urNp linux-2.6.13-rc3/arch/ia64/kernel/setup.c linux-2.6.13-rc3-efimemmap/arch/ia64/kernel/setup.c
--- linux-2.6.13-rc3/arch/ia64/kernel/setup.c	2005-07-28 13:37:40.000000000 -0600
+++ linux-2.6.13-rc3-efimemmap/arch/ia64/kernel/setup.c	2005-08-09 14:34:18.000000000 -0600
@@ -163,6 +164,8 @@ sort_regions (struct rsvd_region *rsvd_r
 	}
 }
 
+extern int find_memmap_space(struct rsvd_region *);
+
 /**
  * reserve_memory - setup reserved memory areas
  *
@@ -203,6 +206,11 @@ reserve_memory (void)
 	}
 #endif
 
+	if (find_memmap_space(&rsvd_region[n]) != 0) {
+		panic("Failed to find space to build kernel EFI memory map");
+	}
+	n++;
+
 	/* end of memory marker */
 	rsvd_region[n].start = ~0UL;
 	rsvd_region[n].end   = ~0UL;
diff -urNp linux-2.6.13-rc3/arch/ia64/mm/contig.c linux-2.6.13-rc3-efimemmap/arch/ia64/mm/contig.c
--- linux-2.6.13-rc3/arch/ia64/mm/contig.c	2005-06-17 13:48:29.000000000 -0600
+++ linux-2.6.13-rc3-efimemmap/arch/ia64/mm/contig.c	2005-08-12 16:36:36.000000000 -0600
@@ -148,6 +148,8 @@ find_memory (void)
 
 	reserve_memory();
 
+	efi_gather_memory();
+
 	/* first find highest page frame number */
 	max_pfn = 0;
 	efi_memmap_walk(find_max_pfn, &max_pfn);
diff -urNp linux-2.6.13-rc3/arch/ia64/mm/discontig.c linux-2.6.13-rc3-efimemmap/arch/ia64/mm/discontig.c
--- linux-2.6.13-rc3/arch/ia64/mm/discontig.c	2005-07-28 13:37:40.000000000 -0600
+++ linux-2.6.13-rc3-efimemmap/arch/ia64/mm/discontig.c	2005-08-12 16:36:40.000000000 -0600
@@ -433,6 +433,8 @@ void __init find_memory(void)
 
 	reserve_memory();
 
+	efi_gather_memory();
+
 	if (num_online_nodes() == 0) {
 		printk(KERN_ERR "node info missing!\n");
 		node_set_online(0);
diff -urNp linux-2.6.13-rc3/include/asm-ia64/meminit.h linux-2.6.13-rc3-efimemmap/include/asm-ia64/meminit.h
--- linux-2.6.13-rc3/include/asm-ia64/meminit.h	2005-06-17 13:48:29.000000000 -0600
+++ linux-2.6.13-rc3-efimemmap/include/asm-ia64/meminit.h	2005-08-12 16:36:05.000000000 -0600
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
@@ -29,6 +30,12 @@ struct rsvd_region {
 extern struct rsvd_region rsvd_region[IA64_MAX_RSVD_REGIONS + 1];
 extern int num_rsvd_regions;
 
+typedef struct kern_memdesc {
+	u64 start;
+	u64 num_pages;
+	struct kern_memdesc *next, *prev;
+} kern_memdesc_t;
+
 extern void find_memory (void);
 extern void reserve_memory (void);
 extern void find_initrd (void);
@@ -57,4 +64,10 @@ extern int filter_rsvd_memory (unsigned 
   extern int create_mem_map_page_table (u64 start, u64 end, void *arg);
 #endif
 
+#define is_available_memory(md) ((md->type == EFI_LOADER_CODE)? 1: \
+				  ((md->type == EFI_LOADER_DATA)? 1: \
+				   ((md->type == EFI_BOOT_SERVICES_CODE)? 1: \
+				    ((md->type == EFI_BOOT_SERVICES_DATA)? 1: \
+				     ((md->type == EFI_CONVENTIONAL_MEMORY)? 1:0)))))
+
 #endif /* meminit_h */

--=-MUkoHr1/bREAlwxQsiJl--

