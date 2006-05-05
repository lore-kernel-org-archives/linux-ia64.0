From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 05 May 2006 18:45:06 +0000
Subject: RE: Small hugetlbpage.c fix
Message-Id: <4sur0l$vejv1@fmsmga001.fm.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <445B125F.3040405@bull.net>
In-Reply-To: <445B125F.3040405@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zoltan Menyhart wrote on Friday, May 05, 2006 1:53 AM
> --- linux-2.6.16.9-save/arch/ia64/mm/hugetlbpage.c	2006-04-21 09:58:55.000000000 +0200
> +++ linux-2.6.16.9/arch/ia64/mm/hugetlbpage.c	2006-05-05 10:35:14.000000000 +0200
> @@ -125,9 +125,9 @@
>  
>  	addr = htlbpage_to_page(addr);
>  	end  = htlbpage_to_page(end);
> -	if (is_hugepage_only_range(tlb->mm, floor, HPAGE_SIZE))
> +	if (is_hugepage_only_range((*tlb)->mm, floor, HPAGE_SIZE))
>  		floor = htlbpage_to_page(floor);
> -	if (is_hugepage_only_range(tlb->mm, ceiling, HPAGE_SIZE))
> +	if (is_hugepage_only_range((*tlb)->mm, ceiling, HPAGE_SIZE))
>  		ceiling = htlbpage_to_page(ceiling);
>  
>  	free_pgd_range(tlb, addr, end, floor, ceiling);


Luck, Tony wrote on Friday, May 05, 2006 9:44 AM
> Greg, Chris:
> 
> 2.6.17-rcN has moved on and changed this in other ways, but
> this patch looks like a candidate for the stable series.
> What's there looks like it should kick a warning, if not a
> full blown error from the compiler for getting the type wrong.


What's the big fuss about it?  The first argument is not even used in
is_hugepage_only_range() for ia64.  Plus the fix is a broken fix anyway.

- Ken
