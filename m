From: Paul Mundt <lethal@linux-sh.org>
Date: Wed, 30 Aug 2006 10:05:18 +0000
Subject: Re: [RFC][PATCH 10/10] convert the "easy" architectures to generic PAGE_SIZE
Message-Id: <20060830100518.GA10629@localhost.internal.ocgnet.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060829201934.47E63D1F@localhost.localdomain> <20060829201941.38D6254C@localhost.localdomain>
In-Reply-To: <20060829201941.38D6254C@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org, rdunlap@xenotime.net

On Tue, Aug 29, 2006 at 01:19:41PM -0700, Dave Hansen wrote:
> diff -puN include/asm-sh/page.h~arch-generic-PAGE_SIZE-give-every-arch-PAGE_SHIFT include/asm-sh/page.h
> --- threadalloc/include/asm-sh/page.h~arch-generic-PAGE_SIZE-give-every-arch-PAGE_SHIFT	2006-08-29 13:14:48.000000000 -0700
> +++ threadalloc-dave/include/asm-sh/page.h	2006-08-29 13:14:58.000000000 -0700
> @@ -13,12 +13,7 @@
>     [ P4 control   ]		0xE0000000
>   */
>  
> -
> -/* PAGE_SHIFT determines the page size */
> -#define PAGE_SHIFT	12
> -#define PAGE_SIZE	(1UL << PAGE_SHIFT)
> -#define PAGE_MASK	(~(PAGE_SIZE-1))
> -#define PTE_MASK	PAGE_MASK
> +#include <asm-generic/page.h>
>  
Overzealous deletion? Please leave PTE_MASK there, we use it for
_PAGE_CHG_MASK in pgtable.h.
