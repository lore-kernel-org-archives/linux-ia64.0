From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 26 Feb 2015 01:29:45 +0000
Subject: [PATCH v3 28/30] PCI: Export find_pci_host_bridge()
Message-Id: <1424914187-21027-29-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424914187-21027-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1424914187-21027-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Export find_pci_host_bridge().

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/host-bridge.c |    2 +-
 include/linux/pci.h       |    1 +
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
index 4a2baa2..51e24f8 100644
--- a/drivers/pci/host-bridge.c
+++ b/drivers/pci/host-bridge.c
@@ -104,7 +104,7 @@ static struct pci_bus *find_pci_root_bus(struct pci_bus *bus)
 	return bus;
 }
 
-static struct pci_host_bridge *find_pci_host_bridge(struct pci_bus *bus)
+struct pci_host_bridge *find_pci_host_bridge(struct pci_bus *bus)
 {
 	struct pci_bus *root_bus = find_pci_root_bus(bus);
 
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 2f29e95..6ac7926 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -426,6 +426,7 @@ void pci_set_host_bridge_release(struct pci_host_bridge *bridge,
 struct pci_host_bridge *pci_create_host_bridge(
 		struct device *parent, u32 dombus, struct list_head *resources, 
 		void *sysdata, struct pci_host_bridge_ops *ops);
+struct pci_host_bridge *find_pci_host_bridge(struct pci_bus* bus);
 /*
  * The first PCI_BRIDGE_RESOURCE_NUM PCI bus resources (those that correspond
  * to P2P or CardBus bridge windows) go in a table.  Additional ones (for
-- 
1.7.1

