From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 12 Aug 2014 07:26:12 +0000
Subject: [RFC PATCH 19/20] tile/MSI: Use msi_chip instead of arch func to configure MSI/MSI-X
Message-Id: <1407828373-24322-20-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1407828373-24322-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1407828373-24322-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-pci@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, arnab.basu@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Yijing Wang <wangyijing@huawei.com>

Introduce a new struct msi_chip tile_msi_chip instead of weak arch
functions to configure MSI/MSI-X.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/tile/kernel/pci_gx.c |   20 +++++++++++++++-----
 1 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/arch/tile/kernel/pci_gx.c b/arch/tile/kernel/pci_gx.c
index e39f9c5..d1f308c 100644
--- a/arch/tile/kernel/pci_gx.c
+++ b/arch/tile/kernel/pci_gx.c
@@ -1485,7 +1485,7 @@ static struct irq_chip tilegx_msi_chip = {
 	/* TBD: support set_affinity. */
 };
 
-int arch_setup_msi_irq(struct pci_dev *pdev, struct msi_desc *desc)
+int tile_setup_msi_irq(struct device *dev, struct msi_desc *desc)
 {
 	struct pci_controller *controller;
 	gxio_trio_context_t *trio_context;
@@ -1510,7 +1510,7 @@ int arch_setup_msi_irq(struct pci_dev *pdev, struct msi_desc *desc)
 	 * Most PCIe endpoint devices do support 64-bit message addressing.
 	 */
 	if (desc->msi_attrib.is_64 = 0) {
-		dev_printk(KERN_INFO, &pdev->dev,
+		dev_printk(KERN_INFO, dev,
 			"64-bit MSI message address not supported, "
 			"falling back to legacy interrupts.\n");
 
@@ -1549,7 +1549,7 @@ int arch_setup_msi_irq(struct pci_dev *pdev, struct msi_desc *desc)
 		/* SQ regions are out, allocate from map mem regions. */
 		mem_map = gxio_trio_alloc_memory_maps(trio_context, 1, 0, 0);
 		if (mem_map < 0) {
-			dev_printk(KERN_INFO, &pdev->dev,
+			dev_printk(KERN_INFO, dev,
 				"%s Mem-Map alloc failure. "
 				"Failed to initialize MSI interrupts. "
 				"Falling back to legacy interrupts.\n",
@@ -1580,7 +1580,7 @@ int arch_setup_msi_irq(struct pci_dev *pdev, struct msi_desc *desc)
 					mem_map, mem_map_base, mem_map_limit,
 					trio_context->asid);
 	if (ret < 0) {
-		dev_printk(KERN_INFO, &pdev->dev, "HV MSI config failed.\n");
+		dev_printk(KERN_INFO, dev, "HV MSI config failed.\n");
 
 		goto hv_msi_config_failure;
 	}
@@ -1604,7 +1604,17 @@ is_64_failure:
 	return ret;
 }
 
-void arch_teardown_msi_irq(unsigned int irq)
+void tile_teardown_msi_irq(unsigned int irq)
 {
 	irq_free_hwirq(irq);
 }
+
+struct msi_chip tile_msi_chip = {
+	.setup_irq = tile_setup_msi_irq,
+	.teardown_irq = tile_teardown_msi_irq,
+};
+
+struct msi_chip *arch_get_match_msi_chip(struct device *dev)
+{
+	return &tile_msi_chip;
+}
-- 
1.7.1

