From: Wei Yang <richardw.yang@linux.intel.com>
Date: Wed, 05 Feb 2020 22:56:33 +0000
Subject: Re: [PATCH v6 08/10] mm/memory_hotplug: Don't check for "all holes" in shrink_zone_span()
Message-Id: <20200205225633.GA28446@richard>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191006085646.5768-1-david@redhat.com>
 <20191006085646.5768-9-david@redhat.com>
 <20200205095924.GC24162@richard>
 <20200205144811.GF26758@MiWiFi-R3L-srv>
In-Reply-To: <20200205144811.GF26758@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Baoquan He <bhe@redhat.com>
Cc: linux-s390@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, Pavel Tatashin <pasha.tatashin@soleen.com>, David Hildenbrand <david@redhat.com>, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Wei Yang <richardw.yang@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>

On Wed, Feb 05, 2020 at 10:48:11PM +0800, Baoquan He wrote:
>Hi Wei Yang,
>
>On 02/05/20 at 05:59pm, Wei Yang wrote:
>> >diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> >index f294918f7211..8dafa1ba8d9f 100644
>> >--- a/mm/memory_hotplug.c
>> >+++ b/mm/memory_hotplug.c
>> >@@ -393,6 +393,9 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
>> > 		if (pfn) {
>> > 			zone->zone_start_pfn = pfn;
>> > 			zone->spanned_pages = zone_end_pfn - pfn;
>> >+		} else {
>> >+			zone->zone_start_pfn = 0;
>> >+			zone->spanned_pages = 0;
>> > 		}
>> > 	} else if (zone_end_pfn = end_pfn) {
>> > 		/*
>> >@@ -405,34 +408,11 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
>> > 					       start_pfn);
>> > 		if (pfn)
>> > 			zone->spanned_pages = pfn - zone_start_pfn + 1;
>> >+		else {
>> >+			zone->zone_start_pfn = 0;
>> >+			zone->spanned_pages = 0;
>> >+		}
>> > 	}
>> 
>> If it is me, I would like to take out these two similar logic out.
>
>I also like this style. 
>> 
>> For example:
>> 
>> 	if () {
>> 	} else if () {
>> 	} else {
>> 		goto out;
>Here the last else is unnecessary, right?
>

I am afraid not.

If the range is not the first or last, we would leave pfn not initialized.


-- 
Wei Yang
Help you, Help me
