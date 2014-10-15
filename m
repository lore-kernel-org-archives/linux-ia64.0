From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 15 Oct 2014 02:33:46 +0000
Subject: [PATCH v3 11/27] PCI/MSI: Refactor struct msi_chip to make it become more common
Message-Id: <1413342435-7876-12-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413342435-7876-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1413342435-7876-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thierry Reding <thierry.reding@gmail.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Liviu Dudau <liviu@dudau.co.uk>, Yijing Wang <wangyijing@huawei.com>

Now there are a lot of __weak arch functions in MSI code.
These functions make MSI driver complex. Thierry introduced
MSI chip framework to configure MSI/MSI-X irq in arm. Use
MSI chip framework to refactor all other platform MSI
code to eliminate weak arch MSI functions. This patch add
.restore_irqs(), .teardown_irqs() and .setup_irqs() to make it
become more common.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Reviewed-by: Lucas Stach <l.stach@pengutronix.de>
---
 drivers/pci/msi.c   |   15 +++++++++++++++
 include/linux/msi.h |    4 ++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
index 56e54ad..5cbd774 100644
--- a/drivers/pci/msi.c
+++ b/drivers/pci/msi.c
@@ -61,6 +61,11 @@ int __weak arch_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
 {
 	struct msi_desc *entry;
 	int ret;
+	struct msi_chip *chip;
+
+	chip = pci_msi_chip(dev->bus);
+	if (chip && chip->setup_irqs)
+		return chip->setup_irqs(chip, dev, nvec, type);
 
 	/*
 	 * If an architecture wants to support multiple MSI, it needs to
@@ -103,6 +108,11 @@ void default_teardown_msi_irqs(struct pci_dev *dev)
 
 void __weak arch_teardown_msi_irqs(struct pci_dev *dev)
 {
+	struct msi_chip *chip = pci_msi_chip(dev->bus);
+
+	if (chip && chip->teardown_irqs)
+		return chip->teardown_irqs(chip, dev);
+
 	return default_teardown_msi_irqs(dev);
 }
 
@@ -126,6 +136,11 @@ static void default_restore_msi_irq(struct pci_dev *dev, int irq)
 
 void __weak arch_restore_msi_irqs(struct pci_dev *dev)
 {
+	struct msi_chip *chip = pci_msi_chip(dev->bus);
+
+	if (chip && chip->restore_irqs)
+             return chip->restore_irqs(chip, dev);
+
 	return default_restore_msi_irqs(dev);
 }
 
diff --git a/include/linux/msi.h b/include/linux/msi.h
index 175aa21..eb5ae36 100644
--- a/include/linux/msi.h
+++ b/include/linux/msi.h
@@ -74,7 +74,11 @@ struct msi_chip {
 
 	int (*setup_irq)(struct msi_chip *chip, struct pci_dev *dev,
 			 struct msi_desc *desc);
+	int (*setup_irqs)(struct msi_chip *chip, struct pci_dev *dev,
+			int nvec, int type);
 	void (*teardown_irq)(struct msi_chip *chip, unsigned int irq);
+	void (*teardown_irqs)(struct msi_chip *chip, struct pci_dev *dev);
+	void (*restore_irqs)(struct msi_chip *chip, struct pci_dev *dev);
 };
 
 #endif /* LINUX_MSI_H */
-- 
1.7.1

