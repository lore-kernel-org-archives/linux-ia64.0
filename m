From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 09 Mar 2015 02:34:07 +0000
Subject: [PATCH v6 10/30] PCI: Introduce pci_host_bridge_list to manage host bridges
Message-Id: <1425868467-9667-11-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425868467-9667-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1425868467-9667-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>, Bjorn Helgaas <bhelgaas@google.com>

Introduce pci_host_bridge_list to manage pci host
bridges in system, so we could detect whether
the host in domain:bus is alreay registered.
Then we could remove bus alreay exist test in
__pci_create_root_bus().

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 drivers/pci/host-bridge.c |   24 +++++++++++++++++++++++-
 drivers/pci/probe.c       |    8 +-------
 include/linux/pci.h       |    1 +
 3 files changed, 25 insertions(+), 8 deletions(-)

diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
index 3bd45e7..0bb08ef 100644
--- a/drivers/pci/host-bridge.c
+++ b/drivers/pci/host-bridge.c
@@ -8,6 +8,9 @@
 
 #include "pci.h"
 
+static LIST_HEAD(pci_host_bridge_list);
+static DEFINE_MUTEX(phb_mutex);
+
 static void pci_release_host_bridge_dev(struct device *dev)
 {
 	struct pci_host_bridge *bridge = to_pci_host_bridge(dev);
@@ -25,7 +28,7 @@ struct pci_host_bridge *pci_create_host_bridge(
 	int error;
 	int bus = PCI_BUSNUM(db);
 	int domain = PCI_DOMAIN(db);
-	struct pci_host_bridge *host;
+	struct pci_host_bridge *host, *temp;
 	struct resource_entry *window, *n;
 
 	host = kzalloc(sizeof(*host), GFP_KERNEL);
@@ -40,6 +43,18 @@ struct pci_host_bridge *pci_create_host_bridge(
 	 */
 	pci_host_assign_domain_nr(host);
 
+	mutex_lock(&phb_mutex);
+	list_for_each_entry(temp, &pci_host_bridge_list, list)
+		if (temp->domain = host->domain
+				&& temp->busnum = host->busnum) {
+			dev_dbg(&host->dev, "pci host bridge pci%04x:%02x exist\n",
+					host->domain, host->busnum);
+			mutex_unlock(&phb_mutex);
+			kfree(host);
+			return NULL;
+		}
+	mutex_unlock(&phb_mutex);
+
 	host->dev.parent = parent;
 	INIT_LIST_HEAD(&host->windows);
 	host->dev.release = pci_release_host_bridge_dev;
@@ -55,11 +70,18 @@ struct pci_host_bridge *pci_create_host_bridge(
 	resource_list_for_each_entry_safe(window, n, resources)
 		list_move_tail(&window->node, &host->windows);
 
+	mutex_lock(&phb_mutex);
+	list_add_tail(&host->list, &pci_host_bridge_list);
+	mutex_unlock(&phb_mutex);
 	return host;
 }
 
 void pci_free_host_bridge(struct pci_host_bridge *host)
 {
+	mutex_lock(&phb_mutex);
+	list_del(&host->list);
+	mutex_unlock(&phb_mutex);
+
 	device_unregister(&host->dev);
 }
 
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 27ec612..7238fa3 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1870,7 +1870,7 @@ static struct pci_bus *__pci_create_root_bus(
 		void *sysdata)
 {
 	int error;
-	struct pci_bus *b, *b2;
+	struct pci_bus *b;
 	struct resource_entry *window;
 	struct device *parent;
 	struct resource *res;
@@ -1887,12 +1887,6 @@ static struct pci_bus *__pci_create_root_bus(
 	b->ops = ops;
 	b->number = b->busn_res.start = bridge->busnum;
 	pci_bus_assign_domain_nr(b, parent);
-	b2 = pci_find_bus(pci_domain_nr(b), b->number);
-	if (b2) {
-		/* If we already got to this bus through a different bridge, ignore it */
-		dev_dbg(&b2->dev, "bus already known\n");
-		goto err_out;
-	}
 
 	bridge->bus = b;
 	b->bridge = get_device(&bridge->dev);
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 463eaa3..b621f5b 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -406,6 +406,7 @@ struct pci_host_bridge {
 	struct device dev;
 	struct pci_bus *bus;		/* root bus */
 	struct list_head windows;	/* resource_entry */
+	struct list_head list;
 	void (*release_fn)(struct pci_host_bridge *);
 	void *release_data;
 };
-- 
1.7.1

