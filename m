From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 21 Apr 2015 11:34:25 +0000
Subject: [PATCH v10 06/29] PCI: Alloc busn resource dynamically for pci_scan_bus()
Message-Id: <1429616088-10249-7-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1429616088-10249-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1429616088-10249-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, dja@axtens.net, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Pci_scan_bus() always add the global busn_resource[00-FF],
the busn resource added is not accurate, if root bus number
is not equal to zero, the bus range bellow root bus number
is pointless, and this inaccurate busn resource would make
host bridge confuse, this patch dynamically allocate busn
resource instead of default global one, and add a flag
to pci_host_bridge, so when pci_host_bridge go to free,
the dynamic busn resource could also be freed properly.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/probe.c |   27 +++++++++++++++++++--------
 include/linux/pci.h |    1 +
 2 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 52b9257..c425755 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -18,13 +18,6 @@
 #define CARDBUS_LATENCY_TIMER	176	/* secondary latency timer */
 #define CARDBUS_RESERVE_BUSNR	3
 
-static struct resource busn_resource = {
-	.name	= "PCI busn",
-	.start	= 0,
-	.end	= 255,
-	.flags	= IORESOURCE_BUS,
-};
-
 /* Ugh.  Need to stop exporting this to modules. */
 LIST_HEAD(pci_root_buses);
 EXPORT_SYMBOL(pci_root_buses);
@@ -516,11 +509,17 @@ static struct pci_bus *pci_alloc_bus(struct pci_bus *parent)
 
 static void pci_release_host_bridge_dev(struct device *dev)
 {
+	struct resource_entry *entry;
 	struct pci_host_bridge *bridge = to_pci_host_bridge(dev);
 
 	if (bridge->release_fn)
 		bridge->release_fn(bridge);
 
+	if (bridge->dynamic_busn) {
+		entry = pci_busn_resource(&bridge->windows);
+		kfree(entry->res);
+	}
+
 	pci_free_resource_list(&bridge->windows);
 
 	kfree(bridge);
@@ -2117,15 +2116,27 @@ struct pci_bus *pci_scan_bus(int domain, int bus,
 {
 	LIST_HEAD(resources);
 	struct pci_bus *b;
+	struct resource *busn_resource;
+	struct pci_host_bridge *host;
+
+	busn_resource = kzalloc(sizeof(struct resource), GFP_KERNEL);
+	if (!busn_resource)
+		return NULL;
 
+	busn_resource->start = bus;
+	busn_resource->end = 255;
+	busn_resource->flags = IORESOURCE_BUS;
 	pci_add_resource(&resources, &ioport_resource);
 	pci_add_resource(&resources, &iomem_resource);
-	pci_add_resource(&resources, &busn_resource);
+	pci_add_resource(&resources, busn_resource);
 	b = pci_create_root_bus(NULL, domain, ops, sysdata,
 			&resources);
 	if (b) {
+		host = to_pci_host_bridge(b->bridge);
+		host->dynamic_busn = true;
 		pci_scan_child_bus(b);
 	} else {
+		kfree(busn_resource);
 		pci_free_resource_list(&resources);
 	}
 	return b;
diff --git a/include/linux/pci.h b/include/linux/pci.h
index df77a62..0716158 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -402,6 +402,7 @@ static inline int pci_channel_offline(struct pci_dev *pdev)
 
 struct pci_host_bridge {
 	int domain;
+	bool dynamic_busn;
 	struct device dev;
 	struct pci_bus *bus;		/* root bus */
 	struct list_head windows;	/* resource_entry */
-- 
1.7.1

