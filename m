From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Date: Thu, 30 Jun 2016 08:26:10 +0000
Subject: [PATCH v5 43/44] dma-mapping: Remove dma_get_attr
Message-Id: <1467275171-6298-43-git-send-email-k.kozlowski@samsung.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1467275019-30789-1-git-send-email-k.kozlowski@samsung.com>
	<1467275171-6298-1-git-send-email-k.kozlowski@samsung.com>
In-Reply-To: <1467275171-6298-1-git-send-email-k.kozlowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, Krzysztof Kozlowski <k.kozlowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Airlie <airlied-cv59FeDIM0c@public.gmane.org>, Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>, Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, "James E.J. Bottomley" <jejb-6jwH94ZQLHl74goWV3ctuw@public.gmane.org>, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, Hans-Christian Egtvedt <egtvedt-BrfabpQBY5qlHtIdYg32fQ@public.gmane.org>, Jonas Bonn <jonas-A9uVI2HLR7kOP4wsBPIw7w@public.gmane.org>, Stefano Stabellini <sstabellini-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Pawel Osciak <pawel-FA/gS7QP4orQT0dZR+AlfA@public.gmane.org>, linux-snps-arc-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, Michael Ellerman <mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>, Helge Deller <deller-Mmb7MZpHnFY@public.gmane.org>, Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>, xen-devel@lists.

After switching DMA attributes to unsigned long it is easier to just
compare the bits.

Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
[for avr32]
Acked-by: Hans-Christian Noren Egtvedt <egtvedt@samfundet.no>
[for arc]
Acked-by: Vineet Gupta <vgupta@synopsys.com>
[for arm64 and dma-iommu]
Acked-by: Robin Murphy <robin.murphy@arm.com>
---
 Documentation/DMA-API.txt                      |  4 +--
 arch/arc/mm/dma.c                              |  4 +--
 arch/arm/mm/dma-mapping.c                      | 36 ++++++++++++--------------
 arch/arm/xen/mm.c                              |  4 +--
 arch/arm64/mm/dma-mapping.c                    | 10 +++----
 arch/avr32/mm/dma-coherent.c                   |  4 +--
 arch/ia64/sn/pci/pci_dma.c                     | 10 ++-----
 arch/metag/kernel/dma.c                        |  2 +-
 arch/mips/mm/dma-default.c                     |  6 ++---
 arch/openrisc/kernel/dma.c                     |  4 +--
 arch/parisc/kernel/pci-dma.c                   |  2 +-
 arch/powerpc/platforms/cell/iommu.c            | 12 ++++-----
 drivers/gpu/drm/rockchip/rockchip_drm_gem.c    |  2 +-
 drivers/iommu/dma-iommu.c                      |  2 +-
 drivers/media/v4l2-core/videobuf2-dma-contig.c |  2 +-
 include/linux/dma-mapping.h                    | 10 -------
 16 files changed, 47 insertions(+), 67 deletions(-)

diff --git a/Documentation/DMA-API.txt b/Documentation/DMA-API.txt
index 24f9688bb98a..1d26eeb6b5f6 100644
--- a/Documentation/DMA-API.txt
+++ b/Documentation/DMA-API.txt
@@ -422,9 +422,7 @@ void whizco_dma_map_sg_attrs(struct device *dev, dma_addr_t dma_addr,
 			     unsigned long attrs)
 {
 	....
-	int foo =  dma_get_attr(DMA_ATTR_FOO, attrs);
-	....
-	if (foo)
+	if (attrs & DMA_ATTR_FOO)
 		/* twizzle the frobnozzle */
 	....
 
diff --git a/arch/arc/mm/dma.c b/arch/arc/mm/dma.c
index 3d1f467d1792..74bbe68dce9d 100644
--- a/arch/arc/mm/dma.c
+++ b/arch/arc/mm/dma.c
@@ -46,7 +46,7 @@ static void *arc_dma_alloc(struct device *dev, size_t size,
 	 *   (vs. always going to memory - thus are faster)
 	 */
 	if ((is_isa_arcv2() && ioc_exists) ||
-	    dma_get_attr(DMA_ATTR_NON_CONSISTENT, attrs))
+	    (attrs & DMA_ATTR_NON_CONSISTENT))
 		need_coh = 0;
 
 	/*
@@ -95,7 +95,7 @@ static void arc_dma_free(struct device *dev, size_t size, void *vaddr,
 	struct page *page = virt_to_page(dma_handle);
 	int is_non_coh = 1;
 
-	is_non_coh = dma_get_attr(DMA_ATTR_NON_CONSISTENT, attrs) ||
+	is_non_coh = (attrs & DMA_ATTR_NON_CONSISTENT) ||
 			(is_isa_arcv2() && ioc_exists);
 
 	if (PageHighMem(page) || !is_non_coh)
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index ebb3fde99043..43e03b5293d0 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -126,7 +126,7 @@ static dma_addr_t arm_dma_map_page(struct device *dev, struct page *page,
 	     unsigned long offset, size_t size, enum dma_data_direction dir,
 	     unsigned long attrs)
 {
-	if (!dma_get_attr(DMA_ATTR_SKIP_CPU_SYNC, attrs))
+	if ((attrs & DMA_ATTR_SKIP_CPU_SYNC) = 0)
 		__dma_page_cpu_to_dev(page, offset, size, dir);
 	return pfn_to_dma(dev, page_to_pfn(page)) + offset;
 }
@@ -155,7 +155,7 @@ static dma_addr_t arm_coherent_dma_map_page(struct device *dev, struct page *pag
 static void arm_dma_unmap_page(struct device *dev, dma_addr_t handle,
 		size_t size, enum dma_data_direction dir, unsigned long attrs)
 {
-	if (!dma_get_attr(DMA_ATTR_SKIP_CPU_SYNC, attrs))
+	if ((attrs & DMA_ATTR_SKIP_CPU_SYNC) = 0)
 		__dma_page_dev_to_cpu(pfn_to_page(dma_to_pfn(dev, handle)),
 				      handle & ~PAGE_MASK, size, dir);
 }
@@ -622,9 +622,9 @@ static void __free_from_contiguous(struct device *dev, struct page *page,
 
 static inline pgprot_t __get_dma_pgprot(unsigned long attrs, pgprot_t prot)
 {
-	prot = dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs) ?
-			    pgprot_writecombine(prot) :
-			    pgprot_dmacoherent(prot);
+	prot = (attrs & DMA_ATTR_WRITE_COMBINE) ?
+			pgprot_writecombine(prot) :
+			pgprot_dmacoherent(prot);
 	return prot;
 }
 
@@ -744,7 +744,7 @@ static void *__dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
 		.gfp = gfp,
 		.prot = prot,
 		.caller = caller,
-		.want_vaddr = !dma_get_attr(DMA_ATTR_NO_KERNEL_MAPPING, attrs),
+		.want_vaddr = ((attrs & DMA_ATTR_NO_KERNEL_MAPPING) = 0),
 	};
 
 #ifdef CONFIG_DMA_API_DEBUG
@@ -887,7 +887,7 @@ static void __arm_dma_free(struct device *dev, size_t size, void *cpu_addr,
 		.size = PAGE_ALIGN(size),
 		.cpu_addr = cpu_addr,
 		.page = page,
-		.want_vaddr = !dma_get_attr(DMA_ATTR_NO_KERNEL_MAPPING, attrs),
+		.want_vaddr = ((attrs & DMA_ATTR_NO_KERNEL_MAPPING) = 0),
 	};
 
 	buf = arm_dma_buffer_find(cpu_addr);
@@ -1267,7 +1267,7 @@ static struct page **__iommu_alloc_buffer(struct device *dev, size_t size,
 	if (!pages)
 		return NULL;
 
-	if (dma_get_attr(DMA_ATTR_FORCE_CONTIGUOUS, attrs))
+	if (attrs & DMA_ATTR_FORCE_CONTIGUOUS)
 	{
 		unsigned long order = get_order(size);
 		struct page *page;
@@ -1285,7 +1285,7 @@ static struct page **__iommu_alloc_buffer(struct device *dev, size_t size,
 	}
 
 	/* Go straight to 4K chunks if caller says it's OK. */
-	if (dma_get_attr(DMA_ATTR_ALLOC_SINGLE_PAGES, attrs))
+	if (attrs & DMA_ATTR_ALLOC_SINGLE_PAGES)
 		order_idx = ARRAY_SIZE(iommu_order_array) - 1;
 
 	/*
@@ -1346,7 +1346,7 @@ static int __iommu_free_buffer(struct device *dev, struct page **pages,
 	int count = size >> PAGE_SHIFT;
 	int i;
 
-	if (dma_get_attr(DMA_ATTR_FORCE_CONTIGUOUS, attrs)) {
+	if (attrs & DMA_ATTR_FORCE_CONTIGUOUS) {
 		dma_release_from_contiguous(dev, pages[0], count);
 	} else {
 		for (i = 0; i < count; i++)
@@ -1445,7 +1445,7 @@ static struct page **__iommu_get_pages(void *cpu_addr, unsigned long attrs)
 	if (__in_atomic_pool(cpu_addr, PAGE_SIZE))
 		return __atomic_get_pages(cpu_addr);
 
-	if (dma_get_attr(DMA_ATTR_NO_KERNEL_MAPPING, attrs))
+	if (attrs & DMA_ATTR_NO_KERNEL_MAPPING)
 		return cpu_addr;
 
 	area = find_vm_area(cpu_addr);
@@ -1512,7 +1512,7 @@ static void *arm_iommu_alloc_attrs(struct device *dev, size_t size,
 	if (*handle = DMA_ERROR_CODE)
 		goto err_buffer;
 
-	if (dma_get_attr(DMA_ATTR_NO_KERNEL_MAPPING, attrs))
+	if (attrs & DMA_ATTR_NO_KERNEL_MAPPING)
 		return pages;
 
 	addr = __iommu_alloc_remap(pages, size, gfp, prot,
@@ -1583,7 +1583,7 @@ void arm_iommu_free_attrs(struct device *dev, size_t size, void *cpu_addr,
 		return;
 	}
 
-	if (!dma_get_attr(DMA_ATTR_NO_KERNEL_MAPPING, attrs)) {
+	if ((attrs & DMA_ATTR_NO_KERNEL_MAPPING) = 0) {
 		dma_common_free_remap(cpu_addr, size,
 			VM_ARM_DMA_CONSISTENT | VM_USERMAP);
 	}
@@ -1653,8 +1653,7 @@ static int __map_sg_chunk(struct device *dev, struct scatterlist *sg,
 		phys_addr_t phys = page_to_phys(sg_page(s));
 		unsigned int len = PAGE_ALIGN(s->offset + s->length);
 
-		if (!is_coherent &&
-			!dma_get_attr(DMA_ATTR_SKIP_CPU_SYNC, attrs))
+		if (!is_coherent && (attrs & DMA_ATTR_SKIP_CPU_SYNC) = 0)
 			__dma_page_cpu_to_dev(sg_page(s), s->offset, s->length, dir);
 
 		prot = __dma_direction_to_prot(dir);
@@ -1767,8 +1766,7 @@ static void __iommu_unmap_sg(struct device *dev, struct scatterlist *sg,
 		if (sg_dma_len(s))
 			__iommu_remove_mapping(dev, sg_dma_address(s),
 					       sg_dma_len(s));
-		if (!is_coherent &&
-		    !dma_get_attr(DMA_ATTR_SKIP_CPU_SYNC, attrs))
+		if (!is_coherent && (attrs & DMA_ATTR_SKIP_CPU_SYNC) = 0)
 			__dma_page_dev_to_cpu(sg_page(s), s->offset,
 					      s->length, dir);
 	}
@@ -1892,7 +1890,7 @@ static dma_addr_t arm_iommu_map_page(struct device *dev, struct page *page,
 	     unsigned long offset, size_t size, enum dma_data_direction dir,
 	     unsigned long attrs)
 {
-	if (!dma_get_attr(DMA_ATTR_SKIP_CPU_SYNC, attrs))
+	if ((attrs & DMA_ATTR_SKIP_CPU_SYNC) = 0)
 		__dma_page_cpu_to_dev(page, offset, size, dir);
 
 	return arm_coherent_iommu_map_page(dev, page, offset, size, dir, attrs);
@@ -1943,7 +1941,7 @@ static void arm_iommu_unmap_page(struct device *dev, dma_addr_t handle,
 	if (!iova)
 		return;
 
-	if (!dma_get_attr(DMA_ATTR_SKIP_CPU_SYNC, attrs))
+	if ((attrs & DMA_ATTR_SKIP_CPU_SYNC) = 0)
 		__dma_page_dev_to_cpu(page, offset, size, dir);
 
 	iommu_unmap(mapping->domain, iova, len);
diff --git a/arch/arm/xen/mm.c b/arch/arm/xen/mm.c
index fc67ed236a10..d062f08f5020 100644
--- a/arch/arm/xen/mm.c
+++ b/arch/arm/xen/mm.c
@@ -102,7 +102,7 @@ void __xen_dma_map_page(struct device *hwdev, struct page *page,
 {
 	if (is_device_dma_coherent(hwdev))
 		return;
-	if (dma_get_attr(DMA_ATTR_SKIP_CPU_SYNC, attrs))
+	if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
 		return;
 
 	__xen_dma_page_cpu_to_dev(hwdev, dev_addr, size, dir);
@@ -115,7 +115,7 @@ void __xen_dma_unmap_page(struct device *hwdev, dma_addr_t handle,
 {
 	if (is_device_dma_coherent(hwdev))
 		return;
-	if (dma_get_attr(DMA_ATTR_SKIP_CPU_SYNC, attrs))
+	if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
 		return;
 
 	__xen_dma_page_dev_to_cpu(hwdev, handle, size, dir);
diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
index 65f69943b1cb..e82763af137f 100644
--- a/arch/arm64/mm/dma-mapping.c
+++ b/arch/arm64/mm/dma-mapping.c
@@ -32,7 +32,7 @@
 static pgprot_t __get_dma_pgprot(unsigned long attrs, pgprot_t prot,
 				 bool coherent)
 {
-	if (!coherent || dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs))
+	if (!coherent || (attrs & DMA_ATTR_WRITE_COMBINE))
 		return pgprot_writecombine(prot);
 	return prot;
 }
@@ -701,7 +701,7 @@ static dma_addr_t __iommu_map_page(struct device *dev, struct page *page,
 	dma_addr_t dev_addr = iommu_dma_map_page(dev, page, offset, size, prot);
 
 	if (!iommu_dma_mapping_error(dev, dev_addr) &&
-	    !dma_get_attr(DMA_ATTR_SKIP_CPU_SYNC, attrs))
+	    (attrs & DMA_ATTR_SKIP_CPU_SYNC) = 0)
 		__iommu_sync_single_for_device(dev, dev_addr, size, dir);
 
 	return dev_addr;
@@ -711,7 +711,7 @@ static void __iommu_unmap_page(struct device *dev, dma_addr_t dev_addr,
 			       size_t size, enum dma_data_direction dir,
 			       unsigned long attrs)
 {
-	if (!dma_get_attr(DMA_ATTR_SKIP_CPU_SYNC, attrs))
+	if ((attrs & DMA_ATTR_SKIP_CPU_SYNC) = 0)
 		__iommu_sync_single_for_cpu(dev, dev_addr, size, dir);
 
 	iommu_dma_unmap_page(dev, dev_addr, size, dir, attrs);
@@ -751,7 +751,7 @@ static int __iommu_map_sg_attrs(struct device *dev, struct scatterlist *sgl,
 {
 	bool coherent = is_device_dma_coherent(dev);
 
-	if (!dma_get_attr(DMA_ATTR_SKIP_CPU_SYNC, attrs))
+	if ((attrs & DMA_ATTR_SKIP_CPU_SYNC) = 0)
 		__iommu_sync_sg_for_device(dev, sgl, nelems, dir);
 
 	return iommu_dma_map_sg(dev, sgl, nelems,
@@ -763,7 +763,7 @@ static void __iommu_unmap_sg_attrs(struct device *dev,
 				   enum dma_data_direction dir,
 				   unsigned long attrs)
 {
-	if (!dma_get_attr(DMA_ATTR_SKIP_CPU_SYNC, attrs))
+	if ((attrs & DMA_ATTR_SKIP_CPU_SYNC) = 0)
 		__iommu_sync_sg_for_cpu(dev, sgl, nelems, dir);
 
 	iommu_dma_unmap_sg(dev, sgl, nelems, dir, attrs);
diff --git a/arch/avr32/mm/dma-coherent.c b/arch/avr32/mm/dma-coherent.c
index fc51f4421933..58610d0df7ed 100644
--- a/arch/avr32/mm/dma-coherent.c
+++ b/arch/avr32/mm/dma-coherent.c
@@ -109,7 +109,7 @@ static void *avr32_dma_alloc(struct device *dev, size_t size,
 		return NULL;
 	phys = page_to_phys(page);
 
-	if (dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs)) {
+	if (attrs & DMA_ATTR_WRITE_COMBINE) {
 		/* Now, map the page into P3 with write-combining turned on */
 		*handle = phys;
 		return __ioremap(phys, size, _PAGE_BUFFER);
@@ -123,7 +123,7 @@ static void avr32_dma_free(struct device *dev, size_t size,
 {
 	struct page *page;
 
-	if (dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs)) {
+	if (attrs & DMA_ATTR_WRITE_COMBINE) {
 		iounmap(cpu_addr);
 
 		page = phys_to_page(handle);
diff --git a/arch/ia64/sn/pci/pci_dma.c b/arch/ia64/sn/pci/pci_dma.c
index 6b78fc953c4b..74c934a997bb 100644
--- a/arch/ia64/sn/pci/pci_dma.c
+++ b/arch/ia64/sn/pci/pci_dma.c
@@ -183,14 +183,11 @@ static dma_addr_t sn_dma_map_page(struct device *dev, struct page *page,
 	unsigned long phys_addr;
 	struct pci_dev *pdev = to_pci_dev(dev);
 	struct sn_pcibus_provider *provider = SN_PCIDEV_BUSPROVIDER(pdev);
-	int dmabarr;
-
-	dmabarr = dma_get_attr(DMA_ATTR_WRITE_BARRIER, attrs);
 
 	BUG_ON(!dev_is_pci(dev));
 
 	phys_addr = __pa(cpu_addr);
-	if (dmabarr)
+	if (attrs & DMA_ATTR_WRITE_BARRIER)
 		dma_addr = provider->dma_map_consistent(pdev, phys_addr,
 							size, SN_DMA_ADDR_PHYS);
 	else
@@ -280,9 +277,6 @@ static int sn_dma_map_sg(struct device *dev, struct scatterlist *sgl,
 	struct pci_dev *pdev = to_pci_dev(dev);
 	struct sn_pcibus_provider *provider = SN_PCIDEV_BUSPROVIDER(pdev);
 	int i;
-	int dmabarr;
-
-	dmabarr = dma_get_attr(DMA_ATTR_WRITE_BARRIER, attrs);
 
 	BUG_ON(!dev_is_pci(dev));
 
@@ -292,7 +286,7 @@ static int sn_dma_map_sg(struct device *dev, struct scatterlist *sgl,
 	for_each_sg(sgl, sg, nhwentries, i) {
 		dma_addr_t dma_addr;
 		phys_addr = SG_ENT_PHYS_ADDRESS(sg);
-		if (dmabarr)
+		if (attrs & DMA_ATTR_WRITE_BARRIER)
 			dma_addr = provider->dma_map_consistent(pdev,
 								phys_addr,
 								sg->length,
diff --git a/arch/metag/kernel/dma.c b/arch/metag/kernel/dma.c
index d68f498e82a1..0db31e24c541 100644
--- a/arch/metag/kernel/dma.c
+++ b/arch/metag/kernel/dma.c
@@ -337,7 +337,7 @@ static int metag_dma_mmap(struct device *dev, struct vm_area_struct *vma,
 	struct metag_vm_region *c;
 	int ret = -ENXIO;
 
-	if (dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs))
+	if (attrs & DMA_ATTR_WRITE_COMBINE)
 		vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
 	else
 		vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
diff --git a/arch/mips/mm/dma-default.c b/arch/mips/mm/dma-default.c
index 0ed9000dc1ff..b2eadd6fa9a1 100644
--- a/arch/mips/mm/dma-default.c
+++ b/arch/mips/mm/dma-default.c
@@ -141,7 +141,7 @@ static void *mips_dma_alloc_coherent(struct device *dev, size_t size,
 	 * XXX: seems like the coherent and non-coherent implementations could
 	 * be consolidated.
 	 */
-	if (dma_get_attr(DMA_ATTR_NON_CONSISTENT, attrs))
+	if (attrs & DMA_ATTR_NON_CONSISTENT)
 		return mips_dma_alloc_noncoherent(dev, size, dma_handle, gfp);
 
 	gfp = massage_gfp_flags(dev, gfp);
@@ -182,7 +182,7 @@ static void mips_dma_free_coherent(struct device *dev, size_t size, void *vaddr,
 	unsigned int count = PAGE_ALIGN(size) >> PAGE_SHIFT;
 	struct page *page = NULL;
 
-	if (dma_get_attr(DMA_ATTR_NON_CONSISTENT, attrs)) {
+	if (attrs & DMA_ATTR_NON_CONSISTENT) {
 		mips_dma_free_noncoherent(dev, size, vaddr, dma_handle);
 		return;
 	}
@@ -214,7 +214,7 @@ static int mips_dma_mmap(struct device *dev, struct vm_area_struct *vma,
 
 	pfn = page_to_pfn(virt_to_page((void *)addr));
 
-	if (dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs))
+	if (attrs & DMA_ATTR_WRITE_COMBINE)
 		vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
 	else
 		vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
diff --git a/arch/openrisc/kernel/dma.c b/arch/openrisc/kernel/dma.c
index 50eb1f26c540..140c99140649 100644
--- a/arch/openrisc/kernel/dma.c
+++ b/arch/openrisc/kernel/dma.c
@@ -100,7 +100,7 @@ or1k_dma_alloc(struct device *dev, size_t size,
 
 	va = (unsigned long)page;
 
-	if (!dma_get_attr(DMA_ATTR_NON_CONSISTENT, attrs)) {
+	if ((attrs & DMA_ATTR_NON_CONSISTENT) = 0) {
 		/*
 		 * We need to iterate through the pages, clearing the dcache for
 		 * them and setting the cache-inhibit bit.
@@ -124,7 +124,7 @@ or1k_dma_free(struct device *dev, size_t size, void *vaddr,
 		.mm = &init_mm
 	};
 
-	if (!dma_get_attr(DMA_ATTR_NON_CONSISTENT, attrs)) {
+	if ((attrs & DMA_ATTR_NON_CONSISTENT) = 0) {
 		/* walk_page_range shouldn't be able to fail here */
 		WARN_ON(walk_page_range(va, va + size, &walk));
 	}
diff --git a/arch/parisc/kernel/pci-dma.c b/arch/parisc/kernel/pci-dma.c
index 845fdd52e4c5..02d9ed0f3949 100644
--- a/arch/parisc/kernel/pci-dma.c
+++ b/arch/parisc/kernel/pci-dma.c
@@ -581,7 +581,7 @@ static void *pcx_dma_alloc(struct device *dev, size_t size,
 {
 	void *addr;
 
-	if (!dma_get_attr(DMA_ATTR_NON_CONSISTENT, attrs))
+	if ((attrs & DMA_ATTR_NON_CONSISTENT) = 0)
 		return NULL;
 
 	addr = (void *)__get_free_pages(flag, get_order(size));
diff --git a/arch/powerpc/platforms/cell/iommu.c b/arch/powerpc/platforms/cell/iommu.c
index c8e11e020335..6128bdb428b2 100644
--- a/arch/powerpc/platforms/cell/iommu.c
+++ b/arch/powerpc/platforms/cell/iommu.c
@@ -193,7 +193,7 @@ static int tce_build_cell(struct iommu_table *tbl, long index, long npages,
 	base_pte = CBE_IOPTE_PP_W | CBE_IOPTE_PP_R | CBE_IOPTE_M |
 		CBE_IOPTE_SO_RW | (window->ioid & CBE_IOPTE_IOID_Mask);
 #endif
-	if (unlikely(dma_get_attr(DMA_ATTR_WEAK_ORDERING, attrs)))
+	if (unlikely(attrs & DMA_ATTR_WEAK_ORDERING))
 		base_pte &= ~CBE_IOPTE_SO_RW;
 
 	io_pte = (unsigned long *)tbl->it_base + (index - tbl->it_offset);
@@ -600,7 +600,7 @@ static dma_addr_t dma_fixed_map_page(struct device *dev, struct page *page,
 				     enum dma_data_direction direction,
 				     unsigned long attrs)
 {
-	if (iommu_fixed_is_weak = dma_get_attr(DMA_ATTR_WEAK_ORDERING, attrs))
+	if (iommu_fixed_is_weak = (attrs & DMA_ATTR_WEAK_ORDERING))
 		return dma_direct_ops.map_page(dev, page, offset, size,
 					       direction, attrs);
 	else
@@ -613,7 +613,7 @@ static void dma_fixed_unmap_page(struct device *dev, dma_addr_t dma_addr,
 				 size_t size, enum dma_data_direction direction,
 				 unsigned long attrs)
 {
-	if (iommu_fixed_is_weak = dma_get_attr(DMA_ATTR_WEAK_ORDERING, attrs))
+	if (iommu_fixed_is_weak = (attrs & DMA_ATTR_WEAK_ORDERING))
 		dma_direct_ops.unmap_page(dev, dma_addr, size, direction,
 					  attrs);
 	else
@@ -625,7 +625,7 @@ static int dma_fixed_map_sg(struct device *dev, struct scatterlist *sg,
 			   int nents, enum dma_data_direction direction,
 			   unsigned long attrs)
 {
-	if (iommu_fixed_is_weak = dma_get_attr(DMA_ATTR_WEAK_ORDERING, attrs))
+	if (iommu_fixed_is_weak = (attrs & DMA_ATTR_WEAK_ORDERING))
 		return dma_direct_ops.map_sg(dev, sg, nents, direction, attrs);
 	else
 		return ppc_iommu_map_sg(dev, cell_get_iommu_table(dev), sg,
@@ -637,7 +637,7 @@ static void dma_fixed_unmap_sg(struct device *dev, struct scatterlist *sg,
 			       int nents, enum dma_data_direction direction,
 			       unsigned long attrs)
 {
-	if (iommu_fixed_is_weak = dma_get_attr(DMA_ATTR_WEAK_ORDERING, attrs))
+	if (iommu_fixed_is_weak = (attrs & DMA_ATTR_WEAK_ORDERING))
 		dma_direct_ops.unmap_sg(dev, sg, nents, direction, attrs);
 	else
 		ppc_iommu_unmap_sg(cell_get_iommu_table(dev), sg, nents,
@@ -1162,7 +1162,7 @@ static int __init setup_iommu_fixed(char *str)
 	pciep = of_find_node_by_type(NULL, "pcie-endpoint");
 
 	if (strcmp(str, "weak") = 0 || (pciep && strcmp(str, "strong") != 0))
-		iommu_fixed_is_weak = 1;
+		iommu_fixed_is_weak = DMA_ATTR_WEAK_ORDERING;
 
 	of_node_put(pciep);
 
diff --git a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
index 7b1788e2a808..4a28d6348c76 100644
--- a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
+++ b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
@@ -273,7 +273,7 @@ void *rockchip_gem_prime_vmap(struct drm_gem_object *obj)
 {
 	struct rockchip_gem_object *rk_obj = to_rockchip_obj(obj);
 
-	if (dma_get_attr(DMA_ATTR_NO_KERNEL_MAPPING, rk_obj->dma_attrs))
+	if (rk_obj->dma_attrs & DMA_ATTR_NO_KERNEL_MAPPING)
 		return NULL;
 
 	return rk_obj->kvaddr;
diff --git a/drivers/iommu/dma-iommu.c b/drivers/iommu/dma-iommu.c
index 6c1bda504fb1..08a1e2f3690f 100644
--- a/drivers/iommu/dma-iommu.c
+++ b/drivers/iommu/dma-iommu.c
@@ -306,7 +306,7 @@ struct page **iommu_dma_alloc(struct device *dev, size_t size, gfp_t gfp,
 	} else {
 		size = ALIGN(size, min_size);
 	}
-	if (dma_get_attr(DMA_ATTR_ALLOC_SINGLE_PAGES, attrs))
+	if (attrs & DMA_ATTR_ALLOC_SINGLE_PAGES)
 		alloc_sizes = min_size;
 
 	count = PAGE_ALIGN(size) >> PAGE_SHIFT;
diff --git a/drivers/media/v4l2-core/videobuf2-dma-contig.c b/drivers/media/v4l2-core/videobuf2-dma-contig.c
index 8009a582326b..d2ab541614b8 100644
--- a/drivers/media/v4l2-core/videobuf2-dma-contig.c
+++ b/drivers/media/v4l2-core/videobuf2-dma-contig.c
@@ -160,7 +160,7 @@ static void *vb2_dc_alloc(void *alloc_ctx, unsigned long size,
 		return ERR_PTR(-ENOMEM);
 	}
 
-	if (!dma_get_attr(DMA_ATTR_NO_KERNEL_MAPPING, buf->attrs))
+	if ((buf->attrs & DMA_ATTR_NO_KERNEL_MAPPING) = 0)
 		buf->vaddr = buf->cookie;
 
 	/* Prevent the device from being released while the buffer is used */
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 1fd9860487b1..d8fb67783cb7 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -101,16 +101,6 @@ static inline int is_device_dma_capable(struct device *dev)
 	return dev->dma_mask != NULL && *dev->dma_mask != DMA_MASK_NONE;
 }
 
-/**
- * dma_get_attr - check for a specific attribute
- * @attr: attribute to look for
- * @attrs: attributes to check within
- */
-static inline bool dma_get_attr(unsigned long attr, unsigned long attrs)
-{
-	return !!(attr & attrs);
-}
-
 #ifdef CONFIG_HAVE_GENERIC_DMA_COHERENT
 /*
  * These three functions are only for dma allocator.
-- 
1.9.1

