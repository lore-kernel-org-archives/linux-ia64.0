From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 21 Apr 2015 11:34:46 +0000
Subject: [PATCH v10 27/29] PCI: Rename __pci_create_root_bus() to pci_create_root_bus()
Message-Id: <1429616088-10249-28-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1429616088-10249-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1429616088-10249-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, dja@axtens.net, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Now no one use pci_create_root_bus(), we could remove it
and rename __pci_create_root_bus() to pci_create_root_bus().

Signed-off-by: wangyijing@huawei.com
---
 drivers/pci/probe.c |   57 +++++++++++++++-----------------------------------
 include/linux/pci.h |    3 --
 2 files changed, 17 insertions(+), 43 deletions(-)

diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 2ba6754..c9bee34 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1858,7 +1858,7 @@ void __weak pcibios_remove_bus(struct pci_bus *bus)
 {
 }
 
-static struct pci_bus *__pci_create_root_bus(
+static struct pci_bus *pci_create_root_bus(
 		struct pci_host_bridge *bridge, struct pci_ops *ops)
 {
 	int error, bus;
@@ -1947,34 +1947,6 @@ put_bridge:
 }
 EXPORT_SYMBOL_GPL(pci_create_root_bus);
 
-struct pci_bus *pci_create_root_bus(struct device *parent,
-		int domain, struct pci_ops *ops, void *sysdata,
-		struct list_head *resources)
-{
-	struct resource_entry *busn_res;
-	struct pci_host_bridge *host;
-
-	busn_res = pci_busn_resource(resources);
-	if (!busn_res) {
-		pr_err("No busn resource found\n");
-		return NULL;
-	}
-
-	host = pci_create_host_bridge(parent, domain, sysdata,
-			resources, NULL);
-	if (!host)
-		return NULL;
-
-	host->bus = __pci_create_root_bus(host, ops);
-	if (!host->bus) {
-		pci_free_host_bridge(host);
-		return NULL;
-	}
-
-	return host->bus;
-}
-
-
 int pci_bus_insert_busn_res(struct pci_bus *b, int bus, int bus_max)
 {
 	struct resource *res = &b->busn_res;
@@ -2060,7 +2032,7 @@ struct pci_host_bridge *pci_scan_host_bridge(
 	if (!host)
 		return NULL;
 
-	host->bus = __pci_create_root_bus(host, ops->pci_ops);
+	host->bus = pci_create_root_bus(host, ops->pci_ops);
 	if (!host->bus) {
 		pci_free_host_bridge(host);
 		return NULL;
@@ -2104,7 +2076,7 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, int domain,
 	if (busn_resource)
 		host->dynamic_busn = true;
 
-	host->bus = __pci_create_root_bus(host, ops);
+	host->bus = pci_create_root_bus(host, ops);
 	if (!host->bus) {
 		pci_free_host_bridge(host);
 		return NULL;
@@ -2123,7 +2095,6 @@ struct pci_bus *pci_scan_bus(int domain, int bus,
 		struct pci_ops *ops, void *sysdata)
 {
 	LIST_HEAD(resources);
-	struct pci_bus *b;
 	struct resource *busn_resource;
 	struct pci_host_bridge *host;
 
@@ -2137,17 +2108,23 @@ struct pci_bus *pci_scan_bus(int domain, int bus,
 	pci_add_resource(&resources, &ioport_resource);
 	pci_add_resource(&resources, &iomem_resource);
 	pci_add_resource(&resources, busn_resource);
-	b = pci_create_root_bus(NULL, domain, ops, sysdata,
-			&resources);
-	if (b) {
-		host = to_pci_host_bridge(b->bridge);
-		host->dynamic_busn = true;
-		pci_scan_child_bus(b);
-	} else {
+	host = pci_create_host_bridge(NULL, domain, sysdata,
+			&resources, NULL);
+	if (!host) {
 		kfree(busn_resource);
 		pci_free_resource_list(&resources);
+		return NULL;
 	}
-	return b;
+
+	host->dynamic_busn = true;
+	host->bus = pci_create_root_bus(host, ops);
+	if (!host->bus) {
+		pci_free_host_bridge(host);
+		return NULL;
+	}
+
+	pci_scan_child_bus(host->bus);
+	return host->bus;
 }
 EXPORT_SYMBOL(pci_scan_bus);
 
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 41eb672..7a9bd2d 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -785,9 +785,6 @@ struct pci_bus *pci_find_bus(int domain, int busnr);
 void pci_bus_add_devices(const struct pci_bus *bus);
 struct pci_bus *pci_scan_bus(int domain, int bus, struct pci_ops *ops,
 					void *sysdata);
-struct pci_bus *pci_create_root_bus(struct device *parent, int domain,
-				    struct pci_ops *ops, void *sysdata,
-				    struct list_head *resources);
 int pci_bus_insert_busn_res(struct pci_bus *b, int bus, int busmax);
 int pci_bus_update_busn_res_end(struct pci_bus *b, int busmax);
 void pci_bus_release_busn_res(struct pci_bus *b);
-- 
1.7.1

