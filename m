From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 27 Oct 2014 12:45:46 +0000
Subject: [PATCH 15/16] tile/MSI: Use MSI controller framework to configure MSI/MSI-X irq
Message-Id: <1414416142-31239-16-git-send-email-wangyijing@huawei.com>
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
 arch/tile/include/asm/pci.h |    2 ++
 arch/tile/kernel/pci_gx.c   |   18 ++++++++++++++++--
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/arch/tile/include/asm/pci.h b/arch/tile/include/asm/pci.h
index dfedd7a..3ebd66b 100644
--- a/arch/tile/include/asm/pci.h
+++ b/arch/tile/include/asm/pci.h
@@ -152,6 +152,7 @@ struct pci_controller {
 	int pio_io_index;	/* PIO region index for I/O space access */
 #endif
 
+	struct msi_controller *msi_ctrl;
 	/*
 	 * Mem-Map regions for all the memory controllers so that Linux can
 	 * map all of its physical memory space to the PCI bus.
@@ -179,6 +180,7 @@ struct pci_controller {
 	int irq_intx_table[4];
 };
 
+extern struct msi_controller tilegx_msi_ctrl;
 extern struct pci_controller pci_controllers[TILEGX_NUM_TRIO * TILEGX_TRIO_PCIES];
 extern gxio_trio_context_t trio_contexts[TILEGX_NUM_TRIO];
 extern int num_trio_shims;
diff --git a/arch/tile/kernel/pci_gx.c b/arch/tile/kernel/pci_gx.c
index e39f9c5..6bf5a24 100644
--- a/arch/tile/kernel/pci_gx.c
+++ b/arch/tile/kernel/pci_gx.c
@@ -887,6 +887,7 @@ int __init pcibios_init(void)
 					controller->mem_offset);
 		pci_add_resource(&resources, &controller->io_space);
 		controller->first_busno = next_busno;
+		controller->msi_ctrl = &tilegx_msi_ctrl;
 		bus = pci_scan_root_bus(NULL, next_busno, controller->ops,
 					controller, &resources);
 		controller->root_bus = bus;
@@ -1485,7 +1486,15 @@ static struct irq_chip tilegx_msi_chip = {
 	/* TBD: support set_affinity. */
 };
 
-int arch_setup_msi_irq(struct pci_dev *pdev, struct msi_desc *desc)
+struct msi_controller *pcibios_msi_controller(struct pci_bus *bus)
+{
+	struct pci_controller *controller = bus->sysdata;
+
+	return controller->msi_ctrl;
+}
+
+static int tile_setup_msi_irq(struct msi_controller *ctrl,
+		struct pci_dev *pdev, struct msi_desc *desc)
 {
 	struct pci_controller *controller;
 	gxio_trio_context_t *trio_context;
@@ -1604,7 +1613,12 @@ is_64_failure:
 	return ret;
 }
 
-void arch_teardown_msi_irq(unsigned int irq)
+static void tile_teardown_msi_irq(struct msi_controller *ctrl, unsigned int irq)
 {
 	irq_free_hwirq(irq);
 }
+
+struct msi_controller tilegx_msi_ctrl = {
+	.setup_irq = tile_setup_msi_irq,
+	.teardown_irq = tile_teardown_msi_irq,
+};
-- 
1.7.1

