From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 04 Sep 2007 19:59:31 +0000
Subject: Re: [PATCH 1/1] Allow global purge traslation cache (ptc.g) to be disabled - take 2
Message-Id: <200709041359.32545.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200708301338.34246.protasnb@gmail.com>
In-Reply-To: <200708301338.34246.protasnb@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 03 September 2007 02:06:20 am Natalie Protasevich wrote:
> This patch allows to disable ptc.g. The code used to be in the kernel, then was removed 
> in 2.4 since the bug that it was fixing has gone away. However, some large system vendors 
> now want this capability available through a means that can be controlled by the platform 
> in the event that there is an issue with either processor or their chipset where global 
> ptc.g is not operational.  They want the mechanism for future platforms to work around 
> such issues. It is also needed for platform makers when they deliberately do not use the 
> global cache purge in their chipset implementation. (For such cases, Intel provided a SAL 
> table entry to specify if ptc.g is allowed and how many).

This is an area prone to hard-to-reproduce and hard-to-debug problems,
and there's a lot of subtle stuff in this patch.  So I worry about the
fact that we're adding a noptcg path that will be basically untested,
compared with the normal path.

> +static inline void
> +flush_tlb_no_ptcg (unsigned long start, unsigned long end,
> +		    unsigned long nbits)
> +{
> +	extern void smp_send_flush_tlb (void);
> +	unsigned long saved_tpr = 0;
> +	unsigned long flags;
> +	int cpus = num_online_cpus();

This isn't safe with respect to CPU hotplug, is it?  What if a CPU
goes offline between here and the "wait for other CPUs" loop below?

> +	/*
> +	 * Sometimes this is called with interrupts disabled and causes
> +	 * deadlock; to avoid this we enable interrupt and raise the TPR
> +	 * to enable ONLY IPI.
> +	 */

I don't think the comment matches the code.  With TPR, you can mask
interrupts 0x10-0x1f, 0x10-0x2f, 0x10-0x3f, ..., 0x10-0xef, or 0x10-0xff.
So you have to leave at least interrupts 0xf0-0xff unmasked, which
includes IA64_IPI_VECTOR at 0xfe and 15 others.

> +	local_save_flags(flags);
> +	if (!(flags & IA64_PSR_I)) {
> +		saved_tpr = ia64_getreg(_IA64_REG_CR_TPR);
> +		ia64_srlz_d();

Why is this srlz.d needed?

> +		ia64_setreg(_IA64_REG_CR_TPR, saved_tpr);

This just writes back the same value we read above.  It doesn't really
do anything, does it?

> +		ia64_srlz_d();
> +		local_irq_enable();
> +	}
> +
> +	ia64_global_tlb_flush_rid = ia64_get_rr(start);
> +	ia64_srlz_d();

Why is this srlz.d needed?

> +	ia64_global_tlb_flush_start = start;
> +	ia64_global_tlb_flush_end = end;
> +	ia64_global_tlb_flush_nbits = nbits;
> +	atomic_set(&ia64_global_tlb_flush_cpu_count, cpus - 1);
> +	smp_send_flush_tlb();
> +	/*
> +	 * Purge local TLB entries. ALAT invalidation is done in ia64_leave_kernel.
> +	 */
> +	do {
> +		ia64_ptcl(start, nbits<<2);
> +		start += (1UL << nbits);
> +	} while (start < end);
> +
> +	ia64_srlz_i();			/* srlz.i implies srlz.d */
> +
> +	/*
> +	 * Wait for other CPUs to finish purging entries.
> +	 */
> +	while (atomic_read(&ia64_global_tlb_flush_cpu_count)) {
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
> diff -puN arch/ia64/kernel/smp.c~ptcg arch/ia64/kernel/smp.c
> --- linux-2.6.23-rc5/arch/ia64/kernel/smp.c~ptcg	2007-09-02 23:58:54.000000000 -0700
> +++ linux-2.6.23-rc5-nataliep/arch/ia64/kernel/smp.c	2007-09-02 23:59:25.000000000 -0700
> @@ -174,6 +175,48 @@ handle_IPI (int irq, void *dev_id)
>  				unw_init_running(kdump_cpu_freeze, NULL);
>  				break;
>  #endif
> +
> +			      case IPI_FLUSH_TLB:
> +			      {
> +				extern unsigned long ia64_global_tlb_flush_start, 
> +				       ia64_global_tlb_flush_end, ia64_global_tlb_flush_nbits, 
> +				       ia64_global_tlb_flush_rid;
> +				extern atomic_t ia64_global_tlb_flush_cpu_count;
> +				unsigned long saved_rid = ia64_get_rr(ia64_global_tlb_flush_start);
> +				unsigned long end = ia64_global_tlb_flush_end;
> +				unsigned long start = ia64_global_tlb_flush_start;
> +				unsigned long nbits = ia64_global_tlb_flush_nbits;
> +	
> +				/*
> +				 * Current CPU may be running with different RID so we need to
> +				 * reload the RID of flushed address.  Purging the translation
> +				 * also needs ALAT invalidation; we do not need "invala" here
> +				 * since it is done in ia64_leave_kernel.
> +				 */
> +				ia64_srlz_d();

Why is this srlz.d needed?

> +				if (saved_rid != ia64_global_tlb_flush_rid) {
> +					ia64_set_rr(ia64_global_tlb_flush_start, ia64_global_tlb_flush_rid);
> +					ia64_srlz_d();
> +				}
> +
> +				do {
> +					/*
> +					 * Purge local TLB entries.
> +				 	 */
> +					ia64_ptcl(start, nbits<<2);
> +					start += (1UL << nbits);
> +				} while (start < end);
> +
> +				ia64_barrier();
> +				ia64_srlz_i();			/* srlz.i implies srlz.d */

Why are these (barrier & srlz.i) needed?

> +				if (saved_rid != ia64_global_tlb_flush_rid) {
> +					ia64_set_rr(ia64_global_tlb_flush_start, saved_rid);
> +					ia64_srlz_d();
> +				}
> +				atomic_dec(&ia64_global_tlb_flush_cpu_count);
> +				break;
> +			      }
>  			      default:
>  				printk(KERN_CRIT "Unknown IPI on CPU %d: %lu\n", this_cpu, which);
>  				break;
