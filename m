From: Mike Kravetz <kravetz@us.ibm.com>
Date: Tue, 12 Jul 2005 18:30:21 +0000
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low()
Message-Id: <20050712183021.GC3987@w-mikek2.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050712152715.44CD.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20050712152715.44CD.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "Martin J. Bligh" <mbligh@mbligh.org>

On Tue, Jul 12, 2005 at 03:50:09PM +0900, Yasunori Goto wrote:
> Index: allocbootmem/mm/bootmem.c
> =================================> --- allocbootmem.orig/mm/bootmem.c	2005-06-30 11:57:13.000000000 +0900
> +++ allocbootmem/mm/bootmem.c	2005-07-08 20:46:56.209040741 +0900
> @@ -387,10 +387,16 @@
>  	pg_data_t *pgdat = pgdat_list;
>  	void *ptr;
>  
> -	for_each_pgdat(pgdat)
> +	for_each_pgdat(pgdat){
> +
> +		if (goal < __pa(MAX_DMA_ADDRESS) &&
> +		    pgdat->bdata->node_boot_start >= __pa(MAX_DMA_ADDRESS))
> +			continue; /* Skip No DMA node */
> +
>  		if ((ptr = __alloc_bootmem_core(pgdat->bdata, size,
>  						align, goal)))
>  			return(ptr);
> +	}
>  
>  	/*
>  	 * Whoops, we cannot satisfy the allocation request.

Need to be careful about the use of MAX_DMA_ADDRESS.  It is not always
the case that archs define MAX_DMA_ADDRESS as a real address.  In some
cases, MAX_DMA_ADDRESS is defined as something like -1 to indicate that
all addresses are available for DMA.  I'm not sure that the above code
will always work as desired in such cases.

FYI - While hacking on the memory hotplug code, I added a special
'#define MAX_DMA_PHYSADDR' to get around this issue on such architectures.
Most likely, this isn't elegant enough as a real solution.  But it does
point out that __pa(MAX_DMA_ADDRESS) doesn't always give you what you
expect.

-- 
Mike
