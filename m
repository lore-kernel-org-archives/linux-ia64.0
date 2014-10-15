From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 15 Oct 2014 02:29:34 +0000
Subject: [PATCH v3 21/27] Powerpc/MSI: Use MSI chip framework to configure MSI/MSI-X irq
Message-Id: <1413342435-7876-22-git-send-email-wangyijing@huawei.com>
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
Hi Michael,
   I dropped the Acked-by , because this version has a
lot changes compared to last. So, I guess you may want to check it again.
---
 arch/powerpc/include/asm/pci-bridge.h |   15 +++++++++++++++
 arch/powerpc/kernel/msi.c             |   12 ++++++++++--
 arch/powerpc/kernel/pci-common.c      |    3 +++
 3 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/include/asm/pci-bridge.h b/arch/powerpc/include/asm/pci-bridge.h
index 4ca90a3..233553e 100644
--- a/arch/powerpc/include/asm/pci-bridge.h
+++ b/arch/powerpc/include/asm/pci-bridge.h
@@ -32,6 +32,10 @@ struct pci_controller {
 	int self_busno;
 	struct resource busn;
 
+#ifdef CONFIG_PCI_MSI
+	struct msi_chip *msi_chip;
+#endif
+
 	void __iomem *io_base_virt;
 #ifdef CONFIG_PPC64
 	void *io_base_alloc;
@@ -94,6 +98,17 @@ struct pci_controller {
 	void *private_data;
 };
 
+#ifdef CONFIG_PCI_MSI
+extern struct msi_chip ppc_msi_chip;
+
+static inline struct msi_chip *pci_msi_chip(struct pci_bus *bus)
+{
+	struct pci_controller *hose = bus->sysdata;
+
+	return hose->msi_chip;
+}
+#endif
+
 /* These are used for config access before all the PCI probing
    has been done. */
 extern int early_read_config_byte(struct pci_controller *hose, int bus,
diff --git a/arch/powerpc/kernel/msi.c b/arch/powerpc/kernel/msi.c
index 71bd161..f38b67c 100644
--- a/arch/powerpc/kernel/msi.c
+++ b/arch/powerpc/kernel/msi.c
@@ -13,7 +13,8 @@
 
 #include <asm/machdep.h>
 
-int arch_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
+static int ppc_setup_msi_irqs(struct msi_chip *chip,
+		struct pci_dev *dev, int nvec, int type)
 {
 	if (!ppc_md.setup_msi_irqs || !ppc_md.teardown_msi_irqs) {
 		pr_debug("msi: Platform doesn't provide MSI callbacks.\n");
@@ -27,7 +28,13 @@ int arch_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
 	return ppc_md.setup_msi_irqs(dev, nvec, type);
 }
 
-void arch_teardown_msi_irqs(struct pci_dev *dev)
+static void ppc_teardown_msi_irqs(struct msi_chip *chip,
+		struct pci_dev *dev)
 {
 	ppc_md.teardown_msi_irqs(dev);
 }
+
+struct msi_chip ppc_msi_chip = {
+	.setup_irqs = ppc_setup_msi_irqs,
+	.teardown_irqs = ppc_teardown_msi_irqs,
+};
diff --git a/arch/powerpc/kernel/pci-common.c b/arch/powerpc/kernel/pci-common.c
index b2814e2..9f18b42 100644
--- a/arch/powerpc/kernel/pci-common.c
+++ b/arch/powerpc/kernel/pci-common.c
@@ -1594,6 +1594,9 @@ void pcibios_scan_phb(struct pci_controller *hose)
 	/* Wire up PHB bus resources */
 	pcibios_setup_phb_resources(hose, &resources);
 
+#ifdef CONFIG_PCI_MSI
+	hose->msi_chip = &ppc_msi_chip;
+#endif
 	hose->busn.start = hose->first_busno;
 	hose->busn.end	 = hose->last_busno;
 	hose->busn.flags = IORESOURCE_BUS;
-- 
1.7.1

