From: Yury Norov <yury.norov@gmail.com>
Date: Sun, 08 May 2022 03:35:35 +0000
Subject: Re: [PATCH] arch/ia64: no need to initialise statics to 0
Message-Id: <Ync6h0QsjZa1jMFX@yury-laptop>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220508022628.96501-1-wangborong@cdjrlc.com>
In-Reply-To: <20220508022628.96501-1-wangborong@cdjrlc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jason Wang <wangborong@cdjrlc.com>
Cc: akpm@linux-foundation.org, Julia.Lawall@inria.fr, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>

+ Fenghua Yu <fenghua.yu@intel.com>

On Sun, May 08, 2022 at 10:26:28AM +0800, Jason Wang wrote:
> Static variables do not need to be initialised to 0, because compiler
> will initialise all uninitialised statics to 0. Thus, remove the
> unneeded initializations.
> 
> Signed-off-by: Jason Wang <wangborong@cdjrlc.com>

Not sure why checkpatch picked me to be a reviewer for this.
Nevertheless...

> ---
>  arch/ia64/mm/tlb.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
> index 7a2d608fba74..854e90c4e7eb 100644
> --- a/arch/ia64/mm/tlb.c
> +++ b/arch/ia64/mm/tlb.c
> @@ -84,7 +84,7 @@ wrap_mmu_context (struct mm_struct *mm)
>  		flush_bit = xchg(&ia64_ctx.flushmap[i], 0);
>  		ia64_ctx.bitmap[i] ^= flush_bit;
>  	}
> - 
> +

This one is unrelated to the patch description. Can you split the
patch, or add a couple words about this cleanup?

>  	/* use offset at 300 to skip daemons */
>  	ia64_ctx.next = find_next_zero_bit(ia64_ctx.bitmap,
>  				ia64_ctx.max_ctx, 300);
> @@ -144,7 +144,7 @@ static inline void up_spin(struct spinaphore *ss)
>  static struct spinaphore ptcg_sem;
>  static u16 nptcg = 1;
>  static int need_ptcg_sem = 1;
> -static int toolatetochangeptcgsem = 0;
> +static int toolatetochangeptcgsem;

There are at least 460 global static variables initialized explicitly.

yury:linux$ git grep "^static" | grep "= 0;" | wc -l
460

Are you going to fix them all? If not why this one is so special?

Before applying this, let's ask Fenghua - maybe it was his intention
to underline that the variable is initialized as 0.  

Thanks,
Yury

>  /*
>   * Kernel parameter "nptcg=" overrides max number of concurrent global TLB
> -- 
> 2.35.1
