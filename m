From: Yijing Wang <wangyijing@huawei.com>
Date: Sun, 04 May 2014 04:23:39 +0000
Subject: [PATCH v2 04/13] x86/PCI: Use new pci_is_bridge() to simplify code
Message-Id: <1399177428-3784-5-git-send-email-wangyijing@huawei.com>
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
 arch/x86/pci/fixup.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/arch/x86/pci/fixup.c b/arch/x86/pci/fixup.c
index 94ae9ae..e5f000c 100644
--- a/arch/x86/pci/fixup.c
+++ b/arch/x86/pci/fixup.c
@@ -337,9 +337,7 @@ static void pci_fixup_video(struct pci_dev *pdev)
 		 * type BRIDGE, or CARDBUS. Host to PCI controllers use
 		 * PCI header type NORMAL.
 		 */
-		if (bridge
-		    && ((bridge->hdr_type = PCI_HEADER_TYPE_BRIDGE)
-		       || (bridge->hdr_type = PCI_HEADER_TYPE_CARDBUS))) {
+		if (bridge && (pci_is_bridge(bridge))) {
 			pci_read_config_word(bridge, PCI_BRIDGE_CONTROL,
 						&config);
 			if (!(config & PCI_BRIDGE_CTL_VGA))
-- 
1.7.1


