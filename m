From: Zhen Lei <thunder.leizhen@huawei.com>
Date: Sun, 07 Apr 2019 12:41:47 +0000
Subject: [PATCH v4 6/6] x86/iommu: use common boot option iommu.dma_mode
Message-Id: <20190407124147.13576-7-thunder.leizhen@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190407124147.13576-1-thunder.leizhen@huawei.com>
In-Reply-To: <20190407124147.13576-1-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, John Garry <john.garry@huawei.com>, Robin Murphy <robin.murphy@arm.com>, Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Jonathan Corbet <corbet@lwn.net>, linux-doc <linux-doc@vger.kernel.org>, Sebastian Ott <sebott@linux.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>, David Woodhouse <dwmw2@infradead.org>, iommu <iommu@lists.linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, x86 <x86@kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>
Cc: Zhen Lei <thunder.leizhen@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

iommu=pt can be replaced with iommu.dma_mode=passthrough.
iommu=nopt can be replaced with iommu.dma_mode=lazy.
intel_iommu=strict can be replaced with iommu.dma_mode=strict.
amd_iommu=fullflush can be replaced with iommu.dma_mode=strict.

Note: intel_iommu_strict is not deleted because it can also be assigned
in quirk_calpella_no_shadow_gtt().

Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
---
 arch/ia64/include/asm/iommu.h   |  2 --
 arch/ia64/kernel/pci-dma.c      |  2 --
 arch/x86/include/asm/iommu.h    |  1 -
 arch/x86/kernel/pci-dma.c       | 20 --------------------
 drivers/iommu/Kconfig           | 14 ++++++--------
 drivers/iommu/amd_iommu.c       | 12 ++++++------
 drivers/iommu/amd_iommu_init.c  |  4 ----
 drivers/iommu/amd_iommu_types.h |  6 ------
 drivers/iommu/intel-iommu.c     |  7 ++-----
 9 files changed, 14 insertions(+), 54 deletions(-)

diff --git a/arch/ia64/include/asm/iommu.h b/arch/ia64/include/asm/iommu.h
index 7429a72f3f92199..92aceef63710861 100644
--- a/arch/ia64/include/asm/iommu.h
+++ b/arch/ia64/include/asm/iommu.h
@@ -8,10 +8,8 @@
 extern void no_iommu_init(void);
 #ifdef	CONFIG_INTEL_IOMMU
 extern int force_iommu, no_iommu;
-extern int iommu_pass_through;
 extern int iommu_detected;
 #else
-#define iommu_pass_through	(0)
 #define no_iommu		(1)
 #define iommu_detected		(0)
 #endif
diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
index fe988c49f01ce6a..f5d49cd3fbb01a9 100644
--- a/arch/ia64/kernel/pci-dma.c
+++ b/arch/ia64/kernel/pci-dma.c
@@ -22,8 +22,6 @@
 int force_iommu __read_mostly;
 #endif
 
-int iommu_pass_through;
-
 static int __init pci_iommu_init(void)
 {
 	if (iommu_detected)
diff --git a/arch/x86/include/asm/iommu.h b/arch/x86/include/asm/iommu.h
index baedab8ac5385f7..b91623d521d9f0f 100644
--- a/arch/x86/include/asm/iommu.h
+++ b/arch/x86/include/asm/iommu.h
@@ -4,7 +4,6 @@
 
 extern int force_iommu, no_iommu;
 extern int iommu_detected;
-extern int iommu_pass_through;
 
 /* 10 seconds */
 #define DMAR_OPERATION_TIMEOUT ((cycles_t) tsc_khz*10*1000)
diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
index d460998ae828514..bd63d80597ae6d0 100644
--- a/arch/x86/kernel/pci-dma.c
+++ b/arch/x86/kernel/pci-dma.c
@@ -34,21 +34,6 @@
 /* Set this to 1 if there is a HW IOMMU in the system */
 int iommu_detected __read_mostly = 0;
 
-/*
- * This variable becomes 1 if iommu=pt is passed on the kernel command line.
- * If this variable is 1, IOMMU implementations do no DMA translation for
- * devices and allow every device to access to whole physical memory. This is
- * useful if a user wants to use an IOMMU only for KVM device assignment to
- * guests and not for driver dma translation.
- * It is also possible to disable by default in kernel config, and enable with
- * iommu=nopt at boot time.
- */
-#ifdef CONFIG_IOMMU_DEFAULT_PASSTHROUGH
-int iommu_pass_through __read_mostly = 1;
-#else
-int iommu_pass_through __read_mostly;
-#endif
-
 extern struct iommu_table_entry __iommu_table[], __iommu_table_end[];
 
 /* Dummy device used for NULL arguments (normally ISA). */
@@ -139,11 +124,6 @@ static __init int iommu_setup(char *p)
 		if (!strncmp(p, "soft", 4))
 			swiotlb = 1;
 #endif
-		if (!strncmp(p, "pt", 2))
-			iommu_pass_through = 1;
-		if (!strncmp(p, "nopt", 4))
-			iommu_pass_through = 0;
-
 		gart_parse_options(p);
 
 #ifdef CONFIG_CALGARY_IOMMU
diff --git a/drivers/iommu/Kconfig b/drivers/iommu/Kconfig
index b053eeaa82ebca8..ff8c5d0d435cf58 100644
--- a/drivers/iommu/Kconfig
+++ b/drivers/iommu/Kconfig
@@ -78,7 +78,7 @@ choice
 	prompt "IOMMU dma mode"
 	depends on IOMMU_API
 	default IOMMU_DMA_MODE_PASSTHROUGH if (PPC_POWERNV && PCI)
-	default IOMMU_DMA_MODE_LAZY if S390_IOMMU
+	default IOMMU_DMA_MODE_LAZY if (AMD_IOMMU || INTEL_IOMMU || S390_IOMMU)
 	default IOMMU_DMA_MODE_STRICT
 	help
 	  IOMMU dma mode, such as: passthrough, lazy, strict.
@@ -87,9 +87,8 @@ config IOMMU_DMA_MODE_PASSTHROUGH
 	bool "Configure DMA to bypass the IOMMU"
         help
 	  Enable passthrough by default, removing the need to pass in
-	  iommu.dma_mode=passthrough or iommu=pt through command line. If this
-	  is enabled, you can still disable with iommu.dma_mode={lazy|strict}
-	  or iommu=nopt depending on the architecture.
+	  iommu.dma_mode=passthrough through command line. If this is enabled,
+	  you can still disable with iommu.dma_mode={lazy|strict}.
 
 config IOMMU_DMA_MODE_LAZY
 	bool "IOMMU DMA use lazy mode to flush IOTLB and free IOVA"
@@ -97,10 +96,9 @@ config IOMMU_DMA_MODE_LAZY
 	  Support lazy mode, where for every IOMMU DMA unmap operation, the
 	  flush operation of IOTLB and the free operation of IOVA are deferred.
 	  They are only guaranteed to be done before the related IOVA will be
-	  reused. Removing the need to pass in kernel parameters through
-	  command line. For example, iommu.dma_mode=lazy on ARM64. If this is
-	  enabled, you can still disable with kernel parameters, such as
-	  iommu.dma_mode=strict depending on the architecture.
+	  reused. Removing the need to pass in iommu.dma_mode=lazy through
+	  command line. If this is enabled, you can still disable with
+	  iommu.dma_mode=strict.
 
 config IOMMU_DMA_MODE_STRICT
 	bool "IOMMU DMA use strict mode to flush IOTLB and free IOVA"
diff --git a/drivers/iommu/amd_iommu.c b/drivers/iommu/amd_iommu.c
index f7cdd2ab7f11f6c..361fa6d5561a0ff 100644
--- a/drivers/iommu/amd_iommu.c
+++ b/drivers/iommu/amd_iommu.c
@@ -94,7 +94,7 @@
 
 /*
  * Domain for untranslated devices - only allocated
- * if iommu=pt passed on kernel cmd line.
+ * if iommu.dma_mode=passthrough passed on kernel cmd line.
  */
 const struct iommu_ops amd_iommu_ops;
 
@@ -448,7 +448,7 @@ static int iommu_init_device(struct device *dev)
 	 * invalid address), we ignore the capability for the device so
 	 * it'll be forced to go into translation mode.
 	 */
-	if ((iommu_pass_through || !amd_iommu_force_isolation) &&
+	if ((IOMMU_DMA_MODE_IS_PASSTHROUGH() || !amd_iommu_force_isolation) &&
 	    dev_is_pci(dev) && pci_iommuv2_capable(to_pci_dev(dev))) {
 		struct amd_iommu *iommu;
 
@@ -2274,7 +2274,7 @@ static int amd_iommu_add_device(struct device *dev)
 
 	BUG_ON(!dev_data);
 
-	if (iommu_pass_through || dev_data->iommu_v2)
+	if (IOMMU_DMA_MODE_IS_PASSTHROUGH() || dev_data->iommu_v2)
 		iommu_request_dm_for_dev(dev);
 
 	/* Domains are initialized for this device - have a look what we ended up with */
@@ -2479,7 +2479,7 @@ static void __unmap_single(struct dma_ops_domain *dma_dom,
 		start += PAGE_SIZE;
 	}
 
-	if (amd_iommu_unmap_flush) {
+	if (!IOMMU_DMA_MODE_IS_LAZY()) {
 		domain_flush_tlb(&dma_dom->domain);
 		domain_flush_complete(&dma_dom->domain);
 		dma_ops_free_iova(dma_dom, dma_addr, pages);
@@ -2853,10 +2853,10 @@ int __init amd_iommu_init_api(void)
 
 int __init amd_iommu_init_dma_ops(void)
 {
-	swiotlb        = (iommu_pass_through || sme_me_mask) ? 1 : 0;
+	swiotlb = (IOMMU_DMA_MODE_IS_PASSTHROUGH() || sme_me_mask) ? 1 : 0;
 	iommu_detected = 1;
 
-	if (amd_iommu_unmap_flush)
+	if (!IOMMU_DMA_MODE_IS_LAZY())
 		pr_info("IO/TLB flush on unmap enabled\n");
 	else
 		pr_info("Lazy IO/TLB flushing enabled\n");
diff --git a/drivers/iommu/amd_iommu_init.c b/drivers/iommu/amd_iommu_init.c
index 1b1378619fc9ec2..68ab83327997e7b 100644
--- a/drivers/iommu/amd_iommu_init.c
+++ b/drivers/iommu/amd_iommu_init.c
@@ -166,8 +166,6 @@ struct ivmd_header {
 					   to handle */
 LIST_HEAD(amd_iommu_unity_map);		/* a list of required unity mappings
 					   we find in ACPI */
-bool amd_iommu_unmap_flush;		/* if true, flush on every unmap */
-
 LIST_HEAD(amd_iommu_list);		/* list of all AMD IOMMUs in the
 					   system */
 
@@ -2856,8 +2854,6 @@ static int __init parse_amd_iommu_intr(char *str)
 static int __init parse_amd_iommu_options(char *str)
 {
 	for (; *str; ++str) {
-		if (strncmp(str, "fullflush", 9) = 0)
-			amd_iommu_unmap_flush = true;
 		if (strncmp(str, "off", 3) = 0)
 			amd_iommu_disabled = true;
 		if (strncmp(str, "force_isolation", 15) = 0)
diff --git a/drivers/iommu/amd_iommu_types.h b/drivers/iommu/amd_iommu_types.h
index 87965e4d964771b..724182f158523a1 100644
--- a/drivers/iommu/amd_iommu_types.h
+++ b/drivers/iommu/amd_iommu_types.h
@@ -743,12 +743,6 @@ struct unity_map_entry {
 /* allocation bitmap for domain ids */
 extern unsigned long *amd_iommu_pd_alloc_bitmap;
 
-/*
- * If true, the addresses will be flushed on unmap time, not when
- * they are reused
- */
-extern bool amd_iommu_unmap_flush;
-
 /* Smallest max PASID supported by any IOMMU in the system */
 extern u32 amd_iommu_max_pasid;
 
diff --git a/drivers/iommu/intel-iommu.c b/drivers/iommu/intel-iommu.c
index 28cb713d728ceef..500b3182d0a9280 100644
--- a/drivers/iommu/intel-iommu.c
+++ b/drivers/iommu/intel-iommu.c
@@ -451,9 +451,6 @@ static int __init intel_iommu_setup(char *str)
 		} else if (!strncmp(str, "forcedac", 8)) {
 			pr_info("Forcing DAC for PCI devices\n");
 			dmar_forcedac = 1;
-		} else if (!strncmp(str, "strict", 6)) {
-			pr_info("Disable batched IOTLB flush\n");
-			intel_iommu_strict = 1;
 		} else if (!strncmp(str, "sp_off", 6)) {
 			pr_info("Disable supported super page\n");
 			intel_iommu_superpage = 0;
@@ -3408,7 +3405,7 @@ static int __init init_dmars(void)
 		iommu->flush.flush_iotlb(iommu, 0, 0, 0, DMA_TLB_GLOBAL_FLUSH);
 	}
 
-	if (iommu_pass_through)
+	if (IOMMU_DMA_MODE_IS_PASSTHROUGH())
 		iommu_identity_mapping |= IDENTMAP_ALL;
 
 #ifdef CONFIG_INTEL_IOMMU_BROKEN_GFX_WA
@@ -3749,7 +3746,7 @@ static void intel_unmap(struct device *dev, dma_addr_t dev_addr, size_t size)
 
 	freelist = domain_unmap(domain, start_pfn, last_pfn);
 
-	if (intel_iommu_strict) {
+	if (!IOMMU_DMA_MODE_IS_LAZY() || intel_iommu_strict) {
 		iommu_flush_iotlb_psi(iommu, domain, start_pfn,
 				      nrpages, !freelist, 0);
 		/* free iova */
-- 
1.8.3

