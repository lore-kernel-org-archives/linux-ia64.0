From: David Hildenbrand <david@redhat.com>
Date: Mon, 14 Oct 2019 09:31:14 +0000
Subject: Re: [PATCH v6 03/10] mm/memory_hotplug: Don't access uninitialized memmaps in shrink_pgdat_span()
Message-Id: <3d8be627-bfd6-1336-689d-345a2ed67118@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191006085646.5768-1-david@redhat.com>
 <20191006085646.5768-4-david@redhat.com>
In-Reply-To: <20191006085646.5768-4-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-s390@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-sh@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, x86@kernel.org, linux-mm@kvack.org, Wei Yang <richardw.yang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>

On 06.10.19 10:56, David Hildenbrand wrote:
> We might use the nid of memmaps that were never initialized. For
> example, if the memmap was poisoned, we will crash the kernel in
> pfn_to_nid() right now. Let's use the calculated boundaries of the separate
> zones instead. This now also avoids having to iterate over a whole bunch of
> subsections again, after shrinking one zone.
> 
> Before commit d0dc12e86b31 ("mm/memory_hotplug: optimize memory
> hotplug"), the memmap was initialized to 0 and the node was set to the
> right value. After that commit, the node might be garbage.
> 
> We'll have to fix shrink_zone_span() next.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Wei Yang <richardw.yang@linux.intel.com>
> Fixes: d0dc12e86b31 ("mm/memory_hotplug: optimize memory hotplug")

@Andrew, can you convert that to

Fixes: f1dd2cd13c4b ("mm, memory_hotplug: do not associate hotadded memory to zones until online") # visible after d0dc12e86b319

and add

Cc: stable@vger.kernel.org # v4.13+

-- 

Thanks,

David / dhildenb
