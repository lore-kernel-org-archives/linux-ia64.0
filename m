From: Keith Owens <kaos@sgi.com>
Date: Sat, 23 Oct 2004 02:00:14 +0000
Subject: [patch 2.6.9] __init fixes for distcontiguous and SGI code
Message-Id: <14725.1098496814@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Correct references from text/data to init.text/data.  These errors were
found by 'make buildcheck'.

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: linux/arch/ia64/mm/discontig.c
=================================--- linux.orig/arch/ia64/mm/discontig.c	Tue Oct 19 07:55:06 2004
+++ linux/arch/ia64/mm/discontig.c	Fri Oct 22 15:56:39 2004
@@ -601,7 +601,7 @@ void call_pernode_memory(unsigned long s
  * for each piece of usable memory and will setup these values for each node.
  * Very similar to build_maps().
  */
-static int count_node_pages(unsigned long start, unsigned long len, int node)
+static __init int count_node_pages(unsigned long start, unsigned long len, int node)
 {
 	unsigned long end = start + len;
 
@@ -626,7 +626,7 @@ static int count_node_pages(unsigned lon
  * paging_init() sets up the page tables for each node of the system and frees
  * the bootmem allocator memory for general use.
  */
-void paging_init(void)
+void __init paging_init(void)
 {
 	unsigned long max_dma;
 	unsigned long zones_size[MAX_NR_ZONES];
Index: linux/drivers/ide/pci/sgiioc4.c
=================================--- linux.orig/drivers/ide/pci/sgiioc4.c	Tue Oct 19 07:54:19 2004
+++ linux/drivers/ide/pci/sgiioc4.c	Fri Oct 22 16:24:59 2004
@@ -382,7 +382,7 @@ sgiioc4_INB(unsigned long port)
 }
 
 /* Creates a dma map for the scatter-gather list entries */
-static void __init
+static void __devinit
 ide_dma_sgiioc4(ide_hwif_t * hwif, unsigned long dma_base)
 {
 	int num_ports = sizeof (ioc4_dma_regs_t);
@@ -607,7 +607,7 @@ sgiioc4_ide_dma_write(ide_drive_t * driv
 	return 0;
 }
 
-static void __init
+static void __devinit
 ide_init_sgiioc4(ide_hwif_t * hwif)
 {
 	hwif->mmio = 2;
@@ -645,7 +645,7 @@ ide_init_sgiioc4(ide_hwif_t * hwif)
 	hwif->INB = &sgiioc4_INB;
 }
 
-static int __init
+static int __devinit
 sgiioc4_ide_setup_pci_device(struct pci_dev *dev, ide_pci_device_t * d)
 {
 	unsigned long base, ctl, dma_base, irqport;
@@ -719,7 +719,7 @@ pciio_endian_t snia_pciio_endian_set(str
 				     *pci_dev, pciio_endian_t device_end,
 				     pciio_endian_t desired_end);
 
-static unsigned int __init
+static unsigned int __devinit
 pci_init_sgiioc4(struct pci_dev *dev, ide_pci_device_t * d)
 {
 	unsigned int class_rev;
@@ -784,13 +784,13 @@ static struct pci_device_id sgiioc4_pci_
 };
 MODULE_DEVICE_TABLE(pci, sgiioc4_pci_tbl);
 
-static struct pci_driver driver = {
+static struct pci_driver __devinitdata driver = {
 	.name = "SGI-IOC4_IDE",
 	.id_table = sgiioc4_pci_tbl,
 	.probe = sgiioc4_init_one,
 };
 
-static int
+static int __devinit
 sgiioc4_ide_init(void)
 {
 	return ide_pci_register_driver(&driver);

