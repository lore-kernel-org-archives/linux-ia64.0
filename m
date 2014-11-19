From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 19 Nov 2014 06:52:10 +0000
Subject: [PATCH 2/5] PCI: Introduce pci_scan_bus_simple()
Message-Id: <1416382369-13587-3-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416382369-13587-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1416382369-13587-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Now pci_scan_bus() and pci_scan_bus_parented()
are almost the same except parent device.
There is no need to use two similar scan interfaces.
Introduce pci_scan_bus_simple() which is same
as pci_scan_bus_parented(). And remove pci_scan_bus()
and pci_scan_bus_parented() in later patch.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/probe.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 5c5e01e..a8d90d4 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -2089,6 +2089,24 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, int bus,
 }
 EXPORT_SYMBOL(pci_scan_root_bus);
 
+struct pci_bus *pci_scan_bus_simple(struct device *parent,
+		int bus, struct pci_ops *ops, void *sysdata)
+{
+	LIST_HEAD(resources);
+	struct pci_bus *b;
+
+	pci_add_resource(&resources, &ioport_resource);
+	pci_add_resource(&resources, &iomem_resource);
+	pci_add_resource(&resources, &busn_resource);
+	b = pci_create_root_bus(parent, bus, ops, sysdata, &resources);
+	if (b)
+		pci_scan_child_bus(b);
+	else
+		pci_free_resource_list(&resources);
+	return b;
+}
+EXPORT_SYMBOL(pci_scan_bus_simple);
+
 /* Deprecated; use pci_scan_root_bus() instead */
 struct pci_bus *pci_scan_bus_parented(struct device *parent,
 		int bus, struct pci_ops *ops, void *sysdata)
-- 
1.7.1

