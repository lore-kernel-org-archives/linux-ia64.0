From: David Hildenbrand <david@redhat.com>
Date: Mon, 14 Sep 2020 17:15:01 +0000
Subject: Re: [PATCH v2 2/3] mm: don't rely on system state to detect hot-plug operations
Message-Id: <c378a52b-ab7b-0cb9-cd34-68e20a9d02b0@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200914165042.96218-1-ldufour@linux.ibm.com>
 <20200914165042.96218-3-ldufour@linux.ibm.com>
In-Reply-To: <20200914165042.96218-3-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Laurent Dufour <ldufour@linux.ibm.com>, akpm@linux-foundation.org, Oscar Salvador <osalvador@suse.de>, mhocko@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-mm@kvack.org, "Rafael J . Wysocki" <rafael@kernel.org>, nathanl@linux.ibm.com, cheloha@linux.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Michal Hocko <mhocko@suse.com>

>  arch/ia64/mm/init.c  |  4 +--
>  drivers/base/node.c  | 86 ++++++++++++++++++++++++++++----------------
>  include/linux/node.h | 11 +++---
>  mm/memory_hotplug.c  |  5 +--
>  4 files changed, 68 insertions(+), 38 deletions(-)
> 
> diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
> index b5054b5e77c8..8e7b8c6c576e 100644
> --- a/arch/ia64/mm/init.c
> +++ b/arch/ia64/mm/init.c
> @@ -538,7 +538,7 @@ virtual_memmap_init(u64 start, u64 end, void *arg)
>  	if (map_start < map_end)
>  		memmap_init_zone((unsigned long)(map_end - map_start),
>  				 args->nid, args->zone, page_to_pfn(map_start),
> -				 MEMPLUG_EARLY, NULL);
> +				 MEMINIT_EARLY, NULL);

Patch #1.

>  	return 0;
>  }
>  
> @@ -548,7 +548,7 @@ memmap_init (unsigned long size, int nid, unsigned long zone,
>  {
>  	if (!vmem_map) {
>  		memmap_init_zone(size, nid, zone, start_pfn,
> -				 MEMPLUG_EARLY, NULL);
> +				 MEMINIT_EARLY, NULL);
>  	} else {
>  		struct page *start;
>  		struct memmap_init_callback_data args;
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 508b80f6329b..01ee73c9d675 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -761,14 +761,36 @@ static int __ref get_nid_for_pfn(unsigned long pfn)
>  	return pfn_to_nid(pfn);
>  }
>  
> +static int do_register_memory_block_under_node(int nid,
> +					       struct memory_block *mem_blk)
> +{
> +	int ret;
> +
> +	/*
> +	 * If this memory block spans multiple nodes, we only indicate
> +	 * the last processed node.
> +	 */
> +	mem_blk->nid = nid;
> +
> +	ret = sysfs_create_link_nowarn(&node_devices[nid]->dev.kobj,
> +				       &mem_blk->dev.kobj,
> +				       kobject_name(&mem_blk->dev.kobj));
> +	if (ret)
> +		return ret;
> +
> +	return sysfs_create_link_nowarn(&mem_blk->dev.kobj,
> +				&node_devices[nid]->dev.kobj,
> +				kobject_name(&node_devices[nid]->dev.kobj));
> +}
> +
>  /* register memory section under specified node if it spans that node */
> -static int register_mem_sect_under_node(struct memory_block *mem_blk,
> -					 void *arg)
> +static int register_mem_block_under_node_early(struct memory_block *mem_blk,
> +					       void *arg)
>  {
>  	unsigned long memory_block_pfns = memory_block_size_bytes() / PAGE_SIZE;
>  	unsigned long start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
>  	unsigned long end_pfn = start_pfn + memory_block_pfns - 1;
> -	int ret, nid = *(int *)arg;
> +	int nid = *(int *)arg;
>  	unsigned long pfn;
>  
>  	for (pfn = start_pfn; pfn <= end_pfn; pfn++) {
> @@ -785,38 +807,34 @@ static int register_mem_sect_under_node(struct memory_block *mem_blk,
>  		}
>  
>  		/*
> -		 * We need to check if page belongs to nid only for the boot
> -		 * case, during hotplug we know that all pages in the memory
> -		 * block belong to the same node.
> -		 */
> -		if (system_state = SYSTEM_BOOTING) {
> -			page_nid = get_nid_for_pfn(pfn);
> -			if (page_nid < 0)
> -				continue;
> -			if (page_nid != nid)
> -				continue;
> -		}
> -
> -		/*
> -		 * If this memory block spans multiple nodes, we only indicate
> -		 * the last processed node.
> +		 * We need to check if page belongs to nid only at the boot
> +		 * case because node's ranges can be interleaved.
>  		 */
> -		mem_blk->nid = nid;
> -
> -		ret = sysfs_create_link_nowarn(&node_devices[nid]->dev.kobj,
> -					&mem_blk->dev.kobj,
> -					kobject_name(&mem_blk->dev.kobj));
> -		if (ret)
> -			return ret;
> +		page_nid = get_nid_for_pfn(pfn);
> +		if (page_nid < 0)
> +			continue;
> +		if (page_nid != nid)
> +			continue;
>  
> -		return sysfs_create_link_nowarn(&mem_blk->dev.kobj,
> -				&node_devices[nid]->dev.kobj,
> -				kobject_name(&node_devices[nid]->dev.kobj));
> +		/* The memory block is registered to the first matching node */

That comment is misleading in that context.

A memory block is registered if there is at least a page that belongs to
the nid. It's perfectly fine to have a single memory block belong to
multiple NUMA nodes (when the split is within a memory block). I'd just
drop it.

[...]

-- 
Thanks,

David / dhildenb
