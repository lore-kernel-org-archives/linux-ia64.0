From: Andrew Morton <akpm@linux-foundation.org>
Date: Fri, 09 May 2008 20:11:34 +0000
Subject: Re: [PATCH 2/3] mm: Avoid putting a bad page back on the LRU v3
Message-Id: <20080509131134.dae2bd65.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080509151058.GC16523@sgi.com>
In-Reply-To: <20080509151058.GC16523@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russ Anderson <rja@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org, tony.luck@intel.com, clameter@sgi.com

On Fri, 9 May 2008 10:10:58 -0500
Russ Anderson <rja@sgi.com> wrote:

> Prevent a page with a physical memory error from being placed back
> on the LRU.  A new page flag (PG_memerror) is added on 64 bit
> architectures.  
> 

A little thing:

> 
> Index: linus/mm/page_alloc.c
> =================================> --- linus.orig/mm/page_alloc.c	2008-05-09 09:20:04.389938802 -0500
> +++ linus/mm/page_alloc.c	2008-05-09 09:20:11.302788361 -0500
> @@ -71,6 +71,7 @@ unsigned long totalram_pages __read_most
>  unsigned long totalreserve_pages __read_mostly;
>  long nr_swap_pages;
>  int percpu_pagelist_fraction;
> +unsigned int totalbad_pages;
>  
>  #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
>  int pageblock_order __read_mostly;
> @@ -602,10 +603,10 @@ static int prep_new_page(struct page *pa
>  		bad_page(page);
>  
>  	/*
> -	 * For now, we report if PG_reserved was found set, but do not
> -	 * clear it, and do not allocate the page: as a safety net.
> +	 * For now, we report if PG_reserved or PG_memerror was found set, but
> +	 * do not clear it, and do not allocate the page: as a safety net.
>  	 */
> -	if (PageReserved(page))
> +	if (PageReserved(page) || PageMemError(page))
>  		return 1;
>  
>  	page->flags &= ~(1 << PG_uptodate | 1 << PG_error | 1 << PG_reclaim |
> @@ -2474,7 +2475,7 @@ static void setup_zone_migrate_reserve(s
>  		page = pfn_to_page(pfn);
>  
>  		/* Blocks with reserved pages will never free, skip them. */
> -		if (PageReserved(page))
> +		if (PageReserved(page) || PageMemError(page))
>  			continue;
>  
>  		block_migratetype = get_pageblock_migratetype(page);
> Index: linus/mm/swap.c
> =================================> --- linus.orig/mm/swap.c	2008-05-09 09:19:40.466984064 -0500
> +++ linus/mm/swap.c	2008-05-09 09:20:11.330791803 -0500
> @@ -195,6 +195,8 @@ void lru_cache_add(struct page *page)
>  	struct pagevec *pvec = &get_cpu_var(lru_add_pvecs);
>  
>  	page_cache_get(page);
> +	if (unlikely(PageMemError(page)))
> +		return;		/* Don't add bad pages to the page list */
>  	if (!pagevec_add(pvec, page))
>  		__pagevec_lru_add(pvec);
>  	put_cpu_var(lru_add_pvecs);
> @@ -205,6 +207,8 @@ void lru_cache_add_active(struct page *p
>  	struct pagevec *pvec = &get_cpu_var(lru_add_active_pvecs);
>  
>  	page_cache_get(page);
> +	if (unlikely(PageMemError(page)))
> +		return;		/* Don't add bad pages to the page list */
>  	if (!pagevec_add(pvec, page))
>  		__pagevec_lru_add_active(pvec);
>  	put_cpu_var(lru_add_active_pvecs);

These PageMemError() tests are happening in some pretty darn hot paths. 
But we've gone and added this overhead to a lot of architectures and
configs which don't need it.

Should we tighten that up?  Arrange for PageMemError() to evaluate to
constant zero for all builds which don't actually implement "Migrate data
off physical pages with correctable errors"?

Probably the way to implement that would be to add a new
CONFIG_NEED_PAGE_MEM_ERROR and `select' that from the appropriate place in
ia64 Kconfig.  Which is pretty nasty, but a) we're nasty that way rather
often and b) this time it _is_ a hot-path, so some nastiness is
justifiable.

