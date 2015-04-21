From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 21 Apr 2015 11:34:30 +0000
Subject: [PATCH v10 11/29] PCI: Save sysdata in pci_host_bridge drvdata
Message-Id: <1429616088-10249-12-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1429616088-10249-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1429616088-10249-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, dja@axtens.net, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Save platform specific sysdata in pci_host_bridge
drvdata, host bridge specific operation need to
access it before the pci bus creation.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/host-bridge.c |    3 ++-
 drivers/pci/pci.h         |    2 +-
 drivers/pci/probe.c       |   13 ++++++-------
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
index e05d8fc..b1cc6ef 100644
--- a/drivers/pci/host-bridge.c
+++ b/drivers/pci/host-bridge.c
@@ -81,7 +81,7 @@ static int pci_host_busn_res_check(
 }
 
 struct pci_host_bridge *pci_create_host_bridge(
-		struct device *parent, int domain,
+		struct device *parent, int domain, void *sysdata,
 		struct list_head *resources)
 {
 	int error, bus;
@@ -118,6 +118,7 @@ struct pci_host_bridge *pci_create_host_bridge(
 	mutex_unlock(&pci_host_mutex);
 
 	host->dev.release = pci_release_host_bridge_dev;
+	dev_set_drvdata(&host->dev, sysdata);
 	dev_set_name(&host->dev, "pci%04x:%02x",
 			host->domain, bus);
 
diff --git a/drivers/pci/pci.h b/drivers/pci/pci.h
index 947c05a..3d6f455 100644
--- a/drivers/pci/pci.h
+++ b/drivers/pci/pci.h
@@ -334,6 +334,6 @@ static inline void pci_bus_assign_domain_nr(struct pci_bus *bus,
 struct resource_entry *pci_busn_resource(struct list_head *resources);
 void pci_host_assign_domain_nr(struct pci_host_bridge *host, int domain);
 struct pci_host_bridge *pci_create_host_bridge(struct device *parent,
-		int domain, struct list_head *resources);
+		int domain, void *sysdata, struct list_head *resources);
 void pci_free_host_bridge(struct pci_host_bridge *host);
 #endif /* DRIVERS_PCI_H */
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index d8c4da8..cba3474 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1871,8 +1871,7 @@ void __weak pcibios_remove_bus(struct pci_bus *bus)
 }
 
 static struct pci_bus *__pci_create_root_bus(
-		struct pci_host_bridge *bridge, struct pci_ops *ops,
-		void *sysdata)
+		struct pci_host_bridge *bridge, struct pci_ops *ops)
 {
 	int error, bus;
 	struct pci_bus *b;
@@ -1892,7 +1891,7 @@ static struct pci_bus *__pci_create_root_bus(
 	if (!b)
 		return NULL;
 
-	b->sysdata = sysdata;
+	b->sysdata = dev_get_drvdata(&bridge->dev);
 	b->ops = ops;
 	b->number = b->busn_res.start = bus;
 	pci_bus_assign_domain_nr(b, parent);
@@ -1973,11 +1972,11 @@ struct pci_bus *pci_create_root_bus(struct device *parent,
 		return NULL;
 	}
 
-	host = pci_create_host_bridge(parent, domain, resources);
+	host = pci_create_host_bridge(parent, domain, sysdata, resources);
 	if (!host)
 		return NULL;
 
-	host->bus = __pci_create_root_bus(host, ops, sysdata);
+	host->bus = __pci_create_root_bus(host, ops);
 	if (!host->bus) {
 		pci_free_host_bridge(host);
 		return NULL;
@@ -2083,7 +2082,7 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, int domain,
 			bus);
 	}
 
-	host = pci_create_host_bridge(parent, domain, resources);
+	host = pci_create_host_bridge(parent, domain, sysdata, resources);
 	if (!host) {
 		kfree(busn_resource);
 		return NULL;
@@ -2092,7 +2091,7 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, int domain,
 	if (busn_resource)
 		host->dynamic_busn = true;
 
-	host->bus = __pci_create_root_bus(host, ops, sysdata);
+	host->bus = __pci_create_root_bus(host, ops);
 	if (!host->bus) {
 		pci_free_host_bridge(host);
 		return NULL;
-- 
1.7.1

