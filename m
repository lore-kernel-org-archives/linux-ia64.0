From: Christoph Hellwig <hch@lst.de>
Date: Sat, 27 Sep 2003 14:24:00 +0000
Subject: [PATCH] sanitize SN2 pci resource setup
Message-Id: <marc-linux-ia64-106467267026750@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A new function, sn_fixup_resource centralizes all handling of pci
resource fixups.  Code slightly cleaned up.


diff -Nru a/arch/ia64/sn/io/machvec/pci_bus_cvlink.c b/arch/ia64/sn/io/machvec/pci_bus_cvlink.c
--- a/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Sat Sep 27 16:20:32 2003
+++ b/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Sat Sep 27 16:20:32 2003
@@ -425,6 +425,39 @@
 	}
 }
 
+
+static void sn_fixup_resource(struct pci_dev *pdev, int idx)
+{
+	struct resource *resource = &pdev->resource[idx];
+	vertex_hdl_t		vhdl = PCIDEV_VERTEX(pdev);
+	pciio_space_t		space = PCIIO_SPACE_WIN(idx);
+	unsigned long		size = resource->end - resource->start;
+	caddr_t                 res = 0;
+	unsigned		flags = 0;
+
+	if (IS_PIC_DEVICE(pdev))
+		flags |= PCIIO_BYTE_STREAM;
+
+	if (!size)
+		return;
+
+	res = pcibr_piotrans_addr(vhdl, NULL, space, 0, size, flags);
+	if (!res) {
+		struct pcibr_piomap_s *map;
+
+		map = pcibr_piomap_alloc(vhdl, NULL, space, 0,
+				size, size, flags);
+		if (map) {
+			res = pcibr_piomap_addr(map, 0, size);
+			if (!res) /* XXX: handle error properly */
+				pcibr_piomap_free(map);
+		}
+	}
+
+	resource->start = (unsigned long)res | __IA64_UNCACHED_OFFSET;
+	resource->end = resource->start + size;
+}
+
 static void __init sn_pci_fixup_one(struct pci_dev *pdev)
 {
 	struct sn_device_sysdata *device_sysdata;
@@ -461,17 +494,7 @@
 	 * Infrastructure ..
 	 */
 	for (idx = 0; idx < PCI_ROM_RESOURCE; idx++) {
-		size = pdev->resource[idx].end -
-			pdev->resource[idx].start;
-		if (!size)
-			continue;
-		pdev->resource[idx].start -			(unsigned long)pciio_pio_addr(device_vertex, 0,
-				PCIIO_SPACE_WIN(idx), 0, size, 0,
-				(IS_PIC_DEVICE(pdev)) ? 0 :
-					PCIIO_BYTE_STREAM);
-		pdev->resource[idx].start |= __IA64_UNCACHED_OFFSET;
-		pdev->resource[idx].end = pdev->resource[idx].start + size;
+		sn_fixup_resource(pdev, idx);
 
 		if (pdev->resource[idx].flags & IORESOURCE_IO)
 			cmd |= PCI_COMMAND_IO;
diff -Nru a/arch/ia64/sn/io/sn2/pciio.c b/arch/ia64/sn/io/sn2/pciio.c
--- a/arch/ia64/sn/io/sn2/pciio.c	Sat Sep 27 16:20:32 2003
+++ b/arch/ia64/sn/io/sn2/pciio.c	Sat Sep 27 16:20:32 2003
@@ -345,49 +345,6 @@
 	(dev, dev_desc, space, addr, byte_count, flags);
 }
 
-caddr_t
-pciio_pio_addr(vertex_hdl_t dev,	/* translate for this device */
-	       device_desc_t dev_desc,	/* device descriptor */
-	       pciio_space_t space,	/* CFG, MEM, IO, or a device-decoded window */
-	       iopaddr_t addr,		/* starting address (or offset in window) */
-	       size_t byte_count,	/* map this many bytes */
-	       pciio_piomap_t *mapp,	/* where to return the map pointer */
-	       unsigned flags)
-{					/* PIO flags */
-    pciio_piomap_t          map = 0;
-    int			    errfree = 0;
-    caddr_t                 res;
-
-    if (mapp) {
-	map = *mapp;			/* possible pre-allocated map */
-	*mapp = 0;			/* record "no map used" */
-    }
-
-    res = pciio_piotrans_addr
-	(dev, dev_desc, space, addr, byte_count, flags);
-    if (res)
-	return res;			/* pciio_piotrans worked */
-
-    if (!map) {
-	map = pciio_piomap_alloc
-	    (dev, dev_desc, space, addr, byte_count, byte_count, flags);
-	if (!map)
-	    return res;			/* pciio_piomap_alloc failed */
-	errfree = 1;
-    }
-
-    res = pciio_piomap_addr
-	(map, addr, byte_count);
-    if (!res) {
-	if (errfree)
-	    pciio_piomap_free(map);
-	return res;			/* pciio_piomap_addr failed */
-    }
-    if (mapp)
-	*mapp = map;			/* pass back map used */
-
-    return res;				/* pciio_piomap_addr succeeded */
-}
 
 iopaddr_t
 pciio_piospace_alloc(vertex_hdl_t dev,	/* Device requiring space */
