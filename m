From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 21 Apr 2015 11:34:28 +0000
Subject: [PATCH v10 09/29] PCI: Separate pci_host_bridge creation out of pci_create_root_bus()
Message-Id: <1429616088-10249-10-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1429616088-10249-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1429616088-10249-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, dja@axtens.net, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

This patch separate pci_host_bridge creation out
of pci_create_root_bus(), and try to make a generic
pci_host_bridge, then we could make it hold host
bridge specific operations like
pcibios_root_bridge_prepare(). The changes are
transparent to platform host bridge drivers.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/host-bridge.c |   58 +++++++++++++++++++++
 drivers/pci/pci.h         |    5 ++-
 drivers/pci/probe.c       |  126 ++++++++++++++++++++-------------------------
 3 files changed, 118 insertions(+), 71 deletions(-)

diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
index 5f4a2e0..78a30c2 100644
--- a/drivers/pci/host-bridge.c
+++ b/drivers/pci/host-bridge.c
@@ -8,6 +8,64 @@
 
 #include "pci.h"
 
+static void pci_release_host_bridge_dev(struct device *dev)
+{
+	struct resource_entry *entry;
+	struct pci_host_bridge *bridge = to_pci_host_bridge(dev);
+
+	if (bridge->release_fn)
+		bridge->release_fn(bridge);
+
+	if (bridge->dynamic_busn) {
+		entry = pci_busn_resource(&bridge->windows);
+		kfree(entry->res);
+	}
+
+	pci_free_resource_list(&bridge->windows);
+	kfree(bridge);
+}
+
+struct pci_host_bridge *pci_create_host_bridge(
+		struct device *parent, int domain,
+		struct list_head *resources)
+{
+	int error, bus;
+	struct pci_host_bridge *host;
+	struct resource_entry *window, *n, *busn_res;
+
+	busn_res = pci_busn_resource(resources);
+	if (!busn_res)
+		return NULL;
+
+	bus = busn_res->res->start;
+	host = kzalloc(sizeof(*host), GFP_KERNEL);
+	if (!host)
+		return NULL;
+
+	INIT_LIST_HEAD(&host->windows);
+	resource_list_for_each_entry_safe(window, n, resources)
+		list_move_tail(&window->node, &host->windows);
+
+	host->dev.parent = parent;
+	pci_host_assign_domain_nr(host, domain);
+	host->dev.release = pci_release_host_bridge_dev;
+	dev_set_name(&host->dev, "pci%04x:%02x",
+			host->domain, bus);
+
+	error = device_register(&host->dev);
+	if (error) {
+		put_device(&host->dev);
+		return NULL;
+	}
+
+	return host;
+}
+
+void pci_free_host_bridge(struct pci_host_bridge *host)
+{
+	device_unregister(&host->dev);
+}
+
 static struct pci_bus *find_pci_root_bus(struct pci_bus *bus)
 {
 	while (bus->parent)
diff --git a/drivers/pci/pci.h b/drivers/pci/pci.h
index 1e291e4..947c05a 100644
--- a/drivers/pci/pci.h
+++ b/drivers/pci/pci.h
@@ -331,6 +331,9 @@ static inline void pci_bus_assign_domain_nr(struct pci_bus *bus,
 {
 }
 #endif
-
+struct resource_entry *pci_busn_resource(struct list_head *resources);
 void pci_host_assign_domain_nr(struct pci_host_bridge *host, int domain);
+struct pci_host_bridge *pci_create_host_bridge(struct device *parent,
+		int domain, struct list_head *resources);
+void pci_free_host_bridge(struct pci_host_bridge *host);
 #endif /* DRIVERS_PCI_H */
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 0eafda2..0b80ecb 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -52,7 +52,7 @@ static struct resource *get_pci_domain_busn_res(int domain_nr)
 	return &r->res;
 }
 
-static struct resource_entry *pci_busn_resource(
+struct resource_entry *pci_busn_resource(
 		struct list_head *resources)
 {
 	struct resource_entry *entry;
@@ -507,37 +507,6 @@ static struct pci_bus *pci_alloc_bus(struct pci_bus *parent)
 	return b;
 }
 
-static void pci_release_host_bridge_dev(struct device *dev)
-{
-	struct resource_entry *entry;
-	struct pci_host_bridge *bridge = to_pci_host_bridge(dev);
-
-	if (bridge->release_fn)
-		bridge->release_fn(bridge);
-
-	if (bridge->dynamic_busn) {
-		entry = pci_busn_resource(&bridge->windows);
-		kfree(entry->res);
-	}
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
@@ -1901,22 +1870,24 @@ void __weak pcibios_remove_bus(struct pci_bus *bus)
 {
 }
 
-struct pci_bus *pci_create_root_bus(struct device *parent, int domain,
-		struct pci_ops *ops, void *sysdata, struct list_head *resources)
+static struct pci_bus *__pci_create_root_bus(
+		struct pci_host_bridge *bridge, struct pci_ops *ops,
+		void *sysdata)
 {
 	int error, bus;
-	struct pci_host_bridge *bridge;
 	struct pci_bus *b, *b2;
-	struct resource_entry *window, *n, *busn_res;
+	struct resource_entry *window, *busn_res;
+	struct device *parent;
 	struct resource *res;
 	resource_size_t offset;
 	char bus_addr[64];
 	char *fmt;
 
-	busn_res = pci_busn_resource(resources);
+	busn_res = pci_busn_resource(&bridge->windows);
 	if (!busn_res)
 		return NULL;
 	bus = busn_res->res->start;
+	parent = bridge->dev.parent;
 	b = pci_alloc_bus(NULL);
 	if (!b)
 		return NULL;
@@ -1932,26 +1903,12 @@ struct pci_bus *pci_create_root_bus(struct device *parent, int domain,
 		goto err_out;
 	}
 
-	bridge = pci_alloc_host_bridge(b);
-	if (!bridge)
-		goto err_out;
-
-	bridge->domain = domain;
-	bridge->dev.parent = parent;
-	bridge->dev.release = pci_release_host_bridge_dev;
-	dev_set_name(&bridge->dev, "pci%04x:%02x", pci_domain_nr(b), bus);
+	bridge->bus = b;
+	b->bridge = get_device(&bridge->dev);
 	error = pcibios_root_bridge_prepare(bridge);
-	if (error) {
-		kfree(bridge);
-		goto err_out;
-	}
+	if (error)
+		goto put_bridge;
 
-	error = device_register(&bridge->dev);
-	if (error) {
-		put_device(&bridge->dev);
-		goto err_out;
-	}
-	b->bridge = get_device(&bridge->dev);
 	device_enable_async_suspend(b->bridge);
 	pci_set_bus_of_node(b);
 
@@ -1960,10 +1917,10 @@ struct pci_bus *pci_create_root_bus(struct device *parent, int domain,
 
 	b->dev.class = &pcibus_class;
 	b->dev.parent = b->bridge;
-	dev_set_name(&b->dev, "%04x:%02x", pci_domain_nr(b), bus);
+	dev_set_name(&b->dev, "%04x:%02x", bridge->domain, bus);
 	error = device_register(&b->dev);
 	if (error)
-		goto class_dev_reg_err;
+		goto put_bridge;
 
 	pcibios_add_bus(b);
 
@@ -1976,8 +1933,7 @@ struct pci_bus *pci_create_root_bus(struct device *parent, int domain,
 		printk(KERN_INFO "PCI host bridge to bus %s\n", dev_name(&b->dev));
 
 	/* Add initial resources to the bus */
-	resource_list_for_each_entry_safe(window, n, resources) {
-		list_move_tail(&window->node, &bridge->windows);
+	resource_list_for_each_entry(window, &bridge->windows) {
 		res = window->res;
 		offset = window->offset;
 		if (res->flags & IORESOURCE_BUS)
@@ -2003,15 +1959,41 @@ struct pci_bus *pci_create_root_bus(struct device *parent, int domain,
 
 	return b;
 
-class_dev_reg_err:
+put_bridge:
 	put_device(&bridge->dev);
-	device_unregister(&bridge->dev);
 err_out:
 	kfree(b);
 	return NULL;
 }
 EXPORT_SYMBOL_GPL(pci_create_root_bus);
 
+struct pci_bus *pci_create_root_bus(struct device *parent,
+		int domain, struct pci_ops *ops, void *sysdata,
+		struct list_head *resources)
+{
+	struct resource_entry *busn_res;
+	struct pci_host_bridge *host;
+
+	busn_res = pci_busn_resource(resources);
+	if (!busn_res) {
+		pr_err("No busn resource found\n");
+		return NULL;
+	}
+
+	host = pci_create_host_bridge(parent, domain, resources);
+	if (!host)
+		return NULL;
+
+	host->bus = __pci_create_root_bus(host, ops, sysdata);
+	if (!host->bus) {
+		pci_free_host_bridge(host);
+		return NULL;
+	}
+
+	return host->bus;
+}
+
+
 int pci_bus_insert_busn_res(struct pci_bus *b, int bus, int bus_max)
 {
 	struct resource *res = &b->busn_res;
@@ -2092,7 +2074,6 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, int domain,
 	struct resource_entry *entry;
 	struct resource *busn_resource = NULL;
 	struct pci_host_bridge *host;
-	struct pci_bus *b;
 	int max;
 
 	entry = pci_busn_resource(resources);
@@ -2109,22 +2090,27 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, int domain,
 			bus);
 	}
 
-	b = pci_create_root_bus(parent, domain, ops,
-			sysdata, resources);
-	if (!b)
+	host = pci_create_host_bridge(parent, domain, resources);
+	if (!host) {
+		kfree(busn_resource);
 		return NULL;
+	}
 
-	if (busn_resource) {
-		host = to_pci_host_bridge(b->bridge);
+	if (busn_resource)
 		host->dynamic_busn = true;
+
+	host->bus = __pci_create_root_bus(host, ops, sysdata);
+	if (!host->bus) {
+		pci_free_host_bridge(host);
+		return NULL;
 	}
 
-	max = pci_scan_child_bus(b);
+	max = pci_scan_child_bus(host->bus);
 
 	if (busn_resource)
-		pci_bus_update_busn_res_end(b, max);
+		pci_bus_update_busn_res_end(host->bus, max);
 
-	return b;
+	return host->bus;
 }
 EXPORT_SYMBOL(pci_scan_root_bus);
 
-- 
1.7.1

