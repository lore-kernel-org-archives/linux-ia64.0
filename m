From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 03 Apr 2015 09:25:40 +0000
Subject: [PATCH v9 06/30] PCI: Separate pci_host_bridge creation out of pci_create_root_bus()
Message-Id: <1428053164-28277-8-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1428053164-28277-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1428053164-28277-1-git-send-email-wangyijing@huawei.com>
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
 drivers/pci/host-bridge.c |   52 +++++++++++++++++++++
 drivers/pci/pci.h         |    3 +
 drivers/pci/probe.c       |  113 +++++++++++++++++++++------------------------
 3 files changed, 108 insertions(+), 60 deletions(-)

diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
index 39b2dbe..7d52a0a 100644
--- a/drivers/pci/host-bridge.c
+++ b/drivers/pci/host-bridge.c
@@ -8,6 +8,58 @@
 
 #include "pci.h"
 
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
+		struct device *parent, int domain, int bus,
+		struct list_head *resources)
+{
+	int error;
+	struct pci_host_bridge *host;
+	struct resource_entry *window, *n;
+
+	host = kzalloc(sizeof(*host), GFP_KERNEL);
+	if (!host)
+		return NULL;
+
+	host->dev.parent = parent;
+	INIT_LIST_HEAD(&host->windows);
+	resource_list_for_each_entry_safe(window, n, resources)
+		list_move_tail(&window->node, &host->windows);
+	/*
+	 * If support CONFIG_PCI_DOMAINS_GENERIC, use
+	 * pci_host_assign_domain_nr() to update domain
+	 * number.
+	 */
+	host->domain = domain;
+	pci_host_assign_domain_nr(host);
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
index 1d3d2d1..8526790 100644
--- a/drivers/pci/pci.h
+++ b/drivers/pci/pci.h
@@ -334,4 +334,7 @@ static inline void pci_host_assign_domain_nr(struct pci_host_bridge *host)
 }
 #endif
 
+struct pci_host_bridge *pci_create_host_bridge(struct device *parent,
+		int domain, int bus, struct list_head *resources);
+void pci_free_host_bridge(struct pci_host_bridge *host);
 #endif /* DRIVERS_PCI_H */
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 767f009..9bc4784 100644
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
@@ -1889,19 +1864,20 @@ void __weak pcibios_remove_bus(struct pci_bus *bus)
 {
 }
 
-struct pci_bus *pci_create_root_bus(struct device *parent, int domain,
-		int bus, struct pci_ops *ops, void *sysdata,
-		struct list_head *resources)
+static struct pci_bus *__pci_create_root_bus(int bus,
+		struct pci_host_bridge *bridge, struct pci_ops *ops,
+		void *sysdata)
 {
 	int error;
-	struct pci_host_bridge *bridge;
 	struct pci_bus *b, *b2;
-	struct resource_entry *window, *n;
+	struct resource_entry *window;
+	struct device *parent;
 	struct resource *res;
 	resource_size_t offset;
 	char bus_addr[64];
 	char *fmt;
 
+	parent = bridge->dev.parent;
 	b = pci_alloc_bus(NULL);
 	if (!b)
 		return NULL;
@@ -1917,26 +1893,12 @@ struct pci_bus *pci_create_root_bus(struct device *parent, int domain,
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
+		goto put_dev;
 
-	error = device_register(&bridge->dev);
-	if (error) {
-		put_device(&bridge->dev);
-		goto err_out;
-	}
-	b->bridge = get_device(&bridge->dev);
 	device_enable_async_suspend(b->bridge);
 	pci_set_bus_of_node(b);
 
@@ -1945,10 +1907,10 @@ struct pci_bus *pci_create_root_bus(struct device *parent, int domain,
 
 	b->dev.class = &pcibus_class;
 	b->dev.parent = b->bridge;
-	dev_set_name(&b->dev, "%04x:%02x", pci_domain_nr(b), bus);
+	dev_set_name(&b->dev, "%04x:%02x", bridge->domain, bus);
 	error = device_register(&b->dev);
 	if (error)
-		goto class_dev_reg_err;
+		goto put_dev;
 
 	pcibios_add_bus(b);
 
@@ -1961,8 +1923,7 @@ struct pci_bus *pci_create_root_bus(struct device *parent, int domain,
 		printk(KERN_INFO "PCI host bridge to bus %s\n", dev_name(&b->dev));
 
 	/* Add initial resources to the bus */
-	resource_list_for_each_entry_safe(window, n, resources) {
-		list_move_tail(&window->node, &bridge->windows);
+	resource_list_for_each_entry(window, &bridge->windows) {
 		res = window->res;
 		offset = window->offset;
 		if (res->flags & IORESOURCE_BUS)
@@ -1988,14 +1949,30 @@ struct pci_bus *pci_create_root_bus(struct device *parent, int domain,
 
 	return b;
 
-class_dev_reg_err:
+put_dev:
 	put_device(&bridge->dev);
-	device_unregister(&bridge->dev);
 err_out:
 	kfree(b);
 	return NULL;
 }
 
+struct pci_bus *pci_create_root_bus(struct device *parent,
+		int domain, int bus, struct pci_ops *ops, void *sysdata,
+		struct list_head *resources)
+{
+	struct pci_host_bridge *host;
+
+	host = pci_create_host_bridge(parent, domain, bus, resources);
+	if (!host)
+		return NULL;
+
+	host->bus = __pci_create_root_bus(bus, host, ops, sysdata);
+	if (!host->bus)
+		pci_free_host_bridge(host);
+
+	return host->bus;
+}
+
 int pci_bus_insert_busn_res(struct pci_bus *b, int bus, int bus_max)
 {
 	struct resource *res = &b->busn_res;
@@ -2059,23 +2036,22 @@ void pci_bus_release_busn_res(struct pci_bus *b)
 			res, ret ? "can not be" : "is");
 }
 
-struct pci_bus *pci_scan_root_bus(struct device *parent, int domain,
-		int bus, struct pci_ops *ops, void *sysdata,
-		struct list_head *resources)
+static struct pci_bus *__pci_scan_root_bus(int bus,
+		struct pci_host_bridge *host, struct pci_ops *ops,
+		void *sysdata)
 {
 	struct resource_entry *window;
 	bool found = false;
 	struct pci_bus *b;
 	int max;
 
-	resource_list_for_each_entry(window, resources)
+	resource_list_for_each_entry(window, &host->windows)
 		if (window->res->flags & IORESOURCE_BUS) {
 			found = true;
 			break;
 		}
 
-	b = pci_create_root_bus(parent, domain, bus, ops,
-			sysdata, resources);
+	b = __pci_create_root_bus(bus, host, ops, sysdata);
 	if (!b)
 		return NULL;
 
@@ -2093,6 +2069,23 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, int domain,
 
 	return b;
 }
+
+struct pci_bus *pci_scan_root_bus(struct device *parent, int domain,
+		int bus, struct pci_ops *ops, void *sysdata,
+		struct list_head *resources)
+{
+	struct pci_host_bridge *host;
+
+	host = pci_create_host_bridge(parent, domain, bus, resources);
+	if (!host)
+		return NULL;
+
+	host->bus = __pci_scan_root_bus(bus, host, ops, sysdata);
+	if (!host->bus)
+		pci_free_host_bridge(host);
+
+	return host->bus;
+}
 EXPORT_SYMBOL(pci_scan_root_bus);
 
 struct pci_bus *pci_scan_bus(int domain, int bus,
-- 
1.7.1

