From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 02 May 2008 01:12:49 +0000
Subject: Re: [PATCH 2/3] mm: Avoid putting a bad page back on the LRU v2
Message-Id: <Pine.LNX.4.64.0805011810410.13527@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080502004248.GC12006@sgi.com>
In-Reply-To: <20080502004248.GC12006@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russ Anderson <rja@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>

On Thu, 1 May 2008, Russ Anderson wrote:

> Index: linus/mm/migrate.c
> =================================> --- linus.orig/mm/migrate.c	2008-05-01 19:05:33.000000000 -0500
> +++ linus/mm/migrate.c	2008-05-01 19:06:15.000000000 -0500
> @@ -380,6 +380,7 @@ static void migrate_page_copy(struct pag
>  		SetPageChecked(newpage);
>  	if (PageMappedToDisk(page))
>  		SetPageMappedToDisk(newpage);
> +	/* Do not migrate PG_memerror to the new page */

Why is the comment here?

  
>  	if (PageDirty(page)) {
>  		clear_page_dirty_for_io(page);
> @@ -721,6 +722,8 @@ unlock:
>   		 */
>   		list_del(&page->lru);
>   		move_to_lru(page);
> +		if (PageMemError(page))
> +			totalbad_pages++;

Wouldnt this be taken care of by the lru handling?

> +#ifdef CONFIG_PAGEFLAGS_EXTENDED
> +PAGEFLAG(MemError, memerror)
> +#else
> +#define PageMemError(page)	0

Use

PAGEFLAG_FLAGS(MemError)

>  #include <linux/page-flags.h>
>  
> -#define PAGE_FLAGS	(1 << PG_lru   | 1 << PG_private   | 1 << PG_locked | \
> +#define PAGE_FLAGS_BASE	(1 << PG_lru   | 1 << PG_private   | 1 << PG_locked | \
>  			 1 << PG_buddy | 1 << PG_writeback | \
>  			 1 << PG_slab  | 1 << PG_swapcache | 1 << PG_active)
> +
> +#ifdef CONFIG_PAGEFLAGS_EXTENDED
> +#define	PAGE_FLAGS	(PAGE_FLAGS_BASE | 1UL << PG_memerror)
> +#else
> +#define	PAGE_FLAGS	(PAGE_FLAGS_BASE)
> +#endif
>  
>  #define PAGE_FLAGS_RECLAIM      (PAGE_FLAGS | 1 << PG_reclaim | 1 << PG_dirty)
>  #define PAGE_FLAGS_RESERVE	(PAGE_FLAGS | 1 << PG_reserved)

The groups of page flags could also be put into page-flags.h.

