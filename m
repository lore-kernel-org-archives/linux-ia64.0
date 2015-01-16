From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 16 Jan 2015 01:44:07 +0000
Subject: [PATCH 09/28] PCI: Separate pci_host_bridge creation out of pci_create_root_bus()
Message-Id: <1421372666-12288-10-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421372666-12288-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1421372666-12288-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

We want to make a generic pci_host_bridge, then we could
place common PCI infos like domain number in it. Ripping
out pci_host_bridge creation from pci_create_root_bus()
make code more better readability. Further more, we could
use the generic pci_host_bridge to hold host bridge specific
operations like pcibios_root_bridge_prepare().

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/host-bridge.c |   78 +++++++++++++++++++++++++++++
 drivers/pci/probe.c       |  121 +++++++++++++++++++--------------------------
 include/linux/pci.h       |    6 ++-
 3 files changed, 134 insertions(+), 71 deletions(-)

diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
index 0e5f3c9..c9ee582 100644
--- a/drivers/pci/host-bridge.c
+++ b/drivers/pci/host-bridge.c
@@ -8,6 +8,84 @@
 
 #include "pci.h"
 
+static LIST_HEAD(pci_host_bridge_list);
+static DEFINE_MUTEX(phb_mutex);
+
+static void pci_release_host_bridge_dev(struct device *dev)
+{
+	struct pci_host_bridge *bridge = to_pci_host_bridge(dev);
+
+	if (bridge->release_fn)
+		bridge->release_fn(bridge);
+
+	pci_free_resource_list(&bridge->windows);
+	kfree(bridge);
+}
+
+struct pci_host_bridge *pci_create_host_bridge(
+		struct device *parent, u32 db, struct list_head *resources)
+{
+	int error;
+	int bus = PCI_BUSNUM(db);
+	int domain = PCI_DOMAIN(db);
+	struct pci_host_bridge *host, *temp;
+	struct pci_host_bridge_window *window, *n;
+
+	host = kzalloc(sizeof(*host), GFP_KERNEL);
+	if (!host)
+		return NULL;
+
+	host->busnum = bus;
+	host->domain = domain;
+	/* If support CONFIG_PCI_DOMAINS_GENERIC, use
+	 * pci_host_assign_domain_nr() to assign domain
+	 * number instead argu u32 db.
+	 */
+	pci_host_assign_domain_nr(host);
+
+	mutex_lock(&phb_mutex);
+	list_for_each_entry(temp, &pci_host_bridge_list, list)
+		if (temp->domain = host->domain
+				&& host->busnum = temp->busnum) {
+			dev_dbg(&host->dev, "pci host bridge pci%04x:%02x exist\n",
+					host->domain, host->busnum);
+			mutex_unlock(&phb_mutex);
+			kfree(host);
+			return NULL;
+		}
+	mutex_unlock(&phb_mutex);
+
+	host->dev.parent = parent;
+	INIT_LIST_HEAD(&host->windows);
+	host->dev.release = pci_release_host_bridge_dev;
+	dev_set_name(&host->dev, "pci%04x:%02x", host->domain,
+			host->busnum);
+
+	error = device_register(&host->dev);
+	if (error) {
+		put_device(&host->dev);
+		return NULL;
+	}
+
+	list_for_each_entry_safe(window, n, resources, list)
+		list_move_tail(&window->list, &host->windows);
+
+	mutex_lock(&phb_mutex);
+	list_add_tail(&host->list, &pci_host_bridge_list);
+	mutex_unlock(&phb_mutex);
+	return host;
+}
+EXPORT_SYMBOL(pci_create_host_bridge);
+
+void pci_free_host_bridge(struct pci_host_bridge *host)
+{
+	mutex_lock(&phb_mutex);
+	list_del(&host->list);
+	mutex_unlock(&phb_mutex);
+
+	device_unregister(&host->dev);
+}
+
 static struct pci_bus *find_pci_root_bus(struct pci_bus *bus)
 {
 	while (bus->parent)
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 50f58b3..2e0b952 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -502,31 +502,6 @@ static struct pci_bus *pci_alloc_bus(struct pci_bus *parent)
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
@@ -1889,54 +1864,35 @@ void __weak pcibios_remove_bus(struct pci_bus *bus)
 {
 }
 
-struct pci_bus *pci_create_root_bus(struct device *parent, u32 db,
-		struct pci_ops *ops, void *sysdata, struct list_head *resources)
+static struct pci_bus *__pci_create_root_bus(
+		struct pci_host_bridge *bridge, struct pci_ops *ops,
+		void *sysdata)
 {
 	int error;
-	struct pci_host_bridge *bridge;
-	struct pci_bus *b, *b2;
-	struct pci_host_bridge_window *window, *n;
+	struct pci_bus *b;
+	struct pci_host_bridge_window *window;
+	struct device *parent;
 	struct resource *res;
 	resource_size_t offset;
 	char bus_addr[64];
 	char *fmt;
-	u8	bus = PCI_BUSNUM(db);
 
+	parent = bridge->dev.parent;
 	b = pci_alloc_bus(NULL);
 	if (!b)
 		return NULL;
 
 	b->sysdata = sysdata;
 	b->ops = ops;
-	b->number = b->busn_res.start = bus;
+	b->number = b->busn_res.start = bridge->busnum;
 	pci_bus_assign_domain_nr(b, parent);
-	b2 = pci_find_bus(pci_domain_nr(b), bus);
-	if (b2) {
-		/* If we already got to this bus through a different bridge, ignore it */
-		dev_dbg(&b2->dev, "bus already known\n");
-		goto err_out;
-	}
 
-	bridge = pci_alloc_host_bridge(b);
-	if (!bridge)
-		goto err_out;
-
-	bridge->domain = PCI_DOMAIN(db);
-	bridge->dev.parent = parent;
-	bridge->dev.release = pci_release_host_bridge_dev;
-	dev_set_name(&bridge->dev, "pci%04x:%02x", pci_domain_nr(b), bus);
+	bridge->bus = b;
+	b->bridge = get_device(&bridge->dev);
 	error = pcibios_root_bridge_prepare(bridge);
-	if (error) {
-		kfree(bridge);
+	if (error)
 		goto err_out;
-	}
 
-	error = device_register(&bridge->dev);
-	if (error) {
-		put_device(&bridge->dev);
-		goto err_out;
-	}
-	b->bridge = get_device(&bridge->dev);
 	device_enable_async_suspend(b->bridge);
 	pci_set_bus_of_node(b);
 
@@ -1945,10 +1901,11 @@ struct pci_bus *pci_create_root_bus(struct device *parent, u32 db,
 
 	b->dev.class = &pcibus_class;
 	b->dev.parent = b->bridge;
-	dev_set_name(&b->dev, "%04x:%02x", pci_domain_nr(b), bus);
+	dev_set_name(&b->dev, "%04x:%02x", bridge->domain,
+			bridge->busnum);
 	error = device_register(&b->dev);
 	if (error)
-		goto class_dev_reg_err;
+		goto err_out;
 
 	pcibios_add_bus(b);
 
@@ -1961,12 +1918,11 @@ struct pci_bus *pci_create_root_bus(struct device *parent, u32 db,
 		printk(KERN_INFO "PCI host bridge to bus %s\n", dev_name(&b->dev));
 
 	/* Add initial resources to the bus */
-	list_for_each_entry_safe(window, n, resources, list) {
-		list_move_tail(&window->list, &bridge->windows);
+	list_for_each_entry(window, &bridge->windows, list) {
 		res = window->res;
 		offset = window->offset;
 		if (res->flags & IORESOURCE_BUS)
-			pci_bus_insert_busn_res(b, bus, res->end);
+			pci_bus_insert_busn_res(b, bridge->busnum, res->end);
 		else
 			pci_bus_add_resource(b, res, 0);
 		if (offset) {
@@ -1988,14 +1944,23 @@ struct pci_bus *pci_create_root_bus(struct device *parent, u32 db,
 
 	return b;
 
-class_dev_reg_err:
-	put_device(&bridge->dev);
-	device_unregister(&bridge->dev);
 err_out:
 	kfree(b);
 	return NULL;
 }
 
+struct pci_bus *pci_create_root_bus(struct device *parent, u32 db,
+		struct pci_ops *ops, void *sysdata, struct list_head *resources)
+{
+	struct pci_host_bridge *host;
+
+	host = pci_create_host_bridge(parent, db, resources);
+	if (!host)
+		return NULL;
+
+	return __pci_create_root_bus(host, ops, sysdata);
+}
+
 int pci_bus_insert_busn_res(struct pci_bus *b, int bus, int bus_max)
 {
 	struct resource *res = &b->busn_res;
@@ -2059,29 +2024,33 @@ void pci_bus_release_busn_res(struct pci_bus *b)
 			res, ret ? "can not be" : "is");
 }
 
-struct pci_bus *pci_scan_root_bus(struct device *parent, u32 db,
-		struct pci_ops *ops, void *sysdata, struct list_head *resources)
+static struct pci_bus *__pci_scan_root_bus(
+		struct pci_host_bridge *host, struct pci_ops *ops,
+		void *sysdata)
 {
+
 	struct pci_host_bridge_window *window;
 	bool found = false;
 	struct pci_bus *b;
 	int max;
 
-	list_for_each_entry(window, resources, list)
+	list_for_each_entry(window, &host->windows, list)
 		if (window->res->flags & IORESOURCE_BUS) {
 			found = true;
 			break;
 		}
 
-	b = pci_create_root_bus(parent, db, ops, sysdata, resources);
-	if (!b)
+	b = __pci_create_root_bus(host, ops, sysdata);
+	if (!b) {
+		pci_free_host_bridge(host);
 		return NULL;
+	}
 
 	if (!found) {
 		dev_info(&b->dev,
 		 "No busn resource found for root bus, will use [bus %02x-ff]\n",
-			PCI_BUSNUM(db));
-		pci_bus_insert_busn_res(b, PCI_BUSNUM(db), 255);
+			host->busnum);
+		pci_bus_insert_busn_res(b, host->busnum, 255);
 	}
 
 	max = pci_scan_child_bus(b);
@@ -2091,6 +2060,18 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, u32 db,
 
 	return b;
 }
+
+struct pci_bus *pci_scan_root_bus(struct device *parent, u32 db,
+		struct pci_ops *ops, void *sysdata, struct list_head *resources)
+{
+	struct pci_host_bridge *host;
+
+	host = pci_create_host_bridge(parent, db, resources);
+	if (!host)
+		return NULL;
+
+	return __pci_scan_root_bus(host, ops, sysdata);
+}
 EXPORT_SYMBOL(pci_scan_root_bus);
 
 struct pci_bus *pci_scan_bus_legacy(u32 db, struct pci_ops *ops,
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 1b9c799..5ee0033 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -403,8 +403,10 @@ struct pci_host_bridge_window {
 
 struct pci_host_bridge {
 	u16	domain;
+	u16 busnum;
 	struct device dev;
 	struct pci_bus *bus;		/* root bus */
+	struct list_head list;
 	struct list_head windows;	/* pci_host_bridge_windows */
 	void (*release_fn)(struct pci_host_bridge *);
 	void *release_data;
@@ -416,7 +418,8 @@ void pci_set_host_bridge_release(struct pci_host_bridge *bridge,
 		     void *release_data);
 
 int pcibios_root_bridge_prepare(struct pci_host_bridge *bridge);
-
+struct pci_host_bridge *pci_create_host_bridge(
+		struct device *parent, u32 dombus, struct list_head *resources);
 /*
  * The first PCI_BRIDGE_RESOURCE_NUM PCI bus resources (those that correspond
  * to P2P or CardBus bridge windows) go in a table.  Additional ones (for
@@ -774,6 +777,7 @@ struct pci_bus *pci_scan_bus_legacy(u32 dombus, struct pci_ops *ops, void *sysda
 struct pci_bus *pci_create_root_bus(struct device *parent, u32 dombus,
 				    struct pci_ops *ops, void *sysdata,
 				    struct list_head *resources);
+void pci_free_host_bridge(struct pci_host_bridge *host);
 int pci_bus_insert_busn_res(struct pci_bus *b, int bus, int busmax);
 int pci_bus_update_busn_res_end(struct pci_bus *b, int busmax);
 void pci_bus_release_busn_res(struct pci_bus *b);
-- 
1.7.1

