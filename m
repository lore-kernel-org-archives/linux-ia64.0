From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 07 Mar 2002 18:18:23 +0000
Subject: [Linux-ia64] [PATCH] agpgart/DRM page_mask
Message-Id: <marc-linux-ia64-105590701905236@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'd like to propose putting the attached patch into the IA64 tree.

The point is to be able to support both 460GX and a similar
HP chipset without having to put kludges in DRM.

Chris Ahna and Jeff Hartmann both seem to be OK with this
approach.  It's not really IA64-specific, and I did try to get
it directly into 2.4.x/2.5.x, but there's really no benefit there
without the 460GX GART code.  So it makes sense to me to
keep it with the 460GX code, and merge both into the main
tree at the same time.
-- 
Bjorn Helgaas - bjorn_helgaas@hp.com
Linux Systems Operation R&D
Hewlett-Packard


diff -u -r -X /home/helgaas/exclude linux-2.4.18-ia64-020226/drivers/char/agp/agp.h build/linux-2.4.18-ia64-020226-pagemask/drivers/char/agp/agp.h
--- linux-2.4.18-ia64-020226/drivers/char/agp/agp.h	Wed Mar  6 16:53:47 2002
+++ build/linux-2.4.18-ia64-020226-pagemask/drivers/char/agp/agp.h	Wed Mar  6 17:06:52 2002
@@ -99,7 +99,6 @@
 	int needs_scratch_page;
 	int aperture_size_idx;
 	int num_aperture_sizes;
-	int num_of_masks;
 	int capndx;
 	int cant_use_aperture;
 
diff -u -r -X /home/helgaas/exclude linux-2.4.18-ia64-020226/drivers/char/agp/agpgart_be.c build/linux-2.4.18-ia64-020226-pagemask/drivers/char/agp/agpgart_be.c
--- linux-2.4.18-ia64-020226/drivers/char/agp/agpgart_be.c	Wed Mar  6 16:53:47 2002
+++ build/linux-2.4.18-ia64-020226-pagemask/drivers/char/agp/agpgart_be.c	Wed Mar  6 17:06:11 2002
@@ -212,8 +212,6 @@
 	if(agp_bridge.cant_use_aperture = 0) {
 		if (curr->page_count != 0) {
 			for (i = 0; i < curr->page_count; i++) {
-				curr->memory[i] = agp_bridge.unmask_memory(
-					                     curr->memory[i]);
 				agp_bridge.agp_destroy_page((unsigned long)
 						 phys_to_virt(curr->memory[i]));
 			}
@@ -302,10 +300,7 @@
 				agp_free_memory(new);
 				return NULL;
 			}
-			new->memory[i] -			    agp_bridge.mask_memory(
-					  virt_to_phys((void *) new->memory[i]),
-							  type);
+			new->memory[i] = virt_to_phys((void *) new->memory[i]);
 			new->page_count++;
 		}
 	} else {
@@ -338,7 +333,7 @@
 #else
 			paddr = pte_val(*pte) & PAGE_MASK;
 #endif
-			new->memory[i] = agp_bridge.mask_memory(paddr, type);
+			new->memory[i] = paddr;
 		}
 
 		new->page_count = page_count;
@@ -384,9 +379,6 @@
 
 void agp_copy_info(agp_kern_info * info)
 {
-	unsigned long page_mask = 0;
-	int i;
-
 	memset(info, 0, sizeof(agp_kern_info));
 	if (agp_bridge.type = NOT_SUPPORTED) {
 		info->chipset = agp_bridge.type;
@@ -402,11 +394,7 @@
 	info->max_memory = agp_bridge.max_memory_agp;
 	info->current_memory = atomic_read(&agp_bridge.current_memory_agp);
 	info->cant_use_aperture = agp_bridge.cant_use_aperture;
-
-	for(i = 0; i < agp_bridge.num_of_masks; i++)
-		page_mask |= agp_bridge.mask_memory(page_mask, i);
-
-	info->page_mask = ~page_mask;
+	info->page_mask = ~0UL;
 }
 
 /* End - Routine to copy over information structure */
@@ -835,7 +823,8 @@
 		mem->is_flushed = TRUE;
 	}
 	for (i = 0, j = pg_start; i < mem->page_count; i++, j++) {
-		agp_bridge.gatt_table[j] = mem->memory[i];
+		agp_bridge.gatt_table[j] +			agp_bridge.mask_memory(mem->memory[i], mem->type);
 	}
 
 	agp_bridge.tlb_flush(mem);
@@ -1077,7 +1066,8 @@
    	CACHE_FLUSH();
 	for (i = 0, j = pg_start; i < mem->page_count; i++, j++) {
 		OUTREG32(intel_i810_private.registers,
-			 I810_PTE_BASE + (j * 4), mem->memory[i]);
+			 I810_PTE_BASE + (j * 4),
+			 agp_bridge.mask_memory(mem->memory[i], mem->type));
 	}
 	CACHE_FLUSH();
 
@@ -1143,10 +1133,7 @@
 			agp_free_memory(new);
 			return NULL;
 		}
-		new->memory[0] -		    agp_bridge.mask_memory(
-				   virt_to_phys((void *) new->memory[0]),
-						  type);
+		new->memory[0] = virt_to_phys((void *) new->memory[0]);
 		new->page_count = 1;
 	   	new->num_scratch_pages = 1;
 	   	new->type = AGP_PHYS_MEMORY;
@@ -1180,7 +1167,6 @@
 	intel_i810_private.i810_dev = i810_dev;
 
 	agp_bridge.masks = intel_i810_masks;
-	agp_bridge.num_of_masks = 2;
 	agp_bridge.aperture_sizes = (void *) intel_i810_sizes;
 	agp_bridge.size_type = FIXED_APER_SIZE;
 	agp_bridge.num_aperture_sizes = 2;
@@ -1383,7 +1369,8 @@
 	CACHE_FLUSH();
 
 	for (i = 0, j = pg_start; i < mem->page_count; i++, j++)
-		OUTREG32(intel_i830_private.registers,I810_PTE_BASE + (j * 4),mem->memory[i]);
+		OUTREG32(intel_i830_private.registers,I810_PTE_BASE + (j * 4),
+			 agp_bridge.mask_memory(mem->memory[i], mem->type));
 
 	CACHE_FLUSH();
 
@@ -1444,7 +1431,7 @@
 			return(NULL);
 		}
 
-		nw->memory[0] = agp_bridge.mask_memory(virt_to_phys((void *) nw->memory[0]),type);
+		nw->memory[0] = virt_to_phys((void *) nw->memory[0]);
 		nw->page_count = 1;
 		nw->num_scratch_pages = 1;
 		nw->type = AGP_PHYS_MEMORY;
@@ -1460,7 +1447,6 @@
 	intel_i830_private.i830_dev = i830_dev;
 
 	agp_bridge.masks = intel_i810_masks;
-	agp_bridge.num_of_masks = 3;
 	agp_bridge.aperture_sizes = (void *) intel_i830_sizes;
 	agp_bridge.size_type = FIXED_APER_SIZE;
 	agp_bridge.num_aperture_sizes = 2;
@@ -1506,6 +1492,7 @@
 
 /* 460 supports multiple GART page sizes, so GART pageshift is dynamic */ 
 static u8 intel_i460_pageshift = 12;
+static u32 intel_i460_pagesize;
 
 /* Keep track of which is larger, chipset or kernel page size. */
 static u32 intel_i460_cpk = 1;
@@ -1533,6 +1520,7 @@
 	/* Determine the GART page size */
 	pci_read_config_byte(agp_bridge.dev, INTEL_I460_GXBCTL, &temp);
 	intel_i460_pageshift = (temp & I460_4M_PS) ? 22 : 12;
+	intel_i460_pagesize = 1UL << intel_i460_pageshift;
 
 	values = A_SIZE_8(agp_bridge.aperture_sizes);
 
@@ -1747,7 +1735,7 @@
 {
 	int i, j, k, num_entries;
 	void *temp;
-	unsigned int hold;
+	unsigned long paddr;
 	unsigned int read_back;
 
 	/* 
@@ -1779,10 +1767,11 @@
 
 	for (i = 0, j = pg_start; i < mem->page_count; i++) {
 
-		hold = (unsigned int) (mem->memory[i]);
+		paddr = mem->memory[i];
 
-		for (k = 0; k < I460_CPAGES_PER_KPAGE; k++, j++, hold++)
-			agp_bridge.gatt_table[j] = hold;
+		for (k = 0; k < I460_CPAGES_PER_KPAGE; k++, j++, paddr += intel_i460_pagesize)
+			agp_bridge.gatt_table[j] = (unsigned int)
+			    agp_bridge.mask_memory(paddr, mem->type);
 	}
 
 	/* 
@@ -1896,6 +1885,7 @@
 	int num_entries;	
 	void *temp;
 	unsigned int read_back;
+	unsigned long paddr;
 
 	temp = agp_bridge.current_size;
 	num_entries = A_SIZE_8(temp)->num_entries;
@@ -1944,18 +1934,17 @@
 
 	for(pg = start_pg, i = 0; pg <= end_pg; pg++)
 	{
+		paddr = agp_bridge.unmask_memory(agp_bridge.gatt_table[pg]);
 		for(idx = ((pg = start_pg) ? start_offset : 0);
 		    idx < ((pg = end_pg) ? (end_offset + 1)
 				       : I460_KPAGES_PER_CPAGE);
 		    idx++, i++)
 		{
-			i460_pg_detail[pg][idx] = agp_bridge.gatt_table[pg] + 
-						      ((idx * PAGE_SIZE) >> 12);
+			mem->memory[i] = paddr + (idx * PAGE_SIZE);
+			i460_pg_detail[pg][idx] +			    agp_bridge.mask_memory(mem->memory[i], mem->type);
+			    
 			i460_pg_count[pg]++;
-
-			/* Finally we fill in mem->memory... */
-			mem->memory[i] = ((unsigned long) (0xffffff & 
-						i460_pg_detail[pg][idx])) << 12;
 		}
 	}
 
@@ -1969,7 +1958,7 @@
 	int num_entries;
 	void *temp;
 	unsigned int read_back;
-	unsigned long addr;
+	unsigned long paddr;
 
 	temp = agp_bridge.current_size;
 	num_entries = A_SIZE_8(temp)->num_entries;
@@ -1996,13 +1985,11 @@
 
 		/* Free GART pages if they are unused */
 		if(i460_pg_count[pg] = 0) {
-			addr = (0xffffffUL & (unsigned long) 
-					     (agp_bridge.gatt_table[pg])) << 12;
-
-			agp_bridge.gatt_table[pg] = 0;
+			paddr = agp_bridge.unmask_memory(agp_bridge.gatt_table[pg]);
+			agp_bridge.gatt_table[pg] = agp_bridge.scratch_page;
 			read_back = agp_bridge.gatt_table[pg];
 
-			intel_i460_free_large_page(pg, addr);
+			intel_i460_free_large_page(pg, paddr);
 		}
 	}
 		
@@ -2091,7 +2078,6 @@
 {
 
         agp_bridge.masks = intel_i460_masks;
-        agp_bridge.num_of_masks = 1;
         agp_bridge.aperture_sizes = (void *) intel_i460_sizes;
         agp_bridge.size_type = U8_APER_SIZE;
         agp_bridge.num_aperture_sizes = 3;
@@ -2513,7 +2499,6 @@
 static int __init intel_generic_setup (struct pci_dev *pdev)
 {
 	agp_bridge.masks = intel_generic_masks;
-	agp_bridge.num_of_masks = 1;
 	agp_bridge.aperture_sizes = (void *) intel_generic_sizes;
 	agp_bridge.size_type = U16_APER_SIZE;
 	agp_bridge.num_aperture_sizes = 7;
@@ -2545,11 +2530,9 @@
 }
 
 
-
 static int __init intel_820_setup (struct pci_dev *pdev)
 {
        agp_bridge.masks = intel_generic_masks;
-       agp_bridge.num_of_masks = 1;
        agp_bridge.aperture_sizes = (void *) intel_8xx_sizes;
        agp_bridge.size_type = U8_APER_SIZE;
        agp_bridge.num_aperture_sizes = 7;
@@ -2582,7 +2565,6 @@
 static int __init intel_830mp_setup (struct pci_dev *pdev)
 {
        agp_bridge.masks = intel_generic_masks;
-       agp_bridge.num_of_masks = 1;
        agp_bridge.aperture_sizes = (void *) intel_830mp_sizes;
        agp_bridge.size_type = U8_APER_SIZE;
        agp_bridge.num_aperture_sizes = 4;
@@ -2614,7 +2596,6 @@
 static int __init intel_840_setup (struct pci_dev *pdev)
 {
 	agp_bridge.masks = intel_generic_masks;
-	agp_bridge.num_of_masks = 1;
 	agp_bridge.aperture_sizes = (void *) intel_8xx_sizes;
 	agp_bridge.size_type = U8_APER_SIZE;
 	agp_bridge.num_aperture_sizes = 7;
@@ -2647,7 +2628,6 @@
 static int __init intel_845_setup (struct pci_dev *pdev)
 {
 	agp_bridge.masks = intel_generic_masks;
-	agp_bridge.num_of_masks = 1;
 	agp_bridge.aperture_sizes = (void *) intel_8xx_sizes;
 	agp_bridge.size_type = U8_APER_SIZE;
 	agp_bridge.num_aperture_sizes = 7;
@@ -2681,7 +2661,6 @@
 static int __init intel_850_setup (struct pci_dev *pdev)
 {
 	agp_bridge.masks = intel_generic_masks;
-	agp_bridge.num_of_masks = 1;
 	agp_bridge.aperture_sizes = (void *) intel_8xx_sizes;
 	agp_bridge.size_type = U8_APER_SIZE;
 	agp_bridge.num_aperture_sizes = 7;
@@ -2715,7 +2694,6 @@
 static int __init intel_860_setup (struct pci_dev *pdev)
 {
 	agp_bridge.masks = intel_generic_masks;
-	agp_bridge.num_of_masks = 1;
 	agp_bridge.aperture_sizes = (void *) intel_8xx_sizes;
 	agp_bridge.size_type = U8_APER_SIZE;
 	agp_bridge.num_aperture_sizes = 7;
@@ -2835,7 +2813,6 @@
 static int __init via_generic_setup (struct pci_dev *pdev)
 {
 	agp_bridge.masks = via_generic_masks;
-	agp_bridge.num_of_masks = 1;
 	agp_bridge.aperture_sizes = (void *) via_generic_sizes;
 	agp_bridge.size_type = U8_APER_SIZE;
 	agp_bridge.num_aperture_sizes = 7;
@@ -2950,7 +2927,6 @@
 static int __init sis_generic_setup (struct pci_dev *pdev)
 {
 	agp_bridge.masks = sis_generic_masks;
-	agp_bridge.num_of_masks = 1;
 	agp_bridge.aperture_sizes = (void *) sis_generic_sizes;
 	agp_bridge.size_type = U8_APER_SIZE;
 	agp_bridge.num_aperture_sizes = 7;
@@ -3283,7 +3259,8 @@
 	for (i = 0, j = pg_start; i < mem->page_count; i++, j++) {
 		addr = (j * PAGE_SIZE) + agp_bridge.gart_bus_addr;
 		cur_gatt = GET_GATT(addr);
-		cur_gatt[GET_GATT_OFF(addr)] = mem->memory[i];
+		cur_gatt[GET_GATT_OFF(addr)] +			agp_bridge.mask_memory(mem->memory[i], mem->type);
 	}
 	agp_bridge.tlb_flush(mem);
 	return 0;
@@ -3329,7 +3306,6 @@
 static int __init amd_irongate_setup (struct pci_dev *pdev)
 {
 	agp_bridge.masks = amd_irongate_masks;
-	agp_bridge.num_of_masks = 1;
 	agp_bridge.aperture_sizes = (void *) amd_irongate_sizes;
 	agp_bridge.size_type = LVL2_APER_SIZE;
 	agp_bridge.num_aperture_sizes = 7;
@@ -3578,7 +3554,6 @@
 static int __init ali_generic_setup (struct pci_dev *pdev)
 {
 	agp_bridge.masks = ali_generic_masks;
-	agp_bridge.num_of_masks = 1;
 	agp_bridge.aperture_sizes = (void *) ali_generic_sizes;
 	agp_bridge.size_type = U32_APER_SIZE;
 	agp_bridge.num_aperture_sizes = 7;
@@ -3987,7 +3962,8 @@
 	for (i = 0, j = pg_start; i < mem->page_count; i++, j++) {
 		addr = (j * PAGE_SIZE) + agp_bridge.gart_bus_addr;
 		cur_gatt = SVRWRKS_GET_GATT(addr);
-		cur_gatt[GET_GATT_OFF(addr)] = mem->memory[i];
+		cur_gatt[GET_GATT_OFF(addr)] +			agp_bridge.mask_memory(mem->memory[i], mem->type);
 	}
 	agp_bridge.tlb_flush(mem);
 	return 0;
@@ -4177,7 +4153,6 @@
 	serverworks_private.svrwrks_dev = pdev;
 
 	agp_bridge.masks = serverworks_masks;
-	agp_bridge.num_of_masks = 1;
 	agp_bridge.aperture_sizes = (void *) serverworks_sizes;
 	agp_bridge.size_type = LVL2_APER_SIZE;
 	agp_bridge.num_aperture_sizes = 7;
diff -u -r -X /home/helgaas/exclude linux-2.4.18-ia64-020226/drivers/char/drm/drm_vm.h build/linux-2.4.18-ia64-020226-pagemask/drivers/char/drm/drm_vm.h
--- linux-2.4.18-ia64-020226/drivers/char/drm/drm_vm.h	Wed Mar  6 16:53:47 2002
+++ build/linux-2.4.18-ia64-020226-pagemask/drivers/char/drm/drm_vm.h	Thu Mar  7 09:56:26 2002
@@ -89,7 +89,7 @@
 
 	if (map && map->type = _DRM_AGP) {
 		unsigned long offset = address - vma->vm_start;
-		unsigned long baddr = VM_OFFSET(vma) + offset, paddr;
+		unsigned long baddr = VM_OFFSET(vma) + offset;
 		struct drm_agp_mem *agpmem;
 		struct page *page;
 
@@ -115,19 +115,8 @@
                  * Get the page, inc the use count, and return it
                  */
 		offset = (baddr - agpmem->bound) >> PAGE_SHIFT;
-
-		/*
-		 * This is bad.  What we really want to do here is unmask
-		 * the GART table entry held in the agp_memory structure.
-		 * There isn't a convenient way to call agp_bridge.unmask_
-		 * memory from here, so hard code it for now.
-		 */
-#if defined(__ia64__)
-		paddr = (agpmem->memory->memory[offset] & 0xffffff) << 12;
-#else
-		paddr = agpmem->memory->memory[offset] & dev->agp->page_mask;
-#endif
-		page = virt_to_page(__va(paddr));
+		agpmem->memory->memory[offset] &= dev->agp->page_mask;
+		page = virt_to_page(__va(agpmem->memory->memory[offset]));
 		get_page(page);
 
 		DRM_DEBUG("baddr = 0x%lx page = 0x%p, offset = 0x%lx\n",

