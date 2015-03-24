From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 24 Mar 2015 03:34:03 +0000
Subject: [PATCH v8 09/30] PCI: Introduce pci_host_first_busnr() function
Message-Id: <1427168064-8657-10-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1427168064-8657-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1427168064-8657-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Use it to get the first bus number of the bus
resource.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/pci.h   |   11 +++++++++++
 drivers/pci/probe.c |   19 ++++++++++---------
 2 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/drivers/pci/pci.h b/drivers/pci/pci.h
index 8526790..886d72f 100644
--- a/drivers/pci/pci.h
+++ b/drivers/pci/pci.h
@@ -337,4 +337,15 @@ static inline void pci_host_assign_domain_nr(struct pci_host_bridge *host)
 struct pci_host_bridge *pci_create_host_bridge(struct device *parent,
 		int domain, int bus, struct list_head *resources);
 void pci_free_host_bridge(struct pci_host_bridge *host);
+
+static inline int pci_host_first_busnr(struct pci_host_bridge *host)
+{
+	struct resource_entry *window;
+
+	resource_list_for_each_entry(window, &host->windows)
+		if (window->res->flags & IORESOURCE_BUS)
+			return window->res->start;
+	return -1;
+}
+
 #endif /* DRIVERS_PCI_H */
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index d5a12d9..25ac741 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1864,7 +1864,7 @@ void __weak pcibios_remove_bus(struct pci_bus *bus)
 {
 }
 
-static struct pci_bus *__pci_create_root_bus(int bus,
+static struct pci_bus *__pci_create_root_bus(
 		struct pci_host_bridge *bridge, struct pci_ops *ops,
 		void *sysdata)
 {
@@ -1884,9 +1884,10 @@ static struct pci_bus *__pci_create_root_bus(int bus,
 
 	b->sysdata = sysdata;
 	b->ops = ops;
-	b->number = b->busn_res.start = bus;
+	b->number = b->busn_res.start +		pci_host_first_busnr(bridge);
 	pci_bus_assign_domain_nr(b, parent);
-	b2 = pci_find_bus(pci_domain_nr(b), bus);
+	b2 = pci_find_bus(pci_domain_nr(b), b->number);
 	if (b2) {
 		/* If we already got to this bus through a different bridge, ignore it */
 		dev_dbg(&b2->dev, "bus already known\n");
@@ -1907,7 +1908,7 @@ static struct pci_bus *__pci_create_root_bus(int bus,
 
 	b->dev.class = &pcibus_class;
 	b->dev.parent = b->bridge;
-	dev_set_name(&b->dev, "%04x:%02x", bridge->domain, bus);
+	dev_set_name(&b->dev, "%04x:%02x", bridge->domain, b->number);
 	error = device_register(&b->dev);
 	if (error)
 		goto put_dev;
@@ -1927,7 +1928,7 @@ static struct pci_bus *__pci_create_root_bus(int bus,
 		res = window->res;
 		offset = window->offset;
 		if (res->flags & IORESOURCE_BUS)
-			pci_bus_insert_busn_res(b, bus, res->end);
+			pci_bus_insert_busn_res(b, b->number, res->end);
 		else
 			pci_bus_add_resource(b, res, 0);
 		if (offset) {
@@ -1966,7 +1967,7 @@ struct pci_bus *pci_create_root_bus(struct device *parent,
 	if (!host)
 		return NULL;
 
-	host->bus = __pci_create_root_bus(bus, host, ops, sysdata);
+	host->bus = __pci_create_root_bus(host, ops, sysdata);
 	if (!host->bus)
 		pci_free_host_bridge(host);
 
@@ -2042,14 +2043,14 @@ void pci_bus_release_busn_res(struct pci_bus *b)
 			res, ret ? "can not be" : "is");
 }
 
-static struct pci_bus *__pci_scan_root_bus(int bus,
+static struct pci_bus *__pci_scan_root_bus(
 		struct pci_host_bridge *host, struct pci_ops *ops,
 		void *sysdata)
 {
 	struct pci_bus *b;
 	int max;
 
-	b = __pci_create_root_bus(bus, host, ops, sysdata);
+	b = __pci_create_root_bus(host, ops, sysdata);
 	if (!b)
 		return NULL;
 
@@ -2074,7 +2075,7 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, int domain,
 	if (!host)
 		return NULL;
 
-	host->bus = __pci_scan_root_bus(bus, host, ops, sysdata);
+	host->bus = __pci_scan_root_bus(host, ops, sysdata);
 	if (!host->bus)
 		pci_free_host_bridge(host);
 
-- 
1.7.1

