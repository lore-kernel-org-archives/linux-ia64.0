From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 17 Sep 2003 22:31:11 +0000
Subject: [PATCH] trivial 2.5 sba_iommu patch
Message-Id: <marc-linux-ia64-106383887224319@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm aligning the 2.4 and 2.5 versions of arch/ia64/hp/common/sba_iommu.c
and found a couple nits in the 2.5 version.  No functional change, just
whitespace, comment, and parameter name changes (and I made
one function static).


=== arch/ia64/hp/common/sba_iommu.c 1.30 vs edited ==--- 1.30/arch/ia64/hp/common/sba_iommu.c	Mon Sep  8 14:51:17 2003
+++ edited/arch/ia64/hp/common/sba_iommu.c	Wed Sep 17 17:59:27 2003
@@ -957,20 +957,20 @@
 
 
 /**
- * sba_alloc_consistent - allocate/map shared mem for DMA
- * @hwdev: instance of PCI owned by the driver that's asking.
+ * sba_alloc_coherent - allocate/map shared mem for DMA
+ * @dev: instance of PCI owned by the driver that's asking.
  * @size:  number of bytes mapped in driver buffer.
  * @dma_handle:  IOVA of new buffer.
  *
  * See Documentation/DMA-mapping.txt
  */
 void *
-sba_alloc_coherent (struct device *hwdev, size_t size, dma_addr_t *dma_handle, int flags)
+sba_alloc_coherent (struct device *dev, size_t size, dma_addr_t *dma_handle, int flags)
 {
 	struct ioc *ioc;
 	void *addr;
 
-        addr = (void *) __get_free_pages(flags, get_order(size));
+	addr = (void *) __get_free_pages(flags, get_order(size));
 	if (!addr)
 		return NULL;
 
@@ -978,7 +978,7 @@
 	 * REVISIT: if sba_map_single starts needing more than dma_mask from the
 	 * device, this needs to be updated.
 	 */
-	ioc = GET_IOC(hwdev);
+	ioc = GET_IOC(dev);
 	ASSERT(ioc);
 	*dma_handle = sba_map_single(&ioc->sac_only_dev->dev, addr, size, 0);
 
@@ -988,17 +988,17 @@
 
 
 /**
- * sba_free_consistent - free/unmap shared mem for DMA
- * @hwdev: instance of PCI owned by the driver that's asking.
+ * sba_free_coherent - free/unmap shared mem for DMA
+ * @dev: instance of PCI owned by the driver that's asking.
  * @size:  number of bytes mapped in driver buffer.
  * @vaddr:  virtual address IOVA of "consistent" buffer.
  * @dma_handler:  IO virtual address of "consistent" buffer.
  *
  * See Documentation/DMA-mapping.txt
  */
-void sba_free_coherent (struct device *hwdev, size_t size, void *vaddr, dma_addr_t dma_handle)
+void sba_free_coherent (struct device *dev, size_t size, void *vaddr, dma_addr_t dma_handle)
 {
-	sba_unmap_single(hwdev, dma_handle, size, 0);
+	sba_unmap_single(dev, dma_handle, size, 0);
 	free_pages((unsigned long) vaddr, get_order(size));
 }
 
@@ -1758,7 +1758,7 @@
 		if (ioc->avg_search[i] > max) max = ioc->avg_search[i];
 		if (ioc->avg_search[i] < min) min = ioc->avg_search[i];
 	}
-  	avg /= SBA_SEARCH_SAMPLE;
+	avg /= SBA_SEARCH_SAMPLE;
 	seq_printf(s, "  Bitmap search : %ld/%ld/%ld (min/avg/max CPU Cycles)\n", min, avg, max);
 
 	seq_printf(s, "pci_map_single(): %12ld calls  %12ld pages (avg %d/1000)\n",
@@ -1859,7 +1859,7 @@
 }
 #endif
 
-void
+static void
 sba_connect_bus(struct pci_bus *bus)
 {
 	acpi_handle handle, parent;
@@ -1867,7 +1867,7 @@
 	struct ioc *ioc;
 
 	if (!PCI_CONTROLLER(bus))
-		panic(PFX "no sysdata on bus %d!\n",bus->number);
+		panic(PFX "no sysdata on bus %d!\n", bus->number);
 
 	if (PCI_CONTROLLER(bus)->iommu)
 		return;

