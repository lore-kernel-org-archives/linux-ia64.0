From: Stephane Eranian <eranian@hpl.hp.com>
Date: Tue, 14 Oct 2003 00:15:22 +0000
Subject: Re: [PATCH] clean up perfmon reset code
Message-Id: <marc-linux-ia64-106609081403477@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106608712100390@msgid-missing>
In-Reply-To: <marc-linux-ia64-106608712100390@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

John,

I have applied this patch to my kernel.

Thanks.

> NO_RESET is never set by any caller, and next_reset_type is unused.
> Neither are present in 2.4
> 
> regards
> john
> 
> Index: linux-cvs/include/asm//perfmon.h
> =================================> RCS file: /home/cvs/linux-2.5/include/asm-ia64/perfmon.h,v
> retrieving revision 1.13
> diff -u -a -p -r1.13 perfmon.h
> --- linux-cvs/include/asm//perfmon.h	22 Aug 2003 00:40:41 -0000	1.13
> +++ linux-cvs/include/asm//perfmon.h	13 Oct 2003 23:07:33 -0000
> @@ -194,9 +194,8 @@ extern void pfm_handle_work(void);
>  /*
>   * Reset PMD register flags
>   */
> -#define PFM_PMD_NO_RESET	0
> +#define PFM_PMD_SHORT_RESET	0
>  #define PFM_PMD_LONG_RESET	1
> -#define PFM_PMD_SHORT_RESET	2
>  
>  typedef union {
>  	unsigned int val;
> Index: linux-cvs/arch/ia64/kernel/perfmon.c
> =================================> RCS file: /home/cvs/linux-2.5/arch/ia64/kernel/perfmon.c,v
> retrieving revision 1.35
> diff -u -a -p -r1.35 perfmon.c
> --- linux-cvs/arch/ia64/kernel/perfmon.c	19 Sep 2003 21:01:14 -0000	1.35
> +++ linux-cvs/arch/ia64/kernel/perfmon.c	13 Oct 2003 23:08:07 -0000
> @@ -241,8 +241,6 @@ typedef struct {
>  
>  /*
>   * 64-bit software counter structure
> - *
> - * the next_reset_type is applied to the next call to pfm_reset_regs()
>   */
>  typedef struct {
>  	unsigned long	val;		/* virtual 64bit counter value */
> @@ -254,7 +252,6 @@ typedef struct {
>  	unsigned long	seed;		/* seed for random-number generator */
>  	unsigned long	mask;		/* mask for random-number generator */
>  	unsigned int 	flags;		/* notify/do not notify */
> -	int 		next_reset_type;/* PFM_PMD_NO_RESET, PFM_PMD_LONG_RESET, PFM_PMD_SHORT_RESET */
>  	unsigned long	eventid;	/* overflow event identifier */
>  } pfm_counter_t;
>  
> @@ -2755,14 +2752,14 @@ pfm_new_counter_value (pfm_counter_t *re
>  }
>  
>  static void
> -pfm_reset_regs_masked(pfm_context_t *ctx, unsigned long *ovfl_regs, int flag)
> +pfm_reset_regs_masked(pfm_context_t *ctx, unsigned long *ovfl_regs, int is_long_reset)
>  {
>  	unsigned long mask = ovfl_regs[0];
>  	unsigned long reset_others = 0UL;
>  	unsigned long val;
> -	int i, is_long_reset = (flag = PFM_PMD_LONG_RESET);
> +	int i;
>  
> -	DPRINT_ovfl(("ovfl_regs=0x%lx flag=%d\n", ovfl_regs[0], flag));
> +	DPRINT_ovfl(("ovfl_regs=0x%lx is_long_reset=%d\n", ovfl_regs[0], is_long_reset));
>  
>  	/*
>  	 * now restore reset value on sampling overflowed counters
> @@ -2793,19 +2790,17 @@ pfm_reset_regs_masked(pfm_context_t *ctx
>  }
>  
>  static void
> -pfm_reset_regs(pfm_context_t *ctx, unsigned long *ovfl_regs, int flag)
> +pfm_reset_regs(pfm_context_t *ctx, unsigned long *ovfl_regs, int is_long_reset)
>  {
>  	unsigned long mask = ovfl_regs[0];
>  	unsigned long reset_others = 0UL;
>  	unsigned long val;
> -	int i, is_long_reset = (flag = PFM_PMD_LONG_RESET);
> -
> -	DPRINT_ovfl(("ovfl_regs=0x%lx flag=%d\n", ovfl_regs[0], flag));
> +	int i;
>  
> -	if (flag = PFM_PMD_NO_RESET) return;
> +	DPRINT_ovfl(("ovfl_regs=0x%lx is_long_reset=%d\n", ovfl_regs[0], is_long_reset));
>  
>  	if (ctx->ctx_state = PFM_CTX_MASKED) {
> -		pfm_reset_regs_masked(ctx, ovfl_regs, flag);
> +		pfm_reset_regs_masked(ctx, ovfl_regs, is_long_reset);
>  		return;
>  	}
>  
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 

-Stephane
