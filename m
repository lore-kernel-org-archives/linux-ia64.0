From: David Hildenbrand <david@redhat.com>
Date: Wed, 02 Oct 2019 07:05:47 +0000
Subject: Re: [PATCH v5 04/10] mm/memory_hotplug: Don't access uninitialized memmaps in shrink_zone_span()
Message-Id: <1b6a5056-7f2a-1e83-fae0-5289435f4270@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191001144011.3801-5-david@redhat.com>
 <201910020852.w9neG45x%lkp@intel.com>
In-Reply-To: <201910020852.w9neG45x%lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kbuild test robot <lkp@intel.com>
Cc: linux-s390@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-sh@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>

On 02.10.19 02:06, kbuild test robot wrote:
> Hi David,
> 
> I love your patch! Perhaps something to improve:
> 
> [auto build test WARNING on mmotm/master]
> 
> url:    https://github.com/0day-ci/linux/commits/David-Hildenbrand/mm-memory_hotplug-Shrink-zones-before-removing-memory/20191002-054310
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: x86_64-randconfig-b002-201939 (attached as .config)
> compiler: gcc-7 (Debian 7.4.0-13) 7.4.0
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
> 
> All warnings (new ones prefixed by >>):
> 
>    In file included from include/asm-generic/bug.h:5:0,
>                     from arch/x86/include/asm/bug.h:83,
>                     from include/linux/bug.h:5,
>                     from include/linux/mmdebug.h:5,
>                     from include/linux/mm.h:9,
>                     from mm/memory_hotplug.c:9:
>    mm/memory_hotplug.c: In function '__remove_zone':
>    mm/memory_hotplug.c:471:24: error: 'ZONE_DEVICE' undeclared (first use in this function); did you mean 'ZONE_MOVABLE'?
>      if (zone_idx(zone) = ZONE_DEVICE)
>                            ^
>    include/linux/compiler.h:58:52: note: in definition of macro '__trace_if_var'
>     #define __trace_if_var(cond) (__builtin_constant_p(cond) ? (cond) : __trace_if_value(cond))
>                                                        ^~~~
>>> mm/memory_hotplug.c:471:2: note: in expansion of macro 'if'
>      if (zone_idx(zone) = ZONE_DEVICE)
>      ^~
>    mm/memory_hotplug.c:471:24: note: each undeclared identifier is reported only once for each function it appears in
>      if (zone_idx(zone) = ZONE_DEVICE)
>                            ^
>    include/linux/compiler.h:58:52: note: in definition of macro '__trace_if_var'
>     #define __trace_if_var(cond) (__builtin_constant_p(cond) ? (cond) : __trace_if_value(cond))
>                                                        ^~~~
>>> mm/memory_hotplug.c:471:2: note: in expansion of macro 'if'
>      if (zone_idx(zone) = ZONE_DEVICE)
>      ^~
> 
> vim +/if +471 mm/memory_hotplug.c
> 
>    459	
>    460	static void __remove_zone(struct zone *zone, unsigned long start_pfn,
>    461			unsigned long nr_pages)
>    462	{
>    463		struct pglist_data *pgdat = zone->zone_pgdat;
>    464		unsigned long flags;
>    465	
>    466		/*
>    467		 * Zone shrinking code cannot properly deal with ZONE_DEVICE. So
>    468		 * we will not try to shrink the zones - which is okay as
>    469		 * set_zone_contiguous() cannot deal with ZONE_DEVICE either way.
>    470		 */
>  > 471		if (zone_idx(zone) = ZONE_DEVICE)
>    472			return;
>    473	
>    474		pgdat_resize_lock(zone->zone_pgdat, &flags);
>    475		shrink_zone_span(zone, start_pfn, start_pfn + nr_pages);
>    476		update_pgdat_span(pgdat);
>    477		pgdat_resize_unlock(zone->zone_pgdat, &flags);
>    478	}
>    479	
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 

That should be easy to fix with some ifdef-ery :)

-- 

Thanks,

David / dhildenb
