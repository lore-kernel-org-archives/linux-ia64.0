From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 03 Feb 2004 00:16:40 +0000
Subject: [PATCH] sba_iommu perf tunning and new functionality
Message-Id: <1075767400.3842.414.camel@patsy.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   I've been doing some performance tuning and adding some functionality
to sba_iommu for zx1/sx1000 chipsets.  This adds:

      * Long overdue consistent_dma_mask support
      * Long overdue ability to do large mappings in the iommu
      * Tightened spinlock usage for better performance/scalability
      * Added branch prediction hints for some of the performance paths
      * Added explicit data prefetching to some performance paths -
        perfmon shows roughly a 20% decrease in L3 misses in the bitmap
        search code
      * Increased delayed resource freeing depth and added a separate
        lock per ioc to avoid contention
      * Added code to free up queued pdir entries should we be unable to
        find space for new ones (not that I've ever seen the pdir
        anywhere close to full)
      * Finished cleaning out the hint support code, Grant is
        maintaining this separately for now
      * Added option to control bypass of sg mappings separately from
        single/coherent mappings

Much like the swiotlb, sba_iommu allows devices capable of 64bit
addressing to bypass the iommu and DMA directly to/from memory.  Using a
worst case scenario test (64bit bypass disabled, all DMA mapped through
the iommu), I saw a 60% increase in sequential block input throughput
using bonnie++ on a large RAID0 MD array.  In fact, this patch provides
the best bonnie++ performance with bypass disabled.  This is likely due
to benefits seen from coalescing the scatterlist, allowing better disk
streaming.  I assume that network performance will likely be limited by
mapping latency, so I added the last bullet item to allow sg mappings to
get the benefit of coalescing while keeping a low latency path for
single and coherent mappings.  If anyone is setup for network
benchmarks, I'd be interested in a before and after with this patch.

   The patch below is against 2.6.2-rc3.  I'll work on a 2.4 version if
nobody spots any issues in this one.  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab


=== arch/ia64/hp/common/sba_iommu.c 1.36 vs edited ==--- 1.36/arch/ia64/hp/common/sba_iommu.c	Mon Jan 26 01:47:02 2004
+++ edited/arch/ia64/hp/common/sba_iommu.c	Mon Feb  2 15:58:46 2004
@@ -57,11 +57,21 @@
 ** There's potentially a conflict in the bio merge code with us
 ** advertising an iommu, but then bypassing it.  Since I/O MMU bypassing
 ** appears to give more performance than bio-level virtual merging, we'll
-** do the former for now.
+** do the former for now.  NOTE: BYPASS_SG also needs to be undef'd to
+** completely restrict DMA to the IOMMU.
 */
 #define ALLOW_IOV_BYPASS
 
 /*
+** This option specifically allows/disallows bypassing scatterlists with
+** multiple entries.  Coalescing these entries can allow better DMA streaming
+** and in some cases shows better performance than entirely bypassing the
+** IOMMU.  Performance increase on the order of 1-2% sequential output/input
+** using bonnie++ on a RAID0 MD device (sym2 & mpt).
+*/
+#undef ALLOW_IOV_BYPASS_SG
+
+/*
 ** If a device prefetches beyond the end of a valid pdir entry, it will cause
 ** a hard failure, ie. MCA.  Version 3.0 and later of the zx1 LBA should
 ** disconnect on 4k boundaries and prevent such issues.  If the device is
@@ -75,7 +85,10 @@
 #define ENABLE_MARK_CLEAN
 
 /*
-** The number of debug flags is a clue - this code is fragile.
+** The number of debug flags is a clue - this code is fragile.  NOTE: since
+** tightening the use of res_lock the resource bitmap and actual pdir are no
+** longer guaranteed to stay in sync.  The sanity checking code isn't going to
+** like that.
 */
 #undef DEBUG_SBA_INIT
 #undef DEBUG_SBA_RUN
@@ -140,9 +153,7 @@
 ** allocated and free'd/purged at a time might make this
 ** less interesting).
 */
-#define DELAYED_RESOURCE_CNT	16
-
-#define DEFAULT_DMA_HINT_REG	0
+#define DELAYED_RESOURCE_CNT	64
 
 #define ZX1_IOC_ID	((PCI_DEVICE_ID_HP_ZX1_IOC << 16) | PCI_VENDOR_ID_HP)
 #define REO_IOC_ID	((PCI_DEVICE_ID_HP_REO_IOC << 16) | PCI_VENDOR_ID_HP)
@@ -187,14 +198,15 @@
 	unsigned long	imask;		/* pdir IOV Space mask */
 
 	unsigned long	*res_hint;	/* next avail IOVP - circular search */
-	spinlock_t	res_lock;
-	unsigned long	hint_mask_pdir;	/* bits used for DMA hints */
+	unsigned long	dma_mask;
+	spinlock_t	res_lock;	/* protects the resource bitmap, but must be held when */
+					/* clearing pdir to prevent races with allocations. */
 	unsigned int	res_bitshift;	/* from the RIGHT! */
 	unsigned int	res_size;	/* size of resource map in bytes */
-	unsigned int	hint_shift_pdir;
-	unsigned long	dma_mask;
 #if DELAYED_RESOURCE_CNT > 0
-	int saved_cnt;
+	spinlock_t	saved_lock;	/* may want to try to get this on a separate cacheline */
+					/* than res_lock for bigger systems. */
+	int		saved_cnt;
 	struct sba_dma_pair {
 		dma_addr_t	iova;
 		size_t		size;
@@ -221,6 +233,9 @@
 static struct ioc *ioc_list;
 static int reserve_sba_gart = 1;
 
+static SBA_INLINE void sba_mark_invalid(struct ioc *, dma_addr_t, size_t);
+static SBA_INLINE void sba_free_range(struct ioc *, dma_addr_t, size_t);
+
 #define sba_sg_address(sg)	(page_address((sg)->page) + (sg)->offset)
 
 #ifdef FULL_VALID_PDIR
@@ -405,7 +420,7 @@
 #define PAGES_PER_RANGE 1	/* could increase this to 4 or 8 if needed */
 
 /* Convert from IOVP to IOVA and vice versa. */
-#define SBA_IOVA(ioc,iovp,offset,hint_reg) ((ioc->ibase) | (iovp) | (offset))
+#define SBA_IOVA(ioc,iovp,offset) ((ioc->ibase) | (iovp) | (offset))
 #define SBA_IOVP(ioc,iova) ((iova) & ~(ioc->ibase))
 
 #define PDIR_ENTRY_SIZE	sizeof(u64)
@@ -453,20 +468,25 @@
 
 	ASSERT(((unsigned long) ioc->res_hint & (sizeof(unsigned long) - 1UL)) = 0);
 	ASSERT(res_ptr < res_end);
-	if (bits_wanted > (BITS_PER_LONG/2)) {
-		/* Search word at a time - no mask needed */
-		for(; res_ptr < res_end; ++res_ptr) {
-			if (*res_ptr = 0) {
-				*res_ptr = RESMAP_MASK(bits_wanted);
+
+	if (likely(bits_wanted = 1)) {
+		unsigned int bitshiftcnt;
+		for(; res_ptr < res_end ; res_ptr++) {
+			if (likely(*res_ptr != ~0UL)) {
+				bitshiftcnt = ffz(*res_ptr);
+				*res_ptr |= (1UL << bitshiftcnt);
 				pide = ((unsigned long)res_ptr - (unsigned long)ioc->res_map);
 				pide <<= 3;	/* convert to bit address */
-				break;
+				pide += bitshiftcnt;
+				ioc->res_bitshift = bitshiftcnt + bits_wanted;
+				goto found_it;
 			}
 		}
-		/* point to the next word on next pass */
-		res_ptr++;
-		ioc->res_bitshift = 0;
-	} else {
+		goto not_found;
+
+	}
+	
+	if (likely(bits_wanted <= BITS_PER_LONG/2)) {
 		/*
 		** Search the resource bit map on well-aligned values.
 		** "o" is the alignment.
@@ -475,45 +495,72 @@
 		*/
 		unsigned long o = 1 << get_iovp_order(bits_wanted << iovp_shift);
 		uint bitshiftcnt = ROUNDUP(ioc->res_bitshift, o);
-		unsigned long mask;
+		unsigned long mask, base_mask;
 
-		if (bitshiftcnt >= BITS_PER_LONG) {
-			bitshiftcnt = 0;
-			res_ptr++;
-		}
-		mask = RESMAP_MASK(bits_wanted) << bitshiftcnt;
+		base_mask = RESMAP_MASK(bits_wanted);
+		mask = base_mask << bitshiftcnt;
 
 		DBG_RES("%s() o %ld %p", __FUNCTION__, o, res_ptr);
-		while(res_ptr < res_end)
+		for(; res_ptr < res_end ; res_ptr++)
 		{ 
 			DBG_RES("    %p %lx %lx\n", res_ptr, mask, *res_ptr);
 			ASSERT(0 != mask);
-			if(0 = ((*res_ptr) & mask)) {
-				*res_ptr |= mask;     /* mark resources busy! */
-				pide = ((unsigned long)res_ptr - (unsigned long)ioc->res_map);
-				pide <<= 3;	/* convert to bit address */
-				pide += bitshiftcnt;
-				break;
-			}
-			mask <<= o;
-			bitshiftcnt += o;
-			if (0 = mask) {
-				mask = RESMAP_MASK(bits_wanted);
-				bitshiftcnt=0;
-				res_ptr++;
+			for (; mask ; mask <<= o, bitshiftcnt += o) {
+				if(0 = ((*res_ptr) & mask)) {
+					*res_ptr |= mask;     /* mark resources busy! */
+					pide = ((unsigned long)res_ptr - (unsigned long)ioc->res_map);
+					pide <<= 3;	/* convert to bit address */
+					pide += bitshiftcnt;
+					ioc->res_bitshift = bitshiftcnt + bits_wanted;
+					goto found_it;
+				}
 			}
+
+			bitshiftcnt = 0;
+			mask = base_mask;
+
 		}
-		/* look in the same word on the next pass */
-		ioc->res_bitshift = bitshiftcnt + bits_wanted;
-	}
 
-	/* wrapped ? */
-	if (res_end <= res_ptr) {
-		ioc->res_hint = (unsigned long *) ioc->res_map;
-		ioc->res_bitshift = 0;
 	} else {
-		ioc->res_hint = res_ptr;
+		int qwords, bits, i;
+		unsigned long *end;
+
+		qwords = bits_wanted >> 6; /* /64 */
+		bits = bits_wanted - (qwords * BITS_PER_LONG);
+
+		end = res_end - qwords;
+
+		for (; res_ptr < end; res_ptr++) {
+			for (i = 0 ; i < qwords ; i++) {
+				if (res_ptr[i] != 0)
+					goto next_ptr;
+			}
+			if (bits && res_ptr[i] && (__ffs(res_ptr[i]) < bits))
+				continue;
+
+			/* Found it, mark it */
+			for (i = 0 ; i < qwords ; i++)
+				res_ptr[i] = ~0UL;
+			res_ptr[i] |= RESMAP_MASK(bits);
+
+			pide = ((unsigned long)res_ptr - (unsigned long)ioc->res_map);
+			pide <<= 3;	/* convert to bit address */
+			res_ptr += qwords;
+			ioc->res_bitshift = bits;
+			goto found_it;
+next_ptr:
+			;
+		}
 	}
+
+not_found:
+	prefetch(ioc->res_map);
+	ioc->res_hint = (unsigned long *) ioc->res_map;
+	ioc->res_bitshift = 0;
+	return (pide);
+
+found_it:
+	ioc->res_hint = res_ptr;
 	return (pide);
 }
 
@@ -531,26 +578,67 @@
 {
 	unsigned int pages_needed = size >> iovp_shift;
 #ifdef PDIR_SEARCH_TIMING
-	unsigned long itc_start = ia64_get_itc();
+	unsigned long itc_start;
 #endif
 	unsigned long pide;
+	unsigned long flags;
 
 	ASSERT(pages_needed);
-	ASSERT(pages_needed <= BITS_PER_LONG);
 	ASSERT(0 = (size & ~iovp_mask));
 
+	spin_lock_irqsave(&ioc->res_lock, flags);
+
+#ifdef PDIR_SEARCH_TIMING
+	itc_start = ia64_get_itc();
+#endif
 	/*
 	** "seek and ye shall find"...praying never hurts either...
 	*/
-
 	pide = sba_search_bitmap(ioc, pages_needed);
-	if (pide >= (ioc->res_size << 3)) {
+	if (unlikely(pide >= (ioc->res_size << 3))) {
 		pide = sba_search_bitmap(ioc, pages_needed);
-		if (pide >= (ioc->res_size << 3))
+		if (unlikely(pide >= (ioc->res_size << 3))) {
+#if DELAYED_RESOURCE_CNT > 0
+			/*
+			** With delayed resource freeing, we can give this one more shot.  We're
+			** getting close to being in trouble here, so do what we can to make this
+			** one count.
+			*/
+			spin_lock(&ioc->saved_lock);
+			if (ioc->saved_cnt > 0) {
+				struct sba_dma_pair *d;
+				int cnt = ioc->saved_cnt;
+
+				d = &(ioc->saved[ioc->saved_cnt]);
+
+				while (cnt--) {
+					sba_mark_invalid(ioc, d->iova, d->size);
+					sba_free_range(ioc, d->iova, d->size);
+					d--;
+				}
+				ioc->saved_cnt = 0;
+				READ_REG(ioc->ioc_hpa+IOC_PCOM);	/* flush purges */
+			}
+			spin_unlock(&ioc->saved_lock);
+
+			pide = sba_search_bitmap(ioc, pages_needed);
+			if (unlikely(pide >= (ioc->res_size << 3)))
+				panic(__FILE__ ": I/O MMU @ %p is out of mapping resources\n",
+				      ioc->ioc_hpa);
+#else
 			panic(__FILE__ ": I/O MMU @ %p is out of mapping resources\n",
 			      ioc->ioc_hpa);
+#endif
+		}
 	}
 
+#ifdef PDIR_SEARCH_TIMING
+	ioc->avg_search[ioc->avg_idx++] = (ia64_get_itc() - itc_start) / pages_needed;
+	ioc->avg_idx &= SBA_SEARCH_SAMPLE - 1;
+#endif
+
+	prefetchw(&(ioc->pdir_base[pide]));
+
 #ifdef ASSERT_PDIR_SANITY
 	/* verify the first enable bit is clear */
 	if(0x00 != ((u8 *) ioc->pdir_base)[pide*PDIR_ENTRY_SIZE + 7]) {
@@ -563,10 +651,7 @@
 		(uint) ((unsigned long) ioc->res_hint - (unsigned long) ioc->res_map),
 		ioc->res_bitshift );
 
-#ifdef PDIR_SEARCH_TIMING
-	ioc->avg_search[ioc->avg_idx++] = ia64_get_itc() - itc_start;
-	ioc->avg_idx &= SBA_SEARCH_SAMPLE - 1;
-#endif
+	spin_unlock_irqrestore(&ioc->res_lock, flags);
 
 	return (pide);
 }
@@ -587,22 +672,33 @@
 	unsigned int pide = PDIR_INDEX(iovp);
 	unsigned int ridx = pide >> 3;	/* convert bit to byte address */
 	unsigned long *res_ptr = (unsigned long *) &((ioc)->res_map[ridx & ~RESMAP_IDX_MASK]);
-
 	int bits_not_wanted = size >> iovp_shift;
+	unsigned long m;
 
-	/* 3-bits "bit" address plus 2 (or 3) bits for "byte" = bit in word */
-	unsigned long m = RESMAP_MASK(bits_not_wanted) << (pide & (BITS_PER_LONG - 1));
+	for (; bits_not_wanted > 0 ; res_ptr++) {
+		
+		if (unlikely(bits_not_wanted > BITS_PER_LONG)) {
+
+			/* these mappings start 64bit aligned */
+			*res_ptr = 0UL;
+			bits_not_wanted -= BITS_PER_LONG;
+			pide += BITS_PER_LONG;
 
-	DBG_RES("%s( ,%x,%x) %x/%lx %x %p %lx\n",
-		__FUNCTION__, (uint) iova, size,
-		bits_not_wanted, m, pide, res_ptr, *res_ptr);
-
-	ASSERT(m != 0);
-	ASSERT(bits_not_wanted);
-	ASSERT((bits_not_wanted * iovp_size) <= DMA_CHUNK_SIZE);
-	ASSERT(bits_not_wanted <= BITS_PER_LONG);
-	ASSERT((*res_ptr & m) = m); /* verify same bits are set */
-	*res_ptr &= ~m;
+		} else {
+
+			/* 3-bits "bit" address plus 2 (or 3) bits for "byte" = bit in word */
+			m = RESMAP_MASK(bits_not_wanted) << (pide & (BITS_PER_LONG - 1));
+			bits_not_wanted = 0;
+
+			DBG_RES("%s( ,%x,%x) %x/%lx %x %p %lx\n", __FUNCTION__, (uint) iova, size,
+		        	bits_not_wanted, m, pide, res_ptr, *res_ptr);
+
+			ASSERT(m != 0);
+			ASSERT(bits_not_wanted);
+			ASSERT((*res_ptr & m) = m); /* verify same bits are set */
+			*res_ptr &= ~m;
+		}
+	}
 }
 
 
@@ -612,9 +708,6 @@
 *
 ***************************************************************/
 
-#define SBA_DMA_HINT(ioc, val) ((val) << (ioc)->hint_shift_pdir)
-
-
 /**
  * sba_io_pdir_entry - fill in one IO PDIR entry
  * @pdir_ptr:  pointer to IO PDIR entry
@@ -764,32 +857,36 @@
 sba_map_single(struct device *dev, void *addr, size_t size, int dir)
 {
 	struct ioc *ioc;
-	unsigned long flags;
 	dma_addr_t iovp;
 	dma_addr_t offset;
 	u64 *pdir_start;
 	int pide;
+#ifdef ASSERT_PDIR_SANITY
+	unsigned long flags;
+#endif
 #ifdef ALLOW_IOV_BYPASS
 	unsigned long pci_addr = virt_to_phys(addr);
 #endif
 
-	ioc = GET_IOC(dev);
-	ASSERT(ioc);
-
 #ifdef ALLOW_IOV_BYPASS
+	ASSERT(to_pci_dev(dev)->dma_mask);
 	/*
  	** Check if the PCI device can DMA to ptr... if so, just return ptr
  	*/
-	if (dev && dev->dma_mask && (pci_addr & ~*dev->dma_mask) = 0) {
+	if (likely((pci_addr & ~to_pci_dev(dev)->dma_mask) = 0)) {
 		/*
  		** Device is bit capable of DMA'ing to the buffer...
 		** just return the PCI address of ptr
  		*/
 		DBG_BYPASS("sba_map_single() bypass mask/addr: 0x%lx/0x%lx\n",
-		           *dev->dma_mask, pci_addr);
+		           to_pci_dev(dev)->dma_mask, pci_addr);
 		return pci_addr;
 	}
 #endif
+	ioc = GET_IOC(dev);
+	ASSERT(ioc);
+
+	prefetch(ioc->res_hint);
 
 	ASSERT(size > 0);
 	ASSERT(size <= DMA_CHUNK_SIZE);
@@ -800,13 +897,15 @@
 	/* round up to nearest iovp_size */
 	size = (size + offset + ~iovp_mask) & iovp_mask;
 
-	spin_lock_irqsave(&ioc->res_lock, flags);
 #ifdef ASSERT_PDIR_SANITY
+	spin_lock_irqsave(&ioc->res_lock, flags);
 	if (sba_check_pdir(ioc,"Check before sba_map_single()"))
 		panic("Sanity check failed");
+	spin_unlock_irqrestore(&ioc->res_lock, flags);
 #endif
 
 	pide = sba_alloc_range(ioc, size);
+
 	iovp = (dma_addr_t) pide << iovp_shift;
 
 	DBG_RUN("%s() 0x%p -> 0x%lx\n",
@@ -829,10 +928,11 @@
 
 	/* form complete address */
 #ifdef ASSERT_PDIR_SANITY
+	spin_lock_irqsave(&ioc->res_lock, flags);
 	sba_check_pdir(ioc,"Check after sba_map_single()");
-#endif
 	spin_unlock_irqrestore(&ioc->res_lock, flags);
-	return SBA_IOVA(ioc, iovp, offset, DEFAULT_DMA_HINT_REG);
+#endif
+	return SBA_IOVA(ioc, iovp, offset);
 }
 
 /**
@@ -857,7 +957,7 @@
 	ASSERT(ioc);
 
 #ifdef ALLOW_IOV_BYPASS
-	if ((iova & ioc->imask) != ioc->ibase) {
+	if (likely((iova & ioc->imask) != ioc->ibase)) {
 		/*
 		** Address does not fall w/in IOVA, must be bypassing
 		*/
@@ -880,14 +980,15 @@
 	size += offset;
 	size = ROUNDUP(size, iovp_size);
 
-	spin_lock_irqsave(&ioc->res_lock, flags);
 
 #if DELAYED_RESOURCE_CNT > 0
+	spin_lock_irqsave(&ioc->saved_lock, flags);
 	d = &(ioc->saved[ioc->saved_cnt]);
 	d->iova = iova;
 	d->size = size;
-	if (++(ioc->saved_cnt) >= DELAYED_RESOURCE_CNT) {
+	if (unlikely(++(ioc->saved_cnt) >= DELAYED_RESOURCE_CNT)) {
 		int cnt = ioc->saved_cnt;
+		spin_lock(&ioc->res_lock);
 		while (cnt--) {
 			sba_mark_invalid(ioc, d->iova, d->size);
 			sba_free_range(ioc, d->iova, d->size);
@@ -895,11 +996,15 @@
 		}
 		ioc->saved_cnt = 0;
 		READ_REG(ioc->ioc_hpa+IOC_PCOM);	/* flush purges */
+		spin_unlock(&ioc->res_lock);
 	}
+	spin_unlock_irqrestore(&ioc->saved_lock, flags);
 #else /* DELAYED_RESOURCE_CNT = 0 */
+	spin_lock_irqsave(&ioc->res_lock, flags);
 	sba_mark_invalid(ioc, iova, size);
 	sba_free_range(ioc, iova, size);
 	READ_REG(ioc->ioc_hpa+IOC_PCOM);	/* flush purges */
+	spin_unlock_irqrestore(&ioc->res_lock, flags);
 #endif /* DELAYED_RESOURCE_CNT = 0 */
 #ifdef ENABLE_MARK_CLEAN
 	if (dir = DMA_FROM_DEVICE) {
@@ -925,16 +1030,6 @@
 		}
 	}
 #endif
-	spin_unlock_irqrestore(&ioc->res_lock, flags);
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
 
 
@@ -953,18 +1048,33 @@
 	void *addr;
 
 	addr = (void *) __get_free_pages(flags, get_order(size));
-	if (!addr)
+	if (unlikely(!addr))
 		return NULL;
 
+	memset(addr, 0, size);
+	*dma_handle = virt_to_phys(addr);
+
+#ifdef ALLOW_IOV_BYPASS
+	ASSERT(to_pci_dev(dev)->consistent_dma_mask);
 	/*
-	 * REVISIT: if sba_map_single starts needing more than dma_mask from the
-	 * device, this needs to be updated.
+ 	** Check if the PCI device can DMA to ptr... if so, just return ptr
+ 	*/
+	if (likely((*dma_handle & ~to_pci_dev(dev)->consistent_dma_mask) = 0)) {
+		DBG_BYPASS("sba_alloc_coherent() bypass mask/addr: 0x%lx/0x%lx\n",
+		           to_pci_dev(dev)->consistent_dma_mask, *dma_handle);
+
+		return addr;
+	}
+#endif
+
+	/*
+	 * If device can't bypass or bypass is disabled, pass the 32bit fake
+	 * device to map single to get an iova mapping.
 	 */
 	ioc = GET_IOC(dev);
 	ASSERT(ioc);
 	*dma_handle = sba_map_single(&ioc->sac_only_dev->dev, addr, size, 0);
 
-	memset(addr, 0, size);
 	return addr;
 }
 
@@ -1232,8 +1342,10 @@
 {
 	struct ioc *ioc;
 	int coalesced, filled = 0;
+#ifdef ASSERT_PDIR_SANITY
 	unsigned long flags;
-#ifdef ALLOW_IOV_BYPASS
+#endif
+#ifdef ALLOW_IOV_BYPASS_SG
 	struct scatterlist *sg;
 #endif
 
@@ -1241,8 +1353,9 @@
 	ioc = GET_IOC(dev);
 	ASSERT(ioc);
 
-#ifdef ALLOW_IOV_BYPASS
-	if (dev && dev->dma_mask && (ioc->dma_mask & ~*dev->dma_mask) = 0) {
+#ifdef ALLOW_IOV_BYPASS_SG
+	ASSERT(to_pci_dev(dev)->dma_mask);
+	if (likely((ioc->dma_mask & ~to_pci_dev(dev)->dma_mask) = 0)) {
 		for (sg = sglist ; filled < nents ; filled++, sg++){
 			sg->dma_length = sg->length;
 			sg->dma_address = virt_to_phys(sba_sg_address(sg));
@@ -1253,21 +1366,22 @@
 	/* Fast path single entry scatterlists. */
 	if (nents = 1) {
 		sglist->dma_length = sglist->length;
-		sglist->dma_address = sba_map_single(dev, sba_sg_address(sglist), sglist->length,
-		                                     dir);
+		sglist->dma_address = sba_map_single(dev, sba_sg_address(sglist), sglist->length, dir);
 		return 1;
 	}
 
-	spin_lock_irqsave(&ioc->res_lock, flags);
-
 #ifdef ASSERT_PDIR_SANITY
+	spin_lock_irqsave(&ioc->res_lock, flags);
 	if (sba_check_pdir(ioc,"Check before sba_map_sg()"))
 	{
 		sba_dump_sg(ioc, sglist, nents);
 		panic("Check before sba_map_sg()");
 	}
+	spin_unlock_irqrestore(&ioc->res_lock, flags);
 #endif
 
+	prefetch(ioc->res_hint);
+
 	/*
 	** First coalesce the chunks and allocate I/O pdir space
 	**
@@ -1289,14 +1403,14 @@
 	filled = sba_fill_pdir(ioc, sglist, nents);
 
 #ifdef ASSERT_PDIR_SANITY
+	spin_lock_irqsave(&ioc->res_lock, flags);
 	if (sba_check_pdir(ioc,"Check after sba_map_sg()"))
 	{
 		sba_dump_sg(ioc, sglist, nents);
 		panic("Check after sba_map_sg()\n");
 	}
-#endif
-
 	spin_unlock_irqrestore(&ioc->res_lock, flags);
+#endif
 
 	ASSERT(coalesced = filled);
 	DBG_RUN_SG("%s() DONE %d mappings\n", __FUNCTION__, filled);
@@ -1316,18 +1430,18 @@
  */
 void sba_unmap_sg (struct device *dev, struct scatterlist *sglist, int nents, int dir)
 {
-	struct ioc *ioc;
 #ifdef ASSERT_PDIR_SANITY
+	struct ioc *ioc;
 	unsigned long flags;
 #endif
 
 	DBG_RUN_SG("%s() START %d entries,  %p,%x\n",
 		__FUNCTION__, nents, sba_sg_address(sglist), sglist->length);
 
+#ifdef ASSERT_PDIR_SANITY
 	ioc = GET_IOC(dev);
 	ASSERT(ioc);
 
-#ifdef ASSERT_PDIR_SANITY
 	spin_lock_irqsave(&ioc->res_lock, flags);
 	sba_check_pdir(ioc,"Check before sba_unmap_sg()");
 	spin_unlock_irqrestore(&ioc->res_lock, flags);
@@ -1478,6 +1592,9 @@
 ioc_resource_init(struct ioc *ioc)
 {
 	spin_lock_init(&ioc->res_lock);
+#if DELAYED_RESOURCE_CNT > 0
+	spin_lock_init(&ioc->saved_lock);
+#endif
 
 	/* resource map size dictated by pdir_size */
 	ioc->res_size = ioc->pdir_size / PDIR_ENTRY_SIZE; /* entries */
@@ -1689,13 +1806,13 @@
 
 	seq_printf(s, "Hewlett Packard %s IOC rev %d.%d\n",
 		ioc->name, ((ioc->rev >> 4) & 0xF), (ioc->rev & 0xF));
-	seq_printf(s, "IOVA size       : %d MB\n", ioc->iov_size/(1024*1024));
+	seq_printf(s, "IOVA size       : %ld MB\n", ((ioc->pdir_size >> 3) * iovp_size)/(1024*1024));
 	seq_printf(s, "IOVA page size  : %ld kb\n", iovp_size/1024);
 
 	for (i = 0; i < (ioc->res_size / sizeof(unsigned long)); ++i, ++res_ptr)
 		used += hweight64(*res_ptr);
 
-	seq_printf(s, "PDIR size       : %d entries\n", ioc->res_size << 3);
+	seq_printf(s, "PDIR size       : %d entries\n", ioc->pdir_size >> 3);
 	seq_printf(s, "PDIR used       : %d entries\n", used);
 
 #ifdef PDIR_SEARCH_TIMING
@@ -1708,7 +1825,7 @@
 			if (ioc->avg_search[i] < min) min = ioc->avg_search[i];
 		}
 		avg /= SBA_SEARCH_SAMPLE;
-		seq_printf(s, "Bitmap search   : %ld/%ld/%ld (min/avg/max CPU Cycles)\n",
+		seq_printf(s, "Bitmap search   : %ld/%ld/%ld (min/avg/max CPU Cycles/IOVA page)\n",
 		           min, avg, max);
 	}
 #endif



