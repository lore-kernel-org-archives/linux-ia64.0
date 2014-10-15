From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 15 Oct 2014 02:31:33 +0000
Subject: [PATCH v3 20/27] MIPS/Xlr/MSI: Use MSI chip framework to configure MSI/MSI-X irq
Message-Id: <1413342435-7876-21-git-send-email-wangyijing@huawei.com>
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
 arch/mips/pci/pci-xlr.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/arch/mips/pci/pci-xlr.c b/arch/mips/pci/pci-xlr.c
index 0dde803..0e611de 100644
--- a/arch/mips/pci/pci-xlr.c
+++ b/arch/mips/pci/pci-xlr.c
@@ -149,6 +149,8 @@ static struct resource nlm_pci_io_resource = {
 	.flags		= IORESOURCE_IO,
 };
 
+static struct msi_chip xlr_msi_chip;
+
 struct pci_controller nlm_pci_controller = {
 	.index		= 0,
 	.pci_ops	= &nlm_pci_ops,
@@ -156,6 +158,9 @@ struct pci_controller nlm_pci_controller = {
 	.mem_offset	= 0x00000000UL,
 	.io_resource	= &nlm_pci_io_resource,
 	.io_offset	= 0x00000000UL,
+#ifdef CONFIG_PCI_MSI
+	.msi_chip = &xlr_msi_chip,
+#endif
 };
 
 /*
@@ -214,11 +219,13 @@ static int get_irq_vector(const struct pci_dev *dev)
 }
 
 #ifdef CONFIG_PCI_MSI
-void arch_teardown_msi_irq(unsigned int irq)
+static void xlr_teardown_msi_irq(struct msi_chip *chip,
+		unsigned int irq)
 {
 }
 
-int arch_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc)
+static int xlr_setup_msi_irq(struct msi_chip *chip,
+		struct pci_dev *dev, struct msi_desc *desc)
 {
 	struct msi_msg msg;
 	struct pci_dev *lnk;
@@ -263,6 +270,12 @@ int arch_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc)
 	write_msi_msg(irq, &msg);
 	return 0;
 }
+
+static struct msi_chip xlr_msi_chip = {
+	.setup_irq = xlr_setup_msi_irq,
+	.teardown_irq = xlr_teardown_msi_irq,
+};
+
 #endif
 
 /* Extra ACK needed for XLR on chip PCI controller */
-- 
1.7.1

