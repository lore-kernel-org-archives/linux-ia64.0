From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 17 Nov 2014 09:40:56 +0000
Subject: [RFC PATCH 03/16] PCI: Clean up pci_scan_bus()
Message-Id: <1416219710-26088-4-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416219710-26088-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1416219710-26088-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Thierry Reding <thierry.reding@gmail.com>, Liviu Dudau <liviu@dudau.co.uk>, Suravee.Suthikulpanit@amd.com, Yijing Wang <wangyijing@huawei.com>

No one uses it, clean up.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/probe.c |   20 --------------------
 include/linux/pci.h |    1 -
 2 files changed, 0 insertions(+), 21 deletions(-)

diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index fc99e88..0a02fc2 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -2125,26 +2125,6 @@ struct pci_bus *pci_scan_bus_parented(struct device *parent,
 }
 EXPORT_SYMBOL(pci_scan_bus_parented);
 
-struct pci_bus *pci_scan_bus(int bus, struct pci_ops *ops,
-					void *sysdata)
-{
-	LIST_HEAD(resources);
-	struct pci_bus *b;
-
-	pci_add_resource(&resources, &ioport_resource);
-	pci_add_resource(&resources, &iomem_resource);
-	pci_add_resource(&resources, &busn_resource);
-	b = pci_create_root_bus(NULL, bus, ops, sysdata, &resources);
-	if (b) {
-		pci_scan_child_bus(b);
-		pci_bus_add_devices(b);
-	} else {
-		pci_free_resource_list(&resources);
-	}
-	return b;
-}
-EXPORT_SYMBOL(pci_scan_bus);
-
 /**
  * pci_rescan_bus_bridge_resize - scan a PCI bus for devices.
  * @bridge: PCI bridge for the bus to scan
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 5be8db4..f8045d6 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -769,7 +769,6 @@ struct pci_bus *pci_find_bus(int domain, int busnr);
 void pci_bus_add_devices(const struct pci_bus *bus);
 struct pci_bus *pci_scan_bus_parented(struct device *parent, int bus,
 				      struct pci_ops *ops, void *sysdata);
-struct pci_bus *pci_scan_bus(int bus, struct pci_ops *ops, void *sysdata);
 struct pci_bus *pci_create_root_bus(struct device *parent, int bus,
 				    struct pci_ops *ops, void *sysdata,
 				    struct list_head *resources);
-- 
1.7.1

