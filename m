From: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>
Date: Tue, 02 Feb 2016 10:21:19 +0000
Subject: [PATCH v10 4/8] arm64, numa : Enable numa dt for arm64 platforms.
Message-Id: <1454407763-1017-5-git-send-email-gkulkarni@caviumnetworks.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1454407763-1017-1-git-send-email-gkulkarni@caviumnetworks.com>
In-Reply-To: <1454407763-1017-1-git-send-email-gkulkarni-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Will.Deacon-5wv7dgnIgG8@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, leif.lindholm-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, rfranz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, msalter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, steve.capper-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, hanjun.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, al.stone-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org, lenb-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, marc.zyngier-5wv7dgnIgG8@public.gmane.org, lorenzo.pieralisi-5wv7dgnIgG8@public.gmane.org, bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, fenghua.yu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, james.hog
Cc: gpkulkarni-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org

Adding numa dt binding support for arm64 based platforms.

Reviewed-by: Robert Richter <rrichter@cavium.com>
Signed-off-by: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>
---
 arch/arm64/include/asm/numa.h |  2 ++
 arch/arm64/kernel/smp.c       |  2 ++
 arch/arm64/mm/numa.c          | 17 +++++++++++++++++
 3 files changed, 21 insertions(+)

diff --git a/arch/arm64/include/asm/numa.h b/arch/arm64/include/asm/numa.h
index 574267f..e9b4f29 100644
--- a/arch/arm64/include/asm/numa.h
+++ b/arch/arm64/include/asm/numa.h
@@ -31,12 +31,14 @@ void __init arm64_numa_init(void);
 int __init numa_add_memblk(int nodeid, u64 start, u64 end);
 void __init numa_set_distance(int from, int to, int distance);
 void __init numa_free_distance(void);
+void __init early_map_cpu_to_node(unsigned int cpu, int nid);
 void numa_store_cpu_info(unsigned int cpu);
 
 #else	/* CONFIG_NUMA */
 
 static inline void numa_store_cpu_info(unsigned int cpu) { }
 static inline void arm64_numa_init(void) { }
+static inline void early_map_cpu_to_node(unsigned int cpu, int nid) { }
 
 #endif	/* CONFIG_NUMA */
 
diff --git a/arch/arm64/kernel/smp.c b/arch/arm64/kernel/smp.c
index d6e7d6a..46c45c8 100644
--- a/arch/arm64/kernel/smp.c
+++ b/arch/arm64/kernel/smp.c
@@ -520,6 +520,8 @@ static void __init of_parse_and_init_cpus(void)
 
 		pr_debug("cpu logical map 0x%llx\n", hwid);
 		cpu_logical_map(cpu_count) = hwid;
+
+		early_map_cpu_to_node(cpu_count, of_node_to_nid(dn));
 next:
 		cpu_count++;
 	}
diff --git a/arch/arm64/mm/numa.c b/arch/arm64/mm/numa.c
index 60f19a2..7aad5d4 100644
--- a/arch/arm64/mm/numa.c
+++ b/arch/arm64/mm/numa.c
@@ -20,6 +20,7 @@
 #include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/module.h>
+#include <linux/of.h>
 
 struct pglist_data *node_data[MAX_NUMNODES] __read_mostly;
 EXPORT_SYMBOL(node_data);
@@ -122,6 +123,15 @@ void numa_store_cpu_info(unsigned int cpu)
 	map_cpu_to_node(cpu, numa_off ? 0 : cpu_to_node_map[cpu]);
 }
 
+void __init early_map_cpu_to_node(unsigned int cpu, int nid)
+{
+	/* fallback to node 0 */
+	if (nid < 0 || nid >= MAX_NUMNODES)
+		nid = 0;
+
+	cpu_to_node_map[cpu] = nid;
+}
+
 /**
  * numa_add_memblk - Set node id to memblk
  * @nid: NUMA node ID of the new memblk
@@ -383,5 +393,12 @@ static int __init dummy_numa_init(void)
  */
 void __init arm64_numa_init(void)
 {
+	if (!numa_off) {
+#ifdef CONFIG_OF_NUMA
+		if (!numa_init(of_numa_init))
+			return;
+#endif
+	}
+
 	numa_init(dummy_numa_init);
 }
-- 
1.8.1.4

