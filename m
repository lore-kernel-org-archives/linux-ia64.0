From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 07 Jan 2005 21:39:38 +0000
Subject: lost patch?
Message-Id: <16863.410.136476.181549@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony,

Apparently you hadn't merged my ZX1_SWIOTLB patch before applying
Jesse's swiotlb patch [1].  Any reason for that?  If not, please apply
the updated patch (it resolves the merge conflict).

Thanks,

	--david

[1] http://www.gelato.unsw.edu.au/linux-ia64/0412/12173.html

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

diff -Nru a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
--- a/Documentation/kernel-parameters.txt	2005-01-07 13:36:03 -08:00
+++ b/Documentation/kernel-parameters.txt	2005-01-07 13:36:03 -08:00
@@ -657,7 +657,11 @@
 
 	mac53c9x=	[HW,SCSI]
 			Format: <num_esps>,<disconnect>,<nosync>,<can_queue>,<cmd_per_lun>,<sg_tablesize>,<hostid>,<use_tags>
-	
+
+	machvec=	[IA64]
+			Force the use of a particular machine-vector (machvec) in a generic
+			kernel.  Example: machvec=hpzx1_swiotlb
+
 	mad16=		[HW,OSS]
 			Format: <io>,<irq>,<dma>,<dma16>,<mpu_io>,<mpu_irq>,<joystick>
 
diff -Nru a/arch/ia64/Kconfig b/arch/ia64/Kconfig
--- a/arch/ia64/Kconfig	2005-01-07 13:36:03 -08:00
+++ b/arch/ia64/Kconfig	2005-01-07 13:36:03 -08:00
@@ -57,11 +57,12 @@
 	  will run on any supported IA-64 system.  However, if you configure
 	  a kernel for your specific system, it will be faster and smaller.
 
-	  generic	 For any supported IA-64 system
-	  DIG-compliant	 For DIG ("Developer's Interface Guide") compliant systems
-	  HP-zx1/sx1000	 For HP systems
-	  SGI-SN2	 For SGI Altix systems
-	  Ski-simulator  For the HP simulator <http://www.hpl.hp.com/research/linux/ski/>
+	  generic		For any supported IA-64 system
+	  DIG-compliant		For DIG ("Developer's Interface Guide") compliant systems
+	  HP-zx1/sx1000		For HP systems
+	  HP-zx1/sx1000+swiotlb	For HP systems with (broken) DMA-constrained devices.
+	  SGI-SN2		For SGI Altix systems
+	  Ski-simulator		For the HP simulator <http://www.hpl.hp.com/research/linux/ski/>
 
 	  If you don't know what to do, choose "generic".
 
@@ -74,6 +75,15 @@
 	  Build a kernel that runs on HP zx1 and sx1000 systems.  This adds
 	  support for the HP I/O MMU.
 
+config IA64_HP_ZX1_SWIOTLB
+	bool "HP-zx1/sx1000 with software I/O TLB"
+	help
+	  Build a kernel that runs on HP zx1 and sx1000 systems even when they
+	  have broken PCI devices which cannot DMA to full 32 bits.  Apart
+	  from support for the HP I/O MMU, this includes support for the software
+	  I/O TLB, which allows supporting the broken devices at the expense of
+	  wasting some kernel memory (about 2MB by default).
+
 config IA64_SGI_SN2
 	bool "SGI-SN2"
 	help
@@ -180,7 +190,7 @@
 
 config DISCONTIGMEM
 	bool "Discontiguous memory support"
-	depends on (IA64_DIG || IA64_SGI_SN2 || IA64_GENERIC || IA64_HP_ZX1) && NUMA && VIRTUAL_MEM_MAP
+	depends on (IA64_DIG || IA64_SGI_SN2 || IA64_GENERIC || IA64_HP_ZX1 || IA64_HP_ZX1_SWIOTLB) && NUMA && VIRTUAL_MEM_MAP
 	default y if (IA64_SGI_SN2 || IA64_GENERIC) && NUMA
 	help
 	  Say Y to support efficient handling of discontiguous physical memory,
@@ -312,7 +322,7 @@
 
 config PM
 	bool "Power Management support"
-	depends on IA64_GENERIC || IA64_DIG || IA64_HP_ZX1
+	depends on IA64_GENERIC || IA64_DIG || IA64_HP_ZX1 || IA64_HP_ZX1_SWIOTLB
 	default y
 	help
 	  "Power Management" means that parts of your computer are shut
diff -Nru a/arch/ia64/Kconfig.debug b/arch/ia64/Kconfig.debug
--- a/arch/ia64/Kconfig.debug	2005-01-07 13:36:03 -08:00
+++ b/arch/ia64/Kconfig.debug	2005-01-07 13:36:03 -08:00
@@ -16,7 +16,7 @@
 
 config IA64_GRANULE_64MB
 	bool "64MB"
-	depends on !(IA64_GENERIC || IA64_HP_ZX1 || IA64_SGI_SN2)
+	depends on !(IA64_GENERIC || IA64_HP_ZX1 || IA64_HP_ZX1_SWIOTLB || IA64_SGI_SN2)
 
 endchoice
 
diff -Nru a/arch/ia64/Makefile b/arch/ia64/Makefile
--- a/arch/ia64/Makefile	2005-01-07 13:36:03 -08:00
+++ b/arch/ia64/Makefile	2005-01-07 13:36:03 -08:00
@@ -57,11 +57,13 @@
 core-$(CONFIG_IA64_DIG) 	+= arch/ia64/dig/
 core-$(CONFIG_IA64_GENERIC) 	+= arch/ia64/dig/
 core-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/dig/
+core-$(CONFIG_IA64_HP_ZX1_SWIOTLB) += arch/ia64/dig/
 core-$(CONFIG_IA64_SGI_SN2)	+= arch/ia64/sn/
 
 drivers-$(CONFIG_PCI)		+= arch/ia64/pci/
 drivers-$(CONFIG_IA64_HP_SIM)	+= arch/ia64/hp/sim/
 drivers-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/
+drivers-$(CONFIG_IA64_HP_ZX1_SWIOTLB) += arch/ia64/hp/common/ arch/ia64/hp/zx1/
 drivers-$(CONFIG_IA64_GENERIC)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/ arch/ia64/hp/sim/ arch/ia64/sn/
 drivers-$(CONFIG_OPROFILE)	+= arch/ia64/oprofile/
 
diff -Nru a/arch/ia64/hp/common/Makefile b/arch/ia64/hp/common/Makefile
--- a/arch/ia64/hp/common/Makefile	2005-01-07 13:36:03 -08:00
+++ b/arch/ia64/hp/common/Makefile	2005-01-07 13:36:03 -08:00
@@ -6,3 +6,5 @@
 #
 
 obj-y := sba_iommu.o
+obj-$(CONFIG_IA64_HP_ZX1_SWIOTLB) += hwsw_iommu.o
+obj-$(CONFIG_IA64_GENERIC) += hwsw_iommu.o
diff -Nru a/arch/ia64/hp/common/hwsw_iommu.c b/arch/ia64/hp/common/hwsw_iommu.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/arch/ia64/hp/common/hwsw_iommu.c	2005-01-07 13:36:03 -08:00
@@ -0,0 +1,185 @@
+/*
+ * Copyright (c) 2004 Hewlett-Packard Development Company, L.P.
+ *   Contributed by David Mosberger-Tang <davidm@hpl.hp.com>
+ *
+ * This is a pseudo I/O MMU which dispatches to the hardware I/O MMU
+ * whenever possible.  We assume that the hardware I/O MMU requires
+ * full 32-bit addressability, as is the case, e.g., for HP zx1-based
+ * systems (there, the I/O MMU window is mapped at 3-4GB).  If a
+ * device doesn't provide full 32-bit addressability, we fall back on
+ * the sw I/O TLB.  This is good enough to let us support broken
+ * hardware such as soundcards which have a DMA engine that can
+ * address only 28 bits.
+ */
+
+#include <linux/device.h>
+
+#include <asm/machvec.h>
+
+/* swiotlb declarations & definitions: */
+extern void swiotlb_init_with_default_size (size_t size);
+extern ia64_mv_dma_alloc_coherent	swiotlb_alloc_coherent;
+extern ia64_mv_dma_free_coherent	swiotlb_free_coherent;
+extern ia64_mv_dma_map_single		swiotlb_map_single;
+extern ia64_mv_dma_unmap_single		swiotlb_unmap_single;
+extern ia64_mv_dma_map_sg		swiotlb_map_sg;
+extern ia64_mv_dma_unmap_sg		swiotlb_unmap_sg;
+extern ia64_mv_dma_supported		swiotlb_dma_supported;
+extern ia64_mv_dma_mapping_error	swiotlb_dma_mapping_error;
+
+/* hwiommu declarations & definitions: */
+
+extern ia64_mv_dma_alloc_coherent	sba_alloc_coherent;
+extern ia64_mv_dma_free_coherent	sba_free_coherent;
+extern ia64_mv_dma_map_single		sba_map_single;
+extern ia64_mv_dma_unmap_single		sba_unmap_single;
+extern ia64_mv_dma_map_sg		sba_map_sg;
+extern ia64_mv_dma_unmap_sg		sba_unmap_sg;
+extern ia64_mv_dma_supported		sba_dma_supported;
+extern ia64_mv_dma_mapping_error	sba_dma_mapping_error;
+
+#define hwiommu_alloc_coherent		sba_alloc_coherent
+#define hwiommu_free_coherent		sba_free_coherent
+#define hwiommu_map_single		sba_map_single
+#define hwiommu_unmap_single		sba_unmap_single
+#define hwiommu_map_sg			sba_map_sg
+#define hwiommu_unmap_sg		sba_unmap_sg
+#define hwiommu_dma_supported		sba_dma_supported
+#define hwiommu_dma_mapping_error	sba_dma_mapping_error
+#define hwiommu_sync_single_for_cpu	machvec_dma_sync_single
+#define hwiommu_sync_sg_for_cpu		machvec_dma_sync_sg
+#define hwiommu_sync_single_for_device	machvec_dma_sync_single
+#define hwiommu_sync_sg_for_device	machvec_dma_sync_sg
+
+
+/*
+ * Note: we need to make the determination of whether or not to use
+ * the sw I/O TLB based purely on the device structure.  Anything else
+ * would be unreliable or would be too intrusive.
+ */
+static inline int
+use_swiotlb (struct device *dev)
+{
+	return dev && dev->dma_mask && !hwiommu_dma_supported(dev, *dev->dma_mask);
+}
+
+void
+hwsw_init (void)
+{
+	/* default to a smallish 2MB sw I/O TLB */
+	swiotlb_init_with_default_size (2 * (1<<20));
+}
+
+void *
+hwsw_alloc_coherent (struct device *dev, size_t size, dma_addr_t *dma_handle, int flags)
+{
+	if (use_swiotlb(dev))
+		return swiotlb_alloc_coherent(dev, size, dma_handle, flags);
+	else
+		return hwiommu_alloc_coherent(dev, size, dma_handle, flags);
+}
+
+void
+hwsw_free_coherent (struct device *dev, size_t size, void *vaddr, dma_addr_t dma_handle)
+{
+	if (use_swiotlb(dev))
+		swiotlb_free_coherent(dev, size, vaddr, dma_handle);
+	else
+		hwiommu_free_coherent(dev, size, vaddr, dma_handle);
+}
+
+dma_addr_t
+hwsw_map_single (struct device *dev, void *addr, size_t size, int dir)
+{
+	if (use_swiotlb(dev))
+		return swiotlb_map_single(dev, addr, size, dir);
+	else
+		return hwiommu_map_single(dev, addr, size, dir);
+}
+
+void
+hwsw_unmap_single (struct device *dev, dma_addr_t iova, size_t size, int dir)
+{
+	if (use_swiotlb(dev))
+		return swiotlb_unmap_single(dev, iova, size, dir);
+	else
+		return hwiommu_unmap_single(dev, iova, size, dir);
+}
+
+
+int
+hwsw_map_sg (struct device *dev, struct scatterlist *sglist, int nents, int dir)
+{
+	if (use_swiotlb(dev))
+		return swiotlb_map_sg(dev, sglist, nents, dir);
+	else
+		return hwiommu_map_sg(dev, sglist, nents, dir);
+}
+
+void
+hwsw_unmap_sg (struct device *dev, struct scatterlist *sglist, int nents, int dir)
+{
+	if (use_swiotlb(dev))
+		return swiotlb_unmap_sg(dev, sglist, nents, dir);
+	else
+		return hwiommu_unmap_sg(dev, sglist, nents, dir);
+}
+
+void
+hwsw_sync_single_for_cpu (struct device *dev, dma_addr_t addr, size_t size, int dir)
+{
+	if (use_swiotlb(dev))
+		swiotlb_sync_single_for_cpu(dev, addr, size, dir);
+	else
+		hwiommu_sync_single_for_cpu(dev, addr, size, dir);
+}
+
+void
+hwsw_sync_sg_for_cpu (struct device *dev, struct scatterlist *sg, int nelems, int dir)
+{
+	if (use_swiotlb(dev))
+		swiotlb_sync_sg_for_cpu(dev, sg, nelems, dir);
+	else
+		hwiommu_sync_sg_for_cpu(dev, sg, nelems, dir);
+}
+
+void
+hwsw_sync_single_for_device (struct device *dev, dma_addr_t addr, size_t size, int dir)
+{
+	if (use_swiotlb(dev))
+		swiotlb_sync_single_for_device(dev, addr, size, dir);
+	else
+		hwiommu_sync_single_for_device(dev, addr, size, dir);
+}
+
+void
+hwsw_sync_sg_for_device (struct device *dev, struct scatterlist *sg, int nelems, int dir)
+{
+	if (use_swiotlb(dev))
+		swiotlb_sync_sg_for_device(dev, sg, nelems, dir);
+	else
+		hwiommu_sync_sg_for_device(dev, sg, nelems, dir);
+}
+
+int
+hwsw_dma_supported (struct device *dev, u64 mask)
+{
+	if (hwiommu_dma_supported(dev, mask))
+		return 1;
+	return swiotlb_dma_supported(dev, mask);
+}
+
+int
+hwsw_dma_mapping_error (dma_addr_t dma_addr)
+{
+	return hwiommu_dma_mapping_error (dma_addr) || swiotlb_dma_mapping_error(dma_addr);
+}
+
+EXPORT_SYMBOL(hwsw_dma_mapping_error);
+EXPORT_SYMBOL(hwsw_map_single);
+EXPORT_SYMBOL(hwsw_unmap_single);
+EXPORT_SYMBOL(hwsw_map_sg);
+EXPORT_SYMBOL(hwsw_unmap_sg);
+EXPORT_SYMBOL(hwsw_dma_supported);
+EXPORT_SYMBOL(hwsw_alloc_coherent);
+EXPORT_SYMBOL(hwsw_free_coherent);
diff -Nru a/arch/ia64/hp/zx1/Makefile b/arch/ia64/hp/zx1/Makefile
--- a/arch/ia64/hp/zx1/Makefile	2005-01-07 13:36:03 -08:00
+++ b/arch/ia64/hp/zx1/Makefile	2005-01-07 13:36:03 -08:00
@@ -5,4 +5,4 @@
 # Copyright (C) Alex Williamson (alex_williamson@hp.com)
 #
 
-obj-$(CONFIG_IA64_GENERIC) += hpzx1_machvec.o
+obj-$(CONFIG_IA64_GENERIC) += hpzx1_machvec.o hpzx1_swiotlb_machvec.o
diff -Nru a/arch/ia64/hp/zx1/hpzx1_swiotlb_machvec.c b/arch/ia64/hp/zx1/hpzx1_swiotlb_machvec.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/arch/ia64/hp/zx1/hpzx1_swiotlb_machvec.c	2005-01-07 13:36:03 -08:00
@@ -0,0 +1,3 @@
+#define MACHVEC_PLATFORM_NAME		hpzx1_swiotlb
+#define MACHVEC_PLATFORM_HEADER		<asm/machvec_hpzx1_swiotlb.h>
+#include <asm/machvec_init.h>
diff -Nru a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
--- a/arch/ia64/kernel/Makefile	2005-01-07 13:36:03 -08:00
+++ b/arch/ia64/kernel/Makefile	2005-01-07 13:36:03 -08:00
@@ -11,6 +11,7 @@
 obj-$(CONFIG_IA64_BRL_EMU)	+= brl_emu.o
 obj-$(CONFIG_IA64_GENERIC)	+= acpi-ext.o
 obj-$(CONFIG_IA64_HP_ZX1)	+= acpi-ext.o
+obj-$(CONFIG_IA64_HP_ZX1_SWIOTLB) += acpi-ext.o
 obj-$(CONFIG_IA64_PALINFO)	+= palinfo.o
 obj-$(CONFIG_IOSAPIC)		+= iosapic.o
 obj-$(CONFIG_MODULES)		+= module.o
diff -Nru a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
--- a/arch/ia64/kernel/acpi.c	2005-01-07 13:36:03 -08:00
+++ b/arch/ia64/kernel/acpi.c	2005-01-07 13:36:03 -08:00
@@ -113,6 +113,8 @@
 	return "hpsim";
 # elif defined (CONFIG_IA64_HP_ZX1)
 	return "hpzx1";
+# elif defined (CONFIG_IA64_HP_ZX1_SWIOTLB)
+	return "hpzx1_swiotlb";
 # elif defined (CONFIG_IA64_SGI_SN2)
 	return "sn2";
 # elif defined (CONFIG_IA64_DIG)
diff -Nru a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
--- a/arch/ia64/kernel/setup.c	2005-01-07 13:36:03 -08:00
+++ b/arch/ia64/kernel/setup.c	2005-01-07 13:36:03 -08:00
@@ -1,7 +1,7 @@
 /*
  * Architecture-specific setup.
  *
- * Copyright (C) 1998-2001, 2003 Hewlett-Packard Co
+ * Copyright (C) 1998-2001, 2003-2004 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *	Stephane Eranian <eranian@hpl.hp.com>
  * Copyright (C) 2000, Rohit Seth <rohit.seth@intel.com>
@@ -312,7 +312,28 @@
 	io_port_init();
 
 #ifdef CONFIG_IA64_GENERIC
-	machvec_init(acpi_get_sysname());
+	{
+		const char *mvec_name = strstr (*cmdline_p, "machvec=");
+		char str[64];
+
+		if (mvec_name) {
+			const char *end;
+			size_t len;
+
+			mvec_name += 8;
+			end = strchr (mvec_name, ' ');
+			if (end)
+				len = end - mvec_name;
+			else
+				len = strlen (mvec_name);
+			len = min(len, sizeof (str) - 1);
+			strncpy (str, mvec_name, len);
+			str[len] = '\0';
+			mvec_name = str;
+		} else
+			mvec_name = acpi_get_sysname();
+		machvec_init(mvec_name);
+	}
 #endif
 
 	if (early_console_setup(*cmdline_p) = 0)
diff -Nru a/arch/ia64/lib/swiotlb.c b/arch/ia64/lib/swiotlb.c
--- a/arch/ia64/lib/swiotlb.c	2005-01-07 13:36:03 -08:00
+++ b/arch/ia64/lib/swiotlb.c	2005-01-07 13:36:03 -08:00
@@ -61,9 +61,8 @@
 /*
  * The number of IO TLB blocks (in groups of 64) betweeen io_tlb_start and
  * io_tlb_end.  This is command line adjustable via setup_io_tlb_npages.
- * Default to 64MB.
  */
-static unsigned long io_tlb_nslabs = 32768;
+static unsigned long io_tlb_nslabs;
 
 /*
  * When the IOMMU overflows we return a fallback buffer. This sets the size.
@@ -113,10 +112,15 @@
  * structures for the software IO TLB used to implement the PCI DMA API.
  */
 void
-swiotlb_init(void)
+swiotlb_init_with_default_size (size_t default_size)
 {
 	unsigned long i;
 
+	if (!io_tlb_nslabs) {
+		io_tlb_nslabs = (default_size >> PAGE_SHIFT);
+		io_tlb_nslabs = ALIGN(io_tlb_nslabs, IO_TLB_SEGSIZE);
+	}
+
 	/*
 	 * Get IO TLB memory from the low pages
 	 */
@@ -143,6 +147,12 @@
 	io_tlb_overflow_buffer = alloc_bootmem_low(io_tlb_overflow);
 	printk(KERN_INFO "Placing software IO TLB between 0x%lx - 0x%lx\n",
 	       virt_to_phys(io_tlb_start), virt_to_phys(io_tlb_end));
+}
+
+void
+swiotlb_init (void)
+{
+	swiotlb_init_with_default_size(64 * (1<<20));	/* default to 64MB */
 }
 
 static inline int
diff -Nru a/drivers/char/agp/Kconfig b/drivers/char/agp/Kconfig
--- a/drivers/char/agp/Kconfig	2005-01-07 13:36:03 -08:00
+++ b/drivers/char/agp/Kconfig	2005-01-07 13:36:03 -08:00
@@ -144,7 +144,7 @@
 
 config AGP_HP_ZX1
 	tristate "HP ZX1 chipset AGP support"
-	depends on AGP && (IA64_HP_ZX1 || IA64_GENERIC)
+	depends on AGP && (IA64_HP_ZX1 || IA64_HP_ZX1_SWIOTLB || IA64_GENERIC)
 	help
 	  This option gives you AGP GART support for the HP ZX1 chipset
 	  for IA64 processors.
diff -Nru a/include/asm-ia64/machvec.h b/include/asm-ia64/machvec.h
--- a/include/asm-ia64/machvec.h	2005-01-07 13:36:03 -08:00
+++ b/include/asm-ia64/machvec.h	2005-01-07 13:36:03 -08:00
@@ -94,6 +94,8 @@
 #  include <asm/machvec_dig.h>
 # elif defined (CONFIG_IA64_HP_ZX1)
 #  include <asm/machvec_hpzx1.h>
+# elif defined (CONFIG_IA64_HP_ZX1_SWIOTLB)
+#  include <asm/machvec_hpzx1_swiotlb.h>
 # elif defined (CONFIG_IA64_SGI_SN2)
 #  include <asm/machvec_sn2.h>
 # elif defined (CONFIG_IA64_GENERIC)
diff -Nru a/include/asm-ia64/machvec_hpzx1_swiotlb.h b/include/asm-ia64/machvec_hpzx1_swiotlb.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/include/asm-ia64/machvec_hpzx1_swiotlb.h	2005-01-07 13:36:03 -08:00
@@ -0,0 +1,43 @@
+#ifndef _ASM_IA64_MACHVEC_HPZX1_SWIOTLB_h
+#define _ASM_IA64_MACHVEC_HPZX1_SWIOTLB_h
+
+extern ia64_mv_setup_t				dig_setup;
+extern ia64_mv_dma_init				hwsw_init;
+extern ia64_mv_dma_alloc_coherent		hwsw_alloc_coherent;
+extern ia64_mv_dma_free_coherent		hwsw_free_coherent;
+extern ia64_mv_dma_map_single			hwsw_map_single;
+extern ia64_mv_dma_unmap_single			hwsw_unmap_single;
+extern ia64_mv_dma_map_sg			hwsw_map_sg;
+extern ia64_mv_dma_unmap_sg			hwsw_unmap_sg;
+extern ia64_mv_dma_supported			hwsw_dma_supported;
+extern ia64_mv_dma_mapping_error		hwsw_dma_mapping_error;
+extern ia64_mv_dma_sync_single_for_cpu		hwsw_sync_single_for_cpu;
+extern ia64_mv_dma_sync_sg_for_cpu		hwsw_sync_sg_for_cpu;
+extern ia64_mv_dma_sync_single_for_device	hwsw_sync_single_for_device;
+extern ia64_mv_dma_sync_sg_for_device		hwsw_sync_sg_for_device;
+
+/*
+ * This stuff has dual use!
+ *
+ * For a generic kernel, the macros are used to initialize the
+ * platform's machvec structure.  When compiling a non-generic kernel,
+ * the macros are used directly.
+ */
+#define platform_name				"hpzx1_swiotlb"
+
+#define platform_setup				dig_setup
+#define platform_dma_init			hwsw_init
+#define platform_dma_alloc_coherent		hwsw_alloc_coherent
+#define platform_dma_free_coherent		hwsw_free_coherent
+#define platform_dma_map_single			hwsw_map_single
+#define platform_dma_unmap_single		hwsw_unmap_single
+#define platform_dma_map_sg			hwsw_map_sg
+#define platform_dma_unmap_sg			hwsw_unmap_sg
+#define platform_dma_supported			hwsw_dma_supported
+#define platform_dma_mapping_error		hwsw_dma_mapping_error
+#define platform_dma_sync_single_for_cpu	hwsw_sync_single_for_cpu
+#define platform_dma_sync_sg_for_cpu		hwsw_sync_sg_for_cpu
+#define platform_dma_sync_single_for_device	hwsw_sync_single_for_device
+#define platform_dma_sync_sg_for_device		hwsw_sync_sg_for_device
+
+#endif /* _ASM_IA64_MACHVEC_HPZX1_SWIOTLB_h */
diff -Nru a/include/asm-ia64/numnodes.h b/include/asm-ia64/numnodes.h
--- a/include/asm-ia64/numnodes.h	2005-01-07 13:36:03 -08:00
+++ b/include/asm-ia64/numnodes.h	2005-01-07 13:36:03 -08:00
@@ -4,7 +4,7 @@
 #ifdef CONFIG_IA64_DIG
 /* Max 8 Nodes */
 #define NODES_SHIFT	3
-#elif defined(CONFIG_IA64_HP_ZX1)
+#elif defined(CONFIG_IA64_HP_ZX1) || defined(CONFIG_IA64_HP_ZX1_SWIOTLB)
 /* Max 32 Nodes */
 #define NODES_SHIFT	5
 #elif defined(CONFIG_IA64_SGI_SN2) || defined(CONFIG_IA64_GENERIC)
