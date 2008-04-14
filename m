From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Mon, 14 Apr 2008 12:40:46 +0000
Subject: Re: [PATCH] NUMA memory configuration issue
Message-Id: <480350CE.8040804@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <47FE313B.2010600@bull.net>
In-Reply-To: <47FE313B.2010600@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
> You missed a spot:
> 
> diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
> index 0479661..798bf98 100644
> --- a/arch/ia64/mm/contig.c
> +++ b/arch/ia64/mm/contig.c
> @@ -253,7 +253,7 @@ paging_init (void)
>  	max_zone_pfns[ZONE_NORMAL] = max_low_pfn;
>  
>  #ifdef CONFIG_VIRTUAL_MEM_MAP
> -	efi_memmap_walk(register_active_ranges, NULL);
> +	efi_memmap_walk(filter_memory, register_active_ranges);
>  	efi_memmap_walk(find_largest_hole, (u64 *)&max_gap);
>  	if (max_gap < LARGE_GAP) {
>  		vmem_map = (struct page *) 0;
> 
> 
> But otherwise this looks plausible.  My non-numa system still
> boots.

Thank your for your response.

My patch aims to avoid the confusion due to the EFI memory ranges
which belong to different numa nodes and are merged in certain
conditions.

Do you think contig.c is also effected?
Can you please explain why?

Thanks,

Zoltan
