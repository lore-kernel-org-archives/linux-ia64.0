From: Jesse Barnes <jbarnes@sgi.com>
Date: Sat, 27 Mar 2004 00:00:52 +0000
Subject: [PATCH] implement dma_mapping_error
Message-Id: <200403261600.52088.jbarnes@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_0QMZAdrqgR3y5mT"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_0QMZAdrqgR3y5mT
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On sn2, dma_mapping_error is trivial.  pci_map_single was already returning 0 
in case of failure (0 is an invalid DMA address on sn2), so make 
dma_mapping_error check for that.

Thanks,
Jesse

--Boundary-00=_0QMZAdrqgR3y5mT
Content-Type: text/plain;
  charset="us-ascii";
  name="pci-dma-mapping-error-2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="pci-dma-mapping-error-2.patch"

===== arch/ia64/sn/io/machvec/pci_dma.c 1.29 vs edited =====
--- 1.29/arch/ia64/sn/io/machvec/pci_dma.c	Mon Mar 22 06:34:46 2004
+++ edited/arch/ia64/sn/io/machvec/pci_dma.c	Fri Mar 26 14:33:08 2004
@@ -391,11 +391,9 @@
 	dma_map = pcibr_dmamap_alloc(vhdl, NULL, size, PCIIO_DMA_DATA | 
 				     MINIMAL_ATE_FLAG(phys_addr, size));
 
-	if (!dma_map) {
-		printk(KERN_ERR "pci_map_single: Unable to allocate anymore "
-		       "32 bit page map entries.\n");
+	/* PMU out of entries */
+	if (!dma_map)
 		return 0;
-	}
 
 	dma_addr = (dma_addr_t) pcibr_dmamap_addr(dma_map, phys_addr, size);
 	dma_map->bd_dma_addr = dma_addr;
@@ -655,6 +653,12 @@
 int
 sn_dma_mapping_error(dma_addr_t dma_addr)
 {
+	/*
+	 * We can only run out of page mapping entries, so if there's
+	 * an error, tell the caller to try again later.
+	 */
+	if (!dma_addr)
+		return -EAGAIN;
 	return 0;
 }
 

--Boundary-00=_0QMZAdrqgR3y5mT--
