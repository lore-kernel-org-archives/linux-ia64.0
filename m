From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 20 Oct 2003 20:35:37 +0000
Subject: [PATCH] zero out topology related sysfs nodes
Message-Id: <marc-linux-ia64-106668318400859@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony pointed out (thanks Tony!) that in -test8 kobject_set_name() will
try to free a kobject's k_name field if it's non-NULL, so we need to
zero it out in case kmalloc() gave us recycled memory or we'll try to
kfree a bogus area.

Jesse

 -Nru a/arch/ia64/mm/numa.c b/arch/ia64/mm/numa.c
--- a/arch/ia64/mm/numa.c	Mon Oct 20 13:23:40 2003
+++ b/arch/ia64/mm/numa.c	Mon Oct 20 13:23:40 2003
@@ -60,6 +60,7 @@
 		err = -ENOMEM;
 		goto out;
 	}
+	memset(sysfs_nodes, 0, sizeof(struct node) * numnodes);
 
 	sysfs_memblks = kmalloc(sizeof(struct memblk) * num_memblks,
 				GFP_KERNEL);
@@ -68,6 +69,7 @@
 		err = -ENOMEM;
 		goto out;
 	}
+	memset(sysfs_memblks, 0, sizeof(struct memblk) * num_memblks);
 
 	sysfs_cpus = kmalloc(sizeof(struct cpu) * NR_CPUS, GFP_KERNEL);
 	if (!sysfs_cpus) {
@@ -76,6 +78,7 @@
 		err = -ENOMEM;
 		goto out;
 	}
+	memset(sysfs_cpus, 0, sizeof(struct cpu) * NR_CPUS);
 
 	for (i = 0; i < numnodes; i++)
 		if ((err = register_node(&sysfs_nodes[i], i, 0)))
