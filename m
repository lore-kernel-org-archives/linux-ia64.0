From: Yijing Wang <wangyijing@huawei.com>
Date: Sun, 04 May 2014 04:23:48 +0000
Subject: [PATCH v2 13/13] PCI, pciehp: Use new pci_is_bridge() to simplify code
Message-Id: <1399177428-3784-14-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1399177428-3784-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1399177428-3784-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-pci@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Yijing Wang <wangyijing@huawei.com>

Now we can use new pci_is_bridge() helper function
to simplify code.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/hotplug/pciehp_pci.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/pci/hotplug/pciehp_pci.c b/drivers/pci/hotplug/pciehp_pci.c
index 1b53306..b6cb1df 100644
--- a/drivers/pci/hotplug/pciehp_pci.c
+++ b/drivers/pci/hotplug/pciehp_pci.c
@@ -62,8 +62,7 @@ int pciehp_configure_device(struct slot *p_slot)
 	}
 
 	list_for_each_entry(dev, &parent->devices, bus_list)
-		if ((dev->hdr_type = PCI_HEADER_TYPE_BRIDGE) ||
-				(dev->hdr_type = PCI_HEADER_TYPE_CARDBUS))
+		if (pci_is_bridge(dev))
 			pci_hp_add_bridge(dev);
 
 	pci_assign_unassigned_bridge_resources(bridge);
-- 
1.7.1


