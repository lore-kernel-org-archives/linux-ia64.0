From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 21 Dec 2006 01:58:07 +0000
Subject: Re: [patch] Cache error recovery
Message-Id: <4589EA2F.8050503@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200612191705.kBJH5e0s69613196@clink.americas.sgi.com>
In-Reply-To: <200612191705.kBJH5e0s69613196@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Looks good. Thanks!

Acked-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

Russ Anderson wrote:
> Here is an updated patch with comment clean up.
> 
> [patch] Cache error recovery
> 
> Similar to memory error recovery, when a cache error is consumed
> by a user process terminate the user instead of crashing the system.
> 
> Signed-off-by: Russ Anderson (rja@sgi.com)
> 
> ---
>  arch/ia64/kernel/mca_drv.c |   32 +++++++++++---------------------
>  1 file changed, 11 insertions(+), 21 deletions(-)
> 
> Index: test/arch/ia64/kernel/mca_drv.c
> =================================> --- test.orig/arch/ia64/kernel/mca_drv.c	2006-12-19 10:28:36.000000000 -0600
> +++ test/arch/ia64/kernel/mca_drv.c	2006-12-20 11:16:19.091608933 -0600
> @@ -602,6 +602,8 @@ recover_from_platform_error(slidx_table_
>  		default:
>  			break;
>  		}
> +	} else if (psp->cc && !psp->bc) {	/* Cache error */
> +		status = recover_from_read_error(slidx, peidx, pbci, sos);
>  	}
>  
>  	return status;
> @@ -645,13 +647,6 @@ recover_from_tlb_check(peidx_table_t *pe
>   * Return value:
>   *	1 on Success / 0 on Failure
>   */
> -/*
> - *  Later we try to recover when below all conditions are satisfied.
> - *   1. Only one processor error section is exist.
> - *   2. BUS_CHECK is exist and the others are not exist.(Except TLB_CHECK)
> - *   3. The entry of BUS_CHECK_INFO is 1.
> - *   4. "External bus error" flag is set and the others are not set.
> - */
>  
>  static int
>  recover_from_processor_error(int platform, slidx_table_t *slidx,
> @@ -687,36 +682,31 @@ recover_from_processor_error(int platfor
>  	/*
>  	 * The cache check and bus check bits have four possible states
>  	 *   cc bc
> -	 *    0  0	Weird record, not recovered
> -	 *    1  0	Cache error, not recovered
> -	 *    0  1	I/O error, attempt recovery
>  	 *    1  1	Memory error, attempt recovery
> +	 *    1  0	Cache error, attempt recovery
> +	 *    0  1	I/O error, attempt recovery
> +	 *    0  0	Other error type, not recovered
>  	 */
> -	if (psp->bc = 0 || pbci = NULL)
> -		return fatal_mca("No bus check");
> +	if (psp->cc = 0 && (psp->bc = 0 || pbci = NULL))
> +		return fatal_mca("No cache or bus check");
>  
>  	/*
> -	 * Sorry, we cannot handle so many.
> +	 * Cannot handle more than one bus check.
>  	 */
>  	if (peidx_bus_check_num(peidx) > 1)
>  		return fatal_mca("Too many bus checks");
> -	/*
> -	 * Well, here is only one bus error.
> -	 */
> +
>  	if (pbci->ib)
>  		return fatal_mca("Internal Bus error");
> -	if (pbci->cc)
> -		return fatal_mca("Cache-cache error");
>  	if (pbci->eb && pbci->bsi > 0)
>  		return fatal_mca("External bus check fatal status");
>  
>  	/*
> -	 * This is a local MCA and estimated as recoverble external bus error.
> -	 * (e.g. a load from poisoned memory)
> -	 * This means "there are some platform errors".
> +	 * This is a local MCA and estimated as a recoverble error.
>  	 */
>  	if (platform)
>  		return recover_from_platform_error(slidx, peidx, pbci, sos);
> +
>  	/*
>  	 * On account of strange SAL error record, we cannot recover.
>  	 */
> 

