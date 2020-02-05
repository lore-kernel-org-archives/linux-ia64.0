From: Baoquan He <bhe@redhat.com>
Date: Wed, 05 Feb 2020 14:12:54 +0000
Subject: Re: [PATCH v6 08/10] mm/memory_hotplug: Don't check for "all holes" in shrink_zone_span()
Message-Id: <20200205141254.GD8965@MiWiFi-R3L-srv>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191006085646.5768-1-david@redhat.com>
 <20191006085646.5768-9-david@redhat.com>
 <20200204142516.GD26758@MiWiFi-R3L-srv>
 <e0006cc4-d448-89c6-38c0-51da7fc08715@redhat.com>
 <20200205124329.GE26758@MiWiFi-R3L-srv>
 <cd353848-301a-025d-dd66-44d76e1bbc44@redhat.com>
 <20200205133442.GC8965@MiWiFi-R3L-srv>
 <2868343a-745b-e2b6-7e78-d5649c00ee31@redhat.com>
In-Reply-To: <2868343a-745b-e2b6-7e78-d5649c00ee31@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-s390@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-sh@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wei Yang <richardw.yang@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>

On 02/05/20 at 02:38pm, David Hildenbrand wrote:
> On 05.02.20 14:34, Baoquan He wrote:
> > On 02/05/20 at 02:20pm, David Hildenbrand wrote:
> >> On 05.02.20 13:43, Baoquan He wrote:
> >>> On 02/04/20 at 03:42pm, David Hildenbrand wrote:
> >>>> On 04.02.20 15:25, Baoquan He wrote:
> >>>>> On 10/06/19 at 10:56am, David Hildenbrand wrote:
> >>>>>> If we have holes, the holes will automatically get detected and removed
> >>>>>> once we remove the next bigger/smaller section. The extra checks can
> >>>>>> go.
> >>>>>>
> >>>>>> Cc: Andrew Morton <akpm@linux-foundation.org>
> >>>>>> Cc: Oscar Salvador <osalvador@suse.de>
> >>>>>> Cc: Michal Hocko <mhocko@suse.com>
> >>>>>> Cc: David Hildenbrand <david@redhat.com>
> >>>>>> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> >>>>>> Cc: Dan Williams <dan.j.williams@intel.com>
> >>>>>> Cc: Wei Yang <richardw.yang@linux.intel.com>
> >>>>>> Signed-off-by: David Hildenbrand <david@redhat.com>
> >>>>>> ---
> >>>>>>  mm/memory_hotplug.c | 34 +++++++---------------------------
> >>>>>>  1 file changed, 7 insertions(+), 27 deletions(-)
> >>>>>>
> >>>>>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> >>>>>> index f294918f7211..8dafa1ba8d9f 100644
> >>>>>> --- a/mm/memory_hotplug.c
> >>>>>> +++ b/mm/memory_hotplug.c
> >>>>>> @@ -393,6 +393,9 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
> >>>>>>  		if (pfn) {
> >>>>>>  			zone->zone_start_pfn = pfn;
> >>>>>>  			zone->spanned_pages = zone_end_pfn - pfn;
> >>>>>> +		} else {
> >>>>>> +			zone->zone_start_pfn = 0;
> >>>>>> +			zone->spanned_pages = 0;
> >>>>>>  		}
> >>>>>>  	} else if (zone_end_pfn = end_pfn) {
> >>>>>>  		/*
> >>>>>> @@ -405,34 +408,11 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
> >>>>>>  					       start_pfn);
> >>>>>>  		if (pfn)
> >>>>>>  			zone->spanned_pages = pfn - zone_start_pfn + 1;
> >>>>>> +		else {
> >>>>>> +			zone->zone_start_pfn = 0;
> >>>>>> +			zone->spanned_pages = 0;
> >>>>>
> >>>>> Thinking in which case (zone_start_pfn != start_pfn) and it comes here.
> >>>>
> >>>> Could only happen in case the zone_start_pfn would have been "out of the
> >>>> zone already". If you ask me: unlikely :)
> >>>
> >>> Yeah, I also think it's unlikely to come here.
> >>>
> >>> The 'if (zone_start_pfn = start_pfn)' checking also covers the case
> >>> (zone_start_pfn = start_pfn && zone_end_pfn = end_pfn). So this
> >>> zone_start_pfn/spanned_pages resetting can be removed to avoid
> >>> confusion.
> >>
> >> At least I would find it more confusing without it (or want a comment
> >> explaining why this does not have to be handled and why the !pfn case is
> >> not possible).
> > 
> > I don't get why being w/o it will be more confusing, but it's OK since
> > it doesn't impact anything. 
> 
> Because we could actually BUG_ON(!pfn) here, right? Only having a "if
> (pfn)" leaves the reader wondering "why is the other case not handled".
> 
> > 
> >>
> >> Anyhow, that patch is already upstream and I don't consider this high
> >> priority. Thanks :)
> > 
> > Yeah, noticed you told Wei the status in another patch thread, I am fine
> > with it, just leave it to you to decide. Thanks.
> 
> I am fairly busy right now. Can you send a patch (double-checking and
> making this eventually unconditional?). Thanks!

Understood, sorry about the noise, David. I will think about this.
