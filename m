From: Thierry Reding <thierry.reding@avionic-design.de>
Date: Mon, 17 Sep 2012 11:22:53 +0000
Subject: [PATCH v2 1/2] PCI: Keep pci_fixup_irqs() around after init
Message-Id: <1347880974-13615-1-git-send-email-thierry.reding@avionic-design.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

Remove the __init annotations in order to keep pci_fixup_irqs() around
after init (e.g. for hotplug). This requires the same change for the
implementation of pcibios_update_irq() on all architectures. While at
it, all __devinit annotations are removed as well, since they will be
useless now that HOTPLUG is always on.

Signed-off-by: Thierry Reding <thierry.reding@avionic-design.de>
---
Changes in v2:
- remove __init and __devinit annotations altogether

 arch/alpha/kernel/pci.c      | 2 +-
 arch/arm/kernel/bios32.c     | 2 +-
 arch/ia64/pci/pci.c          | 2 +-
 arch/mips/pci/pci.c          | 2 +-
 arch/sh/drivers/pci/pci.c    | 2 +-
 arch/sparc/kernel/leon_pci.c | 2 +-
 arch/tile/kernel/pci.c       | 2 +-
 arch/tile/kernel/pci_gx.c    | 2 +-
 arch/unicore32/kernel/pci.c  | 2 +-
 arch/x86/pci/visws.c         | 2 +-
 arch/xtensa/kernel/pci.c     | 2 +-
 drivers/pci/setup-irq.c      | 4 ++--
 12 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/arch/alpha/kernel/pci.c b/arch/alpha/kernel/pci.c
index 9816d5a..920392f 100644
--- a/arch/alpha/kernel/pci.c
+++ b/arch/alpha/kernel/pci.c
@@ -256,7 +256,7 @@ pcibios_fixup_bus(struct pci_bus *bus)
 	}
 }
 
-void __init
+void
 pcibios_update_irq(struct pci_dev *dev, int irq)
 {
 	pci_write_config_byte(dev, PCI_INTERRUPT_LINE, irq);
diff --git a/arch/arm/kernel/bios32.c b/arch/arm/kernel/bios32.c
index 2b2f25e..0174fe6 100644
--- a/arch/arm/kernel/bios32.c
+++ b/arch/arm/kernel/bios32.c
@@ -272,7 +272,7 @@ DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_ITE, PCI_DEVICE_ID_ITE_8152, pci_fixup_it
 
 
 
-void __devinit pcibios_update_irq(struct pci_dev *dev, int irq)
+void pcibios_update_irq(struct pci_dev *dev, int irq)
 {
 	if (debug_pci)
 		printk("PCI: Assigning IRQ %02d to %s\n", irq, pci_name(dev));
diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 81acc7a..27db6a8 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -461,7 +461,7 @@ void pcibios_set_master (struct pci_dev *dev)
 	/* No special bus mastering setup handling */
 }
 
-void __devinit
+void
 pcibios_update_irq (struct pci_dev *dev, int irq)
 {
 	pci_write_config_byte(dev, PCI_INTERRUPT_LINE, irq);
diff --git a/arch/mips/pci/pci.c b/arch/mips/pci/pci.c
index 6903568..64f0419 100644
--- a/arch/mips/pci/pci.c
+++ b/arch/mips/pci/pci.c
@@ -313,7 +313,7 @@ void __devinit pcibios_fixup_bus(struct pci_bus *bus)
 	}
 }
 
-void __init
+void
 pcibios_update_irq(struct pci_dev *dev, int irq)
 {
 	pci_write_config_byte(dev, PCI_INTERRUPT_LINE, irq);
diff --git a/arch/sh/drivers/pci/pci.c b/arch/sh/drivers/pci/pci.c
index 40db2d0..1bd3e08 100644
--- a/arch/sh/drivers/pci/pci.c
+++ b/arch/sh/drivers/pci/pci.c
@@ -192,7 +192,7 @@ int pcibios_enable_device(struct pci_dev *dev, int mask)
 	return pci_enable_resources(dev, mask);
 }
 
-void __init pcibios_update_irq(struct pci_dev *dev, int irq)
+void pcibios_update_irq(struct pci_dev *dev, int irq)
 {
 	pci_write_config_byte(dev, PCI_INTERRUPT_LINE, irq);
 }
diff --git a/arch/sparc/kernel/leon_pci.c b/arch/sparc/kernel/leon_pci.c
index 21dcda7..404621b 100644
--- a/arch/sparc/kernel/leon_pci.c
+++ b/arch/sparc/kernel/leon_pci.c
@@ -102,7 +102,7 @@ int pcibios_enable_device(struct pci_dev *dev, int mask)
 	return pci_enable_resources(dev, mask);
 }
 
-void __devinit pcibios_update_irq(struct pci_dev *dev, int irq)
+void pcibios_update_irq(struct pci_dev *dev, int irq)
 {
 #ifdef CONFIG_PCI_DEBUG
 	printk(KERN_DEBUG "LEONPCI: Assigning IRQ %02d to %s\n", irq,
diff --git a/arch/tile/kernel/pci.c b/arch/tile/kernel/pci.c
index 33c1086..6245bba 100644
--- a/arch/tile/kernel/pci.c
+++ b/arch/tile/kernel/pci.c
@@ -406,7 +406,7 @@ void pcibios_set_master(struct pci_dev *dev)
 /*
  * This is called from the generic Linux layer.
  */
-void __devinit pcibios_update_irq(struct pci_dev *dev, int irq)
+void pcibios_update_irq(struct pci_dev *dev, int irq)
 {
 	pci_write_config_byte(dev, PCI_INTERRUPT_LINE, irq);
 }
diff --git a/arch/tile/kernel/pci_gx.c b/arch/tile/kernel/pci_gx.c
index 0e213e3..5faad0b 100644
--- a/arch/tile/kernel/pci_gx.c
+++ b/arch/tile/kernel/pci_gx.c
@@ -1036,7 +1036,7 @@ char __devinit *pcibios_setup(char *str)
 /*
  * This is called from the generic Linux layer.
  */
-void __devinit pcibios_update_irq(struct pci_dev *dev, int irq)
+void pcibios_update_irq(struct pci_dev *dev, int irq)
 {
 	pci_write_config_byte(dev, PCI_INTERRUPT_LINE, irq);
 }
diff --git a/arch/unicore32/kernel/pci.c b/arch/unicore32/kernel/pci.c
index 46cb6c9..c07ecc5 100644
--- a/arch/unicore32/kernel/pci.c
+++ b/arch/unicore32/kernel/pci.c
@@ -154,7 +154,7 @@ void __init puv3_pci_adjust_zones(unsigned long *zone_size,
 	zhole_size[0] = 0;
 }
 
-void __devinit pcibios_update_irq(struct pci_dev *dev, int irq)
+void pcibios_update_irq(struct pci_dev *dev, int irq)
 {
 	if (debug_pci)
 		printk(KERN_DEBUG "PCI: Assigning IRQ %02d to %s\n",
diff --git a/arch/x86/pci/visws.c b/arch/x86/pci/visws.c
index 6f2f8ee..9d736e7 100644
--- a/arch/x86/pci/visws.c
+++ b/arch/x86/pci/visws.c
@@ -62,7 +62,7 @@ out:
 	return irq;
 }
 
-void __init pcibios_update_irq(struct pci_dev *dev, int irq)
+void pcibios_update_irq(struct pci_dev *dev, int irq)
 {
 	pci_write_config_byte(dev, PCI_INTERRUPT_LINE, irq);
 }
diff --git a/arch/xtensa/kernel/pci.c b/arch/xtensa/kernel/pci.c
index 69759e9..6f9b40c 100644
--- a/arch/xtensa/kernel/pci.c
+++ b/arch/xtensa/kernel/pci.c
@@ -212,7 +212,7 @@ void pcibios_set_master(struct pci_dev *dev)
 
 /* the next one is stolen from the alpha port... */
 
-void __init
+void
 pcibios_update_irq(struct pci_dev *dev, int irq)
 {
 	pci_write_config_byte(dev, PCI_INTERRUPT_LINE, irq);
diff --git a/drivers/pci/setup-irq.c b/drivers/pci/setup-irq.c
index eb219a1..270ae7b 100644
--- a/drivers/pci/setup-irq.c
+++ b/drivers/pci/setup-irq.c
@@ -18,7 +18,7 @@
 #include <linux/cache.h>
 
 
-static void __init
+static void
 pdev_fixup_irq(struct pci_dev *dev,
 	       u8 (*swizzle)(struct pci_dev *, u8 *),
 	       int (*map_irq)(const struct pci_dev *, u8, u8))
@@ -54,7 +54,7 @@ pdev_fixup_irq(struct pci_dev *dev,
 	pcibios_update_irq(dev, irq);
 }
 
-void __init
+void
 pci_fixup_irqs(u8 (*swizzle)(struct pci_dev *, u8 *),
 	       int (*map_irq)(const struct pci_dev *, u8, u8))
 {
-- 
1.7.12

