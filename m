From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Date: Tue, 13 Feb 2007 09:20:23 +0000
Subject: [PATCH] ide controller quirk to correct bad BAR resources
Message-Id: <1171358423.2978.17.camel@ymzhang>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

If ide controllers are at legacy mode, only the 4th BAR
is needed, so some BIOS initiate other BAR with incorrect
value. ata/ata_piix calls pci_enable_device on the ide
controller, which will check BAR resources. If the BAR
resource values are incorrect, pci_enable_device will fail,
and ata/ata_piix couldn't attach the ide controller.

Below patch against 2.6.20 creates a quirk to correct the
bad BAR resources for a special ide controller which is
popular on tiger-4.

Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>

---

--- linux-2.6.20/arch/ia64/kernel/quirks.c	1970-01-01 08:00:00.000000000 +0800
+++ linux-2.6.20_fix/arch/ia64/kernel/quirks.c	2007-02-12 23:31:28.000000000 +0800
@@ -0,0 +1,47 @@
+/*
+ * This file contains work-arounds for ia64 platform bugs.
+ */
+#include <linux/pci.h>
+
+/*
+ * quirk_intel_ide_controller: If an ide/ata controller is
+ * at legacy mode, BIOS might initiates BAR(bar 0~3 and 5)
+ * with incorrect value. This quirk will reset the incorrect
+ * value to 0.
+ */
+static void __devinit quirk_intel_ide_controller(struct pci_dev *dev)
+{
+	unsigned int pos;
+	struct resource *res;
+	int fixed = 0;
+	u8 tmp8;
+	u8 mask;
+
+	if ((dev->class >> 8) != PCI_CLASS_STORAGE_IDE)
+		return;
+
+	/* TODO: What if one channel is in native mode ... */
+	pci_read_config_byte(dev, PCI_CLASS_PROG, &tmp8);
+	mask = (1 << 2) | (1 << 0);
+	if ((tmp8 & mask) = mask)
+		return;
+
+	for( pos = 0; pos < 6; pos ++ ) {
+		res = &dev->resource[pos];
+		if (!(res->flags & (IORESOURCE_IO | IORESOURCE_MEM)))
+			continue;
+
+		if (!res->start && res->end) {
+			res->start = res->end = 0;
+			res->flags = 0;
+			fixed = 1;
+		}
+	}
+	if (fixed)
+		printk(KERN_WARNING
+			"PCI device %s: BIOS resource configuration fixed.\n",
+			pci_name(dev));
+}
+
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_82801DB_11, quirk_intel_ide_controller);
+
--- linux-2.6.20/arch/ia64/kernel/Makefile	2007-02-08 15:13:41.000000000 +0800
+++ linux-2.6.20_fix/arch/ia64/kernel/Makefile	2007-02-12 22:49:39.000000000 +0800
@@ -33,6 +33,7 @@ obj-$(CONFIG_CRASH_DUMP)	+= crash_dump.o
 obj-$(CONFIG_IA64_UNCACHED_ALLOCATOR)	+= uncached.o
 obj-$(CONFIG_AUDIT)		+= audit.o
 obj-$(CONFIG_PCI_MSI)		+= msi_ia64.o
+obj-$(CONFIG_PCI)		+= quirks.o
 mca_recovery-y			+= mca_drv.o mca_drv_asm.o
 
 obj-$(CONFIG_IA64_ESI)		+= esi.o
