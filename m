From: Mark Maule <maule@sgi.com>
Date: Tue, 08 Feb 2005 00:08:16 +0000
Subject: [PATCH 2.6.11-rc2 1/3] altix: pci dma abstraction
Message-Id: <20050208000816.10005.96029.57542@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050204213203.16671.94089.90028@attica.americas.sgi.com>
In-Reply-To: <20050204213203.16671.94089.90028@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

sn2-pci-dma-abstraction.patch:

Provide an abstraction of the altix pci dma runtime layer so that multiple
pci-based bridges can be supported.

diff -Nru a/arch/ia64/sn/include/pci/pcibr_provider.h b/arch/ia64/sn/include/pci/pcibr_provider.h
--- a/arch/ia64/sn/include/pci/pcibr_provider.h	2005-02-07 11:05:01 -06:00
+++ b/arch/ia64/sn/include/pci/pcibr_provider.h	2005-02-07 11:05:01 -06:00
@@ -123,9 +123,11 @@
 }
 #define pcibr_unlock(pcibus_info, flag)  spin_unlock_irqrestore(&pcibus_info->pbi_lock, flag)
 
+extern int  pcibr_init_provider(void);
 extern void *pcibr_bus_fixup(struct pcibus_bussoft *);
-extern uint64_t pcibr_dma_map(struct pcidev_info *, unsigned long, size_t, unsigned int);
-extern void pcibr_dma_unmap(struct pcidev_info *, dma_addr_t, int);
+extern dma_addr_t pcibr_dma_map(struct pci_dev *, unsigned long, size_t);
+extern dma_addr_t pcibr_dma_map_consistent(struct pci_dev *, unsigned long, size_t);
+extern void pcibr_dma_unmap(struct pci_dev *, dma_addr_t, int);
 
 /*
  * prototypes for the bridge asic register access routines in pcibr_reg.c
diff -Nru a/arch/ia64/sn/include/pci/pcibus_provider_defs.h b/arch/ia64/sn/include/pci/pcibus_provider_defs.h
--- a/arch/ia64/sn/include/pci/pcibus_provider_defs.h	2005-02-07 11:05:01 -06:00
+++ b/arch/ia64/sn/include/pci/pcibus_provider_defs.h	2005-02-07 11:05:01 -06:00
@@ -18,6 +18,8 @@
 #define PCIIO_ASIC_TYPE_PIC	2
 #define PCIIO_ASIC_TYPE_TIOCP	3
 
+#define PCIIO_ASIC_MAX_TYPES	4
+
 /*
  * Common pciio bus provider data.  There should be one of these as the
  * first field in any pciio based provider soft structure (e.g. pcibr_soft
@@ -35,9 +37,15 @@
 };
 
 /*
- * DMA mapping flags
+ * SN pci bus indirection
  */
 
-#define SN_PCIDMA_CONSISTENT    0x0001
+struct sn_pcibus_provider {
+	dma_addr_t	(*dma_map)(struct pci_dev *, unsigned long, size_t);
+	dma_addr_t	(*dma_map_consistent)(struct pci_dev *, unsigned long, size_t);
+	void		(*dma_unmap)(struct pci_dev *, dma_addr_t, int);
+	void *		(*bus_fixup)(struct pcibus_bussoft *);
+};
 
+extern struct sn_pcibus_provider *sn_pci_provider[];
 #endif				/* _ASM_IA64_SN_PCI_PCIBUS_PROVIDER_H */
diff -Nru a/arch/ia64/sn/include/pci/pcidev.h b/arch/ia64/sn/include/pci/pcidev.h
--- a/arch/ia64/sn/include/pci/pcidev.h	2005-02-07 11:05:01 -06:00
+++ b/arch/ia64/sn/include/pci/pcidev.h	2005-02-07 11:05:01 -06:00
@@ -32,6 +32,9 @@
 #define SN_PCIDEV_BUSSOFT(pci_dev) \
 	(SN_PCIDEV_INFO(pci_dev)->pdi_host_pcidev_info->pdi_pcibus_info)
 
+#define SN_PCIDEV_BUSPROVIDER(pci_dev) \
+	(SN_PCIDEV_INFO(pci_dev)->pdi_provider)
+
 #define PCIIO_BUS_NONE	255      /* bus 255 reserved */
 #define PCIIO_SLOT_NONE 255
 #define PCIIO_FUNC_NONE 255
@@ -46,6 +49,7 @@
 	struct pci_dev		*pdi_linux_pcidev;	/* Kernel pci_dev */
 
 	struct sn_irq_info	*pdi_sn_irq_info;
+	struct sn_pcibus_provider *pdi_provider;	/* sn pci ops */
 };
 
 extern void sn_irq_fixup(struct pci_dev *pci_dev,
diff -Nru a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
--- a/arch/ia64/sn/kernel/io_init.c	2005-02-07 11:05:01 -06:00
+++ b/arch/ia64/sn/kernel/io_init.c	2005-02-07 11:05:01 -06:00
@@ -34,6 +34,37 @@
 
 int sn_ioif_inited = 0;		/* SN I/O infrastructure initialized? */
 
+struct sn_pcibus_provider *sn_pci_provider[PCIIO_ASIC_MAX_TYPES];	/* indexed by asic type */
+
+/*
+ * Hooks and struct for unsupported pci providers
+ */
+
+static dma_addr_t
+sn_default_pci_map(struct pci_dev *pdev, unsigned long paddr, size_t size)
+{
+	return 0;
+}
+
+static void
+sn_default_pci_unmap(struct pci_dev *pdev, dma_addr_t addr, int direction)
+{
+	return;
+}
+
+static void *
+sn_default_pci_bus_fixup(struct pcibus_bussoft *soft)
+{
+	return NULL;
+}
+
+static struct sn_pcibus_provider sn_pci_default_provider = {
+	.dma_map = sn_default_pci_map,
+	.dma_map_consistent = sn_default_pci_map,
+	.dma_unmap = sn_default_pci_unmap,
+	.bus_fixup = sn_default_pci_bus_fixup,
+};
+
 /*
  * Retrieve the DMA Flush List given nasid.  This list is needed 
  * to implement the WAR - Flush DMA data on PIO Reads.
@@ -201,6 +232,7 @@
 	struct sn_irq_info *sn_irq_info;
 	struct pci_dev *host_pci_dev;
 	int status = 0;
+	struct pcibus_bussoft *bs;
 
 	dev->sysdata = kmalloc(sizeof(struct pcidev_info), GFP_KERNEL);
 	if (SN_PCIDEV_INFO(dev) <= 0)
@@ -241,6 +273,7 @@
 	}
 
 	/* set up host bus linkages */
+	bs = SN_PCIBUS_BUSSOFT(dev->bus);
 	host_pci_dev  	    pci_find_slot(SN_PCIDEV_INFO(dev)->pdi_slot_host_handle >> 32,
 			  SN_PCIDEV_INFO(dev)->
@@ -248,10 +281,16 @@
 	SN_PCIDEV_INFO(dev)->pdi_host_pcidev_info  	    SN_PCIDEV_INFO(host_pci_dev);
 	SN_PCIDEV_INFO(dev)->pdi_linux_pcidev = dev;
-	SN_PCIDEV_INFO(dev)->pdi_pcibus_info = SN_PCIBUS_BUSSOFT(dev->bus);
+	SN_PCIDEV_INFO(dev)->pdi_pcibus_info = bs;
+
+	if (bs && bs->bs_asic_type < PCIIO_ASIC_MAX_TYPES) {
+		SN_PCIDEV_BUSPROVIDER(dev) = sn_pci_provider[bs->bs_asic_type];
+	} else {
+		SN_PCIDEV_BUSPROVIDER(dev) = &sn_pci_default_provider;
+	}
 
 	/* Only set up IRQ stuff if this device has a host bus context */
-	if (SN_PCIDEV_BUSSOFT(dev) && sn_irq_info->irq_irq) {
+	if (bs && sn_irq_info->irq_irq) {
 		SN_PCIDEV_INFO(dev)->pdi_sn_irq_info = sn_irq_info;
 		dev->irq = SN_PCIDEV_INFO(dev)->pdi_sn_irq_info->irq_irq;
 		sn_irq_fixup(dev, sn_irq_info);
@@ -271,6 +310,7 @@
 	struct pcibus_bussoft *prom_bussoft_ptr;
 	struct hubdev_info *hubdev_info;
 	void *provider_soft;
+	struct sn_pcibus_provider *provider;
 
 	status  	    sal_get_pcibus_info((u64) segment, (u64) busnum,
@@ -291,16 +331,22 @@
 	/*
 	 * Per-provider fixup.  Copies the contents from prom to local
 	 * area and links SN_PCIBUS_BUSSOFT().
-	 *
-	 * Note:  Provider is responsible for ensuring that prom_bussoft_ptr
-	 * represents an asic-type that it can handle.
 	 */
 
-	if (prom_bussoft_ptr->bs_asic_type = PCIIO_ASIC_TYPE_PPB) {
-		return;		/* no further fixup necessary */
+	if (prom_bussoft_ptr->bs_asic_type >= PCIIO_ASIC_MAX_TYPES) {
+		return;		/* unsupported asic type */
+	}
+
+	provider = sn_pci_provider[prom_bussoft_ptr->bs_asic_type];
+	if (provider = NULL) {
+		return;		/* no provider registerd for this asic */
+	}
+
+	provider_soft = NULL;
+	if (provider->bus_fixup) {
+		provider_soft = (*provider->bus_fixup) (prom_bussoft_ptr);
 	}
 
-	provider_soft = pcibr_bus_fixup(prom_bussoft_ptr);
 	if (provider_soft = NULL) {
 		return;		/* fixup failed or not applicable */
 	}
@@ -337,6 +383,16 @@
 
 	if (!ia64_platform_is("sn2") || IS_RUNNING_ON_SIMULATOR())
 		return 0;
+
+	/*
+	 * prime sn_pci_provider[].  Individial provider init routines will
+	 * override their respective default entries.
+	 */
+
+	for (i = 0; i < PCIIO_ASIC_MAX_TYPES; i++)
+		sn_pci_provider[i] = &sn_pci_default_provider;
+
+	pcibr_init_provider();
 
 	/*
 	 * This is needed to avoid bounce limit checks in the blk layer
diff -Nru a/arch/ia64/sn/pci/pci_dma.c b/arch/ia64/sn/pci/pci_dma.c
--- a/arch/ia64/sn/pci/pci_dma.c	2005-02-07 11:05:01 -06:00
+++ b/arch/ia64/sn/pci/pci_dma.c	2005-02-07 11:05:01 -06:00
@@ -14,7 +14,6 @@
 #include <asm/sn/sn_sal.h>
 #include "pci/pcibus_provider_defs.h"
 #include "pci/pcidev.h"
-#include "pci/pcibr_provider.h"
 
 #define SG_ENT_VIRT_ADDRESS(sg)	(page_address((sg)->page) + (sg)->offset)
 #define SG_ENT_PHYS_ADDRESS(SG)	virt_to_phys(SG_ENT_VIRT_ADDRESS(SG))
@@ -79,7 +78,8 @@
 {
 	void *cpuaddr;
 	unsigned long phys_addr;
-	struct pcidev_info *pcidev_info = SN_PCIDEV_INFO(to_pci_dev(dev));
+	struct pci_dev *pdev = to_pci_dev(dev);
+	struct sn_pcibus_provider *provider = SN_PCIDEV_BUSPROVIDER(pdev);
 
 	BUG_ON(dev->bus != &pci_bus_type);
 
@@ -102,8 +102,7 @@
 	 * resources.
 	 */
 
-	*dma_handle = pcibr_dma_map(pcidev_info, phys_addr, size,
-				    SN_PCIDMA_CONSISTENT);
+	*dma_handle = provider->dma_map_consistent(pdev, phys_addr, size);
 	if (!*dma_handle) {
 		printk(KERN_ERR "%s: out of ATEs\n", __FUNCTION__);
 		free_pages((unsigned long)cpuaddr, get_order(size));
@@ -127,11 +126,12 @@
 void sn_dma_free_coherent(struct device *dev, size_t size, void *cpu_addr,
 			  dma_addr_t dma_handle)
 {
-	struct pcidev_info *pcidev_info = SN_PCIDEV_INFO(to_pci_dev(dev));
+	struct pci_dev *pdev = to_pci_dev(dev);
+	struct sn_pcibus_provider *provider = SN_PCIDEV_BUSPROVIDER(pdev);
 
 	BUG_ON(dev->bus != &pci_bus_type);
 
-	pcibr_dma_unmap(pcidev_info, dma_handle, 0);
+	provider->dma_unmap(pdev, dma_handle, 0);
 	free_pages((unsigned long)cpu_addr, get_order(size));
 }
 EXPORT_SYMBOL(sn_dma_free_coherent);
@@ -159,12 +159,13 @@
 {
 	dma_addr_t dma_addr;
 	unsigned long phys_addr;
-	struct pcidev_info *pcidev_info = SN_PCIDEV_INFO(to_pci_dev(dev));
+	struct pci_dev *pdev = to_pci_dev(dev);
+	struct sn_pcibus_provider *provider = SN_PCIDEV_BUSPROVIDER(pdev);
 
 	BUG_ON(dev->bus != &pci_bus_type);
 
 	phys_addr = __pa(cpu_addr);
-	dma_addr = pcibr_dma_map(pcidev_info, phys_addr, size, 0);
+	dma_addr = provider->dma_map(pdev, phys_addr, size);
 	if (!dma_addr) {
 		printk(KERN_ERR "%s: out of ATEs\n", __FUNCTION__);
 		return 0;
@@ -187,10 +188,12 @@
 void sn_dma_unmap_single(struct device *dev, dma_addr_t dma_addr, size_t size,
 			 int direction)
 {
-	struct pcidev_info *pcidev_info = SN_PCIDEV_INFO(to_pci_dev(dev));
+	struct pci_dev *pdev = to_pci_dev(dev);
+	struct sn_pcibus_provider *provider = SN_PCIDEV_BUSPROVIDER(pdev);
 
 	BUG_ON(dev->bus != &pci_bus_type);
-	pcibr_dma_unmap(pcidev_info, dma_addr, direction);
+
+	provider->dma_unmap(pdev, dma_addr, direction);
 }
 EXPORT_SYMBOL(sn_dma_unmap_single);
 
@@ -207,12 +210,13 @@
 		     int nhwentries, int direction)
 {
 	int i;
-	struct pcidev_info *pcidev_info = SN_PCIDEV_INFO(to_pci_dev(dev));
+	struct pci_dev *pdev = to_pci_dev(dev);
+	struct sn_pcibus_provider *provider = SN_PCIDEV_BUSPROVIDER(pdev);
 
 	BUG_ON(dev->bus != &pci_bus_type);
 
 	for (i = 0; i < nhwentries; i++, sg++) {
-		pcibr_dma_unmap(pcidev_info, sg->dma_address, direction);
+		provider->dma_unmap(pdev, sg->dma_address, direction);
 		sg->dma_address = (dma_addr_t) NULL;
 		sg->dma_length = 0;
 	}
@@ -233,7 +237,8 @@
 {
 	unsigned long phys_addr;
 	struct scatterlist *saved_sg = sg;
-	struct pcidev_info *pcidev_info = SN_PCIDEV_INFO(to_pci_dev(dev));
+	struct pci_dev *pdev = to_pci_dev(dev);
+	struct sn_pcibus_provider *provider = SN_PCIDEV_BUSPROVIDER(pdev);
 	int i;
 
 	BUG_ON(dev->bus != &pci_bus_type);
@@ -243,8 +248,8 @@
 	 */
 	for (i = 0; i < nhwentries; i++, sg++) {
 		phys_addr = SG_ENT_PHYS_ADDRESS(sg);
-		sg->dma_address = pcibr_dma_map(pcidev_info, phys_addr,
-						sg->length, 0);
+		sg->dma_address = provider->dma_map(pdev,
+						    phys_addr, sg->length);
 
 		if (!sg->dma_address) {
 			printk(KERN_ERR "%s: out of ATEs\n", __FUNCTION__);
diff -Nru a/arch/ia64/sn/pci/pcibr/pcibr_dma.c b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
--- a/arch/ia64/sn/pci/pcibr/pcibr_dma.c	2005-02-07 11:05:01 -06:00
+++ b/arch/ia64/sn/pci/pcibr/pcibr_dma.c	2005-02-07 11:05:01 -06:00
@@ -40,7 +40,7 @@
  *      we do not have to allocate entries in the PMU.
  */
 
-static uint64_t
+static dma_addr_t
 pcibr_dmamap_ate32(struct pcidev_info *info,
 		   uint64_t paddr, size_t req_size, uint64_t flags)
 {
@@ -109,7 +109,7 @@
 	return pci_addr;
 }
 
-static uint64_t
+static dma_addr_t
 pcibr_dmatrans_direct64(struct pcidev_info * info, uint64_t paddr,
 			uint64_t dma_attributes)
 {
@@ -141,7 +141,7 @@
 
 }
 
-static uint64_t
+static dma_addr_t
 pcibr_dmatrans_direct32(struct pcidev_info * info,
 			uint64_t paddr, size_t req_size, uint64_t flags)
 {
@@ -180,11 +180,11 @@
  * DMA mappings for Direct 64 and 32 do not have any DMA maps.
  */
 void
-pcibr_dma_unmap(struct pcidev_info *pcidev_info, dma_addr_t dma_handle,
-		int direction)
+pcibr_dma_unmap(struct pci_dev *hwdev, dma_addr_t dma_handle, int direction)
 {
-	struct pcibus_info *pcibus_info = (struct pcibus_info *)pcidev_info->
-	    pdi_pcibus_info;
+	struct pcidev_info *pcidev_info = SN_PCIDEV_INFO(hwdev);
+	struct pcibus_info *pcibus_info +	    (struct pcibus_info *)pcidev_info->pdi_pcibus_info;
 
 	if (IS_PCI32_MAPPED(dma_handle)) {
 		int ate_index;
@@ -316,61 +316,60 @@
 }
 
 /*
- * Wrapper DMA interface.  Called from pci_dma.c routines.
+ * DMA interfaces.  Called from pci_dma.c routines.
  */
 
-uint64_t
-pcibr_dma_map(struct pcidev_info * pcidev_info, unsigned long phys_addr,
-	      size_t size, unsigned int flags)
+dma_addr_t
+pcibr_dma_map(struct pci_dev * hwdev, unsigned long phys_addr, size_t size)
 {
 	dma_addr_t dma_handle;
-	struct pci_dev *pcidev = pcidev_info->pdi_linux_pcidev;
+	struct pcidev_info *pcidev_info = SN_PCIDEV_INFO(hwdev);
 
-	if (flags & SN_PCIDMA_CONSISTENT) {
-		/* sn_pci_alloc_consistent interfaces */
-		if (pcidev->dev.coherent_dma_mask = ~0UL) {
-			dma_handle -			    pcibr_dmatrans_direct64(pcidev_info, phys_addr,
-						    PCI64_ATTR_BAR);
-		} else {
-			dma_handle -			    (dma_addr_t) pcibr_dmamap_ate32(pcidev_info,
-							    phys_addr, size,
-							    PCI32_ATE_BAR);
-		}
-	} else {
-		/* map_sg/map_single interfaces */
+	/* SN cannot support DMA addresses smaller than 32 bits. */
+	if (hwdev->dma_mask < 0x7fffffff) {
+		return 0;
+	}
 
-		/* SN cannot support DMA addresses smaller than 32 bits. */
-		if (pcidev->dma_mask < 0x7fffffff) {
-			return 0;
-		}
+	if (hwdev->dma_mask = ~0UL) {
+		/*
+		 * Handle the most common case: 64 bit cards.  This
+		 * call should always succeed.
+		 */
 
-		if (pcidev->dma_mask = ~0UL) {
+		dma_handle = pcibr_dmatrans_direct64(pcidev_info, phys_addr,
+						     PCI64_ATTR_PREF);
+	} else {
+		/* Handle 32-63 bit cards via direct mapping */
+		dma_handle = pcibr_dmatrans_direct32(pcidev_info, phys_addr,
+						     size, 0);
+		if (!dma_handle) {
 			/*
-			 * Handle the most common case: 64 bit cards.  This
-			 * call should always succeed.
+			 * It is a 32 bit card and we cannot do direct mapping,
+			 * so we use an ATE.
 			 */
 
-			dma_handle -			    pcibr_dmatrans_direct64(pcidev_info, phys_addr,
-						    PCI64_ATTR_PREF);
-		} else {
-			/* Handle 32-63 bit cards via direct mapping */
-			dma_handle -			    pcibr_dmatrans_direct32(pcidev_info, phys_addr,
-						    size, 0);
-			if (!dma_handle) {
-				/*
-				 * It is a 32 bit card and we cannot do direct mapping,
-				 * so we use an ATE.
-				 */
-
-				dma_handle -				    pcibr_dmamap_ate32(pcidev_info, phys_addr,
-						       size, PCI32_ATE_PREF);
-			}
+			dma_handle = pcibr_dmamap_ate32(pcidev_info, phys_addr,
+							size, PCI32_ATE_PREF);
 		}
+	}
+
+	return dma_handle;
+}
+
+dma_addr_t
+pcibr_dma_map_consistent(struct pci_dev * hwdev, unsigned long phys_addr,
+			 size_t size)
+{
+	dma_addr_t dma_handle;
+	struct pcidev_info *pcidev_info = SN_PCIDEV_INFO(hwdev);
+
+	if (hwdev->dev.coherent_dma_mask = ~0UL) {
+		dma_handle = pcibr_dmatrans_direct64(pcidev_info, phys_addr,
+					    PCI64_ATTR_BAR);
+	} else {
+		dma_handle = (dma_addr_t) pcibr_dmamap_ate32(pcidev_info,
+						    phys_addr, size,
+						    PCI32_ATE_BAR);
 	}
 
 	return dma_handle;
diff -Nru a/arch/ia64/sn/pci/pcibr/pcibr_provider.c b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
--- a/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2005-02-07 11:05:01 -06:00
+++ b/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2005-02-07 11:05:01 -06:00
@@ -168,3 +168,23 @@
 		pcibr_force_interrupt(sn_irq_info);
 	}
 }
+
+/*
+ * Provider entries for PIC/CP
+ */
+
+struct sn_pcibus_provider pcibr_provider = {
+	.dma_map = pcibr_dma_map,
+	.dma_map_consistent = pcibr_dma_map_consistent,
+	.dma_unmap = pcibr_dma_unmap,
+	.bus_fixup = pcibr_bus_fixup,
+};
+
+int
+pcibr_init_provider(void)
+{
+	sn_pci_provider[PCIIO_ASIC_TYPE_PIC] = &pcibr_provider;
+	sn_pci_provider[PCIIO_ASIC_TYPE_TIOCP] = &pcibr_provider;
+
+	return 0;
+}
