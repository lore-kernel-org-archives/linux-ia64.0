From: Jack Steiner <steiner@sgi.com>
Date: Wed, 26 Nov 2003 19:19:38 +0000
Subject: Re: smp_flush_tlb_mm
Message-Id: <marc-linux-ia64-106987490703124@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106985904913387@msgid-missing>
In-Reply-To: <marc-linux-ia64-106985904913387@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 26, 2003 at 10:00:42AM -0500, Jes Sorensen wrote:
> Hi
> 
> Looking at some profiles on a 512p box I noticed that we are seeing a
> few more smp_call_function calls than we really would like ;-)


Not certain, but I suspect you need the following patch. Otherwise, many
TLB fulls that would normally be "ptc.g" flushes will be done
with IPIs.

This isnt the final form for the patch but it works.


diff -Naur linux_base/mm/memory.c linux/mm/memory.c
--- linux_base/mm/memory.c	Tue Nov 25 10:03:50 2003
+++ linux/mm/memory.c	Tue Nov 25 10:55:00 2003
@@ -572,9 +572,10 @@
 			if ((long)zap_bytes > 0)
 				continue;
 			if (need_resched()) {
+				int fullmm = (*tlbp)->fullmm;
 				tlb_finish_mmu(*tlbp, tlb_start, start);
 				cond_resched_lock(&mm->page_table_lock);
-				*tlbp = tlb_gather_mmu(mm, 0);
+				*tlbp = tlb_gather_mmu(mm, fullmm);
 				tlb_start_valid = 0;
 			}
 			zap_bytes = ZAP_BLOCK_SIZE;



> To get around it I have implemented a on_each_cpu_masked() and using it
> in flush_tlb_mm to reduce the call rate a bit. For flush_tlb_range it is
> a little trickier since it relies on platform_global_purge_tlb() rather
> than smp_call_function, so I am hoping we might be able to do a
> platform_purge_tlb_masked() as well?
> 
> A preliminary patch for flush_tlb_mm and on_each_cpu_masked is attached.
> 
> Comments?
> 
> Cheers,
> Jes
> 
> diff -urN -X /usr/people/jes/exclude-linux orig/linux-2.6.0-test10/arch/ia64/kernel/smp.c linux-2.6.0-test10/arch/ia64/kernel/smp.c
> --- orig/linux-2.6.0-test10/arch/ia64/kernel/smp.c	Sun Nov 23 17:33:24 2003
> +++ linux-2.6.0-test10/arch/ia64/kernel/smp.c	Wed Nov 26 05:57:32 2003
> @@ -205,6 +205,55 @@
>  	platform_send_ipi(cpu, IA64_IPI_RESCHEDULE, IA64_IPI_DM_INT, 0);
>  }
>  
> +
> +/*
> + * Call a function on all processors
> + */
> +static inline int on_each_cpu_masked(void (*func) (void *info), void *info,
> +				     int retry, int wait, cpumask_t cpumask)
> +{
> +	cpumask_t tmp;
> +	struct call_data_struct data;
> +	int ret = 0;
> +	int cpus = 0;
> +	int i;
> +
> +	cpus_and(tmp, cpumask, cpu_online_map);
> +
> +	data.func = func;
> +	data.info = info;
> +	atomic_set(&data.started, 0);
> +	data.wait = wait;
> +	if (wait)
> +		atomic_set(&data.finished, 0);
> +
> +	get_cpu();
> +	spin_lock_bh(&call_lock);
> +
> +	call_data = &data;
> +	mb();	/* ensure store to call_data precedes setting of IPI_CALL_FUNC */
> +	for (i = 0; i < NR_CPUS; i++) {
> +		if (cpu_isset(i, tmp), cpu_online(i)) {
> +			cpus++;
> +			send_IPI_single(i, IPI_CALL_FUNC);
> +		}
> +	}
> +
> +	/* Wait for response */
> +	while (atomic_read(&data.started) != cpus)
> +		barrier();
> +
> +	if (wait)
> +		while (atomic_read(&data.finished) != cpus)
> +			barrier();
> +	call_data = NULL;
> +
> +	spin_unlock_bh(&call_lock);
> +	put_cpu();
> +	return ret;
> +}
> +
> +
>  void
>  smp_flush_tlb_all (void)
>  {
> @@ -228,7 +277,12 @@
>  	 * anyhow, and once a CPU is interrupted, the cost of local_flush_tlb_all() is
>  	 * rather trivial.
>  	 */
> +#if 0
>  	on_each_cpu((void (*)(void *))local_finish_flush_tlb_mm, mm, 1, 1);
> +#else
> +	on_each_cpu_masked((void (*)(void *))local_finish_flush_tlb_mm, mm,
> +			   1, 1, mm->cpu_vm_mask);
> +#endif
>  }
>  
>  /*
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


