From: David Hildenbrand <david@redhat.com>
Date: Tue, 03 Dec 2019 15:27:12 +0000
Subject: Re: [PATCH v6 05/10] mm/memory_hotplug: Shrink zones when offlining memory
Message-Id: <9789e892-dd15-c37d-7c0a-0ccb4db1a987@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191006085646.5768-1-david@redhat.com>
 <20191006085646.5768-6-david@redhat.com> <20191203151030.GB2600@linux>
In-Reply-To: <20191203151030.GB2600@linux>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oscar Salvador <osalvador@suse.de>
Cc: linux-s390@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-sh@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, x86@kernel.org, linux-kernel@vger.kernel.org, "Matthew Wilcox (Oracle)" <willy@infradead.org>, linux-mm@kvack.org, Logan Gunthorpe <logang@deltatee.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org

On 03.12.19 16:10, Oscar Salvador wrote:
> On Sun, Oct 06, 2019 at 10:56:41AM +0200, David Hildenbrand wrote:
>> Fixes: d0dc12e86b31 ("mm/memory_hotplug: optimize memory hotplug")
>> Signed-off-by: David Hildenbrand <david@redhat.com>
> 
> I did not see anything wrong with the taken approach, and makes sense to me.
> The only thing that puzzles me is we seem to not balance spanned_pages
> for ZONE_DEVICE anymore.
> memremap_pages() increments them via move_pfn_range_to_zone, but we skip
> ZONE_DEVICE in remove_pfn_range_from_zone.

Yes, documented e.g., in

commit 7ce700bf11b5e2cb84e4352bbdf2123a7a239c84
Author: David Hildenbrand <david@redhat.com>
Date:   Thu Nov 21 17:53:56 2019 -0800

    mm/memory_hotplug: don't access uninitialized memmaps in
shrink_zone_span()

Needs some more thought - but is definitely not urgent (well, now it's
at least no longer completely broken).

> 
> That is not really related to this patch, so I might be missing something,
> but it caught my eye while reviewing this.
> 
> Anyway, for this one:
> 
> Reviewed-by: Oscar Salvador <osalvador@suse.de>
> 

Thanks!

> 
> off-topic: I __think__ we really need to trim the CC list.

Yes we should :) - done.

-- 
Thanks,

David / dhildenb
