From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 25 Sep 2014 02:57:27 +0000
Subject: [PATCH v2 09/22] x86/xen/MSI: Use MSI chip framework to configure MSI/MSI-X irq
Message-Id: <1411614872-4009-10-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1411614872-4009-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1411614872-4009-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thierry Reding <thierry.reding@gmail.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Yijing Wang <wangyijing@huawei.com>

Use MSI chip framework instead of arch MSI functions to configure
MSI/MSI-X irq. So we can manage MSI/MSI-X irq in a unified framework.

Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Acked-by: David Vrabel <david.vrabel@citrix.com>
Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
CC: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 arch/x86/pci/xen.c |   46 ++++++++++++++++++++++++++++++----------------
 1 files changed, 30 insertions(+), 16 deletions(-)

diff --git a/arch/x86/pci/xen.c b/arch/x86/pci/xen.c
index 84c2fce..e669ee4 100644
--- a/arch/x86/pci/xen.c
+++ b/arch/x86/pci/xen.c
@@ -376,6 +376,11 @@ static void xen_initdom_restore_msi_irqs(struct pci_dev *dev)
 }
 #endif
 
+static void xen_teardown_msi_irq(unsigned int irq)
+{
+	xen_destroy_irq(irq);
+}
+
 static void xen_teardown_msi_irqs(struct pci_dev *dev)
 {
 	struct msi_desc *msidesc;
@@ -385,19 +390,26 @@ static void xen_teardown_msi_irqs(struct pci_dev *dev)
 		xen_pci_frontend_disable_msix(dev);
 	else
 		xen_pci_frontend_disable_msi(dev);
-
-	/* Free the IRQ's and the msidesc using the generic code. */
-	default_teardown_msi_irqs(dev);
-}
-
-static void xen_teardown_msi_irq(unsigned int irq)
-{
-	xen_destroy_irq(irq);
+	
+	list_for_each_entry(msidesc, &dev->msi_list, list) {
+		int i, nvec;
+		if (msidesc->irq = 0)
+			continue;
+		if (msidesc->nvec_used)
+			nvec = msidesc->nvec_used;
+		else
+			nvec = 1 << msidesc->msi_attrib.multiple;
+		for (i = 0; i < nvec; i++)
+			xen_teardown_msi_irq(msidesc->irq + i);
+	}
 }
 
 void xen_nop_msi_mask(struct irq_data *data)
 {
 }
+
+struct msi_chip xen_msi_chip;
+
 #endif
 
 int __init pci_xen_init(void)
@@ -418,9 +430,9 @@ int __init pci_xen_init(void)
 #endif
 
 #ifdef CONFIG_PCI_MSI
-	x86_msi.setup_msi_irqs = xen_setup_msi_irqs;
-	x86_msi.teardown_msi_irq = xen_teardown_msi_irq;
-	x86_msi.teardown_msi_irqs = xen_teardown_msi_irqs;
+	xen_msi_chip.setup_irqs = xen_setup_msi_irqs;
+	xen_msi_chip.teardown_irqs = xen_teardown_msi_irqs;
+	x86_msi_chip = &xen_msi_chip;
 	msi_chip.irq_mask = xen_nop_msi_mask;
 	msi_chip.irq_unmask = xen_nop_msi_mask;
 #endif
@@ -441,8 +453,9 @@ int __init pci_xen_hvm_init(void)
 #endif
 
 #ifdef CONFIG_PCI_MSI
-	x86_msi.setup_msi_irqs = xen_hvm_setup_msi_irqs;
-	x86_msi.teardown_msi_irq = xen_teardown_msi_irq;
+	xen_msi_chip.setup_irqs = xen_hvm_setup_msi_irqs;
+	xen_msi_chip.teardown_irq = xen_teardown_msi_irq;
+	x86_msi_chip = &xen_msi_chip;
 #endif
 	return 0;
 }
@@ -499,9 +512,10 @@ int __init pci_xen_initial_domain(void)
 	int irq;
 
 #ifdef CONFIG_PCI_MSI
-	x86_msi.setup_msi_irqs = xen_initdom_setup_msi_irqs;
-	x86_msi.teardown_msi_irq = xen_teardown_msi_irq;
-	x86_msi.restore_msi_irqs = xen_initdom_restore_msi_irqs;
+	xen_msi_chip.setup_irqs = xen_initdom_setup_msi_irqs;
+	xen_msi_chip.teardown_irq = xen_teardown_msi_irq;
+	xen_msi_chip.restore_irqs = xen_initdom_restore_msi_irqs;
+	x86_msi_chip = &xen_msi_chip;
 	msi_chip.irq_mask = xen_nop_msi_mask;
 	msi_chip.irq_unmask = xen_nop_msi_mask;
 #endif
-- 
1.7.1

