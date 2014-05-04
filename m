From: Yijing Wang <wangyijing@huawei.com>
Date: Sun, 04 May 2014 04:23:42 +0000
Subject: [PATCH v2 07/13] sparc/PCI: Use new pci_is_bridge() to simplify code
Message-Id: <1399177428-3784-8-git-send-email-wangyijing@huawei.com>
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

Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/sparc/kernel/pci.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/arch/sparc/kernel/pci.c b/arch/sparc/kernel/pci.c
index 1555bbc..857ad77 100644
--- a/arch/sparc/kernel/pci.c
+++ b/arch/sparc/kernel/pci.c
@@ -543,8 +543,7 @@ static void pci_of_scan_bus(struct pci_pbm_info *pbm,
 			printk("PCI: dev header type: %x\n",
 			       dev->hdr_type);
 
-		if (dev->hdr_type = PCI_HEADER_TYPE_BRIDGE ||
-		    dev->hdr_type = PCI_HEADER_TYPE_CARDBUS)
+		if (pci_is_bridge(dev))
 			of_scan_pci_bridge(pbm, child, dev);
 	}
 }
-- 
1.7.1


