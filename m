From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 16 Jan 2015 01:44:08 +0000
Subject: [PATCH 10/28] PCI: Save sysdata in pci_host_bridge drvdata
Message-Id: <1421372666-12288-11-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421372666-12288-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1421372666-12288-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Save platform specific sysdata in pci_host_bridge
drvdata, host bridge specific operation need to
access it before the pci bus creation.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/host-bridge.c |    4 +++-
 drivers/pci/probe.c       |   18 ++++++++----------
 include/linux/pci.h       |    3 ++-
 3 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
index c9ee582..0b6ba5c 100644
--- a/drivers/pci/host-bridge.c
+++ b/drivers/pci/host-bridge.c
@@ -23,7 +23,8 @@ static void pci_release_host_bridge_dev(struct device *dev)
 }
 
 struct pci_host_bridge *pci_create_host_bridge(
-		struct device *parent, u32 db, struct list_head *resources)
+		struct device *parent, u32 db,
+		struct list_head *resources, void *sysdata)
 {
 	int error;
 	int bus = PCI_BUSNUM(db);
@@ -58,6 +59,7 @@ struct pci_host_bridge *pci_create_host_bridge(
 	host->dev.parent = parent;
 	INIT_LIST_HEAD(&host->windows);
 	host->dev.release = pci_release_host_bridge_dev;
+	dev_set_drvdata(&host->dev, sysdata);
 	dev_set_name(&host->dev, "pci%04x:%02x", host->domain, 
 			host->busnum);
 
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 2e0b952..98a8d97 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1865,8 +1865,7 @@ void __weak pcibios_remove_bus(struct pci_bus *bus)
 }
 
 static struct pci_bus *__pci_create_root_bus(
-		struct pci_host_bridge *bridge, struct pci_ops *ops,
-		void *sysdata)
+		struct pci_host_bridge *bridge, struct pci_ops *ops)
 {
 	int error;
 	struct pci_bus *b;
@@ -1882,7 +1881,7 @@ static struct pci_bus *__pci_create_root_bus(
 	if (!b)
 		return NULL;
 
-	b->sysdata = sysdata;
+	b->sysdata = dev_get_drvdata(&bridge->dev);
 	b->ops = ops;
 	b->number = b->busn_res.start = bridge->busnum;
 	pci_bus_assign_domain_nr(b, parent);
@@ -1954,11 +1953,11 @@ struct pci_bus *pci_create_root_bus(struct device *parent, u32 db,
 {
 	struct pci_host_bridge *host;
 
-	host = pci_create_host_bridge(parent, db, resources);
+	host = pci_create_host_bridge(parent, db, resources, sysdata);
 	if (!host)
 		return NULL;
 	
-	return __pci_create_root_bus(host, ops, sysdata);
+	return __pci_create_root_bus(host, ops);
 }
 
 int pci_bus_insert_busn_res(struct pci_bus *b, int bus, int bus_max)
@@ -2025,8 +2024,7 @@ void pci_bus_release_busn_res(struct pci_bus *b)
 }
 
 static struct pci_bus *__pci_scan_root_bus(
-		struct pci_host_bridge *host, struct pci_ops *ops,
-		void *sysdata)
+		struct pci_host_bridge *host, struct pci_ops *ops)
 {
 
 	struct pci_host_bridge_window *window;
@@ -2040,7 +2038,7 @@ static struct pci_bus *__pci_scan_root_bus(
 			break;
 		}
 
-	b = __pci_create_root_bus(host, ops, sysdata);
+	b = __pci_create_root_bus(host, ops);
 	if (!b) {
 		pci_free_host_bridge(host);
 		return NULL;
@@ -2066,11 +2064,11 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, u32 db,
 {
 	struct pci_host_bridge *host;
 
-	host = pci_create_host_bridge(parent, db, resources);
+	host = pci_create_host_bridge(parent, db, resources, sysdata);
 	if (!host)
 		return NULL;
 
-	return __pci_scan_root_bus(host, ops, sysdata);
+	return __pci_scan_root_bus(host, ops);
 }
 EXPORT_SYMBOL(pci_scan_root_bus);
 
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 5ee0033..3ee8436 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -419,7 +419,8 @@ void pci_set_host_bridge_release(struct pci_host_bridge *bridge,
 
 int pcibios_root_bridge_prepare(struct pci_host_bridge *bridge);
 struct pci_host_bridge *pci_create_host_bridge(
-		struct device *parent, u32 dombus, struct list_head *resources);
+		struct device *parent, u32 dombus,
+		struct list_head *resources, void *sysdata);
 /*
  * The first PCI_BRIDGE_RESOURCE_NUM PCI bus resources (those that correspond
  * to P2P or CardBus bridge windows) go in a table.  Additional ones (for
-- 
1.7.1

