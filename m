From: Mark Goodwin <markgw@sgi.com>
Date: Wed, 09 Mar 2005 01:07:33 +0000
Subject: [PATCH ia64 2.6.11] Altix SN topology fix potential infinite loop
Message-Id: <Pine.LNX.4.62.0503081758160.7236@woolami.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Fix infinite loop if sn_hwperf_location_to_bpos() fails.

Signed-off-by: Mark Goodwin <markgw@sgi.com>

diff -auNr linux.orig/arch/ia64/sn/kernel/sn2/sn_hwperf.c linux/arch/ia64/sn/kernel/sn2/sn_hwperf.c
--- linux.orig/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2005-03-08 17:50:50.000000000 +1100
+++ linux/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2005-03-09 11:59:54.000000000 +1100
@@ -300,14 +300,15 @@
 		 * PCI busses attached to this node, if any
 		 */
 		do {
-			if (!(pci_topo_buf = vmalloc(pci_topo_buf_len))) {
-				printk("sn_topology_show: kmalloc failed\n");
+			if (sn_hwperf_location_to_bpos(obj->location,
+				&rack, &bay, &slot, &slab) {
 				break;
 			}
 
-			if (sn_hwperf_location_to_bpos(obj->location,
-				&rack, &bay, &slot, &slab) != 0)
-				continue;
+			if (!(pci_topo_buf = vmalloc(pci_topo_buf_len))) {
+				printk("sn_topology_show: vmalloc failed\n");
+				break;
+			}
 
 			e = ia64_sn_ioif_get_pci_topology(rack, bay, slot, slab,
 			    	pci_topo_buf, pci_topo_buf_len);
@@ -325,6 +326,7 @@
 				break;
 
 			case SN_HWPERF_OP_OK:
+			default:
 				/* export pci bus info */
 				print_pci_topology(s, obj, &pci_bus_ordinal,
 					pci_topo_buf, pci_topo_buf_len);
