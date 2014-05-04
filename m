From: Yijing Wang <wangyijing@huawei.com>
Date: Sun, 04 May 2014 04:23:46 +0000
Subject: [PATCH v2 11/13] PCI, acpiphp: Use new pci_is_bridge() to simplify code
Message-Id: <1399177428-3784-12-git-send-email-wangyijing@huawei.com>
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
 drivers/pci/hotplug/acpiphp_glue.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/pci/hotplug/acpiphp_glue.c b/drivers/pci/hotplug/acpiphp_glue.c
index bccc27e..f1f9bd1 100644
--- a/drivers/pci/hotplug/acpiphp_glue.c
+++ b/drivers/pci/hotplug/acpiphp_glue.c
@@ -516,8 +516,7 @@ static void __ref enable_slot(struct acpiphp_slot *slot)
 			if (PCI_SLOT(dev->devfn) != slot->device)
 				continue;
 
-			if (dev->hdr_type = PCI_HEADER_TYPE_BRIDGE ||
-			    dev->hdr_type = PCI_HEADER_TYPE_CARDBUS) {
+			if (pci_is_bridge(dev)) {
 				max = pci_scan_bridge(bus, dev, max, pass);
 				if (pass && dev->subordinate) {
 					check_hotplug_bridge(slot, dev);
-- 
1.7.1


