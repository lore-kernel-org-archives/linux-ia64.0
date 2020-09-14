From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Mon, 14 Sep 2020 09:16:41 +0000
Subject: Re: [PATCH 2/3] mm: don't rely on system state to detect hot-plug operations
Message-Id: <9990141a-a4e7-6166-c7aa-e0c1199afa38@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200911134831.53258-1-ldufour@linux.ibm.com>
 <20200911134831.53258-3-ldufour@linux.ibm.com>
 <f50fe4ae-faf0-6e03-b87e-45ca8c53960d@redhat.com>
 <20200914081921.GA15113@linux>
 <96736256-a0a6-3126-3810-3380532b9621@redhat.com>
In-Reply-To: <96736256-a0a6-3126-3810-3380532b9621@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, "Rafael J . Wysocki" <rafael@kernel.org>, nathanl@linux.ibm.com, cheloha@linux.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Michal Hocko <mhocko@suse.com>

Le 14/09/2020 à 10:31, David Hildenbrand a écrit :
>>> static int register_mem_sect_under_node_hotplug(struct memory_block *mem_blk,
>>> 						void *arg)
>>> {
>>> 	const int nid = *(int *)arg;
>>> 	int ret;
>>>
>>> 	/* Hotplugged memory has no holes and belongs to a single node. */
>>> 	mem_blk->nid = nid;
>>> 	ret = sysfs_create_link_nowarn(&node_devices[nid]->dev.kobj,
>>> 				       &mem_blk->dev.kobj,
>>> 				       kobject_name(&mem_blk->dev.kobj));
>>> 	if (ret)
>>> 		returnr et;
>>> 	return sysfs_create_link_nowarn(&mem_blk->dev.kobj,
>>> 					&node_devices[nid]->dev.kobj,
>>> 					kobject_name(&node_devices[nid]->dev.kobj));
>>>
>>> }
>>>
>>> Cleaner, right? :) No unnecessary checks.
>>
>> I tend to agree here, I like more a simplistic version for hotplug.
>>
> 
> ... and while we're at it, we should rename register_mem_sect_under_node
> to something like "register_memory_block_under_node" - "section" is a
> legacy leftover here.
> 
> We could factor out both sysfs_create_link_nowarn() calls into something
> like "do_register_memory_block_under_node" or similar, to minimize code
> duplication.
> 
>>> One could argue if link_mem_section_hotplug() would be better than passing around the context.
>>
>> I am not sure if I would duplicate the code there.
>> We could just pass the pointer of the function we want to call to
>> link_mem_sections? either register_mem_sect_under_node_hotplug or
>> register_mem_sect_under_node_early?
>> Would not that be clean and clear enough?
> 
> I don't particularly like passing around function pointers where it can
> be avoided (e.g., here exporting 3 functions now instead 1). Makes the
> interface harder to get IMHO. But I don't really care about that
> interface, easy to change later on.
>

This would lead to the following.

Do everyone agree?

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 508b80f6329b..444808a7c9b6 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -761,9 +761,32 @@ static int __ref get_nid_for_pfn(unsigned long pfn)
  	return pfn_to_nid(pfn);
  }

+static int do_register_memory_block_under_node(int nid,
+					       struct memory_block *mem_blk)
+{
+	int ret;
+
+	/*
+	 * If this memory block spans multiple nodes, we only indicate
+	 * the last processed node.
+	 */
+	mem_blk->nid = nid;
+
+	ret = sysfs_create_link_nowarn(&node_devices[nid]->dev.kobj,
+				       &mem_blk->dev.kobj,
+				       kobject_name(&mem_blk->dev.kobj));
+	if (ret)
+		return ret;
+
+	return sysfs_create_link_nowarn(&mem_blk->dev.kobj,
+				&node_devices[nid]->dev.kobj,
+				kobject_name(&node_devices[nid]->dev.kobj));
+
+}
+
  /* register memory section under specified node if it spans that node */
-static int register_mem_sect_under_node(struct memory_block *mem_blk,
-					 void *arg)
+static int register_mem_block_under_node_early(struct memory_block *mem_blk,
+					       void *arg)
  {
  	unsigned long memory_block_pfns = memory_block_size_bytes() / PAGE_SIZE;
  	unsigned long start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
@@ -785,38 +808,35 @@ static int register_mem_sect_under_node(struct 
memory_block *mem_blk,
  		}

  		/*
-		 * We need to check if page belongs to nid only for the boot
-		 * case, during hotplug we know that all pages in the memory
-		 * block belong to the same node.
+		 * We need to check if page belongs to nid only at the boot
+		 * case because node's ranges can be interleaved.
  		 */
-		if (system_state = SYSTEM_BOOTING) {
-			page_nid = get_nid_for_pfn(pfn);
-			if (page_nid < 0)
-				continue;
-			if (page_nid != nid)
-				continue;
-		}
-
-		/*
-		 * If this memory block spans multiple nodes, we only indicate
-		 * the last processed node.
-		 */
-		mem_blk->nid = nid;
+		page_nid = get_nid_for_pfn(pfn);
+		if (page_nid < 0)
+			continue;
+		if (page_nid != nid)
+			continue;

-		ret = sysfs_create_link_nowarn(&node_devices[nid]->dev.kobj,
-					&mem_blk->dev.kobj,
-					kobject_name(&mem_blk->dev.kobj));
+		ret = do_register_memory_block_under_node(nid, mem_blk);
  		if (ret)
  			return ret;
-
-		return sysfs_create_link_nowarn(&mem_blk->dev.kobj,
-				&node_devices[nid]->dev.kobj,
-				kobject_name(&node_devices[nid]->dev.kobj));
  	}
  	/* mem section does not span the specified node */
  	return 0;
  }

+/*
+ * During hotplug we know that all pages in the memory block belong to the same
+ * node.
+ */
+static int register_mem_block_under_node_hotplug(struct memory_block *mem_blk,
+						 void *arg)
+{
+	int nid = *(int *)arg;
+
+	return do_register_memory_block_under_node(nid, mem_blk);
+}
+
  /*
   * Unregister a memory block device under the node it spans. Memory blocks
   * with multiple nodes cannot be offlined and therefore also never be removed.
@@ -832,11 +852,19 @@ void unregister_memory_block_under_nodes(struct 
memory_block *mem_blk)
  			  kobject_name(&node_devices[mem_blk->nid]->dev.kobj));
  }

-int link_mem_sections(int nid, unsigned long start_pfn, unsigned long end_pfn)
+int link_mem_sections(int nid, unsigned long start_pfn, unsigned long end_pfn,
+		      enum memplug_context context)
  {
+	walk_memory_blocks_func_t func;
+
+	if (context = MEMPLUG_HOTPLUG)
+		func = register_mem_block_under_node_hotplug;
+	else
+		func = register_mem_block_under_node_early;
+
  	return walk_memory_blocks(PFN_PHYS(start_pfn),
  				  PFN_PHYS(end_pfn - start_pfn), (void *)&nid,
-				  register_mem_sect_under_node);
+				  func);
  }

  #ifdef CONFIG_HUGETLBFS
