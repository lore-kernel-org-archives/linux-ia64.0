From: Khalid Aziz <khalid_aziz@hp.com>
Date: Tue, 25 Oct 2005 22:52:53 +0000
Subject: [PATCH] kexec on ia64
Message-Id: <1130280773.15053.11.camel@lyra.fc.hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-QmwFuLdvrJz+gO4Ih13F"
List-Id: <linux-ia64.vger.kernel.org>
References: <1100550721.26287.32.camel@lyra.fc.hp.com>
In-Reply-To: <1100550721.26287.32.camel@lyra.fc.hp.com>
To: linux-ia64@vger.kernel.org


--=-QmwFuLdvrJz+gO4Ih13F
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

I have ported the original patch I had done for kexec on ia64 on 2.6.8
kernel and fixed a few bugs in the original patch. Attached is a patch
for kernel 2.6.14-rc4. It works with normal kexec reboot on an HP
rx2600. I am now working on adding support for crash kexec. I am also
working on kexec on INIT which I currently have working on 2.6.10
kernel. I am porting it to 2.6.14-rc kernel.

Attached patch needs to be applied on top of iomem and efi_memmapwalk
patches already in ia64 test tree (these patches attached as well for
those who may need them). 

Signed-off-by: Khalid Aziz <khalid.aziz@hp.com>

-- 
Khalid

====================================================================
Khalid Aziz                       Open Source and Linux Organization
(970)898-9214                                        Hewlett-Packard
khalid.aziz@hp.com                                  Fort Collins, CO

"The Linux kernel is subject to relentless development" 
                                - Alessandro Rubini

--=-QmwFuLdvrJz+gO4Ih13F
Content-Disposition: attachment; filename=iomem-2.6.14-rc4.patch
Content-Type: text/x-patch; name=iomem-2.6.14-rc4.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit

--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -923,3 +923,90 @@ efi_memmap_init(unsigned long *s, unsign
 	*s = (u64)kern_memmap;
 	*e = (u64)++k;
 }
+
+void
+efi_initialize_iomem_resources(struct resource *code_resource,
+			       struct resource *data_resource)
+{
+	struct resource *res;
+	void *efi_map_start, *efi_map_end, *p;
+	efi_memory_desc_t *md;
+	u64 efi_desc_size;
+	char *name;
+	unsigned long flags;
+
+	efi_map_start = __va(ia64_boot_param->efi_memmap);
+	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size = ia64_boot_param->efi_memdesc_size;
+
+	res = NULL;
+
+	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
+		md = p;
+
+		if (md->num_pages == 0) /* should not happen */
+			continue;
+
+		flags = IORESOURCE_MEM;
+		switch (md->type) {
+
+			case EFI_MEMORY_MAPPED_IO:
+			case EFI_MEMORY_MAPPED_IO_PORT_SPACE:
+				continue;
+
+			case EFI_LOADER_CODE:
+			case EFI_LOADER_DATA:
+			case EFI_BOOT_SERVICES_DATA:
+			case EFI_BOOT_SERVICES_CODE:
+			case EFI_CONVENTIONAL_MEMORY:
+				if (md->attribute & EFI_MEMORY_WP) {
+					name = "System ROM";
+					flags |= IORESOURCE_READONLY;
+				} else {
+					name = "System RAM";
+				}
+				break;
+
+			case EFI_ACPI_MEMORY_NVS:
+				name = "ACPI Non-volatile Storage";
+				flags |= IORESOURCE_BUSY;
+				break;
+
+			case EFI_UNUSABLE_MEMORY:
+				name = "reserved";
+				flags |= IORESOURCE_BUSY | IORESOURCE_DISABLED;
+				break;
+
+			case EFI_RESERVED_TYPE:
+			case EFI_RUNTIME_SERVICES_CODE:
+			case EFI_RUNTIME_SERVICES_DATA:
+			case EFI_ACPI_RECLAIM_MEMORY:
+			default:
+				name = "reserved";
+				flags |= IORESOURCE_BUSY;
+				break;
+		}
+
+		if ((res = kcalloc(1, sizeof(struct resource), GFP_KERNEL)) == NULL) {
+			printk(KERN_ERR "failed to alocate resource for iomem\n");
+			return;
+		}
+
+		res->name = name;
+		res->start = md->phys_addr;
+		res->end = md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) - 1;
+		res->flags = flags;
+
+		if (insert_resource(&iomem_resource, res) < 0)
+			kfree(res);
+		else {
+			/*
+			 * We don't know which region contains
+			 * kernel data so we try it repeatedly and
+			 * let the resource manager test it.
+			 */
+			insert_resource(res, code_resource);
+			insert_resource(res, data_resource);
+		}
+	}
+}
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -78,6 +78,19 @@ struct screen_info screen_info;
 unsigned long vga_console_iobase;
 unsigned long vga_console_membase;
 
+static struct resource data_resource = {
+	.name	= "Kernel data",
+	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM
+};
+
+static struct resource code_resource = {
+	.name	= "Kernel code",
+	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM
+};
+extern void efi_initialize_iomem_resources(struct resource *,
+		struct resource *);
+extern char _text[], _edata[], _etext[];
+
 unsigned long ia64_max_cacheline_size;
 unsigned long ia64_iobase;	/* virtual address for I/O accesses */
 EXPORT_SYMBOL(ia64_iobase);
@@ -171,6 +184,22 @@ sort_regions (struct rsvd_region *rsvd_r
 	}
 }
 
+/*
+ * Request address space for all standard resources
+ */
+static int __init register_memory(void)
+{
+	code_resource.start = ia64_tpa(_text);
+	code_resource.end   = ia64_tpa(_etext) - 1;
+	data_resource.start = ia64_tpa(_etext);
+	data_resource.end   = ia64_tpa(_edata) - 1;
+	efi_initialize_iomem_resources(&code_resource, &data_resource);
+
+	return 0;
+}
+
+__initcall(register_memory);
+
 /**
  * reserve_memory - setup reserved memory areas
  *

--=-QmwFuLdvrJz+gO4Ih13F
Content-Disposition: attachment; filename=efi_memmapwalk-2.6.14-rc4.patch
Content-Type: text/x-patch; name=efi_memmapwalk-2.6.14-rc4.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit

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
+	u64 start, end, voff;
 
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
+	voff = (attr == EFI_MEMORY_WB) ? PAGE_OFFSET : __IA64_UNCACHED_OFFSET;
+	for (k = kern_memmap; k->start != ~0UL; k++) {
+		if (k->attribute != attr)
+			continue;
+		start = PAGE_ALIGN(k->start);
+		end = (k->start + (k->num_pages << EFI_PAGE_SHIFT)) & PAGE_MASK;
+		if (start < end)
+			if ((*callback)(start + voff, end + voff, arg) < 0)
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
-			    (check_md->phys_addr == first_non_wb_addr))
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
-			if (md->num_pages == 0)
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
-		if (md->attribute == EFI_MEMORY_UC) {
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
@@ -862,3 +706,220 @@ efi_uart_console_only(void)
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
+	u64	contig_low=0, contig_high=0;
+	u64	as = 0, ae;
+	void *efi_map_start, *efi_map_end, *p, *q;
+	efi_memory_desc_t *md, *pmd = NULL, *check_md;
+	u64	space_needed, efi_desc_size;
+	unsigned long total_mem = 0;
+
+	efi_map_start = __va(ia64_boot_param->efi_memmap);
+	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size = ia64_boot_param->efi_memdesc_size;
+
+	/*
+	 * Worst case: we need 3 kernel descriptors for each efi descriptor
+	 * (if every entry has a WB part in the middle, and UC head and tail),
+	 * plus one for the end marker.
+	 */
+	space_needed = sizeof(kern_memdesc_t) *
+		(3 * (ia64_boot_param->efi_memmap_size/efi_desc_size) + 1);
+
+	for (p = efi_map_start; p < efi_map_end; pmd = md, p += efi_desc_size) {
+		md = p;
+		if (!efi_wb(md)) {
+			continue;
+		}
+		if (pmd == NULL || !efi_wb(pmd) || efi_md_end(pmd) != md->phys_addr) {
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
+		if (!is_available_memory(md) || md->type == EFI_LOADER_DATA)
+			continue;
+
+		/* Round ends inward to granule boundaries */
+		as = max(contig_low, md->phys_addr);
+		ae = min(contig_high, efi_md_end(md));
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
+
+		if (ae - as > space_needed)
+			break;
+	}
+	if (p >= efi_map_end)
+		panic("Can't allocate space for kernel memory descriptors");
+
+	return __va(as);
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
+			if (efi_uc(md) && (md->type == EFI_CONVENTIONAL_MEMORY ||
+				    	   md->type == EFI_BOOT_SERVICES_DATA)) {
+				k->attribute = EFI_MEMORY_UC;
+				k->start = md->phys_addr;
+				k->num_pages = md->num_pages;
+				k++;
+			}
+			continue;
+		}
+		if (pmd == NULL || !efi_wb(pmd) || efi_md_end(pmd) != md->phys_addr) {
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
+			lim = min(efi_md_end(md), contig_low);
+			if (efi_uc(md)) {
+				if (k > kern_memmap && (k-1)->attribute == EFI_MEMORY_UC &&
+				    kmd_end(k-1) == md->phys_addr) {
+					(k-1)->num_pages += (lim - md->phys_addr) >> EFI_PAGE_SHIFT;
+				} else {
+					k->attribute = EFI_MEMORY_UC;
+					k->start = md->phys_addr;
+					k->num_pages = (lim - md->phys_addr) >> EFI_PAGE_SHIFT;
+					k++;
+				}
+			}
+			as = contig_low;
+		} else
+			as = md->phys_addr;
+
+		if (efi_md_end(md) > contig_high) {
+			lim = max(md->phys_addr, contig_high);
+			if (efi_uc(md)) {
+				if (lim == md->phys_addr && k > kern_memmap &&
+				    (k-1)->attribute == EFI_MEMORY_UC &&
+				    kmd_end(k-1) == md->phys_addr) {
+					(k-1)->num_pages += md->num_pages;
+				} else {
+					k->attribute = EFI_MEMORY_UC;
+					k->start = lim;
+					k->num_pages = (efi_md_end(md) - lim) >> EFI_PAGE_SHIFT;
+					k++;
+				}
+			}
+			ae = contig_high;
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
+		if (prev && kmd_end(prev) == md->phys_addr) {
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
+}
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
--- a/arch/ia64/kernel/uncached.c
+++ b/arch/ia64/kernel/uncached.c
@@ -205,23 +205,18 @@ EXPORT_SYMBOL(uncached_free_page);
 static int __init
 uncached_build_memmap(unsigned long start, unsigned long end, void *arg)
 {
-	long length;
-	unsigned long vstart, vend;
+	long length = end - start;
 	int node;
 
-	length = end - start;
-	vstart = start + __IA64_UNCACHED_OFFSET;
-	vend = end + __IA64_UNCACHED_OFFSET;
-
 	dprintk(KERN_ERR "uncached_build_memmap(%lx %lx)\n", start, end);
 
-	memset((char *)vstart, 0, length);
+	memset((char *)start, 0, length);
 
-	node = paddr_to_nid(start);
+	node = paddr_to_nid(start - __IA64_UNCACHED_OFFSET);
 
-	for (; vstart < vend ; vstart += PAGE_SIZE) {
-		dprintk(KERN_INFO "sticking %lx into the pool!\n", vstart);
-		gen_pool_free(uncached_pool[node], vstart, PAGE_SIZE);
+	for (; start < end ; start += PAGE_SIZE) {
+		dprintk(KERN_INFO "sticking %lx into the pool!\n", start);
+		gen_pool_free(uncached_pool[node], start, PAGE_SIZE);
 	}
 
 	return 0;
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

--=-QmwFuLdvrJz+gO4Ih13F
Content-Disposition: attachment; filename=kexec-ia64-2.6.14-rc4.patch
Content-Type: text/x-patch; name=kexec-ia64-2.6.14-rc4.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit

diff -urNp linux-2.6.14-rc4/arch/ia64/hp/common/sba_iommu.c linux-2.6.14-rc4-kexec-ia64/arch/ia64/hp/common/sba_iommu.c
--- linux-2.6.14-rc4/arch/ia64/hp/common/sba_iommu.c	2005-08-28 17:41:01.000000000 -0600
+++ linux-2.6.14-rc4-kexec-ia64/arch/ia64/hp/common/sba_iommu.c	2005-10-24 09:18:19.000000000 -0600
@@ -1624,6 +1624,28 @@ ioc_iova_init(struct ioc *ioc)
 	READ_REG(ioc->ioc_hpa + IOC_IBASE);
 }
 
+#ifdef CONFIG_KEXEC
+void
+ioc_iova_disable(void)
+{
+	struct ioc *ioc;
+
+	ioc = ioc_list;
+
+	while (ioc != NULL) {
+		/* Disable IOVA translation */
+		WRITE_REG(ioc->ibase & 0xfffffffffffffffe, ioc->ioc_hpa + IOC_IBASE);
+		READ_REG(ioc->ioc_hpa + IOC_IBASE);
+
+		/* Clear I/O TLB of any possible entries */
+		WRITE_REG(ioc->ibase | (get_iovp_order(ioc->iov_size) + iovp_shift), ioc->ioc_hpa + IOC_PCOM);
+		READ_REG(ioc->ioc_hpa + IOC_PCOM);
+
+		ioc = ioc->next;
+	}
+}
+#endif
+
 static void __init
 ioc_resource_init(struct ioc *ioc)
 {
diff -urNp linux-2.6.14-rc4/arch/ia64/Kconfig linux-2.6.14-rc4-kexec-ia64/arch/ia64/Kconfig
--- linux-2.6.14-rc4/arch/ia64/Kconfig	2005-10-19 09:04:33.000000000 -0600
+++ linux-2.6.14-rc4-kexec-ia64/arch/ia64/Kconfig	2005-10-24 09:18:19.000000000 -0600
@@ -323,6 +323,23 @@ config PERFMON
 	  little bigger and slows down execution a bit, but it is generally
 	  a good idea to turn this on.  If you're unsure, say Y.
 
+config KEXEC
+	bool "kexec system call (EXPERIMENTAL)"
+	depends on EXPERIMENTAL
+	help
+         kexec is a system call that implements the ability to shutdown your
+         current kernel, and to start another kernel.  It is like a reboot
+         but it is indepedent of the system firmware.   And like a reboot
+         you can start any kernel with it, not just Linux.  
+       
+         The name comes from the similiarity to the exec system call. 
+       
+         It is an ongoing process to be certain the hardware in a machine
+         is properly shutdown, so do not be surprised if this code does not
+         initially work for you.  It may help to enable device hotplugging
+         support.  As of this writing the exact hardware interface is
+         strongly in flux, so no good recommendation can be made.
+
 config IA64_PALINFO
 	tristate "/proc/pal support"
 	help
diff -urNp linux-2.6.14-rc4/arch/ia64/kernel/crash.c linux-2.6.14-rc4-kexec-ia64/arch/ia64/kernel/crash.c
--- linux-2.6.14-rc4/arch/ia64/kernel/crash.c	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.14-rc4-kexec-ia64/arch/ia64/kernel/crash.c	2005-10-24 11:06:50.000000000 -0600
@@ -0,0 +1,44 @@
+/*
+ * Architecture specific (ia64) functions for kexec based crash dumps.
+ *
+ * Created by: Khalid Aziz (khalid.aziz@hp.com)
+ *
+ * Copyright (C) Hewlett Packard, 2005. All rights reserved.
+ *
+ */
+#include <linux/init.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/smp.h>
+#include <linux/irq.h>
+#include <linux/reboot.h>
+#include <linux/kexec.h>
+#include <linux/irq.h>
+#include <linux/delay.h>
+#include <linux/elf.h>
+#include <linux/elfcore.h>
+
+note_buf_t crash_notes[NR_CPUS];
+
+void
+machine_crash_shutdown(struct pt_regs *pt)
+{
+	extern void terminate_irqs(void);
+
+	/* This function is only called after the system
+	 * has paniced or is otherwise in a critical state.
+	 * The minimum amount of code to allow a kexec'd kernel
+	 * to run successfully needs to happen here.
+	 *
+	 * In practice this means shooting down the other cpus in
+	 * an SMP system.
+	 */
+	if (in_interrupt()) {
+		terminate_irqs();
+		ia64_eoi();
+	}
+	system_state = SYSTEM_RESTART;
+	device_shutdown();
+	system_state = SYSTEM_BOOTING;
+	machine_shutdown();
+}
diff -urNp linux-2.6.14-rc4/arch/ia64/kernel/efi.c linux-2.6.14-rc4-kexec-ia64/arch/ia64/kernel/efi.c
--- linux-2.6.14-rc4/arch/ia64/kernel/efi.c	2005-10-20 16:44:30.000000000 -0600
+++ linux-2.6.14-rc4-kexec-ia64/arch/ia64/kernel/efi.c	2005-10-24 09:25:03.000000000 -0600
@@ -38,6 +38,9 @@
 extern efi_status_t efi_call_phys (void *, ...);
 
 struct efi efi;
+#ifdef CONFIG_KEXEC
+unsigned long kexec_reboot = 0;
+#endif
 EXPORT_SYMBOL(efi);
 static efi_runtime_services_t *runtime;
 static unsigned long mem_limit = ~0UL, max_addr = ~0UL;
@@ -526,6 +529,9 @@ efi_map_pal_code (void)
 	 * Cannot write to CRx with PSR.ic=1
 	 */
 	psr = ia64_clear_ic();
+#ifdef CONFIG_KEXEC
+	ia64_ptr(0x01, GRANULEROUNDDOWN((unsigned long) pal_vaddr), IA64_GRANULE_SHIFT);
+#endif
 	ia64_itr(0x1, IA64_TR_PALCODE, GRANULEROUNDDOWN((unsigned long) pal_vaddr),
 		 pte_val(pfn_pte(__pa(pal_vaddr) >> PAGE_SHIFT, PAGE_KERNEL)),
 		 IA64_GRANULE_SHIFT);
@@ -549,15 +555,22 @@ efi_init (void)
 		if (memcmp(cp, "mem=", 4) == 0) {
 			cp += 4;
 			mem_limit = memparse(cp, &end);
-			if (end != cp)
-				break;
 			cp = end;
+			while (*cp == ' ')
+				++cp;
 		} else if (memcmp(cp, "max_addr=", 9) == 0) {
 			cp += 9;
 			max_addr = GRANULEROUNDDOWN(memparse(cp, &end));
-			if (end != cp)
-				break;
 			cp = end;
+			while (*cp == ' ')
+				++cp;
+#ifdef CONFIG_KEXEC
+		} else if (memcmp(cp, "kexec_reboot", 12) == 0) {
+			cp += 13;
+			kexec_reboot = 1;
+			while (*cp == ' ')
+				++cp;
+#endif
 		} else {
 			while (*cp != ' ' && *cp)
 				++cp;
@@ -702,10 +715,17 @@ efi_enter_virtual_mode (void)
 		}
 	}
 
+#ifdef CONFIG_KEXEC
+	if (kexec_reboot == 0)
+#endif
 	status = efi_call_phys(__va(runtime->set_virtual_address_map),
 			       ia64_boot_param->efi_memmap_size,
 			       efi_desc_size, ia64_boot_param->efi_memdesc_version,
 			       ia64_boot_param->efi_memmap);
+#ifdef CONFIG_KEXEC
+	else
+		status = EFI_SUCCESS;
+#endif
 	if (status != EFI_SUCCESS) {
 		printk(KERN_WARNING "warning: unable to switch EFI into virtual mode "
 		       "(status=%lu)\n", status);
diff -urNp linux-2.6.14-rc4/arch/ia64/kernel/entry.S linux-2.6.14-rc4-kexec-ia64/arch/ia64/kernel/entry.S
--- linux-2.6.14-rc4/arch/ia64/kernel/entry.S	2005-10-19 09:04:34.000000000 -0600
+++ linux-2.6.14-rc4-kexec-ia64/arch/ia64/kernel/entry.S	2005-10-24 09:25:39.000000000 -0600
@@ -1588,7 +1588,7 @@ sys_call_table:
 	data8 sys_mq_timedreceive		// 1265
 	data8 sys_mq_notify
 	data8 sys_mq_getsetattr
-	data8 sys_ni_syscall			// reserved for kexec_load
+	data8 sys_kexec_load
 	data8 sys_ni_syscall			// reserved for vserver
 	data8 sys_waitid			// 1270
 	data8 sys_add_key
diff -urNp linux-2.6.14-rc4/arch/ia64/kernel/machine_kexec.c linux-2.6.14-rc4-kexec-ia64/arch/ia64/kernel/machine_kexec.c
--- linux-2.6.14-rc4/arch/ia64/kernel/machine_kexec.c	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.14-rc4-kexec-ia64/arch/ia64/kernel/machine_kexec.c	2005-10-25 14:42:35.000000000 -0600
@@ -0,0 +1,224 @@
+/*
+ * machine_kexec.c - handle transition of Linux booting another kernel
+ * Copyright (C) 2002-2003 Eric Biederman  <ebiederm@xmission.com>
+ * Copyright (C) 2005 Khalid Aziz  <khalid.aziz@hp.com>
+ *
+ * This source code is licensed under the GNU General Public License,
+ * Version 2.  See the file COPYING for more details.
+ */
+
+#include <linux/kernel.h>
+#include <linux/config.h>
+#include <linux/mm.h>
+#include <linux/kexec.h>
+#include <linux/pci.h>
+#include <asm/mmu_context.h>
+#include <asm/setup.h>
+#include <asm/mca.h>
+#include <asm/page.h>
+#include <asm/bitops.h>
+#include <asm/tlbflush.h>
+
+DECLARE_PER_CPU(u64, ia64_mca_pal_base);
+
+unsigned int kexec_on_init = 0;
+extern unsigned long ia64_iobase;
+extern unsigned long kexec_reboot;
+extern void kexec_stop_this_cpu(void *);
+extern struct subsystem devices_subsys;
+
+static void set_io_base(void)
+{
+	unsigned long phys_iobase;
+
+	/* set kr0 to iobase */
+	phys_iobase = __pa(ia64_iobase);
+	ia64_set_kr(IA64_KR_IO_BASE, __IA64_UNCACHED_OFFSET | phys_iobase);
+};
+
+typedef void (*relocate_new_kernel_t)(
+	unsigned long indirection_page, unsigned long start_address, 
+	unsigned long boot_param_address);
+
+const extern unsigned long relocate_new_kernel[];
+const extern unsigned long kexec_fake_sal_rendez[];
+const extern unsigned int relocate_new_kernel_size;
+extern void use_mm(struct mm_struct *mm);
+extern void ioc_iova_disable(void);
+
+volatile extern long kexec_cont;
+volatile const extern unsigned char kexec_reloc[];
+volatile extern long kexec_rendez;
+volatile const extern unsigned char kexec_rendez_reloc[];
+volatile extern long kexec_ptcebase, kexec_count0, kexec_count1;
+volatile extern long kexec_stride0, kexec_stride1;
+volatile extern long kexec_pal_base;
+
+static void *kexec_boot_param;
+
+/*
+ * Do what every setup is needed on image and the
+ * reboot code buffer to allow us to avoid allocations
+ * later.
+ */
+int machine_kexec_prepare(struct kimage *image)
+{
+	void *control_code_buffer;
+	unsigned long cmdline_size;
+
+	/* 
+	 * We need to save the boot parameters in kernel pages.
+	 */
+	cmdline_size = (COMMAND_LINE_SIZE + PAGE_SIZE) & PAGE_MASK;
+	if (image->segment[0].bufsz > cmdline_size) {
+		printk(KERN_ERR "Not enough space to load kernel command line (%d)\n", image->segment[0].bufsz);
+		return -ENOMEM;
+	}
+	kexec_boot_param = kmalloc(cmdline_size, GFP_KERNEL);
+	if (kexec_boot_param == NULL) 
+		return -ENOMEM;
+	memset(kexec_boot_param, 0, cmdline_size);
+	memcpy(kexec_boot_param, image->segment[0].buf, 
+			image->segment[0].bufsz);
+	/* 
+	 * We do not want command line parameters loaded in memory later 
+	 * when kernel is relocated just before kexec. So zero out memory
+	 * size for command line param segment
+	 */
+	image->segment[0].memsz = 0;
+
+#if 0
+	/* Pre-load control code buffer in case of INIT */
+	control_code_buffer = ((unsigned long)phys_to_virt(page_to_pfn(image->control_code_page) << PAGE_SHIFT) & (unsigned long)0x1fffffffffffffffL) | __IA64_UNCACHED_OFFSET;
+	kexec_rendez = (long)(page_to_pfn(image->control_code_page) << PAGE_SHIFT) + (long)kexec_rendez_reloc -  (long)kexec_fake_sal_rendez;
+
+	/* copy it out */
+	memcpy((void *)control_code_buffer, kexec_fake_sal_rendez, relocate_new_kernel_size);
+#endif
+
+	return 0;
+}
+
+void machine_kexec_cleanup(struct kimage *image)
+{
+}
+
+void machine_shutdown(void)
+{
+	struct pci_dev *dev;
+	struct list_head *n;
+	u16 command;
+
+	/* Disable bus mastering on all PCI devices */
+	n = pci_devices.next;
+	while (n && (n != &pci_devices)) {
+		dev = pci_dev_g(n);
+		pci_read_config_word(dev, PCI_COMMAND, &command);
+		command &= ~PCI_COMMAND_MASTER;
+		pci_write_config_word(dev, PCI_COMMAND, command);
+		n = n->next;
+	}
+
+#ifdef CONFIG_SMP
+	int reboot_cpu_id;
+
+	/* The boot cpu is always logical cpu 0 */
+	reboot_cpu_id = 0;
+
+	/* Make certain the cpu I'm rebooting on is online */
+	if (!cpu_isset(reboot_cpu_id, cpu_online_map)) {
+		reboot_cpu_id = smp_processor_id();
+	}
+
+	/* Make certain I only run on the appropriate processor */
+	set_cpus_allowed(current, cpumask_of_cpu(reboot_cpu_id));
+#endif
+}
+
+/*
+ * Do not allocate memory (or fail in any way) in machine_kexec().
+ * We are past the point of no return, committed to rebooting now. 
+ */
+void machine_kexec(struct kimage *image)
+{
+	unsigned long indirection_page;
+	void *control_code_buffer;
+	relocate_new_kernel_t rnk;
+	unsigned char *cmdline;
+	int cpu;
+	unsigned long initrd_start, initrd_size;
+
+	control_code_buffer = (void *) (((unsigned long)phys_to_virt(page_to_pfn(image->control_code_page) << PAGE_SHIFT) & (unsigned long)0x1fffffffffffffffL) | __IA64_UNCACHED_OFFSET);
+	indirection_page = image->head & PAGE_MASK;
+
+	/* copy it out */
+	memcpy((void *)control_code_buffer, kexec_fake_sal_rendez, relocate_new_kernel_size);
+
+	/* Save PTCE data for cache flush later */
+	kexec_ptcebase	=  local_cpu_data->ptce_base;
+	kexec_count0	= local_cpu_data->ptce_count[0];
+	kexec_count1	= local_cpu_data->ptce_count[1];
+	kexec_stride0	= local_cpu_data->ptce_stride[0];
+	kexec_stride1	= local_cpu_data->ptce_stride[1];
+
+#ifdef CONFIG_SMP
+	kexec_rendez = (long)(page_to_pfn(image->control_code_page) << PAGE_SHIFT) + (long)kexec_rendez_reloc -  (long)kexec_fake_sal_rendez;
+	if (!kexec_on_init)
+		smp_call_function(kexec_stop_this_cpu, (void *)image->start, 0, 0);
+
+#endif
+	/* Interrupts aren't acceptable while we reboot */
+	local_irq_disable();
+
+	kexec_cont = (long)(page_to_pfn(image->control_code_page) << PAGE_SHIFT) + (long)kexec_reloc -  (long) kexec_fake_sal_rendez;
+
+	/* Save PAL mapping for TR flush later */
+	cpu = smp_processor_id();
+	kexec_pal_base = __get_cpu_var(ia64_mca_pal_base);
+
+	/* set kr0 to the appropriate address */
+	set_io_base();
+
+	/* now execute the control code 
+	 * We will start by executing the control code linked into the 
+	 * kernel as opposed to the code we copied in control code buffer		 * page. When this code switches to physical mode, we will start
+	 * executing the code in control code buffer page. Reason for
+	 * doing this is we start code execution in virtual address space.
+	 * If we were to try to execute the newly copied code in virtual
+	 * address space, we will need to make an ITLB entry to avoid ITLB 
+	 * miss. By executing the code linked into kernel, we take advantage
+	 * of the ITLB entry already in place of kernel and avoid making
+	 * a new entry.
+	 */
+	control_code_buffer = (void *) relocate_new_kernel;
+	rnk = (relocate_new_kernel_t) &control_code_buffer;
+	if (strstr(kexec_boot_param, "kexec_reboot") == NULL)
+		strcat(kexec_boot_param, " kexec_reboot ");
+	cmdline = __va(ia64_boot_param->command_line);
+	strlcpy(cmdline, kexec_boot_param, COMMAND_LINE_SIZE);
+	initrd_start = image->segment[image->nr_segments-1].mem;
+	initrd_size = image->segment[image->nr_segments-1].memsz;
+	if (initrd_size != 0)
+		ia64_boot_param->initrd_start = initrd_start;
+	else
+		ia64_boot_param->initrd_start = 0UL;
+	ia64_boot_param->initrd_size = initrd_size;
+
+	{
+		unsigned long pta, impl_va_bits;
+
+#       define pte_bits                 3
+#       define vmlpt_bits               (impl_va_bits - PAGE_SHIFT + pte_bits)
+#       define POW2(n)                  (1ULL << (n))
+
+		/* Disable VHPT */
+		impl_va_bits = ffz(~(local_cpu_data->unimpl_va_mask | (7UL << 61)));
+		pta = POW2(61) - POW2(vmlpt_bits);
+		ia64_set_pta(pta | (0 << 8) | (vmlpt_bits << 2) | 0);
+	}
+
+#ifdef CONFIG_IA64_HP_ZX1
+	ioc_iova_disable();
+#endif
+	rnk(indirection_page, image->start, (unsigned long) ia64_boot_param);
+}
diff -urNp linux-2.6.14-rc4/arch/ia64/kernel/Makefile linux-2.6.14-rc4-kexec-ia64/arch/ia64/kernel/Makefile
--- linux-2.6.14-rc4/arch/ia64/kernel/Makefile	2005-10-19 09:04:34.000000000 -0600
+++ linux-2.6.14-rc4-kexec-ia64/arch/ia64/kernel/Makefile	2005-10-24 09:19:10.000000000 -0600
@@ -22,6 +22,7 @@ obj-$(CONFIG_PERFMON)		+= perfmon_defaul
 obj-$(CONFIG_IA64_CYCLONE)	+= cyclone.o
 obj-$(CONFIG_CPU_FREQ)		+= cpufreq/
 obj-$(CONFIG_IA64_MCA_RECOVERY)	+= mca_recovery.o
+obj-$(CONFIG_KEXEC)		+= machine_kexec.o relocate_kernel.o crash.o
 obj-$(CONFIG_KPROBES)		+= kprobes.o jprobes.o
 obj-$(CONFIG_IA64_UNCACHED_ALLOCATOR)	+= uncached.o
 mca_recovery-y			+= mca_drv.o mca_drv_asm.o
diff -urNp linux-2.6.14-rc4/arch/ia64/kernel/relocate_kernel.S linux-2.6.14-rc4-kexec-ia64/arch/ia64/kernel/relocate_kernel.S
--- linux-2.6.14-rc4/arch/ia64/kernel/relocate_kernel.S	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.14-rc4-kexec-ia64/arch/ia64/kernel/relocate_kernel.S	2005-10-25 14:43:42.000000000 -0600
@@ -0,0 +1,385 @@
+/*
+ * relocate_kernel.S - Relocate kexec'able kernel and start it
+ * Copyright (C) 2005 Khalid Aziz  <khalid.aziz@hp.com>
+ *
+ * This source code is licensed under the GNU General Public License,
+ * Version 2.  See the file COPYING for more details.
+ */
+
+#include <linux/config.h>
+#include <asm/asmmacro.h>
+#include <asm/kregs.h>
+#include <asm/page.h>
+#include <asm/pgtable.h>
+
+       /* Must be relocatable PIC code callable as a C function, that once
+        * it starts can not use the previous processes stack.
+        *
+        */
+       /* Q: Do I want to setup an interrupt vector, so what happens
+        * when exceptions occur is well defined?
+        */
+	.text
+	.align 32
+	.global kexec_fake_sal_rendez#
+	.proc kexec_fake_sal_rendez#
+kexec_fake_sal_rendez:
+	mf.a
+	;;
+	movl	r25=kexec_rendez
+	;;
+	ld8	r17=[r25]
+	{
+		flushrs
+		srlz.i
+	}
+	;;
+       /* See where I am running, and compute gp */
+	{
+		mov     ar.rsc = 0      /* Put RSE in enforce lacy, LE mode */
+		mov     gp = ip         /* gp == relocate_new_kernel */
+	}
+
+	movl r8=0x00000100000000
+	;;
+	mov cr.iva=r8
+	/* Transition from virtual to physical mode */
+	rsm	psr.i | psr.ic
+	srlz.i
+	movl	r16=(IA64_PSR_AC | IA64_PSR_BN | IA64_PSR_IC | IA64_PSR_MFL)
+	;;
+	mov	cr.ipsr=r16
+	;;
+	mov	cr.iip=r17
+	mov	cr.ifs=r0
+	;;
+	rfi
+	;;
+	.global kexec_rendez_reloc
+kexec_rendez_reloc:     /* Now we are in physical mode */
+
+	mov     b6=r32			/* _start addr */
+	mov	r8=r33			/* ap_wakeup_vector */
+	mov	r26=r34			/* PAL addr */
+	;;
+	/* Purge kernel TRs */
+	movl	r16=KERNEL_START
+	mov	r18=KERNEL_TR_PAGE_SHIFT<<2
+	;;
+	ptr.i	r16,r18
+	ptr.d	r16,r18
+	;;
+	srlz.i
+	;;
+	srlz.d
+	;;
+	/* Purge percpu TR */
+	movl	r16=PERCPU_ADDR
+	mov	r18=PERCPU_PAGE_SHIFT<<2
+	;;
+	ptr.d	r16,r18
+	;;
+	srlz.d
+	;;
+	/* Purge PAL TR */
+	mov	r18=IA64_GRANULE_SHIFT<<2
+	;;
+	ptr.i	r26,r18
+	;;
+	srlz.i
+	;;
+	/* Purge stack TR */
+	mov	r16=IA64_KR(CURRENT_STACK)
+	;;
+	shl	r16=r16,IA64_GRANULE_SHIFT
+	movl	r19=PAGE_OFFSET
+	;;
+	add	r16=r19,r16
+	mov	r18=IA64_GRANULE_SHIFT<<2
+	;;
+	ptr.d	r16,r18
+	;;
+	srlz.i
+	;;
+
+	/* Ensure we can read and clear external interrupts */
+	mov	cr.tpr=r0
+	srlz.d
+
+	shr.u	r9=r8,6			/* which irr */
+	;;
+	and	r8=63,r8		/* bit offset into irr */
+	;;
+	mov	r10=1;;
+	;;
+	shl	r10=r10,r8		/* bit mask off irr we want */
+	cmp.eq	p6,p0=0,r9
+	;;
+(p6)	br.cond.sptk.few        check_irr0
+	cmp.eq	p7,p0=1,r9
+	;;
+(p7)	br.cond.sptk.few        check_irr1
+	cmp.eq	p8,p0=2,r9
+	;;
+(p8)	br.cond.sptk.few        check_irr2
+	cmp.eq	p9,p0=3,r9
+	;;
+(p9)	br.cond.sptk.few        check_irr3
+
+check_irr0:
+	mov	r8=cr.irr0
+	;;
+	and	r8=r8,r10
+	;;
+	cmp.eq	p6,p0=0,r8
+(p6)	br.cond.sptk.few	check_irr0
+	br.few	call_start
+	
+check_irr1:
+	mov	r8=cr.irr1
+	;;
+	and	r8=r8,r10
+	;;
+	cmp.eq	p6,p0=0,r8
+(p6)	br.cond.sptk.few	check_irr1
+	br.few	call_start
+	
+check_irr2:
+	mov	r8=cr.irr2
+	;;
+	and	r8=r8,r10
+	;;
+	cmp.eq	p6,p0=0,r8
+(p6)	br.cond.sptk.few	check_irr2
+	br.few	call_start
+	
+check_irr3:
+	mov	r8=cr.irr3
+	;;
+	and	r8=r8,r10
+	;;
+	cmp.eq	p6,p0=0,r8
+(p6)	br.cond.sptk.few	check_irr3
+	br.few	call_start
+	
+call_start:
+	mov	cr.eoi=r0
+	;;
+	srlz.d
+	;;
+	mov	r8=cr.ivr
+	;;
+	srlz.d
+	;;
+	cmp.eq	p0,p6=15,r8
+(p6)	br.cond.sptk.few	call_start
+	br.sptk.few		b6
+	.endp kexec_fake_sal_rendez#
+
+	.global relocate_new_kernel#
+	.proc relocate_new_kernel#
+relocate_new_kernel:
+	mf
+	;;
+	/* Save the ptce information for translation cache purge later */
+	movl	r25=kexec_cont
+	movl	r27=kexec_ptcebase
+	movl	r28=kexec_count0
+	;;
+	ld8	r17=[r25]
+	ld8	r22=[r27]
+	ld8	r20=[r28]
+	;;
+	movl	r25=kexec_count1
+	movl	r27=kexec_stride0
+	movl	r28=kexec_stride1
+	;;
+	ld8	r21=[r25]
+	ld8	r23=[r27]
+	ld8	r24=[r28]
+	;;
+	movl	r27=kexec_pal_base
+	;;
+	adds 	r25=48,r27
+	;;
+	ld8	r26=[r25]
+	;;
+
+	{
+		flushrs
+		srlz.i
+	}
+	;;
+       /* See where I am running, and compute gp */
+	{
+		mov     ar.rsc = 0      /* Put RSE in enforce lacy, LE mode */
+		mov     gp = ip         /* gp == relocate_new_kernel */
+	}
+
+	movl r8=0x00000100000000
+	;;
+	mov cr.iva=r8
+
+	/* Transition from virtual to physical mode */
+	rsm	psr.i | psr.ic
+	srlz.i
+	movl	r16=(IA64_PSR_AC | IA64_PSR_BN | IA64_PSR_IC | IA64_PSR_MFL)
+	;;
+	mov	cr.ipsr=r16
+	;;
+	mov	cr.iip=r17
+	mov	cr.ifs=r0
+	;;
+	rfi
+	;;
+	.global kexec_reloc
+kexec_reloc:     /* Now we are in physical mode */
+	/* Setup the memory stack */
+	add     r12=(memory_stack_end - relocate_new_kernel),gp
+	/* Setup the register stack */
+	add     r8=(register_stack - relocate_new_kernel),gp
+	;;
+	loadrs
+	;;
+	mov     ar.bspstore=r8
+	;;
+
+	/* Do the copies */
+	mov     r8=r32
+	mov     b6=r33
+	tpa     r28=r34
+	mov     r9=0
+	mov     r11=PAGE_SIZE
+	;;
+	/* top, read another word for the indirection page */
+top:   ld8     r10=[r8], 8
+	;;
+	tbit.nz p6,p0 = r10, 0  /* Is it a destination page? */
+	tbit.nz p7,p0 = r10, 1  /* Is it an indirection page? */
+	tbit.nz p8,p0 = r10, 3  /* Is it the source indicator? */
+	tbit.nz p9,p0 = r10, 2  /* Is it the done indicator? */
+	movl	r19 = PAGE_MASK
+	;;
+	and	r10 = r10, r19	/* Clear the low 12 bits of r10 */
+	;;
+(p6)   mov     r9 = r10        /* destination addr */
+(p7)   mov     r8 = r10        /* indirection addr */
+(p8)   br.cond.sptk.few        source
+(p9)   br.cond.sptk.few        done
+	br.cond.sptk.few        top
+source:
+	add     r16 = r11, r10
+	add     r14 = 8, r10
+	add     r15 = 8, r9
+	;;
+0:
+	ld8     r17 = [r10],16
+	ld8     r18 = [r14],16
+	;;
+	st8     [r9]  = r17, 16
+	st8     [r15] = r18, 16
+	cmp.ne  p6,p0 = r16, r10
+	;;
+(p6)   br.cond.sptk.few        0b
+	br.cond.sptk.few        top
+done:
+	srlz.i
+	srlz.d
+	;;
+
+	/* Now purge local tlb */
+	mov r19 = r0
+	adds	r21=-1,r20
+	;;
+2:
+	cmp.ltu	p6,p7=r19,r20
+(p7)	br.cond.dpnt.few	4f
+	mov	ar.lc=r21
+3:
+	ptc.e	r22
+	;;
+	add	r22=r24,r22
+	br.cloop.sptk.few	3b
+	;;
+	add	r22=r23,r22
+	add	r19=1,r19
+	;;
+	br.sptk.few	2b
+4:
+	srlz.i ;;
+	
+       // Now purge addresses formerly mapped by TR registers
+	// Purge ITR&DTR for kernel.
+	movl r16=KERNEL_START
+	mov r18=KERNEL_TR_PAGE_SHIFT<<2
+	;;
+	ptr.i r16, r18
+	ptr.d r16, r18
+	;;
+	srlz.i
+	;;
+	srlz.d
+	;;
+	// Purge DTR for PERCPU data.
+	movl r16=PERCPU_ADDR
+	mov r18=PERCPU_PAGE_SHIFT<<2
+	;;
+	ptr.d r16,r18
+	;;
+	srlz.d
+	;;
+	// Purge ITR for PAL code
+	mov r18=IA64_GRANULE_SHIFT<<2
+	;;
+	ptr.i r26,r18
+	;;
+	srlz.i
+	;;
+	// Purge DTR for stack.
+	mov r16=IA64_KR(CURRENT_STACK)
+	;;
+	shl r16=r16,IA64_GRANULE_SHIFT
+	movl r19=PAGE_OFFSET
+	;;
+	add r16=r19,r16
+	mov r18=IA64_GRANULE_SHIFT<<2
+	;;
+	ptr.d r16,r18
+	;;
+	srlz.i
+	;;
+
+	br.sptk.few		b6
+	br.cond.sptk.few        0b
+	.endp relocate_new_kernel#
+
+	.balign 8192
+relocate_new_kernel_end:
+	.global relocate_new_kernel_size
+relocate_new_kernel_size:
+	.long relocate_new_kernel_end - kexec_fake_sal_rendez
+
+	.global kexec_cont
+	.align 8
+kexec_cont:	data8 0xdeadbeefdeadbeef
+	.global kexec_rendez
+kexec_rendez:	data8 0xdeadbeefdeadbeef
+	.global kexec_ptcebase
+kexec_ptcebase:	data8 0xdeadbeefdeadbeef
+	.global kexec_count0
+kexec_count0:	data8 0xdeadbeefdeadbeef
+	.global kexec_count1
+kexec_count1:	data8 0xdeadbeefdeadbeef
+	.global kexec_stride0
+kexec_stride0:	data8 0xdeadbeefdeadbeef
+	.global kexec_stride1
+kexec_stride1:	data8 0xdeadbeefdeadbeef
+	.global kexec_pal_base
+kexec_pal_base:	data8 0xdeadbeefdeadbeef
+
+register_stack:
+	.fill           8192, 1, 0
+register_stack_end:
+memory_stack:
+	.fill           8192, 1, 0
+memory_stack_end:
diff -urNp linux-2.6.14-rc4/arch/ia64/kernel/smp.c linux-2.6.14-rc4-kexec-ia64/arch/ia64/kernel/smp.c
--- linux-2.6.14-rc4/arch/ia64/kernel/smp.c	2005-08-28 17:41:01.000000000 -0600
+++ linux-2.6.14-rc4-kexec-ia64/arch/ia64/kernel/smp.c	2005-10-24 10:59:18.000000000 -0600
@@ -30,6 +30,9 @@
 #include <linux/delay.h>
 #include <linux/efi.h>
 #include <linux/bitops.h>
+#ifdef CONFIG_KEXEC
+#include <linux/kexec.h>
+#endif
 
 #include <asm/atomic.h>
 #include <asm/current.h>
@@ -84,6 +87,43 @@ unlock_ipi_calllock(void)
 	spin_unlock_irq(&call_lock);
 }
 
+#ifdef CONFIG_KEXEC
+extern void kexec_fake_sal_rendez(void *start, unsigned long wake_up,
+		unsigned long pal_base);
+
+#define pte_bits	3
+#define vmlpt_bits	(impl_va_bits - PAGE_SHIFT + pte_bits)
+#define POW2(n)		(1ULL << (n))
+
+DECLARE_PER_CPU(u64, ia64_mca_pal_base);
+
+/*
+ * Stop the CPU and put it in fake SAL rendezvous. This allows CPU to wake
+ * up with IPI from boot processor
+ */
+void
+kexec_stop_this_cpu (void *func)
+{
+	unsigned long pta, impl_va_bits, pal_base;
+
+	/*
+	 * Remove this CPU by putting it into fake SAL rendezvous
+	 */
+	cpu_clear(smp_processor_id(), cpu_online_map);
+	max_xtp();
+	ia64_eoi();
+
+	/* Disable VHPT */
+	impl_va_bits = ffz(~(local_cpu_data->unimpl_va_mask | (7UL << 61)));
+	pta = POW2(61) - POW2(vmlpt_bits);
+	ia64_set_pta(pta | (0 << 8) | (vmlpt_bits << 2) | 0);
+
+	local_irq_disable();
+	pal_base = __get_cpu_var(ia64_mca_pal_base);
+	kexec_fake_sal_rendez(func, ap_wakeup_vector, pal_base);
+}
+#endif
+
 static void
 stop_this_cpu (void)
 {
diff -urNp linux-2.6.14-rc4/include/asm-ia64/kexec.h linux-2.6.14-rc4-kexec-ia64/include/asm-ia64/kexec.h
--- linux-2.6.14-rc4/include/asm-ia64/kexec.h	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.14-rc4-kexec-ia64/include/asm-ia64/kexec.h	2005-10-24 10:20:19.000000000 -0600
@@ -0,0 +1,22 @@
+#ifndef _ASM_IA64_KEXEC_H
+#define _ASM_IA64_KEXEC_H
+
+
+/* Maximum physical address we can use pages from */
+#define KEXEC_SOURCE_MEMORY_LIMIT (-1UL)
+/* Maximum address we can reach in physical address mode */
+#define KEXEC_DESTINATION_MEMORY_LIMIT (-1UL)
+/* Maximum address we can use for the control code buffer */
+#define KEXEC_CONTROL_MEMORY_LIMIT TASK_SIZE
+
+#define KEXEC_CONTROL_CODE_SIZE (8192 + 8192 + 4096)
+
+/* The native architecture */
+#define KEXEC_ARCH KEXEC_ARCH_IA_64
+
+#define MAX_NOTE_BYTES 1024
+typedef u32 note_buf_t[MAX_NOTE_BYTES/4];
+
+extern note_buf_t crash_notes[];
+
+#endif /* _ASM_IA64_KEXEC_H */
diff -urNp linux-2.6.14-rc4/kernel/irq/handle.c linux-2.6.14-rc4-kexec-ia64/kernel/irq/handle.c
--- linux-2.6.14-rc4/kernel/irq/handle.c	2005-10-19 09:04:59.000000000 -0600
+++ linux-2.6.14-rc4-kexec-ia64/kernel/irq/handle.c	2005-10-24 09:40:27.000000000 -0600
@@ -100,6 +100,26 @@ fastcall int handle_IRQ_event(unsigned i
 }
 
 /*
+ * Terminate any outstanding interrupts
+ */
+void terminate_irqs(void)
+{
+	struct irqaction * action;
+	irq_desc_t *idesc;
+	unsigned long flags;
+	int i;
+
+	for (i=0; i<NR_IRQS; i++) {
+		idesc = irq_descp(i);
+		action = idesc->action;
+		if (!action)
+			continue;
+		if (idesc->handler->end)
+			idesc->handler->end(i);
+	}
+}
+
+/*
  * do_IRQ handles all normal device IRQ's (the special
  * SMP cross-CPU interrupts have their own specific
  * handlers).

--=-QmwFuLdvrJz+gO4Ih13F--

