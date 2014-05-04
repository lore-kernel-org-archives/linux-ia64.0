From: Yijing Wang <wangyijing@huawei.com>
Date: Sun, 04 May 2014 04:23:45 +0000
Subject: [PATCH v2 10/13] PCI, cpcihp: Use new pci_is_bridge() to simplify code
Message-Id: <1399177428-3784-11-git-send-email-wangyijing@huawei.com>
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
 drivers/pci/hotplug/cpci_hotplug_pci.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/pci/hotplug/cpci_hotplug_pci.c b/drivers/pci/hotplug/cpci_hotplug_pci.c
index 8c14648..9843371 100644
--- a/drivers/pci/hotplug/cpci_hotplug_pci.c
+++ b/drivers/pci/hotplug/cpci_hotplug_pci.c
@@ -289,8 +289,7 @@ int __ref cpci_configure_slot(struct slot *slot)
 	list_for_each_entry(dev, &parent->devices, bus_list)
 		if (PCI_SLOT(dev->devfn) != PCI_SLOT(slot->devfn))
 			continue;
-		if ((dev->hdr_type = PCI_HEADER_TYPE_BRIDGE) ||
-		    (dev->hdr_type = PCI_HEADER_TYPE_CARDBUS))
+		if (pci_is_bridge(dev))
 			pci_hp_add_bridge(dev);
 
 
-- 
1.7.1


