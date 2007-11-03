From: Roel Kluin <12o3l@tiscali.nl>
Date: Sat, 03 Nov 2007 23:50:48 +0000
Subject: [PATCH] Also iounmap when kzalloc fails in tioca_bus_fixup (ia64/sn/pci/tioca_provider.c)
Message-Id: <472D0958.9030203@tiscali.nl>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Also iounmap when kzalloc fails

Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/arch/ia64/sn/pci/tioca_provider.c b/arch/ia64/sn/pci/tioca_provider.c
index ef048a6..de1ec5c 100644
--- a/arch/ia64/sn/pci/tioca_provider.c
+++ b/arch/ia64/sn/pci/tioca_provider.c
@@ -618,6 +618,7 @@ tioca_bus_fixup(struct pcibus_bussoft *prom_bussoft, struct pci_controller *cont
 
 	tioca_kern = kzalloc(sizeof(struct tioca_kernel), GFP_KERNEL);
 	if (!tioca_kern) {
+		iounmap(tioca_common->ca_common.bs_base);
 		kfree(tioca_common);
 		return NULL;
 	}
@@ -637,6 +638,7 @@ tioca_bus_fixup(struct pcibus_bussoft *prom_bussoft, struct pci_controller *cont
 	/* init GART */
 
 	if (tioca_gart_init(tioca_kern) < 0) {
+		iounmap(tioca_common->ca_common.bs_base);
 		kfree(tioca_kern);
 		kfree(tioca_common);
 		return NULL;
