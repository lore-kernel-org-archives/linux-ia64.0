From: Yijing Wang <wangyijing@huawei.com>
Date: Sun, 04 May 2014 04:23:43 +0000
Subject: [PATCH v2 08/13] PCI, rpaphp: Use new pci_is_bridge() to simplify code
Message-Id: <1399177428-3784-9-git-send-email-wangyijing@huawei.com>
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

Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/hotplug/rpadlpar_core.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/pci/hotplug/rpadlpar_core.c b/drivers/pci/hotplug/rpadlpar_core.c
index 4fcdeed..7660232 100644
--- a/drivers/pci/hotplug/rpadlpar_core.c
+++ b/drivers/pci/hotplug/rpadlpar_core.c
@@ -157,8 +157,7 @@ static void dlpar_pci_add_bus(struct device_node *dn)
 	}
 
 	/* Scan below the new bridge */
-	if (dev->hdr_type = PCI_HEADER_TYPE_BRIDGE ||
-	    dev->hdr_type = PCI_HEADER_TYPE_CARDBUS)
+	if (pci_is_bridge(dev))
 		of_scan_pci_bridge(dev);
 
 	/* Map IO space for child bus, which may or may not succeed */
-- 
1.7.1


