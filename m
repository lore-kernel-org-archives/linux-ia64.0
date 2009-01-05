From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Mon, 05 Jan 2009 14:36:15 +0000
Subject: [PATCH 10/13] make sn DMA mapping functions static
Message-Id: <1231166178-20050-11-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1231166178-20050-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-3-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-4-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-5-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-6-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-7-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-8-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-9-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-10-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1231166178-20050-10-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

Now we don't need to export sn DMA mapping functions.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 arch/ia64/sn/pci/pci_dma.c |   64 ++++++++++++++++++--------------------------
 1 files changed, 26 insertions(+), 38 deletions(-)

diff --git a/arch/ia64/sn/pci/pci_dma.c b/arch/ia64/sn/pci/pci_dma.c
index 174a74e..efdd694 100644
--- a/arch/ia64/sn/pci/pci_dma.c
+++ b/arch/ia64/sn/pci/pci_dma.c
@@ -32,7 +32,7 @@
  * this function.  Of course, SN only supports devices that have 32 or more
  * address bits when using the PMU.
  */
-int sn_dma_supported(struct device *dev, u64 mask)
+static int sn_dma_supported(struct device *dev, u64 mask)
 {
 	BUG_ON(dev->bus != &pci_bus_type);
 
@@ -40,7 +40,6 @@ int sn_dma_supported(struct device *dev, u64 mask)
 		return 0;
 	return 1;
 }
-EXPORT_SYMBOL(sn_dma_supported);
 
 /**
  * sn_dma_set_mask - set the DMA mask
@@ -76,8 +75,8 @@ EXPORT_SYMBOL(sn_dma_set_mask);
  * queue for a SCSI controller).  See Documentation/DMA-API.txt for
  * more information.
  */
-void *sn_dma_alloc_coherent(struct device *dev, size_t size,
-			    dma_addr_t * dma_handle, gfp_t flags)
+static void *sn_dma_alloc_coherent(struct device *dev, size_t size,
+				   dma_addr_t * dma_handle, gfp_t flags)
 {
 	void *cpuaddr;
 	unsigned long phys_addr;
@@ -125,7 +124,6 @@ void *sn_dma_alloc_coherent(struct device *dev, size_t size,
 
 	return cpuaddr;
 }
-EXPORT_SYMBOL(sn_dma_alloc_coherent);
 
 /**
  * sn_pci_free_coherent - free memory associated with coherent DMAable region
@@ -137,8 +135,8 @@ EXPORT_SYMBOL(sn_dma_alloc_coherent);
  * Frees the memory allocated by dma_alloc_coherent(), potentially unmapping
  * any associated IOMMU mappings.
  */
-void sn_dma_free_coherent(struct device *dev, size_t size, void *cpu_addr,
-			  dma_addr_t dma_handle)
+static void sn_dma_free_coherent(struct device *dev, size_t size, void *cpu_addr,
+				 dma_addr_t dma_handle)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
 	struct sn_pcibus_provider *provider = SN_PCIDEV_BUSPROVIDER(pdev);
@@ -148,7 +146,6 @@ void sn_dma_free_coherent(struct device *dev, size_t size, void *cpu_addr,
 	provider->dma_unmap(pdev, dma_handle, 0);
 	free_pages((unsigned long)cpu_addr, get_order(size));
 }
-EXPORT_SYMBOL(sn_dma_free_coherent);
 
 /**
  * sn_dma_map_single_attrs - map a single page for DMA
@@ -174,9 +171,9 @@ EXPORT_SYMBOL(sn_dma_free_coherent);
  * TODO: simplify our interface;
  *       figure out how to save dmamap handle so can use two step.
  */
-dma_addr_t sn_dma_map_single_attrs(struct device *dev, void *cpu_addr,
-				   size_t size, int direction,
-				   struct dma_attrs *attrs)
+static dma_addr_t sn_dma_map_single_attrs(struct device *dev, void *cpu_addr,
+					  size_t size, int direction,
+					  struct dma_attrs *attrs)
 {
 	dma_addr_t dma_addr;
 	unsigned long phys_addr;
@@ -202,7 +199,6 @@ dma_addr_t sn_dma_map_single_attrs(struct device *dev, void *cpu_addr,
 	}
 	return dma_addr;
 }
-EXPORT_SYMBOL(sn_dma_map_single_attrs);
 
 /**
  * sn_dma_unmap_single_attrs - unamp a DMA mapped page
@@ -216,9 +212,9 @@ EXPORT_SYMBOL(sn_dma_map_single_attrs);
  * by @dma_handle into the coherence domain.  On SN, we're always cache
  * coherent, so we just need to free any ATEs associated with this mapping.
  */
-void sn_dma_unmap_single_attrs(struct device *dev, dma_addr_t dma_addr,
-			       size_t size, int direction,
-			       struct dma_attrs *attrs)
+static void sn_dma_unmap_single_attrs(struct device *dev, dma_addr_t dma_addr,
+				      size_t size, int direction,
+				      struct dma_attrs *attrs)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
 	struct sn_pcibus_provider *provider = SN_PCIDEV_BUSPROVIDER(pdev);
@@ -227,7 +223,6 @@ void sn_dma_unmap_single_attrs(struct device *dev, dma_addr_t dma_addr,
 
 	provider->dma_unmap(pdev, dma_addr, direction);
 }
-EXPORT_SYMBOL(sn_dma_unmap_single_attrs);
 
 /**
  * sn_dma_unmap_sg_attrs - unmap a DMA scatterlist
@@ -239,9 +234,9 @@ EXPORT_SYMBOL(sn_dma_unmap_single_attrs);
  *
  * Unmap a set of streaming mode DMA translations.
  */
-void sn_dma_unmap_sg_attrs(struct device *dev, struct scatterlist *sgl,
-			   int nhwentries, int direction,
-			   struct dma_attrs *attrs)
+static void sn_dma_unmap_sg_attrs(struct device *dev, struct scatterlist *sgl,
+				  int nhwentries, int direction,
+				  struct dma_attrs *attrs)
 {
 	int i;
 	struct pci_dev *pdev = to_pci_dev(dev);
@@ -256,7 +251,6 @@ void sn_dma_unmap_sg_attrs(struct device *dev, struct scatterlist *sgl,
 		sg->dma_length = 0;
 	}
 }
-EXPORT_SYMBOL(sn_dma_unmap_sg_attrs);
 
 /**
  * sn_dma_map_sg_attrs - map a scatterlist for DMA
@@ -273,8 +267,8 @@ EXPORT_SYMBOL(sn_dma_unmap_sg_attrs);
  *
  * Maps each entry of @sg for DMA.
  */
-int sn_dma_map_sg_attrs(struct device *dev, struct scatterlist *sgl,
-			int nhwentries, int direction, struct dma_attrs *attrs)
+static int sn_dma_map_sg_attrs(struct device *dev, struct scatterlist *sgl,
+			       int nhwentries, int direction, struct dma_attrs *attrs)
 {
 	unsigned long phys_addr;
 	struct scatterlist *saved_sg = sgl, *sg;
@@ -321,41 +315,35 @@ int sn_dma_map_sg_attrs(struct device *dev, struct scatterlist *sgl,
 
 	return nhwentries;
 }
-EXPORT_SYMBOL(sn_dma_map_sg_attrs);
 
-void sn_dma_sync_single_for_cpu(struct device *dev, dma_addr_t dma_handle,
-				size_t size, int direction)
+static void sn_dma_sync_single_for_cpu(struct device *dev, dma_addr_t dma_handle,
+				       size_t size, int direction)
 {
 	BUG_ON(dev->bus != &pci_bus_type);
 }
-EXPORT_SYMBOL(sn_dma_sync_single_for_cpu);
 
-void sn_dma_sync_single_for_device(struct device *dev, dma_addr_t dma_handle,
-				   size_t size, int direction)
+static void sn_dma_sync_single_for_device(struct device *dev, dma_addr_t dma_handle,
+					  size_t size, int direction)
 {
 	BUG_ON(dev->bus != &pci_bus_type);
 }
-EXPORT_SYMBOL(sn_dma_sync_single_for_device);
 
-void sn_dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
-			    int nelems, int direction)
+static void sn_dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
+				   int nelems, int direction)
 {
 	BUG_ON(dev->bus != &pci_bus_type);
 }
-EXPORT_SYMBOL(sn_dma_sync_sg_for_cpu);
 
-void sn_dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
-			       int nelems, int direction)
+static void sn_dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
+				      int nelems, int direction)
 {
 	BUG_ON(dev->bus != &pci_bus_type);
 }
-EXPORT_SYMBOL(sn_dma_sync_sg_for_device);
 
-int sn_dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
+static int sn_dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 {
 	return 0;
 }
-EXPORT_SYMBOL(sn_dma_mapping_error);
 
 char *sn_pci_get_legacy_mem(struct pci_bus *bus)
 {
@@ -467,7 +455,7 @@ int sn_pci_legacy_write(struct pci_bus *bus, u16 port, u32 val, u8 size)
 	return ret;
 }
 
-struct dma_mapping_ops sn_dma_ops = {
+static struct dma_mapping_ops sn_dma_ops = {
 	.alloc_coherent		= sn_dma_alloc_coherent,
 	.free_coherent		= sn_dma_free_coherent,
 	.map_single_attrs	= sn_dma_map_single_attrs,
-- 
1.6.0.6

