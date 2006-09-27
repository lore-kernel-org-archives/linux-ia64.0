From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 27 Sep 2006 16:29:18 +0000
Subject: [PATCH] ia64: Fix HOTPLUG_CPU + !NUMA build
Message-Id: <200609271629.k8RGTIVU009390@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Non-NUMA case should be handled...

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Tony Luck <tony.luck@intel.com>

Index: linux-2.6.18/arch/ia64/kernel/topology.c
=================================--- linux-2.6.18.orig/arch/ia64/kernel/topology.c	2006-09-26 20:31:25.000000000 +0900
+++ linux-2.6.18/arch/ia64/kernel/topology.c	2006-09-26 20:34:03.000000000 +0900
@@ -36,10 +36,8 @@
 	 */
 	if (!can_cpei_retarget() && is_cpu_cpei_target(num))
 		sysfs_cpus[num].cpu.no_control = 1;
-#ifdef CONFIG_NUMA
 	map_cpu_to_node(num, node_cpuid[num].nid);
 #endif
-#endif
 
 	return register_cpu(&sysfs_cpus[num].cpu, num);
 }
Index: linux-2.6.18/include/asm-ia64/numa.h
=================================--- linux-2.6.18.orig/include/asm-ia64/numa.h	2006-09-26 20:31:25.000000000 +0900
+++ linux-2.6.18/include/asm-ia64/numa.h	2006-09-26 20:33:49.000000000 +0900
@@ -69,6 +69,8 @@
 
 
 #else /* !CONFIG_NUMA */
+#define map_cpu_to_node(cpu, nid)	do{}while(0)
+#define unmap_cpu_from_node(cpu, nid)	do{}while(0)
 
 #define paddr_to_nid(addr)	0
 
