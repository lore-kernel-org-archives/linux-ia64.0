From: Baoquan He <bhe@redhat.com>
Date: Wed, 05 Feb 2020 12:43:29 +0000
Subject: Re: [PATCH v6 08/10] mm/memory_hotplug: Don't check for "all holes" in shrink_zone_span()
Message-Id: <20200205124329.GE26758@MiWiFi-R3L-srv>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191006085646.5768-1-david@redhat.com>
 <20191006085646.5768-9-david@redhat.com>
 <20200204142516.GD26758@MiWiFi-R3L-srv>
 <e0006cc4-d448-89c6-38c0-51da7fc08715@redhat.com>
In-Reply-To: <e0006cc4-d448-89c6-38c0-51da7fc08715@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-s390@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-sh@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wei Yang <richardw.yang@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>

On 02/04/20 at 03:42pm, David Hildenbrand wrote:
> On 04.02.20 15:25, Baoquan He wrote:
> > On 10/06/19 at 10:56am, David Hildenbrand wrote:
> >> If we have holes, the holes will automatically get detected and removed
> >> once we remove the next bigger/smaller section. The extra checks can
> >> go.
> >>
> >> Cc: Andrew Morton <akpm@linux-foundation.org>
> >> Cc: Oscar Salvador <osalvador@suse.de>
> >> Cc: Michal Hocko <mhocko@suse.com>
> >> Cc: David Hildenbrand <david@redhat.com>
> >> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> >> Cc: Dan Williams <dan.j.williams@intel.com>
> >> Cc: Wei Yang <richardw.yang@linux.intel.com>
> >> Signed-off-by: David Hildenbrand <david@redhat.com>
> >> ---
> >>  mm/memory_hotplug.c | 34 +++++++---------------------------
> >>  1 file changed, 7 insertions(+), 27 deletions(-)
> >>
> >> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> >> index f294918f7211..8dafa1ba8d9f 100644
> >> --- a/mm/memory_hotplug.c
> >> +++ b/mm/memory_hotplug.c
> >> @@ -393,6 +393,9 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
> >>  		if (pfn) {
> >>  			zone->zone_start_pfn = pfn;
> >>  			zone->spanned_pages = zone_end_pfn - pfn;
> >> +		} else {
> >> +			zone->zone_start_pfn = 0;
> >> +			zone->spanned_pages = 0;
> >>  		}
> >>  	} else if (zone_end_pfn = end_pfn) {
> >>  		/*
> >> @@ -405,34 +408,11 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
> >>  					       start_pfn);
> >>  		if (pfn)
> >>  			zone->spanned_pages = pfn - zone_start_pfn + 1;
> >> +		else {
> >> +			zone->zone_start_pfn = 0;
> >> +			zone->spanned_pages = 0;
> > 
> > Thinking in which case (zone_start_pfn != start_pfn) and it comes here.
> 
> Could only happen in case the zone_start_pfn would have been "out of the
> zone already". If you ask me: unlikely :)

Yeah, I also think it's unlikely to come here.

The 'if (zone_start_pfn = start_pfn)' checking also covers the case
(zone_start_pfn = start_pfn && zone_end_pfn = end_pfn). So this
zone_start_pfn/spanned_pages resetting can be removed to avoid
confusion.
