From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 17 Nov 2014 09:45:20 +0000
Subject: [RFC PATCH 02/16] PCI: Use pci_scan_root_bus() instead of pci_scan_bus()
Message-Id: <1416219710-26088-3-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416219710-26088-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1416219710-26088-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Thierry Reding <thierry.reding@gmail.com>, Liviu Dudau <liviu@dudau.co.uk>, Suravee.Suthikulpanit@amd.com, Yijing Wang <wangyijing@huawei.com>, Yijing Wang <wangyijing0307@gmail.com>

From: Yijing Wang <wangyijing0307@gmail.com>

Now we could use pci_scan_root_bus() instead of
pci_scan_bus(), pass NULL resources means use the default
io/mem.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/alpha/include/asm/pci.h      |    2 +-
 arch/alpha/kernel/sys_nautilus.c  |    2 +-
 arch/cris/include/asm/pci.h       |    2 +-
 arch/ia64/include/asm/pci.h       |    2 +-
 arch/m68k/coldfire/pci.c          |    2 +-
 arch/mips/include/asm/pci.h       |    2 +-
 arch/mn10300/include/asm/pci.h    |    2 +-
 arch/sh/include/asm/pci.h         |    2 +-
 arch/sparc/include/asm/pci_32.h   |    2 +-
 arch/sparc/include/asm/pci_64.h   |    2 +-
 arch/sparc/kernel/pcic.c          |    3 ++-
 arch/unicore32/kernel/pci.c       |    2 +-
 arch/x86/include/asm/pci.h        |    2 +-
 arch/x86/pci/amd_bus.c            |    2 +-
 arch/xtensa/include/asm/pci.h     |    2 +-
 drivers/parisc/dino.c             |    4 ++--
 drivers/pci/hotplug/ibmphp_core.c |    2 +-
 17 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/arch/alpha/include/asm/pci.h b/arch/alpha/include/asm/pci.h
index f7f680f..157925a 100644
--- a/arch/alpha/include/asm/pci.h
+++ b/arch/alpha/include/asm/pci.h
@@ -49,7 +49,7 @@ struct pci_controller {
 	void *sysdata;
 };
 
-/* Override the logic in pci_scan_bus for skipping already-configured
+/* Override the logic in pci_scan_root_bus for skipping already-configured
    bus numbers.  */
 
 #define pcibios_assign_all_busses()	1
diff --git a/arch/alpha/kernel/sys_nautilus.c b/arch/alpha/kernel/sys_nautilus.c
index 837c0fa..1047ab3 100644
--- a/arch/alpha/kernel/sys_nautilus.c
+++ b/arch/alpha/kernel/sys_nautilus.c
@@ -206,7 +206,7 @@ nautilus_init_pci(void)
 	unsigned long memtop = max_low_pfn << PAGE_SHIFT;
 
 	/* Scan our single hose.  */
-	bus = pci_scan_bus(0, alpha_mv.pci_ops, hose);
+	bus = pci_scan_root_bus(NULL, 0, alpha_mv.pci_ops, hose, NULL);
 	hose->bus = bus;
 	pcibios_claim_one_bus(bus);
 
diff --git a/arch/cris/include/asm/pci.h b/arch/cris/include/asm/pci.h
index cc2399c..96b33a6 100644
--- a/arch/cris/include/asm/pci.h
+++ b/arch/cris/include/asm/pci.h
@@ -5,7 +5,7 @@
 #ifdef __KERNEL__
 #include <linux/mm.h>		/* for struct page */
 
-/* Can be used to override the logic in pci_scan_bus for skipping
+/* Can be used to override the logic in pci_scan_root_bus for skipping
    already-configured bus numbers - to be used for buggy BIOSes
    or architectures with incomplete PCI setup by the loader */
 
diff --git a/arch/ia64/include/asm/pci.h b/arch/ia64/include/asm/pci.h
index 52af5ed..64b34d6 100644
--- a/arch/ia64/include/asm/pci.h
+++ b/arch/ia64/include/asm/pci.h
@@ -20,7 +20,7 @@ struct pci_vector_struct {
 };
 
 /*
- * Can be used to override the logic in pci_scan_bus for skipping already-configured bus
+ * Can be used to override the logic in pci_scan_root_bus for skipping already-configured bus
  * numbers - to be used for buggy BIOSes or architectures with incomplete PCI setup by the
  * loader.
  */
diff --git a/arch/m68k/coldfire/pci.c b/arch/m68k/coldfire/pci.c
index df96792..4d242fb 100644
--- a/arch/m68k/coldfire/pci.c
+++ b/arch/m68k/coldfire/pci.c
@@ -312,7 +312,7 @@ static int __init mcf_pci_init(void)
 	set_current_state(TASK_UNINTERRUPTIBLE);
 	schedule_timeout(msecs_to_jiffies(200));
 
-	rootbus = pci_scan_bus(0, &mcf_pci_ops, NULL);
+	rootbus = pci_scan_root_bus(NULL, 0, &mcf_pci_ops, NULL, NULL);
 	rootbus->resource[0] = &mcf_pci_io;
 	rootbus->resource[1] = &mcf_pci_mem;
 
diff --git a/arch/mips/include/asm/pci.h b/arch/mips/include/asm/pci.h
index 974b0e3..212030a 100644
--- a/arch/mips/include/asm/pci.h
+++ b/arch/mips/include/asm/pci.h
@@ -60,7 +60,7 @@ extern void register_pci_controller(struct pci_controller *hose);
 extern int pcibios_map_irq(const struct pci_dev *dev, u8 slot, u8 pin);
 
 
-/* Can be used to override the logic in pci_scan_bus for skipping
+/* Can be used to override the logic in pci_scan_root_bus for skipping
    already-configured bus numbers - to be used for buggy BIOSes
    or architectures with incomplete PCI setup by the loader */
 
diff --git a/arch/mn10300/include/asm/pci.h b/arch/mn10300/include/asm/pci.h
index 5f70af2..6305f14 100644
--- a/arch/mn10300/include/asm/pci.h
+++ b/arch/mn10300/include/asm/pci.h
@@ -33,7 +33,7 @@ do {							\
 #define __pcidebug(FMT, BUS, DEVFN, WHERE, ...)	do {} while (0)
 #endif
 
-/* Can be used to override the logic in pci_scan_bus for skipping
+/* Can be used to override the logic in pci_scan_root_bus for skipping
  * already-configured bus numbers - to be used for buggy BIOSes or
  * architectures with incomplete PCI setup by the loader */
 
diff --git a/arch/sh/include/asm/pci.h b/arch/sh/include/asm/pci.h
index 5b45115..69bcb78 100644
--- a/arch/sh/include/asm/pci.h
+++ b/arch/sh/include/asm/pci.h
@@ -3,7 +3,7 @@
 
 #ifdef __KERNEL__
 
-/* Can be used to override the logic in pci_scan_bus for skipping
+/* Can be used to override the logic in pci_scan_root_bus for skipping
    already-configured bus numbers - to be used for buggy BIOSes
    or architectures with incomplete PCI setup by the loader */
 
diff --git a/arch/sparc/include/asm/pci_32.h b/arch/sparc/include/asm/pci_32.h
index 53e9b49..4ef6064 100644
--- a/arch/sparc/include/asm/pci_32.h
+++ b/arch/sparc/include/asm/pci_32.h
@@ -5,7 +5,7 @@
 
 #include <linux/dma-mapping.h>
 
-/* Can be used to override the logic in pci_scan_bus for skipping
+/* Can be used to override the logic in pci_scan_root_bus for skipping
  * already-configured bus numbers - to be used for buggy BIOSes
  * or architectures with incomplete PCI setup by the loader.
  */
diff --git a/arch/sparc/include/asm/pci_64.h b/arch/sparc/include/asm/pci_64.h
index bd00a62..6e017f9 100644
--- a/arch/sparc/include/asm/pci_64.h
+++ b/arch/sparc/include/asm/pci_64.h
@@ -5,7 +5,7 @@
 
 #include <linux/dma-mapping.h>
 
-/* Can be used to override the logic in pci_scan_bus for skipping
+/* Can be used to override the logic in pci_scan_root_bus for skipping
  * already-configured bus numbers - to be used for buggy BIOSes
  * or architectures with incomplete PCI setup by the loader.
  */
diff --git a/arch/sparc/kernel/pcic.c b/arch/sparc/kernel/pcic.c
index 6cc78c2..64aafac 100644
--- a/arch/sparc/kernel/pcic.c
+++ b/arch/sparc/kernel/pcic.c
@@ -390,7 +390,8 @@ static void __init pcic_pbm_scan_bus(struct linux_pcic *pcic)
 {
 	struct linux_pbm_info *pbm = &pcic->pbm;
 
-	pbm->pci_bus = pci_scan_bus(pbm->pci_first_busno, &pcic_ops, pbm);
+	pbm->pci_bus = pci_scan_root_bus(NULL, pbm->pci_first_busno, 
+			&pcic_ops, pbm, NULL);
 #if 0 /* deadwood transplanted from sparc64 */
 	pci_fill_in_pbm_cookies(pbm->pci_bus, pbm, pbm->prom_node);
 	pci_record_assignments(pbm, pbm->pci_bus);
diff --git a/arch/unicore32/kernel/pci.c b/arch/unicore32/kernel/pci.c
index 374a055..be0f261 100644
--- a/arch/unicore32/kernel/pci.c
+++ b/arch/unicore32/kernel/pci.c
@@ -258,7 +258,7 @@ static int __init pci_common_init(void)
 
 	pci_puv3_preinit();
 
-	puv3_bus = pci_scan_bus(0, &pci_puv3_ops, NULL);
+	puv3_bus = pci_scan_root_bus(NULL, 0, &pci_puv3_ops, NULL, NULL);
 
 	if (!puv3_bus)
 		panic("PCI: unable to scan bus!");
diff --git a/arch/x86/include/asm/pci.h b/arch/x86/include/asm/pci.h
index 0892ea0..0540ff7 100644
--- a/arch/x86/include/asm/pci.h
+++ b/arch/x86/include/asm/pci.h
@@ -41,7 +41,7 @@ static inline int pci_proc_domain(struct pci_bus *bus)
 }
 #endif
 
-/* Can be used to override the logic in pci_scan_bus for skipping
+/* Can be used to override the logic in pci_scan_root_bus for skipping
    already-configured bus numbers - to be used for buggy BIOSes
    or architectures with incomplete PCI setup by the loader */
 
diff --git a/arch/x86/pci/amd_bus.c b/arch/x86/pci/amd_bus.c
index c20d2cc..baf6209 100644
--- a/arch/x86/pci/amd_bus.c
+++ b/arch/x86/pci/amd_bus.c
@@ -52,7 +52,7 @@ static struct pci_root_info __init *find_pci_root_info(int node, int link)
 
 /**
  * early_root_info_init()
- * called before pcibios_scan_root and pci_scan_bus
+ * called before pcibios_scan_root and pci_scan_root_bus
  * fills the mp_bus_to_cpumask array based according
  * to the LDT Bus Number Registers found in the northbridge.
  */
diff --git a/arch/xtensa/include/asm/pci.h b/arch/xtensa/include/asm/pci.h
index 5d52dc4..377fae9 100644
--- a/arch/xtensa/include/asm/pci.h
+++ b/arch/xtensa/include/asm/pci.h
@@ -13,7 +13,7 @@
 
 #ifdef __KERNEL__
 
-/* Can be used to override the logic in pci_scan_bus for skipping
+/* Can be used to override the logic in pci_scan_root_bus for skipping
  * already-configured bus numbers - to be used for buggy BIOSes
  * or architectures with incomplete PCI setup by the loader
  */
diff --git a/drivers/parisc/dino.c b/drivers/parisc/dino.c
index a0580af..67c31bd 100644
--- a/drivers/parisc/dino.c
+++ b/drivers/parisc/dino.c
@@ -74,7 +74,7 @@
 ** assigned a PCI bus number based on "when" it's discovered.
 **
 ** The "secondary" bus number is set to this before calling
-** pci_scan_bus(). If any PPB's are present, the scan will
+** pci_scan_root_bus(). If any PPB's are present, the scan will
 ** discover them and update the "secondary" and "subordinate"
 ** fields in Dino's pci_bus structure.
 **
@@ -787,7 +787,7 @@ static int __init dino_common_init(struct parisc_device *dev,
 
 	pcibios_register_hba(&dino_dev->hba);
 
-	pci_bios = &dino_bios_ops;   /* used by pci_scan_bus() */
+	pci_bios = &dino_bios_ops;   
 	pci_port = &dino_port_ops;
 
 	/*
diff --git a/drivers/pci/hotplug/ibmphp_core.c b/drivers/pci/hotplug/ibmphp_core.c
index 3efaf4c..b486432 100644
--- a/drivers/pci/hotplug/ibmphp_core.c
+++ b/drivers/pci/hotplug/ibmphp_core.c
@@ -767,7 +767,7 @@ static u8 bus_structure_fixup(u8 busno)
 					(l != 0x0000) && (l != 0xffff)) {
 			debug("%s - Inside bus_structure_fixup()\n",
 							__func__);
-			pci_scan_bus(busno, ibmphp_pci_bus->ops, NULL);
+			pci_scan_root_bus(NULL, busno, ibmphp_pci_bus->ops, NULL, NULL);
 			break;
 		}
 	}
-- 
1.7.1

