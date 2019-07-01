From: Michal Hocko <mhocko@kernel.org>
Date: Mon, 01 Jul 2019 07:42:02 +0000
Subject: Re: [PATCH v3 01/11] mm/memory_hotplug: Simplify and fix check_hotplug_memory_range()
Message-Id: <20190701074202.GB6376@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-2-david@redhat.com>
In-Reply-To: <20190527111152.16324-2-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-sh@vger.kernel.org, Mathieu Malaterre <malat@debian.org>, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, Arun KS <arunks@codeaurora.org>, Qian Cai <cai@lca.pw>, Wei Yang <richardw.yang@linux.intel.com>, Igor Mammedov <imammedo@redhat.com>, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>

[Sorry for a really late response]

On Mon 27-05-19 13:11:42, David Hildenbrand wrote:
> By converting start and size to page granularity, we actually ignore
> unaligned parts within a page instead of properly bailing out with an
> error.

I do not expect any code path would ever provide an unaligned address
and even if it did then rounding that to a pfn doesn't sound like a
terrible thing to do. Anyway this removes few lines so why not.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Mathieu Malaterre <malat@debian.org>
> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> Reviewed-by: Wei Yang <richardw.yang@linux.intel.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memory_hotplug.c | 11 +++--------
>  1 file changed, 3 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index e096c987d261..762887b2358b 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1051,16 +1051,11 @@ int try_online_node(int nid)
>  
>  static int check_hotplug_memory_range(u64 start, u64 size)
>  {
> -	unsigned long block_sz = memory_block_size_bytes();
> -	u64 block_nr_pages = block_sz >> PAGE_SHIFT;
> -	u64 nr_pages = size >> PAGE_SHIFT;
> -	u64 start_pfn = PFN_DOWN(start);
> -
>  	/* memory range must be block size aligned */
> -	if (!nr_pages || !IS_ALIGNED(start_pfn, block_nr_pages) ||
> -	    !IS_ALIGNED(nr_pages, block_nr_pages)) {
> +	if (!size || !IS_ALIGNED(start, memory_block_size_bytes()) ||
> +	    !IS_ALIGNED(size, memory_block_size_bytes())) {
>  		pr_err("Block size [%#lx] unaligned hotplug range: start %#llx, size %#llx",
> -		       block_sz, start, size);
> +		       memory_block_size_bytes(), start, size);
>  		return -EINVAL;
>  	}
>  
> -- 
> 2.20.1
> 

-- 
Michal Hocko
SUSE Labs
