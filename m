From: Oscar Salvador <osalvador@suse.de>
Date: Tue, 04 Feb 2020 09:06:22 +0000
Subject: Re: [PATCH v6 07/10] mm/memory_hotplug: We always have a zone in find_(smallest|biggest)_section_pfn
Message-Id: <20200204090622.GB6494@linux>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191006085646.5768-1-david@redhat.com>
 <20191006085646.5768-8-david@redhat.com>
In-Reply-To: <20191006085646.5768-8-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-s390@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-sh@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wei Yang <richardw.yang@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org

On Sun, Oct 06, 2019 at 10:56:43AM +0200, David Hildenbrand wrote:
> With shrink_pgdat_span() out of the way, we now always have a valid
> zone.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Wei Yang <richardw.yang@linux.intel.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

> ---
>  mm/memory_hotplug.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index bf5173e7913d..f294918f7211 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -337,7 +337,7 @@ static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
>  		if (unlikely(pfn_to_nid(start_pfn) != nid))
>  			continue;
>  
> -		if (zone && zone != page_zone(pfn_to_page(start_pfn)))
> +		if (zone != page_zone(pfn_to_page(start_pfn)))
>  			continue;
>  
>  		return start_pfn;
> @@ -362,7 +362,7 @@ static unsigned long find_biggest_section_pfn(int nid, struct zone *zone,
>  		if (unlikely(pfn_to_nid(pfn) != nid))
>  			continue;
>  
> -		if (zone && zone != page_zone(pfn_to_page(pfn)))
> +		if (zone != page_zone(pfn_to_page(pfn)))
>  			continue;
>  
>  		return pfn;
> -- 
> 2.21.0
> 

-- 
Oscar Salvador
SUSE L3
