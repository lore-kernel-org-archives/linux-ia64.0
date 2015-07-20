From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 20 Jul 2015 12:01:13 +0000
Subject: [PATCH part3 v12 05/10] powerpc/PCI: Rename pcibios_root_bridge_prepare() to pcibios_root_bus_prepar
Message-Id: <1437393678-4077-6-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1437393678-4077-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1437393678-4077-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, dja@axtens.net, linux-xtensa@linux-xtensa.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, linux-am33-list@redhat.com, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Pcibios_root_bridge_prepare() in powerpc set root bus
speed, it's not the preparation for pci host bridge.
For better separation of host bridge and root bus creation,
It's need to rename it to another weak function.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/powerpc/include/asm/machdep.h       |    2 +-
 arch/powerpc/kernel/pci-common.c         |    6 +++---
 arch/powerpc/platforms/pseries/pci.c     |    2 +-
 arch/powerpc/platforms/pseries/pseries.h |    2 +-
 arch/powerpc/platforms/pseries/setup.c   |    2 +-
 drivers/pci/probe.c                      |    9 +++++++++
 6 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/arch/powerpc/include/asm/machdep.h b/arch/powerpc/include/asm/machdep.h
index 952579f..dbd5e8b 100644
--- a/arch/powerpc/include/asm/machdep.h
+++ b/arch/powerpc/include/asm/machdep.h
@@ -100,7 +100,7 @@ struct machdep_calls {
 	/* Called after allocating resources */
 	void		(*pcibios_fixup)(void);
 	void		(*pci_irq_fixup)(struct pci_dev *dev);
-	int		(*pcibios_root_bridge_prepare)(struct pci_host_bridge
+	int		(*pcibios_root_bus_prepare)(struct pci_host_bridge
 				*bridge);
 
 	/* To setup PHBs when using automatic OF platform driver for PCI */
diff --git a/arch/powerpc/kernel/pci-common.c b/arch/powerpc/kernel/pci-common.c
index df7f018..3e398c8 100644
--- a/arch/powerpc/kernel/pci-common.c
+++ b/arch/powerpc/kernel/pci-common.c
@@ -782,10 +782,10 @@ int pci_proc_domain(struct pci_bus *bus)
 	return 1;
 }
 
-int pcibios_root_bridge_prepare(struct pci_host_bridge *bridge)
+int pcibios_root_bus_prepare(struct pci_host_bridge *bridge)
 {
-	if (ppc_md.pcibios_root_bridge_prepare)
-		return ppc_md.pcibios_root_bridge_prepare(bridge);
+	if (ppc_md.pcibios_root_bus_prepare)
+		return ppc_md.pcibios_root_bus_prepare(bridge);
 
 	return 0;
 }
diff --git a/arch/powerpc/platforms/pseries/pci.c b/arch/powerpc/platforms/pseries/pci.c
index fe16a50..885f9ff 100644
--- a/arch/powerpc/platforms/pseries/pci.c
+++ b/arch/powerpc/platforms/pseries/pci.c
@@ -110,7 +110,7 @@ static void fixup_winbond_82c105(struct pci_dev* dev)
 DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_WINBOND, PCI_DEVICE_ID_WINBOND_82C105,
 			 fixup_winbond_82c105);
 
-int pseries_root_bridge_prepare(struct pci_host_bridge *bridge)
+int pseries_root_bus_prepare(struct pci_host_bridge *bridge)
 {
 	struct device_node *dn, *pdn;
 	struct pci_bus *bus;
diff --git a/arch/powerpc/platforms/pseries/pseries.h b/arch/powerpc/platforms/pseries/pseries.h
index 8411c27..41310dc 100644
--- a/arch/powerpc/platforms/pseries/pseries.h
+++ b/arch/powerpc/platforms/pseries/pseries.h
@@ -75,7 +75,7 @@ static inline int dlpar_memory(struct pseries_hp_errorlog *hp_elog)
 
 /* PCI root bridge prepare function override for pseries */
 struct pci_host_bridge;
-int pseries_root_bridge_prepare(struct pci_host_bridge *bridge);
+int pseries_root_bus_prepare(struct pci_host_bridge *bridge);
 
 extern struct pci_controller_ops pseries_pci_controller_ops;
 
diff --git a/arch/powerpc/platforms/pseries/setup.c b/arch/powerpc/platforms/pseries/setup.c
index df6a704..2815309 100644
--- a/arch/powerpc/platforms/pseries/setup.c
+++ b/arch/powerpc/platforms/pseries/setup.c
@@ -537,7 +537,7 @@ static void __init pSeries_setup_arch(void)
 		ppc_md.enable_pmcs = power4_enable_pmcs;
 	}
 
-	ppc_md.pcibios_root_bridge_prepare = pseries_root_bridge_prepare;
+	ppc_md.pcibios_root_bus_prepare = pseries_root_bus_prepare;
 
 	if (firmware_has_feature(FW_FEATURE_SET_MODE)) {
 		long rc;
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index b49deb8..0eba126 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1919,6 +1919,11 @@ int __weak pcibios_root_bridge_prepare(struct pci_host_bridge *bridge)
 	return 0;
 }
 
+int __weak pcibios_root_bus_prepare(struct pci_host_bridge *bridge)
+{
+	return 0;
+}
+
 void __weak pcibios_add_bus(struct pci_bus *bus)
 {
 }
@@ -1984,6 +1989,10 @@ struct pci_bus *pci_create_root_bus(struct device *parent, int domain,
 	b->dev.class = &pcibus_class;
 	b->dev.parent = b->bridge;
 	dev_set_name(&b->dev, "%04x:%02x", pci_domain_nr(b), bus);
+	error = pcibios_root_bus_prepare(bridge);
+	if (error)
+		goto class_dev_reg_err;
+
 	error = device_register(&b->dev);
 	if (error)
 		goto class_dev_reg_err;
-- 
1.7.1

