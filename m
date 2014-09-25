From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 25 Sep 2014 02:50:55 +0000
Subject: [PATCH v2 05/22] s390/MSI: Use __msi_mask_irq() instead of default_msi_mask_irq()
Message-Id: <1411614872-4009-6-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1411614872-4009-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1411614872-4009-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thierry Reding <thierry.reding@gmail.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Yijing Wang <wangyijing@huawei.com>

Now only s390/MSI use default_msi_mask_irq() and
default_msix_mask_irq(), replace them with the common
msi mask irq functions __msi_mask_irq() and __msix_mask_irq().
Remove default_msi_mask_irq() and default_msix_mask_irq().

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/s390/pci/pci.c |    4 ++--
 include/linux/msi.h |    2 --
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/arch/s390/pci/pci.c b/arch/s390/pci/pci.c
index 2fa7b14..552b990 100644
--- a/arch/s390/pci/pci.c
+++ b/arch/s390/pci/pci.c
@@ -448,9 +448,9 @@ void arch_teardown_msi_irqs(struct pci_dev *pdev)
 	/* Release MSI interrupts */
 	list_for_each_entry(msi, &pdev->msi_list, list) {
 		if (msi->msi_attrib.is_msix)
-			default_msix_mask_irq(msi, 1);
+			__msix_mask_irq(msi, 1);
 		else
-			default_msi_mask_irq(msi, 1, 1);
+			__msi_mask_irq(msi, 1, 1);
 		irq_set_msi_desc(msi->irq, NULL);
 		irq_free_desc(msi->irq);
 		msi->msg.address_lo = 0;
diff --git a/include/linux/msi.h b/include/linux/msi.h
index cc46a62..6fdc5c6 100644
--- a/include/linux/msi.h
+++ b/include/linux/msi.h
@@ -61,8 +61,6 @@ void arch_restore_msi_irqs(struct pci_dev *dev);
 
 void default_teardown_msi_irqs(struct pci_dev *dev);
 void default_restore_msi_irqs(struct pci_dev *dev);
-#define default_msi_mask_irq	__msi_mask_irq
-#define default_msix_mask_irq	__msix_mask_irq
 
 struct msi_chip {
 	struct module *owner;
-- 
1.7.1

