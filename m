From: Jack Steiner <steiner@sgi.com>
Date: Tue, 07 Mar 2006 17:24:29 +0000
Subject: Re: [patch] optimize flush_tlb_range on large numa box
Message-Id: <20060307172428.GA2500@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603062212.k26MCsg16120@unix-os.sc.intel.com>
In-Reply-To: <200603062212.k26MCsg16120@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 06, 2006 at 02:12:54PM -0800, Chen, Kenneth W wrote:
> It was reported from a field customer that global spin lock ptcg_lock
> is giving a lot of grief on munmap performance running on a large numa
> machine.  What appears to be a problem coming from flush_tlb_range(),
> which currently unconditionally calls platform_global_tlb_purge().
> For some of the numa machines in existence today, this function is
> mapped into ia64_global_tlb_purge(), which holds ptcg_lock spin lock
> while executing ptc.ga instruction.
> 
> Here is a patch that attempt to avoid global tlb purge whenever
> possible.  It will use local tlb purge as much as possible. Though the
> conditions to use local tlb purge is pretty restrictive.  One of the
> side effect of having flush tlb range instruction on ia64 is that
> kernel don't get a chance to clear out cpu_vm_mask.  On ia64, this mask
> is sticky and it will accumulate if process bounces around.  Thus
> diminishing the possible use of ptc.l.  Thoughts?

Patch looks good to me. 

There is some minor cleanup that can be done in the SN 
platform_global_tlb_purge function to take advantage of this patch. 
I'll do that later in a followup patch - the changes are NOT required for
your patch to be accepted.

I think clearing cpu_vm_mask is a good idea. I experimented with
doing that by calling flush_tlb_mm() from the SN platform_global_tlb_purge
function & got a big benefit. However, our workloads are atypical & I'm 
not sure the same algorithm is appropriate for all workloads. Additional 
measurements are needed.


	Acked-by: Jack Steiner <steiner@sgi.com>


> 
> 
> 
> Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
> 
> --- ./arch/ia64/mm/tlb.c.orig	2006-03-05 12:21:27.400110815 -0800
> +++ ./arch/ia64/mm/tlb.c	2006-03-05 12:23:04.725304935 -0800
> @@ -156,17 +156,19 @@ flush_tlb_range (struct vm_area_struct *
>  		nbits = purge.max_bits;
>  	start &= ~((1UL << nbits) - 1);
>  
> -# ifdef CONFIG_SMP
> -	platform_global_tlb_purge(mm, start, end, nbits);
> -# else
>  	preempt_disable();
> +#ifdef CONFIG_SMP
> +	if (mm != current->active_mm || cpus_weight(mm->cpu_vm_mask) != 1) {
> +		platform_global_tlb_purge(mm, start, end, nbits);
> +		preempt_enable();
> +		return;
> +	}
> +#endif
>  	do {
>  		ia64_ptcl(start, (nbits<<2));
>  		start += (1UL << nbits);
>  	} while (start < end);
>  	preempt_enable();
> -# endif
> -
>  	ia64_srlz_i();			/* srlz.i implies srlz.d */
>  }
>  EXPORT_SYMBOL(flush_tlb_range);
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


