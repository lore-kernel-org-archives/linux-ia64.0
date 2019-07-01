From: Michal Hocko <mhocko@kernel.org>
Date: Mon, 01 Jul 2019 07:45:03 +0000
Subject: Re: [PATCH v3 03/11] s390x/mm: Implement arch_remove_memory()
Message-Id: <20190701074503.GD6376@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-4-david@redhat.com>
In-Reply-To: <20190527111152.16324-4-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: Oscar Salvador <osalvador@suse.com>, linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, Vasily Gorbik <gor@linux.ibm.com>, linux-sh@vger.kernel.org, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Igor Mammedov <imammedo@redhat.com>, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org

On Mon 27-05-19 13:11:44, David Hildenbrand wrote:
> Will come in handy when wanting to handle errors after
> arch_add_memory().

I do not understand this. Why do you add a code for something that is
not possible on this HW (based on the comment - is it still valid btw?)

> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Vasily Gorbik <gor@linux.ibm.com>
> Cc: Oscar Salvador <osalvador@suse.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  arch/s390/mm/init.c | 13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
> index d552e330fbcc..14955e0a9fcf 100644
> --- a/arch/s390/mm/init.c
> +++ b/arch/s390/mm/init.c
> @@ -243,12 +243,13 @@ int arch_add_memory(int nid, u64 start, u64 size,
>  void arch_remove_memory(int nid, u64 start, u64 size,
>  			struct vmem_altmap *altmap)
>  {
> -	/*
> -	 * There is no hardware or firmware interface which could trigger a
> -	 * hot memory remove on s390. So there is nothing that needs to be
> -	 * implemented.
> -	 */
> -	BUG();
> +	unsigned long start_pfn = start >> PAGE_SHIFT;
> +	unsigned long nr_pages = size >> PAGE_SHIFT;
> +	struct zone *zone;
> +
> +	zone = page_zone(pfn_to_page(start_pfn));
> +	__remove_pages(zone, start_pfn, nr_pages, altmap);
> +	vmem_remove_mapping(start, size);
>  }
>  #endif
>  #endif /* CONFIG_MEMORY_HOTPLUG */
> -- 
> 2.20.1
> 

-- 
Michal Hocko
SUSE Labs
