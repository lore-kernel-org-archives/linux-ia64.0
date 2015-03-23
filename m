From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 23 Mar 2015 12:40:38 +0000
Subject: [PATCH v7 12/31] powerpc/PCI: Rename pcibios_root_bridge_prepare() to pcibios_set_root_bus_speed()
Message-Id: <1427114457-16687-13-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1427114457-16687-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1427114457-16687-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

pcibios_root_bridge_prepare() in powerpc set
root bus speed, it's not the preparation for
pci host bridge. Rename it for better readability,
and we could move pcibios_root_bridge_prepare()
to pci_create_host_bridge(), in which root bus
is not created. We will clean up these weak functions,
and add pci_host_bridge_ops to do the same thing
in later patch.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/powerpc/include/asm/machdep.h     |    2 +-
 arch/powerpc/kernel/pci-common.c       |    8 +++-----
 arch/powerpc/platforms/pseries/pci.c   |    8 ++++----
 arch/powerpc/platforms/pseries/setup.c |    2 +-
 drivers/pci/probe.c                    |    5 +++++
 5 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/arch/powerpc/include/asm/machdep.h b/arch/powerpc/include/asm/machdep.h
index c8175a3..b811d12 100644
--- a/arch/powerpc/include/asm/machdep.h
+++ b/arch/powerpc/include/asm/machdep.h
@@ -129,7 +129,7 @@ struct machdep_calls {
 	void		(*pcibios_fixup)(void);
 	int		(*pci_probe_mode)(struct pci_bus *);
 	void		(*pci_irq_fixup)(struct pci_dev *dev);
-	int		(*pcibios_root_bridge_prepare)(struct pci_host_bridge
+	void		(*pcibios_set_root_bus_speed)(struct pci_host_bridge
 				*bridge);
 
 	/* To setup PHBs when using automatic OF platform driver for PCI */
diff --git a/arch/powerpc/kernel/pci-common.c b/arch/powerpc/kernel/pci-common.c
index 9913f6c..2c58200 100644
--- a/arch/powerpc/kernel/pci-common.c
+++ b/arch/powerpc/kernel/pci-common.c
@@ -767,12 +767,10 @@ int pci_proc_domain(struct pci_bus *bus)
 	return 1;
 }
 
-int pcibios_root_bridge_prepare(struct pci_host_bridge *bridge)
+void pcibios_set_root_bus_speed(struct pci_host_bridge *bridge)
 {
-	if (ppc_md.pcibios_root_bridge_prepare)
-		return ppc_md.pcibios_root_bridge_prepare(bridge);
-
-	return 0;
+	if (ppc_md.pcibios_set_root_bus_speed)
+		return ppc_md.pcibios_set_root_bus_speed(bridge);
 }
 
 /* This header fixup will do the resource fixup for all devices as they are
diff --git a/arch/powerpc/platforms/pseries/pci.c b/arch/powerpc/platforms/pseries/pci.c
index fe16a50..89ff79c 100644
--- a/arch/powerpc/platforms/pseries/pci.c
+++ b/arch/powerpc/platforms/pseries/pci.c
@@ -110,7 +110,7 @@ static void fixup_winbond_82c105(struct pci_dev* dev)
 DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_WINBOND, PCI_DEVICE_ID_WINBOND_82C105,
 			 fixup_winbond_82c105);
 
-int pseries_root_bridge_prepare(struct pci_host_bridge *bridge)
+void pseries_set_root_bus_speed(struct pci_host_bridge *bridge)
 {
 	struct device_node *dn, *pdn;
 	struct pci_bus *bus;
@@ -121,7 +121,7 @@ int pseries_root_bridge_prepare(struct pci_host_bridge *bridge)
 
 	dn = pcibios_get_phb_of_node(bus);
 	if (!dn)
-		return 0;
+		return;
 
 	for (pdn = dn; pdn != NULL; pdn = of_get_next_parent(pdn)) {
 		rc = of_property_read_u32_array(pdn,
@@ -135,7 +135,7 @@ int pseries_root_bridge_prepare(struct pci_host_bridge *bridge)
 
 	if (rc) {
 		pr_debug("no ibm,pcie-link-speed-stats property\n");
-		return 0;
+		return;
 	}
 
 	switch (pcie_link_speed_stats[0]) {
@@ -168,5 +168,5 @@ int pseries_root_bridge_prepare(struct pci_host_bridge *bridge)
 		break;
 	}
 
-	return 0;
+	return;
 }
diff --git a/arch/powerpc/platforms/pseries/setup.c b/arch/powerpc/platforms/pseries/setup.c
index e445b67..b196c0d 100644
--- a/arch/powerpc/platforms/pseries/setup.c
+++ b/arch/powerpc/platforms/pseries/setup.c
@@ -496,7 +496,7 @@ static void __init pSeries_setup_arch(void)
 		ppc_md.enable_pmcs = power4_enable_pmcs;
 	}
 
-	ppc_md.pcibios_root_bridge_prepare = pseries_root_bridge_prepare;
+	ppc_md.pcibios_set_root_bus_speed = pseries_set_root_bus_speed;
 
 	if (firmware_has_feature(FW_FEATURE_SET_MODE)) {
 		long rc;
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 0ac2bf6..418a426 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1856,6 +1856,10 @@ int __weak pcibios_root_bridge_prepare(struct pci_host_bridge *bridge)
 	return 0;
 }
 
+void __weak pcibios_set_root_bus_speed(struct pci_host_bridge *bridge)
+{
+}
+
 void __weak pcibios_add_bus(struct pci_bus *bus)
 {
 }
@@ -1893,6 +1897,7 @@ static struct pci_bus *__pci_create_root_bus(
 	if (error)
 		goto put_dev;
 
+	pcibios_set_root_bus_speed(bridge);
 	device_enable_async_suspend(b->bridge);
 	pci_set_bus_of_node(b);
 
-- 
1.7.1

