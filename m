From: Zi Yan <zi.yan@sent.com>
Date: Thu, 06 May 2021 15:26:19 +0000
Subject: [RFC PATCH 3/7] mm: memory_hotplug: decouple memory_block size with section size.
Message-Id: <20210506152623.178731-4-zi.yan@sent.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210506152623.178731-1-zi.yan@sent.com>
In-Reply-To: <20210506152623.178731-1-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Wei Yang <richard.weiyang@linux.alibaba.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Zi Yan <ziy@nvidia.com>

From: Zi Yan <ziy@nvidia.com>

To enable subsection memory online/offline, we need to remove the
assumption of memory_block size being greater or equal to section size.

The following changes are made:
1. use (start_pfn, nr_pages) pair to specify memory_block size instead of
   start_section_nr.
2. calculate memory_block id using phys / memory_block_size_bytes()
   instead of section number.

The memory_block minimum size is set to the smaller of 128MB (the old
x86_64 section size) and section size instead.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 drivers/base/memory.c  | 176 ++++++++++++++++++++---------------------
 drivers/base/node.c    |   2 +-
 include/linux/memory.h |   8 +-
 mm/memory_hotplug.c    |   6 +-
 4 files changed, 98 insertions(+), 94 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index b31b3af5c490..141431eb64a4 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -50,19 +50,15 @@ int mhp_online_type_from_str(const char *str)
 
 static int sections_per_block;
 
-static inline unsigned long memory_block_id(unsigned long section_nr)
+static inline unsigned long phys_to_block_id(unsigned long phys)
 {
-	return section_nr / sections_per_block;
+	return phys / memory_block_size_bytes();
 }
 
 static inline unsigned long pfn_to_block_id(unsigned long pfn)
 {
-	return memory_block_id(pfn_to_section_nr(pfn));
-}
-
-static inline unsigned long phys_to_block_id(unsigned long phys)
-{
-	return pfn_to_block_id(PFN_DOWN(phys));
+	/* calculate using memory_block_size_bytes() */
+	return phys_to_block_id(PFN_PHYS(pfn));
 }
 
 static int memory_subsys_online(struct device *dev);
@@ -118,7 +114,7 @@ static ssize_t phys_index_show(struct device *dev,
 	struct memory_block *mem = to_memory_block(dev);
 	unsigned long phys_index;
 
-	phys_index = mem->start_section_nr / sections_per_block;
+	phys_index = pfn_to_section_nr(mem->start_pfn);
 
 	return sysfs_emit(buf, "%08lx\n", phys_index);
 }
@@ -171,8 +167,8 @@ int memory_notify(unsigned long val, void *v)
 
 static int memory_block_online(struct memory_block *mem)
 {
-	unsigned long start_pfn = section_nr_to_pfn(mem->start_section_nr);
-	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
+	unsigned long start_pfn = mem->start_pfn;
+	unsigned long nr_pages = mem->nr_pages;
 	unsigned long nr_vmemmap_pages = mem->nr_vmemmap_pages;
 	struct zone *zone;
 	int ret;
@@ -212,8 +208,8 @@ static int memory_block_online(struct memory_block *mem)
 
 static int memory_block_offline(struct memory_block *mem)
 {
-	unsigned long start_pfn = section_nr_to_pfn(mem->start_section_nr);
-	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
+	unsigned long start_pfn = mem->start_pfn;
+	unsigned long nr_pages = mem->nr_pages;
 	unsigned long nr_vmemmap_pages = mem->nr_vmemmap_pages;
 	struct zone *zone;
 	int ret;
@@ -260,7 +256,7 @@ memory_block_action(struct memory_block *mem, unsigned long action)
 		break;
 	default:
 		WARN(1, KERN_WARNING "%s(%ld, %ld) unknown action: "
-		     "%ld\n", __func__, mem->start_section_nr, action, action);
+		     "%ld\n", __func__, mem->start_pfn, mem->nr_pages, action);
 		ret = -EINVAL;
 	}
 
@@ -366,7 +362,7 @@ static ssize_t phys_device_show(struct device *dev,
 				struct device_attribute *attr, char *buf)
 {
 	struct memory_block *mem = to_memory_block(dev);
-	unsigned long start_pfn = section_nr_to_pfn(mem->start_section_nr);
+	unsigned long start_pfn = mem->start_pfn;
 
 	return sysfs_emit(buf, "%d\n",
 			  arch_get_memory_phys_device(start_pfn));
@@ -390,8 +386,8 @@ static ssize_t valid_zones_show(struct device *dev,
 				struct device_attribute *attr, char *buf)
 {
 	struct memory_block *mem = to_memory_block(dev);
-	unsigned long start_pfn = section_nr_to_pfn(mem->start_section_nr);
-	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
+	unsigned long start_pfn = mem->start_pfn;
+	unsigned long nr_pages = mem->nr_pages;
 	struct zone *default_zone;
 	int len = 0;
 	int nid;
@@ -575,16 +571,6 @@ static struct memory_block *find_memory_block_by_id(unsigned long block_id)
 	return mem;
 }
 
-/*
- * Called under device_hotplug_lock.
- */
-struct memory_block *find_memory_block(struct mem_section *section)
-{
-	unsigned long block_id = memory_block_id(__section_nr(section));
-
-	return find_memory_block_by_id(block_id);
-}
-
 static struct attribute *memory_memblk_attrs[] = {
 	&dev_attr_phys_index.attr,
 	&dev_attr_state.attr,
@@ -614,7 +600,7 @@ int register_memory(struct memory_block *memory)
 	int ret;
 
 	memory->dev.bus = &memory_subsys;
-	memory->dev.id = memory->start_section_nr / sections_per_block;
+	memory->dev.id = memory->start_pfn / (memory_block_size_bytes() >> PAGE_SHIFT);
 	memory->dev.release = memory_block_release;
 	memory->dev.groups = memory_memblk_attr_groups;
 	memory->dev.offline = memory->state == MEM_OFFLINE;
@@ -633,57 +619,89 @@ int register_memory(struct memory_block *memory)
 	return ret;
 }
 
-static int init_memory_block(unsigned long block_id, unsigned long state,
+static void unregister_memory(struct memory_block *memory)
+{
+	if (WARN_ON_ONCE(memory->dev.bus != &memory_subsys))
+		return;
+
+	WARN_ON(xa_erase(&memory_blocks, memory->dev.id) == NULL);
+
+	/* drop the ref. we got via find_memory_block() */
+	put_device(&memory->dev);
+	device_unregister(&memory->dev);
+}
+
+static int init_memory_blocks(unsigned long start_pfn, unsigned long num_pages, unsigned long state,
 			     unsigned long nr_vmemmap_pages)
 {
 	struct memory_block *mem;
 	int ret = 0;
+	unsigned long block_nr_pages = memory_block_size_bytes() / PAGE_SIZE;
+	unsigned long block_start_pfn;
 
-	mem = find_memory_block_by_id(block_id);
-	if (mem) {
-		put_device(&mem->dev);
-		return -EEXIST;
-	}
-	mem = kzalloc(sizeof(*mem), GFP_KERNEL);
-	if (!mem)
-		return -ENOMEM;
-
-	mem->start_section_nr = block_id * sections_per_block;
-	mem->state = state;
-	mem->nid = NUMA_NO_NODE;
-	mem->nr_vmemmap_pages = nr_vmemmap_pages;
+	for (block_start_pfn = start_pfn; num_pages != 0; block_start_pfn += block_nr_pages) {
+		unsigned long block_id = pfn_to_block_id(block_start_pfn);
 
-	ret = register_memory(mem);
-
-	return ret;
+		mem = find_memory_block_by_id(block_id);
+		if (mem) {
+			put_device(&mem->dev);
+			return -EEXIST;
+		}
+		mem = kzalloc(sizeof(*mem), GFP_KERNEL);
+		if (!mem)
+			return -ENOMEM;
+
+		mem->start_pfn = block_start_pfn;
+		mem->nr_pages = min(num_pages, block_nr_pages);
+		mem->state = state;
+		mem->nid = NUMA_NO_NODE;
+		mem->nr_vmemmap_pages = nr_vmemmap_pages;
+
+		ret = register_memory(mem);
+
+		if (ret) {
+			unsigned long unregister_block_pfn;
+
+			for (unregister_block_pfn = start_pfn;
+			     unregister_block_pfn < block_start_pfn;
+			     unregister_block_pfn -= block_nr_pages) {
+				block_id = pfn_to_block_id(unregister_block_pfn);
+				mem = find_memory_block_by_id(block_id);
+				if (WARN_ON_ONCE(!mem))
+					continue;
+				unregister_memory(mem);
+			}
+			return -EINVAL;
+		}
+		if (num_pages > block_nr_pages)
+			num_pages -= block_nr_pages;
+		else
+			num_pages = 0;
+	}
+	return 0;
 }
 
-static int add_memory_block(unsigned long base_section_nr)
+static void add_whole_section_memory_block(unsigned long base_section_nr)
 {
-	int section_count = 0;
-	unsigned long nr;
+	int ret;
+	unsigned long start_pfn = section_nr_to_pfn(base_section_nr);
+	unsigned long nr_pages = 0;
+	struct mem_section *ms = __nr_to_section(base_section_nr);
 
-	for (nr = base_section_nr; nr < base_section_nr + sections_per_block;
-	     nr++)
-		if (present_section_nr(nr))
-			section_count++;
+	if (bitmap_full(ms->usage->subsection_map, SUBSECTIONS_PER_SECTION))
+		nr_pages = PAGES_PER_SECTION;
+	else
+		nr_pages = PAGES_PER_SUBSECTION *
+			bitmap_weight(ms->usage->subsection_map, SUBSECTIONS_PER_SECTION);
 
-	if (section_count == 0)
-		return 0;
-	return init_memory_block(memory_block_id(base_section_nr),
-				 MEM_ONLINE, 0);
-}
 
-static void unregister_memory(struct memory_block *memory)
-{
-	if (WARN_ON_ONCE(memory->dev.bus != &memory_subsys))
+	if (!nr_pages)
 		return;
 
-	WARN_ON(xa_erase(&memory_blocks, memory->dev.id) == NULL);
-
-	/* drop the ref. we got via find_memory_block() */
-	put_device(&memory->dev);
-	device_unregister(&memory->dev);
+	ret = init_memory_blocks(start_pfn, nr_pages, MEM_ONLINE, 0);
+	if (ret)
+		panic("%s() failed to add memory block: %d\n", __func__,
+		      ret);
 }
 
 /*
@@ -696,31 +714,16 @@ static void unregister_memory(struct memory_block *memory)
 int create_memory_block_devices(unsigned long start, unsigned long size,
 				unsigned long vmemmap_pages)
 {
-	const unsigned long start_block_id = pfn_to_block_id(PFN_DOWN(start));
-	unsigned long end_block_id = pfn_to_block_id(PFN_DOWN(start + size));
-	struct memory_block *mem;
-	unsigned long block_id;
+	unsigned long start_pfn = PFN_DOWN(start);
+	unsigned long end_pfn = PFN_DOWN(start + size);
 	int ret = 0;
 
 	if (WARN_ON_ONCE(!IS_ALIGNED(start, memory_block_size_bytes()) ||
 			 !IS_ALIGNED(size, memory_block_size_bytes())))
 		return -EINVAL;
 
-	for (block_id = start_block_id; block_id != end_block_id; block_id++) {
-		ret = init_memory_block(block_id, MEM_OFFLINE, vmemmap_pages);
-		if (ret)
-			break;
-	}
-	if (ret) {
-		end_block_id = block_id;
-		for (block_id = start_block_id; block_id != end_block_id;
-		     block_id++) {
-			mem = find_memory_block_by_id(block_id);
-			if (WARN_ON_ONCE(!mem))
-				continue;
-			unregister_memory(mem);
-		}
-	}
+	ret = init_memory_blocks(start_pfn, end_pfn - start_pfn, MEM_OFFLINE, vmemmap_pages);
+
 	return ret;
 }
 
@@ -807,10 +810,7 @@ void __init memory_dev_init(void)
 	 */
 	for (nr = 0; nr <= __highest_present_section_nr;
 	     nr += sections_per_block) {
-		ret = add_memory_block(nr);
-		if (ret)
-			panic("%s() failed to add memory block: %d\n", __func__,
-			      ret);
+		add_whole_section_memory_block(nr);
 	}
 }
 
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 2c36f61d30bc..76d67b8ddf1b 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -809,7 +809,7 @@ static int register_mem_block_under_node_early(struct memory_block *mem_blk,
 					       void *arg)
 {
 	unsigned long memory_block_pfns = memory_block_size_bytes() / PAGE_SIZE;
-	unsigned long start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
+	unsigned long start_pfn = mem_blk->start_pfn;
 	unsigned long end_pfn = start_pfn + memory_block_pfns - 1;
 	int nid = *(int *)arg;
 	unsigned long pfn;
diff --git a/include/linux/memory.h b/include/linux/memory.h
index 97e92e8b556a..e9590c7c6a9e 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -21,10 +21,15 @@
 #include <linux/mutex.h>
 #include <linux/notifier.h>
 
+#if SECTION_SIZE_BITS > 27  /* 128MB */
+#define MIN_MEMORY_BLOCK_SIZE     (1UL << 27)
+#else
 #define MIN_MEMORY_BLOCK_SIZE     (1UL << SECTION_SIZE_BITS)
+#endif
 
 struct memory_block {
-	unsigned long start_section_nr;
+	unsigned long start_pfn;
+	unsigned long nr_pages;
 	unsigned long state;		/* serialized by the dev->lock */
 	int online_type;		/* for passing data to online routine */
 	int nid;			/* NID for this memory block */
@@ -90,7 +95,6 @@ int create_memory_block_devices(unsigned long start, unsigned long size,
 void remove_memory_block_devices(unsigned long start, unsigned long size);
 extern void memory_dev_init(void);
 extern int memory_notify(unsigned long val, void *v);
-extern struct memory_block *find_memory_block(struct mem_section *);
 typedef int (*walk_memory_blocks_func_t)(struct memory_block *, void *);
 extern int walk_memory_blocks(unsigned long start, unsigned long size,
 			      void *arg, walk_memory_blocks_func_t func);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 70620d0dd923..6e93b0ecc5cb 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1872,8 +1872,8 @@ static int check_memblock_offlined_cb(struct memory_block *mem, void *arg)
 	if (unlikely(ret)) {
 		phys_addr_t beginpa, endpa;
 
-		beginpa = PFN_PHYS(section_nr_to_pfn(mem->start_section_nr));
-		endpa = beginpa + memory_block_size_bytes() - 1;
+		beginpa = PFN_PHYS(mem->start_pfn);
+		endpa = beginpa + mem->nr_pages * PAGE_SIZE - 1;
 		pr_warn("removing memory fails, because memory [%pa-%pa] is onlined\n",
 			&beginpa, &endpa);
 
@@ -2079,7 +2079,7 @@ static int try_offline_memory_block(struct memory_block *mem, void *arg)
 	 * with multiple zones within one memory block will be rejected
 	 * by offlining code ... so we don't care about that.
 	 */
-	page = pfn_to_online_page(section_nr_to_pfn(mem->start_section_nr));
+	page = pfn_to_online_page(mem->start_pfn);
 	if (page && zone_idx(page_zone(page)) == ZONE_MOVABLE)
 		online_type = MMOP_ONLINE_MOVABLE;
 
-- 
2.30.2
