From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Tue, 01 Apr 2003 04:39:21 +0000
Subject: [Linux-ia64] Bug in sba_iommu.c (2.5.64)
Message-Id: <marc-linux-ia64-105590723705373@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

OK, thanks to some inspired debugging work by Matthew Chapman, we now
have the error.   sba_map_sg() was passing the uninitialised  dma
address from the sg-list to sba_map_single() instead of the virtual
address.  This meant that the dma when it happened scribbled over
random memory causing an MCA later, or possibly caused an MCA immediately.

Patch against 2.5.64 appended.


=== linux-userdrivers/arch/ia64/hp/common/sba_iommu.c 1.10 vs edited ==--- 1.10/arch/ia64/hp/common/sba_iommu.c	Wed Feb  5 12:06:01 2003
+++ edited/arch/ia64/hp/common/sba_iommu.c	Tue Apr  1 14:31:50 2003
@@ -1119,7 +1119,7 @@
 	/* Fast path single entry scatterlists. */
 	if (nents = 1) {
 		sba_sg_iova(sglist) = sba_map_single(dev,
-						     (void *) sba_sg_iova(sglist),
+						     (void *)sba_sg_address(sglist),
 						     sba_sg_len(sglist), direction);
 		sba_sg_iova_len(sglist) = sba_sg_len(sglist);
 #ifdef CONFIG_PROC_FS

