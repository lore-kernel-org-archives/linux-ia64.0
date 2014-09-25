From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 25 Sep 2014 02:59:00 +0000
Subject: [PATCH v2 06/22] PCI/MSI: Introduce weak arch_find_msi_chip() to find MSI chip
Message-Id: <1411614872-4009-7-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1411614872-4009-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1411614872-4009-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thierry Reding <thierry.reding@gmail.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Yijing Wang <wangyijing@huawei.com>

Introduce weak arch_find_msi_chip() to find the match msi_chip.
Currently, MSI chip associates pci bus to msi_chip. Because in
ARM platform, there may be more than one MSI controller in system.
Associate pci bus to msi_chip help pci device to find the match
msi_chip and setup MSI/MSI-X irq correctly. But in other platform,
like in x86. we only need one MSI chip, because all device use
the same MSI address/data and irq etc. So it's no need to associate
pci bus to MSI chip, just use a arch function, arch_find_msi_chip()
to return the MSI chip for simplicity. The default weak
arch_find_msi_chip() used in ARM platform, find the MSI chip
by pci bus.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/msi.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
index 5f8f3af..3acbe65 100644
--- a/drivers/pci/msi.c
+++ b/drivers/pci/msi.c
@@ -29,9 +29,14 @@ static int pci_msi_enable = 1;
 
 /* Arch hooks */
 
+struct msi_chip * __weak arch_find_msi_chip(struct pci_dev *dev)
+{
+	return dev->bus->msi;
+}
+
 int __weak arch_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc)
 {
-	struct msi_chip *chip = dev->bus->msi;
+	struct msi_chip *chip = arch_find_msi_chip(dev);
 	int err;
 
 	if (!chip || !chip->setup_irq)
-- 
1.7.1

