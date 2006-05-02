From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Tue, 02 May 2006 08:28:08 +0000
Subject: Re: [rfc] dynamic 3-level / 4-level page table
Message-Id: <44571818.8000209@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <4sur0l$s99mf@fmsmga001.fm.intel.com>
In-Reply-To: <4sur0l$s99mf@fmsmga001.fm.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:
...
> @@ -216,21 +216,11 @@ ENTRY(vhpt_miss)
>  	 * r18 = *pte
>  	 */
>  	ld8 r25=[r21]				// read *pte again
> -	ld8 r26=[r17]				// read *pmd again
> -#ifdef CONFIG_PGTABLE_4
> -	ld8 r19=[r28]				// read *pud again
> -#endif
> -	cmp.ne p6,p7=r0,r0
>  	;;
> -	cmp.ne.or.andcm p6,p7=r26,r20		// did *pmd change
> -#ifdef CONFIG_PGTABLE_4
> -	cmp.ne.or.andcm p6,p7=r19,r29		// did *pud change
> -#endif
...
You explained me a month ago why pud...pmd pointers are re-checked
in "vhpt_miss".

Later I pointed out that *pgd has to be re-read and compared, too.

Could you please explain why you think it is not necessary any
more to re-check them?

Thanks,

Zoltan
