From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 15 Oct 2014 02:33:14 +0000
Subject: [PATCH v3 16/27] Mips/MSI: Save msi chip in pci sysdata
Message-Id: <1413342435-7876-17-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413342435-7876-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1413342435-7876-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thierry Reding <thierry.reding@gmail.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Liviu Dudau <liviu@dudau.co.uk>, Yijing Wang <wangyijing@huawei.com>

Save msi chip in pci sysdata, add arch pci_find_msi_chip()
to extract out msi chip.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/mips/include/asm/pci.h |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/arch/mips/include/asm/pci.h b/arch/mips/include/asm/pci.h
index 974b0e3..287661b 100644
--- a/arch/mips/include/asm/pci.h
+++ b/arch/mips/include/asm/pci.h
@@ -43,6 +43,9 @@ struct pci_controller {
 
 	int iommu;
 
+#ifdef CONFIG_PCI_MSI
+	struct msi_chip *msi_chip;
+#endif
 	/* Optional access methods for reading/writing the bus number
 	   of the PCI controller */
 	int (*get_busno)(void);
@@ -54,6 +57,17 @@ struct pci_controller {
  */
 extern void register_pci_controller(struct pci_controller *hose);
 
+#ifdef CONFIG_PCI_MSI
+
+static inline struct msi_chip *pci_msi_chip(struct pci_bus *bus)
+{
+	struct pci_controller *control = (struct pci_controller *)bus->sysdata;
+
+	return control->msi_chip;
+}
+
+#endif
+
 /*
  * board supplied pci irq fixup routine
  */
-- 
1.7.1

