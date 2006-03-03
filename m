From: Dean Roe <roe@sgi.com>
Date: Fri, 03 Mar 2006 15:03:12 +0000
Subject: [PATCH] fix for-loop in sn_hwperf_geoid_to_cnode()
Message-Id: <20060303150312.GA32225@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix a for-loop in sn_hwperf_geoid_to_cnode().  It needs to loop over
num_cnodes to ensure it can still process TIO nodes in addition to
compute nodes on systems with many nodes.

	Signed-off-by: Dean Roe <roe@sgi.com>


Index: linux-2.6/arch/ia64/sn/kernel/sn2/sn_hwperf.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/sn2/sn_hwperf.c
+++ linux-2.6/arch/ia64/sn/kernel/sn2/sn_hwperf.c
@@ -110,7 +110,7 @@
 	if (sn_hwperf_location_to_bpos(location, &rack, &bay, &slot, &slab))
 		return -1;
 
-	for_each_node(cnode) {
+	for (cnode = 0; cnode < num_cnodes; cnode++) {
 		geoid = cnodeid_get_geoid(cnode);
 		module_id = geo_module(geoid);
 		this_rack = MODULE_GET_RACK(module_id);

