From: Mike Habeck <habeck@sgi.com>
Date: Mon, 26 Nov 2007 17:19:57 +0000
Subject: [PATCH] SGI Altix : fix bug in sn_io_late_init()
Message-Id: <20071126171957.31709.13539.78500@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


When initializing pci_controller->node to point to the closest node we need
to take into consideration that a PIC PCI Bridge ASIC can be connected to a
headless/memless node just like the TIOCP and TIOCE Bridge ASICs

Signed-off-by: Mike Habeck <habeck@sgi.com>

---

This patch is based off the aegl/linux-2.6.git tree.

 arch/ia64/sn/kernel/io_common.c |   11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

Index: linux-2.6/arch/ia64/sn/kernel/io_common.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/io_common.c	2007-11-15 17:30:01.000000000 -0600
+++ linux-2.6/arch/ia64/sn/kernel/io_common.c	2007-11-15 18:28:08.899624967 -0600
@@ -545,19 +545,18 @@ sn_io_late_init(void)
 		nasid = NASID_GET(bussoft->bs_base);
 		cnode = nasid_to_cnodeid(nasid);
 		if ((bussoft->bs_asic_type = PCIIO_ASIC_TYPE_TIOCP) ||
-		    (bussoft->bs_asic_type = PCIIO_ASIC_TYPE_TIOCE)) {
-			/* TIO PCI Bridge: find nearest node with CPUs */
+		    (bussoft->bs_asic_type = PCIIO_ASIC_TYPE_TIOCE) ||
+		    (bussoft->bs_asic_type = PCIIO_ASIC_TYPE_PIC)) {
+			/* PCI Bridge: find nearest node with CPUs */
 			int e = sn_hwperf_get_nearest_node(cnode, NULL,
 							   &near_cnode);
 			if (e < 0) {
 				near_cnode = (cnodeid_t)-1; /* use any node */
-				printk(KERN_WARNING "pcibr_bus_fixup: failed "
-				       "to find near node with CPUs to TIO "
+				printk(KERN_WARNING "sn_io_late_init: failed "
+				       "to find near node with CPUs for "
 				       "node %d, err=%d\n", cnode, e);
 			}
 			PCI_CONTROLLER(bus)->node = near_cnode;
-		} else if (bussoft->bs_asic_type = PCIIO_ASIC_TYPE_PIC) {
-			PCI_CONTROLLER(bus)->node = cnode;
 		}
 	}
 
