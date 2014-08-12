From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 12 Aug 2014 07:26:13 +0000
Subject: [RFC PATCH 20/20] PCI/MSI: Clean up unused MSI arch functions
Message-Id: <1407828373-24322-21-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1407828373-24322-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1407828373-24322-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-pci@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, arnab.basu@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Yijing Wang <wangyijing@huawei.com>

Now we use struct msi_chip in all platforms to configure
MSI/MSI-X. We can clean up the unused arch functions.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/msi.c |   82 ++++++++++++++++++++--------------------------------
 1 files changed, 32 insertions(+), 50 deletions(-)

diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
index feba5dd..2d2d4cd 100644
--- a/drivers/pci/msi.c
+++ b/drivers/pci/msi.c
@@ -41,33 +41,7 @@ struct msi_chip * __weak arch_get_match_msi_chip(struct device *dev)
 	return NULL;
 }
 
-int __weak arch_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc) 
-{
-	int err;
-	struct msi_chip *chip = arch_get_match_msi_chip(&dev->dev);
-
-	if (!chip || !chip->setup_irq)
-		return -EINVAL;
-
-	err = chip->setup_irq(&dev->dev, desc);
-	if (err < 0)
-		return err;
-
-	return 0;
-}
-
-void __weak arch_teardown_msi_irq(unsigned int irq)
-{
-	struct msi_desc *entry = irq_get_msi_desc(irq);
-	struct msi_chip *chip = arch_get_match_msi_chip(&entry->dev->dev);
-
-	if (!chip || !chip->teardown_irq)
-		return;
-
-	chip->teardown_irq(irq);
-}
-
-int __weak arch_msi_check_device(struct pci_dev *dev, int nvec, int type)
+static int msi_check_device(struct pci_dev *dev, int nvec, int type)
 {
 	struct msi_chip *chip = arch_get_match_msi_chip(&dev->dev);
 
@@ -77,25 +51,31 @@ int __weak arch_msi_check_device(struct pci_dev *dev, int nvec, int type)
 	return chip->check_device(&dev->dev, nvec, type);
 }
 
-int __weak arch_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
+static int setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
 {
 	struct msi_desc *entry;
 	int ret;
 	struct msi_chip *chip;
 
 	chip = arch_get_match_msi_chip(&dev->dev);
-	if (chip && chip->setup_irqs)
+	if (!chip)
+		return -EINVAL;
+
+	if (chip->setup_irqs)
 		return chip->setup_irqs(&dev->dev, nvec, type);
 	
 	/*
 	 * If an architecture wants to support multiple MSI, it needs to
-	 * override arch_setup_msi_irqs()
+	 * provide chip->setup_irqs()
 	 */
 	if (type = PCI_CAP_ID_MSI && nvec > 1)
 		return 1;
 
+	if (!chip->setup_irq)
+		return -EINVAL;
+
 	list_for_each_entry(entry, &dev->msi_list, list) {
-		ret = arch_setup_msi_irq(dev, entry);
+		ret = chip->setup_irq(&dev->dev, entry);
 		if (ret < 0)
 			return ret;
 		if (ret > 0)
@@ -105,13 +85,20 @@ int __weak arch_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
 	return 0;
 }
 
-/*
- * We have a default implementation available as a separate non-weak
- * function, as it is used by the Xen x86 PCI code
- */
-void default_teardown_msi_irqs(struct pci_dev *dev)
+static void teardown_msi_irqs(struct pci_dev *dev)
 {
 	struct msi_desc *entry;
+	struct msi_chip *chip;
+
+	chip = arch_get_match_msi_chip(&dev->dev);
+	if (!chip)
+		return;
+
+	if (chip->teardown_irqs)
+		return chip->teardown_irqs(&dev->dev);
+
+	if (!chip->teardown_irq)
+		return;
 
 	list_for_each_entry(entry, &dev->msi_list, list) {
 		int i, nvec;
@@ -122,15 +109,10 @@ void default_teardown_msi_irqs(struct pci_dev *dev)
 		else
 			nvec = 1 << entry->msi_attrib.multiple;
 		for (i = 0; i < nvec; i++)
-			arch_teardown_msi_irq(entry->irq + i);
+			chip->teardown_irq(entry->irq + i);
 	}
 }
 
-void __weak arch_teardown_msi_irqs(struct pci_dev *dev)
-{
-	return default_teardown_msi_irqs(dev);
-}
-
 static void default_restore_msi_irq(struct pci_dev *dev, int irq)
 {
 	struct msi_desc *entry;
@@ -149,9 +131,9 @@ static void default_restore_msi_irq(struct pci_dev *dev, int irq)
 		write_msi_msg(irq, &entry->msg);
 }
 
-void __weak arch_restore_msi_irqs(struct pci_dev *dev)
+static void restore_msi_irqs(struct pci_dev *dev)
 {
-	struct msi_chip *chip = arch_get_msi_chip(&dev->dev);
+	struct msi_chip *chip = arch_get_match_msi_chip(&dev->dev);
 	if (chip && chip->restore_irqs)
 		return chip->restore_irqs(&dev->dev);
 
@@ -386,7 +368,7 @@ static void free_msi_irqs(struct pci_dev *dev)
 			BUG_ON(irq_has_action(entry->irq + i));
 	}
 
-	arch_teardown_msi_irqs(dev);
+	teardown_msi_irqs(dev);
 
 	list_for_each_entry_safe(entry, tmp, &dev->msi_list, list) {
 		if (entry->msi_attrib.is_msix) {
@@ -456,7 +438,7 @@ static void __pci_restore_msi_state(struct pci_dev *dev)
 
 	pci_intx_for_msi(dev, 0);
 	msi_set_enable(dev, 0);
-	arch_restore_msi_irqs(dev);
+	restore_msi_irqs(dev);
 
 	pci_read_config_word(dev, dev->msi_cap + PCI_MSI_FLAGS, &control);
 	msi_mask_irq(entry, msi_mask(entry->msi_attrib.multi_cap),
@@ -479,7 +461,7 @@ static void __pci_restore_msix_state(struct pci_dev *dev)
 	msix_clear_and_set_ctrl(dev, 0,
 				PCI_MSIX_FLAGS_ENABLE | PCI_MSIX_FLAGS_MASKALL);
 
-	arch_restore_msi_irqs(dev);
+	restore_msi_irqs(dev);
 	list_for_each_entry(entry, &dev->msi_list, list) {
 		msix_mask_irq(entry, entry->masked);
 	}
@@ -650,7 +632,7 @@ static int msi_capability_init(struct pci_dev *dev, int nvec)
 	list_add_tail(&entry->list, &dev->msi_list);
 
 	/* Configure MSI capability structure */
-	ret = arch_setup_msi_irqs(dev, nvec, PCI_CAP_ID_MSI);
+	ret = setup_msi_irqs(dev, nvec, PCI_CAP_ID_MSI);
 	if (ret) {
 		msi_mask_irq(entry, mask, ~mask);
 		free_msi_irqs(dev);
@@ -766,7 +748,7 @@ static int msix_capability_init(struct pci_dev *dev,
 	if (ret)
 		return ret;
 
-	ret = arch_setup_msi_irqs(dev, nvec, PCI_CAP_ID_MSIX);
+	ret = setup_msi_irqs(dev, nvec, PCI_CAP_ID_MSIX);
 	if (ret)
 		goto out_avail;
 
@@ -853,7 +835,7 @@ static int pci_msi_check_device(struct pci_dev *dev, int nvec, int type)
 		if (bus->bus_flags & PCI_BUS_FLAGS_NO_MSI)
 			return -EINVAL;
 
-	ret = arch_msi_check_device(dev, nvec, type);
+	ret = msi_check_device(dev, nvec, type);
 	if (ret)
 		return ret;
 
-- 
1.7.1

