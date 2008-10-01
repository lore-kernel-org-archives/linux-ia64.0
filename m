From: Fenghua Yu <fenghua.yu@intel.com>
Date: Wed, 01 Oct 2008 16:57:50 +0000
Subject: [PATCH 2/2]Add Variable Page Size and IA64 Support in Intel IOMMU: IA64 Specific Part
Message-Id: <20081001165750.GA21272@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org




Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>
Signed-off-by: Tony Luck <tony.luck@intel.com>

---

 Kconfig                       |   17 ++++
 Makefile                      |    1 
 configs/generic_defconfig     |    2 
 configs/tiger_defconfig       |    2 
 dig/Makefile                  |    2 
 dig/dig_vtd_iommu.c           |   59 +++++++++++++++++
 dig/machvec_vtd.c             |    3 
 include/asm/cacheflush.h      |    2 
 include/asm/device.h          |    3 
 include/asm/dma-mapping.h     |   50 ++++++++++++++
 include/asm/iommu.h           |   11 +++
 include/asm/machvec.h         |    2 
 include/asm/machvec_dig_vtd.h |   38 +++++++++++
 include/asm/machvec_init.h    |    1 
 include/asm/pci.h             |    3 
 include/asm/swiotlb.h         |   56 ++++++++++++++++
 kernel/Makefile               |    4 +
 kernel/acpi.c                 |   17 ++++
 kernel/msi_ia64.c             |   80 +++++++++++++++++++++++
 kernel/pci-dma.c              |  143 ++++++++++++++++++++++++++++++++++++++++++
 kernel/pci-swiotlb.c          |   46 +++++++++++++
 kernel/setup.c                |   42 ++++++++----
 lib/flush.S                   |   55 ++++++++++++++++
 23 files changed, 626 insertions(+), 13 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 48e496f..ae965aa 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -125,6 +125,7 @@ config IA64_GENERIC
 	select NUMA
 	select ACPI_NUMA
 	select SWIOTLB
+	select PCI_MSI
 	help
 	  This selects the system type of your hardware.  A "generic" kernel
 	  will run on any supported IA-64 system.  However, if you configure
@@ -132,6 +133,7 @@ config IA64_GENERIC
 
 	  generic		For any supported IA-64 system
 	  DIG-compliant		For DIG ("Developer's Interface Guide") compliant systems
+	  DIG+Intel+IOMMU	For DIG systems with Intel IOMMU
 	  HP-zx1/sx1000		For HP systems
 	  HP-zx1/sx1000+swiotlb	For HP systems with (broken) DMA-constrained devices.
 	  SGI-SN2		For SGI Altix systems
@@ -144,6 +146,11 @@ config IA64_DIG
 	bool "DIG-compliant"
 	select SWIOTLB
 
+config IA64_DIG_VTD
+	bool "DIG+Intel+IOMMU"
+	select DMAR
+	select PCI_MSI
+
 config IA64_HP_ZX1
 	bool "HP-zx1/sx1000"
 	help
@@ -589,6 +596,16 @@ source "drivers/pci/hotplug/Kconfig"
 
 source "drivers/pcmcia/Kconfig"
 
+config DMAR
+        bool "Support for DMA Remapping Devices (EXPERIMENTAL)"
+        depends on IA64_GENERIC && ACPI && EXPERIMENTAL
+	help
+	  DMA remapping (DMAR) devices support enables independent address
+	  translations for Direct Memory Access (DMA) from devices.
+	  These DMA remapping devices are reported via ACPI tables
+	  and include PCI device scope covered by these DMA
+	  remapping devices.
+
 endmenu
 
 endif
diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index 905d25b..04cecee 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -53,6 +53,7 @@ libs-y				+= arch/ia64/lib/
 core-y				+= arch/ia64/kernel/ arch/ia64/mm/
 core-$(CONFIG_IA32_SUPPORT)	+= arch/ia64/ia32/
 core-$(CONFIG_IA64_DIG) 	+= arch/ia64/dig/
+core-$(CONFIG_IA64_DIG_VTD) 	+= arch/ia64/dig/
 core-$(CONFIG_IA64_GENERIC) 	+= arch/ia64/dig/
 core-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/dig/
 core-$(CONFIG_IA64_HP_ZX1_SWIOTLB) += arch/ia64/dig/
diff --git a/arch/ia64/configs/generic_defconfig b/arch/ia64/configs/generic_defconfig
index 9f48397..e05f9e1 100644
--- a/arch/ia64/configs/generic_defconfig
+++ b/arch/ia64/configs/generic_defconfig
@@ -233,6 +233,8 @@ CONFIG_DMIID=y
 CONFIG_BINFMT_ELF=y
 CONFIG_BINFMT_MISC=m
 
+# CONFIG_DMAR is not set
+
 #
 # Power management and ACPI
 #
diff --git a/arch/ia64/configs/tiger_defconfig b/arch/ia64/configs/tiger_defconfig
index 797acf9..c522edf 100644
--- a/arch/ia64/configs/tiger_defconfig
+++ b/arch/ia64/configs/tiger_defconfig
@@ -172,6 +172,8 @@ CONFIG_DMIID=y
 CONFIG_BINFMT_ELF=y
 CONFIG_BINFMT_MISC=m
 
+# CONFIG_DMAR is not set
+
 #
 # Power management and ACPI
 #
diff --git a/arch/ia64/dig/Makefile b/arch/ia64/dig/Makefile
index 971cd78..5b63eec 100644
--- a/arch/ia64/dig/Makefile
+++ b/arch/ia64/dig/Makefile
@@ -7,3 +7,5 @@
 
 obj-y := setup.o
 obj-$(CONFIG_IA64_GENERIC) += machvec.o
+obj-$(CONFIG_DMAR)	   += machvec_vtd.o dig_vtd_iommu.o
+obj-$(CONFIG_IA64_DIG_VTD) += dig_vtd_iommu.o
diff --git a/arch/ia64/dig/dig_vtd_iommu.c b/arch/ia64/dig/dig_vtd_iommu.c
new file mode 100644
index 0000000..3d79f76
--- /dev/null
+++ b/arch/ia64/dig/dig_vtd_iommu.c
@@ -0,0 +1,59 @@
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/intel-iommu.h>
+
+void *
+vtd_alloc_coherent(struct device *dev, size_t size, dma_addr_t *dma_handle,
+		 gfp_t flags)
+{
+	return intel_alloc_coherent(dev, size, dma_handle, flags);
+}
+EXPORT_SYMBOL_GPL(vtd_alloc_coherent);
+
+void
+vtd_free_coherent(struct device *dev, size_t size, void *vaddr,
+		 dma_addr_t dma_handle)
+{
+	intel_free_coherent(dev, size, vaddr, dma_handle);
+}
+EXPORT_SYMBOL_GPL(vtd_free_coherent);
+
+dma_addr_t
+vtd_map_single_attrs(struct device *dev, unsigned long addr, size_t size,
+		     int dir, struct dma_attrs *attrs)
+{
+	return intel_map_single(dev, addr, size, dir);
+}
+EXPORT_SYMBOL_GPL(vtd_map_single_attrs);
+
+void
+vtd_unmap_single_attrs(struct device *dev, dma_addr_t iova, size_t size,
+		       int dir, struct dma_attrs *attrs)
+{
+	intel_unmap_single(dev, iova, size, dir);
+}
+EXPORT_SYMBOL_GPL(vtd_unmap_single_attrs);
+
+int
+vtd_map_sg_attrs(struct device *dev, struct scatterlist *sglist, int nents,
+		 int dir, struct dma_attrs *attrs)
+{
+	return intel_map_sg(dev, sglist, nents, dir);
+}
+EXPORT_SYMBOL_GPL(vtd_map_sg_attrs);
+
+void
+vtd_unmap_sg_attrs(struct device *dev, struct scatterlist *sglist,
+		   int nents, int dir, struct dma_attrs *attrs)
+{
+	intel_unmap_sg(dev, sglist, nents, dir);
+}
+EXPORT_SYMBOL_GPL(vtd_unmap_sg_attrs);
+
+int
+vtd_dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
+{
+	return 0;
+}
+EXPORT_SYMBOL_GPL(vtd_dma_mapping_error);
diff --git a/arch/ia64/dig/machvec_vtd.c b/arch/ia64/dig/machvec_vtd.c
new file mode 100644
index 0000000..7cd3eb4
--- /dev/null
+++ b/arch/ia64/dig/machvec_vtd.c
@@ -0,0 +1,3 @@
+#define MACHVEC_PLATFORM_NAME		dig_vtd
+#define MACHVEC_PLATFORM_HEADER		<asm/machvec_dig_vtd.h>
+#include <asm/machvec_init.h>
diff --git a/arch/ia64/include/asm/cacheflush.h b/arch/ia64/include/asm/cacheflush.h
index afcfbda..c8ce271 100644
--- a/arch/ia64/include/asm/cacheflush.h
+++ b/arch/ia64/include/asm/cacheflush.h
@@ -34,6 +34,8 @@ do {						\
 #define flush_dcache_mmap_unlock(mapping)	do { } while (0)
 
 extern void flush_icache_range (unsigned long start, unsigned long end);
+extern void clflush_cache_range(void *addr, int size);
+
 
 #define flush_icache_user_range(vma, page, user_addr, len)					\
 do {												\
diff --git a/arch/ia64/include/asm/device.h b/arch/ia64/include/asm/device.h
index 3db6daf..41ab85d 100644
--- a/arch/ia64/include/asm/device.h
+++ b/arch/ia64/include/asm/device.h
@@ -10,6 +10,9 @@ struct dev_archdata {
 #ifdef CONFIG_ACPI
 	void	*acpi_handle;
 #endif
+#ifdef CONFIG_DMAR
+	void *iommu; /* hook for IOMMU specific extension */
+#endif
 };
 
 #endif /* _ASM_IA64_DEVICE_H */
diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
index 06ff1ba..bbab7e2 100644
--- a/arch/ia64/include/asm/dma-mapping.h
+++ b/arch/ia64/include/asm/dma-mapping.h
@@ -7,6 +7,49 @@
  */
 #include <asm/machvec.h>
 #include <linux/scatterlist.h>
+#include <asm/swiotlb.h>
+
+struct dma_mapping_ops {
+	int             (*mapping_error)(struct device *dev,
+					 dma_addr_t dma_addr);
+	void*           (*alloc_coherent)(struct device *dev, size_t size,
+				dma_addr_t *dma_handle, gfp_t gfp);
+	void            (*free_coherent)(struct device *dev, size_t size,
+				void *vaddr, dma_addr_t dma_handle);
+	dma_addr_t      (*map_single)(struct device *hwdev, unsigned long ptr,
+				size_t size, int direction);
+	void            (*unmap_single)(struct device *dev, dma_addr_t addr,
+				size_t size, int direction);
+	void            (*sync_single_for_cpu)(struct device *hwdev,
+				dma_addr_t dma_handle, size_t size,
+				int direction);
+	void            (*sync_single_for_device)(struct device *hwdev,
+				dma_addr_t dma_handle, size_t size,
+				int direction);
+	void            (*sync_single_range_for_cpu)(struct device *hwdev,
+				dma_addr_t dma_handle, unsigned long offset,
+				size_t size, int direction);
+	void            (*sync_single_range_for_device)(struct device *hwdev,
+				dma_addr_t dma_handle, unsigned long offset,
+				size_t size, int direction);
+	void            (*sync_sg_for_cpu)(struct device *hwdev,
+				struct scatterlist *sg, int nelems,
+				int direction);
+	void            (*sync_sg_for_device)(struct device *hwdev,
+				struct scatterlist *sg, int nelems,
+				int direction);
+	int             (*map_sg)(struct device *hwdev, struct scatterlist *sg,
+				int nents, int direction);
+	void            (*unmap_sg)(struct device *hwdev,
+				struct scatterlist *sg, int nents,
+				int direction);
+	int             (*dma_supported_op)(struct device *hwdev, u64 mask);
+	int		is_phys;
+};
+
+extern struct dma_mapping_ops *dma_ops;
+extern struct ia64_machine_vector ia64_mv;
+extern void set_iommu_machvec(void);
 
 #define dma_alloc_coherent(dev, size, handle, gfp)	\
 	platform_dma_alloc_coherent(dev, size, handle, (gfp) | GFP_DMA)
@@ -96,4 +139,11 @@ dma_cache_sync (struct device *dev, void *vaddr, size_t size,
 
 #define dma_is_consistent(d, h)	(1)	/* all we do is coherent memory... */
 
+static inline struct dma_mapping_ops *get_dma_ops(struct device *dev)
+{
+	return dma_ops;
+}
+
+
+
 #endif /* _ASM_IA64_DMA_MAPPING_H */
diff --git a/arch/ia64/include/asm/iommu.h b/arch/ia64/include/asm/iommu.h
new file mode 100644
index 0000000..7707d2f
--- /dev/null
+++ b/arch/ia64/include/asm/iommu.h
@@ -0,0 +1,11 @@
+#ifndef _ASM_IA64_IOMMU_H
+#define _ASM_IA64_IOMMU_H 1
+
+extern void pci_iommu_shutdown(void);
+extern void no_iommu_init(void);
+extern int force_iommu, no_iommu;
+extern int iommu_detected;
+extern void iommu_dma_init(void);
+extern void machvec_init(const char *name);
+
+#endif
diff --git a/arch/ia64/include/asm/machvec.h b/arch/ia64/include/asm/machvec.h
index 2b850cc..ce9b1d0 100644
--- a/arch/ia64/include/asm/machvec.h
+++ b/arch/ia64/include/asm/machvec.h
@@ -120,6 +120,8 @@ extern void machvec_tlb_migrate_finish (struct mm_struct *);
 #  include <asm/machvec_hpsim.h>
 # elif defined (CONFIG_IA64_DIG)
 #  include <asm/machvec_dig.h>
+# elif defined(CONFIG_IA64_DIG_VTD)
+#  include <asm/machvec_dig_vtd.h>
 # elif defined (CONFIG_IA64_HP_ZX1)
 #  include <asm/machvec_hpzx1.h>
 # elif defined (CONFIG_IA64_HP_ZX1_SWIOTLB)
diff --git a/arch/ia64/include/asm/machvec_dig_vtd.h b/arch/ia64/include/asm/machvec_dig_vtd.h
new file mode 100644
index 0000000..3400b56
--- /dev/null
+++ b/arch/ia64/include/asm/machvec_dig_vtd.h
@@ -0,0 +1,38 @@
+#ifndef _ASM_IA64_MACHVEC_DIG_VTD_h
+#define _ASM_IA64_MACHVEC_DIG_VTD_h
+
+extern ia64_mv_setup_t			dig_setup;
+extern ia64_mv_dma_alloc_coherent	vtd_alloc_coherent;
+extern ia64_mv_dma_free_coherent	vtd_free_coherent;
+extern ia64_mv_dma_map_single_attrs	vtd_map_single_attrs;
+extern ia64_mv_dma_unmap_single_attrs	vtd_unmap_single_attrs;
+extern ia64_mv_dma_map_sg_attrs		vtd_map_sg_attrs;
+extern ia64_mv_dma_unmap_sg_attrs	vtd_unmap_sg_attrs;
+extern ia64_mv_dma_supported		iommu_dma_supported;
+extern ia64_mv_dma_mapping_error	vtd_dma_mapping_error;
+extern ia64_mv_dma_init			pci_iommu_alloc;
+
+/*
+ * This stuff has dual use!
+ *
+ * For a generic kernel, the macros are used to initialize the
+ * platform's machvec structure.  When compiling a non-generic kernel,
+ * the macros are used directly.
+ */
+#define platform_name				"dig_vtd"
+#define platform_setup				dig_setup
+#define platform_dma_init			pci_iommu_alloc
+#define platform_dma_alloc_coherent		vtd_alloc_coherent
+#define platform_dma_free_coherent		vtd_free_coherent
+#define platform_dma_map_single_attrs		vtd_map_single_attrs
+#define platform_dma_unmap_single_attrs		vtd_unmap_single_attrs
+#define platform_dma_map_sg_attrs		vtd_map_sg_attrs
+#define platform_dma_unmap_sg_attrs		vtd_unmap_sg_attrs
+#define platform_dma_sync_single_for_cpu	machvec_dma_sync_single
+#define platform_dma_sync_sg_for_cpu		machvec_dma_sync_sg
+#define platform_dma_sync_single_for_device	machvec_dma_sync_single
+#define platform_dma_sync_sg_for_device		machvec_dma_sync_sg
+#define platform_dma_supported			iommu_dma_supported
+#define platform_dma_mapping_error		vtd_dma_mapping_error
+
+#endif /* _ASM_IA64_MACHVEC_DIG_VTD_h */
diff --git a/arch/ia64/include/asm/machvec_init.h b/arch/ia64/include/asm/machvec_init.h
index 7f21249..ef964b2 100644
--- a/arch/ia64/include/asm/machvec_init.h
+++ b/arch/ia64/include/asm/machvec_init.h
@@ -1,3 +1,4 @@
+#include <asm/iommu.h>
 #include <asm/machvec.h>
 
 extern ia64_mv_send_ipi_t ia64_send_ipi;
diff --git a/arch/ia64/include/asm/pci.h b/arch/ia64/include/asm/pci.h
index 0149097..645ef06 100644
--- a/arch/ia64/include/asm/pci.h
+++ b/arch/ia64/include/asm/pci.h
@@ -164,4 +164,7 @@ static inline int pci_get_legacy_ide_irq(struct pci_dev *dev, int channel)
 	return channel ? isa_irq_to_vector(15) : isa_irq_to_vector(14);
 }
 
+#ifdef CONFIG_DMAR
+extern void pci_iommu_alloc(void);
+#endif
 #endif /* _ASM_IA64_PCI_H */
diff --git a/arch/ia64/include/asm/swiotlb.h b/arch/ia64/include/asm/swiotlb.h
new file mode 100644
index 0000000..fb79423
--- /dev/null
+++ b/arch/ia64/include/asm/swiotlb.h
@@ -0,0 +1,56 @@
+#ifndef ASM_IA64__SWIOTLB_H
+#define ASM_IA64__SWIOTLB_H
+
+#include <linux/dma-mapping.h>
+
+/* SWIOTLB interface */
+
+extern dma_addr_t swiotlb_map_single(struct device *hwdev, void *ptr,
+				     size_t size, int dir);
+extern void *swiotlb_alloc_coherent(struct device *hwdev, size_t size,
+				    dma_addr_t *dma_handle, gfp_t flags);
+extern void swiotlb_unmap_single(struct device *hwdev, dma_addr_t dev_addr,
+				 size_t size, int dir);
+extern void swiotlb_sync_single_for_cpu(struct device *hwdev,
+					dma_addr_t dev_addr,
+					size_t size, int dir);
+extern void swiotlb_sync_single_for_device(struct device *hwdev,
+					   dma_addr_t dev_addr,
+					   size_t size, int dir);
+extern void swiotlb_sync_single_range_for_cpu(struct device *hwdev,
+					      dma_addr_t dev_addr,
+					      unsigned long offset,
+					      size_t size, int dir);
+extern void swiotlb_sync_single_range_for_device(struct device *hwdev,
+						 dma_addr_t dev_addr,
+						 unsigned long offset,
+						 size_t size, int dir);
+extern void swiotlb_sync_sg_for_cpu(struct device *hwdev,
+				    struct scatterlist *sg, int nelems,
+				    int dir);
+extern void swiotlb_sync_sg_for_device(struct device *hwdev,
+				       struct scatterlist *sg, int nelems,
+				       int dir);
+extern int swiotlb_map_sg(struct device *hwdev, struct scatterlist *sg,
+			  int nents, int direction);
+extern void swiotlb_unmap_sg(struct device *hwdev, struct scatterlist *sg,
+			     int nents, int direction);
+extern int swiotlb_dma_mapping_error(struct device *hwdev, dma_addr_t dma_addr);
+extern void swiotlb_free_coherent(struct device *hwdev, size_t size,
+				  void *vaddr, dma_addr_t dma_handle);
+extern int swiotlb_dma_supported(struct device *hwdev, u64 mask);
+extern void swiotlb_init(void);
+
+extern int swiotlb_force;
+
+#ifdef CONFIG_SWIOTLB
+extern int swiotlb;
+extern void pci_swiotlb_init(void);
+#else
+#define swiotlb 0
+static inline void pci_swiotlb_init(void)
+{
+}
+#endif
+
+#endif /* ASM_IA64__SWIOTLB_H */
diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 87fea11..af0e750 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -42,6 +42,10 @@ obj-$(CONFIG_IA64_ESI)		+= esi.o
 ifneq ($(CONFIG_IA64_ESI),)
 obj-y				+= esi_stub.o	# must be in kernel proper
 endif
+obj-$(CONFIG_DMAR)		+= pci-dma.o
+ifeq ($(CONFIG_DMAR), y)
+obj-$(CONFIG_SWIOTLB)		+= pci-swiotlb.o
+endif
 
 # The gate DSO image is built using a special linker script.
 targets += gate.so gate-syms.o
diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 5d1eb7e..8cc2f8a 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -91,6 +91,9 @@ acpi_get_sysname(void)
 	struct acpi_table_rsdp *rsdp;
 	struct acpi_table_xsdt *xsdt;
 	struct acpi_table_header *hdr;
+#ifdef CONFIG_DMAR
+	u64 i, nentries;
+#endif
 
 	rsdp_phys = acpi_find_rsdp();
 	if (!rsdp_phys) {
@@ -123,6 +126,18 @@ acpi_get_sysname(void)
 			return "sn2";
 	}
 
+#ifdef CONFIG_DMAR
+	/* Look for Intel IOMMU */
+	nentries = (hdr->length - sizeof(*hdr)) /
+			 sizeof(xsdt->table_offset_entry[0]);
+	for (i = 0; i < nentries; i++) {
+		hdr = __va(xsdt->table_offset_entry[i]);
+		if (strncmp(hdr->signature, ACPI_SIG_DMAR,
+			sizeof(ACPI_SIG_DMAR) - 1) = 0)
+			return "dig_vtd";
+	}
+#endif
+
 	return "dig";
 #else
 # if defined (CONFIG_IA64_HP_SIM)
@@ -137,6 +152,8 @@ acpi_get_sysname(void)
 	return "uv";
 # elif defined (CONFIG_IA64_DIG)
 	return "dig";
+# elif defined(CONFIG_IA64_DIG_VTD)
+	return "dig_vtd";
 # else
 #	error Unknown platform.  Fix acpi.c.
 # endif
diff --git a/arch/ia64/kernel/msi_ia64.c b/arch/ia64/kernel/msi_ia64.c
index 60c6ef6..702a09c 100644
--- a/arch/ia64/kernel/msi_ia64.c
+++ b/arch/ia64/kernel/msi_ia64.c
@@ -5,6 +5,7 @@
 #include <linux/pci.h>
 #include <linux/irq.h>
 #include <linux/msi.h>
+#include <linux/dmar.h>
 #include <asm/smp.h>
 
 /*
@@ -162,3 +163,82 @@ void arch_teardown_msi_irq(unsigned int irq)
 
 	return ia64_teardown_msi_irq(irq);
 }
+
+#ifdef CONFIG_DMAR
+#ifdef CONFIG_SMP
+static void dmar_msi_set_affinity(unsigned int irq, cpumask_t mask)
+{
+	struct irq_cfg *cfg = irq_cfg + irq;
+	struct msi_msg msg;
+	int cpu = first_cpu(mask);
+
+
+	if (!cpu_online(cpu))
+		return;
+
+	if (irq_prepare_move(irq, cpu))
+		return;
+
+	dmar_msi_read(irq, &msg);
+
+	msg.data &= ~MSI_DATA_VECTOR_MASK;
+	msg.data |= MSI_DATA_VECTOR(cfg->vector);
+	msg.address_lo &= ~MSI_ADDR_DESTID_MASK;
+	msg.address_lo |= MSI_ADDR_DESTID_CPU(cpu_physical_id(cpu));
+
+	dmar_msi_write(irq, &msg);
+	irq_desc[irq].affinity = mask;
+}
+#endif /* CONFIG_SMP */
+
+struct irq_chip dmar_msi_type = {
+	.name = "DMAR_MSI",
+	.unmask = dmar_msi_unmask,
+	.mask = dmar_msi_mask,
+	.ack = ia64_ack_msi_irq,
+#ifdef CONFIG_SMP
+	.set_affinity = dmar_msi_set_affinity,
+#endif
+	.retrigger = ia64_msi_retrigger_irq,
+};
+
+static int
+msi_compose_msg(struct pci_dev *pdev, unsigned int irq, struct msi_msg *msg)
+{
+	struct irq_cfg *cfg = irq_cfg + irq;
+	unsigned dest;
+	cpumask_t mask;
+
+	cpus_and(mask, irq_to_domain(irq), cpu_online_map);
+	dest = cpu_physical_id(first_cpu(mask));
+
+	msg->address_hi = 0;
+	msg->address_lo +		MSI_ADDR_HEADER |
+		MSI_ADDR_DESTMODE_PHYS |
+		MSI_ADDR_REDIRECTION_CPU |
+		MSI_ADDR_DESTID_CPU(dest);
+
+	msg->data +		MSI_DATA_TRIGGER_EDGE |
+		MSI_DATA_LEVEL_ASSERT |
+		MSI_DATA_DELIVERY_FIXED |
+		MSI_DATA_VECTOR(cfg->vector);
+	return 0;
+}
+
+int arch_setup_dmar_msi(unsigned int irq)
+{
+	int ret;
+	struct msi_msg msg;
+
+	ret = msi_compose_msg(NULL, irq, &msg);
+	if (ret < 0)
+		return ret;
+	dmar_msi_write(irq, &msg);
+	set_irq_chip_and_handler_name(irq, &dmar_msi_type, handle_edge_irq,
+		"edge");
+	return 0;
+}
+#endif /* CONFIG_DMAR */
+
diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
new file mode 100644
index 0000000..861ca5c
--- /dev/null
+++ b/arch/ia64/kernel/pci-dma.c
@@ -0,0 +1,143 @@
+/*
+ * Dynamic DMA mapping support.
+ */
+
+#include <linux/types.h>
+#include <linux/mm.h>
+#include <linux/string.h>
+#include <linux/pci.h>
+#include <linux/module.h>
+#include <linux/dmar.h>
+#include <asm/iommu.h>
+#include <asm/machvec.h>
+#include <linux/dma-mapping.h>
+
+#include <asm/machvec.h>
+#include <asm/system.h>
+
+#ifdef CONFIG_DMAR
+
+#include <linux/kernel.h>
+#include <linux/string.h>
+
+#include <asm/page.h>
+#include <asm/iommu.h>
+
+dma_addr_t bad_dma_address __read_mostly;
+EXPORT_SYMBOL(bad_dma_address);
+
+static int iommu_sac_force __read_mostly;
+
+int no_iommu __read_mostly;
+#ifdef CONFIG_IOMMU_DEBUG
+int force_iommu __read_mostly = 1;
+#else
+int force_iommu __read_mostly;
+#endif
+
+/* Set this to 1 if there is a HW IOMMU in the system */
+int iommu_detected __read_mostly;
+
+/* Dummy device used for NULL arguments (normally ISA). Better would
+   be probably a smaller DMA mask, but this is bug-to-bug compatible
+   to i386. */
+struct device fallback_dev = {
+	.bus_id = "fallback device",
+	.coherent_dma_mask = DMA_32BIT_MASK,
+	.dma_mask = &fallback_dev.coherent_dma_mask,
+};
+
+static int forbid_dac __read_mostly;
+
+void __init pci_iommu_alloc(void)
+{
+	/*
+	 * The order of these functions is important for
+	 * fall-back/fail-over reasons
+	 */
+	detect_intel_iommu();
+
+#ifdef CONFIG_SWIOTLB
+	pci_swiotlb_init();
+#endif
+}
+
+static int __init pci_iommu_init(void)
+{
+	if (iommu_detected)
+		intel_iommu_init();
+
+	return 0;
+}
+
+void pci_iommu_shutdown(void)
+{
+	return;
+}
+
+void __init
+iommu_dma_init(void)
+{
+	return;
+}
+
+#ifdef CONFIG_PCI
+/* Many VIA bridges seem to corrupt data for DAC. Disable it here */
+
+static __devinit void via_no_dac(struct pci_dev *dev)
+{
+	if ((dev->class >> 8) = PCI_CLASS_BRIDGE_PCI && forbid_dac = 0) {
+		printk(KERN_INFO "PCI: VIA PCI bridge detected. Disabling DAC.\n");
+		forbid_dac = 1;
+	}
+}
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_VIA, PCI_ANY_ID, via_no_dac);
+#endif
+/* Must execute after PCI subsystem */
+fs_initcall(pci_iommu_init);
+
+struct dma_mapping_ops *dma_ops;
+EXPORT_SYMBOL(dma_ops);
+
+int iommu_dma_supported(struct device *dev, u64 mask)
+{
+	struct dma_mapping_ops *ops = get_dma_ops(dev);
+
+#ifdef CONFIG_PCI
+	if (mask > 0xffffffff && forbid_dac > 0) {
+		dev_info(dev, "PCI: Disallowing DAC for device\n");
+		return 0;
+	}
+#endif
+
+	if (ops->dma_supported_op)
+		return ops->dma_supported_op(dev, mask);
+
+	/* Copied from i386. Doesn't make much sense, because it will
+	   only work for pci_alloc_coherent.
+	   The caller just has to use GFP_DMA in this case. */
+	if (mask < DMA_24BIT_MASK)
+		return 0;
+
+	/* Tell the device to use SAC when IOMMU force is on.  This
+	   allows the driver to use cheaper accesses in some cases.
+
+	   Problem with this is that if we overflow the IOMMU area and
+	   return DAC as fallback address the device may not handle it
+	   correctly.
+
+	   As a special case some controllers have a 39bit address
+	   mode that is as efficient as 32bit (aic79xx). Don't force
+	   SAC for these.  Assume all masks <= 40 bits are of this
+	   type. Normally this doesn't make any difference, but gives
+	   more gentle handling of IOMMU overflow. */
+	if (iommu_sac_force && (mask >= DMA_40BIT_MASK)) {
+		dev_info(dev, "Force SAC with mask %lx\n", mask);
+		return 0;
+	}
+
+	return 1;
+}
+EXPORT_SYMBOL(iommu_dma_supported);
+
+#endif
diff --git a/arch/ia64/kernel/pci-swiotlb.c b/arch/ia64/kernel/pci-swiotlb.c
new file mode 100644
index 0000000..16c5051
--- /dev/null
+++ b/arch/ia64/kernel/pci-swiotlb.c
@@ -0,0 +1,46 @@
+/* Glue code to lib/swiotlb.c */
+
+#include <linux/pci.h>
+#include <linux/cache.h>
+#include <linux/module.h>
+#include <linux/dma-mapping.h>
+
+#include <asm/swiotlb.h>
+#include <asm/dma.h>
+#include <asm/iommu.h>
+#include <asm/machvec.h>
+
+int swiotlb __read_mostly;
+EXPORT_SYMBOL(swiotlb);
+
+struct dma_mapping_ops swiotlb_dma_ops = {
+	.mapping_error = swiotlb_dma_mapping_error,
+	.alloc_coherent = swiotlb_alloc_coherent,
+	.free_coherent = swiotlb_free_coherent,
+	.map_single = swiotlb_map_single,
+	.unmap_single = swiotlb_unmap_single,
+	.sync_single_for_cpu = swiotlb_sync_single_for_cpu,
+	.sync_single_for_device = swiotlb_sync_single_for_device,
+	.sync_single_range_for_cpu = swiotlb_sync_single_range_for_cpu,
+	.sync_single_range_for_device = swiotlb_sync_single_range_for_device,
+	.sync_sg_for_cpu = swiotlb_sync_sg_for_cpu,
+	.sync_sg_for_device = swiotlb_sync_sg_for_device,
+	.map_sg = swiotlb_map_sg,
+	.unmap_sg = swiotlb_unmap_sg,
+	.dma_supported_op = swiotlb_dma_supported,
+};
+
+void __init pci_swiotlb_init(void)
+{
+	if (!iommu_detected) {
+#ifdef CONFIG_IA64_GENERIC
+		swiotlb = 1;
+		printk(KERN_INFO "PCI-DMA: Re-initialize machine vector.\n");
+		machvec_init("dig");
+		swiotlb_init();
+		dma_ops = &swiotlb_dma_ops;
+#else
+		panic("Unable to find Intel IOMMU");
+#endif
+	}
+}
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index c27d5b2..218c550 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -116,6 +116,13 @@ unsigned int num_io_spaces;
  */
 #define	I_CACHE_STRIDE_SHIFT	5	/* Safest way to go: 32 bytes by 32 bytes */
 unsigned long ia64_i_cache_stride_shift = ~0;
+/*
+ * "clflush_cache_range()" needs to know what processor dependent stride size to
+ * use when it flushes cache lines including both d-cache and i-cache.
+ */
+/* Safest way to go: 32 bytes by 32 bytes */
+#define	CACHE_STRIDE_SHIFT	5
+unsigned long ia64_cache_stride_shift = ~0;
 
 /*
  * The merge_mask variable needs to be set to (max(iommu_page_size(iommu)) - 1).  This
@@ -845,13 +852,14 @@ setup_per_cpu_areas (void)
 }
 
 /*
- * Calculate the max. cache line size.
+ * Do the following calculations:
  *
- * In addition, the minimum of the i-cache stride sizes is calculated for
- * "flush_icache_range()".
+ * 1. the max. cache line size.
+ * 2. the minimum of the i-cache stride sizes for "flush_icache_range()".
+ * 3. the minimum of the cache stride sizes for "clflush_cache_range()".
  */
 static void __cpuinit
-get_max_cacheline_size (void)
+get_cache_info(void)
 {
 	unsigned long line_size, max = 1;
 	u64 l, levels, unique_caches;
@@ -865,12 +873,14 @@ get_max_cacheline_size (void)
                 max = SMP_CACHE_BYTES;
 		/* Safest setup for "flush_icache_range()" */
 		ia64_i_cache_stride_shift = I_CACHE_STRIDE_SHIFT;
+		/* Safest setup for "clflush_cache_range()" */
+		ia64_cache_stride_shift = CACHE_STRIDE_SHIFT;
 		goto out;
         }
 
 	for (l = 0; l < levels; ++l) {
-		status = ia64_pal_cache_config_info(l, /* cache_type (data_or_unified)= */ 2,
-						    &cci);
+		/* cache_type (data_or_unified)=2 */
+		status = ia64_pal_cache_config_info(l, 2, &cci);
 		if (status != 0) {
 			printk(KERN_ERR
 			       "%s: ia64_pal_cache_config_info(l=%lu, 2) failed (status=%ld)\n",
@@ -878,15 +888,21 @@ get_max_cacheline_size (void)
 			max = SMP_CACHE_BYTES;
 			/* The safest setup for "flush_icache_range()" */
 			cci.pcci_stride = I_CACHE_STRIDE_SHIFT;
+			/* The safest setup for "clflush_cache_range()" */
+			ia64_cache_stride_shift = CACHE_STRIDE_SHIFT;
 			cci.pcci_unified = 1;
+		} else {
+			if (cci.pcci_stride < ia64_cache_stride_shift)
+				ia64_cache_stride_shift = cci.pcci_stride;
+
+			line_size = 1 << cci.pcci_line_size;
+			if (line_size > max)
+				max = line_size;
 		}
-		line_size = 1 << cci.pcci_line_size;
-		if (line_size > max)
-			max = line_size;
+
 		if (!cci.pcci_unified) {
-			status = ia64_pal_cache_config_info(l,
-						    /* cache_type (instruction)= */ 1,
-						    &cci);
+			/* cache_type (instruction)=1*/
+			status = ia64_pal_cache_config_info(l, 1, &cci);
 			if (status != 0) {
 				printk(KERN_ERR
 				"%s: ia64_pal_cache_config_info(l=%lu, 1) failed (status=%ld)\n",
@@ -940,7 +956,7 @@ cpu_init (void)
 	}
 #endif
 
-	get_max_cacheline_size();
+	get_cache_info();
 
 	/*
 	 * We can't pass "local_cpu_data" to identify_cpu() because we haven't called
diff --git a/arch/ia64/lib/flush.S b/arch/ia64/lib/flush.S
index 2a0d27f..2c1a948 100644
--- a/arch/ia64/lib/flush.S
+++ b/arch/ia64/lib/flush.S
@@ -60,3 +60,58 @@ GLOBAL_ENTRY(flush_icache_range)
 	mov	ar.lc=r3		// restore ar.lc
 	br.ret.sptk.many rp
 END(flush_icache_range)
+
+	/*
+	 * clflush_cache_range(start,size)
+	 *
+	 *	Flush cache lines from start to start+size-1.
+	 *
+	 *	Must deal with range from start to start+size-1 but nothing else
+	 *	(need to be careful not to touch addresses that may be
+	 *	unmapped).
+	 *
+	 *	Note: "in0" and "in1" are preserved for debugging purposes.
+	 */
+	.section .kprobes.text,"ax"
+GLOBAL_ENTRY(clflush_cache_range)
+
+	.prologue
+	alloc	r2=ar.pfs,2,0,0,0
+	movl	r3=ia64_cache_stride_shift
+ 	mov	r21=1
+	add     r22=in1,in0
+	;;
+	ld8	r20=[r3]		// r20: stride shift
+	sub	r22=r22,r0,1		// last byte address
+	;;
+	shr.u	r23=in0,r20		// start / (stride size)
+	shr.u	r22=r22,r20		// (last byte address) / (stride size)
+	shl	r21=r21,r20		// r21: stride size of the i-cache(s)
+	;;
+	sub	r8=r22,r23		// number of strides - 1
+	shl	r24=r23,r20		// r24: addresses for "fc" +					//	"start" rounded down to stride
+					//	boundary
+	.save	ar.lc,r3
+	mov	r3=ar.lc		// save ar.lc
+	;;
+
+	.body
+	mov	ar.lc=r8
+	;;
+	/*
+	 * 32 byte aligned loop, even number of (actually 2) bundles
+	 */
+.Loop_fc:
+	fc	r24		// issuable on M0 only
+	add	r24=r21,r24	// we flush "stride size" bytes per iteration
+	nop.i	0
+	br.cloop.sptk.few .Loop_fc
+	;;
+	sync.i
+	;;
+	srlz.i
+	;;
+	mov	ar.lc=r3		// restore ar.lc
+	br.ret.sptk.many rp
+END(clflush_cache_range)
