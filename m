From: Andy Whitcroft <apw@shadowen.org>
Date: Wed, 15 Aug 2007 14:50:58 +0000
Subject: [PATCH] ia64: default the NUMA node distance when there is no ACPI SLIT
Message-Id: <b6b031e56608ee8acf4c84cb1f413403@pinky>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org


If during boot no ACPI 2.0 SLIT table is found we do not initialise
the NUMA node distance table, leaving all node distances as 0.
This causes IA-64 to fail the regression tests for libnuma.  Also,
when we have a bad formatted table we will set all node distances
to 10.  Both of these forms lose all NUMA information by indicating
all nodes are as close as the "local node", and are inconsistant
in their values.

When an architecture does not offer NUMA topology support the default
node_distance is a distance of LOCAL_DISTANCE (10) to the local node
and REMOTE_DISTANCE (20) to all others.  It seems more correct to
follow this model when the SLIT information is missing or corrupt.

This patch updates the SLIT failure paths to fill in the NUMA node
distance table with this default.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 arch/ia64/kernel/acpi.c |   62 ++++++++++++++++++++++++++++++++++------------
 1 files changed, 46 insertions(+), 16 deletions(-)
diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 3d45d24..3cd3e5b 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -445,7 +445,6 @@ void __init acpi_numa_slit_init(struct acpi_table_slit *slit)
 		printk(KERN_ERR
 		       "ACPI 2.0 SLIT: size mismatch: %d expected, %d actual\n",
 		       len, slit->header.length);
-		memset(numa_slit, 10, sizeof(numa_slit));
 		return;
 	}
 	slit_table = slit;
@@ -507,9 +506,50 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 	num_node_memblks++;
 }
 
+void __init acpi_numa_distance_from_slit(void)
+{
+	int i, j;
+	int node_from;
+	int node_to;
+	int nodes = slit_table->locality_count;
+
+	printk(KERN_INFO "Building NUMA distance from ACPI 2.0 SLIT\n");
+
+	for (i = 0; i < nodes; i++) {
+		if (!pxm_bit_test(i))
+			continue;
+		node_from = pxm_to_node(i);
+		for (j = 0; j < nodes; j++) {
+			if (!pxm_bit_test(j))
+				continue;
+			node_to = pxm_to_node(j);
+			node_distance(node_from, node_to) +					  slit_table->entry[i * nodes + j];
+		}
+	}
+}
+
+void __init acpi_numa_distance_default(void)
+{
+	int i, j;
+	int node_from;
+	int node_to;
+
+	printk(KERN_INFO "No SLIT table, defaulting NUMA distance\n");
+
+	for_each_online_node(i) {
+		node_from = pxm_to_node(i);
+		for_each_online_node(j) {
+			node_to = pxm_to_node(j);
+			node_distance(node_from, node_to) = (i = j)?
+				LOCAL_DISTANCE : REMOTE_DISTANCE;
+		}
+	}
+}
+
 void __init acpi_numa_arch_fixup(void)
 {
-	int i, j, node_from, node_to;
+	int i, j;
 
 	/* If there's no SRAT, fix the phys_id and mark node 0 online */
 	if (srat_num_cpus = 0) {
@@ -553,21 +593,11 @@ void __init acpi_numa_arch_fixup(void)
 	printk(KERN_INFO "Number of memory chunks in system = %d\n",
 	       num_node_memblks);
 
-	if (!slit_table)
-		return;
 	memset(numa_slit, -1, sizeof(numa_slit));
-	for (i = 0; i < slit_table->locality_count; i++) {
-		if (!pxm_bit_test(i))
-			continue;
-		node_from = pxm_to_node(i);
-		for (j = 0; j < slit_table->locality_count; j++) {
-			if (!pxm_bit_test(j))
-				continue;
-			node_to = pxm_to_node(j);
-			node_distance(node_from, node_to) -			    slit_table->entry[i * slit_table->locality_count + j];
-		}
-	}
+	if (slit_table)
+		acpi_numa_distance_from_slit();
+	else
+		acpi_numa_distance_default();
 
 #ifdef SLIT_DEBUG
 	printk("ACPI 2.0 SLIT locality table:\n");
