From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Fri, 07 Jun 2002 22:07:04 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.5.18)
Message-Id: <marc-linux-ia64-105590701905655@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 	-- With CONFIG_GENERIC, sba_iommu.c still doesn't compile
> 	because of the removal of the address field from the scatterlist.

Here's a patch to make sba_iommu work again.

I added dma_address and dma_length to struct scatterlist and
removed orig_address.  This brings IA64 in line with most other
architectures, but required a few changes to swiotlb.

Grant Grundler did the sba_iommu.c updates.

Note that this isn't *quite* enough to make the generic kernel
work on ZX1 boxes, because the ACPI in 2.5.18 barfs on a
ZX1 _CRS method.

David, I've tested both the swiotlb (on i2000 and ZX1) and
sba_iommu (on ZX1, with a kludge for the ACPI problem),
and they seem to work fine.
--
Bjorn Helgaas - bjorn_helgaas at hp.com
Linux Systems Operation R&D
Hewlett-Packard Company


diff -u -r -X /home/helgaas/exclude linux-2.5.18-ia64-020530.orig/arch/ia64/hp/common/sba_iommu.c linux-sg/arch/ia64/hp/common/sba_iommu.c
--- linux-2.5.18-ia64-020530.orig/arch/ia64/hp/common/sba_iommu.c	Tue Jun  4 11:24:07 2002
+++ linux-sg/arch/ia64/hp/common/sba_iommu.c	Fri Jun  7 11:05:07 2002
@@ -2,6 +2,7 @@
 **  IA64 System Bus Adapter (SBA) I/O MMU manager
 **
 **	(c) Copyright 2002 Alex Williamson
+**	(c) Copyright 2002 Grant Grundler
 **	(c) Copyright 2002 Hewlett-Packard Company
 **
 **	Portions (c) 2000 Grant Grundler (from parisc I/O MMU code)
@@ -110,7 +111,7 @@
 */
 #define DELAYED_RESOURCE_CNT	16
 
-#define DEFAULT_DMA_HINT_REG	0
+#define DEFAULT_DMA_HINT_REG(d)	0
 
 #define ZX1_FUNC_ID_VALUE    ((PCI_DEVICE_ID_HP_ZX1_SBA << 16) | PCI_VENDOR_ID_HP)
 #define ZX1_MC_ID    ((PCI_DEVICE_ID_HP_ZX1_MC << 16) | PCI_VENDOR_ID_HP)
@@ -216,9 +217,10 @@
 static int reserve_sba_gart = 1;
 static struct pci_dev sac_only_dev;
 
-#define sba_sg_iova(sg) (sg->address)
+#define sba_sg_address(sg) (page_address((sg)->page) + (sg)->offset)
 #define sba_sg_len(sg) (sg->length)
-#define sba_sg_buffer(sg) (sg->orig_address)
+#define sba_sg_iova(sg) (sg->dma_address)
+#define sba_sg_iova_len(sg) (sg->dma_length)
 
 /* REVISIT - fix me for multiple SBAs/IOCs */
 #define GET_IOC(dev) (sba_list->ioc)
@@ -232,7 +234,7 @@
 ** rather than the HW. I/O MMU allocation alogorithms can be
 ** faster with smaller size is (to some degree).
 */
-#define DMA_CHUNK_SIZE  (BITS_PER_LONG*PAGE_SIZE)
+#define DMA_CHUNK_SIZE  (BITS_PER_LONG*IOVP_SIZE)
 
 /* Looks nice and keeps the compiler happy */
 #define SBA_DEV(d) ((struct sba_device *) (d))
@@ -255,7 +257,7 @@
  * sba_dump_tlb - debugging only - print IOMMU operating parameters
  * @hpa: base address of the IOMMU
  *
- * Print the size/location of the IO MMU PDIR.
+ * Print the size/location of the IO MMU Pdir.
  */
 static void
 sba_dump_tlb(char *hpa)
@@ -273,12 +275,12 @@
 #ifdef ASSERT_PDIR_SANITY
 
 /**
- * sba_dump_pdir_entry - debugging only - print one IOMMU PDIR entry
+ * sba_dump_pdir_entry - debugging only - print one IOMMU Pdir entry
  * @ioc: IO MMU structure which owns the pdir we are interested in.
  * @msg: text to print ont the output line.
  * @pide: pdir index.
  *
- * Print one entry of the IO MMU PDIR in human readable form.
+ * Print one entry of the IO MMU Pdir in human readable form.
  */
 static void
 sba_dump_pdir_entry(struct ioc *ioc, char *msg, uint pide)
@@ -360,25 +362,25 @@
  * print the SG list so we can verify it's correct by hand.
  */
 static void
-sba_dump_sg( struct ioc *ioc, struct scatterlist *startsg, int nents)
+sba_dump_sg(struct ioc *ioc, struct scatterlist *startsg, int nents)
 {
 	while (nents-- > 0) {
-		printk(" %d : %08lx/%05x %p\n",
+		printk(" %d : DMA %08lx/%05x CPU %p\n",
 				nents,
 				(unsigned long) sba_sg_iova(startsg),
-				sba_sg_len(startsg),
-				sba_sg_buffer(startsg));
+				sba_sg_iova_len(startsg),
+				sba_sg_address(startsg));
 		startsg++;
 	}
 }
 static void
-sba_check_sg( struct ioc *ioc, struct scatterlist *startsg, int nents)
+sba_check_sg(struct ioc *ioc, struct scatterlist *startsg, int nents)
 {
 	struct scatterlist *the_sg = startsg;
 	int the_nents = nents;
 
 	while (the_nents-- > 0) {
-		if (sba_sg_buffer(the_sg) = 0x0UL)
+		if (sba_sg_address(the_sg) = 0x0UL)
 			sba_dump_sg(NULL, startsg, nents);
 		the_sg++;
 	}
@@ -404,7 +406,6 @@
 #define SBA_IOVA(ioc,iovp,offset,hint_reg) ((ioc->ibase) | (iovp) | (offset) | ((hint_reg)<<(ioc->hint_shift_pdir)))
 #define SBA_IOVP(ioc,iova) (((iova) & ioc->hint_mask_pdir) & ~(ioc->ibase))
 
-/* FIXME : review these macros to verify correctness and usage */
 #define PDIR_INDEX(iovp)   ((iovp)>>IOVP_SHIFT)
 
 #define RESMAP_MASK(n)    ~(~0UL << (n))
@@ -412,7 +413,7 @@
 
 
 /**
- * sba_search_bitmap - find free space in IO PDIR resource bitmap
+ * sba_search_bitmap - find free space in IO Pdir resource bitmap
  * @ioc: IO MMU structure which owns the pdir we are interested in.
  * @bits_wanted: number of entries we need.
  *
@@ -449,7 +450,7 @@
 		** We need the alignment to invalidate I/O TLB using
 		** SBA HW features in the unmap path.
 		*/
-		unsigned long o = 1 << get_order(bits_wanted << PAGE_SHIFT);
+		unsigned long o = 1 << get_order(bits_wanted << IOVP_SHIFT);
 		uint bitshiftcnt = ROUNDUP(ioc->res_bitshift, o);
 		unsigned long mask;
 
@@ -495,7 +496,7 @@
 
 
 /**
- * sba_alloc_range - find free bits and mark them in IO PDIR resource bitmap
+ * sba_alloc_range - find free bits and mark them in IO Pdir resource bitmap
  * @ioc: IO MMU structure which owns the pdir we are interested in.
  * @size: number of bytes to create a mapping for
  *
@@ -557,7 +558,7 @@
 
 
 /**
- * sba_free_range - unmark bits in IO PDIR resource bitmap
+ * sba_free_range - unmark bits in IO Pdir resource bitmap
  * @ioc: IO MMU structure which owns the pdir we are interested in.
  * @iova: IO virtual address which was previously allocated.
  * @size: number of bytes to create a mapping for
@@ -604,14 +605,14 @@
 
 
 /**
- * sba_io_pdir_entry - fill in one IO PDIR entry
- * @pdir_ptr:  pointer to IO PDIR entry
- * @vba: Virtual CPU address of buffer to map
+ * sba_io_pdir_entry - fill in one IO Pdir entry
+ * @pdir_ptr:  pointer to IO Pdir entry
+ * @phys_page: phys CPU address of page to map
  *
  * SBA Mapping Routine
  *
- * Given a virtual address (vba, arg1) sba_io_pdir_entry()
- * loads the I/O PDIR entry pointed to by pdir_ptr (arg0).
+ * Given a physical address (phys_page, arg1) sba_io_pdir_entry()
+ * loads the I/O Pdir entry pointed to by pdir_ptr (arg0).
  * Each IO Pdir entry consists of 8 bytes as shown below
  * (LSB = bit 0):
  *
@@ -623,20 +624,12 @@
  *  V  = Valid Bit
  *  U  = Unused
  * PPN = Physical Page Number
- *
- * The physical address fields are filled with the results of virt_to_phys()
- * on the vba.
  */
 
-#if 1
-#define sba_io_pdir_entry(pdir_ptr, vba) *pdir_ptr = ((vba & ~0xE000000000000FFFULL) | 0x80000000000000FFULL)
-#else
-void SBA_INLINE
-sba_io_pdir_entry(u64 *pdir_ptr, unsigned long vba)
-{
-	*pdir_ptr = ((vba & ~0xE000000000000FFFULL) | 0x80000000000000FFULL);
-}
-#endif
+#define SBA_VALID_MASK	0x80000000000000FFULL
+#define sba_io_pdir_entry(pdir_ptr, phys_page) *pdir_ptr = (phys_page | SBA_VALID_MASK)
+#define sba_io_page(pdir_ptr) (*pdir_ptr & ~SBA_VALID_MASK)
+
 
 #ifdef ENABLE_MARK_CLEAN
 /**
@@ -660,12 +653,12 @@
 #endif
 
 /**
- * sba_mark_invalid - invalidate one or more IO PDIR entries
+ * sba_mark_invalid - invalidate one or more IO Pdir entries
  * @ioc: IO MMU structure which owns the pdir we are interested in.
  * @iova:  IO Virtual Address mapped earlier
  * @byte_cnt:  number of bytes this mapping covers.
  *
- * Marking the IO PDIR entry(ies) as Invalid and invalidate
+ * Marking the IO Pdir entry(ies) as Invalid and invalidate
  * corresponding IO TLB entry. The PCOM (Purge Command Register)
  * is to purge stale entries in the IO TLB when unmapping entries.
  *
@@ -700,14 +693,14 @@
 		iovp |= IOVP_SHIFT;     /* set "size" field for PCOM */
 
 		/*
-		** clear I/O PDIR entry "valid" bit
+		** clear I/O Pdir entry "valid" bit
 		** Do NOT clear the rest - save it for debugging.
 		** We should only clear bits that have previously
 		** been enabled.
 		*/
-		ioc->pdir_base[off] &= ~(0x80000000000000FFULL);
+		ioc->pdir_base[off] &= ~SBA_VALID_MASK;
 	} else {
-		u32 t = get_order(byte_cnt) + PAGE_SHIFT;
+		u32 t = get_order(byte_cnt) + IOVP_SHIFT;
 
 		iovp |= t;
 		ASSERT(t <= 31);   /* 2GB! Max value of "size" field */
@@ -716,7 +709,7 @@
 			/* verify this pdir entry is enabled */
 			ASSERT(ioc->pdir_base[off]  >> 63);
 			/* clear I/O Pdir entry "valid" bit first */
-			ioc->pdir_base[off] &= ~(0x80000000000000FFULL);
+			ioc->pdir_base[off] &= ~SBA_VALID_MASK;
 			off++;
 			byte_cnt -= IOVP_SIZE;
 		} while (byte_cnt > 0);
@@ -744,7 +737,7 @@
 	u64 *pdir_start;
 	int pide;
 #ifdef ALLOW_IOV_BYPASS
-	unsigned long pci_addr = virt_to_phys(addr);
+	unsigned long phys_addr = virt_to_phys(addr);
 #endif
 
 	ioc = GET_IOC(dev);
@@ -754,7 +747,7 @@
 	/*
  	** Check if the PCI device can DMA to ptr... if so, just return ptr
  	*/
-	if ((pci_addr & ~dev->dma_mask) = 0) {
+	if ((phys_addr & ~dev->dma_mask) = 0) {
 		/*
  		** Device is bit capable of DMA'ing to the buffer...
 		** just return the PCI address of ptr
@@ -765,8 +758,8 @@
 		spin_unlock_irqrestore(&ioc->res_lock, flags);
 #endif
 		DBG_BYPASS("sba_map_single() bypass mask/addr: 0x%lx/0x%lx\n",
-		           dev->dma_mask, pci_addr);
-		return pci_addr;
+		           dev->dma_mask, phys_addr);
+		return phys_addr;
 	}
 #endif
 
@@ -799,7 +792,8 @@
 
 	while (size > 0) {
 		ASSERT(((u8 *)pdir_start)[7] = 0); /* verify availability */
-		sba_io_pdir_entry(pdir_start, (unsigned long) addr);
+
+		sba_io_pdir_entry(pdir_start, virt_to_phys(addr));
 
 		DBG_RUN("     pdir 0x%p %lx\n", pdir_start, *pdir_start);
 
@@ -812,7 +806,7 @@
 	sba_check_pdir(ioc,"Check after sba_map_single()");
 #endif
 	spin_unlock_irqrestore(&ioc->res_lock, flags);
-	return SBA_IOVA(ioc, iovp, offset, DEFAULT_DMA_HINT_REG);
+	return SBA_IOVA(ioc, iovp, offset, DEFAULT_DMA_HINT_REG(direction));
 }
 
 /**
@@ -866,6 +860,29 @@
 	size += offset;
 	size = ROUNDUP(size, IOVP_SIZE);
 
+#ifdef ENABLE_MARK_CLEAN
+	/*
+	** Don't need to hold the spinlock while telling VM pages are "clean".
+	** The pages are "busy" in the resource map until we mark them free.
+	** But tell VM pages are clean *before* releasing the resource
+	** in order to avoid race conditions.
+	*/
+	if (direction = PCI_DMA_FROMDEVICE) {
+		u32 iovp = (u32) SBA_IOVP(ioc,iova);
+		unsigned int pide = PDIR_INDEX(iovp);
+		u64 *pdirp = &(ioc->pdir_base[pide]);
+		size_t byte_cnt = size;
+		void *addr;
+
+		do {
+			addr = phys_to_virt(sba_io_page(pdirp));
+			mark_clean(addr, min(byte_cnt, IOVP_SIZE));
+			pdirp++;
+			byte_cnt -= IOVP_SIZE;
+		} while (byte_cnt > 0);
+	}
+#endif
+
 	spin_lock_irqsave(&ioc->res_lock, flags);
 #ifdef CONFIG_PROC_FS
 	ioc->usingle_calls++;
@@ -891,40 +908,7 @@
 	sba_free_range(ioc, iova, size);
 	READ_REG(ioc->ioc_hpa+IOC_PCOM);	/* flush purges */
 #endif /* DELAYED_RESOURCE_CNT = 0 */
-#ifdef ENABLE_MARK_CLEAN
-	if (direction = PCI_DMA_FROMDEVICE) {
-		u32 iovp = (u32) SBA_IOVP(ioc,iova);
-		int off = PDIR_INDEX(iovp);
-		void *addr;
-
-		if (size <= IOVP_SIZE) {
-			addr = phys_to_virt(ioc->pdir_base[off] &
-					    ~0xE000000000000FFFULL);
-			mark_clean(addr, size);
-		} else {
-			size_t byte_cnt = size;
-
-			do {
-				addr = phys_to_virt(ioc->pdir_base[off] &
-				                    ~0xE000000000000FFFULL);
-				mark_clean(addr, min(byte_cnt, IOVP_SIZE));
-				off++;
-				byte_cnt -= IOVP_SIZE;
-
-			   } while (byte_cnt > 0);
-		}
-	}
-#endif
 	spin_unlock_irqrestore(&ioc->res_lock, flags);
-
-	/* XXX REVISIT for 2.5 Linux - need syncdma for zero-copy support.
-	** For Astro based systems this isn't a big deal WRT performance.
-	** As long as 2.4 kernels copyin/copyout data from/to userspace,
-	** we don't need the syncdma. The issue here is I/O MMU cachelines
-	** are *not* coherent in all cases.  May be hwrev dependent.
-	** Need to investigate more.
-	asm volatile("syncdma");	
-	*/
 }
 
 
@@ -980,242 +964,109 @@
 }
 
 
-/*
-** Since 0 is a valid pdir_base index value, can't use that
-** to determine if a value is valid or not. Use a flag to indicate
-** the SG list entry contains a valid pdir index.
-*/
-#define PIDE_FLAG 0x1UL
-
 #ifdef DEBUG_LARGE_SG_ENTRIES
 int dump_run_sg = 0;
 #endif
 
-
-/**
- * sba_fill_pdir - write allocated SG entries into IO PDIR
- * @ioc: IO MMU structure which owns the pdir we are interested in.
- * @startsg:  list of IOVA/size pairs
- * @nents: number of entries in startsg list
- *
- * Take preprocessed SG list and write corresponding entries
- * in the IO PDIR.
- */
-
-static SBA_INLINE int
-sba_fill_pdir(
-	struct ioc *ioc,
-	struct scatterlist *startsg,
-	int nents)
-{
-	struct scatterlist *dma_sg = startsg;	/* pointer to current DMA */
-	int n_mappings = 0;
-	u64 *pdirp = 0;
-	unsigned long dma_offset = 0;
-
-	dma_sg--;
-	while (nents-- > 0) {
-		int     cnt = sba_sg_len(startsg);
-		sba_sg_len(startsg) = 0;
-
-#ifdef DEBUG_LARGE_SG_ENTRIES
-		if (dump_run_sg)
-			printk(" %2d : %08lx/%05x %p\n",
-				nents,
-				(unsigned long) sba_sg_iova(startsg), cnt,
-				sba_sg_buffer(startsg)
-		);
-#else
-		DBG_RUN_SG(" %d : %08lx/%05x %p\n",
-				nents,
-				(unsigned long) sba_sg_iova(startsg), cnt,
-				sba_sg_buffer(startsg)
-		);
-#endif
-		/*
-		** Look for the start of a new DMA stream
-		*/
-		if ((u64)sba_sg_iova(startsg) & PIDE_FLAG) {
-			u32 pide = (u64)sba_sg_iova(startsg) & ~PIDE_FLAG;
-			dma_offset = (unsigned long) pide & ~IOVP_MASK;
-			sba_sg_iova(startsg) = 0;
-			dma_sg++;
-			sba_sg_iova(dma_sg) = (char *)(pide | ioc->ibase);
-			pdirp = &(ioc->pdir_base[pide >> IOVP_SHIFT]);
-			n_mappings++;
-		}
-
-		/*
-		** Look for a VCONTIG chunk
-		*/
-		if (cnt) {
-			unsigned long vaddr = (unsigned long) sba_sg_buffer(startsg);
-			ASSERT(pdirp);
-
-			/* Since multiple Vcontig blocks could make up
-			** one DMA stream, *add* cnt to dma_len.
-			*/
-			sba_sg_len(dma_sg) += cnt;
-			cnt += dma_offset;
-			dma_offset=0;	/* only want offset on first chunk */
-			cnt = ROUNDUP(cnt, IOVP_SIZE);
-#ifdef CONFIG_PROC_FS
-			ioc->msg_pages += cnt >> IOVP_SHIFT;
-#endif
-			do {
-				sba_io_pdir_entry(pdirp, vaddr);
-				vaddr += IOVP_SIZE;
-				cnt -= IOVP_SIZE;
-				pdirp++;
-			} while (cnt > 0);
-		}
-		startsg++;
-	}
-#ifdef DEBUG_LARGE_SG_ENTRIES
-	dump_run_sg = 0;
-#endif
-	return(n_mappings);
-}
-
-
-/*
-** Two address ranges are DMA contiguous *iff* "end of prev" and
-** "start of next" are both on a page boundry.
-**
-** (shift left is a quick trick to mask off upper bits)
-*/
-#define DMA_CONTIG(__X, __Y) \
-	(((((unsigned long) __X) | ((unsigned long) __Y)) << (BITS_PER_LONG - PAGE_SHIFT)) = 0UL)
+#define SG_ENT_VIRT_PAGE(sg) page_address((sg)->page)
+#define SG_ENT_PHYS_PAGE(SG) virt_to_phys(SG_ENT_VIRT_PAGE(SG))
 
 
 /**
  * sba_coalesce_chunks - preprocess the SG list
  * @ioc: IO MMU structure which owns the pdir we are interested in.
- * @startsg:  list of IOVA/size pairs
+ * @startsg:  input=SG list	output=DMA addr/len pairs filled in
  * @nents: number of entries in startsg list
+ * @direction: R/W or both.
  *
- * First pass is to walk the SG list and determine where the breaks are
- * in the DMA stream. Allocates PDIR entries but does not fill them.
- * Returns the number of DMA chunks.
- *
- * Doing the fill seperate from the coalescing/allocation keeps the
- * code simpler. Future enhancement could make one pass through
- * the sglist do both.
+ * Walk the SG list and determine where the breaks are in the DMA stream.
+ * Allocate IO Pdir resources and fill them in separate loop.
+ * Returns the number of DMA streams used for output IOVA list.
+ * Note each DMA stream can consume multiple IO Pdir entries.
+ *
+ * Code is written assuming some coalescing is possible.
  */
 static SBA_INLINE int
-sba_coalesce_chunks( struct ioc *ioc,
-	struct scatterlist *startsg,
-	int nents)
-{
-	struct scatterlist *vcontig_sg;    /* VCONTIG chunk head */
-	unsigned long vcontig_len;         /* len of VCONTIG chunk */
-	unsigned long vcontig_end;
-	struct scatterlist *dma_sg;        /* next DMA stream head */
-	unsigned long dma_offset, dma_len; /* start/len of DMA stream */
+sba_coalesce_chunks(struct ioc *ioc, struct scatterlist *startsg,
+	int nents, int direction)
+{
+	struct scatterlist *dma_sg = startsg;	/* return array */
 	int n_mappings = 0;
 
-	while (nents > 0) {
-		unsigned long vaddr = (unsigned long) (startsg->address); 
+	ASSERT(nents > 1);
+
+	do {
+		unsigned int dma_cnt = 1; /* number of pages in DMA stream */
+		unsigned int pide;	/* index into IO Pdir array */
+		u64 *pdirp;		/* pointer into IO Pdir array */
+		unsigned long dma_offset, dma_len; /* cumulative DMA stream */
 
 		/*
 		** Prepare for first/next DMA stream
 		*/
-		dma_sg = vcontig_sg = startsg;
-		dma_len = vcontig_len = vcontig_end = sba_sg_len(startsg);
-		vcontig_end +=  vaddr;
-		dma_offset = vaddr & ~IOVP_MASK;
-
-		/* PARANOID: clear entries */
-		sba_sg_buffer(startsg) = sba_sg_iova(startsg);
-		sba_sg_iova(startsg) = 0;
-		sba_sg_len(startsg) = 0;
+		dma_len = sba_sg_len(startsg);
+		dma_offset = sba_sg_address(startsg);
+		startsg++;
+		nents--;
 
 		/*
-		** This loop terminates one iteration "early" since
-		** it's always looking one "ahead".
+		** We want to know how many entries can be coalesced
+		** before trying to allocate IO Pdir space.
+		** IOVAs can then be allocated "naturally" aligned
+		** to take advantage of the block IO TLB flush.
 		*/
-		while (--nents > 0) {
-			unsigned long vaddr;	/* tmp */
-
-			startsg++;
+		while (nents) {
+			unsigned int end_offset = dma_offset + dma_len;
 
-			/* catch brokenness in SCSI layer */
-			ASSERT(startsg->length <= DMA_CHUNK_SIZE);
+			/* prev entry must end on a page boundary */
+			if (end_offset & IOVP_MASK)
+				break;
 
-			/*
-			** First make sure current dma stream won't
-			** exceed DMA_CHUNK_SIZE if we coalesce the
-			** next entry.
-			*/
-			if (((dma_len + dma_offset + startsg->length + ~IOVP_MASK) & IOVP_MASK) > DMA_CHUNK_SIZE)
+			/* next entry start on a page boundary? */
+			if (startsg->offset)
 				break;
 
 			/*
-			** Then look for virtually contiguous blocks.
-			**
-			** append the next transaction?
+			** make sure current dma stream won't exceed
+			** DMA_CHUNK_SIZE if coalescing entries.
 			*/
-			vaddr = (unsigned long) sba_sg_iova(startsg);
-			if  (vcontig_end = vaddr)
-			{
-				vcontig_len += sba_sg_len(startsg);
-				vcontig_end += sba_sg_len(startsg);
-				dma_len     += sba_sg_len(startsg);
-				sba_sg_buffer(startsg) = (char *)vaddr;
-				sba_sg_iova(startsg) = 0;
-				sba_sg_len(startsg) = 0;
-				continue;
-			}
+			if (((end_offset + startsg->length + ~IOVP_MASK)
+								& IOVP_MASK)
+					> DMA_CHUNK_SIZE)
+				break;
 
-#ifdef DEBUG_LARGE_SG_ENTRIES
-			dump_run_sg = (vcontig_len > IOVP_SIZE);
-#endif
+			dma_len += sba_sg_len(startsg);
+			startsg++;
+			nents--;
+			dma_cnt++;
+		}
 
-			/*
-			** Not virtually contigous.
-			** Terminate prev chunk.
-			** Start a new chunk.
-			**
-			** Once we start a new VCONTIG chunk, dma_offset
-			** can't change. And we need the offset from the first
-			** chunk - not the last one. Ergo Successive chunks
-			** must start on page boundaries and dove tail
-			** with it's predecessor.
-			*/
-			sba_sg_len(vcontig_sg) = vcontig_len;
+		ASSERT(dma_len <= DMA_CHUNK_SIZE);
 
-			vcontig_sg = startsg;
-			vcontig_len = sba_sg_len(startsg);
+		/* allocate IO Pdir resource.
+		** returns index into (u64) IO Pdir array.
+		** IOVA is formed from this.
+		*/
+		pide = sba_alloc_range(ioc, dma_cnt << IOVP_SHIFT);
+		pdirp = &(ioc->pdir_base[pide]);
 
-			/*
-			** 3) do the entries end/start on page boundaries?
-			**    Don't update vcontig_end until we've checked.
-			*/
-			if (DMA_CONTIG(vcontig_end, vaddr))
-			{
-				vcontig_end = vcontig_len + vaddr;
-				dma_len += vcontig_len;
-				sba_sg_buffer(startsg) = (char *)vaddr;
-				sba_sg_iova(startsg) = 0;
-				continue;
-			} else {
-				break;
-			}
+		/* fill_pdir: write stream into IO Pdir */
+		while (dma_cnt--) {
+			sba_io_pdir_entry(pdirp, SG_ENT_PHYS_PAGE(startsg));
+			startsg++;
+			pdirp++;
 		}
 
-		/*
-		** End of DMA Stream
-		** Terminate last VCONTIG block.
-		** Allocate space for DMA stream.
-		*/
-		sba_sg_len(vcontig_sg) = vcontig_len;
-		dma_len = (dma_len + dma_offset + ~IOVP_MASK) & IOVP_MASK;
-		ASSERT(dma_len <= DMA_CHUNK_SIZE);
-		sba_sg_iova(dma_sg) = (char *) (PIDE_FLAG 
-			| (sba_alloc_range(ioc, dma_len) << IOVP_SHIFT)
-			| dma_offset);
+		/* "output" IOVA */
+		sba_sg_iova(dma_sg) = SBA_IOVA(ioc,
+					((dma_addr_t) pide << IOVP_SHIFT),
+					dma_offset,
+					DEFAULT_DMA_HINT_REG(direction));
+		sba_sg_iova_len(dma_sg) = dma_len;
+
+		dma_sg++;
 		n_mappings++;
-	}
+	} while (nents);
 
 	return n_mappings;
 }
@@ -1223,7 +1074,7 @@
 
 /**
  * sba_map_sg - map Scatter/Gather list
- * @dev: instance of PCI owned by the driver that's asking.
+ * @dev: instance of PCI device owned by the driver that's asking.
  * @sglist:  array of buffer/length pairs
  * @nents:  number of entries in list
  * @direction:  R/W or both.
@@ -1234,42 +1085,46 @@
 		int direction)
 {
 	struct ioc *ioc;
-	int coalesced, filled = 0;
+	int filled = 0;
 	unsigned long flags;
 #ifdef ALLOW_IOV_BYPASS
 	struct scatterlist *sg;
 #endif
 
-	DBG_RUN_SG("%s() START %d entries\n", __FUNCTION__, nents);
+	DBG_RUN_SG("%s() START %d entries, 0x%p,0x%x\n", __FUNCTION__, nents,
+		sba_sg_address(sglist), sba_sg_len(sglist));
+
 	ioc = GET_IOC(dev);
 	ASSERT(ioc);
 
 #ifdef ALLOW_IOV_BYPASS
 	if (dev->dma_mask >= ioc->dma_mask) {
-		for (sg = sglist ; filled < nents ; filled++, sg++){
-			sba_sg_buffer(sg) = sba_sg_iova(sg);
-			sba_sg_iova(sg) = (char *)virt_to_phys(sba_sg_buffer(sg));
+		for (sg = sglist ; filled < nents ; filled++, sg++) {
+			sba_sg_iova(sg) = virt_to_phys(sba_sg_address(sg));
+			sba_sg_iova_len(sg) = sba_sg_len(sg);
 		}
 #ifdef CONFIG_PROC_FS
 		spin_lock_irqsave(&ioc->res_lock, flags);
 		ioc->msg_bypass++;
 		spin_unlock_irqrestore(&ioc->res_lock, flags);
 #endif
+		DBG_RUN_SG("%s() DONE %d mappings bypassed\n", __FUNCTION__, filled);
 		return filled;
 	}
 #endif
 	/* Fast path single entry scatterlists. */
 	if (nents = 1) {
-		sba_sg_buffer(sglist) = sba_sg_iova(sglist);
 		sba_sg_iova(sglist) = (char *)sba_map_single(dev,
-						sba_sg_buffer(sglist),
+						sba_sg_iova(sglist),
 						sba_sg_len(sglist), direction);
+		sba_sg_iova_len(sglist) = sba_sg_len(sglist);
 #ifdef CONFIG_PROC_FS
 		/*
 		** Should probably do some stats counting, but trying to
 		** be precise quickly starts wasting CPU time.
 		*/
 #endif
+		DBG_RUN_SG("%s() DONE 1 mapping\n", __FUNCTION__);
 		return 1;
 	}
 
@@ -1286,26 +1141,11 @@
 #ifdef CONFIG_PROC_FS
 	ioc->msg_calls++;
 #endif
-
-	/*
-	** First coalesce the chunks and allocate I/O pdir space
-	**
-	** If this is one DMA stream, we can properly map using the
-	** correct virtual address associated with each DMA page.
-	** w/o this association, we wouldn't have coherent DMA!
-	** Access to the virtual address is what forces a two pass algorithm.
-	*/
-	coalesced = sba_coalesce_chunks(ioc, sglist, nents);
  
 	/*
-	** Program the I/O Pdir
-	**
-	** map the virtual addresses to the I/O Pdir
-	** o dma_address will contain the pdir index
-	** o dma_len will contain the number of bytes to map 
-	** o address contains the virtual address.
+	** coalesce and program the I/O Pdir
 	*/
-	filled = sba_fill_pdir(ioc, sglist, nents);
+	filled = sba_coalesce_chunks(ioc, sglist, nents, direction);
 
 #ifdef ASSERT_PDIR_SANITY
 	if (sba_check_pdir(ioc,"Check after sba_map_sg()"))
@@ -1317,7 +1157,6 @@
 
 	spin_unlock_irqrestore(&ioc->res_lock, flags);
 
-	ASSERT(coalesced = filled);
 	DBG_RUN_SG("%s() DONE %d mappings\n", __FUNCTION__, filled);
 
 	return filled;
@@ -1341,8 +1180,8 @@
 	unsigned long flags;
 #endif
 
-	DBG_RUN_SG("%s() START %d entries,  %p,%x\n",
-		__FUNCTION__, nents, sba_sg_buffer(sglist), sglist->length);
+	DBG_RUN_SG("%s() START %d entries, 0x%p,0x%x\n",
+		__FUNCTION__, nents, sba_sg_address(sglist), sba_sg_len(sglist));
 
 	ioc = GET_IOC(dev);
 	ASSERT(ioc);
@@ -1360,7 +1199,7 @@
 	while (sba_sg_len(sglist) && nents--) {
 
 		sba_unmap_single(dev, (dma_addr_t)sba_sg_iova(sglist),
-		                 sba_sg_len(sglist), direction);
+		                 sba_sg_iova_len(sglist), direction);
 #ifdef CONFIG_PROC_FS
 		/*
 		** This leaves inconsistent data in the stats, but we can't
@@ -1368,7 +1207,7 @@
 		** were coalesced to a single entry.  The stats are fun,
 		** but speed is more important.
 		*/
-		ioc->usg_pages += (((u64)sba_sg_iova(sglist) & ~IOVP_MASK) + sba_sg_len(sglist) + IOVP_SIZE - 1) >> PAGE_SHIFT;
+		ioc->usg_pages += (((u64)sba_sg_iova(sglist) & ~IOVP_MASK) + sba_sg_len(sglist) + IOVP_SIZE - 1) >> IOVP_SHIFT;
 #endif
 		++sglist;
 	}
@@ -1429,12 +1268,12 @@
 		__FUNCTION__, ioc->ioc_hpa, iova_space_size>>20,
 		iov_order + PAGE_SHIFT, ioc->pdir_size);
 
-	/* FIXME : DMA HINTs not used */
+	/* XXX DMA HINTs not used */
 	ioc->hint_shift_pdir = iov_order + PAGE_SHIFT;
 	ioc->hint_mask_pdir = ~(0x3 << (iov_order + PAGE_SHIFT));
 
-	ioc->pdir_base -	pdir_base = (void *) __get_free_pages(GFP_KERNEL, get_order(pdir_size));
+	ioc->pdir_base = pdir_base +		(void *) __get_free_pages(GFP_KERNEL, get_order(pdir_size));
 	if (NULL = pdir_base)
 	{
 		panic(__FILE__ ":%s() could not allocate I/O Page Table\n", __FUNCTION__);
@@ -1452,20 +1291,8 @@
 
 	/* build IMASK for IOC and Elroy */
 	iova_space_mask =  0xffffffff;
-	iova_space_mask <<= (iov_order + PAGE_SHIFT);
+	iova_space_mask <<= (iov_order + IOVP_SHIFT);
 
-#ifdef CONFIG_IA64_HP_PROTO
-	/*
-	** REVISIT - this is a kludge, but we won't be supporting anything but
-	** zx1 2.0 or greater for real.  When fw is in shape, ibase will
-	** be preprogrammed w/ the IOVA hole base and imask will give us
-	** the size.
-	*/
-	if ((sba_dev->hw_rev & 0xFF) < 0x20) {
-		DBG_INIT("%s() Found SBA rev < 2.0, setting IOVA base to 0.  This device will not be supported in the future.\n", __FUNCTION__);
-		ioc->ibase = 0x0;
-	} else
-#endif
 	ioc->ibase = READ_REG(ioc->ioc_hpa + IOC_IBASE) & 0xFFFFFFFEUL;
 
 	ioc->imask = iova_space_mask;	/* save it */
@@ -1474,7 +1301,7 @@
 		__FUNCTION__, ioc->ibase, ioc->imask);
 
 	/*
-	** FIXME: Hint registers are programmed with default hint
+	** XXX DMA HINT registers are programmed with default hint
 	** values during boot, so hints should be sane even if we
 	** can't reprogram them the way drivers want.
 	*/
@@ -1487,8 +1314,8 @@
 	*/
 	ioc->imask |= 0xFFFFFFFF00000000UL;
 
-	/* Set I/O PDIR Page size to system page size */
-	switch (PAGE_SHIFT) {
+	/* Set I/O Pdir page size to system page size */
+	switch (IOVP_SHIFT) {
 		case 12: /* 4K */
 			tcnfg = 0;
 			break;
@@ -1636,7 +1463,7 @@
 				res_word = (int)(index / BITS_PER_LONG);
 				mask =  0x1UL << (index - (res_word * BITS_PER_LONG));
 				res_ptr[res_word] |= mask;
-				sba_dev->ioc[i].pdir_base[PDIR_INDEX(reserved_iov)] = (0x80000000000000FFULL | reserved_iov);
+				sba_dev->ioc[i].pdir_base[PDIR_INDEX(reserved_iov)] = (SBA_VALID_MASK | reserved_iov);
 
 			}
 		}
diff -u -r -X /home/helgaas/exclude linux-2.5.18-ia64-020530.orig/arch/ia64/lib/swiotlb.c linux-sg/arch/ia64/lib/swiotlb.c
--- linux-2.5.18-ia64-020530.orig/arch/ia64/lib/swiotlb.c	Tue Jun  4 11:24:07 2002
+++ linux-sg/arch/ia64/lib/swiotlb.c	Fri Jun  7 11:00:04 2002
@@ -415,18 +415,20 @@
 swiotlb_map_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nelems, int direction)
 {
 	void *addr;
+	unsigned long pci_addr;
 	int i;
 
 	if (direction = PCI_DMA_NONE)
 		BUG();
 
 	for (i = 0; i < nelems; i++, sg++) {
-		sg->orig_address = SG_ENT_VIRT_ADDRESS(sg);
-		if ((SG_ENT_PHYS_ADDRESS(sg) & ~hwdev->dma_mask) != 0) {
-			addr = map_single(hwdev, sg->orig_address, sg->length, direction);
-			sg->page = virt_to_page(addr);
-			sg->offset = (u64) addr & ~PAGE_MASK;
-		}
+		addr = SG_ENT_VIRT_ADDRESS(sg);
+		pci_addr = virt_to_phys(addr);
+		if ((pci_addr & ~hwdev->dma_mask) != 0)
+			sg->dma_address = map_single(hwdev, addr, sg->length, direction);
+		else
+			sg->dma_address = pci_addr;
+		sg->dma_length = sg->length;
 	}
 	return nelems;
 }
@@ -444,12 +446,10 @@
 		BUG();
 
 	for (i = 0; i < nelems; i++, sg++)
-		if (sg->orig_address != SG_ENT_VIRT_ADDRESS(sg)) {
-			unmap_single(hwdev, SG_ENT_VIRT_ADDRESS(sg), sg->length, direction);
-			sg->page = virt_to_page(sg->orig_address);
-			sg->offset = (u64) sg->orig_address & ~PAGE_MASK;
-		} else if (direction = PCI_DMA_FROMDEVICE)
-			mark_clean(SG_ENT_VIRT_ADDRESS(sg), sg->length);
+		if (sg->dma_address != SG_ENT_PHYS_ADDRESS(sg))
+			unmap_single(hwdev, sg->dma_address, sg->dma_length, direction);
+		else if (direction = PCI_DMA_FROMDEVICE)
+			mark_clean(SG_ENT_VIRT_ADDRESS(sg), sg->dma_length);
 }
 
 /*
@@ -468,14 +468,14 @@
 		BUG();
 
 	for (i = 0; i < nelems; i++, sg++)
-		if (sg->orig_address != SG_ENT_VIRT_ADDRESS(sg))
-			sync_single(hwdev, SG_ENT_VIRT_ADDRESS(sg), sg->length, direction);
+		if (sg->dma_address != SG_ENT_PHYS_ADDRESS(sg))
+			sync_single(hwdev, sg->dma_address, sg->dma_length, direction);
 }
 
 unsigned long
 swiotlb_dma_address (struct scatterlist *sg)
 {
-	return SG_ENT_PHYS_ADDRESS(sg);
+	return sg->dma_address;
 }
 
 /*
diff -u -r -X /home/helgaas/exclude linux-2.5.18-ia64-020530.orig/include/asm-ia64/pci.h linux-sg/include/asm-ia64/pci.h
--- linux-2.5.18-ia64-020530.orig/include/asm-ia64/pci.h	Thu Jun  6 17:03:56 2002
+++ linux-sg/include/asm-ia64/pci.h	Fri Jun  7 11:04:29 2002
@@ -90,7 +90,7 @@
 /* Return the index of the PCI controller for device PDEV. */
 #define pci_controller_num(PDEV)	(0)
 
-#define sg_dma_len(sg)		((sg)->length)
+#define sg_dma_len(sg)		((sg)->dma_length)
 
 #define HAVE_PCI_MMAP
 extern int pci_mmap_page_range (struct pci_dev *dev, struct vm_area_struct *vma,
diff -u -r -X /home/helgaas/exclude linux-2.5.18-ia64-020530.orig/include/asm-ia64/scatterlist.h linux-sg/include/asm-ia64/scatterlist.h
--- linux-2.5.18-ia64-020530.orig/include/asm-ia64/scatterlist.h	Fri May 24 19:55:16 2002
+++ linux-sg/include/asm-ia64/scatterlist.h	Fri Jun  7 11:00:04 2002
@@ -7,12 +7,12 @@
  */
 
 struct scatterlist {
-	char *orig_address;	/* for use by swiotlb */
-
-	/* These two are only valid if ADDRESS member of this struct is NULL.  */
 	struct page *page;
 	unsigned int offset;
 	unsigned int length;	/* buffer length */
+
+	dma_addr_t dma_address;
+	unsigned int dma_length;
 };
 
 #define ISA_DMA_THRESHOLD	(~0UL)


