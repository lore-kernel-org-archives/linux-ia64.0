From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 21 Apr 2015 11:34:29 +0000
Subject: [PATCH v10 10/29] PCI: Introduce pci_host_bridge_list to manage host bridges
Message-Id: <1429616088-10249-11-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1429616088-10249-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1429616088-10249-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, dja@axtens.net, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Introduce pci_host_bridge_list to manage pci host
bridges in system, this make us have the ability
to check whether the new host would conflict with
existing one. Then we could remove bus alreay exist
check in __pci_create_root_bus().

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/host-bridge.c |   75 ++++++++++++++++++++++++++++++++++++++++++++-
 drivers/pci/probe.c       |    9 +-----
 include/linux/pci.h       |    1 +
 3 files changed, 76 insertions(+), 9 deletions(-)

diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
index 78a30c2..e05d8fc 100644
--- a/drivers/pci/host-bridge.c
+++ b/drivers/pci/host-bridge.c
@@ -8,6 +8,9 @@
 
 #include "pci.h"
 
+static LIST_HEAD(pci_host_bridge_list);
+static DEFINE_MUTEX(pci_host_mutex);
+
 static void pci_release_host_bridge_dev(struct device *dev)
 {
 	struct resource_entry *entry;
@@ -25,12 +28,64 @@ static void pci_release_host_bridge_dev(struct device *dev)
 	kfree(bridge);
 }
 
+static int pci_host_busn_res_check(
+		struct pci_host_bridge *new, struct pci_host_bridge *old)
+{
+	int i;
+	bool conflict;
+	struct resource_entry *entry;
+	struct resource *res_new = NULL, *res_old = NULL;
+
+	entry = pci_busn_resource(&old->windows);
+	res_old = entry->res;
+	entry = pci_busn_resource(&new->windows);
+	res_new = entry->res;
+
+	conflict = resource_overlaps(res_new, res_old);
+	if (conflict) {
+		/*
+		 * We hope every host bridge has its own exclusive
+		 * busn resource, then if new host bridge's busn
+		 * resource conflicts with existing host bridge,
+		 * we could fail it. But in reality, firmware may
+		 * doesn't supply busn resource to every host bridge.
+		 * Or worse, supply the wrong busn resource to
+		 * host bridge. In order to avoid the introduction of
+		 * regression, we try to adjust busn resource for
+		 * both new and existing host bridges. But if root
+		 * bus number conflicts, must fail it.
+		 */
+		pr_warn("pci%04x:%02x %pR conflicts with pci%04x:%02x %pR\n",
+				new->domain, (int)res_new->start, res_new,
+				old->domain, (int)res_old->start, res_old);
+		if (res_new->start = res_old->start)
+			return -ENOSPC;
+
+		if (res_new->start < res_old->start) {
+			res_new->end = res_old->start - 1;
+			pr_warn("pci%04x:%02x busn resource update to %pR\n",
+					new->domain, (int)res_new->start, res_new);
+		} else {
+			for (i = res_new->start;
+					i < (res_old->end - res_new->start + 1); i++) {
+				if (pci_find_bus(new->domain, i))
+					return -ENOSPC;
+			}
+			res_old->end = res_new->start - 1;
+			pr_warn("pci%04x:%02x busn resource update to %pR\n",
+					old->domain, (int)res_old->start, res_old);
+		}
+	}
+
+	return 0;
+}
+
 struct pci_host_bridge *pci_create_host_bridge(
 		struct device *parent, int domain,
 		struct list_head *resources)
 {
 	int error, bus;
-	struct pci_host_bridge *host;
+	struct pci_host_bridge *host, *tmp;
 	struct resource_entry *window, *n, *busn_res;
 
 	busn_res = pci_busn_resource(resources);
@@ -48,6 +103,20 @@ struct pci_host_bridge *pci_create_host_bridge(
 
 	host->dev.parent = parent;
 	pci_host_assign_domain_nr(host, domain);
+
+	mutex_lock(&pci_host_mutex);
+	list_for_each_entry(tmp, &pci_host_bridge_list, list) {
+		if (tmp->domain = host->domain
+			  && pci_host_busn_res_check(host, tmp)) {
+			mutex_unlock(&pci_host_mutex);
+			pci_free_resource_list(&host->windows);
+			kfree(host);
+			return NULL;
+		}
+	}
+	list_add_tail(&host->list, &pci_host_bridge_list);
+	mutex_unlock(&pci_host_mutex);
+
 	host->dev.release = pci_release_host_bridge_dev;
 	dev_set_name(&host->dev, "pci%04x:%02x",
 			host->domain, bus);
@@ -63,6 +132,10 @@ struct pci_host_bridge *pci_create_host_bridge(
 
 void pci_free_host_bridge(struct pci_host_bridge *host)
 {
+	mutex_lock(&pci_host_mutex);
+	list_del(&host->list);
+	mutex_unlock(&pci_host_mutex);
+
 	device_unregister(&host->dev);
 }
 
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 0b80ecb..d8c4da8 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1875,7 +1875,7 @@ static struct pci_bus *__pci_create_root_bus(
 		void *sysdata)
 {
 	int error, bus;
-	struct pci_bus *b, *b2;
+	struct pci_bus *b;
 	struct resource_entry *window, *busn_res;
 	struct device *parent;
 	struct resource *res;
@@ -1896,12 +1896,6 @@ static struct pci_bus *__pci_create_root_bus(
 	b->ops = ops;
 	b->number = b->busn_res.start = bus;
 	pci_bus_assign_domain_nr(b, parent);
-	b2 = pci_find_bus(pci_domain_nr(b), bus);
-	if (b2) {
-		/* If we already got to this bus through a different bridge, ignore it */
-		dev_dbg(&b2->dev, "bus already known\n");
-		goto err_out;
-	}
 
 	bridge->bus = b;
 	b->bridge = get_device(&bridge->dev);
@@ -1961,7 +1955,6 @@ static struct pci_bus *__pci_create_root_bus(
 
 put_bridge:
 	put_device(&bridge->dev);
-err_out:
 	kfree(b);
 	return NULL;
 }
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 0716158..9a8a223 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -406,6 +406,7 @@ struct pci_host_bridge {
 	struct device dev;
 	struct pci_bus *bus;		/* root bus */
 	struct list_head windows;	/* resource_entry */
+	struct list_head list;
 	void (*release_fn)(struct pci_host_bridge *);
 	void *release_data;
 	unsigned int ignore_reset_delay:1;	/* for entire hierarchy */
-- 
1.7.1

