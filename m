From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 04 Mar 2008 23:34:57 +0000
Subject: [PATCH] ia64: use dev_printk in video quirk
Message-Id: <200803041634.57370.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Convert quirk printks to dev_printk().

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: linux-mm/arch/ia64/pci/fixup.c
=================================--- linux-mm.orig/arch/ia64/pci/fixup.c	2008-01-18 12:39:53.000000000 -0700
+++ linux-mm/arch/ia64/pci/fixup.c	2008-01-18 12:43:52.000000000 -0700
@@ -63,7 +63,7 @@
 	pci_read_config_word(pdev, PCI_COMMAND, &config);
 	if (config & (PCI_COMMAND_IO | PCI_COMMAND_MEMORY)) {
 		pdev->resource[PCI_ROM_RESOURCE].flags |= IORESOURCE_ROM_SHADOW;
-		printk(KERN_DEBUG "Boot video device is %s\n", pci_name(pdev));
+		dev_printk(KERN_DEBUG, &pdev->dev, "Boot video device\n");
 	}
 }
 DECLARE_PCI_FIXUP_HEADER(PCI_ANY_ID, PCI_ANY_ID, pci_fixup_video);
