From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 17 Nov 2014 09:45:42 +0000
Subject: [RFC PATCH 01/16] PCI: Enhance pci_scan_root_bus() to support default IO/MEM resources
Message-Id: <1416219710-26088-2-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416219710-26088-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1416219710-26088-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Thierry Reding <thierry.reding@gmail.com>, Liviu Dudau <liviu@dudau.co.uk>, Suravee.Suthikulpanit@amd.com, Yijing Wang <wangyijing@huawei.com>, Yijing Wang <wangyijing0307@gmail.com>

From: Yijing Wang <wangyijing0307@gmail.com>

Pci_scan_root_bus(), pci_scan_bus() and pci_scan_bus_parented()
are very similar. But the latter two use the default
io/mem resources. Enhance pci_scan_root_bus() to support
default io/mem resources, then we could use
pci_scan_root_bus() instead of them, and clean them up.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/probe.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 5ed9930..fc99e88 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -2069,15 +2069,23 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, int bus,
 	struct pci_host_bridge_window *window;
 	bool found = false;
 	struct pci_bus *b;
+	LIST_HEAD(default_res);
 	int max;
 
-	list_for_each_entry(window, resources, list)
-		if (window->res->flags & IORESOURCE_BUS) {
-			found = true;
-			break;
-		}
+	if (!resources) {
+		pci_add_resource(&default_res, &ioport_resource);
+		pci_add_resource(&default_res, &iomem_resource);
+		pci_add_resource(&default_res, &busn_resource);
+	} else {
+		list_for_each_entry(window, resources, list)
+			if (window->res->flags & IORESOURCE_BUS) {
+				found = true;
+				break;
+			}
+	}
 
-	b = pci_create_root_bus(parent, bus, ops, sysdata, resources);
+	b = pci_create_root_bus(parent, bus, ops, sysdata, 
+			resources ? resources : &default_res);
 	if (!b)
 		return NULL;
 
-- 
1.7.1

