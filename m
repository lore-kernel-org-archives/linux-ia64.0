From: Christoph Hellwig <hch@lst.de>
Date: Fri, 30 Nov 2018 13:22:20 +0000
Subject: [PATCH 12/23] ia64/sba_iommu: improve internal map_page users
Message-Id: <20181130132231.16512-13-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181130132231.16512-1-hch@lst.de>
In-Reply-To: <20181130132231.16512-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jon Mason <jdmason@kudzu.us>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Remove the odd sba_{un,}map_single_attrs wrappers, check errors
everywhere.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/hp/common/sba_iommu.c | 73 +++++++++++++--------------------
 1 file changed, 29 insertions(+), 44 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index e8a93b07283e..c56f28c98102 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -907,11 +907,12 @@ sba_mark_invalid(struct ioc *ioc, dma_addr_t iova, size_t byte_cnt)
 }
 
 /**
- * sba_map_single_attrs - map one buffer and return IOVA for DMA
+ * sba_map_page - map one buffer and return IOVA for DMA
  * @dev: instance of PCI owned by the driver that's asking.
- * @addr:  driver buffer to map.
- * @size:  number of bytes to map in driver buffer.
- * @dir:  R/W or both.
+ * @page: page to map
+ * @poff: offset into page
+ * @size: number of bytes to map
+ * @dir: dma direction
  * @attrs: optional dma attributes
  *
  * See Documentation/DMA-API-HOWTO.txt
@@ -944,7 +945,7 @@ static dma_addr_t sba_map_page(struct device *dev, struct page *page,
  		** Device is bit capable of DMA'ing to the buffer...
 		** just return the PCI address of ptr
  		*/
-		DBG_BYPASS("sba_map_single_attrs() bypass mask/addr: "
+		DBG_BYPASS("sba_map_page() bypass mask/addr: "
 			   "0x%lx/0x%lx\n",
 		           to_pci_dev(dev)->dma_mask, pci_addr);
 		return pci_addr;
@@ -966,7 +967,7 @@ static dma_addr_t sba_map_page(struct device *dev, struct page *page,
 
 #ifdef ASSERT_PDIR_SANITY
 	spin_lock_irqsave(&ioc->res_lock, flags);
-	if (sba_check_pdir(ioc,"Check before sba_map_single_attrs()"))
+	if (sba_check_pdir(ioc,"Check before sba_map_page()"))
 		panic("Sanity check failed");
 	spin_unlock_irqrestore(&ioc->res_lock, flags);
 #endif
@@ -997,20 +998,12 @@ static dma_addr_t sba_map_page(struct device *dev, struct page *page,
 	/* form complete address */
 #ifdef ASSERT_PDIR_SANITY
 	spin_lock_irqsave(&ioc->res_lock, flags);
-	sba_check_pdir(ioc,"Check after sba_map_single_attrs()");
+	sba_check_pdir(ioc,"Check after sba_map_page()");
 	spin_unlock_irqrestore(&ioc->res_lock, flags);
 #endif
 	return SBA_IOVA(ioc, iovp, offset);
 }
 
-static dma_addr_t sba_map_single_attrs(struct device *dev, void *addr,
-				       size_t size, enum dma_data_direction dir,
-				       unsigned long attrs)
-{
-	return sba_map_page(dev, virt_to_page(addr),
-			    (unsigned long)addr & ~PAGE_MASK, size, dir, attrs);
-}
-
 #ifdef ENABLE_MARK_CLEAN
 static SBA_INLINE void
 sba_mark_clean(struct ioc *ioc, dma_addr_t iova, size_t size)
@@ -1036,7 +1029,7 @@ sba_mark_clean(struct ioc *ioc, dma_addr_t iova, size_t size)
 #endif
 
 /**
- * sba_unmap_single_attrs - unmap one IOVA and free resources
+ * sba_unmap_page - unmap one IOVA and free resources
  * @dev: instance of PCI owned by the driver that's asking.
  * @iova:  IOVA of driver buffer previously mapped.
  * @size:  number of bytes mapped in driver buffer.
@@ -1063,7 +1056,7 @@ static void sba_unmap_page(struct device *dev, dma_addr_t iova, size_t size,
 		/*
 		** Address does not fall w/in IOVA, must be bypassing
 		*/
-		DBG_BYPASS("sba_unmap_single_attrs() bypass addr: 0x%lx\n",
+		DBG_BYPASS("sba_unmap_page() bypass addr: 0x%lx\n",
 			   iova);
 
 #ifdef ENABLE_MARK_CLEAN
@@ -1114,12 +1107,6 @@ static void sba_unmap_page(struct device *dev, dma_addr_t iova, size_t size,
 #endif /* DELAYED_RESOURCE_CNT = 0 */
 }
 
-void sba_unmap_single_attrs(struct device *dev, dma_addr_t iova, size_t size,
-			    enum dma_data_direction dir, unsigned long attrs)
-{
-	sba_unmap_page(dev, iova, size, dir, attrs);
-}
-
 /**
  * sba_alloc_coherent - allocate/map shared mem for DMA
  * @dev: instance of PCI owned by the driver that's asking.
@@ -1132,30 +1119,24 @@ static void *
 sba_alloc_coherent(struct device *dev, size_t size, dma_addr_t *dma_handle,
 		   gfp_t flags, unsigned long attrs)
 {
+	struct page *page;
 	struct ioc *ioc;
+	int node = -1;
 	void *addr;
 
 	ioc = GET_IOC(dev);
 	ASSERT(ioc);
-
 #ifdef CONFIG_NUMA
-	{
-		struct page *page;
-
-		page = alloc_pages_node(ioc->node, flags, get_order(size));
-		if (unlikely(!page))
-			return NULL;
-
-		addr = page_address(page);
-	}
-#else
-	addr = (void *) __get_free_pages(flags, get_order(size));
+	node = ioc->node;
 #endif
-	if (unlikely(!addr))
+
+	page = alloc_pages_node(node, flags, get_order(size));
+	if (unlikely(!page))
 		return NULL;
 
+	addr = page_address(page);
 	memset(addr, 0, size);
-	*dma_handle = virt_to_phys(addr);
+	*dma_handle = page_to_phys(page);
 
 #ifdef ALLOW_IOV_BYPASS
 	ASSERT(dev->coherent_dma_mask);
@@ -1174,9 +1155,10 @@ sba_alloc_coherent(struct device *dev, size_t size, dma_addr_t *dma_handle,
 	 * If device can't bypass or bypass is disabled, pass the 32bit fake
 	 * device to map single to get an iova mapping.
 	 */
-	*dma_handle = sba_map_single_attrs(&ioc->sac_only_dev->dev, addr,
-					   size, 0, 0);
-
+	*dma_handle = sba_map_page(&ioc->sac_only_dev->dev, page, 0, size,
+			DMA_BIDIRECTIONAL, 0);
+	if (dma_mapping_error(dev, *dma_handle))
+		return NULL;
 	return addr;
 }
 
@@ -1193,7 +1175,7 @@ sba_alloc_coherent(struct device *dev, size_t size, dma_addr_t *dma_handle,
 static void sba_free_coherent(struct device *dev, size_t size, void *vaddr,
 			      dma_addr_t dma_handle, unsigned long attrs)
 {
-	sba_unmap_single_attrs(dev, dma_handle, size, 0, 0);
+	sba_unmap_page(dev, dma_handle, size, 0, 0);
 	free_pages((unsigned long) vaddr, get_order(size));
 }
 
@@ -1483,7 +1465,10 @@ static int sba_map_sg_attrs(struct device *dev, struct scatterlist *sglist,
 	/* Fast path single entry scatterlists. */
 	if (nents = 1) {
 		sglist->dma_length = sglist->length;
-		sglist->dma_address = sba_map_single_attrs(dev, sba_sg_address(sglist), sglist->length, dir, attrs);
+		sglist->dma_address = sba_map_page(dev, sg_page(sglist),
+				sglist->offset, sglist->length, dir, attrs);
+		if (dma_mapping_error(dev, sglist->dma_address))
+			return 0;
 		return 1;
 	}
 
@@ -1572,8 +1557,8 @@ static void sba_unmap_sg_attrs(struct device *dev, struct scatterlist *sglist,
 
 	while (nents && sglist->dma_length) {
 
-		sba_unmap_single_attrs(dev, sglist->dma_address,
-				       sglist->dma_length, dir, attrs);
+		sba_unmap_page(dev, sglist->dma_address, sglist->dma_length,
+			       dir, attrs);
 		sglist = sg_next(sglist);
 		nents--;
 	}
-- 
2.19.1
