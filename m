From: Christoph Hellwig <hch@lst.de>
Date: Fri, 26 Sep 2003 09:17:51 +0000
Subject: [PATCH] kill snia_pciio_*
Message-Id: <marc-linux-ia64-106456792707424@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

These strange mixups of Linux and IRIX PCI interfaces were used in SGI's
2.4 tree for their port of the IRIX scsi code.  They have no business to
stgay in 2.6.


--- 1.4/arch/ia64/sn/io/sn2/pciio.c	Fri Sep 26 09:13:22 2003
+++ edited/arch/ia64/sn/io/sn2/pciio.c	Fri Sep 26 10:26:57 2003
@@ -14,6 +14,7 @@
 #include <linux/sched.h>
 #include <linux/ioport.h>
 #include <linux/slab.h>
+#include <linux/module.h>
 #include <asm/sn/sgi.h>
 #include <asm/sn/xtalk/xbow.h>	/* Must be before iograph.h to get MAX_PORT_NUM */
 #include <asm/sn/iograph.h>
@@ -1399,27 +1400,10 @@
 	return(0);
 }
 
-
 /*
- * These are complementary Linux interfaces that takes in a pci_dev * as the 
- * first arguement instead of vertex_hdl_t.
+ *  XXX: should probably be called __sn2_pci_rrb_alloc
  */
-iopaddr_t               snia_pciio_dmatrans_addr(struct pci_dev *, device_desc_t, paddr_t, size_t, unsigned);
-pciio_dmamap_t          snia_pciio_dmamap_alloc(struct pci_dev *, device_desc_t, size_t, unsigned);
-void                    snia_pciio_dmamap_free(pciio_dmamap_t);
-iopaddr_t               snia_pciio_dmamap_addr(pciio_dmamap_t, paddr_t, size_t);
-void                    snia_pciio_dmamap_done(pciio_dmamap_t);
-pciio_endian_t          snia_pciio_endian_set(struct pci_dev *pci_dev, pciio_endian_t device_end,
-					      pciio_endian_t desired_end);
-
-#include <linux/module.h>
-EXPORT_SYMBOL(snia_pciio_dmatrans_addr);
-EXPORT_SYMBOL(snia_pciio_dmamap_alloc);
-EXPORT_SYMBOL(snia_pciio_dmamap_free);
-EXPORT_SYMBOL(snia_pciio_dmamap_addr);
-EXPORT_SYMBOL(snia_pciio_dmamap_done);
-EXPORT_SYMBOL(snia_pciio_endian_set);
-
+/* used by qla1280 */
 int
 snia_pcibr_rrb_alloc(struct pci_dev *pci_dev,
 	int *count_vchan0,
@@ -1431,6 +1415,13 @@
 }
 EXPORT_SYMBOL(snia_pcibr_rrb_alloc);
 
+/* 
+ * XXX: interface should be more like
+ *
+ *	int __sn2_pci_enable_bwswap(struct pci_dev *dev);
+ *	void __sn2_pci_disable_bswap(struct pci_dev *dev);
+ */
+/* used by ioc4 ide */
 pciio_endian_t
 snia_pciio_endian_set(struct pci_dev *pci_dev,
 	pciio_endian_t device_end,
@@ -1441,62 +1432,4 @@
 	return DEV_FUNC(dev, endian_set)
 		(dev, device_end, desired_end);
 }
-
-iopaddr_t
-snia_pciio_dmatrans_addr(struct pci_dev *pci_dev, /* translate for this device */
-                    device_desc_t dev_desc,     /* device descriptor */
-                    paddr_t paddr,      /* system physical address */
-                    size_t byte_count,  /* length */
-                    unsigned flags)
-{                                       /* defined in dma.h */
-
-    vertex_hdl_t dev = PCIDEV_VERTEX(pci_dev);
-
-    /*
-     * If the device is not a PIC, we always want the PCIIO_BYTE_STREAM to be 
-     * set.  Otherwise, it must not be set.  This applies to SN1 and SN2.
-     */
-    return DEV_FUNC(dev, dmatrans_addr)
-        (dev, dev_desc, paddr, byte_count, (IS_PIC_DEVICE(pci_dev)) ? (flags & ~PCIIO_BYTE_STREAM) : flags | PCIIO_BYTE_STREAM);
-}
-
-pciio_dmamap_t
-snia_pciio_dmamap_alloc(struct pci_dev *pci_dev,  /* set up mappings for this device */
-                   device_desc_t dev_desc,      /* device descriptor */
-                   size_t byte_count_max,       /* max size of a mapping */
-                   unsigned flags)
-{                                       /* defined in dma.h */
-
-    vertex_hdl_t dev = PCIDEV_VERTEX(pci_dev);
-
-    /*
-     * If the device is not a PIC, we always want the PCIIO_BYTE_STREAM to be
-     * set.  Otherwise, it must not be set.  This applies to SN1 and SN2.
-     */
-    return (pciio_dmamap_t) DEV_FUNC(dev, dmamap_alloc)
-        (dev, dev_desc, byte_count_max, (IS_PIC_DEVICE(pci_dev)) ? (flags & ~PCIIO_BYTE_STREAM) : flags | PCIIO_BYTE_STREAM);
-}
-
-void
-snia_pciio_dmamap_free(pciio_dmamap_t pciio_dmamap)
-{
-    DMAMAP_FUNC(pciio_dmamap, dmamap_free)
-        (CAST_DMAMAP(pciio_dmamap));
-}
-
-iopaddr_t
-snia_pciio_dmamap_addr(pciio_dmamap_t pciio_dmamap,  /* use these mapping resources */
-                  paddr_t paddr,        /* map for this address */
-                  size_t byte_count)
-{                                       /* map this many bytes */
-    return DMAMAP_FUNC(pciio_dmamap, dmamap_addr)
-        (CAST_DMAMAP(pciio_dmamap), paddr, byte_count);
-}
-
-void
-snia_pciio_dmamap_done(pciio_dmamap_t pciio_dmamap)
-{
-    DMAMAP_FUNC(pciio_dmamap, dmamap_done)
-        (CAST_DMAMAP(pciio_dmamap));
-}
-
+EXPORT_SYMBOL(snia_pciio_endian_set);
--- 1.5/include/asm-ia64/sn/pci/pci_bus_cvlink.h	Fri May 16 13:18:18 2003
+++ edited/include/asm-ia64/sn/pci/pci_bus_cvlink.h	Fri Sep 26 09:49:31 2003
@@ -60,11 +60,6 @@
 	volatile unsigned int *xbow_buf_sync;
 };
 
-struct sn_dma_maps_s{
-	struct pcibr_dmamap_s dma_map;
-        dma_addr_t      dma_addr;
-};
-
 struct ioports_to_tlbs_s {
 	unsigned long	p:1,
 			rv_1:1,
