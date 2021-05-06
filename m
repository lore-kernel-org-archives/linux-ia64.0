From: David Hildenbrand <david@redhat.com>
Date: Thu, 06 May 2021 19:14:42 +0000
Subject: Re: [RFC PATCH 1/7] mm: sparse: set/clear subsection bitmap when pages are onlined/offlined.
Message-Id: <146a1ec6-38b3-9724-b346-9bb6e7e24c72@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210506152623.178731-1-zi.yan@sent.com>
 <20210506152623.178731-2-zi.yan@sent.com>
 <06dfaf69-1173-462c-b85f-8715cb8d108c@redhat.com>
 <71EE13C0-9CF7-4F1F-9C17-64500A854BD8@nvidia.com>
In-Reply-To: <71EE13C0-9CF7-4F1F-9C17-64500A854BD8@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zi Yan <ziy@nvidia.com>
Cc: Oscar Salvador <osalvador@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Wei Yang <richard.weiyang@linux.alibaba.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

>> But glimpsing at patch #2, I'd rather stop right away digging deeper into this series :)
> 
> What is the issue of patch 2, which makes pageblock_order a variable all the time? BTW, patch 2 fixes a bug by exporting pageblock_order, since when HUGETLB_PAGE_SIZE_VARIABLE is set, virtio-mem will not see pageblock_order as a variable, which could happen for PPC_BOOK2S_64 with virtio-men enabled, right? Or is this an invalid combination?

virtio_mem is x86_64 only. aarch64 and s390x prototypes are available.

If I understood "Make pageblock_order a variable and
set it to the max of HUGETLB_PAGE_ORDER, MAX_ORDER - 1" correctly, 
you're setting the pageblock_order on x86_64 to 4M. That mean's you're 
no longer grouping for THP but MAX_ORDER - 1, which is not what we want. 
We want to optimize for THP.

Also, that would affect virtio-balloon with free page reporting (report 
only 4 MiB chunks not 2 MiB chunks).

> 
>>
>> I think what would really help is drafting a design of how it all could look like and then first discussing the high-level design, investigating how it could play along with all existing users, existing workloads, and existing use cases. Proposing such changes without a clear picture in mind and a high-level overview might give you some unpleasant reactions from some of the developers around here ;)
> 
> Please see my other email for a high-level design. Also I sent the patchset as a RFC to gather information on users, workloads, use cases I did not know about and I learnt a lot from your replies. :) Feedback is always welcome, but I am not sure why it needs to make people unpleasant. ;)

Rather the replies might be unpleasant ;)

-- 
Thanks,

David / dhildenb
