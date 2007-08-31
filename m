From: Zou Nan hai <nanhai.zou@intel.com>
Date: Fri, 31 Aug 2007 01:15:25 +0000
Subject: Re: [PATCH 1/1] Allow global purge traslation cache (ptc.g) to be
Message-Id: <1188522925.2583.11.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <200708301338.34246.protasnb@gmail.com>
In-Reply-To: <200708301338.34246.protasnb@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2007-08-31 at 04:38, Natalie Protasevich wrote:
> From: Natalie Protasevich <protasnb@gmail.com>
> 
> This patch allows to disable ptc.g. The code used to be in the kernel, then 
> was removed in 2.4 since the bug that it was fixing has gone away. However, 
> some large system vendors now want this capability available through a means 
> that can be controlled by the platform in the event that there is an issue 
> with either processor or their chipset where global ptc.g is not operational.  
> They want the mechanism for future platforms to work around such issues. It 
> is also needed for platform makers when they deliberately do not use the 
> global cache purge in their chipset implementation. (For such cases, Intel 
> provided a SAL table entry to specify if ptc.g is allowed and how many).
> 
> 
> ---
> 
>  arch/ia64/kernel/smp.c |   49 ++++++++++++++++++++++++++++++++
>  arch/ia64/mm/tlb.c     |   75 
> ++++++++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 123 insertions(+), 1 deletion(-)
> 
> diff -puN arch/ia64/mm/tlb.c~ptcg arch/ia64/mm/tlb.c
> --- linux-2.6.23-rc4/arch/ia64/mm/tlb.c~ptcg	2007-08-30 
> 11:58:40.000000000 -0700
> +++ linux-2.6.23-rc4-nataliep/arch/ia64/mm/tlb.c	2007-08-30 
> 11:58:40.000000000 -0700
> @@ -18,6 +18,7 @@
>  #include <linux/smp.h>
>  #include <linux/mm.h>
>  #include <linux/bootmem.h>
> +#include <linux/irq.h>
>  
>  #include <asm/delay.h>
>  #include <asm/mmu_context.h>
> @@ -83,6 +84,73 @@ wrap_mmu_context (struct mm_struct *mm)
>  	local_flush_tlb_all();
>  }
>  
> +static int noptcg;
> +
> +static void __init noptcg_setup(char *str)
> +{
> +	noptcg = 1;
> +}
> +__setup("noptcg", noptcg_setup);
> +
> +unsigned long	flush_end, flush_start, flush_nbits, flush_rid;
> +atomic_t flush_cpu_count;
> +
> +/*
> + * flush_tlb_no_ptcg is called with ptcg_lock locked
> + */
> +static inline void
> +flush_tlb_no_ptcg (unsigned long start, unsigned long end, unsigned long 
> nbits)
> +{
> +	extern void smp_send_flush_tlb (void);
> +	unsigned long saved_tpr = 0;
> +	unsigned long flags;
> +	int cpus = num_online_cpus();
> +
> +	/*
> +	 * Sometimes this is called with interrupts disabled and causes
> +	 * deadlock; to avoid this we enable interrupt and raise the TPR
> +	 * to enable ONLY IPI.
> +	 */
> +	local_save_flags(flags);
> +	if (!(flags & IA64_PSR_I)) {
> +		saved_tpr = ia64_getreg(_IA64_REG_CR_TPR);
> +		ia64_srlz_d();
> +		ia64_setreg(_IA64_REG_CR_TPR, saved_tpr);
> +		ia64_srlz_d();
> +		local_irq_enable();
> +	}
> +
> +	flush_rid = ia64_get_rr(start);
> +	ia64_srlz_d();
> +	flush_start = start;
> +	flush_end = end;
> +	flush_nbits = nbits;
> +	atomic_set(&flush_cpu_count, cpus - 1);
> +	smp_send_flush_tlb();
> +	/*
> +	 * Purge local TLB entries. ALAT invalidation is done in ia64_leave_kernel.
> +	 */
> +	do {
> +		asm volatile ("ptc.l %0,%1" :: "r"(start), "r"(nbits<<2) : "memory");
> +		start += (1UL << nbits);
> +	} while (start < end);
> +
> +	ia64_srlz_i();			/* srlz.i implies srlz.d */
> +
> +	/*
> +	 * Wait for other CPUs to finish purging entries.
> +	 */
> +	while (atomic_read(&flush_cpu_count)) {
> +		/* Nothing */
> +	}
> +
> +	if (!(flags & IA64_PSR_I)) {
> +		local_irq_disable();
> +	 	ia64_setreg(_IA64_REG_CR_TPR, saved_tpr);
> +		ia64_srlz_d();
> +	}
> +}
> +
>  void
>  ia64_global_tlb_purge (struct mm_struct *mm, unsigned long start,
>  		       unsigned long end, unsigned long nbits)
> @@ -96,7 +164,9 @@ ia64_global_tlb_purge (struct mm_struct 
>  
>  	/* HW requires global serialization of ptc.ga.  */
>  	spin_lock(&ptcg_lock);
> -	{
> +	if (noptcg)
> +		flush_tlb_no_ptcg(start, end, nbits);
> +	else {
>  		do {
>  			/*
>  			 * Flush ALAT entries also.
> @@ -109,6 +179,9 @@ ia64_global_tlb_purge (struct mm_struct 
>  	spin_unlock(&ptcg_lock);
>  }
>  
> +unsigned long	flush_end, flush_start, flush_nbits, flush_rid;
> +atomic_t flush_cpu_count;
> +
>  void
>  local_flush_tlb_all (void)
>  {
> diff -puN arch/ia64/kernel/smp.c~ptcg arch/ia64/kernel/smp.c
> --- linux-2.6.23-rc4/arch/ia64/kernel/smp.c~ptcg	2007-08-30 
> 11:58:40.000000000 -0700
> +++ linux-2.6.23-rc4-nataliep/arch/ia64/kernel/smp.c	2007-08-30 
> 11:58:40.000000000 -0700
> @@ -79,6 +79,7 @@ static volatile struct call_data_struct 
>  
>  #define IPI_CALL_FUNC		0
>  #define IPI_CPU_STOP		1
> +#define IPI_FLUSH_TLB		2
>  #define IPI_KDUMP_CPU_STOP	3
>  
>  /* This needs to be cacheline aligned because it is written to by *other* 
> CPUs.  */
> @@ -174,6 +175,47 @@ handle_IPI (int irq, void *dev_id)
>  				unw_init_running(kdump_cpu_freeze, NULL);
>  				break;
>  #endif
> +
> +			      case IPI_FLUSH_TLB:
> +			      {
> +				extern unsigned long flush_start, flush_end, flush_nbits, flush_rid;
> +				extern atomic_t flush_cpu_count;
> +				unsigned long saved_rid = ia64_get_rr(flush_start);
> +				unsigned long end = flush_end;
> +				unsigned long start = flush_start;
> +				unsigned long nbits = flush_nbits;
> +	
> +				/*
> +				 * Current CPU may be running with different RID so we need to
> +				 * reload the RID of flushed address.  Purging the translation
> +				 * also needs ALAT invalidation; we do not need "invala" here
> +				 * since it is done in ia64_leave_kernel.
> +				 */
> +				ia64_srlz_d();
> +				if (saved_rid != flush_rid) {
> +					ia64_set_rr(flush_start, flush_rid);
> +					ia64_srlz_d();
> +				}
> +
> +				do {
> +					/*
> +					 * Purge local TLB entries.
> +				 	 */
> +					__asm__ __volatile__ ("ptc.l %0,%1" ::
> +							      "r"(start), "r"(nbits<<2) : "memory");
> +					start += (1UL << nbits);
> +				} while (start < end);
> +
> +				ia64_barrier();
> +				ia64_srlz_i();			/* srlz.i implies srlz.d */
> +
> +				if (saved_rid != flush_rid) {
> +					ia64_set_rr(flush_start, saved_rid);
> +					ia64_srlz_d();
> +				}
> +				atomic_dec(&flush_cpu_count);
> +				break;
> +			      }
>  			      default:
>  				printk(KERN_CRIT "Unknown IPI on CPU %d: %lu\n", this_cpu, which);
>  				break;
> @@ -317,6 +359,13 @@ smp_flush_tlb_cpumask(cpumask_t xcpumask
>  }
>  
>  void
> +smp_send_flush_tlb (void)
> +{
> +	send_IPI_allbutself(IPI_FLUSH_TLB);
> +}
> +
> +
> +void
>  smp_flush_tlb_all (void)
>  {
>  	on_each_cpu((void (*)(void *))local_flush_tlb_all, NULL, 1, 1);
> _
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hi,
	Beside coding style issue, there are race conditions in this patch. You
should reconsider the design.
	Please consider the scenario when many cpus are calling
ia64_global_tlb_purge at the same time without any lock.
	Using global variables to indicate tlb flush start and end is not safe
here.	

Thanks
Zou Nan hai
