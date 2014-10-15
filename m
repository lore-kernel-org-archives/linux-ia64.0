From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 15 Oct 2014 02:26:59 +0000
Subject: [PATCH v3 24/27] IA64/MSI: Use MSI chip framework to configure MSI/MSI-X irq
Message-Id: <1413342435-7876-25-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413342435-7876-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1413342435-7876-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thierry Reding <thierry.reding@gmail.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Liviu Dudau <liviu@dudau.co.uk>, Yijing Wang <wangyijing@huawei.com>

Use MSI chip framework instead of arch MSI functions to configure
MSI/MSI-X irq. So we can manage MSI/MSI-X irq in a unified framework.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/ia64/include/asm/pci.h |   10 ++++++++++
 arch/ia64/kernel/msi_ia64.c |   14 ++++++++++----
 arch/ia64/pci/pci.c         |    1 +
 3 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/include/asm/pci.h b/arch/ia64/include/asm/pci.h
index 52af5ed..907dcba 100644
--- a/arch/ia64/include/asm/pci.h
+++ b/arch/ia64/include/asm/pci.h
@@ -94,6 +94,7 @@ struct pci_controller {
 	int segment;
 	int node;		/* nearest node with memory or NUMA_NO_NODE for global allocation */
 
+	struct msi_chip *msi_chip;
 	void *platform_data;
 };
 
@@ -101,6 +102,15 @@ struct pci_controller {
 #define PCI_CONTROLLER(busdev) ((struct pci_controller *) busdev->sysdata)
 #define pci_domain_nr(busdev)    (PCI_CONTROLLER(busdev)->segment)
 
+extern struct msi_chip chip;
+
+static inline struct msi_chip *pci_msi_chip(struct pci_bus *bus)
+{
+	struct pci_controller *ctrl = bus->sysdata;
+
+	return ctrl->msi_chip;
+}
+
 extern struct pci_ops pci_root_ops;
 
 static inline int pci_proc_domain(struct pci_bus *bus)
diff --git a/arch/ia64/kernel/msi_ia64.c b/arch/ia64/kernel/msi_ia64.c
index 8c3730c..401fc98 100644
--- a/arch/ia64/kernel/msi_ia64.c
+++ b/arch/ia64/kernel/msi_ia64.c
@@ -112,15 +112,16 @@ static struct irq_chip ia64_msi_chip = {
 };
 
 
-int arch_setup_msi_irq(struct pci_dev *pdev, struct msi_desc *desc)
+static int arch_ia64_setup_msi_irq(struct msi_chip *chip,
+		struct pci_dev *dev, struct msi_desc *desc)
 {
 	if (platform_setup_msi_irq)
-		return platform_setup_msi_irq(pdev, desc);
+		return platform_setup_msi_irq(dev, desc);
 
-	return ia64_setup_msi_irq(pdev, desc);
+	return ia64_setup_msi_irq(dev, desc);
 }
 
-void arch_teardown_msi_irq(unsigned int irq)
+static void arch_ia64_teardown_msi_irq(struct msi_chip *chip, unsigned int irq)
 {
 	if (platform_teardown_msi_irq)
 		return platform_teardown_msi_irq(irq);
@@ -128,6 +129,11 @@ void arch_teardown_msi_irq(unsigned int irq)
 	return ia64_teardown_msi_irq(irq);
 }
 
+struct msi_chip chip = {
+	.setup_irq = arch_ia64_setup_msi_irq,
+	.teardown_irq = arch_ia64_teardown_msi_irq,
+};
+
 #ifdef CONFIG_INTEL_IOMMU
 #ifdef CONFIG_SMP
 static int dmar_msi_set_affinity(struct irq_data *data,
diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 291a582..299b67d 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -437,6 +437,7 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 
 	controller->companion = device;
 	controller->node = acpi_get_node(device->handle);
+	controller->msi_chip = &chip;
 
 	info = kzalloc(sizeof(*info), GFP_KERNEL);
 	if (!info) {
-- 
1.7.1

