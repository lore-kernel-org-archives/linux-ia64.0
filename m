From: Jack Steiner <steiner@sgi.com>
Date: Sat, 22 Apr 2006 14:36:07 +0000
Subject: [PATCH] - Fix discover of nearest cpu node to IO node
Message-Id: <20060422143607.GA24662@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix a bug that causes discovery of the nearest node/cpu to
a TIO (IO node) to fail. 

	Signed-off-by: Jack Steiner <steiner@sgi.com>



Index: linux/arch/ia64/sn/kernel/sn2/sn_hwperf.c
=================================--- linux.orig/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2006-04-22 08:50:14.571000439 -0500
+++ linux/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2006-04-22 09:24:01.969360448 -0500
@@ -284,6 +284,8 @@ static int sn_hwperf_get_nearest_node_ob
 	/* find nearest node with cpus and nearest memory */
 	for (router=NULL, j=0; j < op->ports; j++) {
 		dest = sn_hwperf_findobj_id(objbuf, nobj, ptdata[j].conn_id);
+		if (dest && SN_HWPERF_IS_ROUTER(dest))
+			router = dest;
 		if (!dest || SN_HWPERF_FOREIGN(dest) ||
 		    !SN_HWPERF_IS_NODE(dest) || SN_HWPERF_IS_IONODE(dest)) {
 			continue;
@@ -299,8 +301,6 @@ static int sn_hwperf_get_nearest_node_ob
 				*near_mem_node = c;
 			found_mem++;
 		}
-		if (SN_HWPERF_IS_ROUTER(dest))
-			router = dest;
 	}
 
 	if (router && (!found_cpu || !found_mem)) {
Index: linux/include/asm-ia64/sn/sn2/sn_hwperf.h
=================================--- linux.orig/include/asm-ia64/sn/sn2/sn_hwperf.h	2006-04-22 08:50:19.858482442 -0500
+++ linux/include/asm-ia64/sn/sn2/sn_hwperf.h	2006-04-22 09:24:01.973360043 -0500
@@ -45,8 +45,12 @@ struct sn_hwperf_object_info {
 #define SN_HWPERF_IS_NODE(x)		((x) && strstr((x)->name, "SHub"))
 #define SN_HWPERF_IS_NODE_SHUB2(x)	((x) && strstr((x)->name, "SHub 2."))
 #define SN_HWPERF_IS_IONODE(x)		((x) && strstr((x)->name, "TIO"))
-#define SN_HWPERF_IS_ROUTER(x)		((x) && strstr((x)->name, "Router"))
 #define SN_HWPERF_IS_NL3ROUTER(x)	((x) && strstr((x)->name, "NL3Router"))
+#define SN_HWPERF_IS_NL4ROUTER(x)	((x) && strstr((x)->name, "NL4Router"))
+#define SN_HWPERF_IS_OLDROUTER(x)	((x) && strstr((x)->name, "Router"))
+#define SN_HWPERF_IS_ROUTER(x)		(SN_HWPERF_IS_NL3ROUTER(x) || 		\
+					 	SN_HWPERF_IS_NL4ROUTER(x) || 	\
+					 	SN_HWPERF_IS_OLDROUTER(x))
 #define SN_HWPERF_FOREIGN(x)		((x) && !(x)->sn_hwp_this_part && !(x)->sn_hwp_is_shared)
 #define SN_HWPERF_SAME_OBJTYPE(x,y)	((SN_HWPERF_IS_NODE(x) && SN_HWPERF_IS_NODE(y)) ||\
 					(SN_HWPERF_IS_IONODE(x) && SN_HWPERF_IS_IONODE(y)) ||\
