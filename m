From: Alex Williamson <alex.williamson@hp.com>
Date: Wed, 22 Oct 2003 21:46:21 +0000
Subject: [PATCH] trivial ia64 numa/discontig fixes
Message-Id: <marc-linux-ia64-106685936312275@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   I stumbled on a couple trivial bugs in ia64 numa/discontig support. 
The first just sets the default number of nodes to something reasonable
for a generic kernel, otherwise it's really easy to start walking over
your initdata (more error checking should probably be added).  The
second fixes a memcpy to a physical address.  Patch below, please
apply.  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

--- linux-2.5/include/asm-ia64/numnodes.h	Wed Oct 22 15:14:03 2003
+++ linux-2.5/include/asm-ia64/numnodes.h	Wed Oct 22 13:26:08 2003
@@ -4,7 +4,7 @@
 #ifdef CONFIG_IA64_DIG
 /* Max 8 Nodes */
 #define NODES_SHIFT	3
-#elif defined(CONFIG_IA64_SGI_SN2)
+#elif defined(CONFIG_IA64_SGI_SN2) || defined(CONFIG_IA64_GENERIC)
 /* Max 128 Nodes */
 #define NODES_SHIFT	7
 #endif
--- linux-2.5/arch/ia64/mm/discontig.c	Wed Oct 22 15:13:48 2003
+++ linux-2.5/arch/ia64/mm/discontig.c	Wed Oct 22 15:16:42 2003
@@ -186,7 +186,7 @@
 			 */
 			for (cpu = 0; cpu < NR_CPUS; cpu++) {
 				if (node = node_cpuid[cpu].nid) {
-					memcpy(cpu_data, __phys_per_cpu_start,
+					memcpy(__va(cpu_data), __phys_per_cpu_start,
 					       __per_cpu_end-__per_cpu_start);
 					__per_cpu_offset[cpu]  						(char*)__va(cpu_data) -


