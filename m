From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 03 Apr 2015 09:26:01 +0000
Subject: [PATCH v9 27/30] PCI: Rename __pci_create_root_bus() to pci_create_root_bus()
Message-Id: <1428053164-28277-29-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1428053164-28277-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1428053164-28277-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, dja@axtens.net, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Now no one use pci_create_root_bus(), we could remove it
and rename __pci_create_root_bus() to pci_create_root_bus().

Signed-off-by: wangyijing@huawei.com
---
 drivers/pci/probe.c |   35 +++++++++--------------------------
 include/linux/pci.h |    3 ---
 2 files changed, 9 insertions(+), 29 deletions(-)

diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 7796bf8..cb0237f 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1852,7 +1852,7 @@ void __weak pcibios_remove_bus(struct pci_bus *bus)
 {
 }
 
-static struct pci_bus *__pci_create_root_bus(
+static struct pci_bus *pci_create_root_bus(
 		struct pci_host_bridge *bridge, struct pci_ops *ops)
 {
 	int error;
@@ -1937,24 +1937,6 @@ put_dev:
 	return NULL;
 }
 
-struct pci_bus *pci_create_root_bus(struct device *parent,
-		int domain, int bus, struct pci_ops *ops, void *sysdata,
-		struct list_head *resources)
-{
-	struct pci_host_bridge *host;
-
-	host = pci_create_host_bridge(parent, domain, bus,
-			sysdata, resources, NULL);
-	if (!host)
-		return NULL;
-
-	host->bus = __pci_create_root_bus(host, ops);
-	if (!host->bus)
-		pci_free_host_bridge(host);
-
-	return host->bus;
-}
-
 int pci_bus_insert_busn_res(struct pci_bus *b, int bus, int bus_max)
 {
 	struct resource *res = &b->busn_res;
@@ -2030,7 +2012,7 @@ static struct pci_bus *__pci_scan_root_bus(
 	struct pci_bus *b;
 	int max;
 
-	b = __pci_create_root_bus(host, ops);
+	b = pci_create_root_bus(host, ops);
 	if (!b)
 		return NULL;
 
@@ -2093,19 +2075,20 @@ struct pci_bus *pci_scan_bus(int domain, int bus,
 		struct pci_ops *ops, void *sysdata)
 {
 	LIST_HEAD(resources);
-	struct pci_bus *b;
+	struct pci_host_bridge *host;
 
 	pci_add_resource(&resources, &ioport_resource);
 	pci_add_resource(&resources, &iomem_resource);
 	pci_add_resource(&resources, &busn_resource);
-	b = pci_create_root_bus(NULL, domain, bus, ops, sysdata,
-			&resources);
-	if (b) {
-		pci_scan_child_bus(b);
+	host = pci_create_host_bridge(NULL, domain, bus, sysdata,
+			&resources, NULL);
+	if (host) {
+		__pci_scan_root_bus(host, ops);
+		return host->bus;
 	} else {
 		pci_free_resource_list(&resources);
 	}
-	return b;
+	return NULL;
 }
 EXPORT_SYMBOL(pci_scan_bus);
 
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 61e0853..62333ff 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -782,9 +782,6 @@ struct pci_bus *pci_find_bus(int domain, int busnr);
 void pci_bus_add_devices(const struct pci_bus *bus);
 struct pci_bus *pci_scan_bus(int domain, int bus, struct pci_ops *ops,
 					void *sysdata);
-struct pci_bus *pci_create_root_bus(struct device *parent, int domain, int bus,
-				    struct pci_ops *ops, void *sysdata,
-				    struct list_head *resources);
 int pci_bus_insert_busn_res(struct pci_bus *b, int bus, int busmax);
 int pci_bus_update_busn_res_end(struct pci_bus *b, int busmax);
 void pci_bus_release_busn_res(struct pci_bus *b);
-- 
1.7.1

