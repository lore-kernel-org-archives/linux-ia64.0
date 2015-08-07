From: Andrzej Hajda <a.hajda@samsung.com>
Date: Fri, 07 Aug 2015 07:59:08 +0000
Subject: [PATCH 02/31] arch/ia64/tioce: use kmemdup rather than duplicating its implementation
Message-Id: <1438934377-4922-3-git-send-email-a.hajda@samsung.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1438934377-4922-1-git-send-email-a.hajda@samsung.com>
In-Reply-To: <1438934377-4922-1-git-send-email-a.hajda@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Andrzej Hajda <a.hajda@samsung.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

The patch was generated using fixed coccinelle semantic patch
scripts/coccinelle/api/memdup.cocci [1].

[1]: http://permalink.gmane.org/gmane.linux.kernel/2014320

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
 arch/ia64/sn/pci/tioce_provider.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/sn/pci/tioce_provider.c b/arch/ia64/sn/pci/tioce_provider.c
index 46d3df4..2f13276 100644
--- a/arch/ia64/sn/pci/tioce_provider.c
+++ b/arch/ia64/sn/pci/tioce_provider.c
@@ -1000,11 +1000,11 @@ tioce_bus_fixup(struct pcibus_bussoft *prom_bussoft, struct pci_controller *cont
 	 * Allocate kernel bus soft and copy from prom.
 	 */
 
-	tioce_common = kzalloc(sizeof(struct tioce_common), GFP_KERNEL);
+	tioce_common = kmemdup(prom_bussoft, sizeof(struct tioce_common),
+			       GFP_KERNEL);
 	if (!tioce_common)
 		return NULL;
 
-	memcpy(tioce_common, prom_bussoft, sizeof(struct tioce_common));
 	tioce_common->ce_pcibus.bs_base = (unsigned long)
 		ioremap(REGION_OFFSET(tioce_common->ce_pcibus.bs_base),
 			sizeof(struct tioce_common));
-- 
1.9.1

