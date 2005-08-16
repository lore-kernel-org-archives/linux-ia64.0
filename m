From: Mark Goodwin <markgw@sgi.com>
Date: Tue, 16 Aug 2005 07:50:36 +0000
Subject: [PATCH 3/3] - SGI SN hwperf enhancements - pcibr_bus_fixup_for_tio_busses
Message-Id: <Pine.LNX.4.62.0508161741540.7676@woolami.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Update the SN pci device info to use the nearest node function
to allocate driver memory on the nearest node (rather than
defaulting to node 0).

Signed-off-by: Mark Goodwin <markgw@sgi.com>

Index: linux/arch/ia64/sn/pci/pcibr/pcibr_provider.c
=================================--- linux.orig/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2005-08-15 13:23:40.613371546 +1000
+++ linux/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2005-08-16 06:22:01.168092514 +1000
@@ -15,6 +15,7 @@
 #include <asm/sn/pcibus_provider_defs.h>
 #include <asm/sn/pcidev.h>
 #include <asm/sn/sn_sal.h>
+#include <asm/sn/sn2/sn_hwperf.h>
 #include "xtalk/xwidgetdev.h"
 #include "xtalk/hubdev.h"
 
@@ -88,6 +89,7 @@
 pcibr_bus_fixup(struct pcibus_bussoft *prom_bussoft, struct pci_controller *controller)
 {
 	int nasid, cnode, j;
+	cnodeid_t near_cnode;
 	struct hubdev_info *hubdev_info;
 	struct pcibus_info *soft;
 	struct sn_flush_device_list *sn_flush_device_list;
@@ -158,12 +160,18 @@
 	memset(soft->pbi_int_ate_resource.ate, 0,
  	       (soft->pbi_int_ate_size * sizeof(uint64_t)));
 
-	if (prom_bussoft->bs_asic_type = PCIIO_ASIC_TYPE_TIOCP)
-		/*
-		 * TIO PCI Bridge with no closest node information.
-		 * FIXME: Find another way to determine the closest node
-		 */
-		controller->node = -1;
+	if (prom_bussoft->bs_asic_type = PCIIO_ASIC_TYPE_TIOCP) {
+		/* TIO PCI Bridge: find nearest node with CPUs */
+		int e = sn_hwperf_get_nearest_node(cnode, NULL, &near_cnode);
+
+		if (e < 0) {
+			near_cnode = (cnodeid_t)-1; /* use any node */
+			printk(KERN_WARNING "pcibr_bus_fixup: failed to find "
+				"near node with CPUs to TIO node %d, err=%d\n",
+				cnode, e);
+		}
+		controller->node = near_cnode;
+	}
 	else
 		controller->node = cnode;
 	return soft;
