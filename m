From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 25 Apr 2014 09:18:29 +0000
Subject: [PATCH 07/13] sparc/PCI: Use new pci_is_bridge() to simplify code
Message-Id: <1398417515-8740-8-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1398417515-8740-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1398417515-8740-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Yijing Wang <wangyijing@huawei.com>

Now we can use new pci_is_bridge() helper function
to simplify code.

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


