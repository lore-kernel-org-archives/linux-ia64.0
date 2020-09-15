From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Tue, 15 Sep 2020 09:41:43 +0000
Subject: [PATCH v3 3/3] mm: don't panic when links can't be created in sysfs
Message-Id: <20200915094143.79181-4-ldufour@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200915094143.79181-1-ldufour@linux.ibm.com>
In-Reply-To: <20200915094143.79181-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org, David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>, mhocko@suse.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-mm@kvack.org, "Rafael J . Wysocki" <rafael@kernel.org>, nathanl@linux.ibm.com, cheloha@linux.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

At boot time, or when doing memory hot-add operations, if the links in
sysfs can't be created, the system is still able to run, so just report the
error in the kernel log rather than BUG_ON and potentially make system
unusable because the callpath can be called with locks held.

Since the number of memory blocks managed could be high, the messages are
rate limited.

As a consequence, link_mem_sections() has no status to report anymore.

Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: David Hildenbrand <david@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/base/node.c  | 33 +++++++++++++++++++++------------
 include/linux/node.h | 16 +++++++---------
 mm/memory_hotplug.c  |  5 ++---
 3 files changed, 30 insertions(+), 24 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 50af16e68d98..9426b0f1f660 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -761,8 +761,8 @@ static int __ref get_nid_for_pfn(unsigned long pfn)
 	return pfn_to_nid(pfn);
 }
 
-static int do_register_memory_block_under_node(int nid,
-					       struct memory_block *mem_blk)
+static void do_register_memory_block_under_node(int nid,
+						struct memory_block *mem_blk)
 {
 	int ret;
 
@@ -775,12 +775,19 @@ static int do_register_memory_block_under_node(int nid,
 	ret = sysfs_create_link_nowarn(&node_devices[nid]->dev.kobj,
 				       &mem_blk->dev.kobj,
 				       kobject_name(&mem_blk->dev.kobj));
-	if (ret)
-		return ret;
+	if (ret && ret != -EEXIST)
+		dev_err_ratelimited(&node_devices[nid]->dev,
+				    "can't create link to %s in sysfs (%d)\n",
+				    kobject_name(&mem_blk->dev.kobj), ret);
 
-	return sysfs_create_link_nowarn(&mem_blk->dev.kobj,
+	ret = sysfs_create_link_nowarn(&mem_blk->dev.kobj,
 				&node_devices[nid]->dev.kobj,
 				kobject_name(&node_devices[nid]->dev.kobj));
+	if (ret && ret != -EEXIST)
+		dev_err_ratelimited(&mem_blk->dev,
+				    "can't create link to %s in sysfs (%d)\n",
+				    kobject_name(&node_devices[nid]->dev.kobj),
+				    ret);
 }
 
 /* register memory section under specified node if it spans that node */
@@ -816,7 +823,8 @@ static int register_mem_block_under_node_early(struct memory_block *mem_blk,
 		if (page_nid != nid)
 			continue;
 
-		return do_register_memory_block_under_node(nid, mem_blk);
+		do_register_memory_block_under_node(nid, mem_blk);
+		return 0;
 	}
 	/* mem section does not span the specified node */
 	return 0;
@@ -831,7 +839,8 @@ static int register_mem_block_under_node_hotplug(struct memory_block *mem_blk,
 {
 	int nid = *(int *)arg;
 
-	return do_register_memory_block_under_node(nid, mem_blk);
+	do_register_memory_block_under_node(nid, mem_blk);
+	return 0;
 }
 
 /*
@@ -849,8 +858,8 @@ void unregister_memory_block_under_nodes(struct memory_block *mem_blk)
 			  kobject_name(&node_devices[mem_blk->nid]->dev.kobj));
 }
 
-int link_mem_sections(int nid, unsigned long start_pfn, unsigned long end_pfn,
-		      enum meminit_context context)
+void link_mem_sections(int nid, unsigned long start_pfn, unsigned long end_pfn,
+		       enum meminit_context context)
 {
 	walk_memory_blocks_func_t func;
 
@@ -859,9 +868,9 @@ int link_mem_sections(int nid, unsigned long start_pfn, unsigned long end_pfn,
 	else
 		func = register_mem_block_under_node_early;
 
-	return walk_memory_blocks(PFN_PHYS(start_pfn),
-				  PFN_PHYS(end_pfn - start_pfn), (void *)&nid,
-				  func);
+	walk_memory_blocks(PFN_PHYS(start_pfn), PFN_PHYS(end_pfn - start_pfn),
+			   (void *)&nid, func);
+	return;
 }
 
 #ifdef CONFIG_HUGETLBFS
diff --git a/include/linux/node.h b/include/linux/node.h
index 014ba3ab2efd..8e5a29897936 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -99,15 +99,14 @@ extern struct node *node_devices[];
 typedef  void (*node_registration_func_t)(struct node *);
 
 #if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_NUMA)
-int link_mem_sections(int nid, unsigned long start_pfn,
-		      unsigned long end_pfn,
-		      enum meminit_context context);
+void link_mem_sections(int nid, unsigned long start_pfn,
+		       unsigned long end_pfn,
+		       enum meminit_context context);
 #else
-static inline int link_mem_sections(int nid, unsigned long start_pfn,
-				    unsigned long end_pfn,
-				    enum meminit_context context)
+static inline void link_mem_sections(int nid, unsigned long start_pfn,
+				     unsigned long end_pfn,
+				     enum meminit_context context)
 {
-	return 0;
 }
 #endif
 
@@ -130,8 +129,7 @@ static inline int register_one_node(int nid)
 		if (error)
 			return error;
 		/* link memory sections under this node */
-		error = link_mem_sections(nid, start_pfn, end_pfn,
-					  MEMINIT_EARLY);
+		link_mem_sections(nid, start_pfn, end_pfn, MEMINIT_EARLY);
 	}
 
 	return error;
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 03df20078827..01e01a530d38 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1080,9 +1080,8 @@ int __ref add_memory_resource(int nid, struct resource *res)
 	}
 
 	/* link memory sections under this node.*/
-	ret = link_mem_sections(nid, PFN_DOWN(start), PFN_UP(start + size - 1),
-				MEMINIT_HOTPLUG);
-	BUG_ON(ret);
+	link_mem_sections(nid, PFN_DOWN(start), PFN_UP(start + size - 1),
+			  MEMINIT_HOTPLUG);
 
 	/* create new memmap entry */
 	if (!strcmp(res->name, "System RAM"))
-- 
2.28.0
