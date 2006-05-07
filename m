From: Muli Ben-Yehuda <muli@il.ibm.com>
Date: Sun, 07 May 2006 08:50:36 +0000
Subject: Re: [PATCH 2/3] swiotlb: create __alloc_bootmem_low_nopanic and add support in SWIOTLB
Message-Id: <20060507085036.GF6015@rhun.haifa.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060504205929.GD14361@us.ibm.com>
In-Reply-To: <20060504205929.GD14361@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jon Mason <jdmason@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, ak@suse.de, tony.luck@intel.com, linux-ia64@vger.kernel.org, mulix@mulix.org

On Thu, May 04, 2006 at 03:59:29PM -0500, Jon Mason wrote:

> Per Andi Kleen's suggestion in the review of our Calgary IOMMU code, I
> tried to use the alloc_bootmem_nopanic that Andi recently added.
> Unfortunately, it needs low mem for our translation tables, so we needed
> a new function to do this.
> 
> I have updated swiotlb to take advantage of this new function (and
> added an error path to lib/swiotlb.c and resulting fallout from
> calling functions).
> 
> This patch has been tested individually and cumulatively on x86_64 and
> cross-compile tested on IA64.  Since I have no IA64 hardware, any
> testing on that platform would be appreciated.

A couple of minor nits below, otherwise looks good.

> Signed-off-by: Jon Mason <jdmason@us.ibm.com>

Acked-by: Muli Ben-Yehuda <muli@il.ibm.com>

> diff -r b5bb5fea7490 -r 62dc1eb0c5e2 include/linux/bootmem.h
> --- a/include/linux/bootmem.h	Tue Apr 25 18:18:55 2006
> +++ b/include/linux/bootmem.h	Wed Apr 26 16:12:39 2006
> @@ -46,6 +46,7 @@
>  extern void __init free_bootmem (unsigned long addr, unsigned long size);
>  extern void * __init __alloc_bootmem (unsigned long size, unsigned long align, unsigned long goal);
>  extern void * __init __alloc_bootmem_nopanic (unsigned long size, unsigned long align, unsigned long goal);
> +extern void * __init __alloc_bootmem_low_nopanic(unsigned long size, unsigned long align, unsigned long goal);

Would be nice to convert this and the preceding declarations to 80
chars per line, please.

> diff -r b5bb5fea7490 -r 62dc1eb0c5e2 mm/bootmem.c
> --- a/mm/bootmem.c	Tue Apr 25 18:18:55 2006
> +++ b/mm/bootmem.c	Wed Apr 26 16:12:39 2006
> @@ -463,3 +463,16 @@
>  {
>  	return __alloc_bootmem_core(pgdat->bdata, size, align, goal, LOW32LIMIT);
>  }
> +
> +void * __init __alloc_bootmem_low_nopanic(unsigned long size, 
> +					unsigned long align, unsigned long goal)
> +{
> +	bootmem_data_t *bdata;
> +	void *ptr;
> +
> +	list_for_each_entry(bdata, &bdata_list, list)
> +		if ((ptr = __alloc_bootmem_core(bdata, size, align, goal, 
> +						LOW32LIMIT)))
> +			return(ptr);

This should be 'return ptr';

Cheers,
Muli
