From: Wei Yang <richard.weiyang@gmail.com>
Date: Tue, 04 Jun 2019 21:42:34 +0000
Subject: Re: [PATCH v3 07/11] mm/memory_hotplug: Create memory block devices after arch_add_memory()
Message-Id: <20190604214234.ltwtkcdoju2gxisx@master>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-8-david@redhat.com>
In-Reply-To: <20190527111152.16324-8-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, Arun KS <arunks@codeaurora.org>, Ingo Molnar <mingo@kernel.org>, linux-s390@vger.kernel.org, "Rafael J. Wysocki" <rafael@kernel.org>, Pavel Tatashin <pasha.tatashin@soleen.com>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Qian Cai <cai@lca.pw>, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>, Andrew Banman <andrew.banman@hpe.com>, Mathieu Malaterre <malat@debian.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, Igor Mammedov <imammedo@redhat.com>, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org

On Mon, May 27, 2019 at 01:11:48PM +0200, David Hildenbrand wrote:
>Only memory to be added to the buddy and to be onlined/offlined by
>user space using /sys/devices/system/memory/... needs (and should have!)
>memory block devices.
>
>Factor out creation of memory block devices. Create all devices after
>arch_add_memory() succeeded. We can later drop the want_memblock parameter,
>because it is now effectively stale.
>
>Only after memory block devices have been added, memory can be onlined
>by user space. This implies, that memory is not visible to user space at
>all before arch_add_memory() succeeded.
>
>While at it
>- use WARN_ON_ONCE instead of BUG_ON in moved unregister_memory()
>- introduce find_memory_block_by_id() to search via block id
>- Use find_memory_block_by_id() in init_memory_block() to catch
>  duplicates

Generally looks good to me besides two tiny comments.

>
>Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>Cc: "Rafael J. Wysocki" <rafael@kernel.org>
>Cc: David Hildenbrand <david@redhat.com>
>Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
>Cc: Andrew Morton <akpm@linux-foundation.org>
>Cc: Ingo Molnar <mingo@kernel.org>
>Cc: Andrew Banman <andrew.banman@hpe.com>
>Cc: Oscar Salvador <osalvador@suse.de>
>Cc: Michal Hocko <mhocko@suse.com>
>Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>Cc: Qian Cai <cai@lca.pw>
>Cc: Wei Yang <richard.weiyang@gmail.com>
>Cc: Arun KS <arunks@codeaurora.org>
>Cc: Mathieu Malaterre <malat@debian.org>
>Signed-off-by: David Hildenbrand <david@redhat.com>
>---
> drivers/base/memory.c  | 82 +++++++++++++++++++++++++++---------------
> include/linux/memory.h |  2 +-
> mm/memory_hotplug.c    | 15 ++++----
> 3 files changed, 63 insertions(+), 36 deletions(-)
>
>diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>index ac17c95a5f28..5a0370f0c506 100644
>--- a/drivers/base/memory.c
>+++ b/drivers/base/memory.c
>@@ -39,6 +39,11 @@ static inline int base_memory_block_id(int section_nr)
> 	return section_nr / sections_per_block;
> }
> 
>+static inline int pfn_to_block_id(unsigned long pfn)
>+{
>+	return base_memory_block_id(pfn_to_section_nr(pfn));
>+}
>+
> static int memory_subsys_online(struct device *dev);
> static int memory_subsys_offline(struct device *dev);
> 
>@@ -582,10 +587,9 @@ int __weak arch_get_memory_phys_device(unsigned long start_pfn)
>  * A reference for the returned object is held and the reference for the
>  * hinted object is released.
>  */
>-struct memory_block *find_memory_block_hinted(struct mem_section *section,
>-					      struct memory_block *hint)
>+static struct memory_block *find_memory_block_by_id(int block_id,
>+						    struct memory_block *hint)
> {
>-	int block_id = base_memory_block_id(__section_nr(section));
> 	struct device *hintdev = hint ? &hint->dev : NULL;
> 	struct device *dev;
> 
>@@ -597,6 +601,14 @@ struct memory_block *find_memory_block_hinted(struct mem_section *section,
> 	return to_memory_block(dev);
> }
> 
>+struct memory_block *find_memory_block_hinted(struct mem_section *section,
>+					      struct memory_block *hint)
>+{
>+	int block_id = base_memory_block_id(__section_nr(section));
>+
>+	return find_memory_block_by_id(block_id, hint);
>+}
>+
> /*
>  * For now, we have a linear search to go find the appropriate
>  * memory_block corresponding to a particular phys_index. If
>@@ -658,6 +670,11 @@ static int init_memory_block(struct memory_block **memory, int block_id,
> 	unsigned long start_pfn;
> 	int ret = 0;
> 
>+	mem = find_memory_block_by_id(block_id, NULL);
>+	if (mem) {
>+		put_device(&mem->dev);
>+		return -EEXIST;
>+	}

find_memory_block_by_id() is not that close to the main idea in this patch.
Would it be better to split this part?

> 	mem = kzalloc(sizeof(*mem), GFP_KERNEL);
> 	if (!mem)
> 		return -ENOMEM;
>@@ -699,44 +716,53 @@ static int add_memory_block(int base_section_nr)
> 	return 0;
> }
> 
>+static void unregister_memory(struct memory_block *memory)
>+{
>+	if (WARN_ON_ONCE(memory->dev.bus != &memory_subsys))
>+		return;
>+
>+	/* drop the ref. we got via find_memory_block() */
>+	put_device(&memory->dev);
>+	device_unregister(&memory->dev);
>+}
>+
> /*
>- * need an interface for the VM to add new memory regions,
>- * but without onlining it.
>+ * Create memory block devices for the given memory area. Start and size
>+ * have to be aligned to memory block granularity. Memory block devices
>+ * will be initialized as offline.
>  */
>-int hotplug_memory_register(int nid, struct mem_section *section)
>+int create_memory_block_devices(unsigned long start, unsigned long size)
> {
>-	int block_id = base_memory_block_id(__section_nr(section));
>-	int ret = 0;
>+	const int start_block_id = pfn_to_block_id(PFN_DOWN(start));
>+	int end_block_id = pfn_to_block_id(PFN_DOWN(start + size));
> 	struct memory_block *mem;
>+	unsigned long block_id;
>+	int ret = 0;
> 
>-	mutex_lock(&mem_sysfs_mutex);
>+	if (WARN_ON_ONCE(!IS_ALIGNED(start, memory_block_size_bytes()) ||
>+			 !IS_ALIGNED(size, memory_block_size_bytes())))
>+		return -EINVAL;
> 
>-	mem = find_memory_block(section);
>-	if (mem) {
>-		mem->section_count++;
>-		put_device(&mem->dev);
>-	} else {
>+	mutex_lock(&mem_sysfs_mutex);
>+	for (block_id = start_block_id; block_id != end_block_id; block_id++) {
> 		ret = init_memory_block(&mem, block_id, MEM_OFFLINE);
> 		if (ret)
>-			goto out;
>-		mem->section_count++;
>+			break;
>+		mem->section_count = sections_per_block;
>+	}
>+	if (ret) {
>+		end_block_id = block_id;
>+		for (block_id = start_block_id; block_id != end_block_id;
>+		     block_id++) {
>+			mem = find_memory_block_by_id(block_id, NULL);
>+			mem->section_count = 0;
>+			unregister_memory(mem);
>+		}
> 	}

Would it be better to do this in reverse order?

And unregister_memory() would free mem, so it is still necessary to set
section_count to 0?

>-
>-out:
> 	mutex_unlock(&mem_sysfs_mutex);
> 	return ret;
> }
> 
>-static void
>-unregister_memory(struct memory_block *memory)
>-{
>-	BUG_ON(memory->dev.bus != &memory_subsys);
>-
>-	/* drop the ref. we got via find_memory_block() */
>-	put_device(&memory->dev);
>-	device_unregister(&memory->dev);
>-}
>-
> void unregister_memory_section(struct mem_section *section)
> {
> 	struct memory_block *mem;
>diff --git a/include/linux/memory.h b/include/linux/memory.h
>index 474c7c60c8f2..db3e8567f900 100644
>--- a/include/linux/memory.h
>+++ b/include/linux/memory.h
>@@ -111,7 +111,7 @@ extern int register_memory_notifier(struct notifier_block *nb);
> extern void unregister_memory_notifier(struct notifier_block *nb);
> extern int register_memory_isolate_notifier(struct notifier_block *nb);
> extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
>-int hotplug_memory_register(int nid, struct mem_section *section);
>+int create_memory_block_devices(unsigned long start, unsigned long size);
> extern void unregister_memory_section(struct mem_section *);
> extern int memory_dev_init(void);
> extern int memory_notify(unsigned long val, void *v);
>diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>index 4b9d2974f86c..b1fde90bbf19 100644
>--- a/mm/memory_hotplug.c
>+++ b/mm/memory_hotplug.c
>@@ -259,13 +259,7 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
> 		return -EEXIST;
> 
> 	ret = sparse_add_one_section(nid, phys_start_pfn, altmap);
>-	if (ret < 0)
>-		return ret;
>-
>-	if (!want_memblock)
>-		return 0;
>-
>-	return hotplug_memory_register(nid, __pfn_to_section(phys_start_pfn));
>+	return ret < 0 ? ret : 0;
> }
> 
> /*
>@@ -1107,6 +1101,13 @@ int __ref add_memory_resource(int nid, struct resource *res)
> 	if (ret < 0)
> 		goto error;
> 
>+	/* create memory block devices after memory was added */
>+	ret = create_memory_block_devices(start, size);
>+	if (ret) {
>+		arch_remove_memory(nid, start, size, NULL);
>+		goto error;
>+	}
>+
> 	if (new_node) {
> 		/* If sysfs file of new node can't be created, cpu on the node
> 		 * can't be hot-added. There is no rollback way now.
>-- 
>2.20.1

-- 
Wei Yang
Help you, Help me
