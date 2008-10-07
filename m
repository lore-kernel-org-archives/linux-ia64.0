From: Fenghua Yu <fenghua.yu@intel.com>
Date: Tue, 07 Oct 2008 00:01:53 +0000
Subject: [PATCH V2 1/2] Add Variable Page Size and IA64 Support in Intel IOMMU: Generic Part
Message-Id: <20081007000153.GA25089@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <BAE9DCEF64577A439B3A37F36F9B691C0339372B@orsmsx418.amr.corp.intel.com> <617E1C2C70743745A92448908E030B2A02AD5AD7@scsmsx411.amr.corp.intel.com> <20081001165725.GA21559@linux-os.sc.intel.com>
In-Reply-To: <20081001165725.GA21559@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

The current Intel IOMMU code assumes that both host page size and Intel IOMMU page size are 4K. This patch supports variable page size. It provides support for IA64 which has multiple page sizes.
 
This patch also re-organizes code to work on both X86-64 and IA64 platforms, e.g. DMAR_OPERATION_TIMEOUT definition etc.

Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>
Signed-off-by: Tony Luck <tony.luck@intel.com>

---

 arch/x86/kernel/pci-dma.c     |   16 -----
 drivers/pci/dmar.c            |   19 +++---
 drivers/pci/intel-iommu.c     |  124 ++++++++++++++++++++++--------------------
 drivers/pci/quirks.c          |   14 ++++
 include/asm-x86/iommu.h       |    4 +
 include/linux/dma_remapping.h |   27 ++++-----
 include/linux/intel-iommu.h   |   39 +++++++------
 7 files changed, 131 insertions(+), 112 deletions(-)


diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
index 23882c4..6751f4c 100644
--- a/arch/x86/kernel/pci-dma.c
+++ b/arch/x86/kernel/pci-dma.c
@@ -9,8 +9,6 @@
 #include <asm/calgary.h>
 #include <asm/amd_iommu.h>
 
-static int forbid_dac __read_mostly;
-
 struct dma_mapping_ops *dma_ops;
 EXPORT_SYMBOL(dma_ops);
 
@@ -262,17 +260,3 @@ void pci_iommu_shutdown(void)
 }
 /* Must execute after PCI subsystem */
 fs_initcall(pci_iommu_init);
-
-#ifdef CONFIG_PCI
-/* Many VIA bridges seem to corrupt data for DAC. Disable it here */
-
-static __devinit void via_no_dac(struct pci_dev *dev)
-{
-	if ((dev->class >> 8) = PCI_CLASS_BRIDGE_PCI && forbid_dac = 0) {
-		printk(KERN_INFO "PCI: VIA PCI bridge detected."
-				 "Disabling DAC.\n");
-		forbid_dac = 1;
-	}
-}
-DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_VIA, PCI_ANY_ID, via_no_dac);
-#endif
diff --git a/drivers/pci/dmar.c b/drivers/pci/dmar.c
index 0c92e2c..59c974a 100644
--- a/drivers/pci/dmar.c
+++ b/drivers/pci/dmar.c
@@ -277,14 +277,15 @@ dmar_table_print_dmar_entry(struct acpi_dmar_header *header)
 		drhd = (struct acpi_dmar_hardware_unit *)header;
 		printk (KERN_INFO PREFIX
 			"DRHD (flags: 0x%08x)base: 0x%016Lx\n",
-			drhd->flags, drhd->address);
+			drhd->flags, (unsigned long long)drhd->address);
 		break;
 	case ACPI_DMAR_TYPE_RESERVED_MEMORY:
 		rmrr = (struct acpi_dmar_reserved_memory *)header;
 
 		printk (KERN_INFO PREFIX
 			"RMRR base: 0x%016Lx end: 0x%016Lx\n",
-			rmrr->base_address, rmrr->end_address);
+			(unsigned long long)rmrr->base_address,
+			(unsigned long long)rmrr->end_address);
 		break;
 	}
 }
@@ -328,7 +329,7 @@ parse_dmar_table(void)
 	if (!dmar)
 		return -ENODEV;
 
-	if (dmar->width < PAGE_SHIFT_4K - 1) {
+	if (dmar->width < PAGE_SHIFT - 1) {
 		printk(KERN_WARNING PREFIX "Invalid DMAR haw\n");
 		return -EINVAL;
 	}
@@ -510,7 +511,7 @@ int alloc_iommu(struct dmar_drhd_unit *drhd)
 
 	iommu->seq_id = iommu_allocated++;
 
-	iommu->reg = ioremap(drhd->reg_base_addr, PAGE_SIZE_4K);
+	iommu->reg = ioremap(drhd->reg_base_addr, VTD_PAGE_SIZE);
 	if (!iommu->reg) {
 		printk(KERN_ERR "IOMMU: can't map the region\n");
 		goto error;
@@ -521,8 +522,8 @@ int alloc_iommu(struct dmar_drhd_unit *drhd)
 	/* the registers might be more than one page */
 	map_size = max_t(int, ecap_max_iotlb_offset(iommu->ecap),
 		cap_max_fault_reg_offset(iommu->cap));
-	map_size = PAGE_ALIGN_4K(map_size);
-	if (map_size > PAGE_SIZE_4K) {
+	map_size = VTD_PAGE_ALIGN(map_size);
+	if (map_size > VTD_PAGE_SIZE) {
 		iounmap(iommu->reg);
 		iommu->reg = ioremap(drhd->reg_base_addr, map_size);
 		if (!iommu->reg) {
@@ -533,8 +534,10 @@ int alloc_iommu(struct dmar_drhd_unit *drhd)
 
 	ver = readl(iommu->reg + DMAR_VER_REG);
 	pr_debug("IOMMU %llx: ver %d:%d cap %llx ecap %llx\n",
-		drhd->reg_base_addr, DMAR_VER_MAJOR(ver), DMAR_VER_MINOR(ver),
-		iommu->cap, iommu->ecap);
+		(unsigned long long)drhd->reg_base_addr,
+		DMAR_VER_MAJOR(ver), DMAR_VER_MINOR(ver),
+		(unsigned long long)iommu->cap,
+		(unsigned long long)iommu->ecap);
 
 	spin_lock_init(&iommu->register_lock);
 
diff --git a/drivers/pci/intel-iommu.c b/drivers/pci/intel-iommu.c
index fc5f2db..973c7ae 100644
--- a/drivers/pci/intel-iommu.c
+++ b/drivers/pci/intel-iommu.c
@@ -18,6 +18,7 @@
  * Author: Ashok Raj <ashok.raj@intel.com>
  * Author: Shaohua Li <shaohua.li@intel.com>
  * Author: Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>
+ * Author: Fenghua Yu <fenghua.yu@intel.com>
  */
 
 #include <linux/init.h>
@@ -35,11 +36,13 @@
 #include <linux/timer.h>
 #include <linux/iova.h>
 #include <linux/intel-iommu.h>
-#include <asm/proto.h> /* force_iommu in this header in x86-64*/
 #include <asm/cacheflush.h>
 #include <asm/iommu.h>
 #include "pci.h"
 
+#define ROOT_SIZE		VTD_PAGE_SIZE
+#define CONTEXT_SIZE		VTD_PAGE_SIZE
+
 #define IS_GFX_DEVICE(pdev) ((pdev->class >> 16) = PCI_BASE_CLASS_DISPLAY)
 #define IS_ISA_DEVICE(pdev) ((pdev->class >> 8) = PCI_CLASS_BRIDGE_ISA)
 
@@ -199,7 +202,7 @@ static struct context_entry * device_to_context_entry(struct intel_iommu *iommu,
 			spin_unlock_irqrestore(&iommu->lock, flags);
 			return NULL;
 		}
-		__iommu_flush_cache(iommu, (void *)context, PAGE_SIZE_4K);
+		__iommu_flush_cache(iommu, (void *)context, CONTEXT_SIZE);
 		phy_addr = virt_to_phys((void *)context);
 		set_root_value(root, phy_addr);
 		set_root_present(root);
@@ -345,7 +348,7 @@ static struct dma_pte * addr_to_dma_pte(struct dmar_domain *domain, u64 addr)
 				return NULL;
 			}
 			__iommu_flush_cache(domain->iommu, tmp_page,
-					PAGE_SIZE_4K);
+					PAGE_SIZE);
 			dma_set_pte_addr(*pte, virt_to_phys(tmp_page));
 			/*
 			 * high level table always sets r/w, last level page
@@ -408,13 +411,13 @@ static void dma_pte_clear_range(struct dmar_domain *domain, u64 start, u64 end)
 	start &= (((u64)1) << addr_width) - 1;
 	end &= (((u64)1) << addr_width) - 1;
 	/* in case it's partial page */
-	start = PAGE_ALIGN_4K(start);
-	end &= PAGE_MASK_4K;
+	start = PAGE_ALIGN(start);
+	end &= PAGE_MASK;
 
 	/* we don't need lock here, nobody else touches the iova range */
 	while (start < end) {
 		dma_pte_clear_one(domain, start);
-		start += PAGE_SIZE_4K;
+		start += VTD_PAGE_SIZE;
 	}
 }
 
@@ -468,7 +471,7 @@ static int iommu_alloc_root_entry(struct intel_iommu *iommu)
 	if (!root)
 		return -ENOMEM;
 
-	__iommu_flush_cache(iommu, root, PAGE_SIZE_4K);
+	__iommu_flush_cache(iommu, root, ROOT_SIZE);
 
 	spin_lock_irqsave(&iommu->lock, flags);
 	iommu->root_entry = root;
@@ -655,7 +658,8 @@ static int __iommu_flush_iotlb(struct intel_iommu *iommu, u16 did,
 		printk(KERN_ERR"IOMMU: flush IOTLB failed\n");
 	if (DMA_TLB_IAIG(val) != DMA_TLB_IIRG(type))
 		pr_debug("IOMMU: tlb flush request %Lx, actual %Lx\n",
-			DMA_TLB_IIRG(type), DMA_TLB_IAIG(val));
+			(unsigned long long)DMA_TLB_IIRG(type),
+			(unsigned long long) DMA_TLB_IAIG(val));
 	/* flush context entry will implictly flush write buffer */
 	return 0;
 }
@@ -679,7 +683,7 @@ static int iommu_flush_iotlb_psi(struct intel_iommu *iommu, u16 did,
 {
 	unsigned int mask;
 
-	BUG_ON(addr & (~PAGE_MASK_4K));
+	BUG_ON(addr & (~VTD_PAGE_MASK));
 	BUG_ON(pages = 0);
 
 	/* Fallback to domain selective flush if no PSI support */
@@ -831,7 +835,7 @@ void dmar_msi_read(int irq, struct msi_msg *msg)
 }
 
 static int iommu_page_fault_do_one(struct intel_iommu *iommu, int type,
-		u8 fault_reason, u16 source_id, u64 addr)
+		u8 fault_reason, u16 source_id, unsigned long long addr)
 {
 	const char *reason;
 
@@ -1084,9 +1088,9 @@ static void dmar_init_reserved_ranges(void)
 			if (!r->flags || !(r->flags & IORESOURCE_MEM))
 				continue;
 			addr = r->start;
-			addr &= PAGE_MASK_4K;
+			addr &= PAGE_MASK;
 			size = r->end - addr;
-			size = PAGE_ALIGN_4K(size);
+			size = PAGE_ALIGN(size);
 			iova = reserve_iova(&reserved_iova_list, IOVA_PFN(addr),
 				IOVA_PFN(size + addr) - 1);
 			if (!iova)
@@ -1148,7 +1152,7 @@ static int domain_init(struct dmar_domain *domain, int guest_width)
 	domain->pgd = (struct dma_pte *)alloc_pgtable_page();
 	if (!domain->pgd)
 		return -ENOMEM;
-	__iommu_flush_cache(iommu, domain->pgd, PAGE_SIZE_4K);
+	__iommu_flush_cache(iommu, domain->pgd, PAGE_SIZE);
 	return 0;
 }
 
@@ -1164,7 +1168,7 @@ static void domain_exit(struct dmar_domain *domain)
 	/* destroy iovas */
 	put_iova_domain(&domain->iovad);
 	end = DOMAIN_MAX_ADDR(domain->gaw);
-	end = end & (~PAGE_MASK_4K);
+	end = end & (~PAGE_MASK);
 
 	/* clear ptes */
 	dma_pte_clear_range(domain, 0, end);
@@ -1283,22 +1287,25 @@ domain_page_mapping(struct dmar_domain *domain, dma_addr_t iova,
 	u64 start_pfn, end_pfn;
 	struct dma_pte *pte;
 	int index;
+	int addr_width = agaw_to_width(domain->agaw);
+
+	hpa &= (((u64)1) << addr_width) - 1;
 
 	if ((prot & (DMA_PTE_READ|DMA_PTE_WRITE)) = 0)
 		return -EINVAL;
-	iova &= PAGE_MASK_4K;
-	start_pfn = ((u64)hpa) >> PAGE_SHIFT_4K;
-	end_pfn = (PAGE_ALIGN_4K(((u64)hpa) + size)) >> PAGE_SHIFT_4K;
+	iova &= PAGE_MASK;
+	start_pfn = ((u64)hpa) >> VTD_PAGE_SHIFT;
+	end_pfn = (VTD_PAGE_ALIGN(((u64)hpa) + size)) >> VTD_PAGE_SHIFT;
 	index = 0;
 	while (start_pfn < end_pfn) {
-		pte = addr_to_dma_pte(domain, iova + PAGE_SIZE_4K * index);
+		pte = addr_to_dma_pte(domain, iova + VTD_PAGE_SIZE * index);
 		if (!pte)
 			return -ENOMEM;
 		/* We don't need lock here, nobody else
 		 * touches the iova range
 		 */
 		BUG_ON(dma_pte_addr(*pte));
-		dma_set_pte_addr(*pte, start_pfn << PAGE_SHIFT_4K);
+		dma_set_pte_addr(*pte, start_pfn << VTD_PAGE_SHIFT);
 		dma_set_pte_prot(*pte, prot);
 		__iommu_flush_cache(domain->iommu, pte, sizeof(*pte));
 		start_pfn++;
@@ -1474,11 +1481,12 @@ error:
 	return find_domain(pdev);
 }
 
-static int iommu_prepare_identity_map(struct pci_dev *pdev, u64 start, u64 end)
+static int iommu_prepare_identity_map(struct pci_dev *pdev,
+	 unsigned long long start, unsigned long long end)
 {
 	struct dmar_domain *domain;
 	unsigned long size;
-	u64 base;
+	unsigned long long base;
 	int ret;
 
 	printk(KERN_INFO
@@ -1490,9 +1498,9 @@ static int iommu_prepare_identity_map(struct pci_dev *pdev, u64 start, u64 end)
 		return -ENOMEM;
 
 	/* The address might not be aligned */
-	base = start & PAGE_MASK_4K;
+	base = start & PAGE_MASK;
 	size = end - base;
-	size = PAGE_ALIGN_4K(size);
+	size = PAGE_ALIGN(size);
 	if (!reserve_iova(&domain->iovad, IOVA_PFN(base),
 			IOVA_PFN(base + size) - 1)) {
 		printk(KERN_ERR "IOMMU: reserve iova failed\n");
@@ -1738,8 +1746,8 @@ error:
 static inline u64 aligned_size(u64 host_addr, size_t size)
 {
 	u64 addr;
-	addr = (host_addr & (~PAGE_MASK_4K)) + size;
-	return PAGE_ALIGN_4K(addr);
+	addr = (host_addr & (~PAGE_MASK)) + size;
+	return PAGE_ALIGN(addr);
 }
 
 struct iova *
@@ -1753,7 +1761,7 @@ iommu_alloc_iova(struct dmar_domain *domain, size_t size, u64 end)
 		return NULL;
 
 	piova = alloc_iova(&domain->iovad,
-			size >> PAGE_SHIFT_4K, IOVA_PFN(end), 1);
+			size >> PAGE_SHIFT, IOVA_PFN(end), 1);
 	return piova;
 }
 
@@ -1813,8 +1821,9 @@ get_valid_domain_for_dev(struct pci_dev *pdev)
 	return domain;
 }
 
-static dma_addr_t
-intel_map_single(struct device *hwdev, phys_addr_t paddr, size_t size, int dir)
+dma_addr_t
+intel_map_single(struct device *hwdev, unsigned long paddr, size_t size,
+		 int dir)
 {
 	struct pci_dev *pdev = to_pci_dev(hwdev);
 	struct dmar_domain *domain;
@@ -1825,7 +1834,7 @@ intel_map_single(struct device *hwdev, phys_addr_t paddr, size_t size, int dir)
 
 	BUG_ON(dir = DMA_NONE);
 	if (pdev->dev.archdata.iommu = DUMMY_DEVICE_DOMAIN_INFO)
-		return paddr;
+		return (dma_addr_t)paddr;
 
 	domain = get_valid_domain_for_dev(pdev);
 	if (!domain)
@@ -1837,7 +1846,7 @@ intel_map_single(struct device *hwdev, phys_addr_t paddr, size_t size, int dir)
 	if (!iova)
 		goto error;
 
-	start_paddr = iova->pfn_lo << PAGE_SHIFT_4K;
+	start_paddr = iova->pfn_lo << PAGE_SHIFT;
 
 	/*
 	 * Check if DMAR supports zero-length reads on write only
@@ -1855,27 +1864,23 @@ intel_map_single(struct device *hwdev, phys_addr_t paddr, size_t size, int dir)
 	 * is not a big problem
 	 */
 	ret = domain_page_mapping(domain, start_paddr,
-		((u64)paddr) & PAGE_MASK_4K, size, prot);
+		((u64)paddr) & PAGE_MASK, size, prot);
 	if (ret)
 		goto error;
 
-	pr_debug("Device %s request: %lx@%llx mapping: %lx@%llx, dir %d\n",
-		pci_name(pdev), size, (u64)paddr,
-		size, (u64)start_paddr, dir);
-
 	/* it's a non-present to present mapping */
 	ret = iommu_flush_iotlb_psi(domain->iommu, domain->id,
-			start_paddr, size >> PAGE_SHIFT_4K, 1);
+			start_paddr, size >> VTD_PAGE_SHIFT, 1);
 	if (ret)
 		iommu_flush_write_buffer(domain->iommu);
 
-	return (start_paddr + ((u64)paddr & (~PAGE_MASK_4K)));
+	return start_paddr + ((u64)paddr & (~PAGE_MASK));
 
 error:
 	if (iova)
 		__free_iova(&domain->iovad, iova);
 	printk(KERN_ERR"Device %s request: %lx@%llx dir %d --- failed\n",
-		pci_name(pdev), size, (u64)paddr, dir);
+		pci_name(pdev), size, (unsigned long long)paddr, dir);
 	return 0;
 }
 
@@ -1936,7 +1941,8 @@ static void add_unmap(struct dmar_domain *dom, struct iova *iova)
 	spin_unlock_irqrestore(&async_umap_flush_lock, flags);
 }
 
-static void intel_unmap_single(struct device *dev, dma_addr_t dev_addr,
+void
+intel_unmap_single(struct device *dev, dma_addr_t dev_addr,
 	size_t size, int dir)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
@@ -1953,11 +1959,11 @@ static void intel_unmap_single(struct device *dev, dma_addr_t dev_addr,
 	if (!iova)
 		return;
 
-	start_addr = iova->pfn_lo << PAGE_SHIFT_4K;
+	start_addr = iova->pfn_lo << PAGE_SHIFT;
 	size = aligned_size((u64)dev_addr, size);
 
 	pr_debug("Device %s unmapping: %lx@%llx\n",
-		pci_name(pdev), size, (u64)start_addr);
+		pci_name(pdev), size, (unsigned long long)start_addr);
 
 	/*  clear the whole page */
 	dma_pte_clear_range(domain, start_addr, start_addr + size);
@@ -1965,7 +1971,7 @@ static void intel_unmap_single(struct device *dev, dma_addr_t dev_addr,
 	dma_pte_free_pagetable(domain, start_addr, start_addr + size);
 	if (intel_iommu_strict) {
 		if (iommu_flush_iotlb_psi(domain->iommu,
-			domain->id, start_addr, size >> PAGE_SHIFT_4K, 0))
+			domain->id, start_addr, size >> VTD_PAGE_SHIFT, 0))
 			iommu_flush_write_buffer(domain->iommu);
 		/* free iova */
 		__free_iova(&domain->iovad, iova);
@@ -1978,13 +1984,14 @@ static void intel_unmap_single(struct device *dev, dma_addr_t dev_addr,
 	}
 }
 
-static void * intel_alloc_coherent(struct device *hwdev, size_t size,
+void *
+intel_alloc_coherent(struct device *hwdev, size_t size,
 		       dma_addr_t *dma_handle, gfp_t flags)
 {
 	void *vaddr;
 	int order;
 
-	size = PAGE_ALIGN_4K(size);
+	size = PAGE_ALIGN(size);
 	order = get_order(size);
 	flags &= ~(GFP_DMA | GFP_DMA32);
 
@@ -2000,12 +2007,13 @@ static void * intel_alloc_coherent(struct device *hwdev, size_t size,
 	return NULL;
 }
 
-static void intel_free_coherent(struct device *hwdev, size_t size,
+void
+intel_free_coherent(struct device *hwdev, size_t size,
 	void *vaddr, dma_addr_t dma_handle)
 {
 	int order;
 
-	size = PAGE_ALIGN_4K(size);
+	size = PAGE_ALIGN(size);
 	order = get_order(size);
 
 	intel_unmap_single(hwdev, dma_handle, size, DMA_BIDIRECTIONAL);
@@ -2013,7 +2021,8 @@ static void intel_free_coherent(struct device *hwdev, size_t size,
 }
 
 #define SG_ENT_VIRT_ADDRESS(sg)	(sg_virt((sg)))
-static void intel_unmap_sg(struct device *hwdev, struct scatterlist *sglist,
+void
+intel_unmap_sg(struct device *hwdev, struct scatterlist *sglist,
 	int nelems, int dir)
 {
 	int i;
@@ -2038,7 +2047,7 @@ static void intel_unmap_sg(struct device *hwdev, struct scatterlist *sglist,
 		size += aligned_size((u64)addr, sg->length);
 	}
 
-	start_addr = iova->pfn_lo << PAGE_SHIFT_4K;
+	start_addr = iova->pfn_lo << PAGE_SHIFT;
 
 	/*  clear the whole page */
 	dma_pte_clear_range(domain, start_addr, start_addr + size);
@@ -2046,7 +2055,7 @@ static void intel_unmap_sg(struct device *hwdev, struct scatterlist *sglist,
 	dma_pte_free_pagetable(domain, start_addr, start_addr + size);
 
 	if (iommu_flush_iotlb_psi(domain->iommu, domain->id, start_addr,
-			size >> PAGE_SHIFT_4K, 0))
+			size >> VTD_PAGE_SHIFT, 0))
 		iommu_flush_write_buffer(domain->iommu);
 
 	/* free iova */
@@ -2067,7 +2076,8 @@ static int intel_nontranslate_map_sg(struct device *hddev,
 	return nelems;
 }
 
-static int intel_map_sg(struct device *hwdev, struct scatterlist *sglist,
+int
+intel_map_sg(struct device *hwdev, struct scatterlist *sglist,
 				int nelems, int dir)
 {
 	void *addr;
@@ -2112,14 +2122,14 @@ static int intel_map_sg(struct device *hwdev, struct scatterlist *sglist,
 	if (dir = DMA_FROM_DEVICE || dir = DMA_BIDIRECTIONAL)
 		prot |= DMA_PTE_WRITE;
 
-	start_addr = iova->pfn_lo << PAGE_SHIFT_4K;
+	start_addr = iova->pfn_lo << PAGE_SHIFT;
 	offset = 0;
 	for_each_sg(sglist, sg, nelems, i) {
 		addr = SG_ENT_VIRT_ADDRESS(sg);
 		addr = (void *)virt_to_phys(addr);
 		size = aligned_size((u64)addr, sg->length);
 		ret = domain_page_mapping(domain, start_addr + offset,
-			((u64)addr) & PAGE_MASK_4K,
+			((u64)addr) & PAGE_MASK,
 			size, prot);
 		if (ret) {
 			/*  clear the page */
@@ -2133,14 +2143,14 @@ static int intel_map_sg(struct device *hwdev, struct scatterlist *sglist,
 			return 0;
 		}
 		sg->dma_address = start_addr + offset +
-				((u64)addr & (~PAGE_MASK_4K));
+				((u64)addr & (~PAGE_MASK));
 		sg->dma_length = sg->length;
 		offset += size;
 	}
 
 	/* it's a non-present to present mapping */
 	if (iommu_flush_iotlb_psi(domain->iommu, domain->id,
-			start_addr, offset >> PAGE_SHIFT_4K, 1))
+			start_addr, offset >> VTD_PAGE_SHIFT, 1))
 		iommu_flush_write_buffer(domain->iommu);
 	return nelems;
 }
@@ -2180,7 +2190,6 @@ static inline int iommu_devinfo_cache_init(void)
 					 sizeof(struct device_domain_info),
 					 0,
 					 SLAB_HWCACHE_ALIGN,
-
 					 NULL);
 	if (!iommu_devinfo_cache) {
 		printk(KERN_ERR "Couldn't create devinfo cache\n");
@@ -2198,7 +2207,6 @@ static inline int iommu_iova_cache_init(void)
 					 sizeof(struct iova),
 					 0,
 					 SLAB_HWCACHE_ALIGN,
-
 					 NULL);
 	if (!iommu_iova_cache) {
 		printk(KERN_ERR "Couldn't create iova cache\n");
@@ -2327,7 +2335,7 @@ void intel_iommu_domain_exit(struct dmar_domain *domain)
 		return;
 
 	end = DOMAIN_MAX_ADDR(domain->gaw);
-	end = end & (~PAGE_MASK_4K);
+	end = end & (~VTD_PAGE_MASK);
 
 	/* clear ptes */
 	dma_pte_clear_range(domain, 0, end);
@@ -2423,6 +2431,6 @@ u64 intel_iommu_iova_to_pfn(struct dmar_domain *domain, u64 iova)
 	if (pte)
 		pfn = dma_pte_addr(*pte);
 
-	return pfn >> PAGE_SHIFT_4K;
+	return pfn >> VTD_PAGE_SHIFT;
 }
 EXPORT_SYMBOL_GPL(intel_iommu_iova_to_pfn);
diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index b7c2378..5c0ad61 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -30,8 +30,22 @@ int pci_pci_problems;
 EXPORT_SYMBOL(pci_pci_problems);
 int pcie_mch_quirk;
 EXPORT_SYMBOL(pcie_mch_quirk);
+int forbid_dac __read_mostly;
+EXPORT_SYMBOL(forbid_dac);
 
 #ifdef CONFIG_PCI_QUIRKS
+
+/* Many VIA bridges seem to corrupt data for DAC. Disable it here */
+static __devinit void via_no_dac(struct pci_dev *dev)
+{
+	if ((dev->class >> 8) = PCI_CLASS_BRIDGE_PCI && forbid_dac = 0) {
+		dev_info(&dev->dev,
+			"VIA PCI bridge detected. Disabling DAC.\n");
+		forbid_dac = 1;
+	}
+}
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_VIA, PCI_ANY_ID, via_no_dac);
+
 /* The Mellanox Tavor device gives false positive parity errors
  * Mark this device with a broken_parity_status, to allow
  * PCI scanning code to "skip" this now blacklisted device.
diff --git a/include/asm-x86/iommu.h b/include/asm-x86/iommu.h
index 546ad31..fbccb97 100644
--- a/include/asm-x86/iommu.h
+++ b/include/asm-x86/iommu.h
@@ -7,9 +7,13 @@ extern struct dma_mapping_ops nommu_dma_ops;
 extern int force_iommu, no_iommu;
 extern int iommu_detected;
 extern int dmar_disabled;
+extern int forbid_dac;
 
 extern unsigned long iommu_num_pages(unsigned long addr, unsigned long len);
 
+/* 10 seconds */
+#define DMAR_OPERATION_TIMEOUT ((cycles_t) tsc_khz*10*1000)
+
 #ifdef CONFIG_GART_IOMMU
 extern int gart_iommu_aperture;
 extern int gart_iommu_aperture_allowed;
diff --git a/include/linux/dma_remapping.h b/include/linux/dma_remapping.h
index bff5c65..1b49810 100644
--- a/include/linux/dma_remapping.h
+++ b/include/linux/dma_remapping.h
@@ -2,15 +2,14 @@
 #define _DMA_REMAPPING_H
 
 /*
- * We need a fixed PAGE_SIZE of 4K irrespective of
- * arch PAGE_SIZE for IOMMU page tables.
+ * VT-d hardware uses 4K page size regardless host page size.
  */
-#define PAGE_SHIFT_4K		(12)
-#define PAGE_SIZE_4K		(1UL << PAGE_SHIFT_4K)
-#define PAGE_MASK_4K		(((u64)-1) << PAGE_SHIFT_4K)
-#define PAGE_ALIGN_4K(addr)	(((addr) + PAGE_SIZE_4K - 1) & PAGE_MASK_4K)
+#define VTD_PAGE_SHIFT		(12)
+#define VTD_PAGE_SIZE		(1UL << VTD_PAGE_SHIFT)
+#define VTD_PAGE_MASK		(((u64)-1) << VTD_PAGE_SHIFT)
+#define VTD_PAGE_ALIGN(addr)	(((addr) + VTD_PAGE_SIZE - 1) & VTD_PAGE_MASK)
 
-#define IOVA_PFN(addr)		((addr) >> PAGE_SHIFT_4K)
+#define IOVA_PFN(addr)		((addr) >> PAGE_SHIFT)
 #define DMA_32BIT_PFN		IOVA_PFN(DMA_32BIT_MASK)
 #define DMA_64BIT_PFN		IOVA_PFN(DMA_64BIT_MASK)
 
@@ -25,7 +24,7 @@ struct root_entry {
 	u64	val;
 	u64	rsvd1;
 };
-#define ROOT_ENTRY_NR (PAGE_SIZE_4K/sizeof(struct root_entry))
+#define ROOT_ENTRY_NR (VTD_PAGE_SIZE/sizeof(struct root_entry))
 static inline bool root_present(struct root_entry *root)
 {
 	return (root->val & 1);
@@ -36,7 +35,7 @@ static inline void set_root_present(struct root_entry *root)
 }
 static inline void set_root_value(struct root_entry *root, unsigned long value)
 {
-	root->val |= value & PAGE_MASK_4K;
+	root->val |= value & VTD_PAGE_MASK;
 }
 
 struct context_entry;
@@ -45,7 +44,7 @@ get_context_addr_from_root(struct root_entry *root)
 {
 	return (struct context_entry *)
 		(root_present(root)?phys_to_virt(
-		root->val & PAGE_MASK_4K):
+		root->val & VTD_PAGE_MASK) :
 		NULL);
 }
 
@@ -67,7 +66,7 @@ struct context_entry {
 #define context_present(c) ((c).lo & 1)
 #define context_fault_disable(c) (((c).lo >> 1) & 1)
 #define context_translation_type(c) (((c).lo >> 2) & 3)
-#define context_address_root(c) ((c).lo & PAGE_MASK_4K)
+#define context_address_root(c) ((c).lo & VTD_PAGE_MASK)
 #define context_address_width(c) ((c).hi &  7)
 #define context_domain_id(c) (((c).hi >> 8) & ((1 << 16) - 1))
 
@@ -81,7 +80,7 @@ struct context_entry {
 	} while (0)
 #define CONTEXT_TT_MULTI_LEVEL 0
 #define context_set_address_root(c, val) \
-	do {(c).lo |= (val) & PAGE_MASK_4K;} while (0)
+	do {(c).lo |= (val) & VTD_PAGE_MASK; } while (0)
 #define context_set_address_width(c, val) do {(c).hi |= (val) & 7;} while (0)
 #define context_set_domain_id(c, val) \
 	do {(c).hi |= ((val) & ((1 << 16) - 1)) << 8;} while (0)
@@ -107,9 +106,9 @@ struct dma_pte {
 #define dma_set_pte_writable(p) do {(p).val |= DMA_PTE_WRITE;} while (0)
 #define dma_set_pte_prot(p, prot) \
 		do {(p).val = ((p).val & ~3) | ((prot) & 3); } while (0)
-#define dma_pte_addr(p) ((p).val & PAGE_MASK_4K)
+#define dma_pte_addr(p) ((p).val & VTD_PAGE_MASK)
 #define dma_set_pte_addr(p, addr) do {\
-		(p).val |= ((addr) & PAGE_MASK_4K); } while (0)
+		(p).val |= ((addr) & VTD_PAGE_MASK); } while (0)
 #define dma_pte_present(p) (((p).val & 3) != 0)
 
 struct intel_iommu;
diff --git a/include/linux/intel-iommu.h b/include/linux/intel-iommu.h
index e7b196b..0683472 100644
--- a/include/linux/intel-iommu.h
+++ b/include/linux/intel-iommu.h
@@ -27,8 +27,9 @@
 #include <linux/sysdev.h>
 #include <linux/iova.h>
 #include <linux/io.h>
-#include <asm/cacheflush.h>
 #include <linux/dma_remapping.h>
+#include <asm/iommu.h>
+#include <asm/cacheflush.h>
 
 /*
  * Intel IOMMU register specification per version 1.0 public spec.
@@ -200,22 +201,21 @@ static inline void dmar_writeq(void __iomem *addr, u64 val)
 #define dma_frcd_type(d) ((d >> 30) & 1)
 #define dma_frcd_fault_reason(c) (c & 0xff)
 #define dma_frcd_source_id(c) (c & 0xffff)
-#define dma_frcd_page_addr(d) (d & (((u64)-1) << 12)) /* low 64 bit */
-
-#define DMAR_OPERATION_TIMEOUT ((cycles_t) tsc_khz*10*1000) /* 10sec */
-
-#define IOMMU_WAIT_OP(iommu, offset, op, cond, sts) \
-{\
-	cycles_t start_time = get_cycles();\
-	while (1) {\
-		sts = op (iommu->reg + offset);\
-		if (cond)\
-			break;\
+/* low 64 bit */
+#define dma_frcd_page_addr(d) (d & (((u64)-1) << PAGE_SHIFT))
+
+#define IOMMU_WAIT_OP(iommu, offset, op, cond, sts)			\
+do {									\
+	cycles_t start_time = get_cycles();				\
+	while (1) {							\
+		sts = op(iommu->reg + offset);				\
+		if (cond)						\
+			break;						\
 		if (DMAR_OPERATION_TIMEOUT < (get_cycles() - start_time))\
-			panic("DMAR hardware is malfunctioning\n");\
-		cpu_relax();\
-	}\
-}
+			panic("DMAR hardware is malfunctioning\n");	\
+		cpu_relax();						\
+	}								\
+} while (0)
 
 #define QI_LENGTH	256	/* queue length */
 
@@ -316,4 +316,11 @@ struct dmar_domain *intel_iommu_find_domain(struct pci_dev *pdev);
 int intel_iommu_found(void);
 u64 intel_iommu_iova_to_pfn(struct dmar_domain *domain, u64 iova);
 
+extern void *intel_alloc_coherent(struct device *, size_t, dma_addr_t *, gfp_t);
+extern void intel_free_coherent(struct device *, size_t, void *, dma_addr_t);
+extern dma_addr_t intel_map_single(struct device *, unsigned long, size_t, int);
+extern void intel_unmap_single(struct device *, dma_addr_t, size_t, int);
+extern int intel_map_sg(struct device *, struct scatterlist *, int, int);
+extern void intel_unmap_sg(struct device *, struct scatterlist *, int, int);
+
 #endif
