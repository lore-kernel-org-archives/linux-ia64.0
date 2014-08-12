From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 12 Aug 2014 07:25:59 +0000
Subject: [RFC PATCH 06/20] PCI/MSI: Introduce arch_get_match_msi_chip() to find the match msi_chip
Message-Id: <1407828373-24322-7-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1407828373-24322-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1407828373-24322-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-pci@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, arnab.basu@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Yijing Wang <wangyijing@huawei.com>

Introduce __weak arch_get_match_msi_chip() to find the match msi_chip.
We prepare to use struct msi_chip to eliminate arch_xxx functions
in all platforms. The MSI device and the msi_chip binding is platform
specific. For instance, in x86, LAPICs receive all MSI irq, but in
arm, PCI device usually deliver their MSI to PCI hostbridge, if more
than one msi_chip found in system, DTS file will report the binding
between MSI devices and target msi_chip. So we need a platform implemented
interface to do that.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/msi.c |   30 ++++++++++++++++++++++++++----
 1 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
index 7b7abe9..feba5dd 100644
--- a/drivers/pci/msi.c
+++ b/drivers/pci/msi.c
@@ -29,10 +29,22 @@ static int pci_msi_enable = 1;
 
 /* Arch hooks */
 
-int __weak arch_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc)
+struct msi_chip * __weak arch_get_match_msi_chip(struct device *dev)
+{
+	if (dev_is_pci(dev)) {
+		struct pci_dev *pdev = to_pci_dev(dev);
+		struct msi_chip *chip = pdev->bus->msi;
+
+		return chip;
+	}
+
+	return NULL;
+}
+
+int __weak arch_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc)
 {
-	struct msi_chip *chip = dev->bus->msi;
 	int err;
+	struct msi_chip *chip = arch_get_match_msi_chip(&dev->dev);
 
 	if (!chip || !chip->setup_irq)
 		return -EINVAL;
@@ -46,7 +58,8 @@ int __weak arch_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc)
 
 void __weak arch_teardown_msi_irq(unsigned int irq)
 {
-	struct msi_chip *chip = irq_get_chip_data(irq);
+	struct msi_desc *entry = irq_get_msi_desc(irq);
+	struct msi_chip *chip = arch_get_match_msi_chip(&entry->dev->dev);
 
 	if (!chip || !chip->teardown_irq)
 		return;
@@ -56,7 +69,7 @@ void __weak arch_teardown_msi_irq(unsigned int irq)
 
 int __weak arch_msi_check_device(struct pci_dev *dev, int nvec, int type)
 {
-	struct msi_chip *chip = dev->bus->msi;
+	struct msi_chip *chip = arch_get_match_msi_chip(&dev->dev);
 
 	if (!chip || !chip->check_device)
 		return 0;
@@ -68,7 +81,12 @@ int __weak arch_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
 {
 	struct msi_desc *entry;
 	int ret;
+	struct msi_chip *chip;
 
+	chip = arch_get_match_msi_chip(&dev->dev);
+	if (chip && chip->setup_irqs)
+		return chip->setup_irqs(&dev->dev, nvec, type);
+
 	/*
 	 * If an architecture wants to support multiple MSI, it needs to
 	 * override arch_setup_msi_irqs()
@@ -133,6 +151,10 @@ static void default_restore_msi_irq(struct pci_dev *dev, int irq)
 
 void __weak arch_restore_msi_irqs(struct pci_dev *dev)
 {
+	struct msi_chip *chip = arch_get_msi_chip(&dev->dev);
+	if (chip && chip->restore_irqs)
+		return chip->restore_irqs(&dev->dev);
+
 	return default_restore_msi_irqs(dev);
 }
 
-- 
1.7.1

