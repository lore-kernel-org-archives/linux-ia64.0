From: Jes Sorensen <jes@sgi.com>
Date: Mon, 18 Jun 2007 15:19:05 +0000
Subject: [patch] Make SN2 PCI code use ioremap rather than manually mangle
Message-Id: <4676A269.7010207@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------050101030206050507060402"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------050101030206050507060402
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi Tony,

This one changes the SN2 specific PCI drivers to use ioremap() for
obtaining the real address to access for the PCI registers instead of
manually calculating them with __IA64_UNCACHED_OFFSET.

The patch should have no real change when running on a normal Linux
kernel, but when running as a paravirtualized it is needed.

Thanks,
Jes


--------------050101030206050507060402
Content-Type: text/plain;
 name="sn2-ioremap-pic-tio.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sn2-ioremap-pic-tio.diff"

Use ioremap() on SN2 specific PIC and TIO registers rather than
manually setting the __IA64_UNCACHED_OFFSET bits in the address we get
from the PROM.

Signed-off-by: Jes Sorensen <jes@sgi.com>

---
 arch/ia64/sn/pci/pcibr/pcibr_provider.c |    7 ++++---
 arch/ia64/sn/pci/tioca_provider.c       |    4 +++-
 arch/ia64/sn/pci/tioce_provider.c       |    4 +++-
 3 files changed, 10 insertions(+), 5 deletions(-)

Index: linux-2.6/arch/ia64/sn/pci/pcibr/pcibr_provider.c
===================================================================
--- linux-2.6.orig/arch/ia64/sn/pci/pcibr/pcibr_provider.c
+++ linux-2.6/arch/ia64/sn/pci/pcibr/pcibr_provider.c
@@ -15,6 +15,7 @@
 #include <asm/sn/pcibus_provider_defs.h>
 #include <asm/sn/pcidev.h>
 #include <asm/sn/sn_sal.h>
+#include <asm/sn/pic.h>
 #include <asm/sn/sn2/sn_hwperf.h>
 #include "xtalk/xwidgetdev.h"
 #include "xtalk/hubdev.h"
@@ -130,9 +131,9 @@ pcibr_bus_fixup(struct pcibus_bussoft *p
 	}
 
 	memcpy(soft, prom_bussoft, sizeof(struct pcibus_info));
-	soft->pbi_buscommon.bs_base =
-	    (((u64) soft->pbi_buscommon.
-	      bs_base << 4) >> 4) | __IA64_UNCACHED_OFFSET;
+	soft->pbi_buscommon.bs_base = (unsigned long)
+		ioremap(REGION_OFFSET(soft->pbi_buscommon.bs_base),
+			sizeof(struct pic));
 
 	spin_lock_init(&soft->pbi_lock);
 
Index: linux-2.6/arch/ia64/sn/pci/tioca_provider.c
===================================================================
--- linux-2.6.orig/arch/ia64/sn/pci/tioca_provider.c
+++ linux-2.6/arch/ia64/sn/pci/tioca_provider.c
@@ -610,7 +610,9 @@ tioca_bus_fixup(struct pcibus_bussoft *p
 		return NULL;
 
 	memcpy(tioca_common, prom_bussoft, sizeof(struct tioca_common));
-	tioca_common->ca_common.bs_base |= __IA64_UNCACHED_OFFSET;
+	tioca_common->ca_common.bs_base = (unsigned long)
+		ioremap(REGION_OFFSET(tioca_common->ca_common.bs_base),
+			sizeof(struct tioca_common));
 
 	/* init kernel-private area */
 
Index: linux-2.6/arch/ia64/sn/pci/tioce_provider.c
===================================================================
--- linux-2.6.orig/arch/ia64/sn/pci/tioce_provider.c
+++ linux-2.6/arch/ia64/sn/pci/tioce_provider.c
@@ -1002,7 +1002,9 @@ tioce_bus_fixup(struct pcibus_bussoft *p
 		return NULL;
 
 	memcpy(tioce_common, prom_bussoft, sizeof(struct tioce_common));
-	tioce_common->ce_pcibus.bs_base |= __IA64_UNCACHED_OFFSET;
+	tioce_common->ce_pcibus.bs_base = (unsigned long)
+		ioremap(REGION_OFFSET(tioce_common->ce_pcibus.bs_base),
+			sizeof(struct tioce_common));
 
 	tioce_kern = tioce_kern_init(tioce_common);
 	if (tioce_kern == NULL) {

--------------050101030206050507060402--
