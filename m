From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Date: Wed, 04 Aug 2004 22:04:12 +0000
Subject: Re: [PATCH] Various swiotlb fixes
Message-Id: <200408041504.12907.suresh.b.siddha@intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_c1VEBjDoHF1//0i"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_c1VEBjDoHF1//0i
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Friday 30 July 2004 09:59, Andi Kleen wrote:
>
> I added support for swiotlb=force for easier testing.

This bootparam has exposed a bug in today's ia64 swiotlb code, because of 
which the kernel was not booting on my tiger with "swiotlb=force"

In swiotlb_map/unmap_sg(), sg->dma_address is getting setup with virtual 
address instead of physical.

Attached patch fixes this issue.

thanks,
suresh

--Boundary-00=_c1VEBjDoHF1//0i
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="swiotlb-0408.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="swiotlb-0408.patch"

Signed-off-by: Suresh Siddha <suresh.b.siddha@intel.com>

--- linux-2.6.8-rc2/arch/ia64/lib/swiotlb.c.orig	2004-08-04 14:12:09.000000000 -0700
+++ linux-2.6.8-rc2/arch/ia64/lib/swiotlb.c	2004-08-04 14:12:16.000000000 -0700
@@ -492,7 +492,7 @@
 		addr = SG_ENT_VIRT_ADDRESS(sg);
 		dev_addr = virt_to_phys(addr);
 		if (swiotlb_force || address_needs_mapping(hwdev, dev_addr)) {
-			sg->dma_address = (dma_addr_t) map_single(hwdev, addr, sg->length, dir);
+			sg->dma_address = (dma_addr_t) virt_to_phys(map_single(hwdev, addr, sg->length, dir));
 			if (!sg->dma_address) {
 				/* Don't panic here, we expect pci_map_sg users
 				   to do proper error handling. */
@@ -522,7 +522,7 @@
 
 	for (i = 0; i < nelems; i++, sg++)
 		if (sg->dma_address != SG_ENT_PHYS_ADDRESS(sg))
-			unmap_single(hwdev, (void *) sg->dma_address, sg->dma_length, dir);
+			unmap_single(hwdev, (void *) phys_to_virt(sg->dma_address), sg->dma_length, dir);
 		else if (dir == DMA_FROM_DEVICE)
 			mark_clean(SG_ENT_VIRT_ADDRESS(sg), sg->dma_length);
 }

--Boundary-00=_c1VEBjDoHF1//0i--
