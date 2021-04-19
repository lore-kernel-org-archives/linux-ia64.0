From: Christoph Lameter <cl@gentwo.de>
Date: Mon, 19 Apr 2021 10:48:01 +0000
Subject: Re: [PATCH V2] mm/page_alloc: Ensure that HUGETLB_PAGE_ORDER is less than MAX_ORDER
Message-Id: <alpine.DEB.2.22.394.2104191236500.777076@gentwo.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="8323328-1783256993-1618829281=:777076"
List-Id: <linux-ia64.vger.kernel.org>
References: <1618199302-29335-1-git-send-email-anshuman.khandual@arm.com> <09284b9a-cfe1-fc49-e1f6-3cf0c1b74c76@arm.com> <162877dd-e6ba-d465-d301-2956bb034429@redhat.com> <ce4f9838-da4b-1423-4123-23c0941a2198@arm.com>
In-Reply-To: <ce4f9838-da4b-1423-4123-23c0941a2198@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, "linuxppc-dev @ lists . ozlabs . org" <linuxppc-dev@lists.ozlabs.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1783256993-1618829281=:777076
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Mon, 19 Apr 2021, Anshuman Khandual wrote:

> >> Unfortunately the build test fails on both the platforms (powerpc and ia64)
> >> which subscribe HUGETLB_PAGE_SIZE_VARIABLE and where this check would make
> >> sense. I some how overlooked the cross compile build failure that actually
> >> detected this problem.
> >>
> >> But wondering why this assert is not holding true ? and how these platforms
> >> do not see the warning during boot (or do they ?) at mm/vmscan.c:1092 like
> >> arm64 did.
> >>
> >> static int __fragmentation_index(unsigned int order, struct contig_page_info *info)
> >> {
> >>          unsigned long requested = 1UL << order;
> >>
> >>          if (WARN_ON_ONCE(order >= MAX_ORDER))
> >>                  return 0;
> >> ....
> >>
> >> Can pageblock_order really exceed MAX_ORDER - 1 ?

You can have larger blocks but you would need to allocate multiple
contigous max order blocks or do it at boot time before the buddy
allocator is active.

What IA64 did was to do this at boot time thereby avoiding the buddy
lists. And it had a separate virtual address range and page table for the
huge pages.

Looks like the current code does these allocations via CMA which should
also bypass the buddy allocator.


> >     }
> >
> >
> > But it's kind of weird, isn't it? Let's assume we have MAX_ORDER - 1 correspond to 4 MiB and pageblock_order correspond to 8 MiB.
> >
> > Sure, we'd be grouping pages in 8 MiB chunks, however, we cannot even
> > allocate 8 MiB chunks via the buddy. So only alloc_contig_range()
> > could really grab them (IOW: gigantic pages).
>
> Right.

But then you can avoid the buddy allocator.

> > Further, we have code like deferred_free_range(), where we end up
> > calling __free_pages_core()->...->__free_one_page() with
> > pageblock_order. Wouldn't we end up setting the buddy order to
> > something > MAX_ORDER -1 on that path?
>
> Agreed.

We would need to return the supersized block to the huge page pool and not
to the buddy allocator. There is a special callback in the compound page
sos that you can call an alternate free function that is not the buddy
allocator.

>
> >
> > Having pageblock_order > MAX_ORDER feels wrong and looks shaky.
> >
> Agreed, definitely does not look right. Lets see what other folks
> might have to say on this.
>
> + Christoph Lameter <cl@linux.com>
>

It was done for a long time successfully and is running in numerous
configurations.

--8323328-1783256993-1618829281=:777076--
