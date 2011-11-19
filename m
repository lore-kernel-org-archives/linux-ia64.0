From: Thomas Meyer <thomas@m3y3r.de>
Date: Sat, 19 Nov 2011 11:27:39 +0000
Subject: [PATCH] ia64: tioca: Use kmemdup rather than duplicating its
Message-Id: <1321702059.1624.324.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: jes@sgi.com, tony.luck@intel.com, fenghua.yu@intel.com, linux-altix@sgi.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

The semantic patch that makes this change is available
in scripts/coccinelle/api/memdup.cocci.

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/arch/ia64/sn/pci/tioca_provider.c b/arch/ia64/sn/pci/tioca_provider.c
--- a/arch/ia64/sn/pci/tioca_provider.c 2011-11-07 19:39:05.034456070 +0100
+++ b/arch/ia64/sn/pci/tioca_provider.c 2011-11-08 11:01:35.744740824 +0100
@@ -600,11 +600,11 @@ tioca_bus_fixup(struct pcibus_bussoft *p
 	 * Allocate kernel bus soft and copy from prom.
 	 */
 
-	tioca_common = kzalloc(sizeof(struct tioca_common), GFP_KERNEL);
+	tioca_common = kmemdup(prom_bussoft, sizeof(struct tioca_common),
+			       GFP_KERNEL);
 	if (!tioca_common)
 		return NULL;
 
-	memcpy(tioca_common, prom_bussoft, sizeof(struct tioca_common));
 	tioca_common->ca_common.bs_base = (unsigned long)
 		ioremap(REGION_OFFSET(tioca_common->ca_common.bs_base),
 			sizeof(struct tioca_common));


