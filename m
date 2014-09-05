From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 05 Sep 2014 09:49:17 +0000
Subject: [PATCH v1 02/21] PCI/MSI: Remove useless bus->msi assignment
Message-Id: <1409911806-10519-3-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1409911806-10519-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1409911806-10519-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-pci@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem>

Currently, PCI drivers will initialize bus->msi in
pcibios_add_bus(). pcibios_add_bus() will be called
in every pci bus initialization. So the bus->msi
assignment in pci_alloc_child_bus() is useless.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
CC: Thierry Reding <thierry.reding@avionic-design.de>
CC: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/pci/probe.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index e3cf8a2..8296576 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -677,7 +677,6 @@ static struct pci_bus *pci_alloc_child_bus(struct pci_bus *parent,
 
 	child->parent = parent;
 	child->ops = parent->ops;
-	child->msi = parent->msi;
 	child->sysdata = parent->sysdata;
 	child->bus_flags = parent->bus_flags;
 
-- 
1.7.1

