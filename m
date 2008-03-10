From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Mon, 10 Mar 2008 13:17:20 +0000
Subject: [PATCH -mm] ia64: make IOMMU respect the segment boundary limits
Message-Id: <20080310221538U.tomof@acm.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: tony.luck@intel.com, akpm@linux-foundation.org

This patch is another sequel to my patchset that fixes iommu segment
boundary problems, that is, IOMMUs allocate memory areas without
considering a low level driver's segment boundary limits:

http://www.mail-archive.com/linux-scsi@vger.kernel.org/msg11919.html

This patchset fixes the IA64 IOMMU code.

This assumes that ioc->ibase is on iovp_size boundary. If not, please
let me know. I'll fix the patch.

From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH -mm] ia64: make IOMMU respect the segment boundary limits

This makes IA64's IOMMU implementation not allocate a memory area
spanning LLD's segment boundary.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 arch/ia64/Kconfig               |    3 ++
 arch/ia64/hp/common/sba_iommu.c |   56 +++++++++++++++++++++++++++------------
 2 files changed, 42 insertions(+), 17 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 8fa3faf..1b73ffe 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -611,6 +611,9 @@ config IRQ_PER_CPU
 	bool
 	default y
 
+config IOMMU_HELPER
+	def_bool (IA64_HP_ZX1 || IA64_HP_ZX1_SWIOTLB || IA64_GENERIC)
+
 source "arch/ia64/hp/sim/Kconfig"
 
 source "arch/ia64/Kconfig.debug"
diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index 523eae6..9409de5 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -35,6 +35,7 @@
 #include <linux/nodemask.h>
 #include <linux/bitops.h>         /* hweight64() */
 #include <linux/crash_dump.h>
+#include <linux/iommu-helper.h>
 
 #include <asm/delay.h>		/* ia64_get_itc() */
 #include <asm/io.h>
@@ -460,6 +461,13 @@ get_iovp_order (unsigned long size)
 	return order;
 }
 
+static unsigned long ptr_to_pide(struct ioc *ioc, unsigned long *res_ptr,
+				 unsigned int bitshiftcnt)
+{
+	return (((unsigned long)res_ptr - (unsigned long)ioc->res_map) << 3)
+		+ bitshiftcnt;
+}
+
 /**
  * sba_search_bitmap - find free space in IO PDIR resource bitmap
  * @ioc: IO MMU structure which owns the pdir we are interested in.
@@ -471,15 +479,25 @@ get_iovp_order (unsigned long size)
  * Cool perf optimization: search for log2(size) bits at a time.
  */
 static SBA_INLINE unsigned long
-sba_search_bitmap(struct ioc *ioc, unsigned long bits_wanted, int use_hint)
+sba_search_bitmap(struct ioc *ioc, struct device *dev,
+		  unsigned long bits_wanted, int use_hint)
 {
 	unsigned long *res_ptr;
 	unsigned long *res_end = (unsigned long *) &(ioc->res_map[ioc->res_size]);
-	unsigned long flags, pide = ~0UL;
+	unsigned long flags, pide = ~0UL, tpide;
+	unsigned long boundary_size;
+	unsigned long shift;
+	int ret;
 
 	ASSERT(((unsigned long) ioc->res_hint & (sizeof(unsigned long) - 1UL)) = 0);
 	ASSERT(res_ptr < res_end);
 
+	boundary_size = (unsigned long long)dma_get_seg_boundary(dev) + 1;
+	boundary_size = ALIGN(boundary_size, 1ULL << iovp_shift) >> iovp_shift;
+
+	BUG_ON(ioc->ibase & ~iovp_mask);
+	shift = ioc->ibase >> iovp_shift;
+
 	spin_lock_irqsave(&ioc->res_lock, flags);
 
 	/* Allow caller to force a search through the entire resource space */
@@ -504,9 +522,7 @@ sba_search_bitmap(struct ioc *ioc, unsigned long bits_wanted, int use_hint)
 			if (likely(*res_ptr != ~0UL)) {
 				bitshiftcnt = ffz(*res_ptr);
 				*res_ptr |= (1UL << bitshiftcnt);
-				pide = ((unsigned long)res_ptr - (unsigned long)ioc->res_map);
-				pide <<= 3;	/* convert to bit address */
-				pide += bitshiftcnt;
+				pide = ptr_to_pide(ioc, res_ptr, bitshiftcnt);
 				ioc->res_bitshift = bitshiftcnt + bits_wanted;
 				goto found_it;
 			}
@@ -535,11 +551,13 @@ sba_search_bitmap(struct ioc *ioc, unsigned long bits_wanted, int use_hint)
 			DBG_RES("    %p %lx %lx\n", res_ptr, mask, *res_ptr);
 			ASSERT(0 != mask);
 			for (; mask ; mask <<= o, bitshiftcnt += o) {
-				if(0 = ((*res_ptr) & mask)) {
+				tpide = ptr_to_pide(ioc, res_ptr, bitshiftcnt);
+				ret = iommu_is_span_boundary(tpide, bits_wanted,
+							     shift,
+							     boundary_size);
+				if ((0 = ((*res_ptr) & mask)) && !ret) {
 					*res_ptr |= mask;     /* mark resources busy! */
-					pide = ((unsigned long)res_ptr - (unsigned long)ioc->res_map);
-					pide <<= 3;	/* convert to bit address */
-					pide += bitshiftcnt;
+					pide = tpide;
 					ioc->res_bitshift = bitshiftcnt + bits_wanted;
 					goto found_it;
 				}
@@ -560,6 +578,11 @@ sba_search_bitmap(struct ioc *ioc, unsigned long bits_wanted, int use_hint)
 		end = res_end - qwords;
 
 		for (; res_ptr < end; res_ptr++) {
+			tpide = ptr_to_pide(ioc, res_ptr, 0);
+			ret = iommu_is_span_boundary(tpide, bits_wanted,
+						     shift, boundary_size);
+			if (ret)
+				goto next_ptr;
 			for (i = 0 ; i < qwords ; i++) {
 				if (res_ptr[i] != 0)
 					goto next_ptr;
@@ -572,8 +595,7 @@ sba_search_bitmap(struct ioc *ioc, unsigned long bits_wanted, int use_hint)
 				res_ptr[i] = ~0UL;
 			res_ptr[i] |= RESMAP_MASK(bits);
 
-			pide = ((unsigned long)res_ptr - (unsigned long)ioc->res_map);
-			pide <<= 3;	/* convert to bit address */
+			pide = tpide;
 			res_ptr += qwords;
 			ioc->res_bitshift = bits;
 			goto found_it;
@@ -605,7 +627,7 @@ found_it:
  * resource bit map.
  */
 static int
-sba_alloc_range(struct ioc *ioc, size_t size)
+sba_alloc_range(struct ioc *ioc, struct device *dev, size_t size)
 {
 	unsigned int pages_needed = size >> iovp_shift;
 #ifdef PDIR_SEARCH_TIMING
@@ -622,9 +644,9 @@ sba_alloc_range(struct ioc *ioc, size_t size)
 	/*
 	** "seek and ye shall find"...praying never hurts either...
 	*/
-	pide = sba_search_bitmap(ioc, pages_needed, 1);
+	pide = sba_search_bitmap(ioc, dev, pages_needed, 1);
 	if (unlikely(pide >= (ioc->res_size << 3))) {
-		pide = sba_search_bitmap(ioc, pages_needed, 0);
+		pide = sba_search_bitmap(ioc, dev, pages_needed, 0);
 		if (unlikely(pide >= (ioc->res_size << 3))) {
 #if DELAYED_RESOURCE_CNT > 0
 			unsigned long flags;
@@ -653,7 +675,7 @@ sba_alloc_range(struct ioc *ioc, size_t size)
 			}
 			spin_unlock_irqrestore(&ioc->saved_lock, flags);
 
-			pide = sba_search_bitmap(ioc, pages_needed, 0);
+			pide = sba_search_bitmap(ioc, dev, pages_needed, 0);
 			if (unlikely(pide >= (ioc->res_size << 3)))
 				panic(__FILE__ ": I/O MMU @ %p is out of mapping resources\n",
 				      ioc->ioc_hpa);
@@ -936,7 +958,7 @@ sba_map_single(struct device *dev, void *addr, size_t size, int dir)
 	spin_unlock_irqrestore(&ioc->res_lock, flags);
 #endif
 
-	pide = sba_alloc_range(ioc, size);
+	pide = sba_alloc_range(ioc, dev, size);
 
 	iovp = (dma_addr_t) pide << iovp_shift;
 
@@ -1373,7 +1395,7 @@ sba_coalesce_chunks(struct ioc *ioc, struct device *dev,
 		dma_len = (dma_len + dma_offset + ~iovp_mask) & iovp_mask;
 		ASSERT(dma_len <= DMA_CHUNK_SIZE);
 		dma_sg->dma_address = (dma_addr_t) (PIDE_FLAG
-			| (sba_alloc_range(ioc, dma_len) << iovp_shift)
+			| (sba_alloc_range(ioc, dev, dma_len) << iovp_shift)
 			| dma_offset);
 		n_mappings++;
 	}
-- 
1.5.3.7

