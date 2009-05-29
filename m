From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Date: Fri, 29 May 2009 09:06:23 +0000
Subject: Re: swiotlb: Introduce architecture-specific APIs to replace
Message-Id: <1243587983.5997.38.camel@zakaz.uk.xensource.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-H9z1vqT5tQkmjyunorgV"
List-Id: <linux-ia64.vger.kernel.org>
References: <1243586643-5554-1-git-send-email-ian.campbell@citrix.com>
In-Reply-To: <1243586643-5554-1-git-send-email-ian.campbell@citrix.com>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Becky Bruce <beckyb@kernel.crashing.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Greg KH <gregkh@suse.de>, Ingo Molnar <mingo@elte.hu>, Jeremy Fitzhardinge <jeremy@goop.org>, Kumar Gala <galak@kernel.crashing.org>, Olaf Kirch <okir@suse.de>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linuxppc-dev@ozlabs.org" <linuxppc-dev@ozlabs.org>, "x86@kernel.org" <x86@kernel.org>

--=-H9z1vqT5tQkmjyunorgV
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Subject should have been "swiotlb: Introduce architecture-specific APIs
to replace __weak functions". Seems I never drive git send-email right
first time...

On Fri, 2009-05-29 at 04:43 -0400, Ian Campbell wrote:
> This series does not contain any Xen or PowerPC specific changes, those
> will follow in separate postings.

Becky, here is an updated version of your 2/3 "powerpc: Add support for
swiotlb on 32-bit" [0], compile tested with the new interfaces. The
interdiff is attached.

Ian.

[0] http://ozlabs.org/pipermail/linuxppc-dev/2009-May/072140.html

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index cdc9a6f..561abf9 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -296,9 +296,19 @@ config IOMMU_VMERGE
 config IOMMU_HELPER
 	def_bool PPC64
 
+config SWIOTLB
+	bool "SWIOTLB support"
+	default n
+	select IOMMU_HELPER
+	---help---
+	  Support for IO bounce buffering for systems without an IOMMU.
+	  This allows us to DMA to the full physical address space on
+	  platforms where the size of a physical address is larger
+	  than the bus address.  Not all platforms support this.
+
 config PPC_NEED_DMA_SYNC_OPS
 	def_bool y
-	depends on NOT_COHERENT_CACHE
+	depends on (NOT_COHERENT_CACHE || SWIOTLB)
 
 config HOTPLUG_CPU
 	bool "Support for enabling/disabling CPUs"
diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index cb448d6..b2fcd2b 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -15,9 +15,18 @@
 #include <linux/scatterlist.h>
 #include <linux/dma-attrs.h>
 #include <asm/io.h>
+#include <asm/swiotlb.h>
 
 #define DMA_ERROR_CODE		(~(dma_addr_t)0x0)
 
+/* Some dma direct funcs must be visible for use in other dma_ops */
+extern void *dma_direct_alloc_coherent(struct device *dev, size_t size,
+				       dma_addr_t *dma_handle, gfp_t flag);
+extern void dma_direct_free_coherent(struct device *dev, size_t size,
+				     void *vaddr, dma_addr_t dma_handle);
+
+extern unsigned long get_dma_direct_offset(struct device *dev);
+
 #ifdef CONFIG_NOT_COHERENT_CACHE
 /*
  * DMA-consistent mapping functions for PowerPCs that don't support
@@ -78,6 +87,9 @@ struct dma_mapping_ops {
 				dma_addr_t dma_address, size_t size,
 				enum dma_data_direction direction,
 				struct dma_attrs *attrs);
+	bool		(*map_range)(struct device *dev, u64 mask,
+				     phys_addr_t addr, size_t size,
+				     dma_addr_t *dma_addr_p);
 #ifdef CONFIG_PPC_NEED_DMA_SYNC_OPS
 	void            (*sync_single_range_for_cpu)(struct device *hwdev,
 				dma_addr_t dma_handle, unsigned long offset,
@@ -290,6 +302,16 @@ static inline void dma_unmap_sg(struct device *dev, struct scatterlist *sg,
 	dma_unmap_sg_attrs(dev, sg, nhwentries, direction, NULL);
 }
 
+static inline bool dma_map_range(struct device *hwdev, u64 mask,
+				 phys_addr_t addr, size_t size,
+				 dma_addr_t *dma_addr_p)
+{
+	struct dma_mapping_ops *dma_ops = get_dma_ops(hwdev);
+
+	BUG_ON(!dma_ops);
+	return dma_ops->map_range(hwdev, mask, addr, size, dma_addr_p);
+}
+
 #ifdef CONFIG_PPC_NEED_DMA_SYNC_OPS
 static inline void dma_sync_single_for_cpu(struct device *dev,
 		dma_addr_t dma_handle, size_t size,
@@ -409,6 +431,16 @@ static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 #define dma_is_consistent(d, h)	(1)
 #endif
 
+static inline dma_addr_t phys_to_dma(struct device *hwdev, phys_addr_t paddr)
+{
+        return paddr + get_dma_direct_offset(hwdev);
+}
+
+static inline phys_addr_t dma_to_phys(struct device *hwdev, dma_addr_t daddr)
+{
+        return daddr + get_dma_direct_offset(hwdev);
+}
+
 static inline int dma_get_cache_alignment(void)
 {
 #ifdef CONFIG_PPC64
diff --git a/arch/powerpc/include/asm/swiotlb.h b/arch/powerpc/include/asm/swiotlb.h
new file mode 100644
index 0000000..30891d6
--- /dev/null
+++ b/arch/powerpc/include/asm/swiotlb.h
@@ -0,0 +1,27 @@
+/*
+ * Copyright (C) 2009 Becky Bruce, Freescale Semiconductor
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+
+#ifndef __ASM_SWIOTLB_H
+#define __ASM_SWIOTLB_H
+
+#include <linux/swiotlb.h>
+
+extern struct dma_mapping_ops swiotlb_dma_ops;
+extern struct dma_mapping_ops swiotlb_pci_dma_ops;
+
+int swiotlb_arch_address_needs_mapping(struct device *, dma_addr_t,
+				       size_t size);
+
+static inline void dma_mark_clean(void *addr, size_t size) {}
+
+extern unsigned int ppc_swiotlb_enable;
+int __init swiotlb_setup_bus_notifier(void);
+
+#endif /* __ASM_SWIOTLB_H */
diff --git a/arch/powerpc/kernel/Makefile b/arch/powerpc/kernel/Makefile
index 9ba1bb7..f6d720b 100644
--- a/arch/powerpc/kernel/Makefile
+++ b/arch/powerpc/kernel/Makefile
@@ -82,6 +82,7 @@ obj-$(CONFIG_SMP)		+= smp.o
 obj-$(CONFIG_KPROBES)		+= kprobes.o
 obj-$(CONFIG_PPC_UDBG_16550)	+= legacy_serial.o udbg_16550.o
 obj-$(CONFIG_STACKTRACE)	+= stacktrace.o
+obj-$(CONFIG_SWIOTLB)		+= dma-swiotlb.o
 
 pci64-$(CONFIG_PPC64)		+= pci_dn.o isa-bridge.o
 obj-$(CONFIG_PCI)		+= pci_$(CONFIG_WORD_SIZE).o $(pci64-y) \
diff --git a/arch/powerpc/kernel/dma-swiotlb.c b/arch/powerpc/kernel/dma-swiotlb.c
new file mode 100644
index 0000000..ef2e812
--- /dev/null
+++ b/arch/powerpc/kernel/dma-swiotlb.c
@@ -0,0 +1,137 @@
+/*
+ * Contains routines needed to support swiotlb for ppc.
+ *
+ * Copyright (C) 2009 Becky Bruce, Freescale Semiconductor
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+
+#include <linux/dma-mapping.h>
+#include <linux/pfn.h>
+#include <linux/of_platform.h>
+#include <linux/platform_device.h>
+#include <linux/pci.h>
+
+#include <asm/machdep.h>
+#include <asm/swiotlb.h>
+#include <asm/dma.h>
+#include <asm/abs_addr.h>
+
+int swiotlb __read_mostly;
+unsigned int ppc_swiotlb_enable;
+
+/*
+ * Determine if an address is reachable by a pci device, or if we must bounce.
+ */
+static bool
+pci_map_range(struct device *hwdev, u64 mask,
+	      phys_addr_t addr, size_t size,
+	      dma_addr_t *dma_addr_p)
+{
+	dma_addr_t dma_addr = phys_to_dma(hwdev, addr);
+	dma_addr_t max;
+	struct pci_controller *hose;
+	struct pci_dev *pdev = to_pci_dev(hwdev);
+
+	hose = pci_bus_to_host(pdev->bus);
+	max = hose->dma_window_base_cur + hose->dma_window_size;
+
+	/* check that we're within mapped pci window space */
+	if ((dma_addr + size > max) | (dma_addr < hose->dma_window_base_cur))
+		return false;
+
+	*dma_addr_p = dma_addr;
+	return true;
+}
+
+static bool
+map_range(struct device *dev, u64 mask,
+	  phys_addr_t addr, size_t size,
+	  dma_addr_t *dma_addr_p)
+{
+	dma_addr_t dma_addr = phys_to_dma(dev, addr);
+
+	if (dma_addr + size > mask)
+		return false;
+
+	*dma_addr_p = dma_addr;
+	return true;
+}
+
+
+/*
+ *@the moment, all platforms that use this code only require
+ * swiotlb to be used if we're operating on HIGHMEM.  Since
+ * we don't ever call anything other than map_sg, unmap_sg,
+ * map_page, and unmap_page on highmem, use normal dma_ops
+ * for everything else.
+ */
+struct dma_mapping_ops swiotlb_dma_ops = {
+	.alloc_coherent = dma_direct_alloc_coherent,
+	.free_coherent = dma_direct_free_coherent,
+	.map_sg = swiotlb_map_sg_attrs,
+	.unmap_sg = swiotlb_unmap_sg_attrs,
+	.dma_supported = swiotlb_dma_supported,
+	.map_page = swiotlb_map_page,
+	.unmap_page = swiotlb_unmap_page,
+	.map_range = map_range,
+	.sync_single_range_for_cpu = swiotlb_sync_single_range_for_cpu,
+	.sync_single_range_for_device = swiotlb_sync_single_range_for_device,
+	.sync_sg_for_cpu = swiotlb_sync_sg_for_cpu,
+	.sync_sg_for_device = swiotlb_sync_sg_for_device
+};
+
+struct dma_mapping_ops swiotlb_pci_dma_ops = {
+	.alloc_coherent = dma_direct_alloc_coherent,
+	.free_coherent = dma_direct_free_coherent,
+	.map_sg = swiotlb_map_sg_attrs,
+	.unmap_sg = swiotlb_unmap_sg_attrs,
+	.dma_supported = swiotlb_dma_supported,
+	.map_page = swiotlb_map_page,
+	.unmap_page = swiotlb_unmap_page,
+	.map_range = pci_map_range,
+	.sync_single_range_for_cpu = swiotlb_sync_single_range_for_cpu,
+	.sync_single_range_for_device = swiotlb_sync_single_range_for_device,
+	.sync_sg_for_cpu = swiotlb_sync_sg_for_cpu,
+	.sync_sg_for_device = swiotlb_sync_sg_for_device
+};
+
+static int ppc_swiotlb_bus_notify(struct notifier_block *nb,
+				  unsigned long action, void *data)
+{
+	struct device *dev = data;
+
+	/* We are only intereted in device addition */
+	if (action != BUS_NOTIFY_ADD_DEVICE)
+		return 0;
+
+	/* May need to bounce if the device can't address all of DRAM */
+	if (dma_get_mask(dev) < lmb_end_of_DRAM())
+		set_dma_ops(dev, &swiotlb_dma_ops);
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block ppc_swiotlb_plat_bus_notifier = {
+	.notifier_call = ppc_swiotlb_bus_notify,
+	.priority = 0,
+};
+
+static struct notifier_block ppc_swiotlb_of_bus_notifier = {
+	.notifier_call = ppc_swiotlb_bus_notify,
+	.priority = 0,
+};
+
+int __init swiotlb_setup_bus_notifier(void)
+{
+	bus_register_notifier(&platform_bus_type,
+			      &ppc_swiotlb_plat_bus_notifier);
+	bus_register_notifier(&of_platform_bus_type,
+			      &ppc_swiotlb_of_bus_notifier);
+
+	return 0;
+}
diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
index 6b02793..20a60d6 100644
--- a/arch/powerpc/kernel/dma.c
+++ b/arch/powerpc/kernel/dma.c
@@ -19,7 +19,7 @@
  * default the offset is PCI_DRAM_OFFSET.
  */
 
-static unsigned long get_dma_direct_offset(struct device *dev)
+unsigned long get_dma_direct_offset(struct device *dev)
 {
 	if (dev)
 		return (unsigned long)dev->archdata.dma_data;
diff --git a/arch/powerpc/kernel/setup_32.c b/arch/powerpc/kernel/setup_32.c
index 9e1ca74..1d15424 100644
--- a/arch/powerpc/kernel/setup_32.c
+++ b/arch/powerpc/kernel/setup_32.c
@@ -39,6 +39,7 @@
 #include <asm/serial.h>
 #include <asm/udbg.h>
 #include <asm/mmu_context.h>
+#include <asm/swiotlb.h>
 
 #include "setup.h"
 
@@ -332,6 +333,11 @@ void __init setup_arch(char **cmdline_p)
 		ppc_md.setup_arch();
 	if ( ppc_md.progress ) ppc_md.progress("arch: exit", 0x3eab);
 
+#ifdef CONFIG_SWIOTLB
+	if (ppc_swiotlb_enable)
+		swiotlb_init();
+#endif
+
 	paging_init();
 
 	/* Initialize the MMU context management stuff */
diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
index c410c60..fbcca72 100644
--- a/arch/powerpc/kernel/setup_64.c
+++ b/arch/powerpc/kernel/setup_64.c
@@ -61,6 +61,7 @@
 #include <asm/xmon.h>
 #include <asm/udbg.h>
 #include <asm/kexec.h>
+#include <asm/swiotlb.h>
 
 #include "setup.h"
 
@@ -524,6 +525,11 @@ void __init setup_arch(char **cmdline_p)
 	if (ppc_md.setup_arch)
 		ppc_md.setup_arch();
 
+#ifdef CONFIG_SWIOTLB
+	if (ppc_swiotlb_enable)
+		swiotlb_init();
+#endif
+
 	paging_init();
 	ppc64_boot_msg(0x15, "Setup Done");
 }


--=-H9z1vqT5tQkmjyunorgV
Content-Disposition: attachment; filename="interdiff"
Content-Type: text/x-patch; name="interdiff"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index 3d9e887..b2fcd2b 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -87,8 +87,9 @@ struct dma_mapping_ops {
 				dma_addr_t dma_address, size_t size,
 				enum dma_data_direction direction,
 				struct dma_attrs *attrs);
-	int		(*addr_needs_map)(struct device *dev, dma_addr_t addr,
-				size_t size);
+	bool		(*map_range)(struct device *dev, u64 mask,
+				     phys_addr_t addr, size_t size,
+				     dma_addr_t *dma_addr_p);
 #ifdef CONFIG_PPC_NEED_DMA_SYNC_OPS
 	void            (*sync_single_range_for_cpu)(struct device *hwdev,
 				dma_addr_t dma_handle, unsigned long offset,
@@ -301,6 +302,16 @@ static inline void dma_unmap_sg(struct device *dev, struct scatterlist *sg,
 	dma_unmap_sg_attrs(dev, sg, nhwentries, direction, NULL);
 }
 
+static inline bool dma_map_range(struct device *hwdev, u64 mask,
+				 phys_addr_t addr, size_t size,
+				 dma_addr_t *dma_addr_p)
+{
+	struct dma_mapping_ops *dma_ops = get_dma_ops(hwdev);
+
+	BUG_ON(!dma_ops);
+	return dma_ops->map_range(hwdev, mask, addr, size, dma_addr_p);
+}
+
 #ifdef CONFIG_PPC_NEED_DMA_SYNC_OPS
 static inline void dma_sync_single_for_cpu(struct device *dev,
 		dma_addr_t dma_handle, size_t size,
@@ -420,6 +431,16 @@ static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 #define dma_is_consistent(d, h)	(1)
 #endif
 
+static inline dma_addr_t phys_to_dma(struct device *hwdev, phys_addr_t paddr)
+{
+        return paddr + get_dma_direct_offset(hwdev);
+}
+
+static inline phys_addr_t dma_to_phys(struct device *hwdev, dma_addr_t daddr)
+{
+        return daddr + get_dma_direct_offset(hwdev);
+}
+
 static inline int dma_get_cache_alignment(void)
 {
 #ifdef CONFIG_PPC64
diff --git a/arch/powerpc/kernel/dma-swiotlb.c b/arch/powerpc/kernel/dma-swiotlb.c
index 6c00667..ef2e812 100644
--- a/arch/powerpc/kernel/dma-swiotlb.c
+++ b/arch/powerpc/kernel/dma-swiotlb.c
@@ -24,50 +24,15 @@
 int swiotlb __read_mostly;
 unsigned int ppc_swiotlb_enable;
 
-void *swiotlb_bus_to_virt(struct device *hwdev, dma_addr_t addr)
-{
-	unsigned long pfn = PFN_DOWN(swiotlb_bus_to_phys(hwdev, addr));
-	void *pageaddr = page_address(pfn_to_page(pfn));
-
-	if (pageaddr != NULL)
-		return pageaddr + (addr % PAGE_SIZE);
-	return NULL;
-}
-
-dma_addr_t swiotlb_phys_to_bus(struct device *hwdev, phys_addr_t paddr)
-{
-	return paddr + get_dma_direct_offset(hwdev);
-}
-
-phys_addr_t swiotlb_bus_to_phys(struct device *hwdev, dma_addr_t baddr)
-
-{
-	return baddr - get_dma_direct_offset(hwdev);
-}
-
-/*
- * Determine if an address needs bounce buffering via swiotlb.
- * Going forward I expect the swiotlb code to generalize on using
- * a dma_ops->addr_needs_map, and this function will move from here to the
- * generic swiotlb code.
- */
-int
-swiotlb_arch_address_needs_mapping(struct device *hwdev, dma_addr_t addr,
-				   size_t size)
-{
-	struct dma_mapping_ops *dma_ops = get_dma_ops(hwdev);
-
-	BUG_ON(!dma_ops);
-	return dma_ops->addr_needs_map(hwdev, addr, size);
-}
-
 /*
  * Determine if an address is reachable by a pci device, or if we must bounce.
  */
-static int
-swiotlb_pci_addr_needs_map(struct device *hwdev, dma_addr_t addr, size_t size)
+static bool
+pci_map_range(struct device *hwdev, u64 mask,
+	      phys_addr_t addr, size_t size,
+	      dma_addr_t *dma_addr_p)
 {
-	u64 mask = dma_get_mask(hwdev);
+	dma_addr_t dma_addr = phys_to_dma(hwdev, addr);
 	dma_addr_t max;
 	struct pci_controller *hose;
 	struct pci_dev *pdev = to_pci_dev(hwdev);
@@ -76,16 +41,25 @@ swiotlb_pci_addr_needs_map(struct device *hwdev, dma_addr_t addr, size_t size)
 	max = hose->dma_window_base_cur + hose->dma_window_size;
 
 	/* check that we're within mapped pci window space */
-	if ((addr + size > max) | (addr < hose->dma_window_base_cur))
-		return 1;
+	if ((dma_addr + size > max) | (dma_addr < hose->dma_window_base_cur))
+		return false;
 
-	return !is_buffer_dma_capable(mask, addr, size);
+	*dma_addr_p = dma_addr;
+	return true;
 }
 
-static int
-swiotlb_addr_needs_map(struct device *hwdev, dma_addr_t addr, size_t size)
+static bool
+map_range(struct device *dev, u64 mask,
+	  phys_addr_t addr, size_t size,
+	  dma_addr_t *dma_addr_p)
 {
-	return !is_buffer_dma_capable(dma_get_mask(hwdev), addr, size);
+	dma_addr_t dma_addr = phys_to_dma(dev, addr);
+
+	if (dma_addr + size > mask)
+		return false;
+
+	*dma_addr_p = dma_addr;
+	return true;
 }
 
 
@@ -104,7 +78,7 @@ struct dma_mapping_ops swiotlb_dma_ops = {
 	.dma_supported = swiotlb_dma_supported,
 	.map_page = swiotlb_map_page,
 	.unmap_page = swiotlb_unmap_page,
-	.addr_needs_map = swiotlb_addr_needs_map,
+	.map_range = map_range,
 	.sync_single_range_for_cpu = swiotlb_sync_single_range_for_cpu,
 	.sync_single_range_for_device = swiotlb_sync_single_range_for_device,
 	.sync_sg_for_cpu = swiotlb_sync_sg_for_cpu,
@@ -119,7 +93,7 @@ struct dma_mapping_ops swiotlb_pci_dma_ops = {
 	.dma_supported = swiotlb_dma_supported,
 	.map_page = swiotlb_map_page,
 	.unmap_page = swiotlb_unmap_page,
-	.addr_needs_map = swiotlb_pci_addr_needs_map,
+	.map_range = pci_map_range,
 	.sync_single_range_for_cpu = swiotlb_sync_single_range_for_cpu,
 	.sync_single_range_for_device = swiotlb_sync_single_range_for_device,
 	.sync_sg_for_cpu = swiotlb_sync_sg_for_cpu,

--=-H9z1vqT5tQkmjyunorgV--
