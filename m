From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 06 Mar 2015 09:33:44 +0000
Subject: [PATCH v5 27/29] PCI: Export find_pci_host_bridge() and rename to pci_find_host_bridge()
Message-Id: <1425634426-437-28-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425634426-437-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1425634426-437-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>, Bjorn Helgaas <bhelgaas@google.com>

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 drivers/pci/host-bridge.c |    6 +++---
 drivers/pci/pci.h         |    2 ++
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
index bc1de59..51f0a82 100644
--- a/drivers/pci/host-bridge.c
+++ b/drivers/pci/host-bridge.c
@@ -103,7 +103,7 @@ static struct pci_bus *find_pci_root_bus(struct pci_bus *bus)
 	return bus;
 }
 
-static struct pci_host_bridge *find_pci_host_bridge(struct pci_bus *bus)
+struct pci_host_bridge *pci_find_host_bridge(struct pci_bus *bus)
 {
 	struct pci_bus *root_bus = find_pci_root_bus(bus);
 
@@ -121,7 +121,7 @@ void pci_set_host_bridge_release(struct pci_host_bridge *bridge,
 void pcibios_resource_to_bus(struct pci_bus *bus, struct pci_bus_region *region,
 			     struct resource *res)
 {
-	struct pci_host_bridge *bridge = find_pci_host_bridge(bus);
+	struct pci_host_bridge *bridge = pci_find_host_bridge(bus);
 	struct resource_entry *window;
 	resource_size_t offset = 0;
 
@@ -146,7 +146,7 @@ static bool region_contains(struct pci_bus_region *region1,
 void pcibios_bus_to_resource(struct pci_bus *bus, struct resource *res,
 			     struct pci_bus_region *region)
 {
-	struct pci_host_bridge *bridge = find_pci_host_bridge(bus);
+	struct pci_host_bridge *bridge = pci_find_host_bridge(bus);
 	struct resource_entry *window;
 	resource_size_t offset = 0;
 
diff --git a/drivers/pci/pci.h b/drivers/pci/pci.h
index 8bf5be7..ca9fc51 100644
--- a/drivers/pci/pci.h
+++ b/drivers/pci/pci.h
@@ -326,4 +326,6 @@ struct pci_host_bridge *pci_create_host_bridge(
 		void *sysdata, struct pci_host_bridge_ops *ops);
 
 void pci_free_host_bridge(struct pci_host_bridge *host);
+struct pci_host_bridge *pci_find_host_bridge(struct pci_bus *bus);
+
 #endif /* DRIVERS_PCI_H */
-- 
1.7.1

