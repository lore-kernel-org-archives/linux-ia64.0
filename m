From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 14 May 2008 20:28:53 +0000
Subject: Re: [PATCH 1/3] mm: Minor clean-up of page flags in mm/page_alloc.c
Message-Id: <alpine.LFD.1.10.0805141321020.3019@woody.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080513230220.GB26722@sgi.com>
In-Reply-To: <20080513230220.GB26722@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russ Anderson <rja@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>



On Tue, 13 May 2008, Russ Anderson wrote:
>
> Minor source code cleanup of page flags in mm/page_alloc.c.  

Could we (a) make the naming reflect the *use* rather than the flags 
involved and (b) perhaps add a comment about that use at the point of 
definition?

> @@ -237,16 +237,7 @@ static void bad_page(struct page *page)
>  	printk(KERN_EMERG "Trying to fix it up, but a reboot is needed\n"
>  		KERN_EMERG "Backtrace:\n");
>  	dump_stack();
> -	page->flags &= ~(1 << PG_lru	|
> -			1 << PG_private |
> -			1 << PG_locked	|
> -			1 << PG_active	|
> -			1 << PG_dirty	|
> -			1 << PG_reclaim |
> -			1 << PG_slab    |
> -			1 << PG_swapcache |
> -			1 << PG_writeback |
> -			1 << PG_buddy );
> +	page->flags &= ~(PAGE_FLAGS_RECLAIM);

Because here I'm now otherwise looking at the code, and I wonder
 - why the extra odd parenthesis?
 - what does PAGE_FLAG_RECLAIM mean?

and it would be much nicer (I think) if the mask was instead called 
something that reflected what it was all about, ie something along the 
lines of PAGE_FLAG_CLEAR_WHEN_BAD instead.

> @@ -463,16 +454,7 @@ static inline int free_pages_check(struc
>  		(page->mapping != NULL)  |
>  		(page_get_page_cgroup(page) != NULL) |
>  		(page_count(page) != 0)  |
> +		(page->flags & (PAGE_FLAGS_RESERVE))))
>  		bad_page(page);

Same exact thing. I wonder
 - why are those parenthesis there
 - what does "PAGE_FLAGS_RESERVE" mean?

Woudln't it be much more readable if it was called 
"PAGE_FLAGS_CHECK_AT_FREE" or something? That says "those flags will be 
checked when the page is free'd", and now the use _and_ the definition 
hopefully makes some sense?

> @@ -616,17 +598,7 @@ static int prep_new_page(struct page *pa
>  		(page->mapping != NULL)  |
>  		(page_get_page_cgroup(page) != NULL) |
>  		(page_count(page) != 0)  |
> +		(page->flags & (PAGE_FLAGS_DIRTY))))
>  		bad_page(page);

And again - parenthesis, and perhaps "PAGE_FLAGS_CHECK_AT_PREP"?

> +++ linus/include/linux/page-flags.h	2008-05-13 10:26:46.513459253 -0500
> +
> +#define PAGE_FLAGS	(1 << PG_lru   | 1 << PG_private   | 1 << PG_locked | \
> +			 1 << PG_buddy | 1 << PG_writeback | \
> +			 1 << PG_slab  | 1 << PG_swapcache | 1 << PG_active)
> +
> +#define PAGE_FLAGS_RECLAIM	(PAGE_FLAGS | 1 << PG_reclaim | 1 << PG_dirty)
> +#define PAGE_FLAGS_RESERVE	(PAGE_FLAGS | 1 << PG_reserved)
> +#define PAGE_FLAGS_DIRTY	(PAGE_FLAGS | 1 << PG_reserved | 1 << PG_dirty)

This part would also be more explainable - rather than being a random 
collection of flags, wouldn't it be more natural to think of them as 
"flags I check at free", or "flags that I clear when they are corrupt" or 
"flags that I check before I pass on a new page allocation".

Right now it is _totally_ unclear why we should call something 
PAGE_FLAGS_DIRTY when it has a lot of other bits set than just PG_dirty. 
Hmm?

			Linus
