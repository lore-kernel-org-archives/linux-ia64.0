From: Robin Holt <holt@sgi.com>
Date: Tue, 19 Oct 2004 19:12:57 +0000
Subject: Distribute useage of BTE interfaces.
Message-Id: <20041019191257.GF1012@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


During peak utilization periods, the first interface on a node has
an inordinately large amount of contention.  This is due to all
cpus starting their scan for an interface at 0.  This patch distributes
that based upon the slice the requesting cpu is attached to.

Signed-off-by: Robin Holt


Index: linux-2.6/arch/ia64/sn/kernel/bte.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/bte.c	2004-10-18 15:51:04.000000000 -0500
+++ linux-2.6/arch/ia64/sn/kernel/bte.c	2004-10-18 16:18:54.000000000 -0500
@@ -73,6 +73,7 @@
 	unsigned long itc_end = 0;
 	struct bteinfo_s *btes_to_try[MAX_INTERFACES_TO_TRY];
 	int bte_if_index;
+	int bte_pri, bte_sec;
 
 	BTE_PRINTK(("bte_copy(0x%lx, 0x%lx, 0x%lx, 0x%lx, 0x%p)\n",
 		    src, dest, len, mode, notification));
@@ -85,24 +86,33 @@
 		 (src & L1_CACHE_MASK) || (dest & L1_CACHE_MASK));
 	BUG_ON(!(len < ((BTE_LEN_MASK + 1) << L1_CACHE_SHIFT)));
 
+	/* CPU 0 (per node) tries bte0 first, CPU 1 try bte1 first */
+	if (cpuid_to_subnode(smp_processor_id()) = 0) {
+		bte_pri = 0;
+		bte_sec = 1;
+	} else {
+		bte_pri = 1;
+		bte_sec = 0;
+	}
+
 	if (mode & BTE_USE_DEST) {
 		/* try remote then local */
-		btes_to_try[0] = bte_if_on_node(NASID_GET(dest), 0);
-		btes_to_try[1] = bte_if_on_node(NASID_GET(dest), 1);
+		btes_to_try[0] = bte_if_on_node(NASID_GET(dest), bte_pri);
+		btes_to_try[1] = bte_if_on_node(NASID_GET(dest), bte_sec);
 		if (mode & BTE_USE_ANY) {
-			btes_to_try[2] = bte_if_on_node(get_nasid(), 0);
-			btes_to_try[3] = bte_if_on_node(get_nasid(), 1);
+			btes_to_try[2] = bte_if_on_node(get_nasid(), bte_pri);
+			btes_to_try[3] = bte_if_on_node(get_nasid(), bte_sec);
 		} else {
 			btes_to_try[2] = NULL;
 			btes_to_try[3] = NULL;
 		}
 	} else {
 		/* try local then remote */
-		btes_to_try[0] = bte_if_on_node(get_nasid(), 0);
-		btes_to_try[1] = bte_if_on_node(get_nasid(), 1);
+		btes_to_try[0] = bte_if_on_node(get_nasid(), bte_pri);
+		btes_to_try[1] = bte_if_on_node(get_nasid(), bte_sec);
 		if (mode & BTE_USE_ANY) {
-			btes_to_try[2] = bte_if_on_node(NASID_GET(dest), 0);
-			btes_to_try[3] = bte_if_on_node(NASID_GET(dest), 1);
+			btes_to_try[2] = bte_if_on_node(NASID_GET(dest), bte_pri);
+			btes_to_try[3] = bte_if_on_node(NASID_GET(dest), bte_sec);
 		} else {
 			btes_to_try[2] = NULL;
 			btes_to_try[3] = NULL;
