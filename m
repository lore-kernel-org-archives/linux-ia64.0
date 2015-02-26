From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 26 Feb 2015 01:29:23 +0000
Subject: [PATCH v3 06/30] PCI: Combine PCI domain and bus number in u32 arg
Message-Id: <1424914187-21027-7-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424914187-21027-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1424914187-21027-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Currently, we use int type for bus number in
pci_create_root_bus(), pci_scan_root_bus() and
pci_scan_bus_legacy. Because PCI bus number
always <= 255, so we could change the bus number
argument type to u32, and combine PCI domain and
bus number in one. Also add a domain member in
pci_host_bridge to save domain number. Finally,
we could eliminate lots of the platform specific
pci_domain_nr() in the last of the series.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/probe.c      |   16 +++++++++-------
 include/linux/pci.h      |    7 ++++---
 include/uapi/linux/pci.h |    3 +++
 3 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index ccab9b1..ef57da1 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1889,7 +1889,7 @@ void __weak pcibios_remove_bus(struct pci_bus *bus)
 {
 }
 
-struct pci_bus *pci_create_root_bus(struct device *parent, int bus,
+struct pci_bus *pci_create_root_bus(struct device *parent, u32 db,
 		struct pci_ops *ops, void *sysdata, struct list_head *resources)
 {
 	int error;
@@ -1900,6 +1900,7 @@ struct pci_bus *pci_create_root_bus(struct device *parent, int bus,
 	resource_size_t offset;
 	char bus_addr[64];
 	char *fmt;
+	u8	bus = PCI_BUSNUM(db);
 
 	b = pci_alloc_bus(NULL);
 	if (!b)
@@ -1920,6 +1921,7 @@ struct pci_bus *pci_create_root_bus(struct device *parent, int bus,
 	if (!bridge)
 		goto err_out;
 
+	bridge->domain = PCI_DOMAIN(db);
 	bridge->dev.parent = parent;
 	bridge->dev.release = pci_release_host_bridge_dev;
 	dev_set_name(&bridge->dev, "pci%04x:%02x", pci_domain_nr(b), bus);
@@ -2057,7 +2059,7 @@ void pci_bus_release_busn_res(struct pci_bus *b)
 			res, ret ? "can not be" : "is");
 }
 
-struct pci_bus *pci_scan_root_bus(struct device *parent, int bus,
+struct pci_bus *pci_scan_root_bus(struct device *parent, u32 db,
 		struct pci_ops *ops, void *sysdata, struct list_head *resources)
 {
 	struct resource_entry *window;
@@ -2071,15 +2073,15 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, int bus,
 			break;
 		}
 
-	b = pci_create_root_bus(parent, bus, ops, sysdata, resources);
+	b = pci_create_root_bus(parent, db, ops, sysdata, resources);
 	if (!b)
 		return NULL;
 
 	if (!found) {
 		dev_info(&b->dev,
 		 "No busn resource found for root bus, will use [bus %02x-ff]\n",
-			bus);
-		pci_bus_insert_busn_res(b, bus, 255);
+			PCI_BUSNUM(db));
+		pci_bus_insert_busn_res(b, PCI_BUSNUM(db), 255);
 	}
 
 	max = pci_scan_child_bus(b);
@@ -2091,7 +2093,7 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, int bus,
 }
 EXPORT_SYMBOL(pci_scan_root_bus);
 
-struct pci_bus *pci_scan_bus_legacy(int bus, struct pci_ops *ops,
+struct pci_bus *pci_scan_bus_legacy(u32 db, struct pci_ops *ops,
 					void *sysdata)
 {
 	LIST_HEAD(resources);
@@ -2100,7 +2102,7 @@ struct pci_bus *pci_scan_bus_legacy(int bus, struct pci_ops *ops,
 	pci_add_resource(&resources, &ioport_resource);
 	pci_add_resource(&resources, &iomem_resource);
 	pci_add_resource(&resources, &busn_resource);
-	b = pci_create_root_bus(NULL, bus, ops, sysdata, &resources);
+	b = pci_create_root_bus(NULL, db, ops, sysdata, &resources);
 	if (b) {
 		pci_scan_child_bus(b);
 	} else {
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 6dffc57..a11fb55 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -401,6 +401,7 @@ static inline int pci_channel_offline(struct pci_dev *pdev)
 }
 
 struct pci_host_bridge {
+	u16	domain;
 	struct device dev;
 	struct pci_bus *bus;		/* root bus */
 	struct list_head windows;	/* resource_entry */
@@ -769,14 +770,14 @@ void pcibios_bus_to_resource(struct pci_bus *bus, struct resource *res,
 void pcibios_scan_specific_bus(int busn);
 struct pci_bus *pci_find_bus(int domain, int busnr);
 void pci_bus_add_devices(const struct pci_bus *bus);
-struct pci_bus *pci_scan_bus_legacy(int bus, struct pci_ops *ops, void *sysdata);
-struct pci_bus *pci_create_root_bus(struct device *parent, int bus,
+struct pci_bus *pci_scan_bus_legacy(u32 dombus, struct pci_ops *ops, void *sysdata);
+struct pci_bus *pci_create_root_bus(struct device *parent, u32 dombus,
 				    struct pci_ops *ops, void *sysdata,
 				    struct list_head *resources);
 int pci_bus_insert_busn_res(struct pci_bus *b, int bus, int busmax);
 int pci_bus_update_busn_res_end(struct pci_bus *b, int busmax);
 void pci_bus_release_busn_res(struct pci_bus *b);
-struct pci_bus *pci_scan_root_bus(struct device *parent, int bus,
+struct pci_bus *pci_scan_root_bus(struct device *parent, u32 dombus,
 					     struct pci_ops *ops, void *sysdata,
 					     struct list_head *resources);
 struct pci_bus *pci_add_new_bus(struct pci_bus *parent, struct pci_dev *dev,
diff --git a/include/uapi/linux/pci.h b/include/uapi/linux/pci.h
index 3c292bc..89c6f15 100644
--- a/include/uapi/linux/pci.h
+++ b/include/uapi/linux/pci.h
@@ -30,6 +30,9 @@
 #define PCI_DEVFN(slot, func)	((((slot) & 0x1f) << 3) | ((func) & 0x07))
 #define PCI_SLOT(devfn)		(((devfn) >> 3) & 0x1f)
 #define PCI_FUNC(devfn)		((devfn) & 0x07)
+#define PCI_DOMAIN(db)		((db) >> 16)
+#define PCI_BUSNUM(db)		((db) & 0xffff)
+#define PCI_DOMBUS(domain, bus)		(((domain) << 16) | (bus))
 
 /* Ioctls for /proc/bus/pci/X/Y nodes. */
 #define PCIIOC_BASE		('P' << 24 | 'C' << 16 | 'I' << 8)
-- 
1.7.1

