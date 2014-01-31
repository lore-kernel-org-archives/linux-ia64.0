From: Sander Eikelenboom <linux@eikelenboom.it>
Date: Fri, 31 Jan 2014 09:28:23 +0000
Subject: [PATCH v2] Setting the IORESOURCE_ROM_SHADOW flag on a VGA card other than the primary prevents it f
Message-Id: <1391160503-11122-2-git-send-email-linux@eikelenboom.it>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140130000831.GJ16825@google.com>
 <1391160503-11122-1-git-send-email-linux@eikelenboom.it>
In-Reply-To: <1391160503-11122-1-git-send-email-linux@eikelenboom.it>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>, Tony Luck <tony.luck@intel.com>, Dave Airlie <airlied@redhat.com>, Eiichiro Oiwa <eiichiro.oiwa.nm@hitachi.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Sander Eikelenboom <linux@eikelenboom.it>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel @ vger . kernel . org" <linux-kernel@vger.kernel.org>, "linux-pci @ vger . kernel . org" <linux-pci@vger.kernel.org>, linux-ia64@vger.kernel.org

Fix this by checking if the arch code or vga-arbitration has already
determined the vga_default_device, if so only apply the fix to this
primary video device and let the comment reflect this.

Signed-off-by: Sander Eikelenboom <linux@eikelenboom.it>
---
 arch/ia64/pci/fixup.c |   24 +++++++++++++-----------
 arch/x86/pci/fixup.c  |   18 ++++++++++--------
 2 files changed, 23 insertions(+), 19 deletions(-)

diff --git a/arch/ia64/pci/fixup.c b/arch/ia64/pci/fixup.c
index 5dc969d..7762255 100644
--- a/arch/ia64/pci/fixup.c
+++ b/arch/ia64/pci/fixup.c
@@ -19,9 +19,10 @@
  * IORESOURCE_ROM_SHADOW is used to associate the boot video
  * card with this copy. On laptops this copy has to be used since
  * the main ROM may be compressed or combined with another image.
- * See pci_map_rom() for use of this flag. IORESOURCE_ROM_SHADOW
- * is marked here since the boot video device will be the only enabled
- * video device at this point.
+ * See pci_map_rom() for use of this flag. Before marking the device
+ * with IORESOURCE_ROM_SHADOW check if a vga_default_device is already set
+ * by either arch cde or vga-arbitration, if so only apply the fixup to this
+ * already determined primary video card.
  */
 
 static void pci_fixup_video(struct pci_dev *pdev)
@@ -35,9 +36,6 @@ static void pci_fixup_video(struct pci_dev *pdev)
 		return;
 	/* Maybe, this machine supports legacy memory map. */
 
-	if ((pdev->class >> 8) != PCI_CLASS_DISPLAY_VGA)
-		return;
-
 	/* Is VGA routed to us? */
 	bus = pdev->bus;
 	while (bus) {
@@ -60,10 +58,14 @@ static void pci_fixup_video(struct pci_dev *pdev)
 		}
 		bus = bus->parent;
 	}
-	pci_read_config_word(pdev, PCI_COMMAND, &config);
-	if (config & (PCI_COMMAND_IO | PCI_COMMAND_MEMORY)) {
-		pdev->resource[PCI_ROM_RESOURCE].flags |= IORESOURCE_ROM_SHADOW;
-		dev_printk(KERN_DEBUG, &pdev->dev, "Boot video device\n");
+	if (!vga_default_device() || pdev = vga_default_device()) {
+		pci_read_config_word(pdev, PCI_COMMAND, &config);
+		if (config & (PCI_COMMAND_IO | PCI_COMMAND_MEMORY)) {
+			pdev->resource[PCI_ROM_RESOURCE].flags |= IORESOURCE_ROM_SHADOW;
+			dev_printk(KERN_DEBUG, &pdev->dev, "Boot video device\n");
+			vga_set_default_device(pdev);
+		}
 	}
 }
-DECLARE_PCI_FIXUP_HEADER(PCI_ANY_ID, PCI_ANY_ID, pci_fixup_video);
+DECLARE_PCI_FIXUP_CLASS_FINAL(PCI_ANY_ID, PCI_ANY_ID,
+				PCI_CLASS_DISPLAY_VGA, 8, pci_fixup_video);
diff --git a/arch/x86/pci/fixup.c b/arch/x86/pci/fixup.c
index b046e07..34528a7 100644
--- a/arch/x86/pci/fixup.c
+++ b/arch/x86/pci/fixup.c
@@ -314,9 +314,10 @@ DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL,	PCI_DEVICE_ID_INTEL_MCH_PC1,	pcie_r
  * IORESOURCE_ROM_SHADOW is used to associate the boot video
  * card with this copy. On laptops this copy has to be used since
  * the main ROM may be compressed or combined with another image.
- * See pci_map_rom() for use of this flag. IORESOURCE_ROM_SHADOW
- * is marked here since the boot video device will be the only enabled
- * video device at this point.
+ * See pci_map_rom() for use of this flag. Before marking the device
+ * with IORESOURCE_ROM_SHADOW check if a vga_default_device is already set
+ * by either arch cde or vga-arbitration, if so only apply the fixup to this
+ * already determined primary video card.
  */
 
 static void pci_fixup_video(struct pci_dev *pdev)
@@ -347,12 +348,13 @@ static void pci_fixup_video(struct pci_dev *pdev)
 		}
 		bus = bus->parent;
 	}
-	pci_read_config_word(pdev, PCI_COMMAND, &config);
-	if (config & (PCI_COMMAND_IO | PCI_COMMAND_MEMORY)) {
-		pdev->resource[PCI_ROM_RESOURCE].flags |= IORESOURCE_ROM_SHADOW;
-		dev_printk(KERN_DEBUG, &pdev->dev, "Boot video device\n");
-		if (!vga_default_device())
+	if (!vga_default_device() || pdev = vga_default_device()) {
+		pci_read_config_word(pdev, PCI_COMMAND, &config);
+		if (config & (PCI_COMMAND_IO | PCI_COMMAND_MEMORY)) {
+			pdev->resource[PCI_ROM_RESOURCE].flags |= IORESOURCE_ROM_SHADOW;
+			dev_printk(KERN_DEBUG, &pdev->dev, "Boot video device\n");
 			vga_set_default_device(pdev);
+		}
 	}
 }
 DECLARE_PCI_FIXUP_CLASS_FINAL(PCI_ANY_ID, PCI_ANY_ID,
-- 
1.7.10.4

