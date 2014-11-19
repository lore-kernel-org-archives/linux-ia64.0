From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 19 Nov 2014 06:52:12 +0000
Subject: [PATCH 3/5] PCI: Use pci_scan_bus_simple() in simple scene.
Message-Id: <1416382369-13587-4-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416382369-13587-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1416382369-13587-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Use pci_scan_bus_simple() to scan pci buses with
the default IO/MEM/BUS resources. Use it instead
of pci_scan_bus() and pci_scan_bus_parented().

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/alpha/kernel/sys_nautilus.c  |    2 +-
 arch/m68k/coldfire/pci.c          |    2 +-
 arch/sparc/kernel/pcic.c          |    3 ++-
 arch/unicore32/kernel/pci.c       |    4 ++--
 drivers/pci/hotplug/ibmphp_core.c |    3 ++-
 drivers/pci/xen-pcifront.c        |    2 +-
 include/linux/pci.h               |    2 ++
 7 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/arch/alpha/kernel/sys_nautilus.c b/arch/alpha/kernel/sys_nautilus.c
index 4ae4a40..a4f190b 100644
--- a/arch/alpha/kernel/sys_nautilus.c
+++ b/arch/alpha/kernel/sys_nautilus.c
@@ -206,7 +206,7 @@ nautilus_init_pci(void)
 	unsigned long memtop = max_low_pfn << PAGE_SHIFT;
 
 	/* Scan our single hose.  */
-	bus = pci_scan_bus(0, alpha_mv.pci_ops, hose);
+	bus = pci_scan_bus_simple(NULL, 0, alpha_mv.pci_ops, hose);
 	hose->bus = bus;
 	pcibios_claim_one_bus(bus);
 
diff --git a/arch/m68k/coldfire/pci.c b/arch/m68k/coldfire/pci.c
index d45f087..9f423d5 100644
--- a/arch/m68k/coldfire/pci.c
+++ b/arch/m68k/coldfire/pci.c
@@ -312,7 +312,7 @@ static int __init mcf_pci_init(void)
 	set_current_state(TASK_UNINTERRUPTIBLE);
 	schedule_timeout(msecs_to_jiffies(200));
 
-	rootbus = pci_scan_bus(0, &mcf_pci_ops, NULL);
+	rootbus = pci_scan_bus_simple(NULL, 0, &mcf_pci_ops, NULL);
 	rootbus->resource[0] = &mcf_pci_io;
 	rootbus->resource[1] = &mcf_pci_mem;
 
diff --git a/arch/sparc/kernel/pcic.c b/arch/sparc/kernel/pcic.c
index 7a82fe2..9665e03 100644
--- a/arch/sparc/kernel/pcic.c
+++ b/arch/sparc/kernel/pcic.c
@@ -390,7 +390,8 @@ static void __init pcic_pbm_scan_bus(struct linux_pcic *pcic)
 {
 	struct linux_pbm_info *pbm = &pcic->pbm;
 
-	pbm->pci_bus = pci_scan_bus(pbm->pci_first_busno, &pcic_ops, pbm);
+	pbm->pci_bus = pci_scan_bus_simple(NULL,
+			pbm->pci_first_busno, &pcic_ops, pbm);
 	if (pbm->pci_bus)
 		pci_bus_add_devices(pbm->pci_bus);
 #if 0 /* deadwood transplanted from sparc64 */
diff --git a/arch/unicore32/kernel/pci.c b/arch/unicore32/kernel/pci.c
index 3d82024..f290a3d 100644
--- a/arch/unicore32/kernel/pci.c
+++ b/arch/unicore32/kernel/pci.c
@@ -258,8 +258,8 @@ static int __init pci_common_init(void)
 
 	pci_puv3_preinit();
 
-	puv3_bus = pci_scan_bus(0, &pci_puv3_ops, NULL);
-
+	puv3_bus = pci_scan_bus_simple(NULL, 0,
+			&pci_puv3_ops, NULL);
 	if (!puv3_bus)
 		panic("PCI: unable to scan bus!");
 
diff --git a/drivers/pci/hotplug/ibmphp_core.c b/drivers/pci/hotplug/ibmphp_core.c
index db0f2e8..9190cb1 100644
--- a/drivers/pci/hotplug/ibmphp_core.c
+++ b/drivers/pci/hotplug/ibmphp_core.c
@@ -767,7 +767,8 @@ static u8 bus_structure_fixup(u8 busno)
 					(l != 0x0000) && (l != 0xffff)) {
 			debug("%s - Inside bus_structure_fixup()\n",
 							__func__);
-			b = pci_scan_bus(busno, ibmphp_pci_bus->ops, NULL);
+			b = pci_scan_bus_simple(NULL, busno,
+					ibmphp_pci_bus->ops, NULL);
 			if (b)
 				pci_bus_add_devices(b);
 			break;
diff --git a/drivers/pci/xen-pcifront.c b/drivers/pci/xen-pcifront.c
index b1ffebe..364aaf4 100644
--- a/drivers/pci/xen-pcifront.c
+++ b/drivers/pci/xen-pcifront.c
@@ -474,7 +474,7 @@ static int pcifront_scan_root(struct pcifront_device *pdev,
 
 	pci_lock_rescan_remove();
 
-	b = pci_scan_bus_parented(&pdev->xdev->dev, bus,
+	b = pci_scan_bus_simple(&pdev->xdev->dev, bus,
 				  &pcifront_bus_ops, sd);
 	if (!b) {
 		dev_err(&pdev->xdev->dev,
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 90a5fde..befefbd 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -769,6 +769,8 @@ struct pci_bus *pci_find_bus(int domain, int busnr);
 void pci_bus_add_devices(const struct pci_bus *bus);
 struct pci_bus *pci_scan_bus_parented(struct device *parent, int bus,
 				      struct pci_ops *ops, void *sysdata);
+struct pci_bus *pci_scan_bus_simple(struct device *parent, int bus,
+				      struct pci_ops *ops, void *sysdata);
 struct pci_bus *pci_scan_bus(int bus, struct pci_ops *ops, void *sysdata);
 struct pci_bus *pci_create_root_bus(struct device *parent, int bus,
 				    struct pci_ops *ops, void *sysdata,
-- 
1.7.1

