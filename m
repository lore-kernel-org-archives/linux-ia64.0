From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 18 Jun 2003 16:20:15 +0000
Subject: [PATCH] PCI fixes for sn2
MIME-Version: 1
Content-Type: multipart/mixed; boundary="cPi+lWm09sJ+d57q"
Message-Id: <marc-linux-ia64-105595346915713@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--cPi+lWm09sJ+d57q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Sorry I didn't bunch these up, but this is the last of them.  Updates
the PCI routines for sn2.

Thanks,
Jesse

--cPi+lWm09sJ+d57q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sn2-pci-fixes-2.5.69-ia64-bk.patch"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1146  -> 1.1147 
#	arch/ia64/sn/io/machvec/pci.c	1.7     -> 1.8    
#	arch/ia64/sn/io/machvec/pci_dma.c	1.9     -> 1.10   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/17	jbarnes@tomahawk.engr.sgi.com	1.1147
# PCI fixes
# --------------------------------------------
#
diff -Nru a/arch/ia64/sn/io/machvec/pci.c b/arch/ia64/sn/io/machvec/pci.c
--- a/arch/ia64/sn/io/machvec/pci.c	Tue Jun 17 14:46:19 2003
+++ b/arch/ia64/sn/io/machvec/pci.c	Tue Jun 17 14:46:19 2003
@@ -49,6 +49,8 @@
 	vertex_hdl_t device_vertex;
 
 	device_vertex = devfn_to_vertex(bus->number, devfn);
+	if (!device_vertex)
+		return PCIBIOS_DEVICE_NOT_FOUND;
 	res = pciio_config_get(device_vertex, (unsigned) where, size);
 	*val = (unsigned int) res;
 	return PCIBIOS_SUCCESSFUL;
@@ -59,6 +61,8 @@
 	vertex_hdl_t device_vertex;
 
 	device_vertex = devfn_to_vertex(bus->number, devfn);
+	if (!device_vertex)
+		return PCIBIOS_DEVICE_NOT_FOUND;
 	pciio_config_set( device_vertex, (unsigned)where, size, (uint64_t) val);
 	return PCIBIOS_SUCCESSFUL;
 }
diff -Nru a/arch/ia64/sn/io/machvec/pci_dma.c b/arch/ia64/sn/io/machvec/pci_dma.c
--- a/arch/ia64/sn/io/machvec/pci_dma.c	Tue Jun 17 14:46:19 2003
+++ b/arch/ia64/sn/io/machvec/pci_dma.c	Tue Jun 17 14:46:19 2003
@@ -280,7 +280,7 @@
 	 */
 	for (i = 0; i < nents; i++, sg++) {
 		phys_addr = __pa(sg->dma_address ? sg->dma_address :
-			page_address(sg->page) + sg->offset);
+			(unsigned long)page_address(sg->page) + sg->offset);
 
 		/*
 		 * Handle the most common case: 64 bit cards.  This
@@ -578,7 +578,7 @@
 {
 	BUG_ON(dev->bus != &pci_bus_type);
 
-	return pci_dma_supported(to_pci_dev(dev), mask);
+	return sn_pci_dma_supported(to_pci_dev(dev), mask);
 }
 EXPORT_SYMBOL(sn_dma_supported);
 
@@ -587,7 +587,11 @@
 {
 	BUG_ON(dev->bus != &pci_bus_type);
 
-	return pci_set_dma_mask(to_pci_dev(dev), dma_mask);
+	if (!sn_dma_supported(to_pci_dev(dev), dma_mask))
+		return 0;
+
+	dev->dma_mask = dma_mask;
+	return 1;
 }
 EXPORT_SYMBOL(sn_dma_set_mask);
 
@@ -597,7 +601,7 @@
 {
 	BUG_ON(dev->bus != &pci_bus_type);
 
-	return pci_alloc_consistent(to_pci_dev(dev), size, dma_handle);
+	return sn_pci_alloc_consistent(to_pci_dev(dev), size, dma_handle);
 }
 EXPORT_SYMBOL(sn_dma_alloc_coherent);
 
@@ -607,7 +611,7 @@
 {
 	BUG_ON(dev->bus != &pci_bus_type);
 
-	pci_free_consistent(to_pci_dev(dev), size, cpu_addr, dma_handle);
+	sn_pci_free_consistent(to_pci_dev(dev), size, cpu_addr, dma_handle);
 }
 EXPORT_SYMBOL(sn_dma_free_coherent);
 
@@ -617,7 +621,7 @@
 {
 	BUG_ON(dev->bus != &pci_bus_type);
 
-	return pci_map_single(to_pci_dev(dev), cpu_addr, size, (int)direction);
+	return sn_pci_map_single(to_pci_dev(dev), cpu_addr, size, (int)direction);
 }
 EXPORT_SYMBOL(sn_dma_map_single);
 
@@ -627,7 +631,7 @@
 {
 	BUG_ON(dev->bus != &pci_bus_type);
 
-	pci_unmap_single(to_pci_dev(dev), dma_addr, size, (int)direction);
+	sn_pci_unmap_single(to_pci_dev(dev), dma_addr, size, (int)direction);
 }
 EXPORT_SYMBOL(sn_dma_unmap_single);
 
@@ -658,7 +662,7 @@
 {
 	BUG_ON(dev->bus != &pci_bus_type);
 
-	return pci_map_sg(to_pci_dev(dev), sg, nents, (int)direction);
+	return sn_pci_map_sg(to_pci_dev(dev), sg, nents, (int)direction);
 }
 EXPORT_SYMBOL(sn_dma_map_sg);
 
@@ -668,7 +672,7 @@
 {
 	BUG_ON(dev->bus != &pci_bus_type);
 
-	pci_unmap_sg(to_pci_dev(dev), sg, nhwentries, (int)direction);
+	sn_pci_unmap_sg(to_pci_dev(dev), sg, nhwentries, (int)direction);
 }
 EXPORT_SYMBOL(sn_dma_unmap_sg);
 
@@ -678,7 +682,7 @@
 {
 	BUG_ON(dev->bus != &pci_bus_type);
 
-	pci_dma_sync_single(to_pci_dev(dev), dma_handle, size, (int)direction);
+	sn_pci_dma_sync_single(to_pci_dev(dev), dma_handle, size, (int)direction);
 }
 EXPORT_SYMBOL(sn_dma_sync_single);
 
@@ -688,7 +692,7 @@
 {
 	BUG_ON(dev->bus != &pci_bus_type);
 
-	pci_dma_sync_sg(to_pci_dev(dev), sg, nelems, (int)direction);
+	sn_pci_dma_sync_sg(to_pci_dev(dev), sg, nelems, (int)direction);
 }
 EXPORT_SYMBOL(sn_dma_sync_sg);
 

--cPi+lWm09sJ+d57q--
