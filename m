From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 17 Nov 2014 09:45:19 +0000
Subject: [RFC PATCH 06/16] PCI: Use u32 type to combine PCI domain and bus number
Message-Id: <1416219710-26088-7-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416219710-26088-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1416219710-26088-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Thierry Reding <thierry.reding@gmail.com>, Liviu Dudau <liviu@dudau.co.uk>, Suravee.Suthikulpanit@amd.com, Yijing Wang <wangyijing@huawei.com>

Currently, we use int type for bus number in
pci_create_root_bus() and pci_scan_root_bus().
Because bus number is <= 255, so we could
change the bus number argument type to u32,
and combine PCI domain and bus number, we will
save the domain number in pci_host_bridge in
later patch, and eliminate the arch specific
pci_domain_nr().

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/probe.c      |   11 ++++++-----
 include/linux/pci.h      |    4 ++--
 include/uapi/linux/pci.h |    3 +++
 3 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 623bfff..adf4d09 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1895,7 +1895,7 @@ void __weak pcibios_remove_bus(struct pci_bus *bus)
 {
 }
 
-struct pci_bus *pci_create_root_bus(struct device *parent, int bus,
+struct pci_bus *pci_create_root_bus(struct device *parent, u32 db,
 		struct pci_ops *ops, void *sysdata, struct list_head *resources)
 {
 	int error;
@@ -1906,6 +1906,7 @@ struct pci_bus *pci_create_root_bus(struct device *parent, int bus,
 	resource_size_t offset;
 	char bus_addr[64];
 	char *fmt;
+	u8	bus = PCI_BUSNUM(db);
 
 	b = pci_alloc_bus(NULL);
 	if (!b)
@@ -2063,7 +2064,7 @@ void pci_bus_release_busn_res(struct pci_bus *b)
 			res, ret ? "can not be" : "is");
 }
 
-struct pci_bus *pci_scan_root_bus(struct device *parent, int bus,
+struct pci_bus *pci_scan_root_bus(struct device *parent, u32 db,
 		struct pci_ops *ops, void *sysdata, struct list_head *resources)
 {
 	struct pci_host_bridge_window *window;
@@ -2084,7 +2085,7 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, int bus,
 			}
 	}
 
-	b = pci_create_root_bus(parent, bus, ops, sysdata, 
+	b = pci_create_root_bus(parent, db, ops, sysdata, 
 			resources ? resources : &default_res);
 	if (!b)
 		return NULL;
@@ -2092,8 +2093,8 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, int bus,
 	if (!found) {
 		dev_info(&b->dev,
 		 "No busn resource found for root bus, will use [bus %02x-ff]\n",
-			bus);
-		pci_bus_insert_busn_res(b, bus, 255);
+			PCI_BUSNUM(db));
+		pci_bus_insert_busn_res(b, PCI_BUSNUM(db), 255);
 	}
 
 	max = pci_scan_child_bus(b);
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 4daef65..8b11b38 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -767,13 +767,13 @@ void pcibios_bus_to_resource(struct pci_bus *bus, struct resource *res,
 void pcibios_scan_specific_bus(int busn);
 struct pci_bus *pci_find_bus(int domain, int busnr);
 void pci_bus_add_devices(const struct pci_bus *bus);
-struct pci_bus *pci_create_root_bus(struct device *parent, int bus,
+struct pci_bus *pci_create_root_bus(struct device *parent, u32 bus,
 				    struct pci_ops *ops, void *sysdata,
 				    struct list_head *resources);
 int pci_bus_insert_busn_res(struct pci_bus *b, int bus, int busmax);
 int pci_bus_update_busn_res_end(struct pci_bus *b, int busmax);
 void pci_bus_release_busn_res(struct pci_bus *b);
-struct pci_bus *pci_scan_root_bus(struct device *parent, int bus,
+struct pci_bus *pci_scan_root_bus(struct device *parent, u32 bus,
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

