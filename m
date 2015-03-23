From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 23 Mar 2015 12:40:33 +0000
Subject: [PATCH v7 07/31] PCI: Add default bus resource in pci_host_bridge
Message-Id: <1427114457-16687-8-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1427114457-16687-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1427114457-16687-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

If there is no busn resource provided for pci_scan_root_bus(),
we would insert a default bus resource (root_bus_number, 255)
in root bus, and update the max bus number we found after
pci_scan_child_bus(). We also need to hold the default bus
resource in pci_host_bridge, then we could identify whether
the new pci host bridge conflict with existing one.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/host-bridge.c |   20 ++++++++++++++++++++
 drivers/pci/probe.c       |   26 ++++++++++----------------
 include/linux/pci.h       |    2 ++
 3 files changed, 32 insertions(+), 16 deletions(-)

diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
index 7d52a0a..ecc1a7c 100644
--- a/drivers/pci/host-bridge.c
+++ b/drivers/pci/host-bridge.c
@@ -19,6 +19,25 @@ static void pci_release_host_bridge_dev(struct device *dev)
 	kfree(bridge);
 }
 
+static void pci_host_update_busn_res(
+		struct pci_host_bridge *host, int bus,
+		struct list_head *resources)
+{
+	struct resource_entry *window;
+
+	resource_list_for_each_entry(window, resources)
+		if (window->res->flags & IORESOURCE_BUS)
+			return;
+
+	pr_info(
+	 "No busn resource found for pci%04x:%02x, will use [bus %02x-ff]\n",
+		host->domain, bus, bus);
+	host->busn_res.flags = IORESOURCE_BUS;
+	host->busn_res.start = bus;
+	host->busn_res.end = 255;
+	pci_add_resource(resources, &host->busn_res);
+}
+
 struct pci_host_bridge *pci_create_host_bridge(
 		struct device *parent, int domain, int bus,
 		struct list_head *resources)
@@ -33,6 +52,7 @@ struct pci_host_bridge *pci_create_host_bridge(
 
 	host->dev.parent = parent;
 	INIT_LIST_HEAD(&host->windows);
+	pci_host_update_busn_res(host, bus, resources);
 	resource_list_for_each_entry_safe(window, n, resources)
 		list_move_tail(&window->node, &host->windows);
 	/*
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 9bc4784..d5a12d9 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -2022,6 +2022,12 @@ int pci_bus_update_busn_res_end(struct pci_bus *b, int bus_max)
 	return ret;
 }
 
+static void pci_host_update_busn_res_end(
+		struct pci_host_bridge *host, int max)
+{
+	host->busn_res.end = max;
+}
+
 void pci_bus_release_busn_res(struct pci_bus *b)
 {
 	struct resource *res = &b->busn_res;
@@ -2040,32 +2046,20 @@ static struct pci_bus *__pci_scan_root_bus(int bus,
 		struct pci_host_bridge *host, struct pci_ops *ops,
 		void *sysdata)
 {
-	struct resource_entry *window;
-	bool found = false;
 	struct pci_bus *b;
 	int max;
 
-	resource_list_for_each_entry(window, &host->windows)
-		if (window->res->flags & IORESOURCE_BUS) {
-			found = true;
-			break;
-		}
-
 	b = __pci_create_root_bus(bus, host, ops, sysdata);
 	if (!b)
 		return NULL;
 
-	if (!found) {
-		dev_info(&b->dev,
-		 "No busn resource found for root bus, will use [bus %02x-ff]\n",
-			bus);
-		pci_bus_insert_busn_res(b, bus, 255);
-	}
-
 	max = pci_scan_child_bus(b);
 
-	if (!found)
+	/* If default busn resource used, update the max bus number */
+	if (host->busn_res.flags & IORESOURCE_BUS) {
+		pci_host_update_busn_res_end(host, max);
 		pci_bus_update_busn_res_end(b, max);
+	}
 
 	return b;
 }
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 1542df8..f189dfb 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -404,6 +404,8 @@ struct pci_host_bridge {
 	int domain;
 	struct device dev;
 	struct pci_bus *bus;		/* root bus */
+	/* we use default bus resource if no bus resource provided */
+	struct resource busn_res;
 	struct list_head windows;	/* resource_entry */
 	void (*release_fn)(struct pci_host_bridge *);
 	void *release_data;
-- 
1.7.1

