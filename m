From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 17 Sep 2003 21:31:58 +0000
Subject: [PATCH] fix build_zonelists for CONFIG_ACPI_NUMA
Message-Id: <marc-linux-ia64-106383460616067@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's a ugly little patch to make build_zonelists use the ACPI SLIT
table on ia64 if it's present.  Comments?  Should we have a generic
Linux distance table that we use for this?  That way people could
populate it at early boot and we could make this code work for all
platforms.

Btw, this patch sits on top of the last discontig patch I posted.

Thanks,
Jesse

diff -Nru a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
--- a/arch/ia64/kernel/acpi.c	Wed Sep 17 14:27:48 2003
+++ b/arch/ia64/kernel/acpi.c	Wed Sep 17 14:27:48 2003
@@ -342,7 +342,7 @@
 /* maps to convert between proximity domain and logical node ID */
 int __initdata pxm_to_nid_map[MAX_PXM_DOMAINS];
 int __initdata nid_to_pxm_map[NR_NODES];
-static struct acpi_table_slit __initdata *slit_table;
+struct acpi_table_slit __initdata *slit_table;
 
 /*
  * ACPI 2.0 SLIT (System Locality Information Table)
diff -Nru a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
--- a/arch/ia64/mm/discontig.c	Wed Sep 17 14:27:48 2003
+++ b/arch/ia64/mm/discontig.c	Wed Sep 17 14:27:48 2003
@@ -249,6 +249,160 @@
 	}
 }
 
+#ifdef CONFIG_ACPI_NUMA
+
+/**
+ * sort_distance_array - sort a single row from the SLIT table
+ * @slit: copy of a row from the SLIT table
+ * @nodes: on exit, the sorted list of node numbers
+ * @size: size of @slit and @nodes
+ *
+ * Sorts the SLIT row by proximity domain, preferring proximity
+ * domains in order of their CPU count, from lowest to highest.
+ */
+static void __init
+sort_distance_array(unsigned int *slit, int *nodes, int size)
+{
+	unsigned int i, j, k, x, y;
+
+	/*
+	 * Initialize the nodes array and weight the SLIT values
+	 */
+	for (i = 0; i < size; i++)
+		nodes[i] = i;
+
+	for (i = 0; i < size - 1; i++) {
+		k = i;
+		
+		for (j = k + 1; j < size; j++) {
+			if (slit[j] < slit[k])
+				k = j;
+		}
+		
+		if (k != i) {
+			x = slit[k]; slit[k] = slit[i]; slit[i] = x;
+			y = nodes[k]; nodes[k] = nodes[i]; nodes[i] = y;
+		}
+	}
+}
+
+/*
+ * Since kmalloc isn't available yet... (even on a big system this
+ * won't be more than a few kilobytes and it'll get freed up later).
+ */
+static int pxm_by_distance[NR_NODES] __initdata;
+static int nodes_by_distance[NR_NODES] __initdata;
+
+/*
+ * build_zonelist_others - append to the zonelist of a given node
+ * @local_node: node whose zonelist we'll append
+ *
+ * Use the ACPI SLIT table to build a pretty good fallback zonelist
+ * for memory allocations.
+ *
+ * We have a number of potential options here, given the fact that
+ * some nodes may have CPUs disabled (and are thus probably under
+ * less allocation pressure than others).
+ *
+ * Should we _always_ allocate first from nodes without CPUs if we can't
+ * get memory on our local node?  How about nodes with only one CPU?
+ * Should they be preferred over nodes with two?  All else being equal,
+ * we want to at least allocate in concentric rings based on distance,
+ * which means we have to trust (and use!) the values in the SLIT table
+ * as a first step.
+ *
+ * A simple SLIT table describing the distances between three nodes:
+ *
+ *       0   1   2
+ *   0   0  10  20
+ *   1  10   0  10
+ *   2  20  10   0
+ *
+ */
+void __init
+build_zonelists(pg_data_t *pgdat)
+{
+	int 		i, j, k, n;
+	pg_data_t	*node;
+	struct zonelist	*zonelist;
+	struct zone	*zone;
+
+	/*
+	 * Copy the SLIT table row corresponding to local_node since
+	 * we don't want to modify the global copy.  We use an int
+	 * array to give us more flexibility to weight certain types
+	 * of nodes (e.g. nodes w/o CPUs).
+	 */
+	for (i = 0; i < numnodes; i++)
+		pxm_by_distance[i] = (int)slit_table->entry[numnodes*(pgdat->node_id)+i];
+
+	sort_distance_array(pxm_by_distance, nodes_by_distance, numnodes);
+
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+
+		zonelist = pgdat->node_zonelists + i;
+
+		/* find bottom of the list */
+		for (j = 0; zonelist->zones[j]; j++);
+
+		k = ZONE_NORMAL;
+		if (i & __GFP_HIGHMEM)
+			k = ZONE_HIGHMEM;
+		if (i & __GFP_DMA)
+			k = ZONE_DMA;
+
+		/*
+		 * Now we build the zonelist so that it contains the zones
+		 * of all the other nodes based on the sorting.
+		 */
+		for (n = 0 ; n < numnodes; n++) {
+			/*
+			 * Grab the pgdat struct from the next closest
+			 * node.
+			 */
+			node = NODE_DATA(nodes_by_distance[n]);
+
+			/*
+			 * Add the right zone to the end of the zonelist
+			 * of the local node.
+			 */
+			switch (k) {
+			default:
+				BUG();
+				/*
+				 * fallthrough:
+				 */
+			case ZONE_HIGHMEM:
+				zone = node->node_zones + ZONE_HIGHMEM;
+				if (zone->present_pages) {
+#ifndef CONFIG_HIGHMEM
+					BUG();
+#endif
+					zonelist->zones[j++] = zone;
+				}
+			case ZONE_NORMAL:
+				zone = node->node_zones + ZONE_NORMAL;
+				if (zone->present_pages)
+					zonelist->zones[j++] = zone;
+				
+			case ZONE_DMA:
+				zone = node->node_zones + ZONE_DMA;
+				if (zone->present_pages)
+					zonelist->zones[j++] = zone;
+			}
+		}
+		/* zonelist is NULL terminated */
+		zonelist->zones[j++] = NULL;
+	}
+#ifdef DISCONTIG_DEBUG
+	printk("Zonelist for node %d: ", pgdat->node_id);
+	for (i = 0; i < numnodes; i++)
+		printk("%d ", nodes_by_distance[i]);
+	printk("\n");
+#endif
+}
+
+#endif /* CONFIG_ACPI_NUMA */
 
 /*
  * Called early in boot to setup the boot memory allocator, and to
diff -Nru a/include/asm-ia64/acpi.h b/include/asm-ia64/acpi.h
--- a/include/asm-ia64/acpi.h	Wed Sep 17 14:27:48 2003
+++ b/include/asm-ia64/acpi.h	Wed Sep 17 14:27:48 2003
@@ -98,6 +98,7 @@
 #define MAX_PXM_DOMAINS (256)
 extern int __initdata pxm_to_nid_map[MAX_PXM_DOMAINS];
 extern int __initdata nid_to_pxm_map[NR_NODES];
+extern struct acpi_table_slit *slit_table;
 #endif
 
 #endif /*__KERNEL__*/
diff -Nru a/include/asm-ia64/pgtable.h b/include/asm-ia64/pgtable.h
--- a/include/asm-ia64/pgtable.h	Wed Sep 17 14:27:48 2003
+++ b/include/asm-ia64/pgtable.h	Wed Sep 17 14:27:48 2003
@@ -435,11 +435,17 @@
 #ifdef CONFIG_DISCONTIGMEM
 extern void discontig_mem_init(void);
 extern void call_pernode_memory(unsigned long start, unsigned long end, void *arg);
+
+#ifdef CONFIG_ACPI_NUMA
+#define HAVE_ARCH_BUILD_ZONELISTS
+extern void build_zonelists(pg_data_t *pgdat);
+#endif /* CONFIG_ACPI_NUMA */
+
 #else
 extern unsigned long bootmap_start;
 extern int find_max_pfn(unsigned long start, unsigned long end, void *arg);
 extern int find_bootmap_location(unsigned long start, unsigned long end, void *arg);
-#endif
+#endif /* CONFIG_DISCONTIGMEM */
 
 /*
  * Note: The macros below rely on the fact that MAX_SWAPFILES_SHIFT <= number of
diff -Nru a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c	Wed Sep 17 14:27:48 2003
+++ b/mm/page_alloc.c	Wed Sep 17 14:27:48 2003
@@ -1017,6 +1017,8 @@
 	show_swap_cache_info();
 }
 
+#ifndef HAVE_ARCH_BUILD_ZONELISTS
+
 /*
  * Builds allocation fallback zone lists.
  */
@@ -1083,6 +1085,8 @@
 		zonelist->zones[j++] = NULL;
 	} 
 }
+
+#endif /* HAVE_ARCH_BUILD_ZONELISTS */
 
 void __init build_all_zonelists(void)
 {
