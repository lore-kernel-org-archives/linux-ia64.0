From: Jesse Barnes <jbarnes@sgi.com>
Date: Mon, 22 Apr 2002 22:31:56 +0000
Subject: [Linux-ia64] PCI DAC routines for SN
Message-Id: <marc-linux-ia64-105590701905492@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's an implementation of the PCI DAC API for SN, along with some
fixes to the existing implementation.  If this looks ok, I'd like it
to get integrated into the next release, otherwise I'll fix it up.
Please take a look.

Thanks,
Jesse


diff -Naur -X /home/jbarnes/dontdiff linux-2.4.18-ia64/arch/ia64/lib/swiotlb.c linux-2.4.18-ia64-pci-dac/arch/ia64/lib/swiotlb.c
--- linux-2.4.18-ia64/arch/ia64/lib/swiotlb.c	Thu Apr 18 12:37:00 2002
+++ linux-2.4.18-ia64-pci-dac/arch/ia64/lib/swiotlb.c	Thu Apr 18 12:38:09 2002
@@ -489,6 +489,47 @@
 	return SG_ENT_PHYS_ADDRESS(sg);
 }
 
+/*
+ * Return whether the given PCI device DMA address mask can be supported properly.  For
+ * example, if your device can only drive the low 24-bits during PCI bus mastering, then
+ * you would pass 0x00ffffff as the mask to this function.
+ */
+int
+swiotlb_pci_dma_supported (struct pci_dev *hwdev, u64 mask)
+{
+	return 1;
+}
+
+int
+swiotlb_pci_dac_dma_supported (struct pci_dev *hwdev, u64 mask)
+{
+	return 1;
+}
+
+dma64_addr_t
+swiotlb_pci_dac_page_to_dma (struct pci_dev *hwdev, struct page *pg, unsigned long off, int dir)
+{
+        if (dir = PCI_DMA_NONE)
+                BUG();
+
+	return ((dma64_addr_t) page_to_bus(pg) + (off));
+}
+
+struct page *
+swiotlb_pci_dac_dma_to_page (struct pci_dev *hwdev, dma64_addr_t addr)
+{
+	return (virt_to_page(bus_to_virt(addr)));
+}
+
+void
+swiotlb_pci_dac_dma_sync_single (struct pci_dev *hwdev, dma64_addr_t addr, size_t len, int dir)
+{
+        if (dir = PCI_DMA_NONE)
+                BUG();
+
+	return; /* nothing to do for this arch */
+}
+
 EXPORT_SYMBOL(swiotlb_init);
 EXPORT_SYMBOL(swiotlb_map_single);
 EXPORT_SYMBOL(swiotlb_unmap_single);
@@ -499,3 +540,8 @@
 EXPORT_SYMBOL(swiotlb_dma_address);
 EXPORT_SYMBOL(swiotlb_alloc_consistent);
 EXPORT_SYMBOL(swiotlb_free_consistent);
+EXPORT_SYMBOL(swiotlb_pci_dma_supported);
+EXPORT_SYMBOL(swiotlb_pci_dac_dma_supported);
+EXPORT_SYMBOL(swiotlb_pci_dac_page_to_dma);
+EXPORT_SYMBOL(swiotlb_pci_dac_dma_to_page);
+EXPORT_SYMBOL(swiotlb_pci_dac_dma_sync_single);
diff -Naur -X /home/jbarnes/dontdiff linux-2.4.18-ia64/arch/ia64/sn/io/Makefile linux-2.4.18-ia64-pci-dac/arch/ia64/sn/io/Makefile
--- linux-2.4.18-ia64/arch/ia64/sn/io/Makefile	Thu Apr 18 12:37:00 2002
+++ linux-2.4.18-ia64-pci-dac/arch/ia64/sn/io/Makefile	Thu Apr 18 12:38:09 2002
@@ -18,7 +18,7 @@
 O_TARGET := sgiio.o
 
 ifeq ($(CONFIG_MODULES),y)
-export-objs = pciio.o hcl.o
+export-objs = pciio.o hcl.o pci_dma.o
 endif
 
 obj-y  := stubs.o sgi_if.o pciio.o xtalk.o xbow.o xswitch.o klgraph_hack.o \
diff -Naur -X /home/jbarnes/dontdiff linux-2.4.18-ia64/arch/ia64/sn/io/pci_dma.c linux-2.4.18-ia64-pci-dac/arch/ia64/sn/io/pci_dma.c
--- linux-2.4.18-ia64/arch/ia64/sn/io/pci_dma.c	Thu Apr 18 12:37:00 2002
+++ linux-2.4.18-ia64-pci-dac/arch/ia64/sn/io/pci_dma.c	Thu Apr 18 12:43:19 2002
@@ -4,6 +4,9 @@
  * for more details.
  *
  * Copyright (C) 2000,2002 Silicon Graphics, Inc. All rights reserved.
+ *
+ * Routines for PCI DMA mapping.  See Documentation/DMA-mapping.txt for
+ * a description of how these routines should be used.
  */
 
 #include <linux/types.h>
@@ -12,6 +15,7 @@
 #include <linux/pci.h>
 #include <linux/slab.h>
 #include <linux/devfs_fs_kernel.h>
+#include <linux/module.h>
 
 #include <asm/delay.h>
 #include <asm/io.h>
@@ -27,15 +31,38 @@
 #include <asm/sn/pci/pci_bus_cvlink.h>
 #include <asm/sn/nag.h>
 
+/* DMA, PIO, and memory allocation flags */
+#ifdef CONFIG_IA64_SGI_SN1
+#define DMA_DATA_FLAGS		( PCIIO_BYTE_STREAM | PCIIO_DMA_DATA )
+#define DMA_CONTROL_FLAGS	( PCIIO_BYTE_STREAM | PCIBR_BARRIER | \
+				  PCIIO_DMA_CMD )
+#elif defined(CONFIG_IA64_SGI_SN2)
+#define DMA_DATA_FLAGS		( PCIIO_DMA_DATA )
+#define DMA_CONTROL_FLAGS	( PCIBR_BARRIER | PCIIO_DMA_CMD )
+#else
+#error need to define DMA mapping flags for this platform
+#endif
+
+/*
+ * For ATE allocations
+ */
 pciio_dmamap_t get_free_pciio_dmamap(devfs_handle_t);
 void free_pciio_dmamap(pcibr_dmamap_t);
-struct sn_dma_maps_s *find_sn_dma_map(dma_addr_t, unsigned char);
+static struct sn_dma_maps_s *find_sn_dma_map(dma_addr_t, unsigned char);
+
+/*
+ * Toplogy stuff
+ */
 extern devfs_handle_t busnum_to_pcibr_vhdl[];
 extern nasid_t busnum_to_nid[];
 extern void * busnum_to_atedmamaps[];
 
-/*
- * Get a free pciio_dmamap_t entry.
+/**
+ * get_free_pciio_dmamap - find and allocate an ATE
+ * @pci_bus: PCI bus to get an entry for
+ *
+ * Finds and allocates an ATE on the PCI bus specified
+ * by @pci_bus.
  */
 pciio_dmamap_t
 get_free_pciio_dmamap(devfs_handle_t pci_bus)
@@ -46,7 +73,7 @@
 	/*
 	 * Darn, we need to get the maps allocated for this bus.
 	 */
-	for (i=0; i<MAX_PCI_XWIDGET; i++) {
+	for (i = 0; i < MAX_PCI_XWIDGET; i++) {
 		if (busnum_to_pcibr_vhdl[i] = pci_bus) {
 			sn_dma_map = busnum_to_atedmamaps[i];
 		}
@@ -55,19 +82,21 @@
 	/*
 	 * Now get a free dmamap entry from this list.
 	 */
-	for (i=0; i<MAX_ATE_MAPS; i++, sn_dma_map++) {
+	for (i = 0; i < MAX_ATE_MAPS; i++, sn_dma_map++) {
 		if (!sn_dma_map->dma_addr) {
 			sn_dma_map->dma_addr = -1;
 			return( (pciio_dmamap_t) sn_dma_map );
 		}
 	}
 
-	return(NULL);
-
+	return NULL;
 }
 
-/*
- * Free pciio_dmamap_t entry.
+/**
+ * free_pciio_dmamap - free an ATE
+ * @dma_map: ATE to free
+ *
+ * Frees the ATE specified by @dma_map.
  */
 void
 free_pciio_dmamap(pcibr_dmamap_t dma_map)
@@ -76,177 +105,227 @@
 
 	sn_dma_map = (struct sn_dma_maps_s *) dma_map;
 	sn_dma_map->dma_addr = 0;
+}
+
+/**
+ * find_sn_dma_map - find an ATE associated with @dma_addr and @busnum
+ * @dma_addr: DMA address to look for
+ * @busnum: PCI bus to look on
+ *
+ * Finds the ATE associated with @dma_addr and @busnum.
+ */
+static struct sn_dma_maps_s *
+find_sn_dma_map(dma_addr_t dma_addr, unsigned char busnum)
+{
+
+	struct sn_dma_maps_s *sn_dma_map = NULL;
+	int i;
+
+	sn_dma_map = busnum_to_atedmamaps[busnum];
 
+	for (i = 0; i < MAX_ATE_MAPS; i++, sn_dma_map++) {
+		if (sn_dma_map->dma_addr = dma_addr) {
+			return sn_dma_map;
+		}
+	}
+
+	printk(KERN_WARNING "find_sn_dma_map: Unable find the corresponding "
+	       "dma map\n");
+
+	return NULL;
 }
 
-/*
- * sn_dma_sync: This routine flushes all DMA buffers for the device into the II.
- *	This does not mean that the data is in the "Coherence Domain".  But it 
- *	is very close.
+/**
+ * sn_dma_sync - try to flush DMA buffers into the coherence domain
+ * @hwdev: device to flush
+ *
+ * This routine flushes all DMA buffers for the device into the II of
+ * the destination hub.
+ *
+ * NOTE!: this does not mean that the data is in the "coherence domain",
+ * but it is very close.  In other words, this routine *does not* work
+ * as advertised due to hardware bugs, but should be good enough for
+ * most situations.
  */
 void
-sn_dma_sync( struct pci_dev *hwdev )
+sn_dma_sync(struct pci_dev *hwdev)
 {
 
 	struct sn_device_sysdata *device_sysdata;
 	volatile unsigned long dummy;
 
 	/*
-	 * It is expected that on IA64 platform, a DMA sync ensures that all 
-	 * the DMA (dma_handle) are complete and coherent.
-	 *	1. Flush Write Buffers from Bridge.
-	 *	2. Flush Xbow Port.
+	 * It is expected that on an IA64 platform, a DMA sync ensures that 
+	 * all the DMA from a particular device is complete and coherent.  We
+	 * try to do this by
+	 *	1. flushing the write wuffers from Bridge
+	 *	2. flushing the Xbow port.
+	 * Unfortunately, this only gets the DMA transactions 'very close' to
+	 * the coherence domain, but not quite in it.
 	 */
 	device_sysdata = (struct sn_device_sysdata *)hwdev->sysdata;
 	dummy = (volatile unsigned long ) *device_sysdata->dma_buf_sync;
 
 	/*
-	 * For the Xbow Port flush, we maybe denied the request because 
-	 * someone else may be flushing the Port .. try again.
+	 * For the Xbow port flush, we maybe denied the request because 
+	 * someone else may be flushing the port .. try again.
 	 */
 	while((volatile unsigned long ) *device_sysdata->xbow_buf_sync) {
 		udelay(2);
 	}
 }
 
-
-struct sn_dma_maps_s *
-find_sn_dma_map(dma_addr_t dma_addr, unsigned char busnum)
-{
-
-	struct sn_dma_maps_s *sn_dma_map = NULL;
-	int i;
-
-	sn_dma_map = busnum_to_atedmamaps[busnum];
-
-	for (i=0; i<MAX_ATE_MAPS; i++, sn_dma_map++) {
-		if (sn_dma_map->dma_addr = dma_addr) {
-			return( sn_dma_map );
-		}
-	}
-
-printk("find_pciio_dmamap: Unable find the corresponding dma map\n");
-
-	return(NULL);
-
-}
-
-/*
- * sn1 platform specific pci_alloc_consistent()
+/**
+ * sn_pci_alloc_consistent - allocate memory for coherent DMA
+ * @hwdev: device to allocate for
+ * @size: size of the region
+ * @dma_handle: DMA (bus) address
+ *
+ * pci_alloc_consistent() returns a pointer to a memory region suitable for
+ * coherent DMA traffic to/from a PCI device.  On SN platforms, this means
+ * that @dma_handle will have the PCIBR_BARRIER and PCIIO_DMA_CMD flags
+ * set.
  *
- * this interface is meant for "command" streams, i.e. called only
- * once for initializing a device, so we don't want prefetching or
- * write gathering turned on, hence the PCIIO_DMA_CMD flag
+ * This interface is usually used for "command" streams (e.g. the command
+ * queue for a SCSI controller).  See Documentation/DMA-mapping.txt for
+ * more information.  Note that this routine should always put a 32 bit
+ * DMA address into @dma_handle.  This is because most other platforms
+ * that are capable of 64 bit PCI DMA transactions can't do 64 bit _coherent_
+ * DMAs, and unfortunately this interface has to cater to the LCD.  Oh well.
+ *
+ * Also known as platform_pci_alloc_consistent() by the IA64 machvec code.
  */
 void *
-sn_pci_alloc_consistent (struct pci_dev *hwdev, size_t size, dma_addr_t *dma_handle)
+sn_pci_alloc_consistent(struct pci_dev *hwdev, size_t size, dma_addr_t *dma_handle)
 {
-        void *ret;
-        int gfp = GFP_ATOMIC;
-	devfs_handle_t    vhdl;
+        void *cpuaddr;
+	devfs_handle_t vhdl;
 	struct sn_device_sysdata *device_sysdata;
-	paddr_t temp_ptr;
+	unsigned long phys_addr;
+	pciio_dmamap_t dma_map = 0;
+	struct sn_dma_maps_s *sn_dma_map;
 
-	*dma_handle = (dma_addr_t) NULL;
+	*dma_handle = 0;
+
+	/* We can't easily support > 32 bit devices */
+	if (IS_PCI32L(hwdev)) return NULL;
 
 	/*
-	 * get vertex for the device
+	 * Get hwgraph vertex for the device
 	 */
 	device_sysdata = (struct sn_device_sysdata *) hwdev->sysdata;
 	vhdl = device_sysdata->vhdl;
 
-        if ( (ret = (void *)__get_free_pages(gfp, get_order(size))) ) {
-		memset(ret, 0, size);
-	} else {
-		return(NULL);
-	}
+	/*
+	 * Allocate the memory.  FIXME: if we're allocating for
+	 * two devices on the same bus, we should at least try to
+	 * allocate memory in the same 2 GB window to avoid using
+	 * ATEs for the translation.  See the comment above about the
+	 * 32 bit requirement for this function.
+	 */
+	if(!(cpuaddr = (void *)__get_free_pages(GFP_ATOMIC, get_order(size))))
+		return NULL;
 
-	temp_ptr = (paddr_t) __pa(ret);
-	if (IS_PCIA64(hwdev)) {
+	memset(cpuaddr, 0, size); /* have to zero it out */
+
+	/* physical addr. of the memory we just got */
+	phys_addr = __pa(cpuaddr);
 
+	*dma_handle = pciio_dmatrans_addr(vhdl, NULL, phys_addr, size,
+					  DMA_CONTROL_FLAGS);
+	
+	if (!(*dma_handle)) {
 		/*
-		 * This device supports 64bits DMA addresses.
+		 * It is a 32 bit card and we cannot do direct mapping,
+		 * so we use an ATE.
 		 */
-#ifdef CONFIG_IA64_SGI_SN1
-		*dma_handle = pciio_dmatrans_addr(vhdl, NULL, temp_ptr, size,
-			PCIBR_BARRIER | PCIIO_BYTE_STREAM | PCIIO_DMA_CMD
-			| PCIIO_DMA_A64 );
-#else /* SN2 */
-		*dma_handle = pciio_dmatrans_addr(vhdl, NULL, temp_ptr, size,
-			PCIBR_BARRIER | PCIIO_DMA_CMD | PCIIO_DMA_A64 );
-#endif
-
-		return (ret);
-	}
-
-	/*
-	 * Devices that supports 32 Bits upto 63 Bits DMA Address gets
-	 * 32 Bits DMA addresses.
-	 *
-	 * First try to get 32 Bit Direct Map Support.
-	 */
-	if (IS_PCI32G(hwdev)) {
-#ifdef CONFIG_IA64_SGI_SN1
-		*dma_handle = pciio_dmatrans_addr(vhdl, NULL, temp_ptr, size,
-			PCIBR_BARRIER | PCIIO_BYTE_STREAM | PCIIO_DMA_CMD);
-#else /* SN2 */
-		*dma_handle = pciio_dmatrans_addr(vhdl, NULL, temp_ptr, size,
-			PCIBR_BARRIER | PCIIO_DMA_CMD);
-#endif
-
-		if (dma_handle) {
-			return (ret);
-		} else {
-			/*
-			 * We need to map this request by using ATEs.
-			 */
-			printk("sn_pci_alloc_consistent: 32Bits DMA Page Map support not available yet!");
+		dma_map = pciio_dmamap_alloc(vhdl, NULL, size,
+					     DMA_CONTROL_FLAGS);
+		if (!dma_map) {
+			printk(KERN_ERR "sn_pci_alloc_consistent: Unable to "
+			       "allocate anymore 32 bits page map entries.\n");
 			BUG();
 		}
-	}
-
-	if (IS_PCI32L(hwdev)) {
-		/*
-		 * SNIA64 cannot support DMA Addresses smaller than 32 bits.
-		 */
-		return (NULL);
-	}
-
-        return NULL;
-}
-
+		*dma_handle = (dma_addr_t) pciio_dmamap_addr(dma_map,phys_addr,
+							     size);
+		sn_dma_map = (struct sn_dma_maps_s *)dma_map;
+		sn_dma_map->dma_addr = *dma_handle;
+		printk(KERN_INFO "%s: PMU mapping: %p\n", __FUNCTION__,
+		       (void *)*dma_handle);
+	}
+	else
+		printk(KERN_INFO "%s: direct mapping: %p\n", __FUNCTION__,
+		       (void *)*dma_handle);
+
+        return cpuaddr;
+}
+
+/**
+ * sn_pci_free_consistent - free memory associated with coherent DMAable region
+ * @hwdev: device to free for
+ * @size: size to free
+ * @vaddr: kernel virtual address to free
+ * @dma_handle: DMA address associated with this region
+ *
+ * Frees the memory allocated by pci_alloc_consistent().  Also known
+ * as platform_pci_free_consistent() by the IA64 machvec code.
+ */
 void
 sn_pci_free_consistent(struct pci_dev *hwdev, size_t size, void *vaddr, dma_addr_t dma_handle)
 {
+	struct sn_dma_maps_s *sn_dma_map = NULL;
+
+	/*
+	 * Get the sn_dma_map entry.
+	 */
+	if (IS_PCI32_MAPPED(dma_handle))
+		sn_dma_map = find_sn_dma_map(dma_handle, hwdev->bus->number);
+
+	/*
+	 * and free it if necessary...
+	 */
+	if (sn_dma_map) {
+		pciio_dmamap_done((pciio_dmamap_t)sn_dma_map);
+		pciio_dmamap_free((pciio_dmamap_t)sn_dma_map);
+		sn_dma_map->dma_addr = (dma_addr_t)NULL;
+	}
 	free_pages((unsigned long) vaddr, get_order(size));
 }
 
-/*
- * On sn1 we use the page entry of the scatterlist to store
- * the physical address corresponding to the given virtual address
+/**
+ * sn_pci_map_sg - map a scatter-gather list for DMA
+ * @hwdev: device to map for
+ * @sg: scatterlist to map
+ * @nents: number of entries
+ * @direction: direction of the DMA transaction
+ *
+ * Maps each entry of @sg for DMA.  Also known as platform_pci_map_sg by the
+ * IA64 machvec code.
  */
 int
-sn_pci_map_sg (struct pci_dev *hwdev,
-                        struct scatterlist *sg, int nents, int direction)
+sn_pci_map_sg(struct pci_dev *hwdev, struct scatterlist *sg, int nents, int direction)
 {
 
 	int i;
-	devfs_handle_t	vhdl;
+	devfs_handle_t vhdl;
 	dma_addr_t dma_addr;
-	paddr_t temp_ptr;
+	unsigned long phys_addr;
 	struct sn_device_sysdata *device_sysdata;
 	pciio_dmamap_t dma_map;
 
-
-
-	if (direction = PCI_DMA_NONE)
-		BUG();
+	/* can't go anywhere w/o a direction in life */
+	if (direction = PCI_DMA_NONE) BUG();
 
 	/*
-	 * Handle 64 bit cards.
+	 * Get the hwgraph vertex for the device
 	 */
 	device_sysdata = (struct sn_device_sysdata *) hwdev->sysdata;
 	vhdl = device_sysdata->vhdl;
+
+	/*
+	 * Setup a DMA address for each entry in the
+	 * scatterlist.
+	 */
 	for (i = 0; i < nents; i++, sg++) {
 		/* this catches incorrectly written drivers that
                    attempt to map scatterlists that they have
@@ -262,50 +341,37 @@
 			    "%p - this is currently being worked around.\n",
 			    hwdev->slot_name, (void *)sg->address);
 #endif
-			temp_ptr = (u64)sg->address & TO_PHYS_MASK;
+			phys_addr = (u64)sg->address & TO_PHYS_MASK;
 			break;
-		case 0xe: /* a good address, we now map it. */
-			temp_ptr = (paddr_t) __pa(sg->address);
+		default: /* not previously mapped, get the phys. addr */
+			phys_addr = __pa(sg->address);
 			break;
-		default:
-			printk(KERN_ERR
-			       "Very bad address (%p) passed to sn_pci_map_sg\n",
-			       (void *)sg->address);
-			BUG();
 		}
-		sg->page = (char *)NULL;
+		sg->page = NULL;
 		dma_addr = 0;
 
 		/*
-		 * Handle the most common case 64Bit cards.
+		 * Handle the most common case: 64 bit cards.  This
+		 * call should always succeed.
 		 */
 		if (IS_PCIA64(hwdev)) {
-#ifdef CONFIG_IA64_SGI_SN1
-			dma_addr = (dma_addr_t) pciio_dmatrans_addr(vhdl, NULL,
-				temp_ptr, sg->length,
-				PCIIO_BYTE_STREAM | PCIIO_DMA_DATA |
-				PCIIO_DMA_A64 );
-#else
-			dma_addr = (dma_addr_t) pciio_dmatrans_addr(vhdl, NULL,
-				temp_ptr, sg->length,
-				PCIIO_DMA_DATA | PCIIO_DMA_A64 );
-#endif
+			dma_addr = pciio_dmatrans_addr(vhdl, NULL, phys_addr,
+						       sg->length,
+						       DMA_DATA_FLAGS | PCIIO_DMA_A64 );
 			sg->address = (char *)dma_addr;
 			continue;
 		}
 
 		/*
-		 * Handle 32Bits and greater cards.
+		 * Handle 32-63 bit cards via direct mapping
 		 */
 		if (IS_PCI32G(hwdev)) {
-#ifdef CONFIG_IA64_SGI_SN1
-			dma_addr = (dma_addr_t) pciio_dmatrans_addr(vhdl, NULL,
-				temp_ptr, sg->length,
-				PCIIO_BYTE_STREAM | PCIIO_DMA_DATA);
-#else
-			dma_addr = (dma_addr_t) pciio_dmatrans_addr(vhdl, NULL,
-				temp_ptr, sg->length, PCIIO_DMA_DATA);
-#endif
+			dma_addr = pciio_dmatrans_addr(vhdl, NULL, phys_addr,
+						       sg->length,
+						       DMA_DATA_FLAGS);
+			/*
+			 * See if we got a direct map entry
+			 */
 			if (dma_addr) {
 				sg->address = (char *)dma_addr;
 				continue;
@@ -314,22 +380,18 @@
 		}
 
 		/*
-		 * It is a 32bit card and we cannot do Direct mapping.
-		 * Let's 32Bit Page map the request.
+		 * It is a 32 bit card and we cannot do direct mapping,
+		 * so we use an ATE.
 		 */
-		dma_map = NULL;
-#ifdef CONFIG_IA64_SGI_SN1
-		dma_map = pciio_dmamap_alloc(vhdl, NULL, sg->length, 
-				PCIIO_BYTE_STREAM | PCIIO_DMA_DATA);
-#else
-		dma_map = pciio_dmamap_alloc(vhdl, NULL, sg->length, PCIIO_DMA_DATA);
-#endif
+		dma_map = 0;
+		dma_map = pciio_dmamap_alloc(vhdl, NULL, sg->length,
+					     DMA_DATA_FLAGS);
 		if (!dma_map) {
-			printk("pci_map_sg: Unable to allocate anymore 32Bits Page Map entries.\n");
+			printk(KERN_ERR "sn_pci_map_sg: Unable to allocate "
+			       "anymore 32 bit page map entries.\n");
 			BUG();
 		}
-		dma_addr = (dma_addr_t)pciio_dmamap_addr(dma_map, temp_ptr, sg->length);
-		/* printk("pci_map_sg: dma_map 0x%p Phys Addr 0x%p dma_addr 0x%p\n", dma_map, temp_ptr, dma_addr); */
+		dma_addr = pciio_dmamap_addr(dma_map, phys_addr, sg->length);
 		sg->address = (char *)dma_addr;
 		sg->page = (char *)dma_map;
 		
@@ -339,30 +401,33 @@
 
 }
 
-/*
- * Unmap a set of streaming mode DMA translations.
- * Again, cpu read rules concerning calls here are the same as for
- * pci_unmap_single() above.
+/**
+ * sn_pci_unmap_sg - unmap a scatter-gather list
+ * @hwdev: device to unmap
+ * @sg: scatterlist to unmap
+ * @nents: number of scatterlist entries
+ * @direction: DMA direction
+ *
+ * Unmap a set of streaming mode DMA translations.  Again, cpu read rules
+ * concerning calls here are the same as for pci_unmap_single() below.  Also
+ * known as sn_pci_unmap_sg() by the IA64 machvec code.
  */
 void
-sn_pci_unmap_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nelems, int direction)
+sn_pci_unmap_sg(struct pci_dev *hwdev, struct scatterlist *sg, int nents, int direction)
 {
 	int i;
 	struct sn_dma_maps_s *sn_dma_map;
 
+	/* can't go anywhere w/o a direction in life */
+	if (direction = PCI_DMA_NONE) BUG();
 
-	if (direction = PCI_DMA_NONE)
-		BUG();
-
-	for (i = 0; i < nelems; i++, sg++)
+	for (i = 0; i < nents; i++, sg++)
 		if (sg->page) {
 			/*
 			 * We maintain the DMA Map pointer in sg->page if 
 			 * it is ever allocated.
 			 */
-			/* phys_to_virt((dma_addr_t)sg->address | ~0x80000000); */
-			/* sg->address = sg->page; */
-			sg->address = (char *)-1;
+			sg->address = 0;
 			sn_dma_map = (struct sn_dma_maps_s *)sg->page;
 			pciio_dmamap_done((pciio_dmamap_t)sn_dma_map);
 			pciio_dmamap_free((pciio_dmamap_t)sn_dma_map);
@@ -372,7 +437,17 @@
 
 }
 
-/*
+/**
+ * sn_pci_map_single - map a single region for DMA
+ * @hwdev: device to map for
+ * @ptr: kernel virtual address of the region to map
+ * @size: size of the region
+ * @direction: DMA direction
+ *
+ * Map the region pointed to by @ptr for DMA and return the
+ * DMA address.   Also known as platform_pci_map_single() by
+ * the IA64 machvec code.
+ *
  * We map this to the one step pciio_dmamap_trans interface rather than
  * the two step pciio_dmamap_alloc/pciio_dmamap_addr because we have
  * no way of saving the dmamap handle from the alloc to later free
@@ -382,20 +457,20 @@
  *       get rid of dev_desc and vhdl (seems redundant given a pci_dev);
  *       figure out how to save dmamap handle so can use two step.
  */
-dma_addr_t sn_pci_map_single (struct pci_dev *hwdev,
-				void *ptr, size_t size, int direction)
+dma_addr_t
+sn_pci_map_single(struct pci_dev *hwdev, void *ptr, size_t size, int direction)
 {
-	devfs_handle_t	vhdl;
+	devfs_handle_t vhdl;
 	dma_addr_t dma_addr;
-	paddr_t temp_ptr;
+	unsigned long phys_addr;
 	struct sn_device_sysdata *device_sysdata;
 	pciio_dmamap_t dma_map = NULL;
 	struct sn_dma_maps_s *sn_dma_map;
 
+	if (direction = PCI_DMA_NONE) BUG();
 
-	if (direction = PCI_DMA_NONE)
-		BUG();
-
+	/* SN cannot support DMA addresses smaller than 32 bits. */
+	if (IS_PCI32L(hwdev)) return 0;
 
 	/*
 	 * find vertex for the device
@@ -407,83 +482,66 @@
 	 * Call our dmamap interface
 	 */
 	dma_addr = 0;
-	temp_ptr = (paddr_t) __pa(ptr);
+	phys_addr = __pa(ptr);
 
 	if (IS_PCIA64(hwdev)) {
 		/*
-		 * This device supports 64bits DMA addresses.
+		 * This device supports 64 bit DMA addresses.
 		 */
-#ifdef CONFIG_IA64_SGI_SN1
-		dma_addr = (dma_addr_t) pciio_dmatrans_addr(vhdl, NULL,
-			temp_ptr, size,
-			PCIIO_BYTE_STREAM | PCIIO_DMA_DATA | PCIIO_DMA_A64 );
-#else
-		dma_addr = (dma_addr_t) pciio_dmatrans_addr(vhdl, NULL,
-			temp_ptr, size, PCIIO_DMA_DATA | PCIIO_DMA_A64 );
-#endif
-		return (dma_addr);
+		dma_addr = pciio_dmatrans_addr(vhdl, NULL, phys_addr, size,
+					       DMA_DATA_FLAGS | PCIIO_DMA_A64);
+		return dma_addr;
 	}
 
 	/*
-	 * Devices that supports 32 Bits upto 63 Bits DMA Address gets
-	 * 32 Bits DMA addresses.
+	 * Devices that supports 32 bit to 63 bit DMA addresses get
+	 * 32 bit DMA addresses.
 	 *
-	 * First try to get 32 Bit Direct Map Support.
+	 * First try to get a 32 bit direct map register.
 	 */
 	if (IS_PCI32G(hwdev)) {
-#ifdef CONFIG_IA64_SGI_SN1
-		dma_addr = (dma_addr_t) pciio_dmatrans_addr(vhdl, NULL,
-			temp_ptr, size,
-			PCIIO_BYTE_STREAM | PCIIO_DMA_DATA);
-#else
-		dma_addr = (dma_addr_t) pciio_dmatrans_addr(vhdl, NULL,
-			temp_ptr, size, PCIIO_DMA_DATA);
-#endif
-		if (dma_addr) {
-			return (dma_addr);
-		}
+		dma_addr = pciio_dmatrans_addr(vhdl, NULL, phys_addr, size,
+					       DMA_DATA_FLAGS);
+		if (dma_addr)
+			return dma_addr;
 	}
 
-	if (IS_PCI32L(hwdev)) {
-		/*
-		 * SNIA64 cannot support DMA Addresses smaller than 32 bits.
-		 */
-		return ((dma_addr_t) NULL);
-        }
-
 	/*
-	 * It is a 32bit card and we cannot do Direct mapping.
-	 * Let's 32Bit Page map the request.
+	 * It's a 32 bit card and we cannot do direct mapping so
+	 * let's use the PMU instead.
 	 */
 	dma_map = NULL;
-#ifdef CONFIG_IA64_SGI_SN1
-	dma_map = pciio_dmamap_alloc(vhdl, NULL, size, PCIIO_BYTE_STREAM | 
-				     PCIIO_DMA_DATA);
-#else
-	dma_map = pciio_dmamap_alloc(vhdl, NULL, size, PCIIO_DMA_DATA);
-#endif
+	dma_map = pciio_dmamap_alloc(vhdl, NULL, size, DMA_DATA_FLAGS);
+
 	if (!dma_map) {
-		printk("pci_map_single: Unable to allocate anymore 32Bits Page Map entries.\n");
+		printk(KERN_ERR "pci_map_single: Unable to allocate anymore "
+		       "32 bits page map entries.\n");
 		BUG();
 	}
 
-	dma_addr = (dma_addr_t) pciio_dmamap_addr(dma_map, temp_ptr, size);
-	/* printk("pci_map_single: dma_map 0x%p Phys Addr 0x%p dma_addr 0x%p\n", dma_map,
-		temp_ptr, dma_addr); */
+	dma_addr = (dma_addr_t) pciio_dmamap_addr(dma_map, phys_addr, size);
 	sn_dma_map = (struct sn_dma_maps_s *)dma_map;
 	sn_dma_map->dma_addr = dma_addr;
 
 	return ((dma_addr_t)dma_addr);
 }
 
+/**
+ * sn_pci_unmap_single - unmap a region used for DMA
+ * @hwdev: device to unmap
+ * @dma_addr: DMA address to unmap
+ * @size: size of region
+ * @direction: DMA direction
+ *
+ * Unmaps the region pointed to by @dma_addr.  Also known as
+ * platform_pci_unmap_single() by the IA64 machvec code.
+ */
 void
-sn_pci_unmap_single (struct pci_dev *hwdev, dma_addr_t dma_addr, size_t size, int direction)
+sn_pci_unmap_single(struct pci_dev *hwdev, dma_addr_t dma_addr, size_t size, int direction)
 {
-
 	struct sn_dma_maps_s *sn_dma_map = NULL;
 
-        if (direction = PCI_DMA_NONE)
-		BUG();
+        if (direction = PCI_DMA_NONE) BUG();
 
 	/*
 	 * Get the sn_dma_map entry.
@@ -491,37 +549,174 @@
 	if (IS_PCI32_MAPPED(dma_addr))
 		sn_dma_map = find_sn_dma_map(dma_addr, hwdev->bus->number);
 
+	/*
+	 * and free it if necessary...
+	 */
 	if (sn_dma_map) {
 		pciio_dmamap_done((pciio_dmamap_t)sn_dma_map);
 		pciio_dmamap_free((pciio_dmamap_t)sn_dma_map);
 		sn_dma_map->dma_addr = (dma_addr_t)NULL;
 	}
-
 }
 
+/**
+ * sn_pci_dma_sync_single - make sure all DMAs have completed
+ * @hwdev: device to sync
+ * @dma_handle: DMA address to sync
+ * @size: size of region
+ * @direction: DMA direction
+ *
+ * This routine is supposed to sync the DMA region specified
+ * by @dma_handle into the 'coherence domain'.  See sn_dma_sync()
+ * above for more information.   Also known as
+ * platform_pci_dma_sync_single() by the IA64 machvec code.
+ */
 void
-sn_pci_dma_sync_single (struct pci_dev *hwdev, dma_addr_t dma_handle, size_t size, int direction)
+sn_pci_dma_sync_single(struct pci_dev *hwdev, dma_addr_t dma_handle, size_t size, int direction)
 {
-	
-        if (direction = PCI_DMA_NONE)
+	if (direction = PCI_DMA_NONE)
                 BUG();
 
 	sn_dma_sync(hwdev);
-
 }
 
+/**
+ * sn_pci_dma_sync_sg - make sure all DMAs have completed
+ * @hwdev: device to sync
+ * @sg: scatterlist to sync
+ * @nents: number of entries in the scatterlist
+ * @direction: DMA direction
+ *
+ * This routine is supposed to sync the DMA regions specified
+ * by @sg into the 'coherence domain'.  See sn_dma_sync()
+ * above for more information.   Also known as
+ * platform_pci_dma_sync_sg() by the IA64 machvec code.
+ */
 void
-sn_pci_dma_sync_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nelems, int direction)
+sn_pci_dma_sync_sg(struct pci_dev *hwdev, struct scatterlist *sg, int nents, int direction)
 {
         if (direction = PCI_DMA_NONE)
                 BUG();
 
 	sn_dma_sync(hwdev);
-
 }
 
+/**
+ * sn_dma_address - get the DMA address for the first entry of a scatterlist
+ * @sg: sg to look at
+ *
+ * Gets the DMA address for the scatterlist @sg.  Also known as
+ * platform_dma_address() by the IA64 machvec code.
+ */
 unsigned long
-sn_dma_address (struct scatterlist *sg)
+sn_dma_address(struct scatterlist *sg)
 {
 	return ((unsigned long)sg->address);
 }
+
+/**
+ * sn_dma_supported - test a DMA mask
+ * @hwdev: device to test
+ * @mask: DMA mask to test
+ *
+ * Return whether the given PCI device DMA address mask can be supported
+ * properly.  For example, if your device can only drive the low 24-bits
+ * during PCI bus mastering, then you would pass 0x00ffffff as the mask to
+ * this function.  Of course, SN only supports devices that have 32 or more
+ * address bits.
+ */
+int
+sn_pci_dma_supported(struct pci_dev *hwdev, u64 mask)
+{
+	if (mask < 0xffffffff)
+		return 0;
+	return 1;
+}
+
+/**
+ * sn_dac_dma_supported - test a DAC address mask
+ * @hwdev: device to test
+ * @mask: mask to test
+ *
+ * See sn_pci_dma_supported() above for comments.  This interface is made
+ * for 64 bit devices.
+ */
+int
+sn_pci_dac_dma_supported(struct pci_dev *hwdev, u64 mask)
+{
+	if (mask < 0xffffffffffffffff)
+		return 0;
+	return 1;
+}
+
+/**
+ * sn_pci_dac_page_to_dma - convert a page address to a DAC address
+ * @hwdev: device
+ * @pg: page address
+ * @offset: offset in @pg
+ * @dir: DMA direction
+ *
+ * Creates a DAC DMA address for @pg.  Note that this is not a 'consistent'
+ * mapping, so DMA into @pg won't be coherent until pci_dac_dma_sync_single()
+ * is called (and due to hardware bugs, it won't even be coherent then).
+ */
+dma64_addr_t
+sn_pci_dac_page_to_dma(struct pci_dev *hwdev, struct page *pg, unsigned long off, int dir)
+{
+	struct sn_device_sysdata *device_sysdata;
+
+        if (dir = PCI_DMA_NONE)
+                BUG();
+
+	device_sysdata = (struct sn_device_sysdata *)hwdev->sysdata;
+	pciio_dmatrans_addr(device_sysdata->vhdl, NULL,
+			    __pa(page_address(pg) + off),
+			    PAGE_SIZE, DMA_DATA_FLAGS | PCIIO_DMA_A64);
+	return ((dma64_addr_t) page_to_bus(pg) + (off));
+}
+
+/**
+ * sn_pci_dac_dma_to_page - get the page associated with a DMA address
+ * @hwdev: device
+ * @addr: DMA address
+ *
+ * Returns a pointer to the page structure corresponding to the DMA
+ * address in @addr.
+ */
+struct page *
+sn_pci_dac_dma_to_page(struct pci_dev *hwdev, dma64_addr_t addr)
+{
+	return virt_to_page(__tpa(addr));
+}
+
+/**
+ * sn_pci_dac_dma_sync_single - DMA barrier operation
+ * @hwdev: device
+ * @addr: address to sync
+ * @len: length
+ * @dir: DMA direction
+ *
+ * See comments for sn_pci_sync_single() and sn_pci_sync_sg() above.
+ */
+void
+sn_pci_dac_dma_sync_single(struct pci_dev *hwdev, dma64_addr_t addr, size_t len, int dir)
+{
+        if (dir = PCI_DMA_NONE)
+                BUG();
+
+	sn_dma_sync(hwdev);
+}
+
+EXPORT_SYMBOL(sn_pci_unmap_single);
+EXPORT_SYMBOL(sn_pci_map_single);
+EXPORT_SYMBOL(sn_pci_dma_sync_single);
+EXPORT_SYMBOL(sn_pci_map_sg);
+EXPORT_SYMBOL(sn_pci_unmap_sg);
+EXPORT_SYMBOL(sn_pci_alloc_consistent);
+EXPORT_SYMBOL(sn_pci_free_consistent);
+EXPORT_SYMBOL(sn_dma_address);
+EXPORT_SYMBOL(sn_pci_dma_supported);
+EXPORT_SYMBOL(sn_pci_dac_dma_supported);
+EXPORT_SYMBOL(sn_pci_dac_page_to_dma);
+EXPORT_SYMBOL(sn_pci_dac_dma_to_page);
+EXPORT_SYMBOL(sn_pci_dac_dma_sync_single);
diff -Naur -X /home/jbarnes/dontdiff linux-2.4.18-ia64/arch/ia64/sn/kernel/sn_ksyms.c linux-2.4.18-ia64-pci-dac/arch/ia64/sn/kernel/sn_ksyms.c
--- linux-2.4.18-ia64/arch/ia64/sn/kernel/sn_ksyms.c	Thu Apr 18 12:37:00 2002
+++ linux-2.4.18-ia64-pci-dac/arch/ia64/sn/kernel/sn_ksyms.c	Thu Apr 18 12:38:09 2002
@@ -17,15 +17,6 @@
 #include <asm/machvec.h>
 #include <asm/sn/intr.h>
 
-/*
- * other stuff (more to be added later, cleanup then)
- */
-EXPORT_SYMBOL(sn_pci_map_sg);
-EXPORT_SYMBOL(sn_pci_unmap_sg);
-EXPORT_SYMBOL(sn_pci_alloc_consistent);
-EXPORT_SYMBOL(sn_pci_free_consistent);
-EXPORT_SYMBOL(sn_dma_address);
-
 #include <linux/mm.h>
 #include <linux/devfs_fs_kernel.h>
 extern devfs_handle_t          base_io_scsi_ctlr_vhdl[];
@@ -62,6 +53,4 @@
 EXPORT_SYMBOL(sn_send_IPI_phys);
 
 #include <linux/mmzone.h>
-EXPORT_SYMBOL(sn_pci_unmap_single);
-EXPORT_SYMBOL(sn_pci_map_single);
-EXPORT_SYMBOL(sn_pci_dma_sync_single);
+
diff -Naur -X /home/jbarnes/dontdiff linux-2.4.18-ia64/include/asm-ia64/machvec.h linux-2.4.18-ia64-pci-dac/include/asm-ia64/machvec.h
--- linux-2.4.18-ia64/include/asm-ia64/machvec.h	Thu Apr 18 12:37:01 2002
+++ linux-2.4.18-ia64-pci-dac/include/asm-ia64/machvec.h	Thu Apr 18 12:38:09 2002
@@ -18,6 +18,7 @@
 struct pt_regs;
 struct scatterlist;
 struct irq_desc;
+struct page;
 
 typedef void ia64_mv_setup_t (char **);
 typedef void ia64_mv_cpu_init_t(void);
@@ -45,6 +46,11 @@
 typedef void ia64_mv_pci_dma_sync_single (struct pci_dev *, dma_addr_t, size_t, int);
 typedef void ia64_mv_pci_dma_sync_sg (struct pci_dev *, struct scatterlist *, int, int);
 typedef unsigned long ia64_mv_pci_dma_address (struct scatterlist *);
+typedef int ia64_mv_pci_dma_supported (struct pci_dev *, u64);
+typedef int ia64_mv_pci_dac_dma_supported (struct pci_dev *, u64);
+typedef dma64_addr_t ia64_mv_pci_dac_page_to_dma (struct pci_dev *, struct page *, unsigned long, int);
+typedef struct page *ia64_mv_pci_dac_dma_to_page (struct pci_dev *, dma64_addr_t);
+typedef void ia64_mv_pci_dac_dma_sync_single (struct pci_dev *, dma64_addr_t, size_t, int);
 /*
  * WARNING: The legacy I/O space is _architected_.  Platforms are
  * expected to follow this architected model (see Section 10.7 in the
@@ -100,6 +106,11 @@
 #  define platform_pci_dma_sync_single	ia64_mv.sync_single
 #  define platform_pci_dma_sync_sg	ia64_mv.sync_sg
 #  define platform_pci_dma_address	ia64_mv.dma_address
+#  define platform_pci_dma_supported	ia64_mv.dma_supported
+#  define platform_pci_dac_dma_supported	ia64_mv.dac_dma_supported
+#  define platform_pci_dac_page_to_dma	ia64_mv.pci_dac_page_to_dma
+#  define platform_pci_dac_dma_to_page	ia64_mv.pci_dac_dma_to_page
+#  define platform_pci_dac_dma_sync_single	ia64_mv.dac_dma_sync_single
 #  define platform_irq_desc		ia64_mv.irq_desc
 #  define platform_irq_to_vector	ia64_mv.irq_to_vector
 #  define platform_local_vector_to_irq	ia64_mv.local_vector_to_irq
@@ -134,6 +145,11 @@
 	ia64_mv_pci_dma_sync_single *sync_single;
 	ia64_mv_pci_dma_sync_sg *sync_sg;
 	ia64_mv_pci_dma_address *dma_address;
+	ia64_mv_pci_dma_supported *dma_supported;
+	ia64_mv_pci_dac_dma_supported *dac_dma_supported;
+	ia64_mv_pci_dac_page_to_dma *pci_dac_page_to_dma;
+	ia64_mv_pci_dac_dma_to_page *pci_dac_dma_to_page;
+	ia64_mv_pci_dac_dma_sync_single *pci_dac_dma_sync_single;
 	ia64_mv_irq_desc *irq_desc;
 	ia64_mv_irq_to_vector *irq_to_vector;
 	ia64_mv_local_vector_to_irq *local_vector_to_irq;
@@ -169,6 +185,11 @@
 	platform_pci_dma_sync_single,		\
 	platform_pci_dma_sync_sg,		\
 	platform_pci_dma_address,		\
+	platform_pci_dma_supported,		\
+	platform_pci_dac_dma_supported,		\
+	platform_pci_dac_page_to_dma,		\
+	platform_pci_dac_dma_to_page,		\
+	platform_pci_dac_dma_sync_single,	\
 	platform_irq_desc,			\
 	platform_irq_to_vector,			\
 	platform_local_vector_to_irq,		\
@@ -264,6 +285,21 @@
 #endif
 #ifndef platform_pci_dma_address
 # define  platform_pci_dma_address	swiotlb_dma_address
+#endif
+#ifndef platform_pci_dma_supported
+# define  platform_pci_dma_supported	swiotlb_pci_dma_supported
+#endif
+#ifndef platform_pci_dac_dma_supported
+# define  platform_pci_dac_dma_supported	swiotlb_pci_dac_dma_supported
+#endif
+#ifndef platform_pci_dac_page_to_dma
+# define  platform_pci_dac_page_to_dma	swiotlb_pci_dac_page_to_dma
+#endif
+#ifndef platform_pci_dac_dma_to_page
+# define  platform_pci_dac_dma_to_page	swiotlb_pci_dac_dma_to_page
+#endif
+#ifndef platform_pci_dac_dma_sync_single
+# define  platform_pci_dac_dma_sync_single	swiotlb_pci_dac_dma_sync_single
 #endif
 #ifndef platform_irq_desc
 # define platform_irq_desc		__ia64_irq_desc
diff -Naur -X /home/jbarnes/dontdiff linux-2.4.18-ia64/include/asm-ia64/machvec_sn1.h linux-2.4.18-ia64-pci-dac/include/asm-ia64/machvec_sn1.h
--- linux-2.4.18-ia64/include/asm-ia64/machvec_sn1.h	Thu Apr 18 12:37:01 2002
+++ linux-2.4.18-ia64-pci-dac/include/asm-ia64/machvec_sn1.h	Thu Apr 18 12:38:09 2002
@@ -59,6 +59,11 @@
 extern ia64_mv_pci_dma_sync_single	sn_pci_dma_sync_single;
 extern ia64_mv_pci_dma_sync_sg		sn_pci_dma_sync_sg;
 extern ia64_mv_pci_dma_address		sn_dma_address;
+extern ia64_mv_pci_dma_supported	sn_pci_dma_supported;
+extern ia64_mv_pci_dac_dma_supported	sn_pci_dac_dma_supported;
+extern ia64_mv_pci_dac_page_to_dma	sn_pci_dac_page_to_dma;
+extern ia64_mv_pci_dac_dma_to_page	sn_pci_dac_dma_to_page;
+extern ia64_mv_pci_dac_dma_sync_single	sn_pci_dac_dma_sync_single;
 
 /*
  * This stuff has dual use!
@@ -95,5 +100,10 @@
 #define platform_pci_dma_sync_single	sn_pci_dma_sync_single
 #define platform_pci_dma_sync_sg	sn_pci_dma_sync_sg
 #define platform_pci_dma_address	sn_dma_address
+#define platform_pci_dma_supported	sn_pci_dma_supported
+#define platform_pci_dac_dma_supported	sn_pci_dac_dma_supported
+#define platform_pci_dac_page_to_dma	sn_pci_dac_page_to_dma
+#define platform_pci_dac_dma_to_page	sn_pci_dac_dma_to_page
+#define platform_pci_dac_dma_sync_single	sn_pci_dac_dma_sync_single
 
 #endif /* _ASM_IA64_MACHVEC_SN1_h */
diff -Naur -X /home/jbarnes/dontdiff linux-2.4.18-ia64/include/asm-ia64/machvec_sn2.h linux-2.4.18-ia64-pci-dac/include/asm-ia64/machvec_sn2.h
--- linux-2.4.18-ia64/include/asm-ia64/machvec_sn2.h	Thu Apr 18 12:37:01 2002
+++ linux-2.4.18-ia64-pci-dac/include/asm-ia64/machvec_sn2.h	Thu Apr 18 12:38:09 2002
@@ -59,6 +59,11 @@
 extern ia64_mv_pci_dma_sync_single	sn_pci_dma_sync_single;
 extern ia64_mv_pci_dma_sync_sg		sn_pci_dma_sync_sg;
 extern ia64_mv_pci_dma_address		sn_dma_address;
+extern ia64_mv_pci_dma_supported	sn_pci_dma_supported;
+extern ia64_mv_pci_dac_dma_supported	sn_pci_dac_dma_supported;
+extern ia64_mv_pci_dac_page_to_dma	sn_pci_dac_page_to_dma;
+extern ia64_mv_pci_dac_dma_to_page	sn_pci_dac_dma_to_page;
+extern ia64_mv_pci_dac_dma_sync_single	sn_pci_dac_dma_sync_single;
 
 /*
  * This stuff has dual use!
@@ -95,5 +100,10 @@
 #define platform_pci_dma_sync_single	sn_pci_dma_sync_single
 #define platform_pci_dma_sync_sg	sn_pci_dma_sync_sg
 #define platform_pci_dma_address	sn_dma_address
+#define platform_pci_dma_supported	sn_pci_dma_supported
+#define platform_pci_dac_dma_supported	sn_pci_dac_dma_supported
+#define platform_pci_dac_page_to_dma	sn_pci_dac_page_to_dma
+#define platform_pci_dac_dma_to_page	sn_pci_dac_dma_to_page
+#define platform_pci_dac_dma_sync_single	sn_pci_dac_dma_sync_single
 
 #endif /* _ASM_IA64_MACHVEC_SN2_H */
diff -Naur -X /home/jbarnes/dontdiff linux-2.4.18-ia64/include/asm-ia64/pci.h linux-2.4.18-ia64-pci-dac/include/asm-ia64/pci.h
--- linux-2.4.18-ia64/include/asm-ia64/pci.h	Thu Apr 18 12:37:01 2002
+++ linux-2.4.18-ia64-pci-dac/include/asm-ia64/pci.h	Thu Apr 18 12:41:41 2002
@@ -50,6 +50,7 @@
 #define pci_dma_sync_single		platform_pci_dma_sync_single
 #define pci_dma_sync_sg			platform_pci_dma_sync_sg
 #define sg_dma_address			platform_pci_dma_address
+#define pci_dma_supported		platform_pci_dma_supported
 
 /* pci_unmap_{single,page} is not a nop, thus... */
 #define DECLARE_PCI_UNMAP_ADDR(addr_name)	dma_addr_t addr_name;
@@ -59,29 +60,20 @@
 #define pci_unmap_len(ptr, len_name)		((ptr)->len_name)
 #define pci_unmap_len_set(ptr, len_name, val)	(((ptr)->len_name) = (val))
 
-/*
- * Return whether the given PCI device DMA address mask can be supported properly.  For
- * example, if your device can only drive the low 24-bits during PCI bus mastering, then
- * you would pass 0x00ffffff as the mask to this function.
- */
-static inline int
-pci_dma_supported (struct pci_dev *hwdev, u64 mask)
-{
-	return 1;
-}
-
 #define pci_map_page(dev,pg,off,size,dir)				\
 	pci_map_single((dev), page_address(pg) + (off), (size), (dir))
 #define pci_unmap_page(dev,dma_addr,size,dir)				\
 	pci_unmap_single((dev), (dma_addr), (size), (dir))
 
-/* The ia64 platform always supports 64-bit addressing. */
-#define pci_dac_dma_supported(pci_dev, mask)	(1)
-
-#define pci_dac_page_to_dma(dev,pg,off,dir)	((dma64_addr_t) page_to_bus(pg) + (off))
-#define pci_dac_dma_to_page(dev,dma_addr)	(virt_to_page(bus_to_virt(dma_addr)))
-#define pci_dac_dma_to_offset(dev,dma_addr)	((dma_addr) & ~PAGE_MASK)
-#define pci_dac_dma_sync_single(dev,dma_addr,len,dir)	do { /* nothing */ } while (0)
+/*
+ * PCI DAC DMA mapping routines
+ */
+#define pci_dac_dma_supported		platform_pci_dac_dma_supported
+#define pci_dac_page_to_dma		platform_pci_dac_page_to_dma
+#define pci_dac_dma_to_page		platform_pci_dac_dma_to_page
+#define pci_dac_dma_sync_single		platform_pci_dac_dma_sync_single
+  
+#define pci_dac_dma_to_offset(hwdev,dma_addr) ((dma_addr) & ~PAGE_MASK)
 
 /* Return the index of the PCI controller for device PDEV. */
 #define pci_controller_num(PDEV)	(0)
diff -Naur -X /home/jbarnes/dontdiff linux-2.4.18-ia64/include/asm-ia64/types.h linux-2.4.18-ia64-pci-dac/include/asm-ia64/types.h
--- linux-2.4.18-ia64/include/asm-ia64/types.h	Fri Apr 21 15:21:24 2000
+++ linux-2.4.18-ia64-pci-dac/include/asm-ia64/types.h	Thu Apr 18 12:38:09 2002
@@ -63,6 +63,7 @@
 /* DMA addresses are 64-bits wide, in general.  */
 
 typedef u64 dma_addr_t;
+typedef u64 dma64_addr_t;
 
 # endif /* __KERNEL__ */
 #endif /* !__ASSEMBLY__ */

