From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 08 Mar 2005 20:34:06 +0000
Subject: [PATCH] sba_iommu bug fixes
Message-Id: <1110314047.24336.26.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   This fixes a couple of bugs in the zx1/sx1000 sba_iommu.  These are
all pretty low likelihood of hitting.  The first problem is a simple off
by one, deep in the sba_alloc_range() error path.  Surrounding that was
a lock ordering problem that could have potentially deadlocked with the
order the locks are grabbed in sba_unmap_single().  I moved the resource
locking into sba_search_bitmap() to prevent this.  Finally, there's a
potential race between unmapping pdir entries and marking incoming DMA
pages clean.  If you see any oddities, please let me know, but I've
tested it pretty thoroughly here.  Tony, please apply.  Thanks,

	Alex

BTW, many of the options in this driver not on by default are becoming
more and more broken.  I'll be working on some patches to clean them
out, but I wanted to get this bug fix out first.

-- 
Signed-off-by: Alex Williamson <alex.williamson@hp.com>

=== arch/ia64/hp/common/sba_iommu.c 1.50 vs edited ==--- 1.50/arch/ia64/hp/common/sba_iommu.c	2005-01-11 17:10:37 -07:00
+++ edited/arch/ia64/hp/common/sba_iommu.c	2005-03-08 09:23:25 -07:00
@@ -1,9 +1,9 @@
 /*
 **  IA64 System Bus Adapter (SBA) I/O MMU manager
 **
-**	(c) Copyright 2002-2004 Alex Williamson
+**	(c) Copyright 2002-2005 Alex Williamson
 **	(c) Copyright 2002-2003 Grant Grundler
-**	(c) Copyright 2002-2004 Hewlett-Packard Company
+**	(c) Copyright 2002-2005 Hewlett-Packard Company
 **
 **	Portions (c) 2000 Grant Grundler (from parisc I/O MMU code)
 **	Portions (c) 1999 Dave S. Miller (from sparc64 I/O MMU code)
@@ -458,21 +458,32 @@
  * sba_search_bitmap - find free space in IO PDIR resource bitmap
  * @ioc: IO MMU structure which owns the pdir we are interested in.
  * @bits_wanted: number of entries we need.
+ * @use_hint: use res_hint to indicate where to start looking
  *
  * Find consecutive free bits in resource bitmap.
  * Each bit represents one entry in the IO Pdir.
  * Cool perf optimization: search for log2(size) bits at a time.
  */
 static SBA_INLINE unsigned long
-sba_search_bitmap(struct ioc *ioc, unsigned long bits_wanted)
+sba_search_bitmap(struct ioc *ioc, unsigned long bits_wanted, int use_hint)
 {
-	unsigned long *res_ptr = ioc->res_hint;
+	unsigned long *res_ptr;
 	unsigned long *res_end = (unsigned long *) &(ioc->res_map[ioc->res_size]);
-	unsigned long pide = ~0UL;
+	unsigned long flags, pide = ~0UL;
 
 	ASSERT(((unsigned long) ioc->res_hint & (sizeof(unsigned long) - 1UL)) = 0);
 	ASSERT(res_ptr < res_end);
 
+	spin_lock_irqsave(&ioc->res_lock, flags);
+
+	/* Allow caller to force a search through the entire resource space */
+	if (likely(use_hint)) {
+		res_ptr = ioc->res_hint;
+	} else {
+		res_ptr = (ulong *)ioc->res_map;
+		ioc->res_bitshift = 0;
+	}
+
 	/*
 	 * N.B.  REO/Grande defect AR2305 can cause TLB fetch timeouts
 	 * if a TLB entry is purged while in use.  sba_mark_invalid()
@@ -569,10 +580,12 @@
 	prefetch(ioc->res_map);
 	ioc->res_hint = (unsigned long *) ioc->res_map;
 	ioc->res_bitshift = 0;
+	spin_unlock_irqrestore(&ioc->res_lock, flags);
 	return (pide);
 
 found_it:
 	ioc->res_hint = res_ptr;
+	spin_unlock_irqrestore(&ioc->res_lock, flags);
 	return (pide);
 }
 
@@ -593,36 +606,36 @@
 	unsigned long itc_start;
 #endif
 	unsigned long pide;
-	unsigned long flags;
 
 	ASSERT(pages_needed);
 	ASSERT(0 = (size & ~iovp_mask));
 
-	spin_lock_irqsave(&ioc->res_lock, flags);
-
 #ifdef PDIR_SEARCH_TIMING
 	itc_start = ia64_get_itc();
 #endif
 	/*
 	** "seek and ye shall find"...praying never hurts either...
 	*/
-	pide = sba_search_bitmap(ioc, pages_needed);
+	pide = sba_search_bitmap(ioc, pages_needed, 1);
 	if (unlikely(pide >= (ioc->res_size << 3))) {
-		pide = sba_search_bitmap(ioc, pages_needed);
+		pide = sba_search_bitmap(ioc, pages_needed, 0);
 		if (unlikely(pide >= (ioc->res_size << 3))) {
 #if DELAYED_RESOURCE_CNT > 0
+			unsigned long flags;
+
 			/*
 			** With delayed resource freeing, we can give this one more shot.  We're
 			** getting close to being in trouble here, so do what we can to make this
 			** one count.
 			*/
-			spin_lock(&ioc->saved_lock);
+			spin_lock_irqsave(&ioc->saved_lock, flags);
 			if (ioc->saved_cnt > 0) {
 				struct sba_dma_pair *d;
 				int cnt = ioc->saved_cnt;
 
-				d = &(ioc->saved[ioc->saved_cnt]);
+				d = &(ioc->saved[ioc->saved_cnt - 1]);
 
+				spin_lock(&ioc->res_lock);
 				while (cnt--) {
 					sba_mark_invalid(ioc, d->iova, d->size);
 					sba_free_range(ioc, d->iova, d->size);
@@ -630,10 +643,11 @@
 				}
 				ioc->saved_cnt = 0;
 				READ_REG(ioc->ioc_hpa+IOC_PCOM);	/* flush purges */
+				spin_unlock(&ioc->res_lock);
 			}
-			spin_unlock(&ioc->saved_lock);
+			spin_unlock_irqrestore(&ioc->saved_lock, flags);
 
-			pide = sba_search_bitmap(ioc, pages_needed);
+			pide = sba_search_bitmap(ioc, pages_needed, 0);
 			if (unlikely(pide >= (ioc->res_size << 3)))
 				panic(__FILE__ ": I/O MMU @ %p is out of mapping resources\n",
 				      ioc->ioc_hpa);
@@ -663,8 +677,6 @@
 		(uint) ((unsigned long) ioc->res_hint - (unsigned long) ioc->res_map),
 		ioc->res_bitshift );
 
-	spin_unlock_irqrestore(&ioc->res_lock, flags);
-
 	return (pide);
 }
 
@@ -949,6 +961,30 @@
 	return SBA_IOVA(ioc, iovp, offset);
 }
 
+#ifdef ENABLE_MARK_CLEAN
+static SBA_INLINE void
+sba_mark_clean(struct ioc *ioc, dma_addr_t iova, size_t size)
+{
+	u32	iovp = (u32) SBA_IOVP(ioc,iova);
+	int	off = PDIR_INDEX(iovp);
+	void	*addr;
+
+	if (size <= iovp_size) {
+		addr = phys_to_virt(ioc->pdir_base[off] &
+		                    ~0xE000000000000FFFULL);
+		mark_clean(addr, size);
+	} else {
+		do {
+			addr = phys_to_virt(ioc->pdir_base[off] &
+			                    ~0xE000000000000FFFULL);
+			mark_clean(addr, min(size, iovp_size));
+			off++;
+			size -= iovp_size;
+		} while (size > 0);
+	}
+}
+#endif
+
 /**
  * sba_unmap_single - unmap one IOVA and free resources
  * @dev: instance of PCI owned by the driver that's asking.
@@ -994,6 +1030,10 @@
 	size += offset;
 	size = ROUNDUP(size, iovp_size);
 
+#ifdef ENABLE_MARK_CLEAN
+	if (dir = DMA_FROM_DEVICE)
+		sba_mark_clean(ioc, iova, size);
+#endif
 
 #if DELAYED_RESOURCE_CNT > 0
 	spin_lock_irqsave(&ioc->saved_lock, flags);
@@ -1020,30 +1060,6 @@
 	READ_REG(ioc->ioc_hpa+IOC_PCOM);	/* flush purges */
 	spin_unlock_irqrestore(&ioc->res_lock, flags);
 #endif /* DELAYED_RESOURCE_CNT = 0 */
-#ifdef ENABLE_MARK_CLEAN
-	if (dir = DMA_FROM_DEVICE) {
-		u32 iovp = (u32) SBA_IOVP(ioc,iova);
-		int off = PDIR_INDEX(iovp);
-		void *addr;
-
-		if (size <= iovp_size) {
-			addr = phys_to_virt(ioc->pdir_base[off] &
-					    ~0xE000000000000FFFULL);
-			mark_clean(addr, size);
-		} else {
-			size_t byte_cnt = size;
-
-			do {
-				addr = phys_to_virt(ioc->pdir_base[off] &
-				                    ~0xE000000000000FFFULL);
-				mark_clean(addr, min(byte_cnt, iovp_size));
-				off++;
-				byte_cnt -= iovp_size;
-
-			   } while (byte_cnt > 0);
-		}
-	}
-#endif
 }
 
 


