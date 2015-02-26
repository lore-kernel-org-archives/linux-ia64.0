From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 26 Feb 2015 08:12:21 +0000
Subject: [PATCH v4 27/30] PCI: Rename __pci_create_root_bus() to pci_create_root_bus()
Message-Id: <1424938344-4017-28-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424938344-4017-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1424938344-4017-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Now no one use pci_create_root_bus(), we could remove it
and rename __pci_create_root_bus() to pci_create_root_bus().

Signed-off-by: wangyijing@huawei.com
---
 drivers/pci/probe.c |   27 ++++++++-------------------
 include/linux/pci.h |    3 ---
 2 files changed, 8 insertions(+), 22 deletions(-)

diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 356c90f..2e5997a 100644
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
@@ -1935,18 +1935,6 @@ err_out:
 	return NULL;
 }
 
-struct pci_bus *pci_create_root_bus(struct device *parent, u32 db,
-		struct pci_ops *ops, void *sysdata, struct list_head *resources)
-{
-	struct pci_host_bridge *host;
-
-	host = pci_create_host_bridge(parent, db, resources, sysdata, NULL);
-	if (!host)
-		return NULL;
-	
-	return __pci_create_root_bus(host, ops);
-}
-
 int pci_bus_insert_busn_res(struct pci_bus *b, int bus, int bus_max)
 {
 	struct resource *res = &b->busn_res;
@@ -2024,7 +2012,7 @@ static struct pci_bus *__pci_scan_root_bus(
 			break;
 		}
 
-	b = __pci_create_root_bus(host, ops);
+	b = pci_create_root_bus(host, ops);
 	if (!b) {
 		pci_free_host_bridge(host);
 		return NULL;
@@ -2086,18 +2074,19 @@ struct pci_bus *pci_scan_bus_legacy(u32 db, struct pci_ops *ops,
 					void *sysdata)
 {
 	LIST_HEAD(resources);
-	struct pci_bus *b;
+	struct pci_host_bridge *host;
 
 	pci_add_resource(&resources, &ioport_resource);
 	pci_add_resource(&resources, &iomem_resource);
 	pci_add_resource(&resources, &busn_resource);
-	b = pci_create_root_bus(NULL, db, ops, sysdata, &resources);
-	if (b) {
-		pci_scan_child_bus(b);
+	host = pci_create_host_bridge(NULL, db, sysdata, &resources, NULL);
+	if (host) {
+		__pci_scan_root_bus(host, ops);
+		return host->bus;
 	} else {
 		pci_free_resource_list(&resources);
 	}
-	return b;
+	return NULL;
 }
 EXPORT_SYMBOL(pci_scan_bus_legacy);
 
diff --git a/include/linux/pci.h b/include/linux/pci.h
index d266d74..2f29e95 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -781,9 +781,6 @@ void pcibios_scan_specific_bus(int busn);
 struct pci_bus *pci_find_bus(int domain, int busnr);
 void pci_bus_add_devices(const struct pci_bus *bus);
 struct pci_bus *pci_scan_bus_legacy(u32 dombus, struct pci_ops *ops, void *sysdata);
-struct pci_bus *pci_create_root_bus(struct device *parent, u32 dombus,
-				    struct pci_ops *ops, void *sysdata,
-				    struct list_head *resources);
 void pci_free_host_bridge(struct pci_host_bridge *host);
 int pci_bus_insert_busn_res(struct pci_bus *b, int bus, int busmax);
 int pci_bus_update_busn_res_end(struct pci_bus *b, int busmax);
-- 
1.7.1

