From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 09 Jun 2008 18:28:00 +0000
Subject: Re: [PATCH 2/3] mm: Avoid putting a bad page back on the LRU v6
Message-Id: <Pine.LNX.4.64.0806091123400.30605@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080609161933.GC14939@sgi.com>
In-Reply-To: <20080609161933.GC14939@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russ Anderson <rja@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>

On Mon, 9 Jun 2008, Russ Anderson wrote:

> -#define PAGE_FLAGS	(1 << PG_lru   | 1 << PG_private   | 1 << PG_locked | \
> +#define PAGE_FLAGS_BASE	(1 << PG_lru   | 1 << PG_private   | 1 << PG_locked | \
>  			 1 << PG_buddy | 1 << PG_writeback | \
>  			 1 << PG_slab  | 1 << PG_swapcache | 1 << PG_active)
> +
> +#ifdef CONFIG_PAGEFLAGS_EXTENDED
> +PAGEFLAG(MemError, memerror)
> +#define	PAGE_FLAGS	(PAGE_FLAGS_BASE | 1UL << PG_memerror)
> +#else
> +PAGEFLAG_FALSE(MemError)
> +#define	PAGE_FLAGS	(PAGE_FLAGS_BASE)
> +#endif

Hmmmm... That doesnt look nice. It would be good if we had some definition 
that  allows the simple oring with a flag mask. That mask should be 
zero if the flag is always false.

#ifdef CONFIG_PAGEFLAGS_EXTENDED
PAGEFLAG(MemError, memerror)
#define MemError_mask (1 << PG_memerror)
#else
PAGEFLAG_FALSE(MemError)
#define MemError_mask 0
#endif

#define	PAGE_FLAGS	(PAGE_FLAGS_BASE | MemError_mask)

Maybe we could have the PAGEFLAG and the PAGEFLAG_FALSE macros generate 
these definitions?

