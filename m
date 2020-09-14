From: David Hildenbrand <david@redhat.com>
Date: Mon, 14 Sep 2020 17:10:46 +0000
Subject: Re: [PATCH v2 1/3] mm: replace memmap_context by memplug_context
Message-Id: <d6ade681-2fb1-a1df-5673-bceacd1dfc55@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200914165042.96218-1-ldufour@linux.ibm.com>
 <20200914165042.96218-2-ldufour@linux.ibm.com>
In-Reply-To: <20200914165042.96218-2-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Laurent Dufour <ldufour@linux.ibm.com>, akpm@linux-foundation.org, Oscar Salvador <osalvador@suse.de>, mhocko@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-mm@kvack.org, "Rafael J . Wysocki" <rafael@kernel.org>, nathanl@linux.ibm.com, cheloha@linux.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On 14.09.20 18:50, Laurent Dufour wrote:
> The memmap_context is used to detect whether a memory operation is due to a
> hot-add operation or happening at boot time.
> 
> Make it general to the hotplug operation and rename it at memplug_context.
> 
> There is no functional change introduced by this patch
> 
> Suggested-by: David Hildenbrand <david@redhat.com>
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
> ---
>  arch/ia64/mm/init.c    |  6 +++---
>  include/linux/mm.h     |  2 +-
>  include/linux/mmzone.h | 11 ++++++++---
>  mm/memory_hotplug.c    |  2 +-
>  mm/page_alloc.c        | 10 +++++-----
>  5 files changed, 18 insertions(+), 13 deletions(-)
> 
> diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
> index 0b3fb4c7af29..b5054b5e77c8 100644
> --- a/arch/ia64/mm/init.c
> +++ b/arch/ia64/mm/init.c
> @@ -538,7 +538,7 @@ virtual_memmap_init(u64 start, u64 end, void *arg)
>  	if (map_start < map_end)
>  		memmap_init_zone((unsigned long)(map_end - map_start),
>  				 args->nid, args->zone, page_to_pfn(map_start),
> -				 MEMMAP_EARLY, NULL);
> +				 MEMPLUG_EARLY, NULL);

I am pretty sure that won't compile (MEMINIT_EARLY).

(same at other places)


-- 
Thanks,

David / dhildenb
