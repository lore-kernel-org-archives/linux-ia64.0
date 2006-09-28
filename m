From: <eiichiro.oiwa.nm@hitachi.com>
Date: Thu, 28 Sep 2006 04:55:47 +0000
Subject: [PATCH 2.6.18] PCI: Turn pci_fixup_video into generic for embedded
Message-Id: <XNM1$9$0$4$$3$3$7$A$9002686U451b55cd@hitachi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@osdl.org, tony.luck@intel.com, greg@kroah.com, Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Jesse Barnes <jesse.barnes@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

pci_fixup_video turns into generic code because there are many platforms need this fixup
for embedded VGA as well as x86. The Video BIOS integrates into System BIOS on a machine
has embedded VGA although embedded VGA generally don't have PCI ROM. As a result,
embedded VGA need the way that the sysfs rom points to the Video BIOS of System
RAM (0xC0000). PCI-to-PCI Bridge Architecture specification describes the condition whether
or not PCI ROM forwards VGA compatible memory address. fixup_video suits this specification.
Although the Video ROM generally implements in x86 code regardless of platform, some
application such as X Window System can run this code by dosemu86. Therefore,
pci_fixup_video should turn into generic code.


Signed-off-by: Eiichiro Oiwa <eiichiro.oiwa.nm@hitachi.com>
---

diff -dupNr linux-2.6.18.orig/arch/i386/pci/fixup.c linux-2.6.18/arch/i386/pci/fixup.c
--- linux-2.6.18.orig/arch/i386/pci/fixup.c	2006-09-20 12:42:06.000000000 +0900
+++ linux-2.6.18/arch/i386/pci/fixup.c	2006-09-27 14:18:55.000000000 +0900
@@ -343,51 +343,6 @@ DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_IN
 DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL,	PCI_DEVICE_ID_INTEL_MCH_PC1,	pcie_rootport_aspm_quirk );
 
 /*
- * Fixup to mark boot BIOS video selected by BIOS before it changes
- *
- * From information provided by "Jon Smirl" <jonsmirl@gmail.com>
- *
- * The standard boot ROM sequence for an x86 machine uses the BIOS
- * to select an initial video card for boot display. This boot video 
- * card will have it's BIOS copied to C0000 in system RAM. 
- * IORESOURCE_ROM_SHADOW is used to associate the boot video
- * card with this copy. On laptops this copy has to be used since
- * the main ROM may be compressed or combined with another image.
- * See pci_map_rom() for use of this flag. IORESOURCE_ROM_SHADOW
- * is marked here since the boot video device will be the only enabled
- * video device at this point.
- */
-
-static void __devinit pci_fixup_video(struct pci_dev *pdev)
-{
-	struct pci_dev *bridge;
-	struct pci_bus *bus;
-	u16 config;
-
-	if ((pdev->class >> 8) != PCI_CLASS_DISPLAY_VGA)
-		return;
-
-	/* Is VGA routed to us? */
-	bus = pdev->bus;
-	while (bus) {
-		bridge = bus->self;
-		if (bridge) {
-			pci_read_config_word(bridge, PCI_BRIDGE_CONTROL,
-						&config);
-			if (!(config & PCI_BRIDGE_CTL_VGA))
-				return;
-		}
-		bus = bus->parent;
-	}
-	pci_read_config_word(pdev, PCI_COMMAND, &config);
-	if (config & (PCI_COMMAND_IO | PCI_COMMAND_MEMORY)) {
-		pdev->resource[PCI_ROM_RESOURCE].flags |= IORESOURCE_ROM_SHADOW;
-		printk(KERN_DEBUG "Boot video device is %s\n", pci_name(pdev));
-	}
-}
-DECLARE_PCI_FIXUP_HEADER(PCI_ANY_ID, PCI_ANY_ID, pci_fixup_video);
-
-/*
  * Some Toshiba laptops need extra code to enable their TI TSB43AB22/A.
  *
  * We pretend to bring them out of full D3 state, and restore the proper
diff -dupNr linux-2.6.18.orig/drivers/pci/quirks.c linux-2.6.18/drivers/pci/quirks.c
--- linux-2.6.18.orig/drivers/pci/quirks.c	2006-09-20 12:42:06.000000000 +0900
+++ linux-2.6.18/drivers/pci/quirks.c	2006-09-27 14:46:40.000000000 +0900
@@ -1590,6 +1590,51 @@ static void __devinit fixup_rev1_53c810(
 }
 DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_NCR, PCI_DEVICE_ID_NCR_53C810, fixup_rev1_53c810);
 
+/*
+ * Fixup to mark boot BIOS video selected by BIOS before it changes
+ *
+ * From information provided by "Jon Smirl" <jonsmirl@gmail.com>
+ *
+ * The standard boot ROM sequence for an x86 machine uses the BIOS
+ * to select an initial video card for boot display. This boot video 
+ * card will have it's BIOS copied to C0000 in system RAM. 
+ * IORESOURCE_ROM_SHADOW is used to associate the boot video
+ * card with this copy. On laptops this copy has to be used since
+ * the main ROM may be compressed or combined with another image.
+ * See pci_map_rom() for use of this flag. IORESOURCE_ROM_SHADOW
+ * is marked here since the boot video device will be the only enabled
+ * video device at this point.
+ */
+
+static void __devinit fixup_video(struct pci_dev *pdev)
+{
+	struct pci_dev *bridge;
+	struct pci_bus *bus;
+	u16 config;
+
+	if ((pdev->class >> 8) != PCI_CLASS_DISPLAY_VGA)
+		return;
+
+	/* Is VGA routed to us? */
+	bus = pdev->bus;
+	while (bus) {
+		bridge = bus->self;
+		if (bridge) {
+			pci_read_config_word(bridge, PCI_BRIDGE_CONTROL,
+						&config);
+			if (!(config & PCI_BRIDGE_CTL_VGA))
+				return;
+		}
+		bus = bus->parent;
+	}
+	pci_read_config_word(pdev, PCI_COMMAND, &config);
+	if (config & (PCI_COMMAND_IO | PCI_COMMAND_MEMORY)) {
+		pdev->resource[PCI_ROM_RESOURCE].flags |= IORESOURCE_ROM_SHADOW;
+		printk(KERN_DEBUG "Boot video device is %s\n", pci_name(pdev));
+	}
+}
+DECLARE_PCI_FIXUP_HEADER(PCI_ANY_ID, PCI_ANY_ID, fixup_video);
+
 
 static void pci_do_fixups(struct pci_dev *dev, struct pci_fixup *f, struct pci_fixup *end)
 {
diff -dupNr linux-2.6.18.orig/drivers/pci/rom.c linux-2.6.18/drivers/pci/rom.c
--- linux-2.6.18.orig/drivers/pci/rom.c	2006-09-20 12:42:06.000000000 +0900
+++ linux-2.6.18/drivers/pci/rom.c	2006-09-28 12:30:24.000000000 +0900
@@ -71,7 +71,10 @@ void __iomem *pci_map_rom(struct pci_dev
 	void __iomem *image;
 	int last_image;
 
-	/* IORESOURCE_ROM_SHADOW only set on x86 */
+	/*
+	 * IORESOURCE_ROM_SHADOW set if the VGA enable bit of the Bridge Control
+	 * register is set for embedded VGA.
+	 */
 	if (res->flags & IORESOURCE_ROM_SHADOW) {
 		/* primary video rom always starts here */
 		start = (loff_t)0xC0000;
