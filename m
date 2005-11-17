From: Robin Holt <holt@sgi.com>
Date: Thu, 17 Nov 2005 18:51:33 +0000
Subject: Re: [patch] 4 level page table bug fix in vhpt_miss
Message-Id: <20051117185133.GA6708@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200511170938.jAH9cgg11411@unix-os.sc.intel.com>
In-Reply-To: <200511170938.jAH9cgg11411@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This brings performance back in line with the three-level case (approx
0.2% slowdown).  Thanks for finding this.

Robin

On Thu, Nov 17, 2005 at 01:38:42AM -0800, Chen, Kenneth W wrote:
> >From source code inspection, I think there is a bug with 4 level
> page table with vhpt_miss handler.  In the code path of rechecking
> page table entry against previously read value after tlb insertion,
> *pte value in register r18 was overwritten with value newly read
> from pud pointer, render the check of new *pte against previous
> *pte completely wrong.  Though the bug is none fatal and the penalty
> is to purge the entry and retry.  For functional correctness, it
> should be fixed.  The fix is to use a different register so new
> *pud don't trash *pte.  (btw, the comments in the cmp statement is
> wrong as well, which I will address in the next patch).
> 
> Signed-off-by: Ken Chen <kenneth.w.chen@intel.com> 
> 
> --- ./arch/ia64/kernel/ivt.S.orig	2005-11-16 23:35:27.086799703 -0800
> +++ ./arch/ia64/kernel/ivt.S	2005-11-17 00:14:51.247903555 -0800
> @@ -209,13 +209,13 @@ ENTRY(vhpt_miss)
>  	ld8 r25=[r21]				// read L4 entry again
>  	ld8 r26=[r17]				// read L3 PTE again
>  #ifdef CONFIG_PGTABLE_4
> -	ld8 r18=[r28]				// read L2 entry again
> +	ld8 r19=[r28]				// read L2 entry again
>  #endif
>  	cmp.ne p6,p7=r0,r0
>  	;;
>  	cmp.ne.or.andcm p6,p7=r26,r20		// did L3 entry change
>  #ifdef CONFIG_PGTABLE_4
> -	cmp.ne.or.andcm p6,p7=r29,r18		// did L4 PTE change
> +	cmp.ne.or.andcm p6,p7=r19,r29		// did L4 PTE change
>  #endif
>  	mov r27=PAGE_SHIFT<<2
>  	;;
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
