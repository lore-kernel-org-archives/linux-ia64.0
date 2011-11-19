From: Thomas Meyer <thomas@m3y3r.de>
Date: Sat, 19 Nov 2011 11:26:05 +0000
Subject: [PATCH] ia64: pcibr: Use kmemdup rather than duplicating its
Message-Id: <1321701965.1624.323.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: jes@sgi.com, tony.luck@intel.com, fenghua.yu@intel.com, linux-altix@sgi.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

The semantic patch that makes this change is available
in scripts/coccinelle/api/memdup.cocci.

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/arch/ia64/sn/pci/pcibr/pcibr_provider.c b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
--- a/arch/ia64/sn/pci/pcibr/pcibr_provider.c 2011-11-07 19:39:05.034456070 +0100
+++ b/arch/ia64/sn/pci/pcibr/pcibr_provider.c 2011-11-08 11:01:35.484737338 +0100
@@ -127,12 +127,11 @@ pcibr_bus_fixup(struct pcibus_bussoft *p
 	 * Allocate kernel bus soft and copy from prom.
 	 */
 
-	soft = kmalloc(sizeof(struct pcibus_info), GFP_KERNEL);
+	soft = kmemdup(prom_bussoft, sizeof(struct pcibus_info), GFP_KERNEL);
 	if (!soft) {
 		return NULL;
 	}
 
-	memcpy(soft, prom_bussoft, sizeof(struct pcibus_info));
 	soft->pbi_buscommon.bs_base = (unsigned long)
 		ioremap(REGION_OFFSET(soft->pbi_buscommon.bs_base),
 			sizeof(struct pic));


