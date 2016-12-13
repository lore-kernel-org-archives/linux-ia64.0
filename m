From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Date: Tue, 13 Dec 2016 04:18:29 +0000
Subject: [PATCH v2] ACPI/NUMA: Do not map pxm to node when NUMA is turned off
Message-Id: <1481602709-18260-1-git-send-email-boris.ostrovsky@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: catalin.marinas@arm.com, will.deacon@arm.com, tony.luck@intel.com, fenghua.yu@intel.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, rjw@rjwysocki.net, lenb@kernel.org
Cc: x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>

Otherwise we may unexpectedly reference a non-zero node via, for example,
acpi_get_node() while other parts of the kernel assume that only node 0
(which is what NUMA_NO_NODE is supposed to be converted to) is
available.

Signed-off-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
---
V2:
* Drop __initdata from x86's numa_off 
* Make numa_off available to drivers/acpi/numa.c for arm64 and IA64 

 arch/arm64/include/asm/numa.h | 2 ++
 arch/arm64/mm/numa.c          | 2 +-
 arch/ia64/include/asm/numa.h  | 2 ++
 arch/x86/mm/numa.c            | 2 +-
 drivers/acpi/numa.c           | 2 +-
 5 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/include/asm/numa.h b/arch/arm64/include/asm/numa.h
index 600887e..bf466d1 100644
--- a/arch/arm64/include/asm/numa.h
+++ b/arch/arm64/include/asm/numa.h
@@ -15,6 +15,8 @@
 
 extern nodemask_t numa_nodes_parsed __initdata;
 
+extern bool numa_off;
+
 /* Mappings between node number and cpus on that node. */
 extern cpumask_var_t node_to_cpumask_map[MAX_NUMNODES];
 void numa_clear_node(unsigned int cpu);
diff --git a/arch/arm64/mm/numa.c b/arch/arm64/mm/numa.c
index 4b32168..b388a99 100644
--- a/arch/arm64/mm/numa.c
+++ b/arch/arm64/mm/numa.c
@@ -35,7 +35,7 @@
 
 static int numa_distance_cnt;
 static u8 *numa_distance;
-static bool numa_off;
+bool numa_off;
 
 static __init int numa_parse_early_param(char *opt)
 {
diff --git a/arch/ia64/include/asm/numa.h b/arch/ia64/include/asm/numa.h
index 2db0a6c..ebef7f4 100644
--- a/arch/ia64/include/asm/numa.h
+++ b/arch/ia64/include/asm/numa.h
@@ -65,6 +65,8 @@ struct node_cpuid_s {
 
 #define local_nodeid (cpu_to_node_map[smp_processor_id()])
 
+#define numa_off     0
+
 extern void map_cpu_to_node(int cpu, int nid);
 extern void unmap_cpu_from_node(int cpu, int nid);
 extern void numa_clear_node(int cpu);
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 3f35b48..12dcad7 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -19,7 +19,7 @@
 
 #include "numa_internal.h"
 
-int __initdata numa_off;
+int numa_off;
 nodemask_t numa_nodes_parsed __initdata;
 
 struct pglist_data *node_data[MAX_NUMNODES] __read_mostly;
diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index ce3a7a1..edb0c79 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -70,7 +70,7 @@ int acpi_map_pxm_to_node(int pxm)
 {
 	int node;
 
-	if (pxm < 0 || pxm >= MAX_PXM_DOMAINS)
+	if (pxm < 0 || pxm >= MAX_PXM_DOMAINS || numa_off)
 		return NUMA_NO_NODE;
 
 	node = pxm_to_node_map[pxm];
-- 
1.8.3.1

