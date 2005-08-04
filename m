From: Alex Williamson <alex.williamson@hp.com>
Date: Thu, 04 Aug 2005 20:06:15 +0000
Subject: [PATCH] fix swiotlb sizing
Message-Id: <1123185975.5484.73.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   Fix swiotlb sizing to match what the comments and the kernel
parameters documentation indicate.  Given a default 16k page size kernel
(ia64) and a 2k swiotlb page size, we're off by a multiple of 8 trying
to size the swiotlb.  When specified on the boot line, the swiotlb is
made 8x bigger than requested.  When left to the default value, it's 8x
smaller than the comments indicate.  For x86_64 the multiplier would be
2x.  The patch below fixes this.  Now, what's a good default swiotlb
size?  Apparently we don't really need 64MB.

Signed-off-by: Alex Williamson <alex.williamson@hp.com>

diff -r 5be3d7aab675 arch/ia64/lib/swiotlb.c
--- a/arch/ia64/lib/swiotlb.c	Thu Aug  4 17:36:25 2005
+++ b/arch/ia64/lib/swiotlb.c	Thu Aug  4 13:32:52 2005
@@ -93,8 +93,7 @@
 setup_io_tlb_npages(char *str)
 {
 	if (isdigit(*str)) {
-		io_tlb_nslabs = simple_strtoul(str, &str, 0) <<
-			(PAGE_SHIFT - IO_TLB_SHIFT);
+		io_tlb_nslabs = simple_strtoul(str, &str, 0);
 		/* avoid tail segment of size < IO_TLB_SEGSIZE */
 		io_tlb_nslabs = ALIGN(io_tlb_nslabs, IO_TLB_SEGSIZE);
 	}
@@ -117,7 +116,7 @@
 	unsigned long i;
 
 	if (!io_tlb_nslabs) {
-		io_tlb_nslabs = (default_size >> PAGE_SHIFT);
+		io_tlb_nslabs = (default_size >> IO_TLB_SHIFT);
 		io_tlb_nslabs = ALIGN(io_tlb_nslabs, IO_TLB_SEGSIZE);
 	}
 


