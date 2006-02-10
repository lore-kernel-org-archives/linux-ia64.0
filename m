From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Fri, 10 Feb 2006 14:21:09 +0000
Subject: [RFC/PATCH: 005/010] Memory hotplug for new nodes with pgdat allocation. (create sysfs for node (ia6
Message-Id: <20060210224338.C53A.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>, "Luck, Tony" <tony.luck@intel.com>, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, x86-64 Discuss <discuss@x86-64.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>


'register_node()' is to create sysfs file for node.
This is to add arch specific functions 'arch_register_node()'
and 'arch_unregister_node()' to IA64 to call the generic
function 'register_node()' and 'unregister_node()' respectively.

Other archtectures needs like this code, but I've not 
made for them yet.

Signed-off-by: Keiichiro Tokunaga <tokuanga.keiich@jp.fujitsu.com>
Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: pgdat2/arch/ia64/kernel/topology.c
=================================--- pgdat2.orig/arch/ia64/kernel/topology.c	2006-02-10 11:30:48.000000000 +0900
+++ pgdat2/arch/ia64/kernel/topology.c	2006-02-10 14:06:59.000000000 +0900
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
Index: pgdat2/include/asm-ia64/numa.h
=================================--- pgdat2.orig/include/asm-ia64/numa.h	2005-03-02 16:37:55.000000000 +0900
+++ pgdat2/include/asm-ia64/numa.h	2006-02-10 14:06:59.000000000 +0900
@@ -23,6 +23,9 @@
 
 #include <asm/mmzone.h>
 
+extern int arch_register_node(int num);
+extern void arch_unregister_node(int num);
+
 extern u8 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
 extern cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
 

-- 
Yasunori Goto 


