From: Zou Nan hai <nanhai.zou@intel.com>
Date: Mon, 28 Feb 2005 05:23:25 +0000
Subject: Re: [Patch 2/3] Free off node page tables instead of placing on
Message-Id: <1109568205.28455.2.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050226142627.GF10965@lnx-holt.americas.sgi.com>
In-Reply-To: <20050226142627.GF10965@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 2005-02-26 at 22:26, Robin Holt wrote:
> Tony,
> 
> This patch is simple but necessary for large numa configurations.
> Index: linux-2.6/include/asm-ia64/pgalloc.h
> =================================> --- linux-2.6.orig/include/asm-ia64/pgalloc.h	2005-02-25 14:40:02.208212833 -0600
> +++ linux-2.6/include/asm-ia64/pgalloc.h	2005-02-25 15:10:32.929665721 -0600
> @@ -49,6 +49,16 @@
>  static inline void
>  pgtable_quicklist_free (void *pgtable_entry)
>  {
> +#ifdef CONFIG_NUMA
> +	int pg_node;
> +
> +	pg_node = page_zone(virt_to_page(pgtable_entry))->zone_pgdat->node_id;
	  
          Maybe you could use the macro	page_to_nid

> +	if (pg_node != numa_node_id()) {
          will put an unlikely here better?
> +		free_page((unsigned long) pgtable_entry);
> +		return;
> +	}
> +#endif
> +
>  	preempt_disable();
>  	*(unsigned long *)pgtable_entry = (unsigned long) local_cpu_data->pgtable_quicklist;
>  	local_cpu_data->pgtable_quicklist = (unsigned long *) pgtable_entry;
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

