From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 17 Oct 2003 18:25:53 +0000
Subject: [PATCH] fix topology init take 2
Message-Id: <marc-linux-ia64-106641524132220@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Populate topology directories correctly now that NUMA kernels work.

Jesse

diff -Nru a/arch/ia64/mm/numa.c b/arch/ia64/mm/numa.c
--- a/arch/ia64/mm/numa.c	Fri Oct 17 11:24:49 2003
+++ b/arch/ia64/mm/numa.c	Fri Oct 17 11:24:49 2003
@@ -11,12 +11,19 @@
  */
 
 #include <linux/config.h>
+#include <linux/cpu.h>
 #include <linux/kernel.h>
+#include <linux/memblk.h>
 #include <linux/mm.h>
+#include <linux/node.h>
 #include <linux/init.h>
 #include <linux/bootmem.h>
 #include <asm/numa.h>
 
+static struct memblk *sysfs_memblks;
+static struct node *sysfs_nodes;
+static struct cpu *sysfs_cpus;
+
 /*
  * The following structures are usually initialized by ACPI or
  * similar mechanisms and describe the NUMA characteristics of the machine.
@@ -43,3 +50,49 @@
 
 	return (i < num_memblks) ? node_memblk[i].nid : (num_memblks ? -1 : 0);
 }
+
+static int __init topology_init(void)
+{
+	int i, err = 0;
+
+	sysfs_nodes = kmalloc(sizeof(struct node) * numnodes, GFP_KERNEL);
+	if (!sysfs_nodes) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	sysfs_memblks = kmalloc(sizeof(struct memblk) * num_memblks,
+				GFP_KERNEL);
+	if (!sysfs_memblks) {
+		kfree(sysfs_nodes);
+		err = -ENOMEM;
+		goto out;
+	}
+
+	sysfs_cpus = kmalloc(sizeof(struct cpu) * NR_CPUS, GFP_KERNEL);
+	if (!sysfs_cpus) {
+		kfree(sysfs_memblks);
+		kfree(sysfs_nodes);
+		err = -ENOMEM;
+		goto out;
+	}
+
+	for (i = 0; i < numnodes; i++)
+		if ((err = register_node(&sysfs_nodes[i], i, 0)))
+			goto out;
+	
+	for (i = 0; i < num_memblks; i++)
+		if ((err = register_memblk(&sysfs_memblks[i], i,
+					   &sysfs_nodes[memblk_to_node(i)])))
+			goto out;
+	
+	for (i = 0; i < NR_CPUS; i++)
+		if (cpu_online(i))
+			if((err = register_cpu(&sysfs_cpus[i], i,
+					       &sysfs_nodes[cpu_to_node(i)])))
+				goto out;
+ out:
+	return err;
+}
+
+__initcall(topology_init);
