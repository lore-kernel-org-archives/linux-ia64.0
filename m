From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Sat, 08 Jan 2005 01:00:57 +0000
Subject: [PATCH] fix bogus address dereference in sn/setup.c
Message-Id: <200501071700.57816.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_JDz3BC8zZnaWjys"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_JDz3BC8zZnaWjys
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Some code in sn/setup.c was trying to dereference a physical address, which 
usually doesn't work (esp. not with the region register init patch I posted).  
This patch converts the function used to find the klconfig to return virtual 
char * instead of a physical address and updates the caller to deal with it.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_JDz3BC8zZnaWjys
Content-Type: text/plain;
  charset="us-ascii";
  name="klconfig-virtual-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="klconfig-virtual-fix.patch"

===== arch/ia64/sn/kernel/setup.c 1.43 vs edited =====
--- 1.43/arch/ia64/sn/kernel/setup.c	2004-11-02 12:32:14 -08:00
+++ edited/arch/ia64/sn/kernel/setup.c	2005-01-07 16:05:51 -08:00
@@ -503,15 +503,15 @@
 
 	/* Setup ionodes with memory */
 	for (nasid = 0; nasid < MAX_PHYSNODE_ID; nasid += 2) {
-		u64 klgraph_header;
+		char *klgraph_header;
 		cnodeid_t cnodeid;
 
 		if (physical_node_map[nasid] == -1)
 			continue;
 
-		klgraph_header = cnodeid = -1;
-		klgraph_header = ia64_sn_get_klconfig_addr(nasid);
-		if (klgraph_header <= 0) {
+		cnodeid = -1;
+		klgraph_header = __va(ia64_sn_get_klconfig_addr(nasid));
+		if (!klgraph_header) {
 			if (IS_RUNNING_ON_SIMULATOR())
 				continue;
 			BUG();	/* All nodes must have klconfig tables! */
===== include/asm-ia64/sn/sn_sal.h 1.17 vs edited =====
--- 1.17/include/asm-ia64/sn/sn_sal.h	2004-11-03 13:41:17 -08:00
+++ edited/include/asm-ia64/sn/sn_sal.h	2005-01-07 16:05:17 -08:00
@@ -203,7 +203,7 @@
 	return ret_stuff.v0;
 }
 
-static inline u64
+static inline char *
 ia64_sn_get_klconfig_addr(nasid_t nasid)
 {
 	struct ia64_sal_retval ret_stuff;
@@ -223,7 +223,7 @@
 	if (ret_stuff.status != 0) {
 		panic("ia64_sn_get_klconfig_addr: Returned error %lx\n", ret_stuff.status);
 	}
-	return(ret_stuff.v0);
+	return ret_stuff.v0 ? __va(ret_stuff.v0) : NULL;
 }
 
 /*

--Boundary-00=_JDz3BC8zZnaWjys--
