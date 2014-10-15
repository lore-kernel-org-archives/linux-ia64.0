From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 15 Oct 2014 02:31:31 +0000
Subject: [PATCH v3 19/27] MIPS/Xlp/MSI: Use MSI chip framework to configure MSI/MSI-X irq
Message-Id: <1413342435-7876-20-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413342435-7876-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1413342435-7876-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thierry Reding <thierry.reding@gmail.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Liviu Dudau <liviu@dudau.co.uk>, Yijing Wang <wangyijing@huawei.com>

Use MSI chip framework instead of arch MSI functions to configure
MSI/MSI-X IRQ. So we can manage MSI/MSI-X irq in a unified framework.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/mips/include/asm/netlogic/xlp-hal/pcibus.h |    1 +
 arch/mips/pci/msi-xlp.c                         |   11 +++++++++--
 arch/mips/pci/pci-xlp.c                         |    3 +++
 3 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/arch/mips/include/asm/netlogic/xlp-hal/pcibus.h b/arch/mips/include/asm/netlogic/xlp-hal/pcibus.h
index 91540f4..90646ad 100644
--- a/arch/mips/include/asm/netlogic/xlp-hal/pcibus.h
+++ b/arch/mips/include/asm/netlogic/xlp-hal/pcibus.h
@@ -103,6 +103,7 @@
 
 #ifdef CONFIG_PCI_MSI
 void xlp_init_node_msi_irqs(int node, int link);
+extern struct msi_chip xlp_chip;
 #else
 static inline void xlp_init_node_msi_irqs(int node, int link) {}
 #endif
diff --git a/arch/mips/pci/msi-xlp.c b/arch/mips/pci/msi-xlp.c
index e469dc7..cca2257 100644
--- a/arch/mips/pci/msi-xlp.c
+++ b/arch/mips/pci/msi-xlp.c
@@ -245,7 +245,8 @@ static struct irq_chip xlp_msix_chip = {
 	.irq_unmask	= unmask_msi_irq,
 };
 
-void arch_teardown_msi_irq(unsigned int irq)
+static void xlp_teardown_msi_irq(struct msi_chip *chip,
+		unsigned int irq)
 {
 }
 
@@ -450,7 +451,8 @@ static int xlp_setup_msix(uint64_t lnkbase, int node, int link,
 	return 0;
 }
 
-int arch_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc)
+static int xlp_setup_msi_irq(struct msi_chip *chip,
+		struct pci_dev *dev, struct msi_desc *desc)
 {
 	struct pci_dev *lnkdev;
 	uint64_t lnkbase;
@@ -472,6 +474,11 @@ int arch_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc)
 		return xlp_setup_msi(lnkbase, node, link, desc);
 }
 
+struct msi_chip xlp_chip = {
+	.setup_irq = xlp_setup_msi_irq,
+	.teardown_irq = xlp_teardown_msi_irq,
+};
+
 void __init xlp_init_node_msi_irqs(int node, int link)
 {
 	struct nlm_soc_info *nodep;
diff --git a/arch/mips/pci/pci-xlp.c b/arch/mips/pci/pci-xlp.c
index 7babf01..5d7b6a0 100644
--- a/arch/mips/pci/pci-xlp.c
+++ b/arch/mips/pci/pci-xlp.c
@@ -174,6 +174,9 @@ struct pci_controller nlm_pci_controller = {
 	.mem_offset	= 0x00000000UL,
 	.io_resource	= &nlm_pci_io_resource,
 	.io_offset	= 0x00000000UL,
+#ifdef CONFIG_PCI_MSI
+	.msi_chip = &xlp_chip,
+#endif
 };
 
 struct pci_dev *xlp_get_pcie_link(const struct pci_dev *dev)
-- 
1.7.1

