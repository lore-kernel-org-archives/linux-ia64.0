From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 17 Nov 2014 09:45:55 +0000
Subject: [RFC PATCH 07/16] PCI: Separate pci_host_bridge creation out of pci_create_root_bus()
Message-Id: <1416219710-26088-8-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416219710-26088-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1416219710-26088-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Thierry Reding <thierry.reding@gmail.com>, Liviu Dudau <liviu@dudau.co.uk>, Suravee.Suthikulpanit@amd.com, Yijing Wang <wangyijing@huawei.com>

There are some common PCI infos like domain, msi_controller, these
infos are saved in arch PCI sysdata, and lots arch specific functions
like pci_domain_nr() and pcibios_msi_controller() required.
We could separate pci_host_bridge creation out of pci_create_root_bus(),
then we could put the common infos in, then we could eliminate
the arch specifc functions.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/host-bridge.c |   99 +++++++++++++++++++++++++++++++++
 drivers/pci/probe.c       |  134 ++++++++++++++++----------------------------
 include/linux/pci.h       |   11 +++-
 3 files changed, 158 insertions(+), 86 deletions(-)

diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
index 0e5f3c9..e31604f 100644
--- a/drivers/pci/host-bridge.c
+++ b/drivers/pci/host-bridge.c
@@ -8,6 +8,105 @@
 
 #include "pci.h"
 
+LIST_HEAD(pci_host_bridge_list);
+DECLARE_RWSEM(pci_host_bridge_sem);
+
+static struct resource busn_resource = {
+	.name	= "PCI busn",
+	.start	= 0,
+	.end	= 255,
+	.flags	= IORESOURCE_BUS,
+};
+
+static void pci_release_host_bridge_dev(struct device *dev)
+{
+	struct pci_host_bridge *bridge = to_pci_host_bridge(dev);
+
+	if (bridge->release_fn)
+		bridge->release_fn(bridge);
+	pci_free_resource_list(&bridge->windows);
+	kfree(bridge);
+}
+
+struct pci_host_bridge *pci_create_host_bridge(
+		struct device *parent, u32 db, 
+		struct pci_ops *ops, void *sysdata, 
+		struct list_head *resources)
+{
+	int error;
+	struct pci_bus *b;
+	struct pci_host_bridge *host, *h;
+	struct pci_host_bridge_window *window, *n;
+
+	down_read(&pci_host_bridge_sem);
+	list_for_each_entry(h, &pci_host_bridge_list, list) {
+		if (h->domain = PCI_DOMAIN(db) &&
+				h->busnum = PCI_BUSNUM(db)) {
+			dev_dbg(&h->dev, "pci host bridge exist\n");
+			up_read(&pci_host_bridge_sem);
+			return NULL;
+		}
+	}
+	up_read(&pci_host_bridge_sem);
+
+	host = kzalloc(sizeof(*host), GFP_KERNEL);
+	if (!host)
+		return NULL;
+
+	host->sysdata = sysdata;
+	host->busnum = PCI_BUSNUM(db);
+	host->domain = PCI_DOMAIN(db);
+	host->ops = ops;
+	host->dev.parent = parent;
+	INIT_LIST_HEAD(&host->windows);
+	host->dev.release = pci_release_host_bridge_dev;
+
+	/* this is hack, just for build, will be removed later*/
+	b = kzalloc(sizeof(*b), GFP_KERNEL);
+	b->sysdata = sysdata;
+	pci_bus_assign_domain_nr(b, parent);
+	host->domain = pci_domain_nr(b);
+
+	if (!resources) {
+		/* Use default IO/MEM/BUS resources*/
+		pci_add_resource(&host->windows, &ioport_resource);
+		pci_add_resource(&host->windows, &iomem_resource);
+		pci_add_resource(&host->windows, &busn_resource);
+	} else {
+		list_for_each_entry_safe(window, n, resources, list)
+			list_move_tail(&window->list, &host->windows);
+	}
+
+	dev_set_name(&host->dev, "pci%04x:%02x", host->domain, 
+			host->busnum);
+	error = pcibios_root_bridge_prepare(host);
+	if(error) {
+		kfree(host);
+		return NULL;
+	}
+
+	error = device_register(&host->dev);
+	if (error) {
+		put_device(&host->dev);
+		return NULL;
+	}
+
+	down_write(&pci_host_bridge_sem);
+	list_add_tail(&host->list, &pci_host_bridge_list);
+	up_write(&pci_host_bridge_sem);
+	return host;
+}
+EXPORT_SYMBOL(pci_create_host_bridge);
+
+void pci_free_host_bridge(struct pci_host_bridge *host)
+{
+	down_write(&pci_host_bridge_sem);
+	list_del(&host->list);
+	up_write(&pci_host_bridge_sem);
+
+	device_unregister(&host->dev);
+}
+
 static struct pci_bus *find_pci_root_bus(struct pci_bus *bus)
 {
 	while (bus->parent)
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index adf4d09..d472da4 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -17,13 +17,6 @@
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
@@ -508,31 +501,6 @@ static struct pci_bus *pci_alloc_bus(struct pci_bus *parent)
 	return b;
 }
 
-static void pci_release_host_bridge_dev(struct device *dev)
-{
-	struct pci_host_bridge *bridge = to_pci_host_bridge(dev);
-
-	if (bridge->release_fn)
-		bridge->release_fn(bridge);
-
-	pci_free_resource_list(&bridge->windows);
-
-	kfree(bridge);
-}
-
-static struct pci_host_bridge *pci_alloc_host_bridge(struct pci_bus *b)
-{
-	struct pci_host_bridge *bridge;
-
-	bridge = kzalloc(sizeof(*bridge), GFP_KERNEL);
-	if (!bridge)
-		return NULL;
-
-	INIT_LIST_HEAD(&bridge->windows);
-	bridge->bus = b;
-	return bridge;
-}
-
 static const unsigned char pcix_bus_speed[] = {
 	PCI_SPEED_UNKNOWN,		/* 0 */
 	PCI_SPEED_66MHz_PCIX,		/* 1 */
@@ -1895,52 +1863,33 @@ void __weak pcibios_remove_bus(struct pci_bus *bus)
 {
 }
 
-struct pci_bus *pci_create_root_bus(struct device *parent, u32 db,
-		struct pci_ops *ops, void *sysdata, struct list_head *resources)
+struct pci_bus *__pci_create_root_bus(struct pci_host_bridge *bridge)
 {
 	int error;
-	struct pci_host_bridge *bridge;
 	struct pci_bus *b, *b2;
-	struct pci_host_bridge_window *window, *n;
+	struct pci_host_bridge_window *window;
 	struct resource *res;
 	resource_size_t offset;
 	char bus_addr[64];
 	char *fmt;
-	u8	bus = PCI_BUSNUM(db);
+	struct device *parent = bridge->dev.parent;
 
 	b = pci_alloc_bus(NULL);
 	if (!b)
 		return NULL;
 
-	b->sysdata = sysdata;
-	b->ops = ops;
-	b->number = b->busn_res.start = bus;
+	b->sysdata = bridge->sysdata;
+	b->ops = bridge->ops;
+	b->number = b->busn_res.start = bridge->busnum;
 	pci_bus_assign_domain_nr(b, parent);
-	b2 = pci_find_bus(pci_domain_nr(b), bus);
+	bridge->domain = pci_domain_nr(b);
+	b2 = pci_find_bus(pci_domain_nr(b), bridge->busnum);
 	if (b2) {
 		/* If we already got to this bus through a different bridge, ignore it */
 		dev_dbg(&b2->dev, "bus already known\n");
 		goto err_out;
 	}
 
-	bridge = pci_alloc_host_bridge(b);
-	if (!bridge)
-		goto err_out;
-
-	bridge->dev.parent = parent;
-	bridge->dev.release = pci_release_host_bridge_dev;
-	dev_set_name(&bridge->dev, "pci%04x:%02x", pci_domain_nr(b), bus);
-	error = pcibios_root_bridge_prepare(bridge);
-	if (error) {
-		kfree(bridge);
-		goto err_out;
-	}
-
-	error = device_register(&bridge->dev);
-	if (error) {
-		put_device(&bridge->dev);
-		goto err_out;
-	}
 	b->bridge = get_device(&bridge->dev);
 	device_enable_async_suspend(b->bridge);
 	pci_set_bus_of_node(b);
@@ -1950,7 +1899,7 @@ struct pci_bus *pci_create_root_bus(struct device *parent, u32 db,
 
 	b->dev.class = &pcibus_class;
 	b->dev.parent = b->bridge;
-	dev_set_name(&b->dev, "%04x:%02x", pci_domain_nr(b), bus);
+	dev_set_name(&b->dev, "%04x:%02x", pci_domain_nr(b), b->number);
 	error = device_register(&b->dev);
 	if (error)
 		goto class_dev_reg_err;
@@ -1966,12 +1915,11 @@ struct pci_bus *pci_create_root_bus(struct device *parent, u32 db,
 		printk(KERN_INFO "PCI host bridge to bus %s\n", dev_name(&b->dev));
 
 	/* Add initial resources to the bus */
-	list_for_each_entry_safe(window, n, resources, list) {
-		list_move_tail(&window->list, &bridge->windows);
+	list_for_each_entry(window, &bridge->windows, list) {
 		res = window->res;
 		offset = window->offset;
 		if (res->flags & IORESOURCE_BUS)
-			pci_bus_insert_busn_res(b, bus, res->end);
+			pci_bus_insert_busn_res(b, b->number, res->end);
 		else
 			pci_bus_add_resource(b, res, 0);
 		if (offset) {
@@ -2001,6 +1949,25 @@ err_out:
 	return NULL;
 }
 
+struct pci_bus *pci_create_root_bus(struct device *parent, u32 bus,
+		struct pci_ops *ops, void *sysdata, struct list_head *resources)
+{
+	struct pci_host_bridge *host;
+
+	host = pci_create_host_bridge(parent, bus, ops, 
+			sysdata ,resources);
+	if (!host)
+		return NULL;
+
+	host->bus = __pci_create_root_bus(host);
+	if (!host->bus) {
+		pci_free_host_bridge(host);
+		return NULL;
+	}
+		
+	return host->bus;
+}
+
 int pci_bus_insert_busn_res(struct pci_bus *b, int bus, int bus_max)
 {
 	struct resource *res = &b->busn_res;
@@ -2069,40 +2036,37 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, u32 db,
 {
 	struct pci_host_bridge_window *window;
 	bool found = false;
-	struct pci_bus *b;
-	LIST_HEAD(default_res);
+	struct pci_host_bridge *host;
 	int max;
 
-	if (!resources) {
-		pci_add_resource(&default_res, &ioport_resource);
-		pci_add_resource(&default_res, &iomem_resource);
-		pci_add_resource(&default_res, &busn_resource);
-	} else {
-		list_for_each_entry(window, resources, list)
-			if (window->res->flags & IORESOURCE_BUS) {
-				found = true;
-				break;
-			}
-	}
+	host = pci_create_host_bridge(parent, db, ops, sysdata, resources);
+	if (!host)
+		return NULL;
 
-	b = pci_create_root_bus(parent, db, ops, sysdata, 
-			resources ? resources : &default_res);
-	if (!b)
+	list_for_each_entry(window, &host->windows, list)
+		if (window->res->flags & IORESOURCE_BUS) {
+			found = true;
+			break;
+		}
+
+	host->bus = __pci_create_root_bus(host);
+	if (!host->bus) {
+		pci_free_host_bridge(host);
 		return NULL;
+	}
 
 	if (!found) {
-		dev_info(&b->dev,
+		dev_info(&host->bus->dev,
 		 "No busn resource found for root bus, will use [bus %02x-ff]\n",
 			PCI_BUSNUM(db));
-		pci_bus_insert_busn_res(b, PCI_BUSNUM(db), 255);
+		pci_bus_insert_busn_res(host->bus, PCI_BUSNUM(db), 255);
 	}
 
-	max = pci_scan_child_bus(b);
-
+	max = pci_scan_child_bus(host->bus);
 	if (!found)
-		pci_bus_update_busn_res_end(b, max);
+		pci_bus_update_busn_res_end(host->bus, max);
 
-	return b;
+	return host->bus;
 }
 EXPORT_SYMBOL(pci_scan_root_bus);
 
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 8b11b38..daa7f40 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -402,7 +402,12 @@ struct pci_host_bridge_window {
 struct pci_host_bridge {
 	struct device dev;
 	struct pci_bus *bus;		/* root bus */
+	struct list_head list;
 	struct list_head windows;	/* pci_host_bridge_windows */
+	int busnum;
+	int domain;
+	void *sysdata;
+	struct pci_ops *ops;
 	void (*release_fn)(struct pci_host_bridge *);
 	void *release_data;
 };
@@ -413,7 +418,9 @@ void pci_set_host_bridge_release(struct pci_host_bridge *bridge,
 		     void *release_data);
 
 int pcibios_root_bridge_prepare(struct pci_host_bridge *bridge);
-
+struct pci_host_bridge *pci_create_host_bridge(
+		struct device *parent, u32 db, struct pci_ops *ops, 
+		void *sys, struct list_head *resources);
 /*
  * The first PCI_BRIDGE_RESOURCE_NUM PCI bus resources (those that correspond
  * to P2P or CardBus bridge windows) go in a table.  Additional ones (for
@@ -770,6 +777,8 @@ void pci_bus_add_devices(const struct pci_bus *bus);
 struct pci_bus *pci_create_root_bus(struct device *parent, u32 bus,
 				    struct pci_ops *ops, void *sysdata,
 				    struct list_head *resources);
+struct pci_bus *__pci_create_root_bus(struct pci_host_bridge *host);
+void pci_free_host_bridge(struct pci_host_bridge *host);
 int pci_bus_insert_busn_res(struct pci_bus *b, int bus, int busmax);
 int pci_bus_update_busn_res_end(struct pci_bus *b, int busmax);
 void pci_bus_release_busn_res(struct pci_bus *b);
-- 
1.7.1

