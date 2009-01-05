From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Mon, 05 Jan 2009 14:36:12 +0000
Subject: [PATCH 07/13] set up dma_ops appropriately
Message-Id: <1231166178-20050-8-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1231166178-20050-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-3-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-4-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-5-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-6-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-7-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1231166178-20050-7-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

This patch introduces a global pointer, dma_ops, which points to an
appropriate dma_mapping_ops that the kernel should use. This is a
common way to handle multiple dma_mapping_ops (X86, POWER, and SPARC).

dma_ops is set in platform_dma_init. We also set it by hand where
machvec_init is callev via subsys_initcall.

- IA64_DIG_VTD uses vtd_dma_ops.
- IA64_HP_ZX1 uses sba_dma_ops.
- IA64_HP_ZX1_SWIOTLB uses hwsw_dma_ops.
- IA64_SGI_SN2 uses sn_dma_ops.
- The rest use swiotlb_dma_ops.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 arch/ia64/hp/common/hwsw_iommu.c      |    3 +++
 arch/ia64/hp/common/sba_iommu.c       |    9 +++++++++
 arch/ia64/include/asm/machvec.h       |    4 +++-
 arch/ia64/include/asm/machvec_hpzx1.h |    3 ++-
 arch/ia64/include/asm/machvec_sn2.h   |    3 ++-
 arch/ia64/kernel/Makefile             |    2 +-
 arch/ia64/kernel/dma-mapping.c        |    4 ++++
 arch/ia64/kernel/pci-dma.c            |    6 +++---
 arch/ia64/kernel/pci-swiotlb.c        |    6 ++++++
 arch/ia64/sn/pci/pci_dma.c            |    5 +++++
 10 files changed, 38 insertions(+), 7 deletions(-)
 create mode 100644 arch/ia64/kernel/dma-mapping.c

diff --git a/arch/ia64/hp/common/hwsw_iommu.c b/arch/ia64/hp/common/hwsw_iommu.c
index a40dcdd..22145de 100644
--- a/arch/ia64/hp/common/hwsw_iommu.c
+++ b/arch/ia64/hp/common/hwsw_iommu.c
@@ -56,9 +56,12 @@ use_swiotlb (struct device *dev)
 	return dev && dev->dma_mask && !hwiommu_dma_supported(dev, *dev->dma_mask);
 }
 
+struct dma_mapping_ops hwsw_dma_ops;
+
 void __init
 hwsw_init (void)
 {
+	dma_ops = &hwsw_dma_ops;
 	/* default to a smallish 2MB sw I/O TLB */
 	if (swiotlb_late_init_with_default_size (2 * (1<<20)) != 0) {
 #ifdef CONFIG_IA64_GENERIC
diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index 655b9a1..e82870a 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -2065,6 +2065,8 @@ static struct acpi_driver acpi_sba_ioc_driver = {
 	},
 };
 
+extern struct dma_mapping_ops swiotlb_dma_ops;
+
 static int __init
 sba_init(void)
 {
@@ -2078,6 +2080,7 @@ sba_init(void)
 	 * a successful kdump kernel boot is to use the swiotlb.
 	 */
 	if (is_kdump_kernel()) {
+		dma_ops = &swiotlb_dma_ops;
 		if (swiotlb_late_init_with_default_size(64 * (1<<20)) != 0)
 			panic("Unable to initialize software I/O TLB:"
 				  " Try machvec=dig boot option");
@@ -2093,6 +2096,7 @@ sba_init(void)
 		 * If we didn't find something sba_iommu can claim, we
 		 * need to setup the swiotlb and switch to the dig machvec.
 		 */
+		dma_ops = &swiotlb_dma_ops;
 		if (swiotlb_late_init_with_default_size(64 * (1<<20)) != 0)
 			panic("Unable to find SBA IOMMU or initialize "
 			      "software I/O TLB: Try machvec=dig boot option");
@@ -2196,3 +2200,8 @@ struct dma_mapping_ops sba_dma_ops = {
 	.dma_supported_op	= sba_dma_supported,
 	.mapping_error		= sba_dma_mapping_error,
 };
+
+void sba_dma_init(void)
+{
+	dma_ops = &sba_dma_ops;
+}
diff --git a/arch/ia64/include/asm/machvec.h b/arch/ia64/include/asm/machvec.h
index 59c17e4..d40722c 100644
--- a/arch/ia64/include/asm/machvec.h
+++ b/arch/ia64/include/asm/machvec.h
@@ -298,6 +298,8 @@ extern void machvec_init_from_cmdline(const char *cmdline);
 #  error Unknown configuration.  Update arch/ia64/include/asm/machvec.h.
 # endif /* CONFIG_IA64_GENERIC */
 
+extern void swiotlb_dma_init(void);
+
 /*
  * Define default versions so we can extend machvec for new platforms without having
  * to update the machvec files for all existing platforms.
@@ -328,7 +330,7 @@ extern void machvec_init_from_cmdline(const char *cmdline);
 # define platform_kernel_launch_event	machvec_noop
 #endif
 #ifndef platform_dma_init
-# define platform_dma_init		swiotlb_init
+# define platform_dma_init		swiotlb_dma_init
 #endif
 #ifndef platform_dma_alloc_coherent
 # define platform_dma_alloc_coherent	swiotlb_alloc_coherent
diff --git a/arch/ia64/include/asm/machvec_hpzx1.h b/arch/ia64/include/asm/machvec_hpzx1.h
index 2f57f51..dd4140b 100644
--- a/arch/ia64/include/asm/machvec_hpzx1.h
+++ b/arch/ia64/include/asm/machvec_hpzx1.h
@@ -2,6 +2,7 @@
 #define _ASM_IA64_MACHVEC_HPZX1_h
 
 extern ia64_mv_setup_t			dig_setup;
+extern ia64_mv_dma_init			sba_dma_init;
 extern ia64_mv_dma_alloc_coherent	sba_alloc_coherent;
 extern ia64_mv_dma_free_coherent	sba_free_coherent;
 extern ia64_mv_dma_map_single_attrs	sba_map_single_attrs;
@@ -20,7 +21,7 @@ extern ia64_mv_dma_mapping_error	sba_dma_mapping_error;
  */
 #define platform_name				"hpzx1"
 #define platform_setup				dig_setup
-#define platform_dma_init			machvec_noop
+#define platform_dma_init			sba_dma_init
 #define platform_dma_alloc_coherent		sba_alloc_coherent
 #define platform_dma_free_coherent		sba_free_coherent
 #define platform_dma_map_single_attrs		sba_map_single_attrs
diff --git a/arch/ia64/include/asm/machvec_sn2.h b/arch/ia64/include/asm/machvec_sn2.h
index 781308e..c1f6f87 100644
--- a/arch/ia64/include/asm/machvec_sn2.h
+++ b/arch/ia64/include/asm/machvec_sn2.h
@@ -55,6 +55,7 @@ extern ia64_mv_readb_t __sn_readb_relaxed;
 extern ia64_mv_readw_t __sn_readw_relaxed;
 extern ia64_mv_readl_t __sn_readl_relaxed;
 extern ia64_mv_readq_t __sn_readq_relaxed;
+extern ia64_mv_dma_init			sn_dma_init;
 extern ia64_mv_dma_alloc_coherent	sn_dma_alloc_coherent;
 extern ia64_mv_dma_free_coherent	sn_dma_free_coherent;
 extern ia64_mv_dma_map_single_attrs	sn_dma_map_single_attrs;
@@ -110,7 +111,7 @@ extern ia64_mv_pci_fixup_bus_t		sn_pci_fixup_bus;
 #define platform_pci_get_legacy_mem	sn_pci_get_legacy_mem
 #define platform_pci_legacy_read	sn_pci_legacy_read
 #define platform_pci_legacy_write	sn_pci_legacy_write
-#define platform_dma_init		machvec_noop
+#define platform_dma_init		sn_dma_init
 #define platform_dma_alloc_coherent	sn_dma_alloc_coherent
 #define platform_dma_free_coherent	sn_dma_free_coherent
 #define platform_dma_map_single_attrs	sn_dma_map_single_attrs
diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index bc1f62a..f2778f2 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -7,7 +7,7 @@ extra-y	:= head.o init_task.o vmlinux.lds
 obj-y := acpi.o entry.o efi.o efi_stub.o gate-data.o fsys.o ia64_ksyms.o irq.o irq_ia64.o	\
 	 irq_lsapic.o ivt.o machvec.o pal.o patch.o process.o perfmon.o ptrace.o sal.o		\
 	 salinfo.o setup.o signal.o sys_ia64.o time.o traps.o unaligned.o \
-	 unwind.o mca.o mca_asm.o topology.o
+	 unwind.o mca.o mca_asm.o topology.o dma-mapping.o
 
 obj-$(CONFIG_IA64_BRL_EMU)	+= brl_emu.o
 obj-$(CONFIG_IA64_GENERIC)	+= acpi-ext.o
diff --git a/arch/ia64/kernel/dma-mapping.c b/arch/ia64/kernel/dma-mapping.c
new file mode 100644
index 0000000..876665a
--- /dev/null
+++ b/arch/ia64/kernel/dma-mapping.c
@@ -0,0 +1,4 @@
+#include <linux/dma-mapping.h>
+
+struct dma_mapping_ops *dma_ops;
+EXPORT_SYMBOL(dma_ops);
diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
index f8c38bd..1c1224b 100644
--- a/arch/ia64/kernel/pci-dma.c
+++ b/arch/ia64/kernel/pci-dma.c
@@ -41,8 +41,11 @@ struct device fallback_dev = {
 	.dma_mask = &fallback_dev.coherent_dma_mask,
 };
 
+extern struct dma_mapping_ops vtd_dma_ops;
+
 void __init pci_iommu_alloc(void)
 {
+	dma_ops = &vtd_dma_ops;
 	/*
 	 * The order of these functions is important for
 	 * fall-back/fail-over reasons
@@ -76,9 +79,6 @@ iommu_dma_init(void)
 	return;
 }
 
-struct dma_mapping_ops *dma_ops;
-EXPORT_SYMBOL(dma_ops);
-
 int iommu_dma_supported(struct device *dev, u64 mask)
 {
 	struct dma_mapping_ops *ops = get_dma_ops(dev);
diff --git a/arch/ia64/kernel/pci-swiotlb.c b/arch/ia64/kernel/pci-swiotlb.c
index b62fb93..9f172c8 100644
--- a/arch/ia64/kernel/pci-swiotlb.c
+++ b/arch/ia64/kernel/pci-swiotlb.c
@@ -37,6 +37,12 @@ struct dma_mapping_ops swiotlb_dma_ops = {
 	.mapping_error = swiotlb_dma_mapping_error,
 };
 
+void swiotlb_dma_init(void)
+{
+	dma_ops = &swiotlb_dma_ops;
+	swiotlb_init();
+}
+
 void __init pci_swiotlb_init(void)
 {
 	if (!iommu_detected) {
diff --git a/arch/ia64/sn/pci/pci_dma.c b/arch/ia64/sn/pci/pci_dma.c
index 4ad13ff..174a74e 100644
--- a/arch/ia64/sn/pci/pci_dma.c
+++ b/arch/ia64/sn/pci/pci_dma.c
@@ -481,3 +481,8 @@ struct dma_mapping_ops sn_dma_ops = {
 	.mapping_error		= sn_dma_mapping_error,
 	.dma_supported_op	= sn_dma_supported,
 };
+
+void sn_dma_init(void)
+{
+	dma_ops = &sn_dma_ops;
+}
-- 
1.6.0.6

