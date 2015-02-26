From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 26 Feb 2015 08:12:16 +0000
Subject: [PATCH v4 22/30] PCI/Parisc: Use pci_scan_root_bus() for simplicity
Message-Id: <1424938344-4017-23-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424938344-4017-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1424938344-4017-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@lists.linux-m68k.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>, Yijing Wang <wangyijing0307@gmail.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, linux-parisc@vger.kernel.org

From: Yijing Wang <wangyijing0307@gmail.com>

Now pci_bus_add_devices() has been ripped out
from pci_scan_root_bus(), we could use pci_scan_root_bus()
instead of pci_create_root_bus() + pci_scan_child_bus()
for simplicity. We could also remove the pci bus
resource(dino_current_bus,255) and pci_bus_update_busn_res_end(),
because pci_scan_root_bus() would do the same thing.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
CC: "James E.J. Bottomley" <jejb@parisc-linux.org>
CC: linux-parisc@vger.kernel.org
---
 drivers/parisc/dino.c    |   11 ++---------
 drivers/parisc/lba_pci.c |    7 ++-----
 2 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/drivers/parisc/dino.c b/drivers/parisc/dino.c
index a0580af..e5ee339 100644
--- a/drivers/parisc/dino.c
+++ b/drivers/parisc/dino.c
@@ -977,15 +977,11 @@ static int __init dino_probe(struct parisc_device *dev)
 	if (dino_dev->hba.gmmio_space.flags)
 		pci_add_resource(&resources, &dino_dev->hba.gmmio_space);
 
-	dino_dev->hba.bus_num.start = dino_current_bus;
-	dino_dev->hba.bus_num.end = 255;
-	dino_dev->hba.bus_num.flags = IORESOURCE_BUS;
-	pci_add_resource(&resources, &dino_dev->hba.bus_num);
 	/*
 	** It's not used to avoid chicken/egg problems
 	** with configuration accessor functions.
 	*/
-	dino_dev->hba.hba_bus = bus = pci_create_root_bus(&dev->dev,
+	dino_dev->hba.hba_bus = bus = pci_scan_root_bus(&dev->dev,
 			 dino_current_bus, &dino_cfg_ops, NULL, &resources);
 	if (!bus) {
 		printk(KERN_ERR "ERROR: failed to scan PCI bus on %s (duplicate bus number %d?)\n",
@@ -996,13 +992,10 @@ static int __init dino_probe(struct parisc_device *dev)
 		return 0;
 	}
 
-	max = pci_scan_child_bus(bus);
-	pci_bus_update_busn_res_end(bus, max);
-
 	/* This code *depends* on scanning being single threaded
 	 * if it isn't, this global bus number count will fail
 	 */
-	dino_current_bus = max + 1;
+	dino_current_bus = bus->busn_res.end + 1;
 	pci_bus_assign_resources(bus);
 	pci_bus_add_devices(bus);
 	return 0;
diff --git a/drivers/parisc/lba_pci.c b/drivers/parisc/lba_pci.c
index dceb9dd..ba6daec 100644
--- a/drivers/parisc/lba_pci.c
+++ b/drivers/parisc/lba_pci.c
@@ -1422,7 +1422,6 @@ lba_driver_probe(struct parisc_device *dev)
 	void *tmp_obj;
 	char *version;
 	void __iomem *addr = ioremap_nocache(dev->hpa.start, 4096);
-	int max;
 
 	/* Read HW Rev First */
 	func_class = READ_REG32(addr + LBA_FCLASS);
@@ -1563,15 +1562,13 @@ lba_driver_probe(struct parisc_device *dev)
 
 	dev->dev.platform_data = lba_dev;
 	lba_bus = lba_dev->hba.hba_bus -		pci_create_root_bus(&dev->dev, lba_dev->hba.bus_num.start,
+		pci_scan_root_bus(&dev->dev, lba_dev->hba.bus_num.start,
 				    cfg_ops, NULL, &resources);
 	if (!lba_bus) {
 		pci_free_resource_list(&resources);
 		return 0;
 	}
 
-	max = pci_scan_child_bus(lba_bus);
-
 	/* This is in lieu of calling pci_assign_unassigned_resources() */
 	if (is_pdc_pat()) {
 		/* assign resources to un-initialized devices */
@@ -1599,7 +1596,7 @@ lba_driver_probe(struct parisc_device *dev)
 		lba_dev->flags |= LBA_FLAG_SKIP_PROBE;
 	}
 
-	lba_next_bus = max + 1;
+	lba_next_bus = pci_bus_child_max_busnr(lba_bus) + 1;
 	pci_bus_add_devices(lba_bus);
 
 	/* Whew! Finally done! Tell services we got this one covered. */
-- 
1.7.1

