From: Christoph Hellwig <hch@lst.de>
Date: Wed, 12 Aug 2015 07:05:26 +0000
Subject: [PATCH 07/31] alpha/pci_iommu: handle page-less SG entries
Message-Id: <1439363150-8661-8-git-send-email-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439363150-8661-1-git-send-email-hch@lst.de>
In-Reply-To: <1439363150-8661-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, axboe@kernel.dk
Cc: dan.j.williams@intel.com, vgupta@synopsys.com, hskinnemoen@gmail.com, egtvedt@samfundet.no, realmz6@gmail.com, dhowells@redhat.com, monstr@monstr.eu, x86@kernel.org, dwmw2@infradead.org, alex.williamson@redhat.com, grundler@parisc-linux.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-nvdimm@ml01.01.org, linux-media@vger.kernel.org

Use sg_phys() instead of virt_to_phys(sg_virt(sg)) so that we don't
require a kernel virtual address, and switch a few debug printfs to
print physical instead of virtual addresses.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/alpha/kernel/pci_iommu.c | 36 +++++++++++++++---------------------
 1 file changed, 15 insertions(+), 21 deletions(-)

diff --git a/arch/alpha/kernel/pci_iommu.c b/arch/alpha/kernel/pci_iommu.c
index eddee77..5d46b49 100644
--- a/arch/alpha/kernel/pci_iommu.c
+++ b/arch/alpha/kernel/pci_iommu.c
@@ -248,20 +248,17 @@ static int pci_dac_dma_supported(struct pci_dev *dev, u64 mask)
    until either pci_unmap_single or pci_dma_sync_single is performed.  */
 
 static dma_addr_t
-pci_map_single_1(struct pci_dev *pdev, void *cpu_addr, size_t size,
+pci_map_single_1(struct pci_dev *pdev, unsigned long paddr, size_t size,
 		 int dac_allowed)
 {
 	struct pci_controller *hose = pdev ? pdev->sysdata : pci_isa_hose;
 	dma_addr_t max_dma = pdev ? pdev->dma_mask : ISA_DMA_MASK;
 	struct pci_iommu_arena *arena;
 	long npages, dma_ofs, i;
-	unsigned long paddr;
 	dma_addr_t ret;
 	unsigned int align = 0;
 	struct device *dev = pdev ? &pdev->dev : NULL;
 
-	paddr = __pa(cpu_addr);
-
 #if !DEBUG_NODIRECT
 	/* First check to see if we can use the direct map window.  */
 	if (paddr + size + __direct_map_base - 1 <= max_dma
@@ -269,7 +266,7 @@ pci_map_single_1(struct pci_dev *pdev, void *cpu_addr, size_t size,
 		ret = paddr + __direct_map_base;
 
 		DBGA2("pci_map_single: [%p,%zx] -> direct %llx from %pf\n",
-		      cpu_addr, size, ret, __builtin_return_address(0));
+		      paddr, size, ret, __builtin_return_address(0));
 
 		return ret;
 	}
@@ -280,7 +277,7 @@ pci_map_single_1(struct pci_dev *pdev, void *cpu_addr, size_t size,
 		ret = paddr + alpha_mv.pci_dac_offset;
 
 		DBGA2("pci_map_single: [%p,%zx] -> DAC %llx from %pf\n",
-		      cpu_addr, size, ret, __builtin_return_address(0));
+		      paddr, size, ret, __builtin_return_address(0));
 
 		return ret;
 	}
@@ -309,15 +306,15 @@ pci_map_single_1(struct pci_dev *pdev, void *cpu_addr, size_t size,
 		return 0;
 	}
 
+	offset = paddr & ~PAGE_MASK;
 	paddr &= PAGE_MASK;
 	for (i = 0; i < npages; ++i, paddr += PAGE_SIZE)
 		arena->ptes[i + dma_ofs] = mk_iommu_pte(paddr);
 
-	ret = arena->dma_base + dma_ofs * PAGE_SIZE;
-	ret += (unsigned long)cpu_addr & ~PAGE_MASK;
+	ret = arena->dma_base + dma_ofs * PAGE_SIZE + offset;
 
 	DBGA2("pci_map_single: [%p,%zx] np %ld -> sg %llx from %pf\n",
-	      cpu_addr, size, npages, ret, __builtin_return_address(0));
+	      paddr, size, npages, ret, __builtin_return_address(0));
 
 	return ret;
 }
@@ -357,7 +354,7 @@ static dma_addr_t alpha_pci_map_page(struct device *dev, struct page *page,
 	BUG_ON(dir = PCI_DMA_NONE);
 
 	dac_allowed = pdev ? pci_dac_dma_supported(pdev, pdev->dma_mask) : 0; 
-	return pci_map_single_1(pdev, (char *)page_address(page) + offset, 
+	return pci_map_single_1(pdev, page_to_phys(page) + offset,
 				size, dac_allowed);
 }
 
@@ -453,7 +450,7 @@ try_again:
 	}
 	memset(cpu_addr, 0, size);
 
-	*dma_addrp = pci_map_single_1(pdev, cpu_addr, size, 0);
+	*dma_addrp = pci_map_single_1(pdev, __pa(cpu_addr), size, 0);
 	if (*dma_addrp = 0) {
 		free_pages((unsigned long)cpu_addr, order);
 		if (alpha_mv.mv_pci_tbi || (gfp & GFP_DMA))
@@ -497,9 +494,6 @@ static void alpha_pci_free_coherent(struct device *dev, size_t size,
    Write dma_length of each leader with the combined lengths of
    the mergable followers.  */
 
-#define SG_ENT_VIRT_ADDRESS(SG) (sg_virt((SG)))
-#define SG_ENT_PHYS_ADDRESS(SG) __pa(SG_ENT_VIRT_ADDRESS(SG))
-
 static void
 sg_classify(struct device *dev, struct scatterlist *sg, struct scatterlist *end,
 	    int virt_ok)
@@ -512,13 +506,13 @@ sg_classify(struct device *dev, struct scatterlist *sg, struct scatterlist *end,
 	leader = sg;
 	leader_flag = 0;
 	leader_length = leader->length;
-	next_paddr = SG_ENT_PHYS_ADDRESS(leader) + leader_length;
+	next_paddr = sg_phys(leader) + leader_length;
 
 	/* we will not marge sg without device. */
 	max_seg_size = dev ? dma_get_max_seg_size(dev) : 0;
 	for (++sg; sg < end; ++sg) {
 		unsigned long addr, len;
-		addr = SG_ENT_PHYS_ADDRESS(sg);
+		addr = sg_phys(sg);
 		len = sg->length;
 
 		if (leader_length + len > max_seg_size)
@@ -555,7 +549,7 @@ sg_fill(struct device *dev, struct scatterlist *leader, struct scatterlist *end,
 	struct scatterlist *out, struct pci_iommu_arena *arena,
 	dma_addr_t max_dma, int dac_allowed)
 {
-	unsigned long paddr = SG_ENT_PHYS_ADDRESS(leader);
+	unsigned long paddr = sg_phys(leader);
 	long size = leader->dma_length;
 	struct scatterlist *sg;
 	unsigned long *ptes;
@@ -621,7 +615,7 @@ sg_fill(struct device *dev, struct scatterlist *leader, struct scatterlist *end,
 #endif
 
 		size = sg->length;
-		paddr = SG_ENT_PHYS_ADDRESS(sg);
+		paddr = sg_phys(sg);
 
 		while (sg+1 < end && (int) sg[1].dma_address = -1) {
 			size += sg[1].length;
@@ -636,11 +630,11 @@ sg_fill(struct device *dev, struct scatterlist *leader, struct scatterlist *end,
 
 #if DEBUG_ALLOC > 0
 		DBGA("    (%ld) [%p,%x] np %ld\n",
-		     last_sg - leader, SG_ENT_VIRT_ADDRESS(last_sg),
+		     last_sg - leader, sg_phys(last_sg),
 		     last_sg->length, npages);
 		while (++last_sg <= sg) {
 			DBGA("        (%ld) [%p,%x] cont\n",
-			     last_sg - leader, SG_ENT_VIRT_ADDRESS(last_sg),
+			     last_sg - leader, sg_phys(last_sg),
 			     last_sg->length);
 		}
 #endif
@@ -668,7 +662,7 @@ static int alpha_pci_map_sg(struct device *dev, struct scatterlist *sg,
 	if (nents = 1) {
 		sg->dma_length = sg->length;
 		sg->dma_address
-		  = pci_map_single_1(pdev, SG_ENT_VIRT_ADDRESS(sg),
+		  = pci_map_single_1(pdev, sg_phys(sg),
 				     sg->length, dac_allowed);
 		return sg->dma_address != 0;
 	}
-- 
1.9.1

