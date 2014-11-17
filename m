From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 17 Nov 2014 09:43:38 +0000
Subject: [RFC PATCH 04/16] PCI: Rip out pci_bus_add_devices() from pci_scan_root_bus()
Message-Id: <1416219710-26088-5-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416219710-26088-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1416219710-26088-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Thierry Reding <thierry.reding@gmail.com>, Liviu Dudau <liviu@dudau.co.uk>, Suravee.Suthikulpanit@amd.com, Yijing Wang <wangyijing@huawei.com>

Rip out pci_bus_add_devices() from pci_scan_root_bus()
for following reasons.
1. pci_scan_root_bus() means we only do the scan, we should
not add pci busses.
2. A lots of drviers which use pci_scan_root_bus() call
pci_bus_size_bridges(), pci_bus_assign_resources() after
pci_scan_root_bus(). But strictly speaking pci_bus_add_devices()
should be called after the resources assignment.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/alpha/kernel/pci.c           |    1 +
 arch/alpha/kernel/sys_nautilus.c  |    1 +
 arch/frv/mb93090-mb00/pci-vdk.c   |    8 +++++---
 arch/ia64/sn/kernel/io_init.c     |    2 ++
 arch/m68k/coldfire/pci.c          |    1 +
 arch/microblaze/pci/pci-common.c  |    2 +-
 arch/mips/pci/pci.c               |    1 +
 arch/mn10300/unit-asb2305/pci.c   |    7 +++++--
 arch/s390/pci/pci.c               |    2 +-
 arch/sh/drivers/pci/pci.c         |    1 +
 arch/sparc/kernel/leon_pci.c      |    1 +
 arch/sparc/kernel/pcic.c          |    2 ++
 arch/tile/kernel/pci.c            |    3 ++-
 arch/tile/kernel/pci_gx.c         |    3 ++-
 arch/unicore32/kernel/pci.c       |    2 +-
 arch/x86/pci/common.c             |   10 ++++++----
 arch/xtensa/kernel/pci.c          |    1 +
 drivers/pci/host/pci-xgene.c      |    2 +-
 drivers/pci/hotplug/ibmphp_core.c |    6 ++++--
 drivers/pci/probe.c               |    1 -
 20 files changed, 39 insertions(+), 18 deletions(-)

diff --git a/arch/alpha/kernel/pci.c b/arch/alpha/kernel/pci.c
index 076c35c..81251a5 100644
--- a/arch/alpha/kernel/pci.c
+++ b/arch/alpha/kernel/pci.c
@@ -349,6 +349,7 @@ common_init_pci(void)
 
 	pci_assign_unassigned_resources();
 	pci_fixup_irqs(alpha_mv.pci_swizzle, alpha_mv.pci_map_irq);
+	pci_bus_add_devices(bus);
 }
 
 
diff --git a/arch/alpha/kernel/sys_nautilus.c b/arch/alpha/kernel/sys_nautilus.c
index 1047ab3..60fbd77 100644
--- a/arch/alpha/kernel/sys_nautilus.c
+++ b/arch/alpha/kernel/sys_nautilus.c
@@ -253,6 +253,7 @@ nautilus_init_pci(void)
 	   for the root bus, so just clear it. */
 	bus->self = NULL;
 	pci_fixup_irqs(alpha_mv.pci_swizzle, alpha_mv.pci_map_irq);
+	pci_bus_add_devices(bus);
 }
 
 /*
diff --git a/arch/frv/mb93090-mb00/pci-vdk.c b/arch/frv/mb93090-mb00/pci-vdk.c
index efa5d65..85f87dc 100644
--- a/arch/frv/mb93090-mb00/pci-vdk.c
+++ b/arch/frv/mb93090-mb00/pci-vdk.c
@@ -316,6 +316,7 @@ void pcibios_fixup_bus(struct pci_bus *bus)
 
 int __init pcibios_init(void)
 {
+	struct pci_bus *bus = NULL;
 	struct pci_ops *dir = NULL;
 	LIST_HEAD(resources);
 
@@ -383,12 +384,13 @@ int __init pcibios_init(void)
 	printk("PCI: Probing PCI hardware\n");
 	pci_add_resource(&resources, &pci_ioport_resource);
 	pci_add_resource(&resources, &pci_iomem_resource);
-	pci_scan_root_bus(NULL, 0, pci_root_ops, NULL, &resources);
-
+	bus = pci_scan_root_bus(NULL, 0, pci_root_ops, NULL, &resources);
+	if (!bus)
+		return -ENXIO;
 	pcibios_irq_init();
 	pcibios_fixup_irqs();
 	pcibios_resource_survey();
-
+	pci_bus_add_devices(bus);
 	return 0;
 }
 
diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
index 0b5ce82..1be65eb 100644
--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -271,7 +271,9 @@ sn_pci_controller_fixup(int segment, int busnum, struct pci_bus *bus)
  	if (bus = NULL) {
 		kfree(res);
 		kfree(controller);
+		return;
 	}
+	pci_bus_add_devices(bus);
 }
 
 /*
diff --git a/arch/m68k/coldfire/pci.c b/arch/m68k/coldfire/pci.c
index 4d242fb..840a431 100644
--- a/arch/m68k/coldfire/pci.c
+++ b/arch/m68k/coldfire/pci.c
@@ -319,6 +319,7 @@ static int __init mcf_pci_init(void)
 	pci_fixup_irqs(pci_common_swizzle, mcf_pci_map_irq);
 	pci_bus_size_bridges(rootbus);
 	pci_bus_assign_resources(rootbus);
+	pci_bus_add_devices(rootbus);
 	return 0;
 }
 
diff --git a/arch/microblaze/pci/pci-common.c b/arch/microblaze/pci/pci-common.c
index 9037914..9ca7e3f 100644
--- a/arch/microblaze/pci/pci-common.c
+++ b/arch/microblaze/pci/pci-common.c
@@ -1344,8 +1344,8 @@ static void pcibios_scan_phb(struct pci_controller *hose)
 	}
 	bus->busn_res.start = hose->first_busno;
 	hose->bus = bus;
-
 	hose->last_busno = bus->busn_res.end;
+	pci_bus_add_devices(bus);
 }
 
 static int __init pcibios_init(void)
diff --git a/arch/mips/pci/pci.c b/arch/mips/pci/pci.c
index 1bf60b1..f083688 100644
--- a/arch/mips/pci/pci.c
+++ b/arch/mips/pci/pci.c
@@ -113,6 +113,7 @@ static void pcibios_scanbus(struct pci_controller *hose)
 		if (!pci_has_flag(PCI_PROBE_ONLY)) {
 			pci_bus_size_bridges(bus);
 			pci_bus_assign_resources(bus);
+			pci_bus_add_devices(bus);
 		}
 	}
 }
diff --git a/arch/mn10300/unit-asb2305/pci.c b/arch/mn10300/unit-asb2305/pci.c
index 6b4339f..011af54 100644
--- a/arch/mn10300/unit-asb2305/pci.c
+++ b/arch/mn10300/unit-asb2305/pci.c
@@ -345,6 +345,7 @@ void pcibios_fixup_bus(struct pci_bus *bus)
  */
 static int __init pcibios_init(void)
 {
+	struct pci_bus *bus;
 	resource_size_t io_offset, mem_offset;
 	LIST_HEAD(resources);
 
@@ -376,11 +377,13 @@ static int __init pcibios_init(void)
 
 	pci_add_resource_offset(&resources, &pci_ioport_resource, io_offset);
 	pci_add_resource_offset(&resources, &pci_iomem_resource, mem_offset);
-	pci_scan_root_bus(NULL, 0, &pci_direct_ampci, NULL, &resources);
-
+	bus = pci_scan_root_bus(NULL, 0, &pci_direct_ampci, NULL, &resources);
+	if (!bus)
+		return 0;
 	pcibios_irq_init();
 	pcibios_fixup_irqs();
 	pcibios_resource_survey();
+	pci_bus_add_devices(bus);
 	return 0;
 }
 
diff --git a/arch/s390/pci/pci.c b/arch/s390/pci/pci.c
index 2fa7b14..016ea48 100644
--- a/arch/s390/pci/pci.c
+++ b/arch/s390/pci/pci.c
@@ -755,7 +755,7 @@ static int zpci_scan_bus(struct zpci_dev *zdev)
 		zpci_cleanup_bus_resources(zdev);
 		return -EIO;
 	}
-
+	pci_bus_add_devices(zdev->bus);
 	zdev->bus->max_bus_speed = zdev->max_bus_speed;
 	return 0;
 }
diff --git a/arch/sh/drivers/pci/pci.c b/arch/sh/drivers/pci/pci.c
index 1bc09ee..efc1051 100644
--- a/arch/sh/drivers/pci/pci.c
+++ b/arch/sh/drivers/pci/pci.c
@@ -69,6 +69,7 @@ static void pcibios_scanbus(struct pci_channel *hose)
 
 		pci_bus_size_bridges(bus);
 		pci_bus_assign_resources(bus);
+		pci_bus_add_devices(bus);
 	} else {
 		pci_free_resource_list(&resources);
 	}
diff --git a/arch/sparc/kernel/leon_pci.c b/arch/sparc/kernel/leon_pci.c
index 899b720..2971076 100644
--- a/arch/sparc/kernel/leon_pci.c
+++ b/arch/sparc/kernel/leon_pci.c
@@ -40,6 +40,7 @@ void leon_pci_init(struct platform_device *ofdev, struct leon_pci_info *info)
 
 		/* Assign devices with resources */
 		pci_assign_unassigned_resources();
+		pci_bus_add_devices(root_bus);
 	} else {
 		pci_free_resource_list(&resources);
 	}
diff --git a/arch/sparc/kernel/pcic.c b/arch/sparc/kernel/pcic.c
index 64aafac..5457814 100644
--- a/arch/sparc/kernel/pcic.c
+++ b/arch/sparc/kernel/pcic.c
@@ -392,6 +392,8 @@ static void __init pcic_pbm_scan_bus(struct linux_pcic *pcic)
 
 	pbm->pci_bus = pci_scan_root_bus(NULL, pbm->pci_first_busno, 
 			&pcic_ops, pbm, NULL);
+	if (pbm->pci_bus)
+		pci_bus_add_devices(pbm->pci_bus);
 #if 0 /* deadwood transplanted from sparc64 */
 	pci_fill_in_pbm_cookies(pbm->pci_bus, pbm, pbm->prom_node);
 	pci_record_assignments(pbm, pbm->pci_bus);
diff --git a/arch/tile/kernel/pci.c b/arch/tile/kernel/pci.c
index 1f80a88..268423e 100644
--- a/arch/tile/kernel/pci.c
+++ b/arch/tile/kernel/pci.c
@@ -326,7 +326,8 @@ int __init pcibios_init(void)
 
 	/* Configure the max_read_size and max_payload_size values. */
 	fixup_read_and_payload_sizes();
-
+	if (bus)
+		pci_bus_add_devices(bus);
 	/* Record the I/O resources in the PCI controller structure. */
 	for (i = 0; i < TILE_NUM_PCIE; i++) {
 		/*
diff --git a/arch/tile/kernel/pci_gx.c b/arch/tile/kernel/pci_gx.c
index e39f9c5..5f05a9a 100644
--- a/arch/tile/kernel/pci_gx.c
+++ b/arch/tile/kernel/pci_gx.c
@@ -903,7 +903,8 @@ int __init pcibios_init(void)
 	 * associated with the devices read in above.
 	 */
 	pci_assign_unassigned_resources();
-
+	if (bus)
+		pci_bus_add_devices(bus);
 	/* Record the I/O resources in the PCI controller structure. */
 	for (i = 0; i < num_rc_controllers; i++) {
 		struct pci_controller *controller = &pci_controllers[i];
diff --git a/arch/unicore32/kernel/pci.c b/arch/unicore32/kernel/pci.c
index be0f261..0d4c563 100644
--- a/arch/unicore32/kernel/pci.c
+++ b/arch/unicore32/kernel/pci.c
@@ -270,11 +270,11 @@ static int __init pci_common_init(void)
 		 * Size the bridge windows.
 		 */
 		pci_bus_size_bridges(puv3_bus);
-
 		/*
 		 * Assign resources.
 		 */
 		pci_bus_assign_resources(puv3_bus);
+		pci_bus_add_devices(puv3_bus);
 	}
 
 	return 0;
diff --git a/arch/x86/pci/common.c b/arch/x86/pci/common.c
index 7b20bcc..b16632b 100644
--- a/arch/x86/pci/common.c
+++ b/arch/x86/pci/common.c
@@ -471,10 +471,12 @@ void pcibios_scan_root(int busnum)
 	x86_pci_root_bus_resources(busnum, &resources);
 	printk(KERN_DEBUG "PCI: Probing PCI hardware (bus %02x)\n", busnum);
 	bus = pci_scan_root_bus(NULL, busnum, &pci_root_ops, sd, &resources);
-	if (!bus) {
-		pci_free_resource_list(&resources);
-		kfree(sd);
-	}
+	if (bus) {
+		pci_bus_add_devices(bus);
+		return;
+	} 
+	pci_free_resource_list(&resources);
+	kfree(sd);
 }
 
 void __init pcibios_set_cache_line_size(void)
diff --git a/arch/xtensa/kernel/pci.c b/arch/xtensa/kernel/pci.c
index 5b34033..c4b5b5d 100644
--- a/arch/xtensa/kernel/pci.c
+++ b/arch/xtensa/kernel/pci.c
@@ -185,6 +185,7 @@ static int __init pcibios_init(void)
 		pci_controller_apertures(pci_ctrl, &resources);
 		bus = pci_scan_root_bus(NULL, pci_ctrl->first_busno,
 					pci_ctrl->ops, pci_ctrl, &resources);
+		pci_bus_add_devices(bus);
 		pci_ctrl->bus = bus;
 		pci_ctrl->last_busno = bus->busn_res.end;
 		if (next_busno <= pci_ctrl->last_busno)
diff --git a/drivers/pci/host/pci-xgene.c b/drivers/pci/host/pci-xgene.c
index 9ecabfa..e7a4f66 100644
--- a/drivers/pci/host/pci-xgene.c
+++ b/drivers/pci/host/pci-xgene.c
@@ -634,7 +634,7 @@ static int xgene_pcie_probe_bridge(struct platform_device *pdev)
 	bus = pci_scan_root_bus(&pdev->dev, 0, &xgene_pcie_ops, port, &res);
 	if (!bus)
 		return -ENOMEM;
-
+	pci_bus_add_devices(bus);
 	platform_set_drvdata(pdev, port);
 	return 0;
 }
diff --git a/drivers/pci/hotplug/ibmphp_core.c b/drivers/pci/hotplug/ibmphp_core.c
index b486432..76ce157 100644
--- a/drivers/pci/hotplug/ibmphp_core.c
+++ b/drivers/pci/hotplug/ibmphp_core.c
@@ -740,7 +740,7 @@ static void ibm_unconfigure_device(struct pci_func *func)
  */
 static u8 bus_structure_fixup(u8 busno)
 {
-	struct pci_bus *bus;
+	struct pci_bus *bus, *b;
 	struct pci_dev *dev;
 	u16 l;
 
@@ -767,7 +767,9 @@ static u8 bus_structure_fixup(u8 busno)
 					(l != 0x0000) && (l != 0xffff)) {
 			debug("%s - Inside bus_structure_fixup()\n",
 							__func__);
-			pci_scan_root_bus(NULL, busno, ibmphp_pci_bus->ops, NULL, NULL);
+			b = pci_scan_root_bus(NULL, busno, ibmphp_pci_bus->ops, NULL, NULL);
+			if (b)
+				pci_bus_add_devices(b);
 			break;
 		}
 	}
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 0a02fc2..97711f3 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -2101,7 +2101,6 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, int bus,
 	if (!found)
 		pci_bus_update_busn_res_end(b, max);
 
-	pci_bus_add_devices(b);
 	return b;
 }
 EXPORT_SYMBOL(pci_scan_root_bus);
-- 
1.7.1

