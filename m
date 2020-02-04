From: Oscar Salvador <osalvador@suse.de>
Date: Tue, 04 Feb 2020 09:26:23 +0000
Subject: Re: [PATCH v6 09/10] mm/memory_hotplug: Drop local variables in shrink_zone_span()
Message-Id: <20200204092623.GD6494@linux>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191006085646.5768-1-david@redhat.com>
 <20191006085646.5768-10-david@redhat.com>
In-Reply-To: <20191006085646.5768-10-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-s390@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-sh@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wei Yang <richardw.yang@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org

On Sun, Oct 06, 2019 at 10:56:45AM +0200, David Hildenbrand wrote:
> Get rid of the unnecessary local variables.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Wei Yang <richardw.yang@linux.intel.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  mm/memory_hotplug.c | 15 ++++++---------
>  1 file changed, 6 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 8dafa1ba8d9f..843481bd507d 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -374,14 +374,11 @@ static unsigned long find_biggest_section_pfn(int nid, struct zone *zone,
>  static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
>  			     unsigned long end_pfn)
>  {
> -	unsigned long zone_start_pfn = zone->zone_start_pfn;
> -	unsigned long z = zone_end_pfn(zone); /* zone_end_pfn namespace clash */
> -	unsigned long zone_end_pfn = z;
>  	unsigned long pfn;
>  	int nid = zone_to_nid(zone);

We could also remove the nid, right?
AFAICS, the nid is only used in find_{smallest/biggest}_section_pfn so we could
place there as well.

Anyway, nothing to nit-pick about:

Reviewed-by: Oscar Salvador <osalvador@suse.de>

>  
>  	zone_span_writelock(zone);
> -	if (zone_start_pfn = start_pfn) {
> +	if (zone->zone_start_pfn = start_pfn) {
>  		/*
>  		 * If the section is smallest section in the zone, it need
>  		 * shrink zone->zone_start_pfn and zone->zone_spanned_pages.
> @@ -389,25 +386,25 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
>  		 * for shrinking zone.
>  		 */
>  		pfn = find_smallest_section_pfn(nid, zone, end_pfn,
> -						zone_end_pfn);
> +						zone_end_pfn(zone));
>  		if (pfn) {
> +			zone->spanned_pages = zone_end_pfn(zone) - pfn;
>  			zone->zone_start_pfn = pfn;
> -			zone->spanned_pages = zone_end_pfn - pfn;
>  		} else {
>  			zone->zone_start_pfn = 0;
>  			zone->spanned_pages = 0;
>  		}
> -	} else if (zone_end_pfn = end_pfn) {
> +	} else if (zone_end_pfn(zone) = end_pfn) {
>  		/*
>  		 * If the section is biggest section in the zone, it need
>  		 * shrink zone->spanned_pages.
>  		 * In this case, we find second biggest valid mem_section for
>  		 * shrinking zone.
>  		 */
> -		pfn = find_biggest_section_pfn(nid, zone, zone_start_pfn,
> +		pfn = find_biggest_section_pfn(nid, zone, zone->zone_start_pfn,
>  					       start_pfn);
>  		if (pfn)
> -			zone->spanned_pages = pfn - zone_start_pfn + 1;
> +			zone->spanned_pages = pfn - zone->zone_start_pfn + 1;
>  		else {
>  			zone->zone_start_pfn = 0;
>  			zone->spanned_pages = 0;
> -- 
> 2.21.0
> 

-- 
Oscar Salvador
SUSE L3
