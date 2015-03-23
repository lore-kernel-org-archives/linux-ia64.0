From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 23 Mar 2015 12:40:48 +0000
Subject: [PATCH v7 22/31] parisc/PCI: Use pci_scan_root_bus() for simplicity
Message-Id: <1427114457-16687-23-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1427114457-16687-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1427114457-16687-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@lists.linux-m68k.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>, Yijing Wang <wangyijing0307@gmail.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, linux-parisc@vger.kernel.org

From: Yijing Wang <wangyijing0307@gmail.com>

Now pci_bus_add_devices() has been ripped out
from pci_scan_root_bus(), we could use pci_scan_root_bus()
instead of pci_create_root_bus() + pci_scan_child_bus()
for simplicity.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
CC: "James E.J. Bottomley" <jejb@parisc-linux.org>
CC: linux-parisc@vger.kernel.org
---
 drivers/parisc/dino.c    |    4 ++--
 drivers/parisc/lba_pci.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/parisc/dino.c b/drivers/parisc/dino.c
index f375252..146c3ff 100644
--- a/drivers/parisc/dino.c
+++ b/drivers/parisc/dino.c
@@ -985,7 +985,7 @@ static int __init dino_probe(struct parisc_device *dev)
 	** It's not used to avoid chicken/egg problems
 	** with configuration accessor functions.
 	*/
-	dino_dev->hba.hba_bus = bus = pci_create_root_bus(&dev->dev,
+	dino_dev->hba.hba_bus = bus = pci_scan_root_bus(&dev->dev,
 			 0, dino_current_bus, &dino_cfg_ops, NULL, &resources);
 	if (!bus) {
 		printk(KERN_ERR "ERROR: failed to scan PCI bus on %s (duplicate bus number %d?)\n",
@@ -996,7 +996,7 @@ static int __init dino_probe(struct parisc_device *dev)
 		return 0;
 	}
 
-	max = pci_scan_child_bus(bus);
+	max = pci_bus_child_max_busnr(bus);
 	pci_bus_update_busn_res_end(bus, max);
 
 	/* This code *depends* on scanning being single threaded
diff --git a/drivers/parisc/lba_pci.c b/drivers/parisc/lba_pci.c
index 2949030..b630364 100644
--- a/drivers/parisc/lba_pci.c
+++ b/drivers/parisc/lba_pci.c
@@ -1563,14 +1563,14 @@ lba_driver_probe(struct parisc_device *dev)
 
 	dev->dev.platform_data = lba_dev;
 	lba_bus = lba_dev->hba.hba_bus -		pci_create_root_bus(&dev->dev, 0, lba_dev->hba.bus_num.start,
+		pci_scan_root_bus(&dev->dev, 0, lba_dev->hba.bus_num.start,
 				    cfg_ops, NULL, &resources);
 	if (!lba_bus) {
 		pci_free_resource_list(&resources);
 		return 0;
 	}
 
-	max = pci_scan_child_bus(lba_bus);
+	max = pci_bus_child_max_busnr(lba_bus);
 
 	/* This is in lieu of calling pci_assign_unassigned_resources() */
 	if (is_pdc_pat()) {
-- 
1.7.1

