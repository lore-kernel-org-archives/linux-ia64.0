From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 26 Feb 2015 01:29:46 +0000
Subject: [PATCH v3 29/30] PCI: Remove platform specific pci_domain_nr()
Message-Id: <1424914187-21027-30-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424914187-21027-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1424914187-21027-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Now pci_host_bridge holds the domain number,
so we could eliminate all platform specific
pci_domain_nr().

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/alpha/include/asm/pci.h     |    2 --
 arch/ia64/include/asm/pci.h      |    1 -
 arch/microblaze/pci/pci-common.c |   11 -----------
 arch/mips/include/asm/pci.h      |    2 --
 arch/powerpc/kernel/pci-common.c |   11 -----------
 arch/s390/pci/pci.c              |    6 ------
 arch/sh/include/asm/pci.h        |    2 --
 arch/sparc/kernel/pci.c          |   17 -----------------
 arch/tile/include/asm/pci.h      |    2 --
 arch/x86/include/asm/pci.h       |    6 ------
 drivers/pci/pci.c                |    8 ++++++++
 include/linux/pci.h              |    7 ++-----
 12 files changed, 10 insertions(+), 65 deletions(-)

diff --git a/arch/alpha/include/asm/pci.h b/arch/alpha/include/asm/pci.h
index f7f680f..63a9a1e 100644
--- a/arch/alpha/include/asm/pci.h
+++ b/arch/alpha/include/asm/pci.h
@@ -95,8 +95,6 @@ static inline int pci_get_legacy_ide_irq(struct pci_dev *dev, int channel)
 	return channel ? 15 : 14;
 }
 
-#define pci_domain_nr(bus) ((struct pci_controller *)(bus)->sysdata)->index
-
 static inline int pci_proc_domain(struct pci_bus *bus)
 {
 	struct pci_controller *hose = bus->sysdata;
diff --git a/arch/ia64/include/asm/pci.h b/arch/ia64/include/asm/pci.h
index 52af5ed..1dcea49 100644
--- a/arch/ia64/include/asm/pci.h
+++ b/arch/ia64/include/asm/pci.h
@@ -99,7 +99,6 @@ struct pci_controller {
 
 
 #define PCI_CONTROLLER(busdev) ((struct pci_controller *) busdev->sysdata)
-#define pci_domain_nr(busdev)    (PCI_CONTROLLER(busdev)->segment)
 
 extern struct pci_ops pci_root_ops;
 
diff --git a/arch/microblaze/pci/pci-common.c b/arch/microblaze/pci/pci-common.c
index 5c332c0..065e301 100644
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
index 193b4c6..2e4d808 100644
--- a/arch/mips/include/asm/pci.h
+++ b/arch/mips/include/asm/pci.h
@@ -122,8 +122,6 @@ static inline void pci_dma_burst_advice(struct pci_dev *pdev,
 #endif
 
 #ifdef CONFIG_PCI_DOMAINS
-#define pci_domain_nr(bus) ((struct pci_controller *)(bus)->sysdata)->index
-
 static inline int pci_proc_domain(struct pci_bus *bus)
 {
 	struct pci_controller *hose = bus->sysdata;
diff --git a/arch/powerpc/kernel/pci-common.c b/arch/powerpc/kernel/pci-common.c
index 48a6cff..569ac5a 100644
--- a/arch/powerpc/kernel/pci-common.c
+++ b/arch/powerpc/kernel/pci-common.c
@@ -181,17 +181,6 @@ unsigned long pci_address_to_pio(phys_addr_t address)
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
diff --git a/arch/s390/pci/pci.c b/arch/s390/pci/pci.c
index f9c6800..432e2f3 100644
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
index 5b45115..4dc3ad6 100644
--- a/arch/sh/include/asm/pci.h
+++ b/arch/sh/include/asm/pci.h
@@ -109,8 +109,6 @@ static inline void pci_dma_burst_advice(struct pci_dev *pdev,
 /* Board-specific fixup routines. */
 int pcibios_map_platform_irq(const struct pci_dev *dev, u8 slot, u8 pin);
 
-#define pci_domain_nr(bus) ((struct pci_channel *)(bus)->sysdata)->index
-
 static inline int pci_proc_domain(struct pci_bus *bus)
 {
 	struct pci_channel *hose = bus->sysdata;
diff --git a/arch/sparc/kernel/pci.c b/arch/sparc/kernel/pci.c
index 03e7376..deee8c4 100644
--- a/arch/sparc/kernel/pci.c
+++ b/arch/sparc/kernel/pci.c
@@ -903,23 +903,6 @@ int pcibus_to_node(struct pci_bus *pbus)
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
index 4e370a5..4fe0458 100644
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
index 2abac8f..51ada13 100644
--- a/drivers/pci/pci.c
+++ b/drivers/pci/pci.c
@@ -4523,6 +4523,14 @@ int pci_get_new_domain_nr(void)
 	return atomic_inc_return(&__domain_nr);
 }
 
+int pci_domain_nr(struct pci_bus *bus)
+{
+	struct pci_host_bridge *host = find_pci_host_bridge(bus);
+
+	return host->domain;
+}
+EXPORT_SYMBOL(pci_domain_nr);
+
 #ifdef CONFIG_PCI_DOMAINS_GENERIC
 static int pci_assign_domain_nr(struct device *dev)
 {
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 6ac7926..68c09da 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1321,6 +1321,7 @@ void pci_cfg_access_unlock(struct pci_dev *dev);
 #ifdef CONFIG_PCI_DOMAINS
 extern int pci_domains_supported;
 int pci_get_new_domain_nr(void);
+int pci_domain_nr(struct pci_bus *bus);
 #else
 enum { pci_domains_supported = 0 };
 static inline int pci_domain_nr(struct pci_bus *bus) { return 0; }
@@ -1334,15 +1335,11 @@ static inline int pci_get_new_domain_nr(void) { return -ENOSYS; }
  * domains then this implementation will be used
  */
 #ifdef CONFIG_PCI_DOMAINS_GENERIC
-static inline int pci_domain_nr(struct pci_bus *bus)
-{
-	return bus->domain_nr;
-}
 void pci_bus_assign_domain_nr(struct pci_bus *bus, struct device *parent);
 void pci_host_assign_domain_nr(struct pci_host_bridge *host);
 #else
 static inline void pci_bus_assign_domain_nr(struct pci_bus *bus,
-					struct device *parent)
+		                    struct device *parent)
 {
 }
 static inline void pci_host_assign_domain_nr(struct pci_host_bridge *host)
-- 
1.7.1

