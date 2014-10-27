From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 27 Oct 2014 12:46:50 +0000
Subject: [PATCH 02/16] x86/MSI: Use MSI controller framework to configure MSI/MSI-X irq
Message-Id: <1414416142-31239-3-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1414416142-31239-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1414416142-31239-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thierry Reding <thierry.reding@gmail.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Yijing Wang <wangyijing@huawei.com>

Use MSI controller framework instead of arch MSI functions to configure
MSI/MSI-X irq. So we can manage MSI/MSI-X irq in a unified framework.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/x86/include/asm/pci.h     |    4 ++++
 arch/x86/kernel/apic/io_apic.c |   25 +++++++++++++++++++++++++
 arch/x86/pci/acpi.c            |    1 +
 arch/x86/pci/common.c          |    3 +++
 4 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/pci.h b/arch/x86/include/asm/pci.h
index 0892ea0..1af3d77 100644
--- a/arch/x86/include/asm/pci.h
+++ b/arch/x86/include/asm/pci.h
@@ -20,6 +20,9 @@ struct pci_sysdata {
 #ifdef CONFIG_X86_64
 	void		*iommu;		/* IOMMU private data */
 #endif
+#ifdef CONFIG_PCI_MSI
+	struct msi_controller *msi_ctrl;
+#endif
 };
 
 extern int pci_routeirq;
@@ -101,6 +104,7 @@ void native_teardown_msi_irq(unsigned int irq);
 void native_restore_msi_irqs(struct pci_dev *dev);
 int setup_msi_irq(struct pci_dev *dev, struct msi_desc *msidesc,
 		  unsigned int irq_base, unsigned int irq_offset);
+extern struct msi_controller *x86_msi_ctrl;
 #else
 #define native_setup_msi_irqs		NULL
 #define native_teardown_msi_irq		NULL
diff --git a/arch/x86/kernel/apic/io_apic.c b/arch/x86/kernel/apic/io_apic.c
index 1183d54..8b8c671 100644
--- a/arch/x86/kernel/apic/io_apic.c
+++ b/arch/x86/kernel/apic/io_apic.c
@@ -3234,11 +3234,36 @@ int native_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
 	return 0;
 }
 
+static int __native_setup_msi_irqs(struct msi_controller *ctrl,
+		struct pci_dev *dev, int nvec, int type)
+{
+	return native_setup_msi_irqs(dev, nvec, type);
+}
+
 void native_teardown_msi_irq(unsigned int irq)
 {
 	irq_free_hwirq(irq);
 }
 
+static void __native_teardown_msi_irq(struct msi_controller *ctrl,
+		unsigned int irq)
+{
+	native_teardown_msi_irq(irq);
+}
+
+static struct msi_controller native_msi_ctrl = {
+	.setup_irqs = __native_setup_msi_irqs,
+	.teardown_irq = __native_teardown_msi_irq,
+};
+
+struct msi_controller *pcibios_msi_controller(struct pci_bus *bus)
+{
+	struct pci_sysdata *sys = bus->sysdata;
+
+	return sys->msi_ctrl;
+}
+struct msi_controller *x86_msi_ctrl = &native_msi_ctrl;
+
 #ifdef CONFIG_DMAR_TABLE
 static int
 dmar_msi_set_affinity(struct irq_data *data, const struct cpumask *mask,
diff --git a/arch/x86/pci/acpi.c b/arch/x86/pci/acpi.c
index cfd1b13..edb14dd 100644
--- a/arch/x86/pci/acpi.c
+++ b/arch/x86/pci/acpi.c
@@ -508,6 +508,7 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 
 	sd = &info->sd;
 	sd->domain = domain;
+	sd->msi_ctrl = x86_msi_ctrl;
 	sd->node = node;
 	sd->companion = device;
 
diff --git a/arch/x86/pci/common.c b/arch/x86/pci/common.c
index 7b20bcc..4deb240 100644
--- a/arch/x86/pci/common.c
+++ b/arch/x86/pci/common.c
@@ -468,6 +468,9 @@ void pcibios_scan_root(int busnum)
 		return;
 	}
 	sd->node = x86_pci_root_bus_node(busnum);
+#ifdef CONFIG_PCI_MSI
+	sd->msi_ctrl = x86_msi_ctrl;
+#endif
 	x86_pci_root_bus_resources(busnum, &resources);
 	printk(KERN_DEBUG "PCI: Probing PCI hardware (bus %02x)\n", busnum);
 	bus = pci_scan_root_bus(NULL, busnum, &pci_root_ops, sd, &resources);
-- 
1.7.1

