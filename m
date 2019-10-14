From: David Hildenbrand <david@redhat.com>
Date: Mon, 14 Oct 2019 09:32:13 +0000
Subject: Re: [PATCH v6 04/10] mm/memory_hotplug: Don't access uninitialized memmaps in shrink_zone_span()
Message-Id: <5a4573de-bd8a-6cd3-55d0-86d503a236fd@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191006085646.5768-1-david@redhat.com>
 <20191006085646.5768-5-david@redhat.com>
In-Reply-To: <20191006085646.5768-5-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-s390@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-sh@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, x86@kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>

On 06.10.19 10:56, David Hildenbrand wrote:
> Let's limit shrinking to !ZONE_DEVICE so we can fix the current code. We
> should never try to touch the memmap of offline sections where we could
> have uninitialized memmaps and could trigger BUGs when calling
> page_to_nid() on poisoned pages.
> 
> There is no reliable way to distinguish an uninitialized memmap from an
> initialized memmap that belongs to ZONE_DEVICE, as we don't have
> anything like SECTION_IS_ONLINE we can use similar to
> pfn_to_online_section() for !ZONE_DEVICE memory. E.g.,
> set_zone_contiguous() similarly relies on pfn_to_online_section() and
> will therefore never set a ZONE_DEVICE zone consecutive. Stopping to
> shrink the ZONE_DEVICE therefore results in no observable changes,
> besides /proc/zoneinfo indicating different boundaries - something we
> can totally live with.
> 
> Before commit d0dc12e86b31 ("mm/memory_hotplug: optimize memory
> hotplug"), the memmap was initialized with 0 and the node with the
> right value. So the zone might be wrong but not garbage. After that
> commit, both the zone and the node will be garbage when touching
> uninitialized memmaps.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Fixes: d0dc12e86b31 ("mm/memory_hotplug: optimize memory hotplug")

@Andrew, can you convert that to

Fixes: f1dd2cd13c4b ("mm, memory_hotplug: do not associate hotadded 
memory to zones until online") # visible after d0dc12e86b319

and add

Cc: stable@vger.kernel.org # v4.13+


-- 

Thanks,

David / dhildenb
