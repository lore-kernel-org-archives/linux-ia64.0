From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 09 Mar 2015 02:34:01 +0000
Subject: [PATCH v6 04/30] xen/PCI: Don't use deprecated function pci_scan_bus_parented()
Message-Id: <1425868467-9667-5-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425868467-9667-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1425868467-9667-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Bjorn Helgaas <bhelgaas@google.com>

From: Arnd Bergmann <arnd@arndb.de>

Use pci_scan_root_bus() instead of deprecated function
pci_scan_bus_parented().

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Yijing Wang <wangyijing@huawei.com>
CC: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
CC: xen-devel@lists.xenproject.org
Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 drivers/pci/xen-pcifront.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/pci/xen-pcifront.c b/drivers/pci/xen-pcifront.c
index b1ffebe..9e7c28b 100644
--- a/drivers/pci/xen-pcifront.c
+++ b/drivers/pci/xen-pcifront.c
@@ -21,6 +21,7 @@
 #include <linux/bitops.h>
 #include <linux/time.h>
 #include <xen/platform_pci.h>
+#include "pci.h"
 
 #include <asm/xen/swiotlb-xen.h>
 #define INVALID_GRANT_REF (0)
@@ -446,6 +447,7 @@ static int pcifront_scan_root(struct pcifront_device *pdev,
 				 unsigned int domain, unsigned int bus)
 {
 	struct pci_bus *b;
+	LIST_HEAD(resources);
 	struct pcifront_sd *sd = NULL;
 	struct pci_bus_entry *bus_entry = NULL;
 	int err = 0;
@@ -470,17 +472,21 @@ static int pcifront_scan_root(struct pcifront_device *pdev,
 		err = -ENOMEM;
 		goto err_out;
 	}
+	pci_add_resource(&resources, &ioport_resource);
+	pci_add_resource(&resources, &iomem_resource);
+	pci_add_resource(&resources, &busn_resource);
 	pcifront_init_sd(sd, domain, bus, pdev);
 
 	pci_lock_rescan_remove();
 
-	b = pci_scan_bus_parented(&pdev->xdev->dev, bus,
-				  &pcifront_bus_ops, sd);
+	b = pci_scan_root_bus(&pdev->xdev->dev, bus,
+				  &pcifront_bus_ops, sd, &resources);
 	if (!b) {
 		dev_err(&pdev->xdev->dev,
 			"Error creating PCI Frontend Bus!\n");
 		err = -ENOMEM;
 		pci_unlock_rescan_remove();
+		pci_free_resource_list(&resources);
 		goto err_out;
 	}
 
@@ -488,7 +494,7 @@ static int pcifront_scan_root(struct pcifront_device *pdev,
 
 	list_add(&bus_entry->list, &pdev->root_buses);
 
-	/* pci_scan_bus_parented skips devices which do not have a have
+	/* pci_scan_root_bus skips devices which do not have a
 	* devfn=0. The pcifront_scan_bus enumerates all devfn. */
 	err = pcifront_scan_bus(pdev, domain, bus, b);
 
-- 
1.7.1

