From: Roel Kluin <12o3l@tiscali.nl>
Date: Sat, 03 Nov 2007 23:43:42 +0000
Subject: iounmap after ioremap in arch/ia64/sn/pci/pcibr/pcibr_provider.c
Message-Id: <472D07AE.1000202@tiscali.nl>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A better discription, maybe?
--
iounmap after ioremap

Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/arch/ia64/sn/pci/pcibr/pcibr_provider.c b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
index ab3eaf8..00d1b85 100644
--- a/arch/ia64/sn/pci/pcibr/pcibr_provider.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
@@ -186,6 +186,7 @@ pcibr_bus_fixup(struct pcibus_bussoft *prom_bussoft, struct pci_controller *cont
 
 	if (!soft->pbi_int_ate_resource.ate) {
 		kfree(soft);
+		iounmap(soft->pbi_buscommon.bs_base);
 		return NULL;
 	}
 
