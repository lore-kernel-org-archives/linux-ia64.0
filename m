From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 27 Oct 2014 12:45:20 +0000
Subject: [PATCH 16/16] PCI/MSI: Clean up unused MSI arch functions
Message-Id: <1414416142-31239-17-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1414416142-31239-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1414416142-31239-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thierry Reding <thierry.reding@gmail.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Yijing Wang <wangyijing@huawei.com>

Now we use MSI controller in all platforms to configure
MSI/MSI-X. We can clean up the unused arch functions.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Reviewed-by: Lucas Stach <l.stach@pengutronix.de>
---
 drivers/pci/msi.c   |   90 ++++++++++++++++++--------------------------------
 include/linux/msi.h |   11 ------
 2 files changed, 33 insertions(+), 68 deletions(-)

diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
index 0e1da3e..cdb4634 100644
--- a/drivers/pci/msi.c
+++ b/drivers/pci/msi.c
@@ -27,7 +27,6 @@ int pci_msi_ignore_mask;
 
 #define msix_table_size(flags)	((flags & PCI_MSIX_FLAGS_QSIZE) + 1)
 
-
 /* Arch hooks */
 
 struct msi_controller * __weak pcibios_msi_controller(struct pci_bus *bus)
@@ -35,56 +34,31 @@ struct msi_controller * __weak pcibios_msi_controller(struct pci_bus *bus)
 	return NULL;
 }
 
-struct msi_controller *pci_msi_controller(struct pci_bus *bus)
-{
-	return pcibios_msi_controller(bus);
-}
-
-int __weak arch_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc)
-{
-	struct msi_controller *ctrl = pci_msi_controller(dev->bus);
-	int err;
-
-	if (!ctrl || !ctrl->setup_irq)
-		return -EINVAL;
-
-	err = ctrl->setup_irq(ctrl, dev, desc);
-	if (err < 0)
-		return err;
-
-	return 0;
-}
-
-void __weak arch_teardown_msi_irq(unsigned int irq)
-{
-	struct msi_desc *entry = irq_get_msi_desc(irq);
-	struct msi_controller *ctrl = pci_msi_controller(entry->dev->bus);
-
-	if (!ctrl || !ctrl->teardown_irq)
-		return;
-
-	ctrl->teardown_irq(ctrl, irq);
-}
-
-int __weak arch_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
+int setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
 {
 	struct msi_desc *entry;
 	int ret;
 	struct msi_controller *ctrl;
 
-	ctrl = pci_msi_controller(dev->bus);
-	if (ctrl && ctrl->setup_irqs)
+	ctrl = pcibios_msi_controller(dev->bus);
+	if (!ctrl)
+		return -EINVAL;
+
+	if (ctrl->setup_irqs)
 		return ctrl->setup_irqs(ctrl, dev, nvec, type);
 
 	/*
 	 * If an architecture wants to support multiple MSI, it needs to
-	 * override arch_setup_msi_irqs()
+	 * implement ctrl->setup_irqs().
 	 */
 	if (type = PCI_CAP_ID_MSI && nvec > 1)
 		return 1;
 
+	if (!ctrl->setup_irq)
+		return -EINVAL;
+
 	list_for_each_entry(entry, &dev->msi_list, list) {
-		ret = arch_setup_msi_irq(dev, entry);
+		ret = ctrl->setup_irq(ctrl, dev, entry);
 		if (ret < 0)
 			return ret;
 		if (ret > 0)
@@ -101,6 +75,10 @@ int __weak arch_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
 void default_teardown_msi_irqs(struct pci_dev *dev)
 {
 	struct msi_desc *entry;
+	struct msi_controller *ctrl = pcibios_msi_controller(dev->bus);
+
+	if (!ctrl->teardown_irq)
+		return;
 
 	list_for_each_entry(entry, &dev->msi_list, list) {
 		int i, nvec;
@@ -111,18 +89,18 @@ void default_teardown_msi_irqs(struct pci_dev *dev)
 		else
 			nvec = 1 << entry->msi_attrib.multiple;
 		for (i = 0; i < nvec; i++)
-			arch_teardown_msi_irq(entry->irq + i);
+			ctrl->teardown_irq(ctrl, entry->irq + i);
 	}
 }
 
-void __weak arch_teardown_msi_irqs(struct pci_dev *dev)
+static void teardown_msi_irqs(struct pci_dev *dev)
 {
-	struct msi_controller *ctrl = pci_msi_controller(dev->bus);
+	struct msi_controller *ctrl = pcibios_msi_controller(dev->bus);
 
 	if (ctrl && ctrl->teardown_irqs)
 		return ctrl->teardown_irqs(ctrl, dev);
 
-	return default_teardown_msi_irqs(dev);
+	default_teardown_msi_irqs(dev);
 }
 
 static void default_restore_msi_irq(struct pci_dev *dev, int irq)
@@ -143,10 +121,17 @@ static void default_restore_msi_irq(struct pci_dev *dev, int irq)
 		__write_msi_msg(entry, &entry->msg);
 }
 
-void __weak arch_restore_msi_irqs(struct pci_dev *dev)
+void default_restore_msi_irqs(struct pci_dev *dev)
 {
-	struct msi_controller *ctrl = pci_msi_controller(dev->bus);
+	struct msi_desc *entry;
 
+	list_for_each_entry(entry, &dev->msi_list, list)
+		default_restore_msi_irq(dev, entry->irq);
+}
+
+static void restore_msi_irqs(struct pci_dev *dev)
+{
+	struct msi_controller *ctrl = pcibios_msi_controller(dev->bus);
 	if (ctrl && ctrl->restore_irqs)
              return ctrl->restore_irqs(ctrl, dev);
 
@@ -259,15 +244,6 @@ void unmask_msi_irq(struct irq_data *data)
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
@@ -387,7 +363,7 @@ static void free_msi_irqs(struct pci_dev *dev)
 			BUG_ON(irq_has_action(entry->irq + i));
 	}
 
-	arch_teardown_msi_irqs(dev);
+	teardown_msi_irqs(dev);
 
 	list_for_each_entry_safe(entry, tmp, &dev->msi_list, list) {
 		if (entry->msi_attrib.is_msix) {
@@ -446,7 +422,7 @@ static void __pci_restore_msi_state(struct pci_dev *dev)
 
 	pci_intx_for_msi(dev, 0);
 	msi_set_enable(dev, 0);
-	arch_restore_msi_irqs(dev);
+	restore_msi_irqs(dev);
 
 	pci_read_config_word(dev, dev->msi_cap + PCI_MSI_FLAGS, &control);
 	msi_mask_irq(entry, msi_mask(entry->msi_attrib.multi_cap),
@@ -469,7 +445,7 @@ static void __pci_restore_msix_state(struct pci_dev *dev)
 	msix_clear_and_set_ctrl(dev, 0,
 				PCI_MSIX_FLAGS_ENABLE | PCI_MSIX_FLAGS_MASKALL);
 
-	arch_restore_msi_irqs(dev);
+	restore_msi_irqs(dev);
 	list_for_each_entry(entry, &dev->msi_list, list) {
 		msix_mask_irq(entry, entry->masked);
 	}
@@ -639,7 +615,7 @@ static int msi_capability_init(struct pci_dev *dev, int nvec)
 	list_add_tail(&entry->list, &dev->msi_list);
 
 	/* Configure MSI capability structure */
-	ret = arch_setup_msi_irqs(dev, nvec, PCI_CAP_ID_MSI);
+	ret = setup_msi_irqs(dev, nvec, PCI_CAP_ID_MSI);
 	if (ret) {
 		msi_mask_irq(entry, mask, ~mask);
 		free_msi_irqs(dev);
@@ -754,7 +730,7 @@ static int msix_capability_init(struct pci_dev *dev,
 	if (ret)
 		return ret;
 
-	ret = arch_setup_msi_irqs(dev, nvec, PCI_CAP_ID_MSIX);
+	ret = setup_msi_irqs(dev, nvec, PCI_CAP_ID_MSIX);
 	if (ret)
 		goto out_avail;
 
diff --git a/include/linux/msi.h b/include/linux/msi.h
index 4426cb4..e4eb137 100644
--- a/include/linux/msi.h
+++ b/include/linux/msi.h
@@ -51,19 +51,8 @@ struct msi_desc {
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
 
 void default_teardown_msi_irqs(struct pci_dev *dev);
-void default_restore_msi_irqs(struct pci_dev *dev);
 
 struct msi_controller {
 	struct module *owner;
-- 
1.7.1

