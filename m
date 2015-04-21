From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 21 Apr 2015 11:34:39 +0000
Subject: [PATCH v10 20/29] PCI: Remove pcibios_root_bridge_prepare() and pcibos_set_root_bus_speed()
Message-Id: <1429616088-10249-21-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1429616088-10249-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1429616088-10249-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, dja@axtens.net, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Now no one use weak pcibios_root_bridge_prepare() and
pcibios_set_root_bus_speed, we could clean up them.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/host-bridge.c |    4 ----
 drivers/pci/probe.c       |   18 +-----------------
 include/linux/pci.h       |    2 --
 3 files changed, 1 insertions(+), 23 deletions(-)

diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
index 7e25f53..af539c4 100644
--- a/drivers/pci/host-bridge.c
+++ b/drivers/pci/host-bridge.c
@@ -127,10 +127,6 @@ struct pci_host_bridge *pci_create_host_bridge(
 			goto list_del;
 	}
 
-	error = pcibios_root_bridge_prepare(host);
-	if (error)
-		goto list_del;
-
 	error = device_register(&host->dev);
 	if (error) {
 		put_device(&host->dev);
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 708bcf1..2ba6754 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1850,22 +1850,6 @@ unsigned int pci_scan_child_bus(struct pci_bus *bus)
 }
 EXPORT_SYMBOL_GPL(pci_scan_child_bus);
 
-/**
- * pcibios_root_bridge_prepare - Platform-specific host bridge setup.
- * @bridge: Host bridge to set up.
- *
- * Default empty implementation.  Replace with an architecture-specific setup
- * routine, if necessary.
- */
-int __weak pcibios_root_bridge_prepare(struct pci_host_bridge *bridge)
-{
-	return 0;
-}
-
-void __weak pcibios_set_root_bus_speed(struct pci_host_bridge *bridge)
-{
-}
-
 void __weak pcibios_add_bus(struct pci_bus *bus)
 {
 }
@@ -1905,7 +1889,7 @@ static struct pci_bus *__pci_create_root_bus(
 
 	if (bridge->ops && bridge->ops->set_root_bus_speed)
 		bridge->ops->set_root_bus_speed(bridge);
-	pcibios_set_root_bus_speed(bridge);
+
 	device_enable_async_suspend(b->bridge);
 	pci_set_bus_of_node(b);
 
diff --git a/include/linux/pci.h b/include/linux/pci.h
index a82595a..41eb672 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -426,8 +426,6 @@ void pci_set_host_bridge_release(struct pci_host_bridge *bridge,
 		     void (*release_fn)(struct pci_host_bridge *),
 		     void *release_data);
 
-int pcibios_root_bridge_prepare(struct pci_host_bridge *bridge);
-
 /*
  * The first PCI_BRIDGE_RESOURCE_NUM PCI bus resources (those that correspond
  * to P2P or CardBus bridge windows) go in a table.  Additional ones (for
-- 
1.7.1

