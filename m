From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 06 Oct 2003 16:57:41 +0000
Subject: Re: [PATCH] more discontig stuff
Message-Id: <marc-linux-ia64-106546177618144@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106488076517737@msgid-missing>
In-Reply-To: <marc-linux-ia64-106488076517737@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Oct 06, 2003 at 06:54:09PM +0200, Xavier Bru wrote:
> 
> Hi Jesse
> 
> Thanks for your answer. This new one boots OK with CONFIG_NUMA (zones
> have now free_pages non 0 at first __alloc_pages).
> 
> I applied it on 2.6.0-test5 + your patch dated Sept 22.
> 
> I just added a fix to prevent some redeclarations in  meminit.h with
> gcc 3.2 :
> 
> --- linux-2.6.0-test5/include/asm-ia64/meminit.h 2003-10-06 10:51:45.000000000 +0200
> +++ 0t5/include/asm-ia64/meminit.h	2003-10-01 18:56:09.000000000 +0200
> @@ -14,6 +14,8 @@
>   *
>   * More could be added if necessary
>   */
> +#ifndef _ASM_IA64_MEMINIT_H
> +#define _ASM_IA64_MEMINIT_H
>  #define IA64_MAX_RSVD_REGIONS 5
>  
>  struct rsvd_region {
> @@ -58,3 +60,4 @@
>  
>  #define IGNORE_PFN0	1	/* XXX fix me: ignore pfn 0 until TLB miss
>  				   handler is updated... */
> +#endif /* _ASM_IA64_MEMINIT_H */
> 
> Thanks again.

Yeah, David added that to his tree before he put the patch in.  I'll
have to rediff once he comes back and comes out with a patch against
-test6 (or maybe -test7 by then).

Thanks a lot for helping me keep this patch working, I really appreciate
it!

Jesse
