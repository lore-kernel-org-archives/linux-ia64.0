From: Christoph Hellwig <hch@lst.de>
Date: Fri, 26 Sep 2003 10:18:47 +0000
Subject: [PATCH] remove CONFIG_PCI ifdefs in SN2 code
Message-Id: <marc-linux-ia64-106457154710737@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It's not like it would compile without PCI support anyway, and these
ifdefs are _really_ strange.



--- 1.10/arch/ia64/sn/io/machvec/pci.c	Fri Aug  8 19:07:54 2003
+++ edited/arch/ia64/sn/io/machvec/pci.c	Fri Sep 26 12:00:06 2003
@@ -35,8 +35,6 @@
  * can probably be removed with a little more cleanup now that the SAL routines
  * work on sn2.
  */
-#ifdef CONFIG_PCI
-
 extern vertex_hdl_t devfn_to_vertex(unsigned char bus, unsigned char devfn);
 
 int sn_read_config(struct pci_bus *bus, unsigned int devfn, int where, int size, u32 *val)
@@ -71,9 +69,3 @@
 	.read = sn_read_config,
 	.write = sn_write_config,
 };
-
-#else
-struct list_head pci_root_buses;
-struct list_head pci_root_buses;
-struct list_head pci_devices;
-#endif /* CONFIG_PCI */
--- 1.14/arch/ia64/sn/io/machvec/pci_dma.c	Fri Sep 26 09:13:22 2003
+++ edited/arch/ia64/sn/io/machvec/pci_dma.c	Fri Sep 26 11:59:42 2003
@@ -572,8 +562,6 @@
 	return 1;
 }
 
-#ifdef CONFIG_PCI
-
 /*
  * New generic DMA routines just wrap sn2 PCI routines until we
  * support other bus types (if ever).
@@ -701,8 +689,6 @@
 	sn_pci_dma_sync_sg(to_pci_dev(dev), sg, nelems, (int)direction);
 }
 EXPORT_SYMBOL(sn_dma_sync_sg);
-
-#endif /* CONFIG_PCI */
 
 EXPORT_SYMBOL(sn_pci_unmap_single);
 EXPORT_SYMBOL(sn_pci_map_single);
