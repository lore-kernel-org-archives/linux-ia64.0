From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Wed, 08 Mar 2006 13:42:38 +0000
Subject: [PATCH: 011/017](RFC) Memory hotplug for new nodes v.3. (start kswapd)
Message-Id: <20060308213333.0038.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Joel Schopp <jschopp@austin.ibm.com>, Dave Hansen <haveblue@us.ibm.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>

When node is hot-added, kswapd for the node should start.
This export kswapd start function as kswapd_run().


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: pgdat6/mm/vmscan.c
=================================--- pgdat6.orig/mm/vmscan.c	2006-03-06 18:25:37.000000000 +0900
+++ pgdat6/mm/vmscan.c	2006-03-06 18:26:25.000000000 +0900
@@ -35,6 +35,7 @@
 #include <linux/notifier.h>
 #include <linux/rwsem.h>
 #include <linux/delay.h>
+#include <linux/kthread.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -1842,17 +1843,36 @@ static int __devinit cpu_callback(struct
 }
 #endif /* CONFIG_HOTPLUG_CPU */
 
+/*
+ * This kswapd start function will be called by init anod node-hot-add.
+ * On node-hot-add, kswapd will moved to proper cpus if cpus are hot-added.
+ */
+int kswapd_run(int nid)
+{
+	pg_data_t *pgdat = NODE_DATA(nid);
+	int ret = 0;
+
+	if (pgdat->kswapd)
+		return 0;
+
+	pgdat->kswapd = kthread_run(kswapd, pgdat, "kswapd%d", nid);
+	if (pgdat->kswapd = ERR_PTR(-ENOMEM)) {
+		/* failure at boot is fatal */
+		BUG_ON(system_state = SYSTEM_BOOTING);
+		printk("faled to run kswapd on node %d\n",nid);
+		ret = -1;
+	}
+	return ret;
+}
+EXPORT_SYMBOL(kswapd_run);
+
 static int __init kswapd_init(void)
 {
-	pg_data_t *pgdat;
+	int nid;
 
 	swap_setup();
-	for_each_online_pgdat(pgdat) {
-		pid_t pid;
-
-		pid = kernel_thread(kswapd, pgdat, CLONE_KERNEL);
-		BUG_ON(pid < 0);
-		pgdat->kswapd = find_task_by_pid(pid);
+	for_each_online_node(nid) {
+		kswapd_run(nid);
 	}
 	total_memory = nr_free_pagecache_pages();
 	hotcpu_notifier(cpu_callback, 0);
Index: pgdat6/include/linux/swap.h
=================================--- pgdat6.orig/include/linux/swap.h	2006-03-06 18:25:37.000000000 +0900
+++ pgdat6/include/linux/swap.h	2006-03-06 18:26:25.000000000 +0900
@@ -208,6 +208,11 @@ static inline int migrate_pages(struct l
 #define fail_migrate_page NULL
 #endif
 
+#ifdef CONFIG_MEMORY_HOTPLUG
+/* start new kswapd for new node */
+extern int kswapd_run(int nid);
+#endif
+
 #ifdef CONFIG_MMU
 /* linux/mm/shmem.c */
 extern int shmem_unuse(swp_entry_t entry, struct page *page);

-- 
Yasunori Goto 


