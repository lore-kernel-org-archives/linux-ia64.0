From: David Hildenbrand <david@redhat.com>
Date: Thu, 06 May 2021 19:38:37 +0000
Subject: Re: [RFC PATCH 0/7] Memory hotplug/hotremove at subsection size
Message-Id: <d2e3c89d-a1fe-e7bc-c2ec-586df2073951@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210506152623.178731-1-zi.yan@sent.com>
 <fb60eabd-f8ef-2cb1-7338-7725efe3c286@redhat.com>
 <9D7FD316-988E-4B11-AC1C-64FF790BA79E@nvidia.com>
 <3a51f564-f3d1-c21f-93b5-1b91639523ec@redhat.com>
 <16962E62-7D1E-4E06-B832-EC91F54CC359@nvidia.com>
 <f3a2152c-685b-2141-3e33-b2bcab8b6010@redhat.com>
 <3A6D54CF-76F4-4401-A434-84BEB813A65A@nvidia.com>
 <0e850dcb-c69a-188b-7ab9-09e6644af3ab@redhat.com>
 <20210506193026.GE388843@casper.infradead.org>
In-Reply-To: <20210506193026.GE388843@casper.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@infradead.org>
Cc: Zi Yan <ziy@nvidia.com>, Oscar Salvador <osalvador@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Wei Yang <richard.weiyang@linux.alibaba.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On 06.05.21 21:30, Matthew Wilcox wrote:
> On Thu, May 06, 2021 at 09:10:52PM +0200, David Hildenbrand wrote:
>> I have to admit that I am not really a friend of that. I still think our
>> target goal should be to have gigantic THP *in addition to* ordinary THP.
>> Use gigantic THP where enabled and possible, and just use ordinary THP
>> everywhere else. Having one pageblock granularity is a real limitation IMHO
>> and requires us to hack the system to support it to some degree.
> 
> You're thinking too small with only two THP sizes ;-)  I'm aiming to

Well, I raised in my other mail that we will have multiple different use 
cases, including multiple different THP e.g., on aarch64 ;)

> support arbitrary power-of-two memory allocations.  I think there's a
> fruitful discussion to be had about how that works for anonymous memory --
> with page cache, we have readahead to tell us when our predictions of use
> are actually fulfilled.  It doesn't tell us what percentage of the pages

Right, and I think we have to think about a better approach than just 
increasing the pageblock_order.

> allocated were actually used, but it's a hint.  It's a big lift to go from
> 2MB all the way to 1GB ... if you can look back to see that the previous
> 1GB was basically fully populated, then maybe jump up from allocating
> 2MB folios to allocating a 1GB folio, but wow, that's a big step.
> 
> This goal really does mean that we want to allocate from the page
> allocator, and so we do want to grow MAX_ORDER.  I suppose we could
> do somethig ugly like
> 
> 	if (order <= MAX_ORDER)
> 		alloc_page()
> 	else
> 		alloc_really_big_page()
> 
> but that feels like unnecessary hardship to place on the user.

I had something similar for the sort term in mind, relying on 
alloc_contig_pages() (and maybe ZONE_MOVABLE to make allocations more 
likely to succeed). Devil's in the details (page migration, ...).


-- 
Thanks,

David / dhildenb
