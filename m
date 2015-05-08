From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 08 May 2015 07:22:55 +0000
Subject: [PATCH Part3 v11 5/9] powerpc/PCI: Rename pcibios_root_bridge_prepare() to pcibios_root_bus_prepare(
Message-Id: <1431069779-29346-6-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1431069779-29346-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1431069779-29346-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-arm-kernel@lists.infradead.org, Liviu Dudau <liviu@dudau.co.uk>, x86@kernel.org, linux-ia64@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-pci@vger.kernel.org, dja@axtens.net, Arnd Bergmann <arnd@arndb.de>, Yijing Wang <wangyijing@huawei.com>

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
index ef88994..f236660 100644
--- a/arch/powerpc/include/asm/machdep.h
+++ b/arch/powerpc/include/asm/machdep.h
@@ -125,7 +125,7 @@ struct machdep_calls {
 	/* Called after allocating resources */
 	void		(*pcibios_fixup)(void);
 	void		(*pci_irq_fixup)(struct pci_dev *dev);
-	int		(*pcibios_root_bridge_prepare)(struct pci_host_bridge
+	int		(*pcibios_root_bus_prepare)(struct pci_host_bridge
 				*bridge);
 
 	/* To setup PHBs when using automatic OF platform driver for PCI */
diff --git a/arch/powerpc/kernel/pci-common.c b/arch/powerpc/kernel/pci-common.c
index e9506d5..5754367 100644
--- a/arch/powerpc/kernel/pci-common.c
+++ b/arch/powerpc/kernel/pci-common.c
@@ -781,10 +781,10 @@ int pci_proc_domain(struct pci_bus *bus)
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
index 9f9445e..f5f5de6 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1883,6 +1883,11 @@ int __weak pcibios_root_bridge_prepare(struct pci_host_bridge *bridge)
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
@@ -1948,6 +1953,10 @@ struct pci_bus *pci_create_root_bus(struct device *parent, int domain,
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

