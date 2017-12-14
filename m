From: James Clarke <jrtc27@jrtc27.com>
Date: Thu, 14 Dec 2017 16:00:42 +0000
Subject: [PATCH] ia64: Bounds-check node_distance and allow use from modules
Message-Id: <20171214160042.8990-1-jrtc27@jrtc27.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Currently, the node_distance macro just indexes numa_slit. However,
numa_slit is not currently exported, and so node_distance cannot be used
by any modules, whether in-tree or out-of-tree. None of the in-tree
modules use it directly, but NVMe used to. Instead of exporting
numa_slit, this commit refactors the implementation to be more like x86
and arm64, by providing wrapper functions for getting and setting
distances which perform bounds-checking on the parameters, and exporting
the new __node_distance function.

Signed-off-by: James Clarke <jrtc27@jrtc27.com>
---
 arch/ia64/include/asm/numa.h | 13 ++++--------
 arch/ia64/kernel/acpi.c      | 18 +++++++++-------
 arch/ia64/mm/numa.c          | 50 +++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 64 insertions(+), 17 deletions(-)

diff --git a/arch/ia64/include/asm/numa.h b/arch/ia64/include/asm/numa.h
index ebef7f40aabb..43242d9283af 100644
--- a/arch/ia64/include/asm/numa.h
+++ b/arch/ia64/include/asm/numa.h
@@ -50,16 +50,11 @@ struct node_cpuid_s {
 extern struct node_memblk_s node_memblk[NR_NODE_MEMBLKS];
 extern struct node_cpuid_s node_cpuid[NR_CPUS];
 
-/*
- * ACPI 2.0 SLIT (System Locality Information Table)
- * http://devresource.hp.com/devresource/Docs/TechPapers/IA64/slit.pdf
- *
- * This is a matrix with "distances" between nodes, they should be
- * proportional to the memory access latency ratios.
- */
+extern void __init numa_reset_distance(void);
+extern void __init numa_set_distance(int from, int to, int distance);
 
-extern u8 numa_slit[MAX_NUMNODES * MAX_NUMNODES];
-#define node_distance(from,to) (numa_slit[(from) * MAX_NUMNODES + (to)])
+extern int __node_distance(int, int);
+#define node_distance(a, b) __node_distance(a, b)
 
 extern int paddr_to_nid(unsigned long paddr);
 
diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 1d29b2f8726b..4cbc58519e25 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -571,24 +571,28 @@ void __init acpi_numa_fixup(void)
 	       num_node_memblks);
 
 	if (!slit_table) {
-		for (i = 0; i < MAX_NUMNODES; i++)
-			for (j = 0; j < MAX_NUMNODES; j++)
-				node_distance(i, j) = i = j ? LOCAL_DISTANCE :
-							REMOTE_DISTANCE;
+		for (i = 0; i < MAX_NUMNODES; i++) {
+			for (j = 0; j < MAX_NUMNODES; j++) {
+				int dist = i = j ?
+					LOCAL_DISTANCE : REMOTE_DISTANCE;
+				numa_set_distance(i, j, dist);
+			}
+		}
 		return;
 	}
 
-	memset(numa_slit, -1, sizeof(numa_slit));
+	numa_reset_distance();
 	for (i = 0; i < slit_table->locality_count; i++) {
 		if (!pxm_bit_test(i))
 			continue;
 		node_from = pxm_to_node(i);
 		for (j = 0; j < slit_table->locality_count; j++) {
+			int dist;
 			if (!pxm_bit_test(j))
 				continue;
 			node_to = pxm_to_node(j);
-			node_distance(node_from, node_to) -			    slit_table->entry[i * slit_table->locality_count + j];
+			dist = slit_table->entry[i * slit_table->locality_count + j];
+			numa_set_distance(node_from, node_to, dist);
 		}
 	}
 
diff --git a/arch/ia64/mm/numa.c b/arch/ia64/mm/numa.c
index aa19b7ac8222..7c0b563ca878 100644
--- a/arch/ia64/mm/numa.c
+++ b/arch/ia64/mm/numa.c
@@ -34,7 +34,55 @@ struct node_cpuid_s node_cpuid[NR_CPUS]   * This is a matrix with "distances" between nodes, they should be
  * proportional to the memory access latency ratios.
  */
-u8 numa_slit[MAX_NUMNODES * MAX_NUMNODES];
+static u8 numa_slit[MAX_NUMNODES * MAX_NUMNODES];
+
+/**
+ * numa_reset_distance - Reset NUMA distance table
+ *
+ * The current table is filled with 0xFF.
+ */
+void __init numa_reset_distance(void)
+{
+	memset(numa_slit, -1, sizeof(numa_slit));
+}
+
+/**
+ * numa_set_distance - Set NUMA distance from one NUMA to another
+ * @from: the 'from' node to set distance
+ * @to: the 'to'  node to set distance
+ * @distance: NUMA distance
+ *
+ * Set the distance from node @from to @to to @distance. If @from or @to is
+ * higher than the highest possible node or lower than zero, or @distance
+ * doesn't make sense, the call is ignored.  This is to allow simplification of
+ * specific NUMA config implementations.
+ */
+void __init numa_set_distance(int from, int to, int distance)
+{
+	if (from >= MAX_NUMNODES || to >= MAX_NUMNODES ||
+			from < 0 || to < 0) {
+		pr_warn_once("NUMA: Warning: node ids are out of bound, from=%d to=%d distance=%d\n",
+			    from, to, distance);
+		return;
+	}
+
+	if ((u8)distance != distance ||
+	    (from = to && distance != LOCAL_DISTANCE)) {
+		pr_warn_once("NUMA: Warning: invalid distance parameter, from=%d to=%d distance=%d\n",
+			     from, to, distance);
+		return;
+	}
+
+	numa_slit[from * MAX_NUMNODES + to] = distance;
+}
+
+int __node_distance(int from, int to)
+{
+	if (from >= MAX_NUMNODES || to >= MAX_NUMNODES)
+		return from = to ? LOCAL_DISTANCE : REMOTE_DISTANCE;
+	return numa_slit[from * MAX_NUMNODES + to];
+}
+EXPORT_SYMBOL(__node_distance);
 
 /* Identify which cnode a physical address resides on */
 int
-- 
2.15.1

