From: Fenghua Yu <fenghua.yu@intel.com>
Date: Mon, 24 Nov 2008 19:53:11 +0000
Subject: [PATCH 1/2] Enable Pass Through Feature in Intel IOMMU
Message-Id: <20081124195311.GA26246@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081001165750.GA21272@linux-os.sc.intel.com> <200810030941.42800.bjorn.helgaas@hp.com> <A6AD88C3F2289247BE726C37303E1EB8844A6398@orsmsx505.amr.corp.intel.com> <200810060855.36880.bjorn.helgaas@hp.com>
In-Reply-To: <200810060855.36880.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Woodhouse <dwmw2@infradead.org>, Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>, "Luck, Tony" <tony.luck@intel.com>, Jesse Barnes <jbarnes@virtuousgeek.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, iommu@lists.linux-foundation.org, kvm@vger.kernel.org


The patch set adds kernel parameter intel_iommu=pt to set up pass through mode in
context mapping entry. This disables DMAR in linux kernel; but KVM still runs on
VT-d. In this mode, kernel uses swiotlb for DMA API functions but other VT-d 
functionalities are enabled for KVM. KVM always uses multi level translation
page table in VT-d. By default, pass though mode is disabled in kernel.

This is useful when people don't want to enable VT-d DMAR in kernel for
reasons like kernel iommu performance concern or debug purpose but still want to
use KVM.

Thanks.

-Fenghua


Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>
Signed-off-by: Weidong Han <weidong.han@intel.com>
Signed-off-by: Allen Kay <allen.m.kay@intel.com>
Signed-off-by: David Woodhouse <david.woodhouse@intel.com>

---

 Documentation/kernel-parameters.txt |    5 +++
 arch/ia64/include/asm/iommu.h       |    1 
 arch/ia64/kernel/pci-swiotlb.c      |    2 -
 arch/x86/include/asm/iommu.h        |    1 
 arch/x86/kernel/pci-swiotlb_64.c    |    4 ++-
 drivers/pci/intel-iommu.c           |   47 ++++++++++++++++++++++++++----------
 include/linux/dma_remapping.h       |    3 ++
 include/linux/intel-iommu.h         |    3 +-
 8 files changed, 50 insertions(+), 16 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index e0f346d..b966185 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -931,6 +931,11 @@ and is between 256 and 4096 characters. It is defined in the file
 			With this option on every unmap_single operation will
 			result in a hardware IOTLB flush operation as opposed
 			to batching them for performance.
+		pt	[Default no Pass Through]
+			This option enables Pass Through in context mapping if
+			Pass Through is supported in hardware. With this option
+			DMAR is disabled in kernel and kernel uses swiotlb, but
+			KVM still uses VT-d hardware.
 
 	io_delay=	[X86-32,X86-64] I/O delay method
 		0x80
diff --git a/arch/ia64/include/asm/iommu.h b/arch/ia64/include/asm/iommu.h
index 0490794..37d41ca 100644
--- a/arch/ia64/include/asm/iommu.h
+++ b/arch/ia64/include/asm/iommu.h
@@ -9,6 +9,7 @@ extern void pci_iommu_shutdown(void);
 extern void no_iommu_init(void);
 extern int force_iommu, no_iommu;
 extern int iommu_detected;
+extern int iommu_pass_through;
 extern void iommu_dma_init(void);
 extern void machvec_init(const char *name);
 
diff --git a/arch/ia64/kernel/pci-swiotlb.c b/arch/ia64/kernel/pci-swiotlb.c
index 16c5051..69135b0 100644
--- a/arch/ia64/kernel/pci-swiotlb.c
+++ b/arch/ia64/kernel/pci-swiotlb.c
@@ -32,7 +32,7 @@ struct dma_mapping_ops swiotlb_dma_ops = {
 
 void __init pci_swiotlb_init(void)
 {
-	if (!iommu_detected) {
+	if (!iommu_detected || iommu_pass_through) {
 #ifdef CONFIG_IA64_GENERIC
 		swiotlb = 1;
 		printk(KERN_INFO "PCI-DMA: Re-initialize machine vector.\n");
diff --git a/arch/x86/include/asm/iommu.h b/arch/x86/include/asm/iommu.h
index 0b500c5..014e94f 100644
--- a/arch/x86/include/asm/iommu.h
+++ b/arch/x86/include/asm/iommu.h
@@ -6,6 +6,7 @@ extern void no_iommu_init(void);
 extern struct dma_mapping_ops nommu_dma_ops;
 extern int force_iommu, no_iommu;
 extern int iommu_detected;
+extern int iommu_pass_through;
 
 extern unsigned long iommu_nr_pages(unsigned long addr, unsigned long len);
 
diff --git a/arch/x86/kernel/pci-swiotlb_64.c b/arch/x86/kernel/pci-swiotlb_64.c
index 3c539d1..4af2425 100644
--- a/arch/x86/kernel/pci-swiotlb_64.c
+++ b/arch/x86/kernel/pci-swiotlb_64.c
@@ -50,8 +50,10 @@ struct dma_mapping_ops swiotlb_dma_ops = {
 void __init pci_swiotlb_init(void)
 {
 	/* don't initialize swiotlb if iommu=off (no_iommu=1) */
-	if (!iommu_detected && !no_iommu && max_pfn > MAX_DMA32_PFN)
+	if ((!iommu_detected && !no_iommu && max_pfn > MAX_DMA32_PFN) ||
+		iommu_pass_through)
 	       swiotlb = 1;
+
 	if (swiotlb_force)
 		swiotlb = 1;
 	if (swiotlb) {
diff --git a/drivers/pci/intel-iommu.c b/drivers/pci/intel-iommu.c
index aec60ad..f164a3c 100644
--- a/drivers/pci/intel-iommu.c
+++ b/drivers/pci/intel-iommu.c
@@ -120,7 +120,6 @@ struct context_entry {
 		(c).lo &= (((u64)-1) << 4) | 3; \
 		(c).lo |= ((val) & 3) << 2; \
 	} while (0)
-#define CONTEXT_TT_MULTI_LEVEL 0
 #define context_set_address_root(c, val) \
 	do {(c).lo |= (val) & VTD_PAGE_MASK; } while (0)
 #define context_set_address_width(c, val) do {(c).hi |= (val) & 7;} while (0)
@@ -203,6 +202,7 @@ static long list_size;
 static void domain_remove_dev_info(struct dmar_domain *domain);
 
 int dmar_disabled;
+int iommu_pass_through;
 static int __initdata dmar_map_gfx = 1;
 static int dmar_forcedac;
 static int intel_iommu_strict;
@@ -231,6 +231,9 @@ static int __init intel_iommu_setup(char *str)
 			printk(KERN_INFO
 				"Intel-IOMMU: disable batched IOTLB flush\n");
 			intel_iommu_strict = 1;
+		} else if (!strncmp(str, "pt", 2)) {
+			iommu_pass_through = 1;
+			printk(KERN_INFO "Intel-IOMMU: Pass Through enabled\n");
 		}
 
 		str += strcspn(str, ",");
@@ -1271,7 +1274,7 @@ static void domain_exit(struct dmar_domain *domain)
 }
 
 static int domain_context_mapping_one(struct dmar_domain *domain,
-		u8 bus, u8 devfn)
+		u8 bus, u8 devfn, int translation)
 {
 	struct context_entry *context;
 	struct intel_iommu *iommu = domain->iommu;
@@ -1279,7 +1282,11 @@ static int domain_context_mapping_one(struct dmar_domain *domain,
 
 	pr_debug("Set context mapping for %02x:%02x.%d\n",
 		bus, PCI_SLOT(devfn), PCI_FUNC(devfn));
+
 	BUG_ON(!domain->pgd);
+	BUG_ON(translation != CONTEXT_TT_PASS_THROUGH &&
+		translation != CONTEXT_TT_MULTI_LEVEL);
+
 	context = device_to_context_entry(iommu, bus, devfn);
 	if (!context)
 		return -ENOMEM;
@@ -1292,7 +1299,7 @@ static int domain_context_mapping_one(struct dmar_domain *domain,
 	context_set_domain_id(*context, domain->id);
 	context_set_address_width(*context, domain->agaw);
 	context_set_address_root(*context, virt_to_phys(domain->pgd));
-	context_set_translation_type(*context, CONTEXT_TT_MULTI_LEVEL);
+	context_set_translation_type(*context, translation);
 	context_set_fault_enable(*context);
 	context_set_present(*context);
 	__iommu_flush_cache(iommu, context, sizeof(*context));
@@ -1310,13 +1317,14 @@ static int domain_context_mapping_one(struct dmar_domain *domain,
 }
 
 static int
-domain_context_mapping(struct dmar_domain *domain, struct pci_dev *pdev)
+domain_context_mapping(struct dmar_domain *domain, struct pci_dev *pdev,
+			int translation)
 {
 	int ret;
 	struct pci_dev *tmp, *parent;
 
 	ret = domain_context_mapping_one(domain, pdev->bus->number,
-		pdev->devfn);
+		pdev->devfn, translation);
 	if (ret)
 		return ret;
 
@@ -1328,17 +1336,17 @@ domain_context_mapping(struct dmar_domain *domain, struct pci_dev *pdev)
 	parent = pdev->bus->self;
 	while (parent != tmp) {
 		ret = domain_context_mapping_one(domain, parent->bus->number,
-			parent->devfn);
+			parent->devfn, translation);
 		if (ret)
 			return ret;
 		parent = parent->bus->self;
 	}
 	if (tmp->is_pcie) /* this is a PCIE-to-PCI bridge */
 		return domain_context_mapping_one(domain,
-			tmp->subordinate->number, 0);
+			tmp->subordinate->number, 0, translation);
 	else /* this is a legacy PCI bridge */
 		return domain_context_mapping_one(domain,
-			tmp->bus->number, tmp->devfn);
+			tmp->bus->number, tmp->devfn, translation);
 }
 
 static int domain_context_mapped(struct dmar_domain *domain,
@@ -1583,6 +1591,8 @@ static int iommu_prepare_identity_map(struct pci_dev *pdev,
 	unsigned long size;
 	unsigned long long base;
 	int ret;
+	int translation = iommu_pass_through ? CONTEXT_TT_PASS_THROUGH :
+				CONTEXT_TT_MULTI_LEVEL;
 
 	printk(KERN_INFO
 		"IOMMU: Setting identity map for device %s [0x%Lx - 0x%Lx]\n",
@@ -1617,7 +1627,7 @@ static int iommu_prepare_identity_map(struct pci_dev *pdev,
 		goto error;
 
 	/* context entry init */
-	ret = domain_context_mapping(domain, pdev);
+	ret = domain_context_mapping(domain, pdev, translation);
 	if (!ret)
 		return 0;
 error:
@@ -1725,6 +1735,7 @@ static int __init init_dmars(void)
 	struct pci_dev *pdev;
 	struct intel_iommu *iommu;
 	int i, ret, unit = 0;
+	int pass_through = 1;
 
 	/*
 	 * for each drhd
@@ -1790,7 +1801,14 @@ static int __init init_dmars(void)
 			printk(KERN_INFO "IOMMU 0x%Lx: using Queued "
 			       "invalidation\n", drhd->reg_base_addr);
 		}
+		if (!ecap_pass_through(iommu->ecap))
+			pass_through = 0;
 	}
+	if (iommu_pass_through & pass_through) {
+		iommu_pass_through = 1;
+		printk(KERN_INFO "IOMMU is using Pass Through.\n");
+	} else
+		iommu_pass_through = 0;
 
 	/*
 	 * For each rmrr
@@ -1921,6 +1939,8 @@ get_valid_domain_for_dev(struct pci_dev *pdev)
 {
 	struct dmar_domain *domain;
 	int ret;
+	int translation = iommu_pass_through ? CONTEXT_TT_PASS_THROUGH :
+				CONTEXT_TT_MULTI_LEVEL;
 
 	domain = get_domain_for_dev(pdev,
 			DEFAULT_DOMAIN_ADDRESS_WIDTH);
@@ -1932,7 +1952,7 @@ get_valid_domain_for_dev(struct pci_dev *pdev)
 
 	/* make sure context mapping is ok */
 	if (unlikely(!domain_context_mapped(domain, pdev))) {
-		ret = domain_context_mapping(domain, pdev);
+		ret = domain_context_mapping(domain, pdev, translation);
 		if (ret) {
 			printk(KERN_ERR
 				"Domain context map for %s failed",
@@ -2450,7 +2470,8 @@ int __init intel_iommu_init(void)
 
 	init_timer(&unmap_timer);
 	force_iommu = 1;
-	dma_ops = &intel_dma_ops;
+	if (!iommu_pass_through)
+		dma_ops = &intel_dma_ops;
 	return 0;
 }
 
@@ -2511,10 +2532,10 @@ struct dmar_domain *intel_iommu_domain_alloc(struct pci_dev *pdev)
 EXPORT_SYMBOL_GPL(intel_iommu_domain_alloc);
 
 int intel_iommu_context_mapping(
-	struct dmar_domain *domain, struct pci_dev *pdev)
+	struct dmar_domain *domain, struct pci_dev *pdev, int translation)
 {
 	int rc;
-	rc = domain_context_mapping(domain, pdev);
+	rc = domain_context_mapping(domain, pdev, translation);
 	return rc;
 }
 EXPORT_SYMBOL_GPL(intel_iommu_context_mapping);
diff --git a/include/linux/dma_remapping.h b/include/linux/dma_remapping.h
index 7799a85..03054a6 100644
--- a/include/linux/dma_remapping.h
+++ b/include/linux/dma_remapping.h
@@ -12,6 +12,9 @@
 #define DMA_PTE_READ (1)
 #define DMA_PTE_WRITE (2)
 
+#define CONTEXT_TT_MULTI_LEVEL	0
+#define CONTEXT_TT_PASS_THROUGH 2
+
 struct intel_iommu;
 struct dmar_domain;
 struct root_entry;
diff --git a/include/linux/intel-iommu.h b/include/linux/intel-iommu.h
index 1bff7bf..229b101 100644
--- a/include/linux/intel-iommu.h
+++ b/include/linux/intel-iommu.h
@@ -120,6 +120,7 @@ static inline void dmar_writeq(void __iomem *addr, u64 val)
 	(ecap_iotlb_offset(e) + ecap_niotlb_iunits(e) * 16)
 #define ecap_coherent(e)	((e) & 0x1)
 #define ecap_qis(e)		((e) & 0x2)
+#define ecap_pass_through(e)	((e >> 6) & 0x1)
 #define ecap_eim_support(e)	((e >> 4) & 0x1)
 #define ecap_ir_support(e)	((e >> 3) & 0x1)
 #define ecap_max_handle_mask(e) ((e >> 20) & 0xf)
@@ -332,7 +333,7 @@ extern void qi_submit_sync(struct qi_desc *desc, struct intel_iommu *iommu);
 void intel_iommu_domain_exit(struct dmar_domain *domain);
 struct dmar_domain *intel_iommu_domain_alloc(struct pci_dev *pdev);
 int intel_iommu_context_mapping(struct dmar_domain *domain,
-				struct pci_dev *pdev);
+				struct pci_dev *pdev, int translation);
 int intel_iommu_page_mapping(struct dmar_domain *domain, dma_addr_t iova,
 			     u64 hpa, size_t size, int prot);
 void intel_iommu_detach_dev(struct dmar_domain *domain, u8 bus, u8 devfn);
