From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 27 Oct 2014 12:44:43 +0000
Subject: [PATCH 13/16] IA64/MSI: Use MSI controller framework to configure MSI/MSI-X irq
Message-Id: <1414416142-31239-14-git-send-email-wangyijing@huawei.com>
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
 arch/ia64/include/asm/pci.h |    3 ++-
 arch/ia64/kernel/msi_ia64.c |   24 ++++++++++++++++++------
 arch/ia64/pci/pci.c         |    1 +
 3 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/arch/ia64/include/asm/pci.h b/arch/ia64/include/asm/pci.h
index 52af5ed..805bbc3 100644
--- a/arch/ia64/include/asm/pci.h
+++ b/arch/ia64/include/asm/pci.h
@@ -93,7 +93,7 @@ struct pci_controller {
 	void *iommu;
 	int segment;
 	int node;		/* nearest node with memory or NUMA_NO_NODE for global allocation */
-
+	struct msi_controller *msi_ctrl;
 	void *platform_data;
 };
 
@@ -101,6 +101,7 @@ struct pci_controller {
 #define PCI_CONTROLLER(busdev) ((struct pci_controller *) busdev->sysdata)
 #define pci_domain_nr(busdev)    (PCI_CONTROLLER(busdev)->segment)
 
+extern struct msi_controller ia64_msi_ctrl;
 extern struct pci_ops pci_root_ops;
 
 static inline int pci_proc_domain(struct pci_bus *bus)
diff --git a/arch/ia64/kernel/msi_ia64.c b/arch/ia64/kernel/msi_ia64.c
index 8c3730c..b92b8e2 100644
--- a/arch/ia64/kernel/msi_ia64.c
+++ b/arch/ia64/kernel/msi_ia64.c
@@ -42,7 +42,7 @@ static int ia64_set_msi_irq_affinity(struct irq_data *idata,
 }
 #endif /* CONFIG_SMP */
 
-int ia64_setup_msi_irq(struct pci_dev *pdev, struct msi_desc *desc)
+int __ia64_setup_msi_irq(struct pci_dev *pdev, struct msi_desc *desc)
 {
 	struct msi_msg	msg;
 	unsigned long	dest_phys_id;
@@ -77,7 +77,7 @@ int ia64_setup_msi_irq(struct pci_dev *pdev, struct msi_desc *desc)
 	return 0;
 }
 
-void ia64_teardown_msi_irq(unsigned int irq)
+void __ia64_teardown_msi_irq(unsigned int irq)
 {
 	destroy_irq(irq);
 }
@@ -111,23 +111,35 @@ static struct irq_chip ia64_msi_chip = {
 	.irq_retrigger		= ia64_msi_retrigger_irq,
 };
 
+struct msi_controller *pcibios_msi_controller(struct pci_bus *bus)
+{
+	struct pci_controller *ctrl = bus->sysdata;
+
+	return ctrl->msi_ctrl;
+}
 
-int arch_setup_msi_irq(struct pci_dev *pdev, struct msi_desc *desc)
+static int ia64_setup_msi_irq(struct msi_controller *ctrl,
+		struct pci_dev *pdev, struct msi_desc *desc)
 {
 	if (platform_setup_msi_irq)
 		return platform_setup_msi_irq(pdev, desc);
 
-	return ia64_setup_msi_irq(pdev, desc);
+	return __ia64_setup_msi_irq(pdev, desc);
 }
 
-void arch_teardown_msi_irq(unsigned int irq)
+static void ia64_teardown_msi_irq(struct msi_controller *ctrl, unsigned int irq)
 {
 	if (platform_teardown_msi_irq)
 		return platform_teardown_msi_irq(irq);
 
-	return ia64_teardown_msi_irq(irq);
+	return __ia64_teardown_msi_irq(irq);
 }
 
+struct msi_controller ia64_msi_ctrl = {
+	.setup_irq = ia64_setup_msi_irq,
+	.teardown_irq = ia64_teardown_msi_irq,
+};
+
 #ifdef CONFIG_INTEL_IOMMU
 #ifdef CONFIG_SMP
 static int dmar_msi_set_affinity(struct irq_data *data,
diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 291a582..875f46a 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -437,6 +437,7 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 
 	controller->companion = device;
 	controller->node = acpi_get_node(device->handle);
+	controller->msi_ctrl = &ia64_msi_ctrl;
 
 	info = kzalloc(sizeof(*info), GFP_KERNEL);
 	if (!info) {
-- 
1.7.1

