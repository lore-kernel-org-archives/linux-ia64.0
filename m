From: Jack Steiner <steiner@sgi.com>
Date: Wed, 05 Nov 2003 19:44:17 +0000
Subject: [PATCH] - Increase max number of nodes (cpu_to_node_map)
Message-Id: <marc-linux-ia64-106806288024897@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I hit a problem with systems having > 256 nodes. The
cpu_to_node_map array is an array of char - needs to be 
bigger.

Here is a patch that changes it to a short.



--- linux_base/arch/ia64/kernel/smpboot.c	Wed Nov  5 08:39:40 2003
+++ linux/arch/ia64/kernel/smpboot.c	Wed Nov  5 12:30:12 2003
@@ -466,7 +466,7 @@
 #ifdef CONFIG_NUMA
 
 /* on which node is each logical CPU (one cacheline even for 64 CPUs) */
-volatile char cpu_to_node_map[NR_CPUS] __cacheline_aligned;
+volatile short cpu_to_node_map[NR_CPUS] __cacheline_aligned;
 /* which logical CPUs are on which nodes */
 volatile cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
 
--- linux_base/include/asm-ia64/numa.h	Wed Nov  5 12:49:18 2003
+++ linux/include/asm-ia64/numa.h	Wed Nov  5 12:31:04 2003
@@ -24,7 +24,7 @@
 
 #include <asm/mmzone.h>
 
-extern volatile char cpu_to_node_map[NR_CPUS] __cacheline_aligned;
+extern volatile short cpu_to_node_map[NR_CPUS] __cacheline_aligned;
 extern volatile cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
 
 /* Stuff below this line could be architecture independent */




-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


