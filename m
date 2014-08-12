From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 12 Aug 2014 07:26:04 +0000
Subject: [RFC PATCH 11/20] MIPS/Octeon/MSI: Use msi_chip instead of arch func to configure MSI/MSI-X
Message-Id: <1407828373-24322-12-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1407828373-24322-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1407828373-24322-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-pci@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, arnab.basu@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Yijing Wang <wangyijing@huawei.com>

Introduce a new struct msi_chip octeon_msi_chip instead of weak arch
functions to configure MSI/MSI-X.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/mips/pci/msi-octeon.c |   45 ++++++++++++++++++-------------------------
 1 files changed, 19 insertions(+), 26 deletions(-)

diff --git a/arch/mips/pci/msi-octeon.c b/arch/mips/pci/msi-octeon.c
index ab0c5d1..8098066 100644
--- a/arch/mips/pci/msi-octeon.c
+++ b/arch/mips/pci/msi-octeon.c
@@ -57,7 +57,7 @@ static int msi_irq_size;
  *
  * Returns 0 on success.
  */
-int arch_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc)
+int octeon_setup_msi_irq(struct device *dev, struct msi_desc *desc)
 {
 	struct msi_msg msg;
 	u16 control;
@@ -73,7 +73,7 @@ int arch_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc)
 	 * wants.  Most devices only want 1, which will give
 	 * configured_private_bits and request_private_bits equal 0.
 	 */
-	pci_read_config_word(dev, desc->msi_attrib.pos + PCI_MSI_FLAGS,
+	pci_read_config_word(to_pci_dev(dev), desc->msi_attrib.pos + PCI_MSI_FLAGS,
 			     &control);
 
 	/*
@@ -176,7 +176,7 @@ msi_irq_allocated:
 	/* Update the number of IRQs the device has available to it */
 	control &= ~PCI_MSI_FLAGS_QSIZE;
 	control |= request_private_bits << 4;
-	pci_write_config_word(dev, desc->msi_attrib.pos + PCI_MSI_FLAGS,
+	pci_write_config_word(to_pci_dev(dev), desc->msi_attrib.pos + PCI_MSI_FLAGS,
 			      control);
 
 	irq_set_msi_desc(irq, desc);
@@ -184,32 +184,14 @@ msi_irq_allocated:
 	return 0;
 }
 
-int arch_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
+int octeon_check_msi_device(struct device *dev, int nvec, int type)
 {
-	struct msi_desc *entry;
-	int ret;
-
 	/*
 	 * MSI-X is not supported.
 	 */
 	if (type = PCI_CAP_ID_MSIX)
 		return -EINVAL;
 
-	/*
-	 * If an architecture wants to support multiple MSI, it needs to
-	 * override arch_setup_msi_irqs()
-	 */
-	if (type = PCI_CAP_ID_MSI && nvec > 1)
-		return 1;
-
-	list_for_each_entry(entry, &dev->msi_list, list) {
-		ret = arch_setup_msi_irq(dev, entry);
-		if (ret < 0)
-			return ret;
-		if (ret > 0)
-			return -ENOSPC;
-	}
-
 	return 0;
 }
 
@@ -219,7 +201,7 @@ int arch_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
  *
  * @irq:    The devices first irq number. There may be multple in sequence.
  */
-void arch_teardown_msi_irq(unsigned int irq)
+void octeon_teardown_msi_irq(unsigned int irq)
 {
 	int number_irqs;
 	u64 bitmask;
@@ -229,7 +211,7 @@ void arch_teardown_msi_irq(unsigned int irq)
 	if ((irq < OCTEON_IRQ_MSI_BIT0)
 		|| (irq > msi_irq_size + OCTEON_IRQ_MSI_BIT0))
 		panic("arch_teardown_msi_irq: Attempted to teardown illegal "
-		      "MSI interrupt (%d)", irq);
+			"MSI interrupt (%d)", irq);
 
 	irq -= OCTEON_IRQ_MSI_BIT0;
 	index = irq / 64;
@@ -242,7 +224,7 @@ void arch_teardown_msi_irq(unsigned int irq)
 	 */
 	number_irqs = 0;
 	while ((irq0 + number_irqs < 64) &&
-	       (msi_multiple_irq_bitmask[index]
+		(msi_multiple_irq_bitmask[index]
 		& (1ull << (irq0 + number_irqs))))
 		number_irqs++;
 	number_irqs++;
@@ -252,7 +234,7 @@ void arch_teardown_msi_irq(unsigned int irq)
 	bitmask <<= irq0;
 	if ((msi_free_irq_bitmask[index] & bitmask) != bitmask)
 		panic("arch_teardown_msi_irq: Attempted to teardown MSI "
-		      "interrupt (%d) not in use", irq);
+			"interrupt (%d) not in use", irq);
 
 	/* Checks are done, update the in use bitmask */
 	spin_lock(&msi_free_irq_bitmask_lock);
@@ -261,6 +243,17 @@ void arch_teardown_msi_irq(unsigned int irq)
 	spin_unlock(&msi_free_irq_bitmask_lock);
 }
 
+struct msi_chip octeon_msi_chip = {
+	.setup_irq = octeon_setup_msi_irq,
+	.teardown_irq = octeon_teardown_msi_irq,
+	.check_device = octeon_check_msi_device,
+};
+
+struct msi_chip *arch_get_match_msi_chip(struct device *dev)
+{
+	return &octeon_msi_chip;
+}
+
 static DEFINE_RAW_SPINLOCK(octeon_irq_msi_lock);
 
 static u64 msi_rcv_reg[4];
-- 
1.7.1

