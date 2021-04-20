From: David Hildenbrand <david@redhat.com>
Date: Tue, 20 Apr 2021 09:03:43 +0000
Subject: Re: [PATCH V2] mm/page_alloc: Ensure that HUGETLB_PAGE_ORDER is less than MAX_ORDER
Message-Id: <01bdeedc-f77d-ebd0-9d42-62f09b0a2d1a@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1618199302-29335-1-git-send-email-anshuman.khandual@arm.com>
 <09284b9a-cfe1-fc49-e1f6-3cf0c1b74c76@arm.com>
 <162877dd-e6ba-d465-d301-2956bb034429@redhat.com>
 <ce4f9838-da4b-1423-4123-23c0941a2198@arm.com>
 <alpine.DEB.2.22.394.2104191236500.777076@gentwo.de>
In-Reply-To: <alpine.DEB.2.22.394.2104191236500.777076@gentwo.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Christoph Lameter <cl@gentwo.de>, Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, "linuxppc-dev @ lists . ozlabs . org" <linuxppc-dev@lists.ozlabs.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Mike Kravetz <mike.kravetz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>

Hi Christoph,

thanks for your insight.

> You can have larger blocks but you would need to allocate multiple
> contigous max order blocks or do it at boot time before the buddy
> allocator is active.
> 
> What IA64 did was to do this at boot time thereby avoiding the buddy
> lists. And it had a separate virtual address range and page table for the
> huge pages.
> 
> Looks like the current code does these allocations via CMA which should
> also bypass the buddy allocator.

Using CMA doesn't really care about the pageblock size when it comes to 
fragmentation avoidance a.k.a. somewhat reliable allocation of memory 
chunks with an order > MAX_ORDER - 1.

IOW, when using CMA for hugetlb, we don't need pageblock_order > 
MAX_ORDER - 1.

> 
> 
>>>      }
>>>
>>>
>>> But it's kind of weird, isn't it? Let's assume we have MAX_ORDER - 1 correspond to 4 MiB and pageblock_order correspond to 8 MiB.
>>>
>>> Sure, we'd be grouping pages in 8 MiB chunks, however, we cannot even
>>> allocate 8 MiB chunks via the buddy. So only alloc_contig_range()
>>> could really grab them (IOW: gigantic pages).
>>
>> Right.
> 
> But then you can avoid the buddy allocator.
> 
>>> Further, we have code like deferred_free_range(), where we end up
>>> calling __free_pages_core()->...->__free_one_page() with
>>> pageblock_order. Wouldn't we end up setting the buddy order to
>>> something > MAX_ORDER -1 on that path?
>>
>> Agreed.
> 
> We would need to return the supersized block to the huge page pool and not
> to the buddy allocator. There is a special callback in the compound page
> sos that you can call an alternate free function that is not the buddy
> allocator.

Sorry, but that doesn't make any sense. We are talking about bringup 
code, where we transition from memblock to the buddy and fill the free 
page lists. Looking at the code, deferred initialization of the memmap 
is broken on these setups -- so I deferred memmap init is never enabled.

> 
>>
>>>
>>> Having pageblock_order > MAX_ORDER feels wrong and looks shaky.
>>>
>> Agreed, definitely does not look right. Lets see what other folks
>> might have to say on this.
>>
>> + Christoph Lameter <cl@linux.com>
>>
> 
> It was done for a long time successfully and is running in numerous
> configurations.

Enforcing pageblock_order < MAX_ORDER would mean that runtime allocation 
of gigantic (here:huge) pages (HUGETLB_PAGE_ORDER >= MAX_ORDER) via 
alloc_contig_pages() becomes less reliable. To compensate, relevant 
archs could switch to "hugetlb_cma=", to improve the reliability of 
runtime allocation.

I wonder which configurations we are talking about:

a) ia64

At least I couldn't care less; it's a dead architecture -- not
sure how much people care about "more reliable runtime
allocation of gigantic (here: huge) pages". Also, not sure about which 
exact configurations.

b) ppc64

We have variable hpage size only with CONFIG_PPC_BOOK3S_64. We 
initialize the hugepage either to 1M, 2M or 16M. 16M seems to be the 
primary choice.

ppc64 has CONFIG_FORCE_MAX_ZONEORDER

default "9" if PPC64 && PPC_64K_PAGES
-> 16M effective buddy maximum size
default "13" if PPC64 && !PPC_64K_PAGES
-> 16M effective buddy maximum size

So I fail to see in which scenario we even could end up with 
pageblock_order < MAX_ORDER. I did not check ppc32.

-- 
Thanks,

David / dhildenb
