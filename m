From: Christoph Hellwig <hch@lst.de>
Date: Fri, 26 Sep 2003 09:30:59 +0000
Subject: [PATCH] simplify and speedup SN2 dma mapping
Message-Id: <marc-linux-ia64-106456869808105@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Currently the the SN2 dma mapping code uses a file systen lookup (!!) to
find the operation vector for the underlying dma mapping implementation.

But not only there is exactly one of those implementation, also data
structures from this lowlevel driver are used in the actual Linux dma
mapping routines and quite a few assumption are made about it.  So let's
just call directly in the lowlevel code and give up this utter bullshit.


--- 1.10/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Mon Sep  8 14:12:36 2003
+++ edited/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Fri Sep 26 09:43:58 2003
@@ -700,12 +700,12 @@
 		 * Pre assign DMA maps needed for 32 Bits Page Map DMA.
 		 */
 		busnum_to_atedmamaps[num_bridges - 1] = (void *) kmalloc(
-			sizeof(struct sn_dma_maps_s) * MAX_ATE_MAPS, GFP_KERNEL);
+			sizeof(struct pcibr_dmamap_s) * MAX_ATE_MAPS, GFP_KERNEL);
 		if (!busnum_to_atedmamaps[num_bridges - 1])
 			printk("WARNING: pci_bus_map_create: Unable to precreate ATE DMA Maps for busnum %d vertex 0x%p\n", num_bridges - 1, (void *)xwidget);
 
 		memset(busnum_to_atedmamaps[num_bridges - 1], 0x0, 
-			sizeof(struct sn_dma_maps_s) * MAX_ATE_MAPS);
+			sizeof(struct pcibr_dmamap_s) * MAX_ATE_MAPS);
 
 	}
 
@@ -764,12 +764,12 @@
 			 * Pre assign DMA maps needed for 32 Bits Page Map DMA.
 			 */
 			busnum_to_atedmamaps[bus_number] = (void *) kmalloc(
-				sizeof(struct sn_dma_maps_s) * MAX_ATE_MAPS, GFP_KERNEL);
+				sizeof(struct pcibr_dmamap_s) * MAX_ATE_MAPS, GFP_KERNEL);
 			if (!busnum_to_atedmamaps[bus_number])
 				printk("WARNING: pci_bus_map_create: Unable to precreate ATE DMA Maps for busnum %d vertex 0x%p\n", num_bridges - 1, (void *)xwidget);
 	
 			memset(busnum_to_atedmamaps[bus_number], 0x0, 
-				sizeof(struct sn_dma_maps_s) * MAX_ATE_MAPS);
+				sizeof(struct pcibr_dmamap_s) * MAX_ATE_MAPS);
 		}
 	}
 
=== arch/ia64/sn/io/machvec/pci_dma.c 1.14 vs edited ==--- 1.14/arch/ia64/sn/io/machvec/pci_dma.c	Fri Sep 26 09:13:22 2003
+++ edited/arch/ia64/sn/io/machvec/pci_dma.c	Fri Sep 26 09:50:33 2003
@@ -36,7 +36,7 @@
  */
 pciio_dmamap_t get_free_pciio_dmamap(vertex_hdl_t);
 void free_pciio_dmamap(pcibr_dmamap_t);
-static struct sn_dma_maps_s *find_sn_dma_map(dma_addr_t, unsigned char);
+static struct pcibr_dmamap_s *find_sn_dma_map(dma_addr_t, unsigned char);
 void sn_pci_unmap_sg(struct pci_dev *hwdev, struct scatterlist *sg, int nents, int direction);
 
 /*
@@ -57,7 +57,7 @@
 get_free_pciio_dmamap(vertex_hdl_t pci_bus)
 {
 	int i;
-	struct sn_dma_maps_s *sn_dma_map = NULL;
+	struct pcibr_dmamap_s *sn_dma_map = NULL;
 
 	/*
 	 * Darn, we need to get the maps allocated for this bus.
@@ -72,8 +72,8 @@
 	 * Now get a free dmamap entry from this list.
 	 */
 	for (i = 0; i < MAX_ATE_MAPS; i++, sn_dma_map++) {
-		if (!sn_dma_map->dma_addr) {
-			sn_dma_map->dma_addr = -1;
+		if (!sn_dma_map->bd_dma_addr) {
+			sn_dma_map->bd_dma_addr = -1;
 			return( (pciio_dmamap_t) sn_dma_map );
 		}
 	}
@@ -90,10 +90,7 @@
 void
 free_pciio_dmamap(pcibr_dmamap_t dma_map)
 {
-	struct sn_dma_maps_s *sn_dma_map;
-
-	sn_dma_map = (struct sn_dma_maps_s *) dma_map;
-	sn_dma_map->dma_addr = 0;
+	dma_map->bd_dma_addr = 0;
 }
 
 /**
@@ -103,17 +100,17 @@
  *
  * Finds the ATE associated with @dma_addr and @busnum.
  */
-static struct sn_dma_maps_s *
+static struct pcibr_dmamap_s *
 find_sn_dma_map(dma_addr_t dma_addr, unsigned char busnum)
 {
 
-	struct sn_dma_maps_s *sn_dma_map = NULL;
+	struct pcibr_dmamap_s *sn_dma_map = NULL;
 	int i;
 
 	sn_dma_map = busnum_to_atedmamaps[busnum];
 
 	for (i = 0; i < MAX_ATE_MAPS; i++, sn_dma_map++) {
-		if (sn_dma_map->dma_addr = dma_addr) {
+		if (sn_dma_map->bd_dma_addr = dma_addr) {
 			return sn_dma_map;
 		}
 	}
@@ -147,8 +144,7 @@
 	vertex_hdl_t vhdl;
 	struct sn_device_sysdata *device_sysdata;
 	unsigned long phys_addr;
-	pciio_dmamap_t dma_map = 0;
-	struct sn_dma_maps_s *sn_dma_map;
+	pcibr_dmamap_t dma_map = 0;
 
 	*dma_handle = 0;
 
@@ -180,7 +176,7 @@
 	 * device on the same bus is already mapped with different
 	 * attributes or to a different memory region.
 	 */
-	*dma_handle = pciio_dmatrans_addr(vhdl, NULL, phys_addr, size,
+	*dma_handle = pcibr_dmatrans_addr(vhdl, NULL, phys_addr, size,
 			((IS_PIC_DEVICE(hwdev)) ? 0 : PCIIO_BYTE_STREAM) |
 					  PCIIO_DMA_CMD);
 
@@ -199,7 +195,7 @@
 	 * so we try to use an ATE.
 	 */
 	if (!(*dma_handle)) {
-		dma_map = pciio_dmamap_alloc(vhdl, NULL, size,
+		dma_map = pcibr_dmamap_alloc(vhdl, NULL, size,
 				((IS_PIC_DEVICE(hwdev)) ? 0 : PCIIO_BYTE_STREAM) |
 					     PCIIO_DMA_CMD);
 		if (!dma_map) {
@@ -207,10 +203,9 @@
 			       "allocate anymore 32 bit page map entries.\n");
 			return 0;
 		}
-		*dma_handle = (dma_addr_t) pciio_dmamap_addr(dma_map,phys_addr,
+		*dma_handle = (dma_addr_t) pcibr_dmamap_addr(dma_map,phys_addr,
 							     size);
-		sn_dma_map = (struct sn_dma_maps_s *)dma_map;
-		sn_dma_map->dma_addr = *dma_handle;
+		dma_map->bd_dma_addr = *dma_handle;
 	}
 
         return cpuaddr;
@@ -229,21 +224,21 @@
 void
 sn_pci_free_consistent(struct pci_dev *hwdev, size_t size, void *vaddr, dma_addr_t dma_handle)
 {
-	struct sn_dma_maps_s *sn_dma_map = NULL;
+	struct pcibr_dmamap_s *dma_map = NULL;
 
 	/*
 	 * Get the sn_dma_map entry.
 	 */
 	if (IS_PCI32_MAPPED(dma_handle))
-		sn_dma_map = find_sn_dma_map(dma_handle, hwdev->bus->number);
+		dma_map = find_sn_dma_map(dma_handle, hwdev->bus->number);
 
 	/*
 	 * and free it if necessary...
 	 */
-	if (sn_dma_map) {
-		pciio_dmamap_done((pciio_dmamap_t)sn_dma_map);
-		pciio_dmamap_free((pciio_dmamap_t)sn_dma_map);
-		sn_dma_map->dma_addr = (dma_addr_t)NULL;
+	if (dma_map) {
+		pcibr_dmamap_done(dma_map);
+		pcibr_dmamap_free(dma_map);
+		dma_map->bd_dma_addr = 0;
 	}
 	free_pages((unsigned long) vaddr, get_order(size));
 }
@@ -266,8 +261,7 @@
 	vertex_hdl_t vhdl;
 	unsigned long phys_addr;
 	struct sn_device_sysdata *device_sysdata;
-	pciio_dmamap_t dma_map;
-	struct sn_dma_maps_s *sn_dma_map;
+	pcibr_dmamap_t dma_map;
 	struct scatterlist *saved_sg = sg;
 
 	/* can't go anywhere w/o a direction in life */
@@ -293,7 +287,7 @@
 		 * call should always succeed.
 		 */
 		if (IS_PCIA64(hwdev)) {
-			sg->dma_address = pciio_dmatrans_addr(vhdl, NULL, phys_addr,
+			sg->dma_address = pcibr_dmatrans_addr(vhdl, NULL, phys_addr,
 						       sg->length,
 			       ((IS_PIC_DEVICE(hwdev)) ? 0 : PCIIO_BYTE_STREAM) |
 						       PCIIO_DMA_DATA |
@@ -306,7 +300,7 @@
 		 * Handle 32-63 bit cards via direct mapping
 		 */
 		if (IS_PCI32G(hwdev)) {
-			sg->dma_address = pciio_dmatrans_addr(vhdl, NULL, phys_addr,
+			sg->dma_address = pcibr_dmatrans_addr(vhdl, NULL, phys_addr,
 						       sg->length,
 					((IS_PIC_DEVICE(hwdev)) ? 0 : PCIIO_BYTE_STREAM) |
 						       PCIIO_DMA_DATA);
@@ -324,7 +318,7 @@
 		 * It is a 32 bit card and we cannot do direct mapping,
 		 * so we use an ATE.
 		 */
-		dma_map = pciio_dmamap_alloc(vhdl, NULL, sg->length,
+		dma_map = pcibr_dmamap_alloc(vhdl, NULL, sg->length,
 				((IS_PIC_DEVICE(hwdev)) ? 0 : PCIIO_BYTE_STREAM) |
 					     PCIIO_DMA_DATA);
 		if (!dma_map) {
@@ -339,10 +333,9 @@
 			return (0);
 		}
 
-		sg->dma_address = pciio_dmamap_addr(dma_map, phys_addr, sg->length);
+		sg->dma_address = pcibr_dmamap_addr(dma_map, phys_addr, sg->length);
 		sg->dma_length = sg->length;
-		sn_dma_map = (struct sn_dma_maps_s *)dma_map;
-		sn_dma_map->dma_addr = sg->dma_address;
+		dma_map->bd_dma_addr = sg->dma_address;
 	}
 
 	return nents;
@@ -364,7 +357,7 @@
 sn_pci_unmap_sg(struct pci_dev *hwdev, struct scatterlist *sg, int nents, int direction)
 {
 	int i;
-	struct sn_dma_maps_s *sn_dma_map;
+	struct pcibr_dmamap_s *dma_map;
 
 	/* can't go anywhere w/o a direction in life */
 	if (direction = PCI_DMA_NONE)
@@ -373,12 +366,11 @@
 	for (i = 0; i < nents; i++, sg++){
 
 		if (IS_PCI32_MAPPED(sg->dma_address)) {
-			sn_dma_map = NULL;
-                	sn_dma_map = find_sn_dma_map(sg->dma_address, hwdev->bus->number);
-        		if (sn_dma_map) {
-                		pciio_dmamap_done((pciio_dmamap_t)sn_dma_map);
-                		pciio_dmamap_free((pciio_dmamap_t)sn_dma_map);
-                		sn_dma_map->dma_addr = (dma_addr_t)NULL;
+                	dma_map = find_sn_dma_map(sg->dma_address, hwdev->bus->number);
+        		if (dma_map) {
+                		pcibr_dmamap_done(dma_map);
+                		pcibr_dmamap_free(dma_map);
+                		dma_map->bd_dma_addr = 0;
 			}
         	}
 
@@ -398,7 +390,7 @@
  * DMA address.   Also known as platform_pci_map_single() by
  * the IA64 machvec code.
  *
- * We map this to the one step pciio_dmamap_trans interface rather than
+ * We map this to the one step pcibr_dmamap_trans interface rather than
  * the two step pciio_dmamap_alloc/pciio_dmamap_addr because we have
  * no way of saving the dmamap handle from the alloc to later free
  * (which is pretty much unacceptable).
@@ -414,8 +406,7 @@
 	dma_addr_t dma_addr;
 	unsigned long phys_addr;
 	struct sn_device_sysdata *device_sysdata;
-	pciio_dmamap_t dma_map = NULL;
-	struct sn_dma_maps_s *sn_dma_map;
+	pcibr_dmamap_t dma_map = NULL;
 
 	if (direction = PCI_DMA_NONE)
 		BUG();
@@ -438,7 +429,7 @@
 
 	if (IS_PCIA64(hwdev)) {
 		/* This device supports 64 bit DMA addresses. */
-		dma_addr = pciio_dmatrans_addr(vhdl, NULL, phys_addr, size,
+		dma_addr = pcibr_dmatrans_addr(vhdl, NULL, phys_addr, size,
 		       ((IS_PIC_DEVICE(hwdev)) ? 0 : PCIIO_BYTE_STREAM) |
 					       PCIIO_DMA_DATA |
 					       PCIIO_DMA_A64);
@@ -452,7 +443,7 @@
 	 * First try to get a 32 bit direct map register.
 	 */
 	if (IS_PCI32G(hwdev)) {
-		dma_addr = pciio_dmatrans_addr(vhdl, NULL, phys_addr, size,
+		dma_addr = pcibr_dmatrans_addr(vhdl, NULL, phys_addr, size,
 			((IS_PIC_DEVICE(hwdev)) ? 0 : PCIIO_BYTE_STREAM) |
 					       PCIIO_DMA_DATA);
 		if (dma_addr)
@@ -464,7 +455,7 @@
 	 * let's use the PMU instead.
 	 */
 	dma_map = NULL;
-	dma_map = pciio_dmamap_alloc(vhdl, NULL, size, 
+	dma_map = pcibr_dmamap_alloc(vhdl, NULL, size, 
 			((IS_PIC_DEVICE(hwdev)) ? 0 : PCIIO_BYTE_STREAM) |
 			PCIIO_DMA_DATA);
 
@@ -474,9 +465,8 @@
 		return 0;
 	}
 
-	dma_addr = (dma_addr_t) pciio_dmamap_addr(dma_map, phys_addr, size);
-	sn_dma_map = (struct sn_dma_maps_s *)dma_map;
-	sn_dma_map->dma_addr = dma_addr;
+	dma_addr = (dma_addr_t) pcibr_dmamap_addr(dma_map, phys_addr, size);
+	dma_map->bd_dma_addr = dma_addr;
 
 	return ((dma_addr_t)dma_addr);
 }
@@ -494,7 +484,7 @@
 void
 sn_pci_unmap_single(struct pci_dev *hwdev, dma_addr_t dma_addr, size_t size, int direction)
 {
-	struct sn_dma_maps_s *sn_dma_map = NULL;
+	struct pcibr_dmamap_s *dma_map = NULL;
 
         if (direction = PCI_DMA_NONE)
 		BUG();
@@ -503,15 +493,15 @@
 	 * Get the sn_dma_map entry.
 	 */
 	if (IS_PCI32_MAPPED(dma_addr))
-		sn_dma_map = find_sn_dma_map(dma_addr, hwdev->bus->number);
+		dma_map = find_sn_dma_map(dma_addr, hwdev->bus->number);
 
 	/*
 	 * and free it if necessary...
 	 */
-	if (sn_dma_map) {
-		pciio_dmamap_done((pciio_dmamap_t)sn_dma_map);
-		pciio_dmamap_free((pciio_dmamap_t)sn_dma_map);
-		sn_dma_map->dma_addr = (dma_addr_t)NULL;
+	if (dma_map) {
+		pcibr_dmamap_done(dma_map);
+		pcibr_dmamap_free(dma_map);
+		dma_map->bd_dma_addr = 0;
 	}
 }
 
--- 1.9/include/asm-ia64/sn/pci/pcibr_private.h	Tue Sep 16 17:30:22 2003
+++ edited/include/asm-ia64/sn/pci/pcibr_private.h	Fri Sep 26 09:30:53 2003
@@ -139,6 +139,7 @@
     bridge_ate_p            bd_ate_ptr;		/* where to write first ATE */
     bridge_ate_t            bd_ate_proto;	/* prototype ATE (for xioaddr=0) */
     bridge_ate_t            bd_ate_prime;	/* value of 1st ATE written */
+    dma_addr_t		    bd_dma_addr;	/* Linux dma handle */
 };
 
 #define	IBUFSIZE	5		/* size of circular buffer (holds 4) */
