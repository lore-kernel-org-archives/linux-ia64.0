From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 16 May 2008 23:13:11 +0000
Subject: Re: [PATCH 2/3] mm: Avoid putting a bad page back on the LRU v5
Message-Id: <Pine.LNX.4.64.0805161609060.5114@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080516192320.GE7885@sgi.com>
In-Reply-To: <20080516192320.GE7885@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russ Anderson <rja@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>

On Fri, 16 May 2008, Russ Anderson wrote:

> Prevent a page with a physical memory error from being placed back
> on the LRU.  A new page flag (PG_memerror) is added on 64 bit
> architectures.  

Not 64 bit. Its added if CONFIG_PAGEFLAGS_EXTENDED is defined. That is 
the case when we are not in a configuration that uses lots ofpageflags for 
other purposes (like regular sparsemem).

> @@ -2474,7 +2474,7 @@ static void setup_zone_migrate_reserve(s
>  		page = pfn_to_page(pfn);
>  
>  		/* Blocks with reserved pages will never free, skip them. */

Update comment too?

> -		if (PageReserved(page))
> +		if (PageReserved(page) || PageMemError(page))
>  			continue;
>  
>  		block_migratetype = get_pageblock_migratetype(page);
> Index: linus/mm/migrate.c
> =================================> --- linus.orig/mm/migrate.c	2008-05-15 12:58:25.165679802 -0500
> +++ linus/mm/migrate.c	2008-05-16 12:25:16.145557095 -0500
> @@ -35,6 +35,8 @@
>  
>  #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
>  
> +unsigned int totalbad_pages;
> +

Why is this defined in migrate.c?

>  /*
>   * Isolate one page from the LRU lists. If successful put it onto
>   * the indicated list with elevated page count.
> @@ -110,6 +112,8 @@ int putback_lru_pages(struct list_head *
>  
>  	list_for_each_entry_safe(page, page2, l, lru) {
>  		list_del(&page->lru);
> +		if (unlikely(PageMemError(page)))
> +			continue;
>  		move_to_lru(page);
>  		count++;
>  	}
> @@ -717,10 +721,14 @@ unlock:
>   		 * A page that has been migrated has all references
>   		 * removed and will be freed. A page that has not been
>   		 * migrated will have kepts its references and be
> - 		 * restored.
> +		 * restored.  A page with a memory error will not
> +		 * be moved to the LRU.
>   		 */
>   		list_del(&page->lru);
> - 		move_to_lru(page);
> +		if (PageMemError(page))
> +			totalbad_pages++;
> +		else
> +			move_to_lru(page);
>  	}

So what happens if a page has acquired an additional ref count and 
PageMemError is set. Then we fail migration and the page will not be put 
back on the LRU? So it will not be migratable anymore?
