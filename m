From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 30 Aug 2005 18:40:06 +0000
Subject: [rfc patch] swiotlb: consolidate swiotlb_sync_sg_* implementations
Message-Id: <20050830184006.GG18998@tuxdriver.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0443A4B5@scsmsx401.amr.corp.intel.com> <20050830180912.GE18998@tuxdriver.com> <20050830183337.GF18998@tuxdriver.com>
In-Reply-To: <20050830183337.GF18998@tuxdriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Andi Kleen <ak@suse.de>, discuss@x86-64.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, Asit.K.Mallick@intel.com

On Tue, Aug 30, 2005 at 02:33:39PM -0400, John W. Linville wrote:
> On Tue, Aug 30, 2005 at 02:09:14PM -0400, John W. Linville wrote:
> > On Tue, Aug 30, 2005 at 11:03:35AM -0700, Luck, Tony wrote:
> > > 
> > > >+swiotlb_sync_single_range_for_cpu(struct device *hwdev, 
> > > >+swiotlb_sync_single_range_for_device(struct device *hwdev, 
> > > 
> > > Huh?  These look identical ... same args, same code, just a
> > > different name.
> > 
> > Have you looked at the implementations for swiotlb_sync_single_for_cpu
> > and swiotlb_sync_single_for_device?  Those are already identical.
> 
> How about a patch like this?  Just for comment...I'll repost if people
> want it...

Probably should include the swiotlb_sync_sg_* variations too...

Whaddya think?  Again, I'll repost if this is viewed favorably.

John

--- linux-8_29_2005/arch/ia64/lib/swiotlb.c.orig	2005-08-30 14:35:35.000000000 -0400
+++ linux-8_29_2005/arch/ia64/lib/swiotlb.c	2005-08-30 14:37:05.000000000 -0400
@@ -612,9 +612,9 @@ swiotlb_unmap_sg(struct device *hwdev, s
  * The same as swiotlb_sync_single_* but for a scatter-gather list, same rules
  * and usage.
  */
-void
-swiotlb_sync_sg_for_cpu(struct device *hwdev, struct scatterlist *sg,
-			int nelems, int dir)
+static inline void
+swiotlb_sync_sg(struct device *hwdev, struct scatterlist *sg,
+		int nelems, int dir)
 {
 	int i;
 
@@ -628,18 +628,17 @@ swiotlb_sync_sg_for_cpu(struct device *h
 }
 
 void
+swiotlb_sync_sg_for_cpu(struct device *hwdev, struct scatterlist *sg,
+			int nelems, int dir)
+{
+	swiotlb_sync_sg(hwdev, sg, nelems, dir);
+}
+
+void
 swiotlb_sync_sg_for_device(struct device *hwdev, struct scatterlist *sg,
 			   int nelems, int dir)
 {
-	int i;
-
-	if (dir = DMA_NONE)
-		BUG();
-
-	for (i = 0; i < nelems; i++, sg++)
-		if (sg->dma_address != SG_ENT_PHYS_ADDRESS(sg))
-			sync_single(hwdev, (void *) sg->dma_address,
-				    sg->dma_length, dir);
+	swiotlb_sync_sg(hwdev, sg, nelems, dir);
 }
 
 int
-- 
John W. Linville
linville@tuxdriver.com
