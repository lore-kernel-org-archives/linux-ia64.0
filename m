From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Wed, 08 Mar 2006 13:43:12 +0000
Subject: [PATCH: 017/017](RFC) Memory hotplug for new nodes v.3. (arch_register_node() for ia64)
Message-Id: <20060308214141.0044.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Joel Schopp <jschopp@austin.ibm.com>, Dave Hansen <haveblue@us.ibm.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>


This is to create sysfs file for new node.
It adds arch specific functions 'arch_register_node()'
and 'arch_unregister_node()' to IA64 to call the generic
function 'register_node()' and 'unregister_node()' respectively.

(Each arch defines like sysfs_nodes[] to describe its nodes
 topology. I'm not sure they can be merged as generic code.)

Signed-off-by: Keiichiro Tokunaga <tokuanga.keiich@jp.fujitsu.com>
Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: pgdat6/arch/ia64/kernel/topology.c
=================================--- pgdat6.orig/arch/ia64/kernel/topology.c	2006-03-06 18:25:31.000000000 +0900
+++ pgdat6/arch/ia64/kernel/topology.c	2006-03-06 18:26:33.000000000 +0900
@@ -65,6 +65,21 @@ EXPORT_SYMBOL(arch_register_cpu);
 EXPORT_SYMBOL(arch_unregister_cpu);
 #endif /*CONFIG_HOTPLUG_CPU*/
 
+#ifdef CONFIG_NUMA
+int arch_register_node(int num)
+{
+	if (sysfs_nodes[num].sysdev.id = num)
+		return 0;
+
+	return register_node(&sysfs_nodes[num], num, 0);
+}
+
+void arch_unregister_node(int num)
+{
+	unregister_node(&sysfs_nodes[num]);
+	sysfs_nodes[num].sysdev.id = -1;
+}
+#endif
 
 static int __init topology_init(void)
 {
Index: pgdat6/include/asm-ia64/numa.h
=================================--- pgdat6.orig/include/asm-ia64/numa.h	2006-03-06 18:24:01.000000000 +0900
+++ pgdat6/include/asm-ia64/numa.h	2006-03-06 18:26:33.000000000 +0900
@@ -23,6 +23,9 @@
 
 #include <asm/mmzone.h>
 
+extern int arch_register_node(int num);
+extern void arch_unregister_node(int num);
+
 extern u8 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
 extern cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
 

-- 
Yasunori Goto 


