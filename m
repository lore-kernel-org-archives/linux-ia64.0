From: tony.luck@intel.com
Date: Sat, 03 Sep 2005 06:25:30 +0000
Subject: RE: efi_memmapwalk re-write
Message-Id: <200509030625.j836PUDX019346@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F040F73E2@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F040F73E2@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Here is the updated patch. It incorporates your suggestions. I have left
>kern_memdesc as a linked list as opposed to array. Linked list is little
>more versatile structure and the cost is minimal over an array. Unless
>you feel strongly about using arrays instead of linked list, I would
>prefer to leave it this way.

I ditched the list ... it seems like overkill for a structure that
we only need to append things to.

There were a couple of problems in the "gather" code where you
dropped efi memory sections before doing the contiguity scan, so
you ended up not using memory that could have been used. That may
have contributed to it not booting on tiger (as it ignored all memory
below 4G!).  But I didn't track down exactly what was wrong.

Then I went wild and re-arranged a whole lot of stuff, and added
code to pick out the UC memory, and save the trimmed off pieces
for use by efi_memmap_walk_uc().

Remaining issues:
1) Does it boot on anything else? (I only tried Tiger so far, but I
did confirm that memory passed to the kernel is identical to the
old efi_memmap_walk/trim_top/trim_bottom).
2) I trimmed down the find_memmap_space() routine ... but I am not
really happy with it.  We need to find a relatively tiny piece of
memory to use, but I fear we have to duplicate most of the code
to figure out the granule boundaries to be sure of picking from
memory that will eventually be part of the kernel.
3) Does it find the UC memory on sn2?  Or do the type/attribute
checks need tweaking?  My version returns region 6 addresses (for
symmetry with the region 7 addresses returned by the regular walk),
but the original just returned physical addresses. I switch to
physical easily if that is of more use to the callers.
4) Most of these routines should be marked "__init".
5) There is debug code at the bottom of efi.c to print out a summary
of the blocks of memory available for the kernel ("K") and for the
uncached allocator ("U").  This shouldn't be checked in, but it may
be useful to check whether this code is doing the right thing.

-Tony

diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -239,57 +239,30 @@ is_available_memory (efi_memory_desc_t *
 	return 0;
 }
 
-/*
- * Trim descriptor MD so its starts at address START_ADDR.  If the descriptor covers
- * memory that is normally available to the kernel, issue a warning that some memory
- * is being ignored.
- */
-static void
-trim_bottom (efi_memory_desc_t *md, u64 start_addr)
-{
-	u64 num_skipped_pages;
+typedef struct kern_memdesc {
+	u64 attribute;
+	u64 start;
+	u64 num_pages;
+} kern_memdesc_t;
 
-	if (md->phys_addr >= start_addr || !md->num_pages)
-		return;
-
-	num_skipped_pages = (start_addr - md->phys_addr) >> EFI_PAGE_SHIFT;
-	if (num_skipped_pages > md->num_pages)
-		num_skipped_pages = md->num_pages;
-
-	if (is_available_memory(md))
-		printk(KERN_NOTICE "efi.%s: ignoring %luKB of memory at 0x%lx due to granule hole "
-		       "at 0x%lx\n", __FUNCTION__,
-		       (num_skipped_pages << EFI_PAGE_SHIFT) >> 10,
-		       md->phys_addr, start_addr - IA64_GRANULE_SIZE);
-	/*
-	 * NOTE: Don't set md->phys_addr to START_ADDR because that could cause the memory
-	 * descriptor list to become unsorted.  In such a case, md->num_pages will be
-	 * zero, so the Right Thing will happen.
-	 */
-	md->phys_addr += num_skipped_pages << EFI_PAGE_SHIFT;
-	md->num_pages -= num_skipped_pages;
-}
+static kern_memdesc_t *kern_memmap;
 
 static void
-trim_top (efi_memory_desc_t *md, u64 end_addr)
+walk (efi_freemem_callback_t callback, void *arg, u64 attr)
 {
-	u64 num_dropped_pages, md_end_addr;
+	kern_memdesc_t *k;
+	u64 start, end;
 
-	md_end_addr = md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT);
-
-	if (md_end_addr <= end_addr || !md->num_pages)
-		return;
-
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
+	for (k = kern_memmap; k->start != ~0UL; k++) {
+		if (k->attribute != attr)
+			continue;
+		start = (attr = EFI_MEMORY_WB) ? PAGE_OFFSET : __IA64_UNCACHED_OFFSET;
+		start += PAGE_ALIGN(k->start);
+		end = (start + (k->num_pages << EFI_PAGE_SHIFT)) & PAGE_MASK;
+		if (start < end)
+			if ((*callback)(start, end, arg) < 0)
+				return;
+	}
 }
 
 /*
@@ -299,148 +272,19 @@ trim_top (efi_memory_desc_t *md, u64 end
 void
 efi_memmap_walk (efi_freemem_callback_t callback, void *arg)
 {
-	int prev_valid = 0;
-	struct range {
-		u64 start;
-		u64 end;
-	} prev, curr;
-	void *efi_map_start, *efi_map_end, *p, *q;
-	efi_memory_desc_t *md, *check_md;
-	u64 efi_desc_size, start, end, granule_addr, last_granule_addr, first_non_wb_addr = 0;
-	unsigned long total_mem = 0;
-
-	efi_map_start = __va(ia64_boot_param->efi_memmap);
-	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
-	efi_desc_size = ia64_boot_param->efi_memdesc_size;
-
-	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
-		md = p;
-
-		/* skip over non-WB memory descriptors; that's all we're interested in... */
-		if (!(md->attribute & EFI_MEMORY_WB))
-			continue;
-
-		/*
-		 * granule_addr is the base of md's first granule.
-		 * [granule_addr - first_non_wb_addr) is guaranteed to
-		 * be contiguous WB memory.
-		 */
-		granule_addr = GRANULEROUNDDOWN(md->phys_addr);
-		first_non_wb_addr = max(first_non_wb_addr, granule_addr);
-
-		if (first_non_wb_addr < md->phys_addr) {
-			trim_bottom(md, granule_addr + IA64_GRANULE_SIZE);
-			granule_addr = GRANULEROUNDDOWN(md->phys_addr);
-			first_non_wb_addr = max(first_non_wb_addr, granule_addr);
-		}
-
-		for (q = p; q < efi_map_end; q += efi_desc_size) {
-			check_md = q;
-
-			if ((check_md->attribute & EFI_MEMORY_WB) &&
-			    (check_md->phys_addr = first_non_wb_addr))
-				first_non_wb_addr += check_md->num_pages << EFI_PAGE_SHIFT;
-			else
-				break;		/* non-WB or hole */
-		}
-
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
-				continue;
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
-			}
-			total_mem += (md->num_pages << EFI_PAGE_SHIFT);
-
-			if (md->num_pages = 0)
-				continue;
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
-				if (prev.end = curr.start) {
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
-		}
-	}
-	if (prev_valid) {
-		start = PAGE_ALIGN(prev.start);
-		end = prev.end & PAGE_MASK;
-		if (end > start)
-			(*callback)(start, end, arg);
-	}
+	walk(callback, arg, EFI_MEMORY_WB);
 }
 
 /*
- * Walk the EFI memory map to pull out leftover pages in the lower
- * memory regions which do not end up in the regular memory map and
- * stick them into the uncached allocator
- *
- * The regular walk function is significantly more complex than the
- * uncached walk which means it really doesn't make sense to try and
- * marge the two.
+ * Walks the EFI memory map and calls CALLBACK once for each EFI memory descriptor that
+ * has memory that is available for uncached allocator.
  */
-void __init
-efi_memmap_walk_uc (efi_freemem_callback_t callback)
+void
+efi_memmap_walk_uc (efi_freemem_callback_t callback, void *arg)
 {
-	void *efi_map_start, *efi_map_end, *p;
-	efi_memory_desc_t *md;
-	u64 efi_desc_size, start, end;
-
-	efi_map_start = __va(ia64_boot_param->efi_memmap);
-	efi_map_end = efi_map_start + ia64_boot_param->efi_memmap_size;
-	efi_desc_size = ia64_boot_param->efi_memdesc_size;
-
-	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
-		md = p;
-		if (md->attribute = EFI_MEMORY_UC) {
-			start = PAGE_ALIGN(md->phys_addr);
-			end = PAGE_ALIGN((md->phys_addr+(md->num_pages << EFI_PAGE_SHIFT)) & PAGE_MASK);
-			if ((*callback)(start, end, NULL) < 0)
-				return;
-		}
-	}
+	walk(callback, arg, EFI_MEMORY_UC);
 }
 
-
 /*
  * Look for the PAL_CODE region reported by EFI and maps it using an
  * ITR to enable safe PAL calls in virtual mode.  See IA-64 Processor
@@ -862,3 +706,196 @@ efi_uart_console_only(void)
 	printk(KERN_ERR "Malformed %s value\n", name);
 	return 0;
 }
+
+#define efi_md_size(md)	(md->num_pages << EFI_PAGE_SHIFT)
+
+static inline u64
+kmd_end(kern_memdesc_t *kmd)
+{
+	return (kmd->start + (kmd->num_pages << EFI_PAGE_SHIFT));
+}
+
+static inline u64
+efi_md_end(efi_memory_desc_t *md)
+{
+	return (md->phys_addr + efi_md_size(md));
+}
+
+static inline int
+efi_wb(efi_memory_desc_t *md)
+{
+	return (md->attribute & EFI_MEMORY_WB);
+}
+
+static inline int
+efi_uc(efi_memory_desc_t *md)
+{
+	return (md->attribute & EFI_MEMORY_UC);
+}
+
+/*
+ * Look for the first granule aligned memory descriptor memory
+ * that is big enough to hold EFI memory map. Make sure this
+ * descriptor is atleast granule sized so it does not get trimmed
+ */
+struct kern_memdesc *
+find_memmap_space (void)
+{
+	void *efi_map_start, *efi_map_end, *p;
+	u64 efi_desc_size, space_needed;
+	u64 smallest_block = UINT_MAX;
+	u64 small_block_addr = -1UL;
+	u64 block_size;
+	efi_memory_desc_t *md;
+
+	efi_map_start = __va(ia64_boot_param->efi_memmap);
+	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size = ia64_boot_param->efi_memdesc_size;
+
+	/*
+	 * We will allocate enough memory to hold as many nodes as
+	 * there are in EFI memory map and a null node.
+	 */
+	space_needed = sizeof(kern_memdesc_t)*((ia64_boot_param->efi_memmap_size/efi_desc_size) + 1);
+
+	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
+		md = p;
+
+		/* skip over non-available memory descriptors */
+		if (!is_available_memory(md) || md->type = EFI_LOADER_DATA)
+			continue;
+		block_size = efi_md_size(md);
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
+	return __va(small_block_addr);
+}
+
+/*
+ * Walk the EFI memory map and gather all memory available for kernel
+ * to use.  We can allocate partial granules only if the unavailable
+ * parts exist, and are WB.
+ */
+void
+efi_memmap_init(unsigned long *s, unsigned long *e)
+{
+	struct kern_memdesc *k, *prev = 0;
+	u64	contig_low=0, contig_high=0;
+	u64	as, ae, lim;
+	void *efi_map_start, *efi_map_end, *p, *q;
+	efi_memory_desc_t *md, *pmd = NULL, *check_md;
+	u64	efi_desc_size;
+	unsigned long total_mem = 0;
+
+	k = kern_memmap = find_memmap_space();
+
+	efi_map_start = __va(ia64_boot_param->efi_memmap);
+	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size = ia64_boot_param->efi_memdesc_size;
+
+	for (p = efi_map_start; p < efi_map_end; pmd = md, p += efi_desc_size) {
+		md = p;
+		if (!efi_wb(md)) {
+			if (efi_uc(md) && md->type = EFI_CONVENTIONAL_MEMORY) {
+				k->attribute = EFI_MEMORY_UC;
+				k->start = md->phys_addr;
+				k->num_pages = md->num_pages;
+				k++;
+			}
+			continue;
+		}
+		if (pmd = NULL || !efi_wb(pmd) || efi_md_end(pmd) != md->phys_addr) {
+			contig_low = GRANULEROUNDUP(md->phys_addr);
+			contig_high = efi_md_end(md);
+			for (q = p + efi_desc_size; q < efi_map_end; q += efi_desc_size) {
+				check_md = q;
+				if (!efi_wb(check_md))
+					break;
+				if (contig_high != check_md->phys_addr)
+					break;
+				contig_high = efi_md_end(check_md);
+			}
+			contig_high = GRANULEROUNDDOWN(contig_high);
+		}
+		if (!is_available_memory(md))
+			continue;
+
+		/*
+		 * Round ends inward to granule boundaries
+		 * Give trimmings to uncached allocator
+		 */
+		if (md->phys_addr < contig_low) {
+			lim = min(kmd_end(k), contig_low);
+			if (efi_uc(md)) {
+				if (k > kern_memmap && (k-1)->attribute = EFI_MEMORY_UC &&
+				    kmd_end(k-1) = md->phys_addr) {
+					(k-1)->num_pages += (lim - md->phys_addr) >> EFI_PAGE_SHIFT;
+				} else {
+					k->attribute = EFI_MEMORY_UC;
+					k->start = md->phys_addr;
+					k->num_pages = (lim - md->phys_addr) >> EFI_PAGE_SHIFT;
+					k++;
+				}
+			}
+			as = lim;
+		} else
+			as = md->phys_addr;
+
+		if (efi_md_end(md) > contig_high) {
+			lim = max(md->phys_addr, contig_high);
+			if (efi_uc(md)) {
+				if (lim = md->phys_addr && k > kern_memmap &&
+				    (k-1)->attribute = EFI_MEMORY_UC &&
+				    kmd_end(k-1) = md->phys_addr) {
+					(k-1)->num_pages += md->num_pages;
+				} else {
+					k->attribute = EFI_MEMORY_UC;
+					k->start = lim;
+					k->num_pages = (efi_md_end(md) - k->start) >> EFI_PAGE_SHIFT;
+					k++;
+				}
+			}
+			ae = lim;
+		} else
+			ae = efi_md_end(md);
+
+		/* keep within max_addr= command line arg */
+		ae = min(ae, max_addr);
+		if (ae <= as)
+			continue;
+
+		/* avoid going over mem= command line arg */
+		if (total_mem + (ae - as) > mem_limit)
+			ae -= total_mem + (ae - as) - mem_limit;
+
+		if (ae <= as)
+			continue;
+		if (prev && kmd_end(prev) = md->phys_addr) {
+			prev->num_pages += (ae - as) >> EFI_PAGE_SHIFT;
+			total_mem += ae - as;
+			continue;
+		}
+		k->attribute = EFI_MEMORY_WB;
+		k->start = as;
+		k->num_pages = (ae - as) >> EFI_PAGE_SHIFT;
+		total_mem += ae - as;
+		prev = k++;
+	}
+	k->start = ~0L; /* end-marker */
+
+	/* reserve the memory we are using for kern_memmap */
+	*s = (u64)kern_memmap;
+	*e = (u64)++k;
+
+/*DEBUG PRINTK TO BE REMOVED*/
+	for (k = kern_memmap; k->start != ~0L; k++)
+		printk("%c %.16lx %.16lx\n", (k->attribute = EFI_MEMORY_WB)?'K':'U',
+			k->start, kmd_end(k));
+}
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -211,6 +211,9 @@ reserve_memory (void)
 	}
 #endif
 
+	efi_memmap_init(&rsvd_region[n].start, &rsvd_region[n].end);
+	n++;
+
 	/* end of memory marker */
 	rsvd_region[n].start = ~0UL;
 	rsvd_region[n].end   = ~0UL;
diff --git a/include/asm-ia64/meminit.h b/include/asm-ia64/meminit.h
--- a/include/asm-ia64/meminit.h
+++ b/include/asm-ia64/meminit.h
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
@@ -33,6 +34,7 @@ extern void find_memory (void);
 extern void reserve_memory (void);
 extern void find_initrd (void);
 extern int filter_rsvd_memory (unsigned long start, unsigned long end, void *arg);
+extern void efi_memmap_init(unsigned long *, unsigned long *);
 
 /*
  * For rounding an address to the next IA64_GRANULE_SIZE or order
