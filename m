From: Robin Holt <holt@sgi.com>
Date: Fri, 28 Apr 2006 15:33:37 +0000
Subject: Re: [rfc] dynamic 3-level / 4-level page table
Message-Id: <20060428153336.GA25570@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4sur0l$s99mf@fmsmga001.fm.intel.com>
In-Reply-To: <4sur0l$s99mf@fmsmga001.fm.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Apr 27, 2006 at 07:09:17PM -0700, Chen, Kenneth W wrote:
> --- ./arch/ia64/kernel/ivt.S.orig	2006-04-27 19:21:55.000000000 -0700
> +++ ./arch/ia64/kernel/ivt.S	2006-04-27 19:46:44.000000000 -0700
> @@ -142,16 +142,16 @@ ENTRY(vhpt_miss)
>  (p7)	dep r17=r18,r17,3,(PAGE_SHIFT-6)	// r17=pgd_offset for region[0-4]
>  	cmp.eq p7,p6=0,r21			// unused address bits all zeroes?
>  #ifdef CONFIG_PGTABLE_4
> -	shr.u r28=r22,PUD_SHIFT			// shift pud index into position
> +	extr.u r28=r22,PUD_SHIFT,11		// get pud index

How well does this work with different page sizes?

> +
> +#ifdef CONFIG_PGTABLE_4
> +int pgtbl3;
> +static __init int setup_pgtbl3(char *s)
> +{
> +	pgtbl3 = 1;
> +	return 0;
> +}
> +early_param("pgtbl3", setup_pgtbl3);
> +#endif

What about taking out CONFIG_PGTABLE_*, having the default be 3, and have the
boot option enable 4 levels?  I haven't given this much though yet, but my
first reaction was that would be the correct way to go.

Thanks,
Robin
