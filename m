From: Oscar Salvador <osalvador@suse.de>
Date: Tue, 04 Feb 2020 09:13:12 +0000
Subject: Re: [PATCH v6 08/10] mm/memory_hotplug: Don't check for "all holes" in shrink_zone_span()
Message-Id: <20200204091312.GC6494@linux>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191006085646.5768-1-david@redhat.com>
 <20191006085646.5768-9-david@redhat.com>
In-Reply-To: <20191006085646.5768-9-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-s390@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-sh@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wei Yang <richardw.yang@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org

On Sun, Oct 06, 2019 at 10:56:44AM +0200, David Hildenbrand wrote:
> If we have holes, the holes will automatically get detected and removed
> once we remove the next bigger/smaller section. The extra checks can
> go.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Wei Yang <richardw.yang@linux.intel.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Heh, I have been here before.
I have to confess that when I wrote my version of this I was not really 100%
about removing it, because hotplug was a sort of a "catchall" for all sort of weird
and corner-cases configurations, but thinking more about it, I cannot think of
any situation that would make this blow up.

Reviewed-by: Oscar Salvador <osalvador@suse.de>

> ---
>  mm/memory_hotplug.c | 34 +++++++---------------------------
>  1 file changed, 7 insertions(+), 27 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index f294918f7211..8dafa1ba8d9f 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -393,6 +393,9 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
>  		if (pfn) {
>  			zone->zone_start_pfn = pfn;
>  			zone->spanned_pages = zone_end_pfn - pfn;
> +		} else {
> +			zone->zone_start_pfn = 0;
> +			zone->spanned_pages = 0;
>  		}
>  	} else if (zone_end_pfn = end_pfn) {
>  		/*
> @@ -405,34 +408,11 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
>  					       start_pfn);
>  		if (pfn)
>  			zone->spanned_pages = pfn - zone_start_pfn + 1;
> +		else {
> +			zone->zone_start_pfn = 0;
> +			zone->spanned_pages = 0;
> +		}
>  	}
> -
> -	/*
> -	 * The section is not biggest or smallest mem_section in the zone, it
> -	 * only creates a hole in the zone. So in this case, we need not
> -	 * change the zone. But perhaps, the zone has only hole data. Thus
> -	 * it check the zone has only hole or not.
> -	 */
> -	pfn = zone_start_pfn;
> -	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SUBSECTION) {
> -		if (unlikely(!pfn_to_online_page(pfn)))
> -			continue;
> -
> -		if (page_zone(pfn_to_page(pfn)) != zone)
> -			continue;
> -
> -		/* Skip range to be removed */
> -		if (pfn >= start_pfn && pfn < end_pfn)
> -			continue;
> -
> -		/* If we find valid section, we have nothing to do */
> -		zone_span_writeunlock(zone);
> -		return;
> -	}
> -
> -	/* The zone has no valid section */
> -	zone->zone_start_pfn = 0;
> -	zone->spanned_pages = 0;
>  	zone_span_writeunlock(zone);
>  }
>  
> -- 
> 2.21.0
> 

-- 
Oscar Salvador
SUSE L3
