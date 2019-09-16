From: Denis Efremov <efremov@linux.com>
Date: Mon, 16 Sep 2019 20:41:41 +0000
Subject: [PATCH v3 09/26] ia64: Use PCI_STD_NUM_BARS
Message-Id: <20190916204158.6889-10-efremov@linux.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190916204158.6889-1-efremov@linux.com>
In-Reply-To: <20190916204158.6889-1-efremov@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Denis Efremov <efremov@linux.com>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, Andrew Murray <andrew.murray@arm.com>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

Use define PCI_STD_NUM_BARS instead of PCI_ROM_RESOURCE for the number of
PCI BARs.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Signed-off-by: Denis Efremov <efremov@linux.com>
---
 arch/ia64/sn/pci/pcibr/pcibr_dma.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/sn/pci/pcibr/pcibr_dma.c b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
index 1e863b277ac9..ff981e415a28 100644
--- a/arch/ia64/sn/pci/pcibr/pcibr_dma.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
@@ -295,14 +295,14 @@ void sn_dma_flush(u64 addr)
 	/* find a matching BAR */
 	for (i = 0; i < DEV_PER_WIDGET; i++,p++) {
 		common = p->common;
-		for (j = 0; j < PCI_ROM_RESOURCE; j++) {
+		for (j = 0; j < PCI_STD_NUM_BARS; j++) {
 			if (common->sfdl_bar_list[j].start = 0)
 				break;
 			if (addr >= common->sfdl_bar_list[j].start
 			    && addr <= common->sfdl_bar_list[j].end)
 				break;
 		}
-		if (j < PCI_ROM_RESOURCE && common->sfdl_bar_list[j].start != 0)
+		if (j < PCI_STD_NUM_BARS && common->sfdl_bar_list[j].start != 0)
 			break;
 	}
 
-- 
2.21.0
