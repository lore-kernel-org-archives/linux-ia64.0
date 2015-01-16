From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 16 Jan 2015 01:44:09 +0000
Subject: [PATCH 11/28] PCI: Introduce pci_host_bridge_ops to setup host bridge
Message-Id: <1421372666-12288-12-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421372666-12288-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1421372666-12288-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Now we have weak functions like pcibios_root_bridge_prepare()
to setup pci host bridge, We could introduce pci_host_bridge_ops
which contain host bridge specific ops to setup pci_host_bridge.
Then host bridge driver could add pci_host_bridge_ops hooks
intead of weak function to setup pci_host_bridge.
This patch add following pci_host_bridge_ops hooks:

pci_host_bridge_ops {
	/* set root bus speed, some platform need this like powerpc */
	void (*phb_set_root_bus_speed)(struct pci_host_bridge *host);
	/* setup pci_host_bridge before pci_host_bridge be added to driver core */
	int (*phb_prepare)(struct pci_host_bridge *host);
	/* probe whether pci_host_bridge scan mode is of mode */
	void (*phb_probe_mode)(struct pci_host_bridge *);
	/* platform specific of scan hook to scan pci device */
	void (*phb_of_scan_bus)(struct pci_host_bridge *);
}

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/host-bridge.c |   12 ++++++++++--
 drivers/pci/probe.c       |   19 ++++++++++++++-----
 include/linux/pci.h       |   16 ++++++++++++++--
 3 files changed, 38 insertions(+), 9 deletions(-)

diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
index 0b6ba5c..ccbf168 100644
--- a/drivers/pci/host-bridge.c
+++ b/drivers/pci/host-bridge.c
@@ -23,8 +23,8 @@ static void pci_release_host_bridge_dev(struct device *dev)
 }
 
 struct pci_host_bridge *pci_create_host_bridge(
-		struct device *parent, u32 db, 
-		struct list_head *resources, void *sysdata)
+		struct device *parent, u32 db, struct list_head *resources,
+		void *sysdata, struct pci_host_bridge_ops *ops)
 {
 	int error;
 	int bus = PCI_BUSNUM(db);
@@ -56,6 +56,7 @@ struct pci_host_bridge *pci_create_host_bridge(
 		}
 	mutex_unlock(&phb_mutex);
 
+	host->ops = ops;
 	host->dev.parent = parent;
 	INIT_LIST_HEAD(&host->windows);
 	host->dev.release = pci_release_host_bridge_dev;
@@ -63,6 +64,13 @@ struct pci_host_bridge *pci_create_host_bridge(
 	dev_set_name(&host->dev, "pci%04x:%02x", host->domain, 
 			host->busnum);
 
+	if (host->ops && host->ops->phb_prepare) {
+		error = host->ops->phb_prepare(host);
+		if(error) {
+			kfree(host);
+			return NULL;
+		}
+	}
 	error = device_register(&host->dev);
 	if (error) {
 		put_device(&host->dev);
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 98a8d97..5f748ed 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1888,6 +1888,8 @@ static struct pci_bus *__pci_create_root_bus(
 
 	bridge->bus = b;
 	b->bridge = get_device(&bridge->dev);
+	if (bridge->ops && bridge->ops->phb_set_root_bus_speed)
+		bridge->ops->phb_set_root_bus_speed(bridge);
 	error = pcibios_root_bridge_prepare(bridge);
 	if (error)
 		goto err_out;
@@ -1953,7 +1955,7 @@ struct pci_bus *pci_create_root_bus(struct device *parent, u32 db,
 {
 	struct pci_host_bridge *host;
 
-	host = pci_create_host_bridge(parent, db, resources, sysdata);
+	host = pci_create_host_bridge(parent, db, resources, sysdata, NULL);
 	if (!host)
 		return NULL;
 	
@@ -2051,10 +2053,17 @@ static struct pci_bus *__pci_scan_root_bus(
 		pci_bus_insert_busn_res(b, host->busnum, 255);
 	}
 
-	max = pci_scan_child_bus(b);
+	if (host->ops && host->ops->phb_probe_mode)
+		host->ops->phb_probe_mode(host);
 
-	if (!found)
-		pci_bus_update_busn_res_end(b, max);
+	if (host->of_scan) {
+		if (host->ops &&host->ops->phb_of_scan_bus)
+			host->ops->phb_of_scan_bus(host);
+	} else {
+		max = pci_scan_child_bus(b);
+		if (!found)
+			pci_bus_update_busn_res_end(b, max);
+	}
 
 	return b;
 }
@@ -2064,7 +2073,7 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, u32 db,
 {
 	struct pci_host_bridge *host;
 
-	host = pci_create_host_bridge(parent, db, resources, sysdata);
+	host = pci_create_host_bridge(parent, db, resources, sysdata, NULL);
 	if (!host)
 		return NULL;
 
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 3ee8436..c06b95d 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -401,13 +401,25 @@ struct pci_host_bridge_window {
 	resource_size_t offset;		/* bus address + offset = CPU address */
 };
 
+struct pci_host_bridge;
+struct pci_host_bridge_ops {
+	void (*phb_set_root_bus_speed)(struct pci_host_bridge *host);
+	int (*phb_prepare)(struct pci_host_bridge *host);
+	/* Override domain number by host specific .phv_assign_domain_nr()  */
+	void (*phb_assign_domain_nr)(struct pci_host_bridge *);
+	void (*phb_probe_mode)(struct pci_host_bridge *);
+	void (*phb_of_scan_bus)(struct pci_host_bridge *);
+};
+
 struct pci_host_bridge {
 	u16	domain;
 	u16 busnum;
+	bool of_scan;
 	struct device dev;
 	struct pci_bus *bus;		/* root bus */
 	struct list_head list;
 	struct list_head windows;	/* pci_host_bridge_windows */
+	struct pci_host_bridge_ops *ops;
 	void (*release_fn)(struct pci_host_bridge *);
 	void *release_data;
 };
@@ -419,8 +431,8 @@ void pci_set_host_bridge_release(struct pci_host_bridge *bridge,
 
 int pcibios_root_bridge_prepare(struct pci_host_bridge *bridge);
 struct pci_host_bridge *pci_create_host_bridge(
-		struct device *parent, u32 dombus, 
-		struct list_head *resources, void *sysdata);
+		struct device *parent, u32 dombus, struct list_head *resources,
+		void *sysdata, struct pci_host_bridge_ops *ops);
 /*
  * The first PCI_BRIDGE_RESOURCE_NUM PCI bus resources (those that correspond
  * to P2P or CardBus bridge windows) go in a table.  Additional ones (for
-- 
1.7.1

