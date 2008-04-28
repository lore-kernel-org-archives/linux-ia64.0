From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 28 Apr 2008 19:39:06 +0000
Subject: Re: [PATCH 1/2] mm: Avoid putting a bad page back on the LRU
Message-Id: <Pine.LNX.4.64.0804281238080.30548@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080428192358.GB14629@sgi.com>
In-Reply-To: <20080428192358.GB14629@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russ Anderson <rja@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>

On Mon, 28 Apr 2008, Russ Anderson wrote:

> +#if (BITS_PER_LONG > 32)
> +#define PageMemError(page)	test_bit(PG_memerror, &(page)->flags)
> +#define SetPageMemError(page)	set_bit(PG_memerror, &(page)->flags)
> +#define ClearPageMemError(page)	clear_bit(PG_memerror, &(page)->flags)
> +#define PAGE_FLAGS	(1 << PG_lru   | 1 << PG_private   | 1 << PG_locked | \
> +			 1 << PG_buddy | 1 << PG_writeback | \
> +			 1 << PG_slab  | 1 << PG_swapcache | 1 << PG_active | \
> +			 1UL << PG_memerror)
> +#else
> +#define PageMemError(page)	0
> +#define PAGE_FLAGS	(1 << PG_lru   | 1 << PG_private   | 1 << PG_locked | \
> +			 1 << PG_buddy | 1 << PG_writeback | \
> +			 1 << PG_slab  | 1 << PG_swapcache | 1 << PG_active)
> +#endif
> +#define PAGE_FLAGS_RECLAIM	(PAGE_FLAGS | 1 << PG_reclaim | 1 << PG_dirty)
> +#define PAGE_FLAGS_RESERVE	(PAGE_FLAGS | 1 << PG_reserved)
> +#define PAGE_FLAGS_DIRTY	(PAGE_FLAGS | 1 << PG_reserved | 1 << PG_dirty)
> +

All the PAGE_FLAGS_xx things could be in a separate cleanup patch. Also 
note that the way page flags are defined may change soon.

