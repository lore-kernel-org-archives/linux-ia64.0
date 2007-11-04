From: Roel Kluin <12o3l@tiscali.nl>
Date: Sun, 04 Nov 2007 11:12:23 +0000
Subject: [PATCH] iounmap if tioce_kern_init fails in ia64/sn/pci/tioce_provider.c
Message-Id: <472DA917.9050000@tiscali.nl>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Do iounmap if tioce_kern_init fails

Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/arch/ia64/sn/pci/tioce_provider.c b/arch/ia64/sn/pci/tioce_provider.c
index cee9379..128ed07 100644
--- a/arch/ia64/sn/pci/tioce_provider.c
+++ b/arch/ia64/sn/pci/tioce_provider.c
@@ -1008,6 +1008,7 @@ tioce_bus_fixup(struct pcibus_bussoft *prom_bussoft, struct pci_controller *cont
 
 	tioce_kern = tioce_kern_init(tioce_common);
 	if (tioce_kern = NULL) {
+		iounmap(tioce_common->ce_pcibus.bs_base);
 		kfree(tioce_common);
 		return NULL;
 	}

