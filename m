From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 21 Apr 2015 11:34:32 +0000
Subject: [PATCH v10 13/29] PCI: Move pcibios_root_bridge_prepare() to pci_create_host_bridge()
Message-Id: <1429616088-10249-14-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1429616088-10249-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1429616088-10249-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, dja@axtens.net, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Move pcibios_root_bridge_prepare() to pci_create_host_bridge().

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/host-bridge.c |   16 +++++++++++++---
 drivers/pci/probe.c       |    3 ---
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
index b1cc6ef..6309970 100644
--- a/drivers/pci/host-bridge.c
+++ b/drivers/pci/host-bridge.c
@@ -109,9 +109,7 @@ struct pci_host_bridge *pci_create_host_bridge(
 		if (tmp->domain = host->domain
 			  && pci_host_busn_res_check(host, tmp)) {
 			mutex_unlock(&pci_host_mutex);
-			pci_free_resource_list(&host->windows);
-			kfree(host);
-			return NULL;
+			goto free_res;
 		}
 	}
 	list_add_tail(&host->list, &pci_host_bridge_list);
@@ -122,6 +120,10 @@ struct pci_host_bridge *pci_create_host_bridge(
 	dev_set_name(&host->dev, "pci%04x:%02x",
 			host->domain, bus);
 
+	error = pcibios_root_bridge_prepare(host);
+	if (error)
+		goto list_del;
+
 	error = device_register(&host->dev);
 	if (error) {
 		put_device(&host->dev);
@@ -129,6 +131,14 @@ struct pci_host_bridge *pci_create_host_bridge(
 	}
 
 	return host;
+list_del:
+	mutex_lock(&pci_host_mutex);
+	list_del(&host->list);
+	mutex_unlock(&pci_host_mutex);
+free_res:
+	pci_free_resource_list(&host->windows);
+	kfree(host);
+	return NULL;
 }
 
 void pci_free_host_bridge(struct pci_host_bridge *host)
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 3c53fe7..e75b27c 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1902,9 +1902,6 @@ static struct pci_bus *__pci_create_root_bus(
 
 	bridge->bus = b;
 	b->bridge = get_device(&bridge->dev);
-	error = pcibios_root_bridge_prepare(bridge);
-	if (error)
-		goto put_bridge;
 
 	pcibios_set_root_bus_speed(bridge);
 	device_enable_async_suspend(b->bridge);
-- 
1.7.1

