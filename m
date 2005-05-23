From: Jesse Barnes <jesse.barnes@intel.com>
Date: Mon, 23 May 2005 18:14:48 +0000
Subject: Re: [patch 3/4] ia64 SPARSEMEM - conditional changes for SPARSEMEM
Message-Id: <200505231114.48509.jesse.barnes@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050523175107.GF2783@localhost.localdomain>
In-Reply-To: <20050523175107.GF2783@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday, May 23, 2005 10:51 am, Bob Picco wrote:
> This patch introduces the conditional changes required for the three
> memory models.  With [patch 1/4] there are three memory model
> FLATMEM, DISCONTIG and SPARSEMEM.  Also a new arch include file
> sparemem.h is introduced for defining SPARSEMEM parameters.

This looks like a good start at untangling CONFIG_DISCONTIGMEM and 
CONFIG_NUMA.  Yay!

> -#ifdef CONFIG_VIRTUAL_MEM_MAP
> +#ifdef	CONFIG_VIRTUAL_MEM_MAP

You can drop this hunk, right?

>  extern int ia64_pfn_valid (unsigned long pfn);
> -#else
> +#elif	CONFIG_FLATMEM

Space instead of tab?

>  # define ia64_pfn_valid(pfn) 1
>  #endif
>
> -#ifndef CONFIG_DISCONTIGMEM
> +#ifdef	CONFIG_FLATMEM

Ditto, and a few more later.

> -#define __pa(x)		({ia64_va _v; _v.l = (long) (x); _v.f.reg = 0;
> _v.l;}) -#define __va(x)		({ia64_va _v; _v.l = (long) (x); _v.f.reg > -1; _v.p;}) +#define __pa(x)	({							\
> +	ia64_va _v; 							\
> +	_v.l = (long) (x); 						\
> +	_v.f.reg = 0; 							\
> +	_v.l;								\
> +})
> +#define __va(x)	({							\
> +	ia64_va _v;							\
> +	_v.l = (long) (x);						\
> +	_v.f.reg = -1;							\
> +	_v.p;								\
> +})

This looks like unrelated (but good) cleanup.  Should probably be 
submitted separately along with similar cleanups for the other macros 
(e.g. REGION_NUMBER, REGION_OFFSET).

> +/* until we think of something better */
> +#define	page_is_ram(pfn)	1

This macro could consult the EFI memory map (maybe only returning true 
if the page was WB enabled?).  Does it have to be fast?

Jesse
