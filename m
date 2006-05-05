From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 05 May 2006 19:06:46 +0000
Subject: RE: Small hugetlbpage.c fix
Message-Id: <4sur0l$vetgo@fmsmga001.fm.intel.com>
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


Sorry, I have to nak this one, for multiple reasons:

(1) A proper fix is already in the latest git tree.
(2) usage of is_hugepage_only_range() in function hugetlb_free_pgd_range
    is wrong here.  Because in 2.6.16, is_hugepage_only_range on ia64 is
    defined to be within, where in here the real intent is to scale floor
    and ceiling addresses if they falls into hugetlb virtual address range.
    A proper fix should be:

	-	if (is_hugepage_only_range(tlb->mm, floor, HPAGE_SIZE))
	+	if (REGION_NUMBER(floor) = RGN_HPAGE)
	 		floor = htlbpage_to_page(floor);
	-	if (is_hugepage_only_range(tlb->mm, ceiling, HPAGE_SIZE))
	+	if (REGION_NUMBER(ceiling) = RGN_HPAGE)
	 		ceiling = htlbpage_to_page(ceiling);

	we get away from this bug because such scenario is not possible on
      ia64 because we have a virtual address hole at the end of each region
      used by the short format vhpt hash address.
(3) lastly, the first argument is not used on ia64.  If the fix is for
    cosmetic reason, that's fine by me.  But I object on the ground of
    correctness for the two reasons given above.

- Ken
