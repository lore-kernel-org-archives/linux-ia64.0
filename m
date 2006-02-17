From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Fri, 17 Feb 2006 13:29:20 +0000
Subject: [PATCH: 007/012] Memory hotplug for new nodes v.2.(create sysfs for node (x86-64))
Message-Id: <20060217213414.4076.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, Joel Schopp <jschopp@austin.ibm.com>, Dave Hansen <haveblue@us.ibm.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, x86-64 Discuss <discuss@x86-64.org>


This patch is to use arch_register_node() on "x86-64".
x86-64 uses i386's topology.c Howerver, arch_register_node() is
written at include/asm-i386/node.c. x86-64 couldn't use it.

I suppose there is no reason that it must be defined as
inline function. So, I move it to topology.c.


Index: pgdat3/arch/i386/mach-default/topology.c
=================================--- pgdat3.orig/arch/i386/mach-default/topology.c	2005-10-28 12:04:38.000000000 +0900
+++ pgdat3/arch/i386/mach-default/topology.c	2006-02-17 16:17:30.000000000 +0900
@@ -69,6 +69,26 @@ EXPORT_SYMBOL(arch_unregister_cpu);
 
 struct i386_node node_devices[MAX_NUMNODES];
 
+int arch_register_node(int num)
+{
+	int p_node;
+	struct node *parent = NULL;
+
+	if (!node_online(num))
+		return 0;
+	p_node = parent_node(num);
+
+	if (p_node != num)
+		parent = &node_devices[p_node].node;
+
+	return register_node(&node_devices[num].node, num, parent);
+}
+
+void arch_unregister_node(int num)
+{
+	unregister_node(&node_devices[num].node);
+}
+
 static int __init topology_init(void)
 {
 	int i;
Index: pgdat3/include/asm-i386/node.h
=================================--- pgdat3.orig/include/asm-i386/node.h	2005-03-02 16:37:51.000000000 +0900
+++ pgdat3/include/asm-i386/node.h	2006-02-17 16:17:30.000000000 +0900
@@ -11,19 +11,6 @@ struct i386_node {
 	struct node node;
 };
 extern struct i386_node node_devices[MAX_NUMNODES];
-
-static inline int arch_register_node(int num){
-	int p_node;
-	struct node *parent = NULL;
-
-	if (!node_online(num))
-		return 0;
-	p_node = parent_node(num);
-
-	if (p_node != num)
-		parent = &node_devices[p_node].node;
-
-	return register_node(&node_devices[num].node, num, parent);
-}
+extern int arch_register_node(int);
 
 #endif /* _ASM_I386_NODE_H_ */

-- 
Yasunori Goto 


