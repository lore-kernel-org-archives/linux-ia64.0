From: Christoph Hellwig <hch@lst.de>
Date: Wed, 12 Aug 2015 07:05:39 +0000
Subject: [PATCH 20/31] avr32: handle page-less SG entries
Message-Id: <1439363150-8661-21-git-send-email-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439363150-8661-1-git-send-email-hch@lst.de>
In-Reply-To: <1439363150-8661-1-git-send-email-hch-jcswGhMUV9g@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org
Cc: dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, vgupta-HKixBCOQz3hWk0Htik3J/w@public.gmane.org, hskinnemoen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, egtvedt-BrfabpQBY5qlHtIdYg32fQ@public.gmane.org, realmz6-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, alex.williamson-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, grundler-6jwH94ZQLHl74goWV3ctuw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, linux-nvdimm-y27Ovi1pjclAfugRpC6u6w@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

Make all cache invalidation conditional on sg_has_page() and use
sg_phys to get the physical address directly, bypassing the noop
page_to_bus.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/avr32/include/asm/dma-mapping.h | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/arch/avr32/include/asm/dma-mapping.h b/arch/avr32/include/asm/dma-mapping.h
index ae7ac92..a662ce2 100644
--- a/arch/avr32/include/asm/dma-mapping.h
+++ b/arch/avr32/include/asm/dma-mapping.h
@@ -216,11 +216,9 @@ dma_map_sg(struct device *dev, struct scatterlist *sglist, int nents,
 	struct scatterlist *sg;
 
 	for_each_sg(sglist, sg, nents, i) {
-		char *virt;
-
-		sg->dma_address = page_to_bus(sg_page(sg)) + sg->offset;
-		virt = sg_virt(sg);
-		dma_cache_sync(dev, virt, sg->length, direction);
+		sg->dma_address = sg_phys(sg);
+		if (sg_has_page(sg))
+			dma_cache_sync(dev, sg_virt(sg), sg->length, direction);
 	}
 
 	return nents;
@@ -328,8 +326,10 @@ dma_sync_sg_for_device(struct device *dev, struct scatterlist *sglist,
 	int i;
 	struct scatterlist *sg;
 
-	for_each_sg(sglist, sg, nents, i)
-		dma_cache_sync(dev, sg_virt(sg), sg->length, direction);
+	for_each_sg(sglist, sg, nents, i) {
+		if (sg_has_page(sg))
+			dma_cache_sync(dev, sg_virt(sg), sg->length, direction);
+	}
 }
 
 /* Now for the API extensions over the pci_ one */
-- 
1.9.1

