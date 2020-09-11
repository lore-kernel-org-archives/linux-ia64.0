From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Fri, 11 Sep 2020 13:48:31 +0000
Subject: [PATCH 3/3] mm: don't panic when links can't be created in sysfs
Message-Id: <20200911134831.53258-4-ldufour@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200911134831.53258-1-ldufour@linux.ibm.com>
In-Reply-To: <20200911134831.53258-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org, David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>, mhocko@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-mm@kvack.org, "Rafael J . Wysocki" <rafael@kernel.org>, nathanl@linux.ibm.com, cheloha@linux.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

At boot time, or when doing memory hot-add operations, if the links in
sysfs can't be created, the system is still able to run, so just report the
error in the kernel log.

Since the number of memory blocks managed could be high, the messages are
rate limited.

As a consequence, link_mem_sections() has no status to report anymore.

Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
Cc: David Hildenbrand <david@redhat.com>
---
 drivers/base/node.c  | 25 +++++++++++++++++--------
 include/linux/node.h | 17 ++++++++---------
 mm/memory_hotplug.c  |  5 ++---
 3 files changed, 27 insertions(+), 20 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 862516c5a5ae..749a1c8ea992 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -811,12 +811,21 @@ static int register_mem_sect_under_node(struct memory_block *mem_blk,
 		ret = sysfs_create_link_nowarn(&node_devices[nid]->dev.kobj,
 					&mem_blk->dev.kobj,
 					kobject_name(&mem_blk->dev.kobj));
-		if (ret)
-			return ret;
+		if (ret && ret != -EEXIST)
+			pr_err_ratelimited(
+				"can't create %s to %s link in sysfs (%d)\n",
+				kobject_name(&node_devices[nid]->dev.kobj),
+				kobject_name(&mem_blk->dev.kobj), ret);
 
-		return sysfs_create_link_nowarn(&mem_blk->dev.kobj,
+		ret = sysfs_create_link_nowarn(&mem_blk->dev.kobj,
 				&node_devices[nid]->dev.kobj,
 				kobject_name(&node_devices[nid]->dev.kobj));
+		if (ret && ret != -EEXIST)
+			pr_err_ratelimited(
+				"can't create %s to %s link in sysfs (%d)\n",
+				kobject_name(&mem_blk->dev.kobj),
+				kobject_name(&node_devices[nid]->dev.kobj),
+				ret);
 	}
 	/* mem section does not span the specified node */
 	return 0;
@@ -837,17 +846,17 @@ void unregister_memory_block_under_nodes(struct memory_block *mem_blk)
 			  kobject_name(&node_devices[mem_blk->nid]->dev.kobj));
 }
 
-int link_mem_sections(int nid, unsigned long start_pfn, unsigned long end_pfn,
-		      enum memplug_context context)
+void link_mem_sections(int nid, unsigned long start_pfn, unsigned long end_pfn,
+		       enum memplug_context context)
 {
 	struct rmsun_args args = {
 		.nid = nid,
 		.context = context,
 	};
 
-	return walk_memory_blocks(PFN_PHYS(start_pfn),
-				  PFN_PHYS(end_pfn - start_pfn), (void *)&args,
-				  register_mem_sect_under_node);
+	walk_memory_blocks(PFN_PHYS(start_pfn),
+			   PFN_PHYS(end_pfn - start_pfn), (void *)&args,
+			   register_mem_sect_under_node);
 }
 
 #ifdef CONFIG_HUGETLBFS
diff --git a/include/linux/node.h b/include/linux/node.h
index 8ff08520488c..6bdd6f3ed3aa 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -99,15 +99,14 @@ extern struct node *node_devices[];
 typedef  void (*node_registration_func_t)(struct node *);
 
 #if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_NUMA)
-extern int link_mem_sections(int nid, unsigned long start_pfn,
-			     unsigned long end_pfn,
-			     enum memplug_context context);
+void link_mem_sections(int nid, unsigned long start_pfn,
+		       unsigned long end_pfn,
+		       enum memplug_context context);
 #else
-static inline int link_mem_sections(int nid, unsigned long start_pfn,
-				    unsigned long end_pfn,
-				    enum memplug_context context)
+static inline void link_mem_sections(int nid, unsigned long start_pfn,
+				     unsigned long end_pfn,
+				     enum memplug_context context)
 {
-	return 0;
 }
 #endif
 
@@ -130,8 +129,8 @@ static inline int register_one_node(int nid)
 		if (error)
 			return error;
 		/* link memory sections under this node */
-		error = link_mem_sections(nid, start_pfn, end_pfn,
-					  MEMPLUG_EARLY);
+		link_mem_sections(nid, start_pfn, end_pfn,
+				  MEMPLUG_EARLY);
 	}
 
 	return error;
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 912d355ca446..668418071a49 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1080,9 +1080,8 @@ int __ref add_memory_resource(int nid, struct resource *res)
 	}
 
 	/* link memory sections under this node.*/
-	ret = link_mem_sections(nid, PFN_DOWN(start), PFN_UP(start + size - 1),
-				MEMPLUG_HOTPLUG);
-	BUG_ON(ret);
+	link_mem_sections(nid, PFN_DOWN(start), PFN_UP(start + size - 1),
+			  MEMPLUG_HOTPLUG);
 
 	/* create new memmap entry */
 	if (!strcmp(res->name, "System RAM"))
-- 
2.28.0
