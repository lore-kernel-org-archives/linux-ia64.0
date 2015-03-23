From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 23 Mar 2015 12:40:51 +0000
Subject: [PATCH v7 25/31] PCI/designware: Use pci_scan_root_bus() for simplicity
Message-Id: <1427114457-16687-26-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1427114457-16687-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1427114457-16687-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>, Mohit Kumar <mohit.kumar@st.com>, Jingoo Han <jg1.han@samsung.com>

Use pci_scan_root_bus() instead of pci_create_root_bus() +
pci_scan_child_bus() for simplicity.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
CC: Mohit Kumar <mohit.kumar@st.com>
CC: Jingoo Han <jg1.han@samsung.com>
---
 drivers/pci/host/pcie-designware.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/pci/host/pcie-designware.c b/drivers/pci/host/pcie-designware.c
index 93778b9..3d7d6fb 100644
--- a/drivers/pci/host/pcie-designware.c
+++ b/drivers/pci/host/pcie-designware.c
@@ -728,13 +728,11 @@ static struct pci_bus *dw_pcie_scan_bus(int nr, struct pci_sys_data *sys)
 	struct pcie_port *pp = sys_to_pcie(sys);
 
 	pp->root_bus_nr = sys->busnr;
-	bus = pci_create_root_bus(pp->dev, -1, sys->busnr,
+	bus = pci_scan_root_bus(pp->dev, -1, sys->busnr,
 				  &dw_pcie_ops, sys, &sys->resources);
 	if (!bus)
 		return NULL;
 
-	pci_scan_child_bus(bus);
-
 	if (bus && pp->ops->scan_bus)
 		pp->ops->scan_bus(pp);
 
-- 
1.7.1

