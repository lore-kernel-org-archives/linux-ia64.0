From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 27 Oct 2014 12:47:00 +0000
Subject: [PATCH 07/16] MIPS/Octeon/MSI: Use MSI controller framework to configure MSI/MSI-X irq
Message-Id: <1414416142-31239-8-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1414416142-31239-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1414416142-31239-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thierry Reding <thierry.reding@gmail.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Yijing Wang <wangyijing@huawei.com>

Use MSI controller framework instead of arch MSI functions to configure
MSI/MSI-X irq. So we can manage MSI/MSI-X irq in a unified framework.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/mips/include/asm/octeon/pci-octeon.h |    4 +++
 arch/mips/pci/msi-octeon.c                |   31 ++++++++++++++++------------
 arch/mips/pci/pci-octeon.c                |    3 ++
 3 files changed, 25 insertions(+), 13 deletions(-)

diff --git a/arch/mips/include/asm/octeon/pci-octeon.h b/arch/mips/include/asm/octeon/pci-octeon.h
index 64ba56a..61c038d 100644
--- a/arch/mips/include/asm/octeon/pci-octeon.h
+++ b/arch/mips/include/asm/octeon/pci-octeon.h
@@ -66,4 +66,8 @@ enum octeon_dma_bar_type {
  */
 extern enum octeon_dma_bar_type octeon_dma_bar_type;
 
+#ifdef CONFIG_PCI_MSI
+extern struct msi_controller octeon_msi_ctrl;
+#endif
+
 #endif
diff --git a/arch/mips/pci/msi-octeon.c b/arch/mips/pci/msi-octeon.c
index 63bbe07..30976da 100644
--- a/arch/mips/pci/msi-octeon.c
+++ b/arch/mips/pci/msi-octeon.c
@@ -57,7 +57,7 @@ static int msi_irq_size;
  *
  * Returns 0 on success.
  */
-int arch_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc)
+static int octeon_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc)
 {
 	struct msi_msg msg;
 	u16 control;
@@ -132,12 +132,12 @@ msi_irq_allocated:
 	/* Make sure the search for available interrupts didn't fail */
 	if (irq >= 64) {
 		if (request_private_bits) {
-			pr_err("arch_setup_msi_irq: Unable to find %d free interrupts, trying just one",
-			       1 << request_private_bits);
+			pr_err("%s: Unable to find %d free interrupts, trying just one",
+			       __func__, 1 << request_private_bits);
 			request_private_bits = 0;
 			goto try_only_one;
 		} else
-			panic("arch_setup_msi_irq: Unable to find a free MSI interrupt");
+			panic("%s: Unable to find a free MSI interrupt", __func__);
 	}
 
 	/* MSI interrupts start at logical IRQ OCTEON_IRQ_MSI_BIT0 */
@@ -168,7 +168,7 @@ msi_irq_allocated:
 		msg.address_hi = (0 + CVMX_SLI_PCIE_MSI_RCV) >> 32;
 		break;
 	default:
-		panic("arch_setup_msi_irq: Invalid octeon_dma_bar_type");
+		panic("%s: Invalid octeon_dma_bar_type", __func__);
 	}
 	msg.data = irq - OCTEON_IRQ_MSI_BIT0;
 
@@ -182,7 +182,8 @@ msi_irq_allocated:
 	return 0;
 }
 
-int arch_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
+static int octeon_setup_msi_irqs(struct msi_controller *ctrl, struct pci_dev *dev,
+		int nvec, int type)
 {
 	struct msi_desc *entry;
 	int ret;
@@ -201,7 +202,7 @@ int arch_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
 		return 1;
 
 	list_for_each_entry(entry, &dev->msi_list, list) {
-		ret = arch_setup_msi_irq(dev, entry);
+		ret = octeon_setup_msi_irq(dev, entry);
 		if (ret < 0)
 			return ret;
 		if (ret > 0)
@@ -210,14 +211,13 @@ int arch_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
 
 	return 0;
 }
-
 /**
  * Called when a device no longer needs its MSI interrupts. All
  * MSI interrupts for the device are freed.
  *
  * @irq:    The devices first irq number. There may be multple in sequence.
  */
-void arch_teardown_msi_irq(unsigned int irq)
+static void octeon_teardown_msi_irq(struct msi_controller *ctrl, unsigned int irq)
 {
 	int number_irqs;
 	u64 bitmask;
@@ -226,8 +226,8 @@ void arch_teardown_msi_irq(unsigned int irq)
 
 	if ((irq < OCTEON_IRQ_MSI_BIT0)
 		|| (irq > msi_irq_size + OCTEON_IRQ_MSI_BIT0))
-		panic("arch_teardown_msi_irq: Attempted to teardown illegal "
-		      "MSI interrupt (%d)", irq);
+		panic("%s: Attempted to teardown illegal "
+			"MSI interrupt (%d)", __func__, irq);
 
 	irq -= OCTEON_IRQ_MSI_BIT0;
 	index = irq / 64;
@@ -249,8 +249,8 @@ void arch_teardown_msi_irq(unsigned int irq)
 	/* Shift the mask to the correct bit location */
 	bitmask <<= irq0;
 	if ((msi_free_irq_bitmask[index] & bitmask) != bitmask)
-		panic("arch_teardown_msi_irq: Attempted to teardown MSI "
-		      "interrupt (%d) not in use", irq);
+		panic("%s: Attempted to teardown MSI "
+			"interrupt (%d) not in use", __func__, irq);
 
 	/* Checks are done, update the in use bitmask */
 	spin_lock(&msi_free_irq_bitmask_lock);
@@ -259,6 +259,11 @@ void arch_teardown_msi_irq(unsigned int irq)
 	spin_unlock(&msi_free_irq_bitmask_lock);
 }
 
+struct msi_controller octeon_msi_ctrl = {
+	.setup_irqs = octeon_setup_msi_irqs,
+	.teardown_irq = octeon_teardown_msi_irq,
+};
+
 static DEFINE_RAW_SPINLOCK(octeon_irq_msi_lock);
 
 static u64 msi_rcv_reg[4];
diff --git a/arch/mips/pci/pci-octeon.c b/arch/mips/pci/pci-octeon.c
index 59cccd9..9935448 100644
--- a/arch/mips/pci/pci-octeon.c
+++ b/arch/mips/pci/pci-octeon.c
@@ -356,6 +356,9 @@ static struct pci_controller octeon_pci_controller = {
 	.io_resource = &octeon_pci_io_resource,
 	.io_offset = 0,
 	.io_map_base = OCTEON_PCI_IOSPACE_BASE,
+#ifdef CONFIG_PCI_MSI
+	.msi_ctrl = &octeon_msi_ctrl,
+#endif
 };
 
 
-- 
1.7.1

