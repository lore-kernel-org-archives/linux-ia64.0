From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 25 Sep 2014 02:50:51 +0000
Subject: [PATCH v2 07/22] PCI/MSI: Refactor struct msi_chip to make it become more common
Message-Id: <1411614872-4009-8-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1411614872-4009-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1411614872-4009-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thierry Reding <thierry.reding@gmail.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Yijing Wang <wangyijing@huawei.com>

Now there are a lot of __weak arch functions in MSI code.
These functions make MSI driver complex. Thierry Reding Introduced
a new MSI chip framework to configure MSI/MSI-X irq in ARM. Use
the new MSI chip framework to refactor all other platform MSI
arch code to eliminate weak arch MSI functions. This patch add
.restore_irq() and .setup_irqs() to make it become more common.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Reviewed-by: Lucas Stach <l.stach@pengutronix.de>
---
 drivers/pci/msi.c   |   15 +++++++++++++++
 include/linux/msi.h |    3 +++
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
index 3acbe65..d10edee 100644
--- a/drivers/pci/msi.c
+++ b/drivers/pci/msi.c
@@ -64,6 +64,11 @@ int __weak arch_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
 {
 	struct msi_desc *entry;
 	int ret;
+	struct msi_chip *chip;
+
+	chip = arch_find_msi_chip(dev);
+	if (chip && chip->setup_irqs)
+		return chip->setup_irqs(dev, nvec, type);
 
 	/*
 	 * If an architecture wants to support multiple MSI, it needs to
@@ -106,6 +111,11 @@ void default_teardown_msi_irqs(struct pci_dev *dev)
 
 void __weak arch_teardown_msi_irqs(struct pci_dev *dev)
 {
+	struct msi_chip *chip = arch_find_msi_chip(dev);
+
+	if (chip && chip->teardown_irqs)
+		return chip->teardown_irqs(dev);
+
 	return default_teardown_msi_irqs(dev);
 }
 
@@ -129,6 +139,11 @@ static void default_restore_msi_irq(struct pci_dev *dev, int irq)
 
 void __weak arch_restore_msi_irqs(struct pci_dev *dev)
 {
+	struct msi_chip *chip = arch_find_msi_chip(dev);
+
+	if (chip && chip->restore_irqs)
+		return chip->restore_irqs(dev);
+
 	return default_restore_msi_irqs(dev);
 }
 
diff --git a/include/linux/msi.h b/include/linux/msi.h
index 6fdc5c6..4cf1f31 100644
--- a/include/linux/msi.h
+++ b/include/linux/msi.h
@@ -69,7 +69,10 @@ struct msi_chip {
 	struct list_head list;
 
 	int (*setup_irq)(struct pci_dev *dev, struct msi_desc *desc);
+	int (*setup_irqs)(struct pci_dev *dev, int nvec, int type);
 	void (*teardown_irq)(unsigned int irq);
+	void (*teardown_irqs)(struct pci_dev *dev);
+	void (*restore_irqs)(struct pci_dev *dev);
 };
 
 #endif /* LINUX_MSI_H */
-- 
1.7.1

