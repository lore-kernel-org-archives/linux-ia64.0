From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 10 Oct 2003 16:21:12 +0000
Subject: [PATCH] fix sn2 interrupt allocation
Message-Id: <marc-linux-ia64-106580300518072@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Patch from Christoph.  Fixes interrupt allocation code for sn2.

Jesse

--- 1.6/arch/ia64/sn/io/sn2/ml_SN_intr.c	Fri Sep 26 13:38:25 2003
+++ edited/arch/ia64/sn/io/sn2/ml_SN_intr.c	Sun Sep 28 10:26:47 2003
@@ -285,7 +273,6 @@
 cpuid_t intr_heuristic(vertex_hdl_t dev, int req_bit, int *resp_bit)
 {
 	cpuid_t		cpuid;
-	cpuid_t		candidate = CPU_NONE;
 	vertex_hdl_t	pconn_vhdl;
 	pcibr_soft_t	pcibr_soft;
 	int 		bit;
@@ -293,30 +280,32 @@
 	/* XXX: gross layering violation.. */
 	if (hwgraph_edge_get(dev, EDGE_LBL_PCI, &pconn_vhdl) = GRAPH_SUCCESS) {
 		pcibr_soft = pcibr_soft_get(pconn_vhdl);
-		if (pcibr_soft && pcibr_soft->bsi_err_intr)
-			candidate = ((hub_intr_t)pcibr_soft->bsi_err_intr)->i_cpuid;
-	}
-
-	if (candidate != CPU_NONE) {
-		/*
-		 * The cpu was chosen already when we assigned
-		 * the error interrupt.
-		 */
-		bit = intr_reserve_level(candidate, req_bit);
-		if (bit >= 0) {
-			*resp_bit = bit;
-			return candidate;
+		if (pcibr_soft && pcibr_soft->bsi_err_intr) {
+			/*
+			 * The cpu was chosen already when we assigned
+			 * the error interrupt.
+			 */
+			cpuid = ((hub_intr_t)pcibr_soft->bsi_err_intr)->i_cpuid;
+			goto done;
 		}
-
-		printk("Cannot target interrupt to target node (%ld).\n",candidate);
-		return CPU_NONE;
 	}
 
 	/*
 	 * Need to choose one.  Try the controlling c-brick first.
 	 */
 	cpuid = intr_cpu_choose_from_node(master_node_get(dev));
-	if (cpuid != CPU_NONE)
-		return cpuid;
-	return intr_cpu_choose_node();
+	if (cpuid = CPU_NONE)
+		cpuid = intr_cpu_choose_node();
+
+ done:
+	if (cpuid != CPU_NONE) {
+		bit = intr_reserve_level(cpuid, req_bit);
+		if (bit >= 0) {
+			*resp_bit = bit;
+			return cpuid;
+		}
+	}
+
+	printk("Cannot target interrupt to target cpu (%ld).\n", cpuid);
+	return CPU_NONE;
 }
