From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 23 Mar 2015 12:40:40 +0000
Subject: [PATCH v7 14/31] PCI: Introduce pci_host_bridge_ops to support host specific operations
Message-Id: <1427114457-16687-15-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1427114457-16687-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1427114457-16687-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Now we have weak functions like pcibios_root_bridge_prepare()
to setup pci host bridge, We could introduce pci_host_bridge_ops
which contain host bridge specific ops to setup pci_host_bridge.
Then host bridge driver could add pci_host_bridge_ops hooks
intead of weak function to setup pci_host_bridge.
This patch add following pci_host_bridge_ops hooks:

pci_host_bridge_ops {
	struct pci_ops *ops;
	/* set root bus speed, some platform need this like powerpc */
	void (*set_root_bus_speed)(struct pci_host_bridge *host);
	/* setup pci_host_bridge before pci_host_bridge be added to driver core */
	int (*prepare)(struct pci_host_bridge *host);
	/* platform specific of scan hook to scan pci device */
	int (*scan_bus)(struct pci_host_bridge *);
}
We could easily extend it to support different host bridge
specific operations.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/host-bridge.c |    9 ++++++++-
 drivers/pci/pci.h         |    5 +++--
 drivers/pci/probe.c       |   11 ++++++++---
 include/linux/pci.h       |    9 +++++++++
 4 files changed, 28 insertions(+), 6 deletions(-)

diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
index 87c4fc5..b439264 100644
--- a/drivers/pci/host-bridge.c
+++ b/drivers/pci/host-bridge.c
@@ -63,7 +63,8 @@ static bool pci_host_busn_res_overlap(
 
 struct pci_host_bridge *pci_create_host_bridge(
 		struct device *parent, int domain, int bus,
-		void *sysdata, struct list_head *resources)
+		void *sysdata, struct list_head *resources,
+		struct pci_host_bridge_ops *ops)
 {
 	int error;
 	struct pci_host_bridge *host, *tmp;
@@ -98,10 +99,16 @@ struct pci_host_bridge *pci_create_host_bridge(
 	list_add_tail(&host->list, &pci_host_bridge_list);
 	mutex_unlock(&pci_host_mutex);
 
+	host->ops = ops;
 	host->dev.release = pci_release_host_bridge_dev;
 	dev_set_drvdata(&host->dev, sysdata);
 	dev_set_name(&host->dev, "pci%04x:%02x",
 			host->domain, bus);
+	if (host->ops && host->ops->prepare) {
+		error = host->ops->prepare(host);
+		if (error)
+			goto list_del;
+	}
 
 	error = pcibios_root_bridge_prepare(host);
 	if (error)
diff --git a/drivers/pci/pci.h b/drivers/pci/pci.h
index 027fba0..ef10cc1 100644
--- a/drivers/pci/pci.h
+++ b/drivers/pci/pci.h
@@ -334,8 +334,9 @@ static inline void pci_host_assign_domain_nr(struct pci_host_bridge *host)
 }
 #endif
 
-struct pci_host_bridge *pci_create_host_bridge(struct device *parent,
-        int domain, int bus, void *sysdata, struct list_head *resources);
+struct pci_host_bridge *pci_create_host_bridge(
+		struct device *parent, int domain, int bus, void *sysdata,
+		struct list_head *resources, struct pci_host_bridge_ops *ops);
 void pci_free_host_bridge(struct pci_host_bridge *host);
 
 static inline int pci_host_first_busnr(struct pci_host_bridge *host)
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index ee17d9a..36dfee0 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1894,6 +1894,8 @@ static struct pci_bus *__pci_create_root_bus(
 	bridge->bus = b;
 	b->bridge = get_device(&bridge->dev);
 
+	if (bridge->ops && bridge->ops->set_root_bus_speed)
+		bridge->ops->set_root_bus_speed(bridge);
 	pcibios_set_root_bus_speed(bridge);
 	device_enable_async_suspend(b->bridge);
 	pci_set_bus_of_node(b);
@@ -1958,7 +1960,7 @@ struct pci_bus *pci_create_root_bus(struct device *parent,
 	struct pci_host_bridge *host;
 
 	host = pci_create_host_bridge(parent, domain, bus,
-			sysdata, resources);
+			sysdata, resources, NULL);
 	if (!host)
 		return NULL;
 
@@ -2048,7 +2050,10 @@ static struct pci_bus *__pci_scan_root_bus(
 	if (!b)
 		return NULL;
 
-	max = pci_scan_child_bus(b);
+	if (host->ops && host->ops->scan_bus)
+		max = host->ops->scan_bus(host);
+	else
+		max = pci_scan_child_bus(b);
 
 	/* If default busn resource used, update the max bus number */
 	if (host->busn_res.flags & IORESOURCE_BUS) {
@@ -2066,7 +2071,7 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, int domain,
 	struct pci_host_bridge *host;
 
 	host = pci_create_host_bridge(parent, domain, bus,
-			sysdata, resources);
+			sysdata, resources, NULL);
 	if (!host)
 		return NULL;
 
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 91cba01..2702a51 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -400,6 +400,14 @@ static inline int pci_channel_offline(struct pci_dev *pdev)
 	return (pdev->error_state != pci_channel_io_normal);
 }
 
+struct pci_host_bridge;
+struct pci_host_bridge_ops {
+	struct pci_ops *pci_ops;
+	int (*prepare)(struct pci_host_bridge *host);
+	void (*set_root_bus_speed)(struct pci_host_bridge *host);
+	int (*scan_bus)(struct pci_host_bridge *host);
+};
+
 struct pci_host_bridge {
 	int domain;
 	struct device dev;
@@ -408,6 +416,7 @@ struct pci_host_bridge {
 	struct resource busn_res;
 	struct list_head windows;	/* resource_entry */
 	struct list_head list;
+	struct pci_host_bridge_ops *ops;
 	void (*release_fn)(struct pci_host_bridge *);
 	void *release_data;
 };
-- 
1.7.1

