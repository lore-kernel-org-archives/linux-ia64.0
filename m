From: Alex Williamson <alex_williamson@hp.com>
Date: Tue, 29 Oct 2002 17:58:20 +0000
Subject: [Linux-ia64] sba_iommu fixes/update
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------33920388437F0A5FEA6522E8"
Message-Id: <marc-linux-ia64-105590709805285@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------33920388437F0A5FEA6522E8
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


   Attached is a patch that should apply against Bjorn's 2.4 bk
tree.  Changes:

 - Fixes a potential silent data corruption because the pdir
   cache on the chipset set was getting improperly flushed.
   It's very hard to hit given the allocation mechanism for the
   pdir, but it is possible.

 - Demangles scatter-gather pointers.  The driver was taking far
   too much liberty in changing these.  A known MCA path caused
   by this is SCSI retries, which passed back in a pre-mangled
   scatter-gather array.

 - Adds an option for keeping the entire iommu pdir valid.  This
   is really just some debugging code that I added along the way.
   In the event that you've installed a device that aggressively
   tries to prefetch, you may get an MCA if it prefetches beyond
   it's pdir entry.  New boxes shouldn't see much of this because
   PCI will disconnect.  Older systems w/ < rev 3.0 LBAs might
   see issues.  Turning this on, makes all unused pdir entries
   point to a spill page that contains poisoned data. (off by
   default)

 - Removes platform_pci_dma_address().  With the extra scatterlist
   entries, it seems reasonable for DMA engines to store the
   address in dma_address.  pci_dma_length is now just a macro for
   sg->dma_length, this feels cleaner and reduces complexity for
   DMA engines that try to coalesce.  I believe it's even a
   benefit for swiotlb.  The sn pci_dma interface likely needs
   some touchups by those that know the interface in this area.
   (thanks to Grant Grundler for helping out here)

   One issue I've seen, that's simply because the scatterlist is
bigger now, 64k pages and IDE don't get along.  ide-dma tries
to kmalloc a _very_ large scatterlist.  The algorithm factors in
PAGE_SIZE, but it only seems to produce a reasonable value if you
have 4k pages.  It goes ballistic at 64k.  Replacing the kmalloc/
kfree w/ a vmalloc/vfree solves the problem, but seems like it's
only a bandaid.

        Alex

--
Alex Williamson                                  Linux Development Lab
alex_williamson@hp.com                                 Hewlett Packard
970-898-9173                                          Fort Collins, CO
--------------33920388437F0A5FEA6522E8
Content-Type: text/plain; charset=us-ascii;
 name="2.4.20-pre-sba-update.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="2.4.20-pre-sba-update.diff"

--- linux-ia64-2.4/arch/ia64/hp/common/sba_iommu.c	2002-10-23 19:08:55.000000000 -0600
+++ linux/arch/ia64/hp/common/sba_iommu.c	2002-10-23 20:42:01.000000000 -0600
@@ -39,8 +39,25 @@
 
 #define PFX "IOC: "
 
+/*
+** This option allows cards capable of 64bit DMA to bypass the IOMMU.  If
+** not defined, all DMA will be 32bit and go through the TLB.
+*/
 #define ALLOW_IOV_BYPASS
+
+/*
+** If a device prefetches beyond the end of a valid pdir entry, it will cause
+** a hard failure, ie. MCA.  Version 3.0 and later of the zx1 LBA should
+** disconnect on 4k boundaries and prevent such issues.  If the device is
+** particularly agressive, this option will keep the entire pdir valid such
+** that prefetching will hit a valid address.  This could severely impact
+** error containment, and is therefore off by default.  The page that is
+** used for spill-over is poisoned, so that should help debugging somewhat.
+*/
+#undef FULL_VALID_PDIR
+
 #define ENABLE_MARK_CLEAN
+
 /*
 ** The number of debug flags is a clue - this code is fragile.
 */
@@ -52,6 +69,10 @@
 #undef DEBUG_LARGE_SG_ENTRIES
 #undef DEBUG_BYPASS
 
+#if defined(FULL_VALID_PDIR) && defined(ASSERT_PDIR_SANITY)
+#error FULL_VALID_PDIR and ASSERT_PDIR_SANITY are mutually exclusive
+#endif
+
 #define SBA_INLINE	__inline__
 /* #define SBA_INLINE */
 
@@ -198,9 +219,10 @@ static int reserve_sba_gart = 1;
 
 #define sba_sg_address(sg)	(sg->address ? sg->address : \
 				       page_address((sg)->page) + (sg)->offset)
-#define sba_sg_iova(sg) (sg->address)
-#define sba_sg_len(sg) (sg->length)
-#define sba_sg_buffer(sg) (sg->orig_address)
+
+#ifdef FULL_VALID_PDIR
+static void* prefetch_spill_page;
+#endif
 
 #define GET_IOC(dev)	((struct ioc *) PCI_CONTROLLER(dev)->iommu)
 
@@ -340,10 +362,8 @@ sba_dump_sg( struct ioc *ioc, struct sca
 {
 	while (nents-- > 0) {
 		printk(" %d : %08lx/%05x %p\n",
-				nents,
-				(unsigned long) sba_sg_iova(startsg),
-				sba_sg_len(startsg),
-				sba_sg_buffer(startsg));
+				nents, startsg->dma_address,
+				startsg->dma_length, sba_sg_address(startsg));
 		startsg++;
 	}
 }
@@ -354,7 +374,7 @@ sba_check_sg( struct ioc *ioc, struct sc
 	int the_nents = nents;
 
 	while (the_nents-- > 0) {
-		if (sba_sg_buffer(the_sg) == 0x0UL)
+		if (sba_sg_address(the_sg) == 0x0UL)
 			sba_dump_sg(NULL, startsg, nents);
 		the_sg++;
 	}
@@ -675,6 +695,7 @@ sba_mark_invalid(struct ioc *ioc, dma_ad
 
 		iovp |= IOVP_SHIFT;     /* set "size" field for PCOM */
 
+#ifndef FULL_VALID_PDIR
 		/*
 		** clear I/O PDIR entry "valid" bit
 		** Do NOT clear the rest - save it for debugging.
@@ -682,6 +703,14 @@ sba_mark_invalid(struct ioc *ioc, dma_ad
 		** been enabled.
 		*/
 		ioc->pdir_base[off] &= ~(0x80000000000000FFULL);
+#else
+		/*
+  		** If we want to maintain the PDIR as valid, put in
+		** the spill page so devices prefetching won't
+		** cause a hard fail.
+		*/
+		ioc->pdir_base[off] = (0x80000000000000FFULL | (u64)prefetch_spill_page);
+#endif
 	} else {
 		u32 t = get_order(byte_cnt) + PAGE_SHIFT;
 
@@ -691,14 +720,18 @@ sba_mark_invalid(struct ioc *ioc, dma_ad
 		do {
 			/* verify this pdir entry is enabled */
 			ASSERT(ioc->pdir_base[off]  >> 63);
+#ifndef FULL_VALID_PDIR
 			/* clear I/O Pdir entry "valid" bit first */
 			ioc->pdir_base[off] &= ~(0x80000000000000FFULL);
+#else
+			ioc->pdir_base[off] = (0x80000000000000FFULL | (u64)prefetch_spill_page);
+#endif
 			off++;
 			byte_cnt -= IOVP_SIZE;
 		} while (byte_cnt > 0);
 	}
 
-	WRITE_REG(iovp, ioc->ioc_hpa+IOC_PCOM);
+	WRITE_REG(iovp | ioc->ibase, ioc->ioc_hpa+IOC_PCOM);
 }
 
 /**
@@ -993,32 +1026,28 @@ sba_fill_pdir(
 
 	dma_sg--;
 	while (nents-- > 0) {
-		int     cnt = sba_sg_len(startsg);
-		sba_sg_len(startsg) = 0;
+		int     cnt = startsg->dma_length;
+		startsg->dma_length = 0;
 
 #ifdef DEBUG_LARGE_SG_ENTRIES
 		if (dump_run_sg)
 			printk(" %2d : %08lx/%05x %p\n",
-				nents,
-				(unsigned long) sba_sg_iova(startsg), cnt,
-				sba_sg_buffer(startsg)
-		);
+				nents, startsg->dma_address, cnt,
+				sba_sg_address(startsg));
 #else
 		DBG_RUN_SG(" %d : %08lx/%05x %p\n",
-				nents,
-				(unsigned long) sba_sg_iova(startsg), cnt,
-				sba_sg_buffer(startsg)
-		);
+				nents, startsg->dma_address, cnt,
+				sba_sg_address(startsg));
 #endif
 		/*
 		** Look for the start of a new DMA stream
 		*/
-		if ((u64)sba_sg_iova(startsg) & PIDE_FLAG) {
-			u32 pide = (u64)sba_sg_iova(startsg) & ~PIDE_FLAG;
+		if (startsg->dma_address & PIDE_FLAG) {
+			u32 pide = startsg->dma_address & ~PIDE_FLAG;
 			dma_offset = (unsigned long) pide & ~IOVP_MASK;
-			sba_sg_iova(startsg) = 0;
+			startsg->dma_address = 0;
 			dma_sg++;
-			sba_sg_iova(dma_sg) = (char *)(pide | ioc->ibase);
+			dma_sg->dma_address = pide | ioc->ibase;
 			pdirp = &(ioc->pdir_base[pide >> IOVP_SHIFT]);
 			n_mappings++;
 		}
@@ -1027,13 +1056,13 @@ sba_fill_pdir(
 		** Look for a VCONTIG chunk
 		*/
 		if (cnt) {
-			unsigned long vaddr = (unsigned long) sba_sg_buffer(startsg);
+			unsigned long vaddr = (unsigned long) sba_sg_address(startsg);
 			ASSERT(pdirp);
 
 			/* Since multiple Vcontig blocks could make up
 			** one DMA stream, *add* cnt to dma_len.
 			*/
-			sba_sg_len(dma_sg) += cnt;
+			dma_sg->dma_length += cnt;
 			cnt += dma_offset;
 			dma_offset=0;	/* only want offset on first chunk */
 			cnt = ROUNDUP(cnt, IOVP_SIZE);
@@ -1093,20 +1122,18 @@ sba_coalesce_chunks( struct ioc *ioc,
 	int n_mappings = 0;
 
 	while (nents > 0) {
-		unsigned long vaddr = (unsigned long) sba_sg_address(startsg);
+		unsigned long vaddr = (unsigned long) sba_sg_address(startsg); 
 
 		/*
 		** Prepare for first/next DMA stream
 		*/
 		dma_sg = vcontig_sg = startsg;
-		dma_len = vcontig_len = vcontig_end = sba_sg_len(startsg);
+		dma_len = vcontig_len = vcontig_end = startsg->length;
 		vcontig_end +=  vaddr;
 		dma_offset = vaddr & ~IOVP_MASK;
 
 		/* PARANOID: clear entries */
-		sba_sg_buffer(startsg) = vaddr;
-		sba_sg_iova(startsg) = 0;
-		sba_sg_len(startsg) = 0;
+		startsg->dma_address = startsg->dma_length = 0;
 
 		/*
 		** This loop terminates one iteration "early" since
@@ -1117,6 +1144,9 @@ sba_coalesce_chunks( struct ioc *ioc,
 
 			startsg++;
 
+			/* PARANOID */
+			startsg->dma_address = startsg->dma_length = 0;
+
 			/* catch brokenness in SCSI layer */
 			ASSERT(startsg->length <= DMA_CHUNK_SIZE);
 
@@ -1136,12 +1166,9 @@ sba_coalesce_chunks( struct ioc *ioc,
 			vaddr = (unsigned long) sba_sg_address(startsg);
 			if  (vcontig_end == vaddr)
 			{
-				vcontig_len += sba_sg_len(startsg);
-				vcontig_end += sba_sg_len(startsg);
-				dma_len     += sba_sg_len(startsg);
-				sba_sg_buffer(startsg) = (char *)vaddr;
-				sba_sg_iova(startsg) = 0;
-				sba_sg_len(startsg) = 0;
+				vcontig_len += startsg->length;
+				vcontig_end += startsg->length;
+				dma_len     += startsg->length;
 				continue;
 			}
 
@@ -1160,10 +1187,10 @@ sba_coalesce_chunks( struct ioc *ioc,
 			** must start on page boundaries and dove tail
 			** with it's predecessor.
 			*/
-			sba_sg_len(vcontig_sg) = vcontig_len;
+			vcontig_sg->dma_length = vcontig_len;
 
 			vcontig_sg = startsg;
-			vcontig_len = sba_sg_len(startsg);
+			vcontig_len = startsg->length;
 
 			/*
 			** 3) do the entries end/start on page boundaries?
@@ -1173,8 +1200,6 @@ sba_coalesce_chunks( struct ioc *ioc,
 			{
 				vcontig_end = vcontig_len + vaddr;
 				dma_len += vcontig_len;
-				sba_sg_buffer(startsg) = (char *)vaddr;
-				sba_sg_iova(startsg) = 0;
 				continue;
 			} else {
 				break;
@@ -1186,10 +1211,10 @@ sba_coalesce_chunks( struct ioc *ioc,
 		** Terminate last VCONTIG block.
 		** Allocate space for DMA stream.
 		*/
-		sba_sg_len(vcontig_sg) = vcontig_len;
+		vcontig_sg->dma_length = vcontig_len;
 		dma_len = (dma_len + dma_offset + ~IOVP_MASK) & IOVP_MASK;
 		ASSERT(dma_len <= DMA_CHUNK_SIZE);
-		sba_sg_iova(dma_sg) = (char *) (PIDE_FLAG 
+		dma_sg->dma_address = (dma_addr_t) (PIDE_FLAG 
 			| (sba_alloc_range(ioc, dma_len) << IOVP_SHIFT)
 			| dma_offset);
 		n_mappings++;
@@ -1225,8 +1250,8 @@ int sba_map_sg(struct pci_dev *dev, stru
 #ifdef ALLOW_IOV_BYPASS
 	if (dev->dma_mask >= ioc->dma_mask) {
 		for (sg = sglist ; filled < nents ; filled++, sg++){
-			sba_sg_buffer(sg) = sba_sg_address(sg);
-			sba_sg_iova(sg) = (char *)virt_to_phys(sba_sg_buffer(sg));
+			sg->dma_length = sg->length;
+			sg->dma_address = virt_to_phys(sba_sg_address(sg));
 		}
 #ifdef CONFIG_PROC_FS
 		spin_lock_irqsave(&ioc->res_lock, flags);
@@ -1238,10 +1263,10 @@ int sba_map_sg(struct pci_dev *dev, stru
 #endif
 	/* Fast path single entry scatterlists. */
 	if (nents == 1) {
-		sba_sg_buffer(sglist) = sba_sg_address(sglist);
-		sba_sg_iova(sglist) = (char *)sba_map_single(dev,
-						sba_sg_buffer(sglist),
-						sba_sg_len(sglist), direction);
+		sglist->dma_length = sglist->length;
+		sglist->dma_address = sba_map_single(dev,
+		                                     sba_sg_address(sglist),
+		                                     sglist->length, direction);
 #ifdef CONFIG_PROC_FS
 		/*
 		** Should probably do some stats counting, but trying to
@@ -1320,7 +1345,7 @@ void sba_unmap_sg(struct pci_dev *dev, s
 #endif
 
 	DBG_RUN_SG("%s() START %d entries,  %p,%x\n",
-		__FUNCTION__, nents, sba_sg_buffer(sglist), sglist->length);
+		__FUNCTION__, nents, sba_sg_address(sglist), sglist->length);
 
 	ioc = GET_IOC(dev);
 	ASSERT(ioc);
@@ -1335,10 +1360,10 @@ void sba_unmap_sg(struct pci_dev *dev, s
 	spin_unlock_irqrestore(&ioc->res_lock, flags);
 #endif
 
-	while (sba_sg_len(sglist) && nents--) {
+	while (nents && sglist->dma_length) {
 
-		sba_unmap_single(dev, (dma_addr_t)sba_sg_iova(sglist),
-		                 sba_sg_len(sglist), direction);
+		sba_unmap_single(dev, sglist->dma_address,
+		                 sglist->dma_length, direction);
 #ifdef CONFIG_PROC_FS
 		/*
 		** This leaves inconsistent data in the stats, but we can't
@@ -1346,9 +1371,10 @@ void sba_unmap_sg(struct pci_dev *dev, s
 		** were coalesced to a single entry.  The stats are fun,
 		** but speed is more important.
 		*/
-		ioc->usg_pages += (((u64)sba_sg_iova(sglist) & ~IOVP_MASK) + sba_sg_len(sglist) + IOVP_SIZE - 1) >> PAGE_SHIFT;
+		ioc->usg_pages += ((sglist->dma_address & ~IOVP_MASK) + sglist->dma_length + IOVP_SIZE - 1) >> PAGE_SHIFT;
 #endif
-		++sglist;
+		sglist++;
+		nents--;
 	}
 
 	DBG_RUN_SG("%s() DONE (nents %d)\n", __FUNCTION__,  nents);
@@ -1361,12 +1387,6 @@ void sba_unmap_sg(struct pci_dev *dev, s
 
 }
 
-unsigned long
-sba_dma_address (struct scatterlist *sg)
-{
-	return ((unsigned long)sba_sg_iova(sg));
-}
-
 int
 sba_dma_supported (struct pci_dev *dev, u64 mask)
 {
@@ -1386,6 +1406,9 @@ ioc_iova_init(struct ioc *ioc)
 	int iov_order, tcnfg;
 	int agp_found = 0;
 	struct pci_dev *device;
+#ifdef FULL_VALID_PDIR
+	unsigned long index;
+#endif
 
 	/*
 	** Firmware programs the base and size of a "safe IOVA space"
@@ -1483,7 +1506,7 @@ ioc_iova_init(struct ioc *ioc)
 	** Clear I/O TLB of any possible entries.
 	** (Yes. This is a bit paranoid...but so what)
 	*/
-	WRITE_REG(0 | 31, ioc->ioc_hpa + IOC_PCOM);
+	WRITE_REG(ioc->ibase | (iov_order+PAGE_SHIFT), ioc->ioc_hpa + IOC_PCOM);
 
 	/*
 	** If an AGP device is present, only use half of the IOV space
@@ -1501,6 +1524,34 @@ ioc_iova_init(struct ioc *ioc)
 		ioc->pdir_size /= 2;
 		((u64 *)ioc->pdir_base)[PDIR_INDEX(ioc->iov_size/2)] = ZX1_SBA_IOMMU_COOKIE;
 	}
+#ifdef FULL_VALID_PDIR
+	/*
+  	** Check to see if the spill page has been allocated, we don't need more than
+	** one across multiple SBAs.
+	*/
+	if (!prefetch_spill_page) {
+		char *spill_poison = "SBAIOMMU POISON";
+		int poison_size = 16;
+		void *poison_addr;
+									
+		prefetch_spill_page = (void *)__get_free_pages(GFP_KERNEL, get_order(IOVP_SIZE));
+		if (!prefetch_spill_page)
+			panic(PFX "Couldn't allocate PDIR spill page\n");
+
+		poison_addr = prefetch_spill_page;
+		for (; (u64)poison_addr < (u64)prefetch_spill_page + IOVP_SIZE ; poison_addr += poison_size)
+			(void)memcpy(poison_addr,spill_poison,poison_size);
+
+		prefetch_spill_page = (void *)virt_to_phys(prefetch_spill_page);
+
+		DBG_INIT("%s() prefetch spill addr: %p\n", __FUNCTION__, prefetch_spill_page);
+	}
+	/*
+  	** Set all the PDIR entries valid w/ the spill page as the target
+	*/
+	for (index = 0 ; index < (ioc->pdir_size / sizeof(u64)) ; index++)
+		((u64 *)ioc->pdir_base)[index] = (0x80000000000000FFULL | (u64)prefetch_spill_page);
+#endif
 }
 
 static void __init
@@ -1527,6 +1578,11 @@ ioc_resource_init(struct ioc *ioc)
 	ioc->res_map[0] = 0x1;
 	ioc->pdir_base[0] = 0x8000000000000000ULL | ZX1_SBA_IOMMU_COOKIE;
 #endif
+#ifdef FULL_VALID_PDIR
+	/* Mark the last resource used so we don't prefetch beyond IOVA space */
+	ioc->res_map[ioc->res_size - 1] |= 0x80UL; /* res_map is chars */
+	ioc->pdir_base[(ioc->pdir_size / sizeof(u64)) - 1] = (0x80000000000000FFULL | (u64)prefetch_spill_page);
+#endif
 
 	DBG_INIT("%s() res_map %x %p\n", __FUNCTION__,
 		 ioc->res_size, (void *) ioc->res_map);
@@ -1864,7 +1920,6 @@ EXPORT_SYMBOL(sba_map_single);
 EXPORT_SYMBOL(sba_unmap_single);
 EXPORT_SYMBOL(sba_map_sg);
 EXPORT_SYMBOL(sba_unmap_sg);
-EXPORT_SYMBOL(sba_dma_address);
 EXPORT_SYMBOL(sba_dma_supported);
 EXPORT_SYMBOL(sba_alloc_consistent);
 EXPORT_SYMBOL(sba_free_consistent);
--- linux-ia64-2.4/arch/ia64/lib/swiotlb.c	2002-10-23 19:08:55.000000000 -0600
+++ linux/arch/ia64/lib/swiotlb.c	2002-10-23 21:12:27.000000000 -0600
@@ -417,23 +417,23 @@ swiotlb_sync_single (struct pci_dev *hwd
 int
 swiotlb_map_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nelems, int direction)
 {
-	void *addr;
 	int i;
 
 	if (direction == PCI_DMA_NONE)
 		BUG();
 
 	for (i = 0; i < nelems; i++, sg++) {
-		sg->orig_address = SG_ENT_VIRT_ADDRESS(sg);
-		if ((SG_ENT_PHYS_ADDRESS(sg) & ~hwdev->dma_mask) != 0) {
-			addr = map_single(hwdev, sg->orig_address, sg->length, direction);
-			if (sg->address)
-				sg->address = addr;
-			else {
-				sg->page = virt_to_page(addr);
-				sg->offset = (u64) addr & ~PAGE_MASK;
-			}
-		}
+		void * virt_address = SG_ENT_VIRT_ADDRESS(sg);
+		unsigned long phys_address = virt_to_phys(virt_address);
+
+		sg->dma_length = sg->length;
+		if (phys_address & ~hwdev->dma_mask)
+			sg->dma_address = virt_to_phys(map_single(hwdev,
+			                                          virt_address,
+			                                          sg->length,
+			                                          direction));
+		else
+			sg->dma_address = phys_address;
 	}
 	return nelems;
 }
@@ -451,14 +451,9 @@ swiotlb_unmap_sg (struct pci_dev *hwdev,
 		BUG();
 
 	for (i = 0; i < nelems; i++, sg++)
-		if (sg->orig_address != SG_ENT_VIRT_ADDRESS(sg)) {
-			unmap_single(hwdev, SG_ENT_VIRT_ADDRESS(sg), sg->length, direction);
-			if (sg->address)
-				sg->address = sg->orig_address;
-			else {
-				sg->page = virt_to_page(sg->orig_address);
-				sg->offset = (u64) sg->orig_address & ~PAGE_MASK;
-			}
+		if (sg->dma_address != virt_to_phys(SG_ENT_VIRT_ADDRESS(sg))) {
+			unmap_single(hwdev, phys_to_virt(sg->dma_address),
+			             sg->dma_length, direction);
 		} else if (direction == PCI_DMA_FROMDEVICE)
 			mark_clean(SG_ENT_VIRT_ADDRESS(sg), sg->length);
 }
@@ -479,14 +474,9 @@ swiotlb_sync_sg (struct pci_dev *hwdev, 
 		BUG();
 
 	for (i = 0; i < nelems; i++, sg++)
-		if (sg->orig_address != SG_ENT_VIRT_ADDRESS(sg))
-			sync_single(hwdev, SG_ENT_VIRT_ADDRESS(sg), sg->length, direction);
-}
-
-unsigned long
-swiotlb_dma_address (struct scatterlist *sg)
-{
-	return SG_ENT_PHYS_ADDRESS(sg);
+		if (sg->dma_address != virt_to_phys(SG_ENT_VIRT_ADDRESS(sg)))
+			sync_single(hwdev, phys_to_virt(sg->dma_address),
+			            sg->dma_length, direction);
 }
 
 /*
@@ -507,7 +497,6 @@ EXPORT_SYMBOL(swiotlb_map_sg);
 EXPORT_SYMBOL(swiotlb_unmap_sg);
 EXPORT_SYMBOL(swiotlb_sync_single);
 EXPORT_SYMBOL(swiotlb_sync_sg);
-EXPORT_SYMBOL(swiotlb_dma_address);
 EXPORT_SYMBOL(swiotlb_alloc_consistent);
 EXPORT_SYMBOL(swiotlb_free_consistent);
 EXPORT_SYMBOL(swiotlb_pci_dma_supported);
--- linux-ia64-2.4/include/asm-ia64/machvec.h	2002-10-23 19:09:08.000000000 -0600
+++ linux/include/asm-ia64/machvec.h	2002-10-15 00:46:21.000000000 -0600
@@ -46,7 +46,6 @@ typedef int ia64_mv_pci_map_sg (struct p
 typedef void ia64_mv_pci_unmap_sg (struct pci_dev *, struct scatterlist *, int, int);
 typedef void ia64_mv_pci_dma_sync_single (struct pci_dev *, dma_addr_t, size_t, int);
 typedef void ia64_mv_pci_dma_sync_sg (struct pci_dev *, struct scatterlist *, int, int);
-typedef unsigned long ia64_mv_pci_dma_address (struct scatterlist *);
 typedef int ia64_mv_pci_dma_supported (struct pci_dev *, u64);
 
 /*
@@ -104,7 +103,6 @@ extern void machvec_noop (void);
 #  define platform_pci_unmap_sg		ia64_mv.unmap_sg
 #  define platform_pci_dma_sync_single	ia64_mv.sync_single
 #  define platform_pci_dma_sync_sg	ia64_mv.sync_sg
-#  define platform_pci_dma_address	ia64_mv.dma_address
 #  define platform_pci_dma_supported	ia64_mv.dma_supported
 #  define platform_irq_desc		ia64_mv.irq_desc
 #  define platform_irq_to_vector	ia64_mv.irq_to_vector
@@ -140,7 +138,6 @@ struct ia64_machine_vector {
 	ia64_mv_pci_unmap_sg *unmap_sg;
 	ia64_mv_pci_dma_sync_single *sync_single;
 	ia64_mv_pci_dma_sync_sg *sync_sg;
-	ia64_mv_pci_dma_address *dma_address;
 	ia64_mv_pci_dma_supported *dma_supported;
 	ia64_mv_irq_desc *irq_desc;
 	ia64_mv_irq_to_vector *irq_to_vector;
@@ -177,7 +174,6 @@ struct ia64_machine_vector {
 	platform_pci_unmap_sg,			\
 	platform_pci_dma_sync_single,		\
 	platform_pci_dma_sync_sg,		\
-	platform_pci_dma_address,		\
 	platform_pci_dma_supported,		\
 	platform_irq_desc,			\
 	platform_irq_to_vector,			\
@@ -209,7 +205,6 @@ extern ia64_mv_pci_map_sg swiotlb_map_sg
 extern ia64_mv_pci_unmap_sg swiotlb_unmap_sg;
 extern ia64_mv_pci_dma_sync_single swiotlb_sync_single;
 extern ia64_mv_pci_dma_sync_sg swiotlb_sync_sg;
-extern ia64_mv_pci_dma_address swiotlb_dma_address;
 extern ia64_mv_pci_dma_supported swiotlb_pci_dma_supported;
 
 /*
@@ -276,9 +271,6 @@ extern ia64_mv_pci_dma_supported swiotlb
 #ifndef platform_pci_dma_sync_sg
 # define platform_pci_dma_sync_sg	swiotlb_sync_sg
 #endif
-#ifndef platform_pci_dma_address
-# define  platform_pci_dma_address	swiotlb_dma_address
-#endif
 #ifndef platform_pci_dma_supported
 # define  platform_pci_dma_supported	swiotlb_pci_dma_supported
 #endif
--- linux-ia64-2.4/include/asm-ia64/machvec_hpzx1.h	2002-10-23 19:09:08.000000000 -0600
+++ linux/include/asm-ia64/machvec_hpzx1.h	2002-10-15 00:46:21.000000000 -0600
@@ -11,7 +11,6 @@ extern ia64_mv_pci_map_single sba_map_si
 extern ia64_mv_pci_unmap_single sba_unmap_single;
 extern ia64_mv_pci_map_sg sba_map_sg;
 extern ia64_mv_pci_unmap_sg sba_unmap_sg;
-extern ia64_mv_pci_dma_address sba_dma_address;
 extern ia64_mv_pci_dma_supported sba_dma_supported;
 
 /*
@@ -35,7 +34,6 @@ extern ia64_mv_pci_dma_supported sba_dma
 #define platform_pci_unmap_sg		sba_unmap_sg
 #define platform_pci_dma_sync_single	((ia64_mv_pci_dma_sync_single *) machvec_noop)
 #define platform_pci_dma_sync_sg	((ia64_mv_pci_dma_sync_sg *) machvec_noop)
-#define platform_pci_dma_address	sba_dma_address
 #define platform_pci_dma_supported	sba_dma_supported
 
 #endif /* _ASM_IA64_MACHVEC_HPZX1_h */
--- linux-ia64-2.4/include/asm-ia64/pci.h	2002-10-23 19:09:08.000000000 -0600
+++ linux/include/asm-ia64/pci.h	2002-10-15 00:46:21.000000000 -0600
@@ -56,7 +49,6 @@ pcibios_penalize_isa_irq (int irq)
 #define pci_unmap_sg			platform_pci_unmap_sg
 #define pci_dma_sync_single		platform_pci_dma_sync_single
 #define pci_dma_sync_sg			platform_pci_dma_sync_sg
-#define sg_dma_address			platform_pci_dma_address
 #define pci_dma_supported		platform_pci_dma_supported
 
 /* pci_unmap_{single,page} is not a nop, thus... */
@@ -83,7 +75,8 @@ pcibios_penalize_isa_irq (int irq)
 /* Return the index of the PCI controller for device PDEV. */
 #define pci_controller_num(PDEV)	(0)
 
-#define sg_dma_len(sg)		((sg)->length)
+#define sg_dma_address(sg)	((sg)->dma_address)
+#define sg_dma_len(sg)		((sg)->dma_length)
 
 #define HAVE_PCI_MMAP
 extern int pci_mmap_page_range (struct pci_dev *dev, struct vm_area_struct *vma,
--- linux-ia64-2.4/include/asm-ia64/scatterlist.h	2002-10-23 19:09:08.000000000 -0600
+++ linux/include/asm-ia64/scatterlist.h	2002-10-15 00:13:27.000000000 -0600
@@ -9,12 +9,13 @@
 struct scatterlist {
 	/* This will disappear in 2.5.x: */
 	char *address;		/* location data is to be transferred to, NULL for highmem page */
-	char *orig_address;	/* for use by swiotlb */
 
 	/* These two are only valid if ADDRESS member of this struct is NULL.  */
 	struct page *page;
 	unsigned int offset;
 	unsigned int length;	/* buffer length */
+	dma_addr_t dma_address;
+	unsigned int dma_length;
 };
 
 #define ISA_DMA_THRESHOLD	(~0UL)
--- linux-ia64-2.4/arch/ia64/sn/io/pci_dma.c	2002-10-23 19:08:55.000000000 -0600
+++ linux/arch/ia64/sn/io/pci_dma.c	2002-10-23 21:39:07.000000000 -0600
@@ -309,7 +309,6 @@ sn_pci_map_sg(struct pci_dev *hwdev, str
 
 	int i;
 	devfs_handle_t vhdl;
-	dma_addr_t dma_addr;
 	unsigned long phys_addr;
 	struct sn_device_sysdata *device_sysdata;
 	pciio_dmamap_t dma_map;
@@ -333,34 +332,28 @@ sn_pci_map_sg(struct pci_dev *hwdev, str
                    attempt to map scatterlists that they have
                    previously mapped.  we print a warning and
                    continue, but the driver should be fixed */
-		switch (((u64)sg->address) >> 60) {
-		case 0xa:
-		case 0xb:
 #ifdef DEBUG
+		if (sg->dma_address) {
 /* This needs to be cleaned up at some point. */
 			NAG("A PCI driver (for device at%8s) has attempted to "
 			    "map a scatterlist that was previously mapped at "
 			    "%p - this is currently being worked around.\n",
-			    hwdev->slot_name, (void *)sg->address);
+			    hwdev->slot_name, (void *)sg->dma_address);
+			phys_addr = (u64)sg->dma_address & TO_PHYS_MASK;
+		} else
 #endif
-			phys_addr = (u64)sg->address & TO_PHYS_MASK;
-			break;
-		default: /* not previously mapped, get the phys. addr */
-			phys_addr = __pa(sg->address);
-			break;
-		}
-		sg->page = NULL;
-		dma_addr = 0;
+			phys_addr = __pa(sg->address ? sg->address :
+					page_address(sg->page) + offset);
 
 		/*
 		 * Handle the most common case: 64 bit cards.  This
 		 * call should always succeed.
 		 */
 		if (IS_PCIA64(hwdev)) {
-			dma_addr = pciio_dmatrans_addr(vhdl, NULL, phys_addr,
+			sg->dma_address = pciio_dmatrans_addr(vhdl, NULL, phys_addr,
 						       sg->length,
 						       DMA_DATA_FLAGS | PCIIO_DMA_A64 );
-			sg->address = (char *)dma_addr;
+			sg->dma_length = sg->length;
 			continue;
 		}
 
@@ -368,16 +361,14 @@ sn_pci_map_sg(struct pci_dev *hwdev, str
 		 * Handle 32-63 bit cards via direct mapping
 		 */
 		if (IS_PCI32G(hwdev)) {
-			dma_addr = pciio_dmatrans_addr(vhdl, NULL, phys_addr,
-						       sg->length,
-						       DMA_DATA_FLAGS);
-			/*
-			 * See if we got a direct map entry
-			 */
-			if (dma_addr) {
-				sg->address = (char *)dma_addr;
+			sg->dma_address = pciio_dmatrans_addr(vhdl, NULL,
+								phys_addr,
+								sg->length,
+								DMA_DATA_FLAGS);
+			sg->dma_length = sg->length;
+
+			if (sg->dma_address)
 				continue;
-			}
 
 		}
 
@@ -393,10 +384,10 @@ sn_pci_map_sg(struct pci_dev *hwdev, str
 			       "anymore 32 bit page map entries.\n");
 			BUG();
 		}
-		dma_addr = pciio_dmamap_addr(dma_map, phys_addr, sg->length);
-		sg->address = (char *)dma_addr;
+		sg->dma_address = pciio_dmamap_addr(dma_map, phys_addr, sg->length);
+		sg->dma_length = sg->length;
+#warning BADBADBAD scsi retries will die since sglist is unmapped and reused.
 		sg->page = (char *)dma_map;
-		
 	}
 
 	return nents;
@@ -418,19 +409,20 @@ void
 sn_pci_unmap_sg(struct pci_dev *hwdev, struct scatterlist *sg, int nents, int direction)
 {
 	int i;
-	struct sn_dma_maps_s *sn_dma_map;
 
 	/* can't go anywhere w/o a direction in life */
 	if (direction == PCI_DMA_NONE)
 		BUG();
 
 	for (i = 0; i < nents; i++, sg++)
+#warning need to derive sn_dma_map from sg->dma_address instead
 		if (sg->page) {
+			struct sn_dma_maps_s *sn_dma_map;
 			/*
 			 * We maintain the DMA Map pointer in sg->page if 
 			 * it is ever allocated.
 			 */
-			sg->address = 0;
+			sg->dma_address = 0;
 			sn_dma_map = (struct sn_dma_maps_s *)sg->page;
 			pciio_dmamap_done((pciio_dmamap_t)sn_dma_map);
 			pciio_dmamap_free((pciio_dmamap_t)sn_dma_map);
@@ -607,19 +599,6 @@ sn_pci_dma_sync_sg(struct pci_dev *hwdev
 }
 
 /**
- * sn_dma_address - get the DMA address for the first entry of a scatterlist
- * @sg: sg to look at
- *
- * Gets the DMA address for the scatterlist @sg.  Also known as
- * platform_dma_address() by the IA64 machvec code.
- */
-unsigned long
-sn_dma_address(struct scatterlist *sg)
-{
-	return ((unsigned long)sg->address);
-}
-
-/**
  * sn_dma_supported - test a DMA mask
  * @hwdev: device to test
  * @mask: DMA mask to test
@@ -645,6 +624,5 @@ EXPORT_SYMBOL(sn_pci_map_sg);
 EXPORT_SYMBOL(sn_pci_unmap_sg);
 EXPORT_SYMBOL(sn_pci_alloc_consistent);
 EXPORT_SYMBOL(sn_pci_free_consistent);
-EXPORT_SYMBOL(sn_dma_address);
 EXPORT_SYMBOL(sn_pci_dma_supported);
 
--- linux-ia64-2.4/include/asm-ia64/machvec_sn1.h	2002-10-23 19:09:08.000000000 -0600
+++ linux/include/asm-ia64/machvec_sn1.h	2002-10-15 00:46:21.000000000 -0600
@@ -58,7 +58,6 @@ extern ia64_mv_pci_map_sg		sn_pci_map_sg
 extern ia64_mv_pci_unmap_sg		sn_pci_unmap_sg;
 extern ia64_mv_pci_dma_sync_single	sn_pci_dma_sync_single;
 extern ia64_mv_pci_dma_sync_sg		sn_pci_dma_sync_sg;
-extern ia64_mv_pci_dma_address		sn_dma_address;
 extern ia64_mv_pci_dma_supported	sn_pci_dma_supported;
 
 /*
@@ -95,7 +94,6 @@ extern ia64_mv_pci_dma_supported	sn_pci_
 #define platform_pci_unmap_sg		sn_pci_unmap_sg
 #define platform_pci_dma_sync_single	sn_pci_dma_sync_single
 #define platform_pci_dma_sync_sg	sn_pci_dma_sync_sg
-#define platform_pci_dma_address	sn_dma_address
 #define platform_pci_dma_supported	sn_pci_dma_supported
 
 #endif /* _ASM_IA64_MACHVEC_SN1_h */
--- linux-ia64-2.4/include/asm-ia64/machvec_sn2.h	2002-10-23 19:09:08.000000000 -0600
+++ linux/include/asm-ia64/machvec_sn2.h	2002-10-15 00:46:21.000000000 -0600
@@ -58,7 +58,6 @@ extern ia64_mv_pci_map_sg		sn_pci_map_sg
 extern ia64_mv_pci_unmap_sg		sn_pci_unmap_sg;
 extern ia64_mv_pci_dma_sync_single	sn_pci_dma_sync_single;
 extern ia64_mv_pci_dma_sync_sg		sn_pci_dma_sync_sg;
-extern ia64_mv_pci_dma_address		sn_dma_address;
 extern ia64_mv_pci_dma_supported	sn_pci_dma_supported;
 
 /*
@@ -95,7 +94,6 @@ extern ia64_mv_pci_dma_supported	sn_pci_
 #define platform_pci_unmap_sg		sn_pci_unmap_sg
 #define platform_pci_dma_sync_single	sn_pci_dma_sync_single
 #define platform_pci_dma_sync_sg	sn_pci_dma_sync_sg
-#define platform_pci_dma_address	sn_dma_address
 #define platform_pci_dma_supported	sn_pci_dma_supported
 
 #endif /* _ASM_IA64_MACHVEC_SN2_H */


--------------33920388437F0A5FEA6522E8--


