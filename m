From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 21 Apr 2015 11:34:26 +0000
Subject: [PATCH v10 07/29] PCI: Allocate busn resource for pci_scan_root_bus()
Message-Id: <1429616088-10249-8-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1429616088-10249-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1429616088-10249-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, dja@axtens.net, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Some pci_scan_root_bus() callers don't supply the busn
resource, because they don't know the max bus number.
Currently we insert default busn resource[bus-FF] to root bus,
and update the max bus number after pci_scan_child_bus().
We could dynamically allocate busn resource and add it
to pci_host_bridge, in the later patch, it would be easy
to check whether new pci_host_bridge busn resource conflict.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/probe.c |   43 ++++++++++++++++++++++++++++++-------------
 1 files changed, 30 insertions(+), 13 deletions(-)

diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index c425755..0eafda2 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -2041,6 +2041,8 @@ int pci_bus_insert_busn_res(struct pci_bus *b, int bus, int bus_max)
 
 int pci_bus_update_busn_res_end(struct pci_bus *b, int bus_max)
 {
+	struct resource_entry *entry;
+	struct pci_host_bridge *host;
 	struct resource *res = &b->busn_res;
 	struct resource old_res = *res;
 	resource_size_t size;
@@ -2058,6 +2060,14 @@ int pci_bus_update_busn_res_end(struct pci_bus *b, int bus_max)
 	if (!ret && !res->parent)
 		pci_bus_insert_busn_res(b, res->start, res->end);
 
+	if (!ret && pci_is_root_bus(b)) {
+		host = to_pci_host_bridge(b->bridge);
+		if (host->dynamic_busn) {
+			entry = pci_busn_resource(&host->windows);
+			entry->res->end = bus_max;
+		}
+	}
+
 	return ret;
 }
 
@@ -2079,32 +2089,39 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, int domain,
 		int bus, struct pci_ops *ops, void *sysdata,
 		struct list_head *resources)
 {
-	struct resource_entry *window;
-	bool found = false;
+	struct resource_entry *entry;
+	struct resource *busn_resource = NULL;
+	struct pci_host_bridge *host;
 	struct pci_bus *b;
 	int max;
 
-	resource_list_for_each_entry(window, resources)
-		if (window->res->flags & IORESOURCE_BUS) {
-			found = true;
-			break;
-		}
+	entry = pci_busn_resource(resources);
+	if (!entry) {
+		busn_resource = kzalloc(sizeof (struct resource), GFP_KERNEL);
+		if (!busn_resource)
+			return NULL;
+		busn_resource->start = bus;
+		busn_resource->end = 255;
+		busn_resource->flags = IORESOURCE_BUS;
+		pci_add_resource(resources, busn_resource);
+		pr_info(
+		 "No busn resource found for root bus, will use [bus %02x-ff]\n",
+			bus);
+	}
 
 	b = pci_create_root_bus(parent, domain, ops,
 			sysdata, resources);
 	if (!b)
 		return NULL;
 
-	if (!found) {
-		dev_info(&b->dev,
-		 "No busn resource found for root bus, will use [bus %02x-ff]\n",
-			bus);
-		pci_bus_insert_busn_res(b, bus, 255);
+	if (busn_resource) {
+		host = to_pci_host_bridge(b->bridge);
+		host->dynamic_busn = true;
 	}
 
 	max = pci_scan_child_bus(b);
 
-	if (!found)
+	if (busn_resource)
 		pci_bus_update_busn_res_end(b, max);
 
 	return b;
-- 
1.7.1

