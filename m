From: Suresh Siddha <suresh.b.siddha@intel.com>
Date: Thu, 07 Oct 2004 02:44:52 +0000
Subject: [Patch] swiotlb: fallback to swiotlb for consistent DMA mappings
Message-Id: <20041006194452.B10900@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is mainly needed for EM64T platforms and makes sense for ia64 too. 
Need of this was broughtup sometime(long time?) back on lkml.
http://www.ussg.iu.edu/hypermail/linux/kernel/0406.3/0112.html

Appended patch does this.

thanks,
suresh
--

Fallback to swiotlb for pci consistent DMA mappings. On EM64T, this will
increase the practical size limit of pci_alloc_consistent mappings above
16MB. This makes sense on IA64 too under extreme conditions.

Signed-off-by: Suresh Siddha <suresh.b.siddha@intel.com>


diff -Nrup linux/arch/ia64/lib/swiotlb.c linux-swiotlb/arch/ia64/lib/swiotlb.c
--- linux/arch/ia64/lib/swiotlb.c	2004-09-03 04:01:58.000000000 -0700
+++ linux-swiotlb/arch/ia64/lib/swiotlb.c	2004-09-03 06:33:54.040063240 -0700
@@ -305,8 +305,15 @@ swiotlb_alloc_coherent (struct device *h
 	flags |= GFP_DMA;
 
 	ret = (void *)__get_free_pages(flags, get_order(size));
-	if (!ret)
-		return NULL;
+	if (!ret) {
+		 /* DMA_FROM_DEVICE is to avoid the memcpy in map_single */
+		dma_addr_t handle;
+		handle = swiotlb_map_single(NULL, NULL, size, DMA_FROM_DEVICE);
+		if (dma_mapping_error(handle))
+			return NULL;
+
+		ret = phys_to_virt(handle);
+	}
 
 	memset(ret, 0, size);
 	dev_addr = virt_to_phys(ret);
@@ -319,7 +326,12 @@ swiotlb_alloc_coherent (struct device *h
 void
 swiotlb_free_coherent (struct device *hwdev, size_t size, void *vaddr, dma_addr_t dma_handle)
 {
-	free_pages((unsigned long) vaddr, get_order(size));
+	if (!(vaddr >= (void *)io_tlb_start
+                    && vaddr < (void *)io_tlb_end))
+		free_pages((unsigned long) vaddr, get_order(size));
+	else
+		/* DMA_TO_DEVICE to avoid memcpy in unmap_single */
+		swiotlb_unmap_single (hwdev, dma_handle, size, DMA_TO_DEVICE);
 }
 
 static void swiotlb_full(struct device *dev, size_t size, int dir, int do_panic)
