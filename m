From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 15 Oct 2014 02:33:15 +0000
Subject: [PATCH v3 07/27] PCI: rcar: Save msi chip in pci_sys_data
Message-Id: <1413342435-7876-8-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413342435-7876-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1413342435-7876-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thierry Reding <thierry.reding@gmail.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Liviu Dudau <liviu@dudau.co.uk>, Yijing Wang <wangyijing@huawei.com>

Save msi chip in pci_sys_data instead of assign
msi chip to every pci bus in .add_bus().

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/host/pcie-rcar.c |   13 +++----------
 1 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/pci/host/pcie-rcar.c b/drivers/pci/host/pcie-rcar.c
index 61158e0..c999c7e 100644
--- a/drivers/pci/host/pcie-rcar.c
+++ b/drivers/pci/host/pcie-rcar.c
@@ -380,20 +380,10 @@ static int rcar_pcie_setup(int nr, struct pci_sys_data *sys)
 	return 1;
 }
 
-static void rcar_pcie_add_bus(struct pci_bus *bus)
-{
-	if (IS_ENABLED(CONFIG_PCI_MSI)) {
-		struct rcar_pcie *pcie = sys_to_pcie(bus->sysdata);
-
-		bus->msi = &pcie->msi.chip;
-	}
-}
-
 struct hw_pci rcar_pci = {
 	.setup          = rcar_pcie_setup,
 	.map_irq        = of_irq_parse_and_map_pci,
 	.ops            = &rcar_pcie_ops,
-	.add_bus        = rcar_pcie_add_bus,
 };
 
 static void rcar_pcie_enable(struct rcar_pcie *pcie)
@@ -402,6 +392,9 @@ static void rcar_pcie_enable(struct rcar_pcie *pcie)
 
 	rcar_pci.nr_controllers = 1;
 	rcar_pci.private_data = (void **)&pcie;
+#ifdef CONFIG_PCI_MSI
+	rcar_pci.msi_chip = &pcie->msi.chip;
+#endif
 
 	pci_common_init_dev(&pdev->dev, &rcar_pci);
 #ifdef CONFIG_PCI_DOMAINS
-- 
1.7.1

