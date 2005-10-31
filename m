From: "Peter Keilty" <Peter.Keilty@hp.com>
Date: Mon, 31 Oct 2005 15:00:58 +0000
Subject: RE: ia64 get_mmu_context patch - v2
Message-Id: <200510311501.j9VF1bo0001129618@kitche.zk3.dec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200510300133.j9U1Xwg10988@unix-os.sc.intel.com>
In-Reply-To: <200510300133.j9U1Xwg10988@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Ken,

Glad to see the range limit is back in.

As for the printk I can remove it. 
Do I put out a patch on top of yours?
Not sure what the protocol is here, first time.

Thanks,
pete
 


> -----Original Message-----
> From: Chen, Kenneth W [mailto:kenneth.w.chen@intel.com] 
> Sent: Saturday, October 29, 2005 9:34 PM
> To: linux-ia64@vger.kernel.org
> Cc: 'Peter Keilty'
> Subject: ia64 get_mmu_context patch - v2
> 
> rev 2 of mmu_context wrap optimization, on top of Peter's patch.
> Changes from v1:
> 
> - minor tweak in mmu_context_init.  This function is called from
>   setup_arch, which can only be executed on boot cpu at startup.
>   Use of spin lock there is spurious. Also use alloc_bootmem
>   instead of __alloc_bootmem.
> 
> - comment fix for mmu_context_init
> 
> - use xchg when zeroing flushmap.  This get rid of read lock in
>   the flushmap update path.
> 
> - address the concern that v1 does find_next_zero_bit for each
>   ctx id allocation instead of just increment next.  Reinstate
>   ia64_ctx.limit, Only now it is used as free id range indicator.
>   The decision to call wrap_mmu_context is still (next >= max_ctx)
> 
> 
> Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
> Signed-off-by: Rohit Seth <rohit.seth@intel.com>
> 
> --- ./arch/ia64/mm/tlb.c.orig	2005-10-29 17:04:05.000000000 -0700
> +++ ./arch/ia64/mm/tlb.c	2005-10-29 17:05:02.000000000 -0700
> @@ -4,10 +4,13 @@
>   * Copyright (C) 1998-2001, 2003 Hewlett-Packard Co
>   *	David Mosberger-Tang <davidm@hpl.hp.com>
>   *
> + * Copyright (C) 2000, 2005 Intel Corp.
>   * 08/02/00 A. Mallick <asit.k.mallick@intel.com>
>   *		Modified RID allocation for SMP
>   *          Goutham Rao <goutham.rao@intel.com>
>   *              IPI based ptc implementation and A-step IPI 
> implementation.
> + * Rohit Seth <rohit.seth@intel.com>
> + * Ken Chen <kenneth.w.chen@intel.com>
>   */
>  #include <linux/config.h>
>  #include <linux/module.h>
> @@ -33,7 +36,6 @@
>  struct ia64_ctx ia64_ctx = {
>  	.lock =		SPIN_LOCK_UNLOCKED,
>  	.next =		1,
> -	.limit =	(1 << 15) - 1,		/* start out 
> with the safe (architected) limit */
>  	.max_ctx =	~0U
>  };
>  
> @@ -42,21 +44,13 @@
>  /*
>   * Initializes the ia64_ctx.bitmap array based on max_ctx+1.
>   * Called after cpu_init() has setup ia64_ctx.max_ctx based on
> - * maximum RID that is supported by all CPUs.
> + * maximum RID that is supported by boot CPU.
>   */
>  void __init
>  mmu_context_init (void)
>  {
> -	unsigned long flags;
> -
> -	spin_lock_irqsave(&ia64_ctx.lock, flags);
> -	if (ia64_ctx.bitmap = NULL) {
> -		ia64_ctx.bitmap = (unsigned long *)__alloc_bootmem(
> -							
> (ia64_ctx.max_ctx+1)>>3,
> -							PAGE_SIZE,
> -							
> __pa(MAX_DMA_ADDRESS));
> -	}
> -	spin_unlock_irqrestore(&ia64_ctx.lock, flags);
> +	ia64_ctx.bitmap = alloc_bootmem((ia64_ctx.max_ctx+1)>>3);
> +	ia64_ctx.flushmap = alloc_bootmem((ia64_ctx.max_ctx+1)>>3);
>  }
>  
>  /*
> @@ -65,30 +59,19 @@
>  void
>  wrap_mmu_context (struct mm_struct *mm)  {
> -	unsigned int next_ctx, max_ctx = ia64_ctx.max_ctx;
>  	int i;
> +	unsigned long flush_bit;
>  
> -	if (ia64_ctx.next > max_ctx)
> -		ia64_ctx.next = 300;	/* skip daemons */
> -	ia64_ctx.limit = max_ctx + 1;
> -
> -	/*
> -	 * Scan the ia64_ctx bitmap and set proper safe range
> -	 */
> -repeat:
> -	next_ctx = find_next_zero_bit(ia64_ctx.bitmap, 
> ia64_ctx.limit, ia64_ctx.next);
> -	if (next_ctx >= ia64_ctx.limit) {
> -		smp_mb();
> -		ia64_ctx.next = 300;	/* skip daemons */
> -		goto repeat;
> -	}
> -	ia64_ctx.next = next_ctx;
> -
> -	next_ctx = find_next_bit(ia64_ctx.bitmap, 
> ia64_ctx.limit, ia64_ctx.next);
> -	if (next_ctx >= ia64_ctx.limit) {
> -		next_ctx = ia64_ctx.limit;
> +	for (i=0; i <= ia64_ctx.max_ctx / BITS_PER_LONG; i++) {
> +		flush_bit = xchg(&ia64_ctx.flushmap[i], 0);
> +		ia64_ctx.bitmap[i] ^= flush_bit;
>  	}
> -	ia64_ctx.limit = next_ctx;
> +
> +	/* use offset at 300 to skip daemons */
> +	ia64_ctx.next = find_next_zero_bit(ia64_ctx.bitmap,
> +				ia64_ctx.max_ctx, 300);
> +	ia64_ctx.limit = find_next_bit(ia64_ctx.bitmap,
> +				ia64_ctx.max_ctx, ia64_ctx.next);
>  
>  	/* can't call flush_tlb_all() here because of race 
> condition with O(1) scheduler [EF] */
>  	{
> --- ./include/asm-ia64/mmu_context.h.orig	2005-10-29 
> 17:04:05.000000000 -0700
> +++ ./include/asm-ia64/mmu_context.h	2005-10-29 
> 17:05:44.000000000 -0700
> @@ -32,9 +32,11 @@
>  struct ia64_ctx {
>  	spinlock_t lock;
>  	unsigned int next;	/* next context number to use */
> -	unsigned int limit;	/* next >= limit => must call 
> wrap_mmu_context() */
> +	unsigned int limit;	/* available free range */
>  	unsigned int max_ctx;	/* max. context value supported 
> by all CPUs */
> +				/* call wrap_mmu_context when 
> next >= max */
>  	unsigned long *bitmap;	/* bitmap size is max_ctx+1 */
> +	unsigned long *flushmap;/* pending rid to be flushed */
>  };
>  
>  extern struct ia64_ctx ia64_ctx;
> @@ -85,10 +87,16 @@
>  			context = mm->context;
>  			if (context = 0) {
>  				cpus_clear(mm->cpu_vm_mask);
> -				if (ia64_ctx.next >= ia64_ctx.limit)
> -					wrap_mmu_context(mm);
> +				if (ia64_ctx.next >= ia64_ctx.limit) {
> +					ia64_ctx.next = 
> find_next_zero_bit(ia64_ctx.bitmap,
> +							
> ia64_ctx.max_ctx, ia64_ctx.next);
> +					ia64_ctx.limit = 
> find_next_bit(ia64_ctx.bitmap,
> +	                                                
> ia64_ctx.max_ctx, ia64_ctx.next);
> +					if (ia64_ctx.next >= 
> ia64_ctx.max_ctx)
> +						wrap_mmu_context(mm);
> +				}
>  				mm->context = context = ia64_ctx.next++;
> -	 			set_bit(context, ia64_ctx.bitmap);
> + 				__set_bit(context, ia64_ctx.bitmap);
>  			}
>  		}
>  		spin_unlock_irqrestore(&ia64_ctx.lock, flags);
> --- ./include/asm-ia64/tlbflush.h.orig	2005-10-29 
> 17:04:05.000000000 -0700
> +++ ./include/asm-ia64/tlbflush.h	2005-10-29 
> 17:04:26.000000000 -0700
> @@ -51,7 +51,7 @@
>  	if (!mm)
>  		return;
>  
> -	clear_bit(mm->context, ia64_ctx.bitmap);
> +	set_bit(mm->context, ia64_ctx.flushmap);
>  	mm->context = 0;
>  
>  	if (atomic_read(&mm->mm_users) = 0)
> 
> 
> 


