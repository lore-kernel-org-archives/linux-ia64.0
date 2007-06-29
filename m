From: John Keller <jpk@sgi.com>
Date: Fri, 29 Jun 2007 17:52:21 +0000
Subject: RESEND: [PATCH] - SN: Correct ROM resource length for BIOS copy
Message-Id: <20070629175221.10106.62977.sendpatchset@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, John Keller <jpk@sgi.com>

On SN systems, when setting the IORESOURCE_ROM_BIOS_COPY resource flag,
the resource length should be set to the actual size of the ROM image
so that a call to pci_map_rom() returns the correct size.

Signed-off-by: John Keller <jpk@sgi.com>
---

Resend #1 - correct format of block comment for pci_get_rom_size()


To avoid duplicate code, the image size calculation loop in
pci_map_rom() has been put into a separate function that both
pci_map_rom() and the SN specific code now call.

 arch/ia64/sn/kernel/io_acpi_init.c |   17 ++----
 arch/ia64/sn/kernel/io_init.c      |   20 ++++++-
 drivers/pci/rom.c                  |   73 ++++++++++++++++-----------
 include/linux/pci.h                |    1 
 4 files changed, 70 insertions(+), 41 deletions(-)


Index: linux-2.6/arch/ia64/sn/kernel/io_acpi_init.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/io_acpi_init.c	2007-06-28 10:35:59.144045279 -0500
+++ linux-2.6/arch/ia64/sn/kernel/io_acpi_init.c	2007-06-28 10:44:38.034721316 -0500
@@ -418,7 +418,7 @@ sn_acpi_slot_fixup(struct pci_dev *dev)
 	void __iomem *addr;
 	struct pcidev_info *pcidev_info = NULL;
 	struct sn_irq_info *sn_irq_info = NULL;
-	size_t size;
+	size_t image_size, size;
 
 	if (sn_acpi_get_pcidev_info(dev, &pcidev_info, &sn_irq_info)) {
 		panic("%s:  Failure obtaining pcidev_info for %s\n",
@@ -428,17 +428,16 @@ sn_acpi_slot_fixup(struct pci_dev *dev)
 	if (pcidev_info->pdi_pio_mapped_addr[PCI_ROM_RESOURCE]) {
 		/*
 		 * A valid ROM image exists and has been shadowed by the
-		 * PROM. Setup the pci_dev ROM resource to point to
-		 * the shadowed copy.
+		 * PROM. Setup the pci_dev ROM resource with the address
+		 * of the shadowed copy, and the actual length of the ROM image.
 		 */
-		size = dev->resource[PCI_ROM_RESOURCE].end -
-				dev->resource[PCI_ROM_RESOURCE].start;
-		addr -		     ioremap(pcidev_info->pdi_pio_mapped_addr[PCI_ROM_RESOURCE],
-			     size);
+		size = pci_resource_len(dev, PCI_ROM_RESOURCE);
+		addr = ioremap(pcidev_info->pdi_pio_mapped_addr[PCI_ROM_RESOURCE],
+			       size);
+		image_size = pci_get_rom_size(addr, size);
 		dev->resource[PCI_ROM_RESOURCE].start = (unsigned long) addr;
 		dev->resource[PCI_ROM_RESOURCE].end -						(unsigned long) addr + size;
+					(unsigned long) addr + image_size - 1;
 		dev->resource[PCI_ROM_RESOURCE].flags |= IORESOURCE_ROM_BIOS_COPY;
 	}
 	sn_pci_fixup_slot(dev, pcidev_info, sn_irq_info);
Index: linux-2.6/arch/ia64/sn/kernel/io_init.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/io_init.c	2007-06-28 10:35:59.144045279 -0500
+++ linux-2.6/arch/ia64/sn/kernel/io_init.c	2007-06-28 10:44:51.712380223 -0500
@@ -259,9 +259,23 @@ sn_io_slot_fixup(struct pci_dev *dev)
 			insert_resource(&ioport_resource, &dev->resource[idx]);
 		else
 			insert_resource(&iomem_resource, &dev->resource[idx]);
-		/* If ROM, mark as shadowed in PROM */
-		if (idx = PCI_ROM_RESOURCE)
-			dev->resource[idx].flags |= IORESOURCE_ROM_BIOS_COPY;
+		/*
+		 * If ROM, set the actual ROM image size, and mark as
+		 * shadowed in PROM.
+		 */
+		if (idx = PCI_ROM_RESOURCE) {
+			size_t image_size;
+			void __iomem *rom;
+
+			rom = ioremap(pci_resource_start(dev, PCI_ROM_RESOURCE),
+				      size + 1);
+			image_size = pci_get_rom_size(rom, size + 1);
+			dev->resource[PCI_ROM_RESOURCE].end +				dev->resource[PCI_ROM_RESOURCE].start +
+				image_size - 1;
+			dev->resource[PCI_ROM_RESOURCE].flags |+						 IORESOURCE_ROM_BIOS_COPY;
+		}
 	}
 	/* Create a pci_window in the pci_controller struct for
 	 * each device resource.
Index: linux-2.6/drivers/pci/rom.c
=================================--- linux-2.6.orig/drivers/pci/rom.c	2007-06-28 10:36:02.956505069 -0500
+++ linux-2.6/drivers/pci/rom.c	2007-06-28 10:45:18.475626403 -0500
@@ -54,6 +54,49 @@ static void pci_disable_rom(struct pci_d
 }
 
 /**
+ * pci_get_rom_size - obtain the actual size of the ROM image
+ * @rom: kernel virtual pointer to image of ROM
+ * @size: size of PCI window
+ *  return: size of actual ROM image
+ *
+ * Determine the actual length of the ROM image.
+ * The PCI window size could be much larger than the
+ * actual image size.
+ */
+size_t pci_get_rom_size(void __iomem *rom, size_t size)
+{
+	void __iomem *image;
+	int last_image;
+
+	image = rom;
+	do {
+		void __iomem *pds;
+		/* Standard PCI ROMs start out with these bytes 55 AA */
+		if (readb(image) != 0x55)
+			break;
+		if (readb(image + 1) != 0xAA)
+			break;
+		/* get the PCI data structure and check its signature */
+		pds = image + readw(image + 24);
+		if (readb(pds) != 'P')
+			break;
+		if (readb(pds + 1) != 'C')
+			break;
+		if (readb(pds + 2) != 'I')
+			break;
+		if (readb(pds + 3) != 'R')
+			break;
+		last_image = readb(pds + 21) & 0x80;
+		/* this length is reliable */
+		image += readw(pds + 16) * 512;
+	} while (!last_image);
+
+	/* never return a size larger than the PCI resource window */
+	/* there are known ROMs that get the size wrong */
+	return min((size_t)(image - rom), size);
+}
+
+/**
  * pci_map_rom - map a PCI ROM to kernel space
  * @pdev: pointer to pci device struct
  * @size: pointer to receive size of pci window over ROM
@@ -68,8 +111,6 @@ void __iomem *pci_map_rom(struct pci_dev
 	struct resource *res = &pdev->resource[PCI_ROM_RESOURCE];
 	loff_t start;
 	void __iomem *rom;
-	void __iomem *image;
-	int last_image;
 
 	/*
 	 * IORESOURCE_ROM_SHADOW set on x86, x86_64 and IA64 supports legacy
@@ -117,33 +158,7 @@ void __iomem *pci_map_rom(struct pci_dev
 	 * size is much larger than the actual size of the ROM.
 	 * True size is important if the ROM is going to be copied.
 	 */
-	image = rom;
-	do {
-		void __iomem *pds;
-		/* Standard PCI ROMs start out with these bytes 55 AA */
-		if (readb(image) != 0x55)
-			break;
-		if (readb(image + 1) != 0xAA)
-			break;
-		/* get the PCI data structure and check its signature */
-		pds = image + readw(image + 24);
-		if (readb(pds) != 'P')
-			break;
-		if (readb(pds + 1) != 'C')
-			break;
-		if (readb(pds + 2) != 'I')
-			break;
-		if (readb(pds + 3) != 'R')
-			break;
-		last_image = readb(pds + 21) & 0x80;
-		/* this length is reliable */
-		image += readw(pds + 16) * 512;
-	} while (!last_image);
-
-	/* never return a size larger than the PCI resource window */
-	/* there are known ROMs that get the size wrong */
-	*size = min((size_t)(image - rom), *size);
-
+	*size = pci_get_rom_size(rom, *size);
 	return rom;
 }
 
Index: linux-2.6/include/linux/pci.h
=================================--- linux-2.6.orig/include/linux/pci.h	2007-06-28 10:36:06.224899250 -0500
+++ linux-2.6/include/linux/pci.h	2007-06-28 10:37:24.226308077 -0500
@@ -560,6 +560,7 @@ void __iomem __must_check *pci_map_rom(s
 void __iomem __must_check *pci_map_rom_copy(struct pci_dev *pdev, size_t *size);
 void pci_unmap_rom(struct pci_dev *pdev, void __iomem *rom);
 void pci_remove_rom(struct pci_dev *pdev);
+size_t pci_get_rom_size(void __iomem *rom, size_t size);
 
 /* Power management related routines */
 int pci_save_state(struct pci_dev *dev);
