From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 30 Aug 2005 18:33:39 +0000
Subject: [rfc patch] swiotlb: consolidate swiotlb_sync_single_* implementations
Message-Id: <20050830183337.GF18998@tuxdriver.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0443A4B5@scsmsx401.amr.corp.intel.com> <20050830180912.GE18998@tuxdriver.com>
In-Reply-To: <20050830180912.GE18998@tuxdriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Andi Kleen <ak@suse.de>, discuss@x86-64.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, Asit.K.Mallick@intel.com

On Tue, Aug 30, 2005 at 02:09:14PM -0400, John W. Linville wrote:
> On Tue, Aug 30, 2005 at 11:03:35AM -0700, Luck, Tony wrote:
> > 
> > >+swiotlb_sync_single_range_for_cpu(struct device *hwdev, 
> > >+swiotlb_sync_single_range_for_device(struct device *hwdev, 
> > 
> > Huh?  These look identical ... same args, same code, just a
> > different name.
> 
> Have you looked at the implementations for swiotlb_sync_single_for_cpu
> and swiotlb_sync_single_for_device?  Those are already identical.

How about a patch like this?  Just for comment...I'll repost if people
want it...

John

P.S.  This is meant to apply on top of my previous swiotlb patch...

--- linux-8_29_2005/arch/ia64/lib/swiotlb.c.orig	2005-08-30 14:19:32.000000000 -0400
+++ linux-8_29_2005/arch/ia64/lib/swiotlb.c	2005-08-30 14:23:18.000000000 -0400
@@ -493,11 +493,11 @@ swiotlb_unmap_single(struct device *hwde
  * address back to the card, you must first perform a
  * swiotlb_dma_sync_for_device, and then the device again owns the buffer
  */
-void
-swiotlb_sync_single_for_cpu(struct device *hwdev, dma_addr_t dev_addr,
-			    size_t size, int dir)
+static inline void
+swiotlb_sync_single_range(struct device *hwdev, dma_addr_t dev_addr,
+			  unsigned long offset, size_t size, int dir)
 {
-	char *dma_addr = phys_to_virt(dev_addr);
+	char *dma_addr = phys_to_virt(dev_addr) + offset;
 
 	if (dir = DMA_NONE)
 		BUG();
@@ -508,17 +508,17 @@ swiotlb_sync_single_for_cpu(struct devic
 }
 
 void
+swiotlb_sync_single_for_cpu(struct device *hwdev, dma_addr_t dev_addr,
+			    size_t size, int dir)
+{
+	swiotlb_sync_single_range(hwdev, dev_addr, 0, size, dir);
+}
+
+void
 swiotlb_sync_single_for_device(struct device *hwdev, dma_addr_t dev_addr,
 			       size_t size, int dir)
 {
-	char *dma_addr = phys_to_virt(dev_addr);
-
-	if (dir = DMA_NONE)
-		BUG();
-	if (dma_addr >= io_tlb_start && dma_addr < io_tlb_end)
-		sync_single(hwdev, dma_addr, size, dir);
-	else if (dir = DMA_FROM_DEVICE)
-		mark_clean(dma_addr, size);
+	swiotlb_sync_single_range(hwdev, dev_addr, 0, size, dir);
 }
 
 /*
@@ -528,28 +528,14 @@ void
 swiotlb_sync_single_range_for_cpu(struct device *hwdev, dma_addr_t dev_addr,
 				  unsigned long offset, size_t size, int dir)
 {
-	char *dma_addr = phys_to_virt(dev_addr) + offset;
-
-	if (dir = DMA_NONE)
-		BUG();
-	if (dma_addr >= io_tlb_start && dma_addr < io_tlb_end)
-		sync_single(hwdev, dma_addr, size, dir);
-	else if (dir = DMA_FROM_DEVICE)
-		mark_clean(dma_addr, size);
+	swiotlb_sync_single_range(hwdev, dev_addr, offset, size, dir);
 }
 
 void
 swiotlb_sync_single_range_for_device(struct device *hwdev, dma_addr_t dev_addr,
 				     unsigned long offset, size_t size, int dir)
 {
-	char *dma_addr = phys_to_virt(dev_addr) + offset;
-
-	if (dir = DMA_NONE)
-		BUG();
-	if (dma_addr >= io_tlb_start && dma_addr < io_tlb_end)
-		sync_single(hwdev, dma_addr, size, dir);
-	else if (dir = DMA_FROM_DEVICE)
-		mark_clean(dma_addr, size);
+	swiotlb_sync_single_range(hwdev, dev_addr, offset, size, dir);
 }
 
 /*
-- 
John W. Linville
linville@tuxdriver.com
