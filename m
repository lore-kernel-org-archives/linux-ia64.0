From: Christoph Hellwig <hch@lst.de>
Date: Wed, 12 Aug 2015 07:05:46 +0000
Subject: [PATCH 27/31] mips: handle page-less SG entries
Message-Id: <1439363150-8661-28-git-send-email-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439363150-8661-1-git-send-email-hch@lst.de>
In-Reply-To: <1439363150-8661-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, axboe@kernel.dk
Cc: dan.j.williams@intel.com, vgupta@synopsys.com, hskinnemoen@gmail.com, egtvedt@samfundet.no, realmz6@gmail.com, dhowells@redhat.com, monstr@monstr.eu, x86@kernel.org, dwmw2@infradead.org, alex.williamson@redhat.com, grundler@parisc-linux.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-nvdimm@ml01.01.org, linux-media@vger.kernel.org

Make all cache invalidation conditional on sg_has_page() and use
sg_phys to get the physical address directly.  To do this consolidate
the two platform callouts using pages and virtual addresses into a
single one using a physical address.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/mips/bmips/dma.c                              |  9 ++------
 arch/mips/include/asm/mach-ath25/dma-coherence.h   | 10 ++-------
 arch/mips/include/asm/mach-bmips/dma-coherence.h   |  4 ++--
 .../include/asm/mach-cavium-octeon/dma-coherence.h | 11 ++--------
 arch/mips/include/asm/mach-generic/dma-coherence.h | 12 +++--------
 arch/mips/include/asm/mach-ip27/dma-coherence.h    | 16 +++-----------
 arch/mips/include/asm/mach-ip32/dma-coherence.h    | 19 +++-------------
 arch/mips/include/asm/mach-jazz/dma-coherence.h    | 11 +++-------
 .../include/asm/mach-loongson64/dma-coherence.h    | 16 +++-----------
 arch/mips/mm/dma-default.c                         | 25 ++++++++++++----------
 10 files changed, 37 insertions(+), 96 deletions(-)

diff --git a/arch/mips/bmips/dma.c b/arch/mips/bmips/dma.c
index 04790f4..13fc891 100644
--- a/arch/mips/bmips/dma.c
+++ b/arch/mips/bmips/dma.c
@@ -52,14 +52,9 @@ static dma_addr_t bmips_phys_to_dma(struct device *dev, phys_addr_t pa)
 	return pa;
 }
 
-dma_addr_t plat_map_dma_mem(struct device *dev, void *addr, size_t size)
+dma_addr_t plat_map_dma_mem(struct device *dev, phys_addr_t phys, size_t size)
 {
-	return bmips_phys_to_dma(dev, virt_to_phys(addr));
-}
-
-dma_addr_t plat_map_dma_mem_page(struct device *dev, struct page *page)
-{
-	return bmips_phys_to_dma(dev, page_to_phys(page));
+	return bmips_phys_to_dma(dev, phys);
 }
 
 unsigned long plat_dma_addr_to_phys(struct device *dev, dma_addr_t dma_addr)
diff --git a/arch/mips/include/asm/mach-ath25/dma-coherence.h b/arch/mips/include/asm/mach-ath25/dma-coherence.h
index d5defdd..4330de6 100644
--- a/arch/mips/include/asm/mach-ath25/dma-coherence.h
+++ b/arch/mips/include/asm/mach-ath25/dma-coherence.h
@@ -31,15 +31,9 @@ static inline dma_addr_t ath25_dev_offset(struct device *dev)
 }
 
 static inline dma_addr_t
-plat_map_dma_mem(struct device *dev, void *addr, size_t size)
+plat_map_dma_mem(struct device *dev, phys_addr_t phys, size_t size)
 {
-	return virt_to_phys(addr) + ath25_dev_offset(dev);
-}
-
-static inline dma_addr_t
-plat_map_dma_mem_page(struct device *dev, struct page *page)
-{
-	return page_to_phys(page) + ath25_dev_offset(dev);
+	return phys + ath25_dev_offset(dev);
 }
 
 static inline unsigned long
diff --git a/arch/mips/include/asm/mach-bmips/dma-coherence.h b/arch/mips/include/asm/mach-bmips/dma-coherence.h
index d29781f..1b9a7f4 100644
--- a/arch/mips/include/asm/mach-bmips/dma-coherence.h
+++ b/arch/mips/include/asm/mach-bmips/dma-coherence.h
@@ -21,8 +21,8 @@
 
 struct device;
 
-extern dma_addr_t plat_map_dma_mem(struct device *dev, void *addr, size_t size);
-extern dma_addr_t plat_map_dma_mem_page(struct device *dev, struct page *page);
+extern dma_addr_t plat_map_dma_mem(struct device *dev, phys_addr_t phys,
+		size_t size);
 extern unsigned long plat_dma_addr_to_phys(struct device *dev,
 	dma_addr_t dma_addr);
 
diff --git a/arch/mips/include/asm/mach-cavium-octeon/dma-coherence.h b/arch/mips/include/asm/mach-cavium-octeon/dma-coherence.h
index 460042e..d0988c7 100644
--- a/arch/mips/include/asm/mach-cavium-octeon/dma-coherence.h
+++ b/arch/mips/include/asm/mach-cavium-octeon/dma-coherence.h
@@ -19,15 +19,8 @@ struct device;
 
 extern void octeon_pci_dma_init(void);
 
-static inline dma_addr_t plat_map_dma_mem(struct device *dev, void *addr,
-	size_t size)
-{
-	BUG();
-	return 0;
-}
-
-static inline dma_addr_t plat_map_dma_mem_page(struct device *dev,
-	struct page *page)
+static inline dma_addr_t plat_map_dma_mem(struct device *dev, phys_addr_t phys,
+		size_t size)
 {
 	BUG();
 	return 0;
diff --git a/arch/mips/include/asm/mach-generic/dma-coherence.h b/arch/mips/include/asm/mach-generic/dma-coherence.h
index 0f8a354..2dfb133 100644
--- a/arch/mips/include/asm/mach-generic/dma-coherence.h
+++ b/arch/mips/include/asm/mach-generic/dma-coherence.h
@@ -11,16 +11,10 @@
 
 struct device;
 
-static inline dma_addr_t plat_map_dma_mem(struct device *dev, void *addr,
-	size_t size)
+static inline dma_addr_t plat_map_dma_mem(struct device *dev, phys_addr_t phys,
+		size_t size)
 {
-	return virt_to_phys(addr);
-}
-
-static inline dma_addr_t plat_map_dma_mem_page(struct device *dev,
-	struct page *page)
-{
-	return page_to_phys(page);
+	return phys;
 }
 
 static inline unsigned long plat_dma_addr_to_phys(struct device *dev,
diff --git a/arch/mips/include/asm/mach-ip27/dma-coherence.h b/arch/mips/include/asm/mach-ip27/dma-coherence.h
index 1daa644..2578b9d 100644
--- a/arch/mips/include/asm/mach-ip27/dma-coherence.h
+++ b/arch/mips/include/asm/mach-ip27/dma-coherence.h
@@ -18,20 +18,10 @@
 
 struct device;
 
-static inline dma_addr_t plat_map_dma_mem(struct device *dev, void *addr,
-	size_t size)
+static inline dma_addr_t plat_map_dma_mem(struct device *dev, phys_addr_t phys,
+		size_t size)
 {
-	dma_addr_t pa = dev_to_baddr(dev, virt_to_phys(addr));
-
-	return pa;
-}
-
-static inline dma_addr_t plat_map_dma_mem_page(struct device *dev,
-	struct page *page)
-{
-	dma_addr_t pa = dev_to_baddr(dev, page_to_phys(page));
-
-	return pa;
+	return dev_to_baddr(dev, phys);
 }
 
 static inline unsigned long plat_dma_addr_to_phys(struct device *dev,
diff --git a/arch/mips/include/asm/mach-ip32/dma-coherence.h b/arch/mips/include/asm/mach-ip32/dma-coherence.h
index 0a0b0e2..a5e8d75 100644
--- a/arch/mips/include/asm/mach-ip32/dma-coherence.h
+++ b/arch/mips/include/asm/mach-ip32/dma-coherence.h
@@ -26,23 +26,10 @@ struct device;
 
 #define RAM_OFFSET_MASK 0x3fffffffUL
 
-static inline dma_addr_t plat_map_dma_mem(struct device *dev, void *addr,
-	size_t size)
+static inline dma_addr_t plat_map_dma_mem(struct device *dev, phys_addr_t phys,
+		size_t size)
 {
-	dma_addr_t pa = virt_to_phys(addr) & RAM_OFFSET_MASK;
-
-	if (dev = NULL)
-		pa += CRIME_HI_MEM_BASE;
-
-	return pa;
-}
-
-static inline dma_addr_t plat_map_dma_mem_page(struct device *dev,
-	struct page *page)
-{
-	dma_addr_t pa;
-
-	pa = page_to_phys(page) & RAM_OFFSET_MASK;
+	dma_addr_t pa = phys & RAM_OFFSET_MASK;
 
 	if (dev = NULL)
 		pa += CRIME_HI_MEM_BASE;
diff --git a/arch/mips/include/asm/mach-jazz/dma-coherence.h b/arch/mips/include/asm/mach-jazz/dma-coherence.h
index dc347c2..7739782 100644
--- a/arch/mips/include/asm/mach-jazz/dma-coherence.h
+++ b/arch/mips/include/asm/mach-jazz/dma-coherence.h
@@ -12,15 +12,10 @@
 
 struct device;
 
-static inline dma_addr_t plat_map_dma_mem(struct device *dev, void *addr, size_t size)
+static inline dma_addr_t plat_map_dma_mem(struct device *dev, phys_addr_t phys,
+		size_t size)
 {
-	return vdma_alloc(virt_to_phys(addr), size);
-}
-
-static inline dma_addr_t plat_map_dma_mem_page(struct device *dev,
-	struct page *page)
-{
-	return vdma_alloc(page_to_phys(page), PAGE_SIZE);
+	return vdma_alloc(phys, size);
 }
 
 static inline unsigned long plat_dma_addr_to_phys(struct device *dev,
diff --git a/arch/mips/include/asm/mach-loongson64/dma-coherence.h b/arch/mips/include/asm/mach-loongson64/dma-coherence.h
index 1602a9e..a75d4ba 100644
--- a/arch/mips/include/asm/mach-loongson64/dma-coherence.h
+++ b/arch/mips/include/asm/mach-loongson64/dma-coherence.h
@@ -19,23 +19,13 @@ struct device;
 
 extern dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr);
 extern phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr);
-static inline dma_addr_t plat_map_dma_mem(struct device *dev, void *addr,
+static inline dma_addr_t plat_map_dma_mem(struct device *dev, phys_addr_t phys,
 					  size_t size)
 {
 #ifdef CONFIG_CPU_LOONGSON3
-	return phys_to_dma(dev, virt_to_phys(addr));
+	return phys_to_dma(dev, phys);
 #else
-	return virt_to_phys(addr) | 0x80000000;
-#endif
-}
-
-static inline dma_addr_t plat_map_dma_mem_page(struct device *dev,
-					       struct page *page)
-{
-#ifdef CONFIG_CPU_LOONGSON3
-	return phys_to_dma(dev, page_to_phys(page));
-#else
-	return page_to_phys(page) | 0x80000000;
+	return phys | 0x80000000;
 #endif
 }
 
diff --git a/arch/mips/mm/dma-default.c b/arch/mips/mm/dma-default.c
index eeaf024..409fdc8 100644
--- a/arch/mips/mm/dma-default.c
+++ b/arch/mips/mm/dma-default.c
@@ -123,7 +123,7 @@ void *dma_alloc_noncoherent(struct device *dev, size_t size,
 
 	if (ret != NULL) {
 		memset(ret, 0, size);
-		*dma_handle = plat_map_dma_mem(dev, ret, size);
+		*dma_handle = plat_map_dma_mem(dev, virt_to_phys(ret), size);
 	}
 
 	return ret;
@@ -153,7 +153,7 @@ static void *mips_dma_alloc_coherent(struct device *dev, size_t size,
 
 	ret = page_address(page);
 	memset(ret, 0, size);
-	*dma_handle = plat_map_dma_mem(dev, ret, size);
+	*dma_handle = plat_map_dma_mem(dev, virt_to_phys(ret), size);
 	if (!plat_device_is_coherent(dev)) {
 		dma_cache_wback_inv((unsigned long) ret, size);
 		if (!hw_coherentio)
@@ -269,14 +269,13 @@ static int mips_dma_map_sg(struct device *dev, struct scatterlist *sglist,
 	struct scatterlist *sg;
 
 	for_each_sg(sglist, sg, nents, i) {
-		if (!plat_device_is_coherent(dev))
+		if (sg_has_page(sg) && !plat_device_is_coherent(dev))
 			__dma_sync(sg_page(sg), sg->offset, sg->length,
 				   direction);
 #ifdef CONFIG_NEED_SG_DMA_LENGTH
 		sg->dma_length = sg->length;
 #endif
-		sg->dma_address = plat_map_dma_mem_page(dev, sg_page(sg)) +
-				  sg->offset;
+		sg->dma_address = plat_map_dma_mem(dev, sg_phys(sg), PAGE_SIZE);
 	}
 
 	return nents;
@@ -289,7 +288,7 @@ static dma_addr_t mips_dma_map_page(struct device *dev, struct page *page,
 	if (!plat_device_is_coherent(dev))
 		__dma_sync(page, offset, size, direction);
 
-	return plat_map_dma_mem_page(dev, page) + offset;
+	return plat_map_dma_mem(dev, page_to_phys(page), PAGE_SIZE) + offset;
 }
 
 static void mips_dma_unmap_sg(struct device *dev, struct scatterlist *sglist,
@@ -300,7 +299,7 @@ static void mips_dma_unmap_sg(struct device *dev, struct scatterlist *sglist,
 	struct scatterlist *sg;
 
 	for_each_sg(sglist, sg, nhwentries, i) {
-		if (!plat_device_is_coherent(dev) &&
+		if (sg_has_page(sg) && !plat_device_is_coherent(dev) &&
 		    direction != DMA_TO_DEVICE)
 			__dma_sync(sg_page(sg), sg->offset, sg->length,
 				   direction);
@@ -334,8 +333,10 @@ static void mips_dma_sync_sg_for_cpu(struct device *dev,
 
 	if (cpu_needs_post_dma_flush(dev)) {
 		for_each_sg(sglist, sg, nelems, i) {
-			__dma_sync(sg_page(sg), sg->offset, sg->length,
-				   direction);
+			if (sg_has_page(sg)) {
+				__dma_sync(sg_page(sg), sg->offset, sg->length,
+					   direction);
+			}
 		}
 	}
 	plat_post_dma_flush(dev);
@@ -350,8 +351,10 @@ static void mips_dma_sync_sg_for_device(struct device *dev,
 
 	if (!plat_device_is_coherent(dev)) {
 		for_each_sg(sglist, sg, nelems, i) {
-			__dma_sync(sg_page(sg), sg->offset, sg->length,
-				   direction);
+			if (sg_has_page(sg)) {
+				__dma_sync(sg_page(sg), sg->offset, sg->length,
+					   direction);
+			}
 		}
 	}
 }
-- 
1.9.1

