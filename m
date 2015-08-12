From: Christoph Hellwig <hch@lst.de>
Date: Wed, 12 Aug 2015 07:05:48 +0000
Subject: [PATCH 29/31] parisc: handle page-less SG entries
Message-Id: <1439363150-8661-30-git-send-email-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439363150-8661-1-git-send-email-hch@lst.de>
In-Reply-To: <1439363150-8661-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, axboe@kernel.dk
Cc: dan.j.williams@intel.com, vgupta@synopsys.com, hskinnemoen@gmail.com, egtvedt@samfundet.no, realmz6@gmail.com, dhowells@redhat.com, monstr@monstr.eu, x86@kernel.org, dwmw2@infradead.org, alex.williamson@redhat.com, grundler@parisc-linux.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-nvdimm@ml01.01.org, linux-media@vger.kernel.org

Make all cache invalidation conditional on sg_has_page() and use
sg_phys to get the physical address directly.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/parisc/kernel/pci-dma.c | 29 ++++++++++++++++++-----------
 1 file changed, 18 insertions(+), 11 deletions(-)

diff --git a/arch/parisc/kernel/pci-dma.c b/arch/parisc/kernel/pci-dma.c
index b9402c9..6cad0e0 100644
--- a/arch/parisc/kernel/pci-dma.c
+++ b/arch/parisc/kernel/pci-dma.c
@@ -483,11 +483,13 @@ static int pa11_dma_map_sg(struct device *dev, struct scatterlist *sglist, int n
 	BUG_ON(direction = DMA_NONE);
 
 	for_each_sg(sglist, sg, nents, i) {
-		unsigned long vaddr = (unsigned long)sg_virt(sg);
-
-		sg_dma_address(sg) = (dma_addr_t) virt_to_phys(vaddr);
+		sg_dma_address(sg) = sg_phys(sg);
 		sg_dma_len(sg) = sg->length;
-		flush_kernel_dcache_range(vaddr, sg->length);
+
+		if (sg_has_page(sg)) {
+			flush_kernel_dcache_range((unsigned long)sg_virt(sg),
+						  sg->length);
+		}
 	}
 	return nents;
 }
@@ -504,9 +506,10 @@ static void pa11_dma_unmap_sg(struct device *dev, struct scatterlist *sglist, in
 
 	/* once we do combining we'll need to use phys_to_virt(sg_dma_address(sglist)) */
 
-	for_each_sg(sglist, sg, nents, i)
-		flush_kernel_vmap_range(sg_virt(sg), sg->length);
-	return;
+	for_each_sg(sglist, sg, nents, i) {
+		if (sg_has_page(sg))
+			flush_kernel_vmap_range(sg_virt(sg), sg->length);
+	}
 }
 
 static void pa11_dma_sync_single_for_cpu(struct device *dev, dma_addr_t dma_handle, unsigned long offset, size_t size, enum dma_data_direction direction)
@@ -530,8 +533,10 @@ static void pa11_dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sgl
 
 	/* once we do combining we'll need to use phys_to_virt(sg_dma_address(sglist)) */
 
-	for_each_sg(sglist, sg, nents, i)
-		flush_kernel_vmap_range(sg_virt(sg), sg->length);
+	for_each_sg(sglist, sg, nents, i) {
+		if (sg_has_page(sg))
+			flush_kernel_vmap_range(sg_virt(sg), sg->length);
+	}
 }
 
 static void pa11_dma_sync_sg_for_device(struct device *dev, struct scatterlist *sglist, int nents, enum dma_data_direction direction)
@@ -541,8 +546,10 @@ static void pa11_dma_sync_sg_for_device(struct device *dev, struct scatterlist *
 
 	/* once we do combining we'll need to use phys_to_virt(sg_dma_address(sglist)) */
 
-	for_each_sg(sglist, sg, nents, i)
-		flush_kernel_vmap_range(sg_virt(sg), sg->length);
+	for_each_sg(sglist, sg, nents, i) {
+		if (sg_has_page(sg))
+			flush_kernel_vmap_range(sg_virt(sg), sg->length);
+	}
 }
 
 struct hppa_dma_ops pcxl_dma_ops = {
-- 
1.9.1

