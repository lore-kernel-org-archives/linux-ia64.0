From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 15 Oct 2014 02:26:27 +0000
Subject: [PATCH v3 27/27] PCI/MSI: Clean up unused MSI arch functions
Message-Id: <1413342435-7876-28-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413342435-7876-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1413342435-7876-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thierry Reding <thierry.reding@gmail.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Liviu Dudau <liviu@dudau.co.uk>, Yijing Wang <wangyijing@huawei.com>

Now we use struct msi_chip in all platforms to configure
MSI/MSI-X. We can clean up the unused arch functions.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
Hi Lucas,
   I dropped the reviewed-by, because this version has a lot changes
compared to last one, I guess you may want to check it again.
---
 drivers/iommu/irq_remapping.c |    2 +-
 drivers/pci/msi.c             |  103 +++++++++++++++--------------------------
 include/linux/msi.h           |   14 ------
 include/linux/pci.h           |    8 ---
 4 files changed, 39 insertions(+), 88 deletions(-)

diff --git a/drivers/iommu/irq_remapping.c b/drivers/iommu/irq_remapping.c
index 48d57e9..77160a5 100644
--- a/drivers/iommu/irq_remapping.c
+++ b/drivers/iommu/irq_remapping.c
@@ -92,7 +92,7 @@ error:
 
 	/*
 	 * Restore altered MSI descriptor fields and prevent just destroyed
-	 * IRQs from tearing down again in default_teardown_msi_irqs()
+	 * IRQs from tearing down again in teardown_msi_irqs()
 	 */
 	msidesc->irq = 0;
 	msidesc->nvec_used = 0;
diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
index 5cbd774..b9fefe9 100644
--- a/drivers/pci/msi.c
+++ b/drivers/pci/msi.c
@@ -28,54 +28,31 @@ int pci_msi_ignore_mask;
 #define msix_table_size(flags)	((flags & PCI_MSIX_FLAGS_QSIZE) + 1)
 
 
-/* Arch hooks */
-
-int __weak arch_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc)
-{
-	struct msi_chip *chip;
-	int err;
-
-	chip = pci_msi_chip(dev->bus);
-	if (!chip || !chip->setup_irq)
-		return -EINVAL;
-
-	err = chip->setup_irq(chip, dev, desc);
-	if (err < 0)
-		return err;
-
-	return 0;
-}
-
-void __weak arch_teardown_msi_irq(unsigned int irq)
-{
-	struct msi_desc *entry = irq_get_msi_desc(irq);
-	struct msi_chip *chip = pci_msi_chip(entry->dev->bus);
-
-	if (!chip || !chip->teardown_irq)
-		return;
-
-	chip->teardown_irq(chip, irq);
-}
-
-int __weak arch_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
+int setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
 {
 	struct msi_desc *entry;
 	int ret;
 	struct msi_chip *chip;
 
 	chip = pci_msi_chip(dev->bus);
-	if (chip && chip->setup_irqs)
+	if (!chip)
+	   return -EINVAL;
+
+	if (chip->setup_irqs)
 		return chip->setup_irqs(chip, dev, nvec, type);
 
 	/*
 	 * If an architecture wants to support multiple MSI, it needs to
-	 * override arch_setup_msi_irqs()
+	 * implement chip->setup_irqs().
 	 */
 	if (type = PCI_CAP_ID_MSI && nvec > 1)
 		return 1;
 
+	if (!chip->setup_irq)
+		return -EINVAL;
+
 	list_for_each_entry(entry, &dev->msi_list, list) {
-		ret = arch_setup_msi_irq(dev, entry);
+		ret = chip->setup_irq(chip, dev, entry);
 		if (ret < 0)
 			return ret;
 		if (ret > 0)
@@ -85,13 +62,20 @@ int __weak arch_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
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
+	chip = pci_msi_chip(dev->bus);
+	if (!chip)
+		return;
+
+	if (chip->teardown_irqs)
+		return chip->teardown_irqs(chip, dev);
+
+	if (!chip->teardown_irq)
+		return;
 
 	list_for_each_entry(entry, &dev->msi_list, list) {
 		int i, nvec;
@@ -102,20 +86,10 @@ void default_teardown_msi_irqs(struct pci_dev *dev)
 		else
 			nvec = 1 << entry->msi_attrib.multiple;
 		for (i = 0; i < nvec; i++)
-			arch_teardown_msi_irq(entry->irq + i);
+			chip->teardown_irq(chip, entry->irq + i);
 	}
 }
 
-void __weak arch_teardown_msi_irqs(struct pci_dev *dev)
-{
-	struct msi_chip *chip = pci_msi_chip(dev->bus);
-
-	if (chip && chip->teardown_irqs)
-		return chip->teardown_irqs(chip, dev);
-
-	return default_teardown_msi_irqs(dev);
-}
-
 static void default_restore_msi_irq(struct pci_dev *dev, int irq)
 {
 	struct msi_desc *entry;
@@ -134,10 +108,18 @@ static void default_restore_msi_irq(struct pci_dev *dev, int irq)
 		__write_msi_msg(entry, &entry->msg);
 }
 
-void __weak arch_restore_msi_irqs(struct pci_dev *dev)
+static void default_restore_msi_irqs(struct pci_dev *dev)
 {
-	struct msi_chip *chip = pci_msi_chip(dev->bus);
+	struct msi_desc *entry = NULL;
+
+	list_for_each_entry(entry, &dev->msi_list, list) {
+		default_restore_msi_irq(dev, entry->irq);
+	}
+}
 
+static void restore_msi_irqs(struct pci_dev *dev)
+{
+	struct msi_chip *chip = pci_msi_chip(dev->bus);
 	if (chip && chip->restore_irqs)
              return chip->restore_irqs(chip, dev);
 
@@ -250,15 +232,6 @@ void unmask_msi_irq(struct irq_data *data)
 	msi_set_mask_bit(data, 0);
 }
 
-void default_restore_msi_irqs(struct pci_dev *dev)
-{
-	struct msi_desc *entry;
-
-	list_for_each_entry(entry, &dev->msi_list, list) {
-		default_restore_msi_irq(dev, entry->irq);
-	}
-}
-
 void __read_msi_msg(struct msi_desc *entry, struct msi_msg *msg)
 {
 	BUG_ON(entry->dev->current_state != PCI_D0);
@@ -376,7 +349,7 @@ static void free_msi_irqs(struct pci_dev *dev)
 			BUG_ON(irq_has_action(entry->irq + i));
 	}
 
-	arch_teardown_msi_irqs(dev);
+	teardown_msi_irqs(dev);
 
 	list_for_each_entry_safe(entry, tmp, &dev->msi_list, list) {
 		if (entry->msi_attrib.is_msix) {
@@ -435,7 +408,7 @@ static void __pci_restore_msi_state(struct pci_dev *dev)
 
 	pci_intx_for_msi(dev, 0);
 	msi_set_enable(dev, 0);
-	arch_restore_msi_irqs(dev);
+	restore_msi_irqs(dev);
 
 	pci_read_config_word(dev, dev->msi_cap + PCI_MSI_FLAGS, &control);
 	msi_mask_irq(entry, msi_mask(entry->msi_attrib.multi_cap),
@@ -458,7 +431,7 @@ static void __pci_restore_msix_state(struct pci_dev *dev)
 	msix_clear_and_set_ctrl(dev, 0,
 				PCI_MSIX_FLAGS_ENABLE | PCI_MSIX_FLAGS_MASKALL);
 
-	arch_restore_msi_irqs(dev);
+	restore_msi_irqs(dev);
 	list_for_each_entry(entry, &dev->msi_list, list) {
 		msix_mask_irq(entry, entry->masked);
 	}
@@ -628,7 +601,7 @@ static int msi_capability_init(struct pci_dev *dev, int nvec)
 	list_add_tail(&entry->list, &dev->msi_list);
 
 	/* Configure MSI capability structure */
-	ret = arch_setup_msi_irqs(dev, nvec, PCI_CAP_ID_MSI);
+	ret = setup_msi_irqs(dev, nvec, PCI_CAP_ID_MSI);
 	if (ret) {
 		msi_mask_irq(entry, mask, ~mask);
 		free_msi_irqs(dev);
@@ -743,7 +716,7 @@ static int msix_capability_init(struct pci_dev *dev,
 	if (ret)
 		return ret;
 
-	ret = arch_setup_msi_irqs(dev, nvec, PCI_CAP_ID_MSIX);
+	ret = setup_msi_irqs(dev, nvec, PCI_CAP_ID_MSIX);
 	if (ret)
 		goto out_avail;
 
diff --git a/include/linux/msi.h b/include/linux/msi.h
index eb5ae36..65b0927 100644
--- a/include/linux/msi.h
+++ b/include/linux/msi.h
@@ -52,20 +52,6 @@ struct msi_desc {
 	struct msi_msg msg;
 };
 
-/*
- * The arch hooks to setup up msi irqs. Those functions are
- * implemented as weak symbols so that they /can/ be overriden by
- * architecture specific code if needed.
- */
-int arch_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc);
-void arch_teardown_msi_irq(unsigned int irq);
-int arch_setup_msi_irqs(struct pci_dev *dev, int nvec, int type);
-void arch_teardown_msi_irqs(struct pci_dev *dev);
-void arch_restore_msi_irqs(struct pci_dev *dev);
-
-void default_teardown_msi_irqs(struct pci_dev *dev);
-void default_restore_msi_irqs(struct pci_dev *dev);
-
 struct msi_chip {
 	struct module *owner;
 	struct device *dev;
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 7a48b40..b28cc03 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1433,14 +1433,6 @@ static inline int pci_get_new_domain_nr(void) { return -ENOSYS; }
 
 #include <asm/pci.h>
 
-/* Just avoid compile error, will be clean up later */
-#ifdef CONFIG_PCI_MSI
-
-#ifndef pci_msi_chip
-#define pci_msi_chip(bus)	NULL
-#endif
-
-#endif
 
 /* these helpers provide future and backwards compatibility
  * for accessing popular PCI BAR info */
-- 
1.7.1

