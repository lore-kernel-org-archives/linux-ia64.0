From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 12 Aug 2014 07:26:06 +0000
Subject: [RFC PATCH 13/20] MIPS/xlr/MSI: Use msi_chip instead of arch func to configure MSI/MSI-X
Message-Id: <1407828373-24322-14-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1407828373-24322-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1407828373-24322-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-pci@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, arnab.basu@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Yijing Wang <wangyijing@huawei.com>

Introduce a new struct msi_chip xlr_msi_chip instead of weak arch
functions to configure MSI/MSI-X.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/mips/pci/pci-xlr.c |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/arch/mips/pci/pci-xlr.c b/arch/mips/pci/pci-xlr.c
index 0dde803..6eef164 100644
--- a/arch/mips/pci/pci-xlr.c
+++ b/arch/mips/pci/pci-xlr.c
@@ -214,11 +214,11 @@ static int get_irq_vector(const struct pci_dev *dev)
 }
 
 #ifdef CONFIG_PCI_MSI
-void arch_teardown_msi_irq(unsigned int irq)
+void xlr_teardown_msi_irq(unsigned int irq)
 {
 }
 
-int arch_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc)
+int xlr_setup_msi_irq(struct device *dev, struct msi_desc *desc)
 {
 	struct msi_msg msg;
 	struct pci_dev *lnk;
@@ -233,7 +233,7 @@ int arch_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc)
 	 * Enable MSI on the XLS PCIe controller bridge which was disabled
 	 * at enumeration, the bridge MSI capability is at 0x50
 	 */
-	lnk = xls_get_pcie_link(dev);
+	lnk = xls_get_pcie_link(to_pci_dev(dev));
 	if (lnk = NULL)
 		return 1;
 
@@ -243,7 +243,7 @@ int arch_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc)
 		pci_write_config_word(lnk, 0x50 + PCI_MSI_FLAGS, val);
 	}
 
-	irq = get_irq_vector(dev);
+	irq = get_irq_vector(to_pci_dev(dev));
 	if (irq <= 0)
 		return 1;
 
@@ -263,6 +263,17 @@ int arch_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc)
 	write_msi_msg(irq, &msg);
 	return 0;
 }
+
+struct msi_chip xlr_msi_chip = {
+	.setup_irq = xlr_setup_msi_irq,
+	.teardown_irq = xlr_teardown_msi_irq,
+};
+
+struct msi_chip *arch_get_match_msi_chip(struct device *dev)
+{
+	return &xlr_msi_chip;
+}
+
 #endif
 
 /* Extra ACK needed for XLR on chip PCI controller */
-- 
1.7.1

