From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 12 Jan 2004 23:53:37 +0000
Subject: Re: [PATCH] sba_iommu update (2.6 version)
Message-Id: <1073951617.6497.141.camel@patsy.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1073938588.6497.56.camel@patsy.fc.hp.com>
In-Reply-To: <1073938588.6497.56.camel@patsy.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2004-01-12 at 14:26, David Mosberger wrote:
> 
> Please avoid inline-asm and use the corresponding intrinsic instead
> (ia64_getf_exp(), in this particular case) so that the Intel compiler
> remains usable.
> 

   Oops, I overlooked that.  Fixed below.

> Also, looking at it, I suspect we'd be better off using "long double"
> instead of "double" to avoid problems with huge values (yeah, probably
> doesn't make a difference in practice, but we should avoid propagating
> potentially-buggy code; I see get_order() has the same
> problem---apparently only ia64_fls() got fixed).
> 

   Fixed for this chunk of code.

>   Alex> +sba_page_override(char *str)
> 
> Wouldn't it be cleaner to use lib/cmdline.c:memparse() here?

   Yes, much cleaner.  Thanks for the suggestions.  New patch below, let
me know if you spot anything else.  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

=== arch/ia64/hp/common/sba_iommu.c 1.33 vs edited ==--- 1.33/arch/ia64/hp/common/sba_iommu.c	Fri Sep 19 09:03:40 2003
+++ edited/arch/ia64/hp/common/sba_iommu.c	Mon Jan 12 16:02:23 2004
@@ -1,9 +1,9 @@
 /*
 **  IA64 System Bus Adapter (SBA) I/O MMU manager
 **
-**	(c) Copyright 2002-2003 Alex Williamson
+**	(c) Copyright 2002-2004 Alex Williamson
 **	(c) Copyright 2002-2003 Grant Grundler
-**	(c) Copyright 2002-2003 Hewlett-Packard Company
+**	(c) Copyright 2002-2004 Hewlett-Packard Company
 **
 **	Portions (c) 2000 Grant Grundler (from parisc I/O MMU code)
 **	Portions (c) 1999 Dave S. Miller (from sparc64 I/O MMU code)
@@ -39,12 +39,19 @@
 #include <asm/page.h>		/* PAGE_OFFSET */
 #include <asm/dma.h>
 #include <asm/system.h>		/* wmb() */
+#include <asm/bitops.h>		/* hweight64() */
 
 #include <asm/acpi-ext.h>
 
 #define PFX "IOC: "
 
 /*
+** Enabling timing search of the pdir resource map.  Output in /proc.
+** Disabled by default to optimize performance.
+*/
+#undef PDIR_SEARCH_TIMING
+
+/*
 ** This option allows cards capable of 64bit DMA to bypass the IOMMU.  If
 ** not defined, all DMA will be 32bit and go through the TLB.
 ** There's potentially a conflict in the bio merge code with us
@@ -54,11 +61,6 @@
 */
 #define ALLOW_IOV_BYPASS
 
-#ifdef CONFIG_PROC_FS
-  /* turn it off for now; without per-CPU counters, it's too much of a scalability bottleneck: */
-# define SBA_PROC_FS 0
-#endif
-
 /*
 ** If a device prefetches beyond the end of a valid pdir entry, it will cause
 ** a hard failure, ie. MCA.  Version 3.0 and later of the zx1 LBA should
@@ -160,21 +162,18 @@
 #define ZX1_SBA_IOMMU_COOKIE	0x0000badbadc0ffeeUL
 
 /*
-** IOC supports 4/8/16/64KB page sizes (see TCNFG register)
-** It's safer (avoid memory corruption) to keep DMA page mappings
-** equivalently sized to VM PAGE_SIZE.
+** The zx1 IOC supports 4/8/16/64KB page sizes (see TCNFG register)
 **
-** We really can't avoid generating a new mapping for each
-** page since the Virtual Coherence Index has to be generated
-** and updated for each page.
+** Some IOCs (sx1000) can run at the above pages sizes, but are
+** really only supported using the IOC at a 4k page size.
 **
-** IOVP_SIZE could only be greater than PAGE_SIZE if we are
+** iovp_size could only be greater than PAGE_SIZE if we are
 ** confident the drivers really only touch the next physical
 ** page iff that driver instance owns it.
 */
-#define IOVP_SIZE	PAGE_SIZE
-#define IOVP_SHIFT	PAGE_SHIFT
-#define IOVP_MASK	PAGE_MASK
+static unsigned long iovp_size;
+static unsigned long iovp_shift;
+static unsigned long iovp_mask;
 
 struct ioc {
 	void		*ioc_hpa;	/* I/O MMU base address */
@@ -198,24 +197,10 @@
 	} saved[DELAYED_RESOURCE_CNT];
 #endif
 
-#if SBA_PROC_FS
+#ifdef PDIR_SEARCH_TIMING
 #define SBA_SEARCH_SAMPLE	0x100
 	unsigned long avg_search[SBA_SEARCH_SAMPLE];
 	unsigned long avg_idx;	/* current index into avg_search */
-	unsigned long used_pages;
-	unsigned long msingle_calls;
-	unsigned long msingle_pages;
-	unsigned long msg_calls;
-	unsigned long msg_pages;
-	unsigned long usingle_calls;
-	unsigned long usingle_pages;
-	unsigned long usg_calls;
-	unsigned long usg_pages;
-#ifdef ALLOW_IOV_BYPASS
-	unsigned long msingle_bypass;
-	unsigned long usingle_bypass;
-	unsigned long msg_bypass;
-#endif
 #endif
 
 	/* Stuff we don't need in performance path */
@@ -252,7 +237,7 @@
 ** rather than the HW. I/O MMU allocation alogorithms can be
 ** faster with smaller size is (to some degree).
 */
-#define DMA_CHUNK_SIZE  (BITS_PER_LONG*PAGE_SIZE)
+#define DMA_CHUNK_SIZE  (BITS_PER_LONG*iovp_size)
 
 #define ROUNDUP(x,y) ((x + ((y)-1)) & ~((y)-1))
 
@@ -416,18 +401,37 @@
 #define PAGES_PER_RANGE 1	/* could increase this to 4 or 8 if needed */
 
 /* Convert from IOVP to IOVA and vice versa. */
-#define SBA_IOVA(ioc,iovp,offset,hint_reg) ((ioc->ibase) | (iovp) | (offset) |		\
-					    ((hint_reg)<<(ioc->hint_shift_pdir)))
-#define SBA_IOVP(ioc,iova) (((iova) & ioc->hint_mask_pdir) & ~(ioc->ibase))
+#define SBA_IOVA(ioc,iovp,offset,hint_reg) ((ioc->ibase) | (iovp) | (offset))
+#define SBA_IOVP(ioc,iova) ((iova) & ~(ioc->ibase))
 
-/* FIXME : review these macros to verify correctness and usage */
-#define PDIR_INDEX(iovp)   ((iovp)>>IOVP_SHIFT)
+#define PDIR_ENTRY_SIZE	sizeof(u64)
+
+#define PDIR_INDEX(iovp)   ((iovp)>>iovp_shift)
 
 #define RESMAP_MASK(n)    ~(~0UL << (n))
 #define RESMAP_IDX_MASK   (sizeof(unsigned long) - 1)
 
 
 /**
+ * For most cases the normal get_order is sufficient, however it limits us
+ * to PAGE_SIZE being the minimum mapping alignment and TC flush granularity.
+ * It only incurs about 1 clock cycle to use this one with the static variable
+ * and makes the code more intuitive.
+ */
+static SBA_INLINE int
+get_iovp_order (unsigned long size)
+{
+	long double d = size - 1;
+	long order;
+
+	order = ia64_getf_exp(d);
+	order = order - iovp_shift - 0xffff + 1;
+	if (order < 0)
+		order = 0;
+	return order;
+}
+
+/**
  * sba_search_bitmap - find free space in IO PDIR resource bitmap
  * @ioc: IO MMU structure which owns the pdir we are interested in.
  * @bits_wanted: number of entries we need.
@@ -465,7 +469,7 @@
 		** We need the alignment to invalidate I/O TLB using
 		** SBA HW features in the unmap path.
 		*/
-		unsigned long o = 1 << get_order(bits_wanted << PAGE_SHIFT);
+		unsigned long o = 1 << get_iovp_order(bits_wanted << iovp_shift);
 		uint bitshiftcnt = ROUNDUP(ioc->res_bitshift, o);
 		unsigned long mask;
 
@@ -521,16 +525,15 @@
 static int
 sba_alloc_range(struct ioc *ioc, size_t size)
 {
-	unsigned int pages_needed = size >> IOVP_SHIFT;
-#if SBA_PROC_FS
+	unsigned int pages_needed = size >> iovp_shift;
+#ifdef PDIR_SEARCH_TIMING
 	unsigned long itc_start = ia64_get_itc();
 #endif
 	unsigned long pide;
 
 	ASSERT(pages_needed);
-	ASSERT((pages_needed * IOVP_SIZE) <= DMA_CHUNK_SIZE);
 	ASSERT(pages_needed <= BITS_PER_LONG);
-	ASSERT(0 = (size & ~IOVP_MASK));
+	ASSERT(0 = (size & ~iovp_mask));
 
 	/*
 	** "seek and ye shall find"...praying never hurts either...
@@ -546,7 +549,7 @@
 
 #ifdef ASSERT_PDIR_SANITY
 	/* verify the first enable bit is clear */
-	if(0x00 != ((u8 *) ioc->pdir_base)[pide*sizeof(u64) + 7]) {
+	if(0x00 != ((u8 *) ioc->pdir_base)[pide*PDIR_ENTRY_SIZE + 7]) {
 		sba_dump_pdir_entry(ioc, "sba_search_bitmap() botched it?", pide);
 	}
 #endif
@@ -556,17 +559,9 @@
 		(uint) ((unsigned long) ioc->res_hint - (unsigned long) ioc->res_map),
 		ioc->res_bitshift );
 
-#if SBA_PROC_FS
-	{
-		unsigned long itc_end = ia64_get_itc();
-		unsigned long tmp = itc_end - itc_start;
-		/* check for roll over */
-		itc_start = (itc_end < itc_start) ?  -(tmp) : (tmp);
-	}
-	ioc->avg_search[ioc->avg_idx++] = itc_start;
+#ifdef PDIR_SEARCH_TIMING
+	ioc->avg_search[ioc->avg_idx++] = ia64_get_itc() - itc_start;
 	ioc->avg_idx &= SBA_SEARCH_SAMPLE - 1;
-
-	ioc->used_pages += pages_needed;
 #endif
 
 	return (pide);
@@ -589,7 +584,7 @@
 	unsigned int ridx = pide >> 3;	/* convert bit to byte address */
 	unsigned long *res_ptr = (unsigned long *) &((ioc)->res_map[ridx & ~RESMAP_IDX_MASK]);
 
-	int bits_not_wanted = size >> IOVP_SHIFT;
+	int bits_not_wanted = size >> iovp_shift;
 
 	/* 3-bits "bit" address plus 2 (or 3) bits for "byte" = bit in word */
 	unsigned long m = RESMAP_MASK(bits_not_wanted) << (pide & (BITS_PER_LONG - 1));
@@ -598,13 +593,9 @@
 		__FUNCTION__, (uint) iova, size,
 		bits_not_wanted, m, pide, res_ptr, *res_ptr);
 
-#if SBA_PROC_FS
-	ioc->used_pages -= bits_not_wanted;
-#endif
-
 	ASSERT(m != 0);
 	ASSERT(bits_not_wanted);
-	ASSERT((bits_not_wanted * IOVP_SIZE) <= DMA_CHUNK_SIZE);
+	ASSERT((bits_not_wanted * iovp_size) <= DMA_CHUNK_SIZE);
 	ASSERT(bits_not_wanted <= BITS_PER_LONG);
 	ASSERT((*res_ptr & m) = m); /* verify same bits are set */
 	*res_ptr &= ~m;
@@ -702,7 +693,7 @@
 
 	/* Must be non-zero and rounded up */
 	ASSERT(byte_cnt > 0);
-	ASSERT(0 = (byte_cnt & ~IOVP_MASK));
+	ASSERT(0 = (byte_cnt & ~iovp_mask));
 
 #ifdef ASSERT_PDIR_SANITY
 	/* Assert first pdir entry is set */
@@ -711,11 +702,11 @@
 	}
 #endif
 
-	if (byte_cnt <= IOVP_SIZE)
+	if (byte_cnt <= iovp_size)
 	{
 		ASSERT(off < ioc->pdir_size);
 
-		iovp |= IOVP_SHIFT;     /* set "size" field for PCOM */
+		iovp |= iovp_shift;     /* set "size" field for PCOM */
 
 #ifndef FULL_VALID_PDIR
 		/*
@@ -734,7 +725,7 @@
 		ioc->pdir_base[off] = (0x80000000000000FFULL | prefetch_spill_page);
 #endif
 	} else {
-		u32 t = get_order(byte_cnt) + PAGE_SHIFT;
+		u32 t = get_iovp_order(byte_cnt) + iovp_shift;
 
 		iovp |= t;
 		ASSERT(t <= 31);   /* 2GB! Max value of "size" field */
@@ -749,7 +740,7 @@
 			ioc->pdir_base[off] = (0x80000000000000FFULL | prefetch_spill_page);
 #endif
 			off++;
-			byte_cnt -= IOVP_SIZE;
+			byte_cnt -= iovp_size;
 		} while (byte_cnt > 0);
 	}
 
@@ -790,11 +781,6 @@
  		** Device is bit capable of DMA'ing to the buffer...
 		** just return the PCI address of ptr
  		*/
-#if SBA_PROC_FS
-		spin_lock_irqsave(&ioc->res_lock, flags);
-		ioc->msingle_bypass++;
-		spin_unlock_irqrestore(&ioc->res_lock, flags);
-#endif
 		DBG_BYPASS("sba_map_single() bypass mask/addr: 0x%lx/0x%lx\n",
 		           *dev->dma_mask, pci_addr);
 		return pci_addr;
@@ -805,10 +791,10 @@
 	ASSERT(size <= DMA_CHUNK_SIZE);
 
 	/* save offset bits */
-	offset = ((dma_addr_t) (long) addr) & ~IOVP_MASK;
+	offset = ((dma_addr_t) (long) addr) & ~iovp_mask;
 
-	/* round up to nearest IOVP_SIZE */
-	size = (size + offset + ~IOVP_MASK) & IOVP_MASK;
+	/* round up to nearest iovp_size */
+	size = (size + offset + ~iovp_mask) & iovp_mask;
 
 	spin_lock_irqsave(&ioc->res_lock, flags);
 #ifdef ASSERT_PDIR_SANITY
@@ -816,12 +802,8 @@
 		panic("Sanity check failed");
 #endif
 
-#if SBA_PROC_FS
-	ioc->msingle_calls++;
-	ioc->msingle_pages += size >> IOVP_SHIFT;
-#endif
 	pide = sba_alloc_range(ioc, size);
-	iovp = (dma_addr_t) pide << IOVP_SHIFT;
+	iovp = (dma_addr_t) pide << iovp_shift;
 
 	DBG_RUN("%s() 0x%p -> 0x%lx\n",
 		__FUNCTION__, addr, (long) iovp | offset);
@@ -834,8 +816,8 @@
 
 		DBG_RUN("     pdir 0x%p %lx\n", pdir_start, *pdir_start);
 
-		addr += IOVP_SIZE;
-		size -= IOVP_SIZE;
+		addr += iovp_size;
+		size -= iovp_size;
 		pdir_start++;
 	}
 	/* force pdir update */
@@ -875,11 +857,6 @@
 		/*
 		** Address does not fall w/in IOVA, must be bypassing
 		*/
-#if SBA_PROC_FS
-		spin_lock_irqsave(&ioc->res_lock, flags);
-		ioc->usingle_bypass++;
-		spin_unlock_irqrestore(&ioc->res_lock, flags);
-#endif
 		DBG_BYPASS("sba_unmap_single() bypass addr: 0x%lx\n", iova);
 
 #ifdef ENABLE_MARK_CLEAN
@@ -890,20 +867,16 @@
 		return;
 	}
 #endif
-	offset = iova & ~IOVP_MASK;
+	offset = iova & ~iovp_mask;
 
 	DBG_RUN("%s() iovp 0x%lx/%x\n",
 		__FUNCTION__, (long) iova, size);
 
 	iova ^= offset;        /* clear offset bits */
 	size += offset;
-	size = ROUNDUP(size, IOVP_SIZE);
+	size = ROUNDUP(size, iovp_size);
 
 	spin_lock_irqsave(&ioc->res_lock, flags);
-#if SBA_PROC_FS
-	ioc->usingle_calls++;
-	ioc->usingle_pages += size >> IOVP_SHIFT;
-#endif
 
 #if DELAYED_RESOURCE_CNT > 0
 	d = &(ioc->saved[ioc->saved_cnt]);
@@ -930,7 +903,7 @@
 		int off = PDIR_INDEX(iovp);
 		void *addr;
 
-		if (size <= IOVP_SIZE) {
+		if (size <= iovp_size) {
 			addr = phys_to_virt(ioc->pdir_base[off] &
 					    ~0xE000000000000FFFULL);
 			mark_clean(addr, size);
@@ -940,9 +913,9 @@
 			do {
 				addr = phys_to_virt(ioc->pdir_base[off] &
 				                    ~0xE000000000000FFFULL);
-				mark_clean(addr, min(byte_cnt, IOVP_SIZE));
+				mark_clean(addr, min(byte_cnt, iovp_size));
 				off++;
-				byte_cnt -= IOVP_SIZE;
+				byte_cnt -= iovp_size;
 
 			   } while (byte_cnt > 0);
 		}
@@ -1061,11 +1034,11 @@
 		*/
 		if (startsg->dma_address & PIDE_FLAG) {
 			u32 pide = startsg->dma_address & ~PIDE_FLAG;
-			dma_offset = (unsigned long) pide & ~IOVP_MASK;
+			dma_offset = (unsigned long) pide & ~iovp_mask;
 			startsg->dma_address = 0;
 			dma_sg++;
 			dma_sg->dma_address = pide | ioc->ibase;
-			pdirp = &(ioc->pdir_base[pide >> IOVP_SHIFT]);
+			pdirp = &(ioc->pdir_base[pide >> iovp_shift]);
 			n_mappings++;
 		}
 
@@ -1082,14 +1055,11 @@
 			dma_sg->dma_length += cnt;
 			cnt += dma_offset;
 			dma_offset=0;	/* only want offset on first chunk */
-			cnt = ROUNDUP(cnt, IOVP_SIZE);
-#if SBA_PROC_FS
-			ioc->msg_pages += cnt >> IOVP_SHIFT;
-#endif
+			cnt = ROUNDUP(cnt, iovp_size);
 			do {
 				sba_io_pdir_entry(pdirp, vaddr);
-				vaddr += IOVP_SIZE;
-				cnt -= IOVP_SIZE;
+				vaddr += iovp_size;
+				cnt -= iovp_size;
 				pdirp++;
 			} while (cnt > 0);
 		}
@@ -1107,12 +1077,12 @@
 
 /*
 ** Two address ranges are DMA contiguous *iff* "end of prev" and
-** "start of next" are both on a page boundry.
+** "start of next" are both on an IOV page boundary.
 **
 ** (shift left is a quick trick to mask off upper bits)
 */
 #define DMA_CONTIG(__X, __Y) \
-	(((((unsigned long) __X) | ((unsigned long) __Y)) << (BITS_PER_LONG - PAGE_SHIFT)) = 0UL)
+	(((((unsigned long) __X) | ((unsigned long) __Y)) << (BITS_PER_LONG - iovp_shift)) = 0UL)
 
 
 /**
@@ -1150,7 +1120,7 @@
 		dma_sg = vcontig_sg = startsg;
 		dma_len = vcontig_len = vcontig_end = startsg->length;
 		vcontig_end +=  vaddr;
-		dma_offset = vaddr & ~IOVP_MASK;
+		dma_offset = vaddr & ~iovp_mask;
 
 		/* PARANOID: clear entries */
 		startsg->dma_address = startsg->dma_length = 0;
@@ -1175,7 +1145,7 @@
 			** exceed DMA_CHUNK_SIZE if we coalesce the
 			** next entry.
 			*/
-			if (((dma_len + dma_offset + startsg->length + ~IOVP_MASK) & IOVP_MASK)
+			if (((dma_len + dma_offset + startsg->length + ~iovp_mask) & iovp_mask)
 			    > DMA_CHUNK_SIZE)
 				break;
 
@@ -1194,7 +1164,7 @@
 			}
 
 #ifdef DEBUG_LARGE_SG_ENTRIES
-			dump_run_sg = (vcontig_len > IOVP_SIZE);
+			dump_run_sg = (vcontig_len > iovp_size);
 #endif
 
 			/*
@@ -1233,10 +1203,10 @@
 		** Allocate space for DMA stream.
 		*/
 		vcontig_sg->dma_length = vcontig_len;
-		dma_len = (dma_len + dma_offset + ~IOVP_MASK) & IOVP_MASK;
+		dma_len = (dma_len + dma_offset + ~iovp_mask) & iovp_mask;
 		ASSERT(dma_len <= DMA_CHUNK_SIZE);
 		dma_sg->dma_address = (dma_addr_t) (PIDE_FLAG
-			| (sba_alloc_range(ioc, dma_len) << IOVP_SHIFT)
+			| (sba_alloc_range(ioc, dma_len) << iovp_shift)
 			| dma_offset);
 		n_mappings++;
 	}
@@ -1273,11 +1243,6 @@
 			sg->dma_length = sg->length;
 			sg->dma_address = virt_to_phys(sba_sg_address(sg));
 		}
-#if SBA_PROC_FS
-		spin_lock_irqsave(&ioc->res_lock, flags);
-		ioc->msg_bypass++;
-		spin_unlock_irqrestore(&ioc->res_lock, flags);
-#endif
 		return filled;
 	}
 #endif
@@ -1285,13 +1250,7 @@
 	if (nents = 1) {
 		sglist->dma_length = sglist->length;
 		sglist->dma_address = sba_map_single(dev, sba_sg_address(sglist), sglist->length,
-						     dir);
-#if SBA_PROC_FS
-		/*
-		** Should probably do some stats counting, but trying to
-		** be precise quickly starts wasting CPU time.
-		*/
-#endif
+		                                     dir);
 		return 1;
 	}
 
@@ -1305,10 +1264,6 @@
 	}
 #endif
 
-#if SBA_PROC_FS
-	ioc->msg_calls++;
-#endif
-
 	/*
 	** First coalesce the chunks and allocate I/O pdir space
 	**
@@ -1368,10 +1323,6 @@
 	ioc = GET_IOC(dev);
 	ASSERT(ioc);
 
-#if SBA_PROC_FS
-	ioc->usg_calls++;
-#endif
-
 #ifdef ASSERT_PDIR_SANITY
 	spin_lock_irqsave(&ioc->res_lock, flags);
 	sba_check_pdir(ioc,"Check before sba_unmap_sg()");
@@ -1381,16 +1332,6 @@
 	while (nents && sglist->dma_length) {
 
 		sba_unmap_single(dev, sglist->dma_address, sglist->dma_length, dir);
-#if SBA_PROC_FS
-		/*
-		** This leaves inconsistent data in the stats, but we can't
-		** tell which sg lists were mapped by map_single and which
-		** were coalesced to a single entry.  The stats are fun,
-		** but speed is more important.
-		*/
-		ioc->usg_pages += ((sglist->dma_address & ~IOVP_MASK) + sglist->dma_length
-				   + IOVP_SIZE - 1) >> PAGE_SHIFT;
-#endif
 		sglist++;
 		nents--;
 	}
@@ -1414,8 +1355,7 @@
 static void __init
 ioc_iova_init(struct ioc *ioc)
 {
-	u32 iova_space_mask;
-	int iov_order, tcnfg;
+	int tcnfg;
 	int agp_found = 0;
 	struct pci_dev *device = NULL;
 #ifdef FULL_VALID_PDIR
@@ -1428,23 +1368,27 @@
 	** IBASE and IMASK registers.
 	*/
 	ioc->ibase = READ_REG(ioc->ioc_hpa + IOC_IBASE) & ~0x1UL;
-	ioc->iov_size = ~(READ_REG(ioc->ioc_hpa + IOC_IMASK) & 0xFFFFFFFFUL) + 1;
+	ioc->imask = READ_REG(ioc->ioc_hpa + IOC_IMASK) | 0xFFFFFFFF00000000UL;
 
-	/*
-	** iov_order is always based on a 1GB IOVA space since we want to
-	** turn on the other half for AGP GART.
-	*/
-	iov_order = get_order(ioc->iov_size >> (IOVP_SHIFT - PAGE_SHIFT));
-	ioc->pdir_size = (ioc->iov_size / IOVP_SIZE) * sizeof(u64);
+	ioc->iov_size = ~ioc->imask + 1;
 
-	DBG_INIT("%s() hpa %p IOV %dMB (%d bits) PDIR size 0x%x\n",
-		 __FUNCTION__, ioc->ioc_hpa, ioc->iov_size >> 20,
-		 iov_order + PAGE_SHIFT, ioc->pdir_size);
-
-	/* FIXME : DMA HINTs not used */
-	ioc->hint_shift_pdir = iov_order + PAGE_SHIFT;
-	ioc->hint_mask_pdir = ~(0x3 << (iov_order + PAGE_SHIFT));
+	DBG_INIT("%s() hpa %p IOV base 0x%lx mask 0x%lx (%dMB)\n",
+		__FUNCTION__, ioc->ioc_hpa, ioc->ibase, ioc->imask,
+		ioc->iov_size >> 20);
+
+	switch (iovp_size) {
+		case  4*1024: tcnfg = 0; break;
+		case  8*1024: tcnfg = 1; break;
+		case 16*1024: tcnfg = 2; break;
+		case 64*1024: tcnfg = 3; break;
+		default:
+			panic(PFX "Unsupported IOTLB page size %ldK",
+				iovp_size >> 10);
+			break;
+	}
+	WRITE_REG(tcnfg, ioc->ioc_hpa + IOC_TCNFG);
 
+	ioc->pdir_size = (ioc->iov_size / iovp_size) * PDIR_ENTRY_SIZE;
 	ioc->pdir_base = (void *) __get_free_pages(GFP_KERNEL,
 						   get_order(ioc->pdir_size));
 	if (!ioc->pdir_base)
@@ -1452,61 +1396,12 @@
 
 	memset(ioc->pdir_base, 0, ioc->pdir_size);
 
-	DBG_INIT("%s() pdir %p size %x hint_shift_pdir %x hint_mask_pdir %lx\n",
-		__FUNCTION__, ioc->pdir_base, ioc->pdir_size,
-		ioc->hint_shift_pdir, ioc->hint_mask_pdir);
+	DBG_INIT("%s() IOV page size %ldK pdir %p size %x\n", __FUNCTION__,
+		iovp_size >> 10, ioc->pdir_base, ioc->pdir_size);
 
-	ASSERT((((unsigned long) ioc->pdir_base) & PAGE_MASK) = (unsigned long) ioc->pdir_base);
+	ASSERT(ALIGN((unsigned long) ioc->pdir_base, 4*1024) = (unsigned long) ioc->pdir_base);
 	WRITE_REG(virt_to_phys(ioc->pdir_base), ioc->ioc_hpa + IOC_PDIR_BASE);
 
-	DBG_INIT(" base %p\n", ioc->pdir_base);
-
-	/* build IMASK for IOC and Elroy */
-	iova_space_mask =  0xffffffff;
-	iova_space_mask <<= (iov_order + PAGE_SHIFT);
-	ioc->imask = iova_space_mask;
-
-	DBG_INIT("%s() IOV base 0x%lx mask 0x%0lx\n",
-		__FUNCTION__, ioc->ibase, ioc->imask);
-
-	/*
-	** FIXME: Hint registers are programmed with default hint
-	** values during boot, so hints should be sane even if we
-	** can't reprogram them the way drivers want.
-	*/
-	WRITE_REG(ioc->imask, ioc->ioc_hpa + IOC_IMASK);
-
-	/*
-	** Setting the upper bits makes checking for bypass addresses
-	** a little faster later on.
-	*/
-	ioc->imask |= 0xFFFFFFFF00000000UL;
-
-	/* Set I/O PDIR Page size to system page size */
-	switch (PAGE_SHIFT) {
-		case 12: tcnfg = 0; break;	/*  4K */
-		case 13: tcnfg = 1; break;	/*  8K */
-		case 14: tcnfg = 2; break;	/* 16K */
-		case 16: tcnfg = 3; break;	/* 64K */
-		default:
-			panic(PFX "Unsupported system page size %d",
-				1 << PAGE_SHIFT);
-			break;
-	}
-	WRITE_REG(tcnfg, ioc->ioc_hpa + IOC_TCNFG);
-
-	/*
-	** Program the IOC's ibase and enable IOVA translation
-	** Bit zero = enable bit.
-	*/
-	WRITE_REG(ioc->ibase | 1, ioc->ioc_hpa + IOC_IBASE);
-
-	/*
-	** Clear I/O TLB of any possible entries.
-	** (Yes. This is a bit paranoid...but so what)
-	*/
-	WRITE_REG(ioc->ibase | (iov_order+PAGE_SHIFT), ioc->ioc_hpa + IOC_PCOM);
-
 	/*
 	** If an AGP device is present, only use half of the IOV space
 	** for PCI DMA.  Unfortunately we can't know ahead of time
@@ -1534,12 +1429,12 @@
 		int poison_size = 16;
 		void *poison_addr, *addr;
 
-		addr = (void *)__get_free_pages(GFP_KERNEL, get_order(IOVP_SIZE));
+		addr = (void *)__get_free_pages(GFP_KERNEL, get_order(iovp_size));
 		if (!addr)
 			panic(PFX "Couldn't allocate PDIR spill page\n");
 
 		poison_addr = addr;
-		for ( ; (u64) poison_addr < addr + IOVP_SIZE; poison_addr += poison_size)
+		for ( ; (u64) poison_addr < addr + iovp_size; poison_addr += poison_size)
 			memcpy(poison_addr, spill_poison, poison_size);
 
 		prefetch_spill_page = virt_to_phys(addr);
@@ -1549,10 +1444,17 @@
 	/*
   	** Set all the PDIR entries valid w/ the spill page as the target
 	*/
-	for (index = 0 ; index < (ioc->pdir_size / sizeof(u64)) ; index++)
+	for (index = 0 ; index < (ioc->pdir_size / PDIR_ENTRY_SIZE) ; index++)
 		((u64 *)ioc->pdir_base)[index] = (0x80000000000000FF | prefetch_spill_page);
 #endif
 
+	/* Clear I/O TLB of any possible entries */
+	WRITE_REG(ioc->ibase | (get_iovp_order(ioc->iov_size) + iovp_shift), ioc->ioc_hpa + IOC_PCOM);
+	READ_REG(ioc->ioc_hpa + IOC_PCOM);
+
+	/* Enable IOVA translation */
+	WRITE_REG(ioc->ibase | 1, ioc->ioc_hpa + IOC_IBASE);
+	READ_REG(ioc->ioc_hpa + IOC_IBASE);
 }
 
 static void __init
@@ -1561,7 +1463,7 @@
 	spin_lock_init(&ioc->res_lock);
 
 	/* resource map size dictated by pdir_size */
-	ioc->res_size = ioc->pdir_size / sizeof(u64); /* entries */
+	ioc->res_size = ioc->pdir_size / PDIR_ENTRY_SIZE; /* entries */
 	ioc->res_size >>= 3;  /* convert bit count to byte count */
 	DBG_INIT("%s() res_size 0x%x\n", __FUNCTION__, ioc->res_size);
 
@@ -1582,7 +1484,7 @@
 #ifdef FULL_VALID_PDIR
 	/* Mark the last resource used so we don't prefetch beyond IOVA space */
 	ioc->res_map[ioc->res_size - 1] |= 0x80UL; /* res_map is chars */
-	ioc->pdir_base[(ioc->pdir_size / sizeof(u64)) - 1] = (0x80000000000000FF
+	ioc->pdir_base[(ioc->pdir_size / PDIR_ENTRY_SIZE) - 1] = (0x80000000000000FF
 							      | prefetch_spill_page);
 #endif
 
@@ -1627,6 +1529,23 @@
 		panic(PFX "IOC 2.0 or later required for IOMMU support\n");
 
 	ioc->dma_mask = 0xFFFFFFFFFFUL;
+
+	if (!iovp_shift) {
+		/* 64k is max iommu page size */
+		iovp_shift = min(PAGE_SHIFT, 16);
+		iovp_size = (1 << iovp_shift);
+		iovp_mask = ~(iovp_size - 1);
+	}
+}
+
+static void __init
+ioc_sx1000_init(struct ioc *ioc)
+{
+	if (!iovp_shift) {
+		iovp_shift = 12;	/* 4K for now */
+		iovp_size = (1 << iovp_shift);
+		iovp_mask = ~(iovp_size - 1);
+	}
 }
 
 typedef void (initfunc)(struct ioc *);
@@ -1639,8 +1558,8 @@
 
 static struct ioc_iommu ioc_iommu_info[] __initdata = {
 	{ ZX1_IOC_ID, "zx1", ioc_zx1_init },
-	{ REO_IOC_ID, "REO" },
-	{ SX1000_IOC_ID, "sx1000" },
+	{ REO_IOC_ID, "REO", ioc_sx1000_init },
+	{ SX1000_IOC_ID, "sx1000", ioc_sx1000_init },
 };
 
 static struct ioc * __init
@@ -1665,6 +1584,11 @@
 	ioc->rev = READ_REG(ioc->ioc_hpa + IOC_FCLASS) & 0xFFUL;
 	ioc->dma_mask = 0xFFFFFFFFFFFFFFFFUL;	/* conservative */
 
+	if (iovp_shift) {
+		iovp_size = (1 << iovp_shift);
+		iovp_mask = ~(iovp_size - 1);
+	}
+
 	for (info = ioc_iommu_info; info < ioc_iommu_info + ARRAY_SIZE(ioc_iommu_info); info++) {
 		if (ioc->func_id = info->func_id) {
 			ioc->name = info->name;
@@ -1672,6 +1596,8 @@
 				(info->init)(ioc);
 		}
 	}
+	DBG_INIT("%s: PAGE_SIZE %ldK, iovp_size %ldK\n", __FUNCTION__,
+		PAGE_SIZE >> 10, iovp_size >> 10);
 
 	if (!ioc->name) {
 		ioc->name = kmalloc(24, GFP_KERNEL);
@@ -1686,8 +1612,8 @@
 	ioc_resource_init(ioc);
 	ioc_sac_init(ioc);
 
-	if ((long) ~IOVP_MASK > (long) ia64_max_iommu_merge_mask)
-		ia64_max_iommu_merge_mask = ~IOVP_MASK;
+	if ((long) ~iovp_mask > (long) ia64_max_iommu_merge_mask)
+		ia64_max_iommu_merge_mask = ~iovp_mask;
 	MAX_DMA_ADDRESS = ~0UL;
 
 	printk(KERN_INFO PFX
@@ -1709,7 +1635,7 @@
 **
 **************************************************************************/
 
-#if SBA_PROC_FS
+#ifdef CONFIG_PROC_FS
 static void *
 ioc_start(struct seq_file *s, loff_t *pos)
 {
@@ -1741,55 +1667,37 @@
 ioc_show(struct seq_file *s, void *v)
 {
 	struct ioc *ioc = v;
-	int total_pages = (int) (ioc->res_size << 3); /* 8 bits per byte */
-	unsigned long i = 0, avg = 0, min, max;
+	unsigned long *res_ptr = (unsigned long *)ioc->res_map;
+	int i, used = 0;
 
 	seq_printf(s, "Hewlett Packard %s IOC rev %d.%d\n",
 		ioc->name, ((ioc->rev >> 4) & 0xF), (ioc->rev & 0xF));
-	seq_printf(s, "IO PDIR size    : %d bytes (%d entries)\n",
-		(int) ((ioc->res_size << 3) * sizeof(u64)), /* 8 bits/byte */
-		total_pages);
-
-	seq_printf(s, "IO PDIR entries : %ld free  %ld used (%d%%)\n",
-		total_pages - ioc->used_pages, ioc->used_pages,
-		(int) (ioc->used_pages * 100 / total_pages));
-
-	seq_printf(s, "Resource bitmap : %d bytes (%d pages)\n",
-		ioc->res_size, ioc->res_size << 3);   /* 8 bits per byte */
-
-	min = max = ioc->avg_search[0];
-	for (i = 0; i < SBA_SEARCH_SAMPLE; i++) {
-		avg += ioc->avg_search[i];
-		if (ioc->avg_search[i] > max) max = ioc->avg_search[i];
-		if (ioc->avg_search[i] < min) min = ioc->avg_search[i];
-	}
-	avg /= SBA_SEARCH_SAMPLE;
-	seq_printf(s, "  Bitmap search : %ld/%ld/%ld (min/avg/max CPU Cycles)\n", min, avg, max);
-
-	seq_printf(s, "pci_map_single(): %12ld calls  %12ld pages (avg %d/1000)\n",
-		   ioc->msingle_calls, ioc->msingle_pages,
-		   (int) ((ioc->msingle_pages * 1000)/ioc->msingle_calls));
-#ifdef ALLOW_IOV_BYPASS
-	seq_printf(s, "pci_map_single(): %12ld bypasses\n", ioc->msingle_bypass);
-#endif
+	seq_printf(s, "IOVA size       : %d MB\n", ioc->iov_size/(1024*1024));
+	seq_printf(s, "IOVA page size  : %ld kb\n", iovp_size/1024);
 
-	seq_printf(s, "pci_unmap_single: %12ld calls  %12ld pages (avg %d/1000)\n",
-		   ioc->usingle_calls, ioc->usingle_pages,
-		   (int) ((ioc->usingle_pages * 1000)/ioc->usingle_calls));
-#ifdef ALLOW_IOV_BYPASS
-	seq_printf(s, "pci_unmap_single: %12ld bypasses\n", ioc->usingle_bypass);
-#endif
-
-	seq_printf(s, "pci_map_sg()    : %12ld calls  %12ld pages (avg %d/1000)\n",
-		   ioc->msg_calls, ioc->msg_pages,
-		   (int) ((ioc->msg_pages * 1000)/ioc->msg_calls));
-#ifdef ALLOW_IOV_BYPASS
-	seq_printf(s, "pci_map_sg()    : %12ld bypasses\n", ioc->msg_bypass);
-#endif
+	for (i = 0; i < (ioc->res_size / sizeof(unsigned long)); ++i, ++res_ptr)
+		used += hweight64(*res_ptr);
 
-	seq_printf(s, "pci_unmap_sg()  : %12ld calls  %12ld pages (avg %d/1000)\n",
-		   ioc->usg_calls, ioc->usg_pages, (int) ((ioc->usg_pages * 1000)/ioc->usg_calls));
+	seq_printf(s, "PDIR size       : %d entries\n", ioc->res_size << 3);
+	seq_printf(s, "PDIR used       : %d entries\n", used);
 
+#ifdef PDIR_SEARCH_TIMING
+	{
+		unsigned long i = 0, avg = 0, min, max;
+		min = max = ioc->avg_search[0];
+		for (i = 0; i < SBA_SEARCH_SAMPLE; i++) {
+			avg += ioc->avg_search[i];
+			if (ioc->avg_search[i] > max) max = ioc->avg_search[i];
+			if (ioc->avg_search[i] < min) min = ioc->avg_search[i];
+		}
+		avg /= SBA_SEARCH_SAMPLE;
+		seq_printf(s, "Bitmap search   : %ld/%ld/%ld (min/avg/max CPU Cycles)\n",
+		           min, avg, max);
+	}
+#endif
+#ifndef ALLOW_IOV_BYPASS
+	 seq_printf(s, "IOVA bypass disabled\n");
+#endif
 	return 0;
 }
 
@@ -1813,39 +1721,6 @@
 	.release = seq_release
 };
 
-static int
-ioc_map_show(struct seq_file *s, void *v)
-{
-	struct ioc *ioc = v;
-	unsigned int i, *res_ptr = (unsigned int *)ioc->res_map;
-
-	for (i = 0; i < ioc->res_size / sizeof(unsigned int); ++i, ++res_ptr)
-		seq_printf(s, "%s%08x", (i & 7) ? " " : "\n   ", *res_ptr);
-	seq_printf(s, "\n");
-
-	return 0;
-}
-
-static struct seq_operations ioc_map_ops = {
-	.start = ioc_start,
-	.next  = ioc_next,
-	.stop  = ioc_stop,
-	.show  = ioc_map_show
-};
-
-static int
-ioc_map_open(struct inode *inode, struct file *file)
-{
-	return seq_open(file, &ioc_map_ops);
-}
-
-static struct file_operations ioc_map_fops = {
-	.open    = ioc_map_open,
-	.read    = seq_read,
-	.llseek  = seq_lseek,
-	.release = seq_release
-};
-
 static void __init
 ioc_proc_init(void)
 {
@@ -1858,10 +1733,6 @@
 	entry = create_proc_entry(ioc_list->name, 0, dir);
 	if (entry)
 		entry->proc_fops = &ioc_fops;
-
-	entry = create_proc_entry("bitmap", 0, dir);
-	if (entry)
-		entry->proc_fops = &ioc_map_fops;
 }
 #endif
 
@@ -1958,7 +1829,7 @@
 	}
 #endif
 
-#if SBA_PROC_FS
+#ifdef CONFIG_PROC_FS
 	ioc_proc_init();
 #endif
 	return 0;
@@ -1981,6 +1852,29 @@
 }
 
 __setup("nosbagart", nosbagart);
+
+static int __init
+sba_page_override(char *str)
+{
+	unsigned long page_size;
+
+	page_size = memparse(str, &str);
+	switch (page_size) {
+		case 4096:
+		case 8192:
+		case 16384:
+		case 65536:
+			iovp_shift = ffs(page_size) - 1;
+			break;
+		default:
+			printk("%s: unknown/unsupported iommu page size %ld\n",
+			       __FUNCTION__, page_size);
+	}
+
+	return 1;
+}
+
+__setup("sbapagesize=",sba_page_override);
 
 EXPORT_SYMBOL(sba_map_single);
 EXPORT_SYMBOL(sba_unmap_single);


