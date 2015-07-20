From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 20 Jul 2015 12:01:16 +0000
Subject: [PATCH part3 v12 08/10] PCI: Introduce common pci_domain_nr() and remove platform specific code
Message-Id: <1437393678-4077-9-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1437393678-4077-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1437393678-4077-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, dja@axtens.net, linux-xtensa@linux-xtensa.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, linux-am33-list@redhat.com, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Now pci_host_bridge holds the domain number, we could
introduce common pci_domain_nr(), and remove platform specific code.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/alpha/include/asm/pci.h      |    2 --
 arch/ia64/include/asm/pci.h       |    1 -
 arch/microblaze/include/asm/pci.h |    2 --
 arch/microblaze/pci/pci-common.c  |   11 -----------
 arch/mips/include/asm/pci.h       |    2 --
 arch/powerpc/include/asm/pci.h    |    2 --
 arch/powerpc/kernel/pci-common.c  |   11 -----------
 arch/s390/include/asm/pci.h       |    1 -
 arch/s390/pci/pci.c               |    6 ------
 arch/sh/include/asm/pci.h         |    2 --
 arch/sparc/include/asm/pci_64.h   |    1 -
 arch/sparc/kernel/pci.c           |   17 -----------------
 arch/tile/include/asm/pci.h       |    2 --
 arch/x86/include/asm/pci.h        |    6 ------
 drivers/pci/pci.c                 |    8 ++++++++
 include/linux/pci.h               |    7 +------
 16 files changed, 9 insertions(+), 72 deletions(-)

diff --git a/arch/alpha/include/asm/pci.h b/arch/alpha/include/asm/pci.h
index 98f2eee..1f50c81 100644
--- a/arch/alpha/include/asm/pci.h
+++ b/arch/alpha/include/asm/pci.h
@@ -79,8 +79,6 @@ static inline int pci_get_legacy_ide_irq(struct pci_dev *dev, int channel)
 	return channel ? 15 : 14;
 }
 
-#define pci_domain_nr(bus) ((struct pci_controller *)(bus)->sysdata)->index
-
 static inline int pci_proc_domain(struct pci_bus *bus)
 {
 	struct pci_controller *hose = bus->sysdata;
diff --git a/arch/ia64/include/asm/pci.h b/arch/ia64/include/asm/pci.h
index 36d2c1e..ba6c40a 100644
--- a/arch/ia64/include/asm/pci.h
+++ b/arch/ia64/include/asm/pci.h
@@ -80,7 +80,6 @@ struct pci_controller {
 
 
 #define PCI_CONTROLLER(busdev) ((struct pci_controller *) busdev->sysdata)
-#define pci_domain_nr(busdev)    (PCI_CONTROLLER(busdev)->segment)
 
 extern struct pci_ops pci_root_ops;
 
diff --git a/arch/microblaze/include/asm/pci.h b/arch/microblaze/include/asm/pci.h
index dc9eb66..a452163 100644
--- a/arch/microblaze/include/asm/pci.h
+++ b/arch/microblaze/include/asm/pci.h
@@ -42,8 +42,6 @@
  */
 #define pcibios_assign_all_busses()	0
 
-extern int pci_domain_nr(struct pci_bus *bus);
-
 /* Decide whether to display the domain number in /proc */
 extern int pci_proc_domain(struct pci_bus *bus);
 
diff --git a/arch/microblaze/pci/pci-common.c b/arch/microblaze/pci/pci-common.c
index d232c8a..6f64908 100644
--- a/arch/microblaze/pci/pci-common.c
+++ b/arch/microblaze/pci/pci-common.c
@@ -123,17 +123,6 @@ unsigned long pci_address_to_pio(phys_addr_t address)
 }
 EXPORT_SYMBOL_GPL(pci_address_to_pio);
 
-/*
- * Return the domain number for this bus.
- */
-int pci_domain_nr(struct pci_bus *bus)
-{
-	struct pci_controller *hose = pci_bus_to_host(bus);
-
-	return hose->global_number;
-}
-EXPORT_SYMBOL(pci_domain_nr);
-
 /* This routine is meant to be used early during boot, when the
  * PCI bus numbers have not yet been assigned, and you need to
  * issue PCI config cycles to an OF device.
diff --git a/arch/mips/include/asm/pci.h b/arch/mips/include/asm/pci.h
index 98c31e5..8757775 100644
--- a/arch/mips/include/asm/pci.h
+++ b/arch/mips/include/asm/pci.h
@@ -114,8 +114,6 @@ struct pci_dev;
 extern unsigned int PCI_DMA_BUS_IS_PHYS;
 
 #ifdef CONFIG_PCI_DOMAINS
-#define pci_domain_nr(bus) ((struct pci_controller *)(bus)->sysdata)->index
-
 static inline int pci_proc_domain(struct pci_bus *bus)
 {
 	struct pci_controller *hose = bus->sysdata;
diff --git a/arch/powerpc/include/asm/pci.h b/arch/powerpc/include/asm/pci.h
index 3453bd8..f83b8c8 100644
--- a/arch/powerpc/include/asm/pci.h
+++ b/arch/powerpc/include/asm/pci.h
@@ -73,8 +73,6 @@ extern struct dma_map_ops *get_pci_dma_ops(void);
 
 #endif /* CONFIG_PPC64 */
 
-extern int pci_domain_nr(struct pci_bus *bus);
-
 /* Decide whether to display the domain number in /proc */
 extern int pci_proc_domain(struct pci_bus *bus);
 
diff --git a/arch/powerpc/kernel/pci-common.c b/arch/powerpc/kernel/pci-common.c
index 3e398c8..42928a0 100644
--- a/arch/powerpc/kernel/pci-common.c
+++ b/arch/powerpc/kernel/pci-common.c
@@ -196,17 +196,6 @@ unsigned long pci_address_to_pio(phys_addr_t address)
 }
 EXPORT_SYMBOL_GPL(pci_address_to_pio);
 
-/*
- * Return the domain number for this bus.
- */
-int pci_domain_nr(struct pci_bus *bus)
-{
-	struct pci_controller *hose = pci_bus_to_host(bus);
-
-	return hose->global_number;
-}
-EXPORT_SYMBOL(pci_domain_nr);
-
 /* This routine is meant to be used early during boot, when the
  * PCI bus numbers have not yet been assigned, and you need to
  * issue PCI config cycles to an OF device.
diff --git a/arch/s390/include/asm/pci.h b/arch/s390/include/asm/pci.h
index a648338..fe605b5 100644
--- a/arch/s390/include/asm/pci.h
+++ b/arch/s390/include/asm/pci.h
@@ -20,7 +20,6 @@
 
 void __iomem *pci_iomap(struct pci_dev *, int, unsigned long);
 void pci_iounmap(struct pci_dev *, void __iomem *);
-int pci_domain_nr(struct pci_bus *);
 int pci_proc_domain(struct pci_bus *);
 
 #define ZPCI_BUS_NR			0	/* default bus number */
diff --git a/arch/s390/pci/pci.c b/arch/s390/pci/pci.c
index b9ac2f5..86acba4 100644
--- a/arch/s390/pci/pci.c
+++ b/arch/s390/pci/pci.c
@@ -101,12 +101,6 @@ static struct zpci_dev *get_zdev_by_bus(struct pci_bus *bus)
 	return (bus && bus->sysdata) ? (struct zpci_dev *) bus->sysdata : NULL;
 }
 
-int pci_domain_nr(struct pci_bus *bus)
-{
-	return ((struct zpci_dev *) bus->sysdata)->domain;
-}
-EXPORT_SYMBOL_GPL(pci_domain_nr);
-
 int pci_proc_domain(struct pci_bus *bus)
 {
 	return pci_domain_nr(bus);
diff --git a/arch/sh/include/asm/pci.h b/arch/sh/include/asm/pci.h
index e343dbd..9d44611 100644
--- a/arch/sh/include/asm/pci.h
+++ b/arch/sh/include/asm/pci.h
@@ -91,8 +91,6 @@ extern void pcibios_set_master(struct pci_dev *dev);
 /* Board-specific fixup routines. */
 int pcibios_map_platform_irq(const struct pci_dev *dev, u8 slot, u8 pin);
 
-#define pci_domain_nr(bus) ((struct pci_channel *)(bus)->sysdata)->index
-
 static inline int pci_proc_domain(struct pci_bus *bus)
 {
 	struct pci_channel *hose = bus->sysdata;
diff --git a/arch/sparc/include/asm/pci_64.h b/arch/sparc/include/asm/pci_64.h
index 022d160..229b4f6 100644
--- a/arch/sparc/include/asm/pci_64.h
+++ b/arch/sparc/include/asm/pci_64.h
@@ -33,7 +33,6 @@
 
 /* Return the index of the PCI controller for device PDEV. */
 
-int pci_domain_nr(struct pci_bus *bus);
 static inline int pci_proc_domain(struct pci_bus *bus)
 {
 	return 1;
diff --git a/arch/sparc/kernel/pci.c b/arch/sparc/kernel/pci.c
index 1e957de..79c6941 100644
--- a/arch/sparc/kernel/pci.c
+++ b/arch/sparc/kernel/pci.c
@@ -886,23 +886,6 @@ int pcibus_to_node(struct pci_bus *pbus)
 EXPORT_SYMBOL(pcibus_to_node);
 #endif
 
-/* Return the domain number for this pci bus */
-
-int pci_domain_nr(struct pci_bus *pbus)
-{
-	struct pci_pbm_info *pbm = pbus->sysdata;
-	int ret;
-
-	if (!pbm) {
-		ret = -ENXIO;
-	} else {
-		ret = pbm->index;
-	}
-
-	return ret;
-}
-EXPORT_SYMBOL(pci_domain_nr);
-
 #ifdef CONFIG_PCI_MSI
 int arch_setup_msi_irq(struct pci_dev *pdev, struct msi_desc *desc)
 {
diff --git a/arch/tile/include/asm/pci.h b/arch/tile/include/asm/pci.h
index dfedd7a..23a726e 100644
--- a/arch/tile/include/asm/pci.h
+++ b/arch/tile/include/asm/pci.h
@@ -199,8 +199,6 @@ int __init pcibios_init(void);
 
 void pcibios_fixup_bus(struct pci_bus *bus);
 
-#define pci_domain_nr(bus) (((struct pci_controller *)(bus)->sysdata)->index)
-
 /*
  * This decides whether to display the domain number in /proc.
  */
diff --git a/arch/x86/include/asm/pci.h b/arch/x86/include/asm/pci.h
index 4625943..1ff7869 100644
--- a/arch/x86/include/asm/pci.h
+++ b/arch/x86/include/asm/pci.h
@@ -29,12 +29,6 @@ extern int noioapicreroute;
 #ifdef CONFIG_PCI
 
 #ifdef CONFIG_PCI_DOMAINS
-static inline int pci_domain_nr(struct pci_bus *bus)
-{
-	struct pci_sysdata *sd = bus->sysdata;
-	return sd->domain;
-}
-
 static inline int pci_proc_domain(struct pci_bus *bus)
 {
 	return pci_domain_nr(bus);
diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
index 79d01e4..0074420 100644
--- a/drivers/pci/pci.c
+++ b/drivers/pci/pci.c
@@ -4476,6 +4476,14 @@ static void pci_no_domains(void)
 }
 
 #ifdef CONFIG_PCI_DOMAINS
+int pci_domain_nr(struct pci_bus *bus)
+{
+	struct pci_host_bridge *host = pci_find_host_bridge(bus);
+
+	return host->domain;
+}
+EXPORT_SYMBOL(pci_domain_nr);
+
 #ifdef CONFIG_PCI_DOMAINS_GENERIC
 static atomic_t __domain_nr = ATOMIC_INIT(-1);
 
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 4524592..6b4789c 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1319,6 +1319,7 @@ void pci_cfg_access_unlock(struct pci_dev *dev);
  */
 #ifdef CONFIG_PCI_DOMAINS
 extern int pci_domains_supported;
+int pci_domain_nr(struct pci_bus *bus);
 #else
 enum { pci_domains_supported = 0 };
 static inline int pci_domain_nr(struct pci_bus *bus) { return 0; }
@@ -1330,12 +1331,6 @@ static inline int pci_proc_domain(struct pci_bus *bus) { return 0; }
  * architecture does not need custom management of PCI
  * domains then this implementation will be used
  */
-#ifdef CONFIG_PCI_DOMAINS_GENERIC
-static inline int pci_domain_nr(struct pci_bus *bus)
-{
-	return bus->domain_nr;
-}
-#endif
 
 /* some architectures require additional setup to direct VGA traffic */
 typedef int (*arch_set_vga_state_t)(struct pci_dev *pdev, bool decode,
-- 
1.7.1

