From: jbarnes@sgi.com (Jesse Barnes)
Date: Thu, 18 Dec 2003 20:11:10 +0000
Subject: [PATCH] make cpu_to_node_map unsigned
Message-Id: <marc-linux-ia64-107177935424572@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This small fix is needed for machines with more than 128 nodes.

Jesse

diff -Nru a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
--- a/arch/ia64/kernel/smpboot.c	Thu Dec 18 12:08:52 2003
+++ b/arch/ia64/kernel/smpboot.c	Thu Dec 18 12:08:52 2003
@@ -466,7 +466,7 @@
 #ifdef CONFIG_NUMA
 
 /* on which node is each logical CPU (one cacheline even for 64 CPUs) */
-volatile char cpu_to_node_map[NR_CPUS] __cacheline_aligned;
+volatile u8 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
 /* which logical CPUs are on which nodes */
 volatile cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
 
diff -Nru a/include/asm-ia64/numa.h b/include/asm-ia64/numa.h
--- a/include/asm-ia64/numa.h	Thu Dec 18 12:08:52 2003
+++ b/include/asm-ia64/numa.h	Thu Dec 18 12:08:52 2003
@@ -24,7 +24,7 @@
 
 #include <asm/mmzone.h>
 
-extern volatile char cpu_to_node_map[NR_CPUS] __cacheline_aligned;
+extern volatile u8 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
 extern volatile cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
 
 /* Stuff below this line could be architecture independent */
