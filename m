From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 06 Mar 2015 09:33:29 +0000
Subject: [PATCH v5 12/29] PCI: Introduce new scan function pci_scan_host_bridge()
Message-Id: <1425634426-437-13-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425634426-437-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1425634426-437-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>, Bjorn Helgaas <bhelgaas@google.com>

Introduce new scan function pci_scan_host_bridge() to
support host bridge drivers that need to provide platform
own pci_host_bridge_ops.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 drivers/pci/probe.c |   22 ++++++++++++++++++++++
 include/linux/pci.h |    4 ++++
 2 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index b76fca6..54557a1 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -2063,6 +2063,28 @@ static struct pci_bus *__pci_scan_root_bus(
 	return b;
 }
 
+struct pci_host_bridge *pci_scan_host_bridge(struct device *parent,
+		u32 db, struct pci_ops *ops, void *sysdata,
+		struct list_head *resources,
+		struct pci_host_bridge_ops *phb_ops)
+{
+	struct pci_host_bridge *host;
+	struct pci_bus *bus;
+
+	host = pci_create_host_bridge(parent, db, resources,
+			sysdata, phb_ops);
+	if (!host)
+		return NULL;
+
+	bus = __pci_scan_root_bus(host, ops);
+	if (!bus)
+		pci_free_host_bridge(host);
+
+	return host;
+}
+EXPORT_SYMBOL(pci_scan_host_bridge);
+
+
 struct pci_bus *pci_scan_root_bus(struct device *parent, u32 db,
 		struct pci_ops *ops, void *sysdata, struct list_head *resources)
 {
diff --git a/include/linux/pci.h b/include/linux/pci.h
index e9922b1..28eafb5 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -790,6 +790,10 @@ void pci_bus_release_busn_res(struct pci_bus *b);
 struct pci_bus *pci_scan_root_bus(struct device *parent, u32 dombus,
 					     struct pci_ops *ops, void *sysdata,
 					     struct list_head *resources);
+struct pci_host_bridge *pci_scan_host_bridge(struct device *parent,
+		u32 dombus, struct pci_ops *ops, void *sysdata,
+		struct list_head *resources,
+		struct pci_host_bridge_ops *phb_ops);
 struct pci_bus *pci_add_new_bus(struct pci_bus *parent, struct pci_dev *dev,
 				int busnr);
 void pcie_update_link_speed(struct pci_bus *bus, u16 link_status);
-- 
1.7.1

