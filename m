From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 27 Oct 2014 12:47:14 +0000
Subject: [PATCH 06/16] Mips/MSI: Save MSI controller in pci sysdata
Message-Id: <1414416142-31239-7-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1414416142-31239-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1414416142-31239-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thierry Reding <thierry.reding@gmail.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Yijing Wang <wangyijing@huawei.com>

Save MSI controller in pci sysdata, add arch pcibios_msi_controller()
to extract out MSI controller.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/mips/include/asm/pci.h |    3 +++
 arch/mips/pci/pci.c         |    9 +++++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/arch/mips/include/asm/pci.h b/arch/mips/include/asm/pci.h
index 974b0e3..d7cd850 100644
--- a/arch/mips/include/asm/pci.h
+++ b/arch/mips/include/asm/pci.h
@@ -43,6 +43,9 @@ struct pci_controller {
 
 	int iommu;
 
+#ifdef CONFIG_PCI_MSI
+	struct msi_controller *msi_ctrl;
+#endif
 	/* Optional access methods for reading/writing the bus number
 	   of the PCI controller */
 	int (*get_busno)(void);
diff --git a/arch/mips/pci/pci.c b/arch/mips/pci/pci.c
index 1bf60b1..7917cba 100644
--- a/arch/mips/pci/pci.c
+++ b/arch/mips/pci/pci.c
@@ -36,6 +36,15 @@ unsigned long PCIBIOS_MIN_MEM;
 
 static int pci_initialized;
 
+#ifdef CONFIG_PCI_MSI
+struct msi_controller *pcibios_msi_controller(struct pci_bus *bus)
+{
+	struct pci_controller *ctrl = bus->sysdata;
+
+	return ctrl->msi_ctrl;
+}
+#endif
+
 /*
  * We need to avoid collisions with `mirrored' VGA ports
  * and other strange ISA hardware, so we always want the
-- 
1.7.1

