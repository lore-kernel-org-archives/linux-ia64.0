From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 29 Jul 2004 17:25:54 +0000
Subject: [PATCH] fix HP iommu TLB fetch MCA
Message-Id: <200407291125.54475.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

REO/Grande defect AR2305 can cause TLB fetch timeouts if entries
are purged while in use.  Round up IOVA allocations to power-of-two
boundaries to prevent this.  This is originally due to Alex Williamson.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

=== arch/ia64/hp/common/sba_iommu.c 1.42 vs edited ==--- 1.42/arch/ia64/hp/common/sba_iommu.c	2004-04-05 05:14:20 -06:00
+++ edited/arch/ia64/hp/common/sba_iommu.c	2004-07-29 11:13:46 -06:00
@@ -469,6 +469,14 @@
 	ASSERT(((unsigned long) ioc->res_hint & (sizeof(unsigned long) - 1UL)) = 0);
 	ASSERT(res_ptr < res_end);
 
+	/*
+	 * N.B.  REO/Grande defect AR2305 can cause TLB fetch timeouts
+	 * if a TLB entry is purged while in use.  sba_mark_invalid()
+	 * purges IOTLB entries in power-of-two sizes, so we also
+	 * allocate IOVA space in power-of-two sizes.
+	 */
+	bits_wanted = 1UL << get_iovp_order(bits_wanted << PAGE_SHIFT);
+
 	if (likely(bits_wanted = 1)) {
 		unsigned int bitshiftcnt;
 		for(; res_ptr < res_end ; res_ptr++) {
@@ -675,6 +683,8 @@
 	int bits_not_wanted = size >> iovp_shift;
 	unsigned long m;
 
+	/* Round up to power-of-two size: see AR2305 note above */
+	bits_not_wanted = 1UL << get_iovp_order(bits_not_wanted << PAGE_SHIFT);
 	for (; bits_not_wanted > 0 ; res_ptr++) {
 		
 		if (unlikely(bits_not_wanted > BITS_PER_LONG)) {
