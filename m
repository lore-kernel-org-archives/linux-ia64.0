From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 21 Apr 2015 11:34:33 +0000
Subject: [PATCH v10 14/29] PCI: Introduce pci_host_bridge_ops to support host specific operations
Message-Id: <1429616088-10249-15-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1429616088-10249-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1429616088-10249-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, dja@axtens.net, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Now we have weak functions like pcibios_root_bridge_prepare()
to setup pci host bridge, We could introduce pci_host_bridge_ops
which contain host bridge specific ops to setup pci_host_bridge.
Then host bridge driver could add pci_host_bridge_ops hooks
intead of weak function to setup pci_host_bridge.
This patch add following pci_host_bridge_ops hooks:

pci_host_bridge_ops {
	struct pci_ops *pci_ops;
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
 drivers/pci/pci.h         |    3 ++-
 drivers/pci/probe.c       |    8 ++++++--
 include/linux/pci.h       |    9 +++++++++
 4 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
index 6309970..7e25f53 100644
--- a/drivers/pci/host-bridge.c
+++ b/drivers/pci/host-bridge.c
@@ -82,7 +82,8 @@ static int pci_host_busn_res_check(
 
 struct pci_host_bridge *pci_create_host_bridge(
 		struct device *parent, int domain, void *sysdata,
-		struct list_head *resources)
+		struct list_head *resources,
+		struct pci_host_bridge_ops *ops)
 {
 	int error, bus;
 	struct pci_host_bridge *host, *tmp;
@@ -115,10 +116,16 @@ struct pci_host_bridge *pci_create_host_bridge(
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
index 3d6f455..0432889 100644
--- a/drivers/pci/pci.h
+++ b/drivers/pci/pci.h
@@ -334,6 +334,7 @@ static inline void pci_bus_assign_domain_nr(struct pci_bus *bus,
 struct resource_entry *pci_busn_resource(struct list_head *resources);
 void pci_host_assign_domain_nr(struct pci_host_bridge *host, int domain);
 struct pci_host_bridge *pci_create_host_bridge(struct device *parent,
-		int domain, void *sysdata, struct list_head *resources);
+		int domain, void *sysdata, struct list_head *resources,
+		struct pci_host_bridge_ops *ops);
 void pci_free_host_bridge(struct pci_host_bridge *host);
 #endif /* DRIVERS_PCI_H */
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index e75b27c..83cf7c6 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1903,6 +1903,8 @@ static struct pci_bus *__pci_create_root_bus(
 	bridge->bus = b;
 	b->bridge = get_device(&bridge->dev);
 
+	if (bridge->ops && bridge->ops->set_root_bus_speed)
+		bridge->ops->set_root_bus_speed(bridge);
 	pcibios_set_root_bus_speed(bridge);
 	device_enable_async_suspend(b->bridge);
 	pci_set_bus_of_node(b);
@@ -1974,7 +1976,8 @@ struct pci_bus *pci_create_root_bus(struct device *parent,
 		return NULL;
 	}
 
-	host = pci_create_host_bridge(parent, domain, sysdata, resources);
+	host = pci_create_host_bridge(parent, domain, sysdata,
+			resources, NULL);
 	if (!host)
 		return NULL;
 
@@ -2084,7 +2087,8 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, int domain,
 			bus);
 	}
 
-	host = pci_create_host_bridge(parent, domain, sysdata, resources);
+	host = pci_create_host_bridge(parent, domain, sysdata,
+			resources, NULL);
 	if (!host) {
 		kfree(busn_resource);
 		return NULL;
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 9a8a223..91fde6a 100644
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
 	bool dynamic_busn;
@@ -407,6 +415,7 @@ struct pci_host_bridge {
 	struct pci_bus *bus;		/* root bus */
 	struct list_head windows;	/* resource_entry */
 	struct list_head list;
+	struct pci_host_bridge_ops *ops;
 	void (*release_fn)(struct pci_host_bridge *);
 	void *release_data;
 	unsigned int ignore_reset_delay:1;	/* for entire hierarchy */
-- 
1.7.1

