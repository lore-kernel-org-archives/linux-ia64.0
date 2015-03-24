From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 24 Mar 2015 03:34:09 +0000
Subject: [PATCH v8 15/30] PCI: Introduce new scan function pci_scan_host_bridge()
Message-Id: <1427168064-8657-16-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1427168064-8657-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1427168064-8657-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Introduce new scan function pci_scan_host_bridge() to
support host bridge drivers that need to provide platform
own pci_host_bridge_ops.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/probe.c |   22 ++++++++++++++++++++++
 include/linux/pci.h |    3 +++
 2 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 36dfee0..b3d9b1b 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -2064,6 +2064,28 @@ static struct pci_bus *__pci_scan_root_bus(
 	return b;
 }
 
+struct pci_host_bridge *pci_scan_host_bridge(
+		struct device *parent, int domain, int bus,
+		void *sysdata, struct list_head *resources,
+		struct pci_host_bridge_ops *ops)
+{
+	struct pci_host_bridge *host;
+
+	host = pci_create_host_bridge(parent, domain, bus, sysdata,
+			resources, ops);
+	if (!host)
+		return NULL;
+
+	host->bus = __pci_scan_root_bus(host, ops->pci_ops);
+	if (!host->bus) {
+		pci_free_host_bridge(host);
+		return NULL;
+	}
+
+	return host;
+}
+EXPORT_SYMBOL(pci_scan_host_bridge);
+
 struct pci_bus *pci_scan_root_bus(struct device *parent, int domain,
 		int bus, struct pci_ops *ops, void *sysdata,
 		struct list_head *resources)
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 2702a51..7f4f182 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -793,6 +793,9 @@ void pci_bus_release_busn_res(struct pci_bus *b);
 struct pci_bus *pci_scan_root_bus(struct device *parent, int domain, int bus,
 					     struct pci_ops *ops, void *sysdata,
 					     struct list_head *resources);
+struct pci_host_bridge *pci_scan_host_bridge(struct device *parent, int domain,
+		int bus, void *sysdata, struct list_head *resources,
+		struct pci_host_bridge_ops *ops);
 struct pci_bus *pci_add_new_bus(struct pci_bus *parent, struct pci_dev *dev,
 				int busnr);
 void pcie_update_link_speed(struct pci_bus *bus, u16 link_status);
-- 
1.7.1

