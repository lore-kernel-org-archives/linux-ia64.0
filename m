From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Mon, 26 Apr 2004 03:28:41 +0000
Subject: RE: [RFC IA64 Hotplug] [Patch 7/7] migrate_irq.patch
Message-Id: <MDEEKOKJPMPMKGHIFAMAMELMDNAA.kaneshige.kenji@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <ORSMSX404NsokLQ8aZR00000175@orsmsx404.amr.corp.intel.com>
In-Reply-To: <ORSMSX404NsokLQ8aZR00000175@orsmsx404.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Ashok,

I think some parts of your patch are required not only to support
CPU removal, but also to fix the following problem of IRQ affinity of
current ia64 linux :)

Current irq_affinity_write_proc() changes unmasked RTEs by force.
But I think it is dangerous because it might cause a race condition
if some interrupts are generated while changing the RTE. 

Your patch solves this problem by changing the RTE while the
interrupt is pending, doesn't it?

Thanks,
Kenji Kaneshige


> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org 
> [mailto:linux-ia64-owner@vger.kernel.org]On Behalf Of Ashok Raj
> Sent: Sunday, April 25, 2004 3:47 PM
> To: LHCS list
> Cc: linux-ia64@vger.kernel.org; davidm@hpl.hp.com; akpm@osdl.org; 
> Rusty Russell; Luck, Tony; Mallick, Asit K; Saxena, Sunil; Shah, Rajesh
> Subject: [RFC IA64 Hotplug] [Patch 7/7] migrate_irq.patch
> 
> 
> Patch 7/7
> 
> Cheers,
> ashok raj
> - Linux Core Software Group
>    
> 
> 
> Name: migrate_irq.patch
> Author: Ashok Raj (Intel Corporation)
> D: This patch adds interrupt migration necessary for supporting 
> CPU removal
> in IA64.
> D: Devices dont stop generating interrupts, and some special handling is
> required to 
> D: ensure the kernel does not loose interrupt events in the process of
> D: migrating interrupt destinations to different target cpu's. For proper
> D: functioning, we need to disable platform level interrupt redirection.
> D: Rest is in code for review. To test, i manually migrated network, disk
> D: interrupts to cpu3 and removed it later, interrupts should now start
> D: on first online cpu (i.e the boot cpu). At time of release worked fine
> for
> D: 24+ hrs without any panics and hangs.
> 
> 
> ---
> 
>  linux-2.6.5-lhcs-root/arch/ia64/kernel/iosapic.c  |   28 +++++
>  linux-2.6.5-lhcs-root/arch/ia64/kernel/irq.c      |  114
> ++++++++++++++++++----
>  linux-2.6.5-lhcs-root/arch/ia64/kernel/irq_ia64.c |   60 ++++++++++-
>  linux-2.6.5-lhcs-root/arch/ia64/kernel/sal.c      |   13 ++
>  4 files changed, 190 insertions(+), 25 deletions(-)
> 
> diff -puN arch/ia64/kernel/irq.c~migrate_irq arch/ia64/kernel/irq.c
> --- linux-2.6.5-lhcs/arch/ia64/kernel/irq.c~migrate_irq	2004-04-23
> 23:11:22.976199926 -0700
> +++ linux-2.6.5-lhcs-root/arch/ia64/kernel/irq.c	2004-04-23
> 23:11:22.982059304 -0700
> @@ -8,6 +8,12 @@
>   * instead of just grabbing them. Thus setups with different IRQ numbers
>   * shouldn't result in any weird surprises, and installing new handlers
>   * should be easier.
> + *
> + * Copyright (C) Ashok Raj<ashok.raj@intel.com>, Intel Corporation 2004
> + *
> + * 4/14/2004: Added code to handle cpu migration and do safe irq
> + *			migration without lossing interrupts for iosapic
> + *			architecture.
>   */
>  
>  /*
> @@ -49,8 +55,9 @@
>  #include <asm/irq.h>
>  #include <asm/tlbflush.h>
>  #include <asm/cpu.h>
> +#include <asm/bug.h>
>  
> -
> +extern cpumask_t	__cacheline_aligned pending_irq_cpumask[NR_IRQS];
>  
>  /*
>   * Linux has a controller-independent x86 interrupt architecture.
> @@ -943,10 +950,14 @@ void set_irq_affinity_info (unsigned int
>  static int irq_affinity_read_proc (char *page, char **start, off_t off,
>  			int count, int *eof, void *data)
>  {
> -	int len = cpumask_scnprintf(page, count, irq_affinity[(long)data]);
> +	extern void print_rte(unsigned int irq);
> +	int len = sprintf(page, "%s", irq_redir[(long)data] ? "r " : "");
> +
> +	len += cpumask_scnprintf(page+len, count, irq_affinity[(long)data]);
>  	if (count - len < 2)
>  		return -EINVAL;
>  	len += sprintf(page + len, "\n");
> +
>  	return len;
>  }
>  
> @@ -961,6 +972,7 @@ static int irq_affinity_write_proc (stru
>  	int rlen;
>  	int prelen;
>  	irq_desc_t *desc = irq_descp(irq);
> +	unsigned long flags;
>  
>  	if (!desc->handler->set_affinity)
>  		return -EIO;
> @@ -999,40 +1011,106 @@ static int irq_affinity_write_proc (stru
>  	if (cpus_empty(tmp))
>  		return -EINVAL;
>  
> -	desc->handler->set_affinity(irq, new_value);
> +	spin_lock_irqsave(&desc->lock, flags);
> +	pending_irq_cpumask[irq] = new_value;
> +	spin_unlock_irqrestore(&desc->lock, flags);
> +
>  	return full_count;
>  }
>  
>  #endif /* CONFIG_SMP */
>  
>  #ifdef CONFIG_HOTPLUG_CPU
> -void fixup_irqs(void)
> +unsigned int vectors_in_migration[NR_IRQS];
> +
> +/*
> + * Since cpu_online_map is already updated, we just need to check for
> + * affinity that has zeros
> + */
> +static void migrate_irqs(void)
>  {
>  	cpumask_t	mask;
> -	unsigned int irq, redir;
>  	irq_desc_t *desc;
> -	static int warned;
> +	int 		irq, new_cpu;
> +
> +	for (irq=0; irq < NR_IRQS; irq++) {
> +		desc = irq_descp(irq);
> +
> +		/*
> +		 * No handling for now.
> +		 * TBD: Implement a disable function so we can now
> +		 * tell CPU not to respond to these local intr sources.
> +		 * such as ITV,CPEI,MCA etc.
> +		 */
> +		if (desc->status = IRQ_PER_CPU)
> +			continue;
>  
> -	for (irq = 0; irq < NR_IRQS; irq++) {
>  		cpus_and(mask, irq_affinity[irq], cpu_online_map);
>  		if (any_online_cpu(mask) = NR_CPUS) {
> -			printk("Breaking affinity for irq %ui\n", irq);
> -			mask = any_online_cpu(cpu_online_map);
> +			/*
> +			 * Save it for phase 2 processing
> +			 */
> +			vectors_in_migration[irq] = irq;
> +
> +			new_cpu = any_online_cpu(cpu_online_map);
> +			mask = cpumask_of_cpu(new_cpu);
> +
> +			/*
> +			 * Al three are essential, currently WARN_ON.. maybe
> panic?
> +			 */
> +			if (desc->handler && desc->handler->disable &&
> +				desc->handler->enable &&
> desc->handler->set_affinity) {
> +				desc->handler->disable(irq);
> +				desc->handler->set_affinity(irq, mask);
> +				desc->handler->enable(irq);
> +			} else {
> +				WARN_ON((!(desc->handler) ||
> !(desc->handler->disable) ||
> +						!(desc->handler->enable) ||
> +
> !(desc->handler->set_affinity)));
> +			}
>  		}
> -		desc = irq_descp(irq);
> -		if (desc->handler->set_affinity) {
> -			redir = irq_redir[irq];
> -			desc->handler->set_affinity(irq | (redir ?
> IA64_IRQ_REDIRECTED : 0),
> -
> mask);
> +	}
> +}
> +
> +void fixup_irqs(void)
> +{
> +	unsigned int irq;
> +	extern void ia64_process_pending_intr(void);
> +
> +	ia64_set_itv(1<<16);
> +	/*
> +	 * Phase 1: Locate irq's bound to this cpu and
> +	 * relocate them for cpu removal.
> +	 */
> +	migrate_irqs();
> +
> +	/*
> +	 * Phase 2: Perform interrupt processing for all entries reported in
> +	 * local APIC.
> +	 */
> +	ia64_process_pending_intr();
> +
> +	/*
> +	 * Phase 3: Now handle any interrupts not captured in local APIC.
> +	 * This is to account for cases that device interrupted during the
> time the
> +	 * rte was being disabled and re-programmed.
> +	 */
> +	for (irq=0; irq < NR_IRQS; irq++) {
> +		if (vectors_in_migration[irq]) {
> +			vectors_in_migration[irq]=0;
> +			do_IRQ(irq, NULL);
>  		}
> -		else if (desc->action && !(warned++))
> -			printk("Cannot set affinity for irq %i\n", irq);
>  	}
> +
> +	/*
> +	 * Now let processor die. We do irq disable and max_xtp() to
> +	 * ensure there is no more interrupts routed to this processor.
> +	 * But the local timer interrupt can have 1 pending which we
> +	 * take care in timer_interrupt().
> +	 */
>  	max_xtp();
>  	local_irq_disable();
> -	__get_cpu_var(cpu_state) = CPU_DEAD;
>  }
> -
>  #endif
>  
>  static int prof_cpu_mask_read_proc (char *page, char **start, off_t off,
> diff -puN arch/ia64/kernel/irq_ia64.c~migrate_irq
> arch/ia64/kernel/irq_ia64.c
> --- linux-2.6.5-lhcs/arch/ia64/kernel/irq_ia64.c~migrate_irq	2004-04-23
> 23:11:22.977176489 -0700
> +++ linux-2.6.5-lhcs-root/arch/ia64/kernel/irq_ia64.c	2004-04-23
> 23:11:22.983035867 -0700
> @@ -10,6 +10,8 @@
>   *
>   * 09/15/00 Goutham Rao <goutham.rao@intel.com> Implemented
> pci_irq_to_vector
>   *                      PCI to vector allocation routine.
> + * 04/14/2004 Ashok Raj <ashok.raj@intel.com>
> + *						Added CPU Hotplug handling
> for IPF.
>   */
>  
>  #include <linux/config.h>
> @@ -85,6 +87,11 @@ ia64_alloc_vector (void)
>  
>  extern unsigned int do_IRQ(unsigned long irq, struct pt_regs *regs);
>  
> +#ifdef CONFIG_SMP
> +#	define IS_RESCHEDULE(vec)	(vec = IA64_IPI_RESCHEDULE)
> +#else
> +#	define IS_RESCHEDULE(vec)	(0)
> +#endif
>  /*
>   * That's where the IVT branches when we get an external
>   * interrupt. This branches to the correct hardware IRQ handler via
> @@ -94,11 +101,6 @@ void
>  ia64_handle_irq (ia64_vector vector, struct pt_regs *regs)
>  {
>  	unsigned long saved_tpr;
> -#ifdef CONFIG_SMP
> -#	define IS_RESCHEDULE(vec)	(vec = IA64_IPI_RESCHEDULE)
> -#else
> -#	define IS_RESCHEDULE(vec)	(0)
> -#endif
>  
>  #if IRQ_DEBUG
>  	{
> @@ -162,6 +164,54 @@ ia64_handle_irq (ia64_vector vector, str
>  	irq_exit();
>  }
>  
> +#ifdef CONFIG_HOTPLUG_CPU
> +/*
> + * This function emulates a interrupt processing when a cpu is 
> about to be
> + * brought down.
> + */
> +void ia64_process_pending_intr(void)
> +{
> +	ia64_vector vector;
> +	unsigned long saved_tpr;
> +	extern unsigned int vectors_in_migration[NR_IRQS];
> +
> +	vector = ia64_get_ivr();
> +
> +	 irq_enter();
> +	 saved_tpr = ia64_getreg(_IA64_REG_CR_TPR);
> +	 ia64_srlz_d();
> +
> +	 /*
> +	  * Perform normal interrupt style processing
> +	  */
> +	while (vector != IA64_SPURIOUS_INT_VECTOR) {
> +		if (!IS_RESCHEDULE(vector)) {
> +			ia64_setreg(_IA64_REG_CR_TPR, vector);
> +			ia64_srlz_d();
> +
> +			/*
> +			 * Now try calling normal ia64_handle_irq as it
> would have got called
> +			 * from a real intr handler. Try passing null for
> pt_regs, hopefully
> +			 * it will work. I hope it works!.
> +			 * Probably could shared code.
> +			 */
> +			vectors_in_migration[local_vector_to_irq(vector)]=0;
> +			do_IRQ(local_vector_to_irq(vector), NULL);
> +
> +			/*
> +			 * Disable interrupts and send EOI
> +			 */
> +			local_irq_disable();
> +			ia64_setreg(_IA64_REG_CR_TPR, saved_tpr);
> +		}
> +		ia64_eoi();
> +		vector = ia64_get_ivr();
> +	}
> +	irq_exit();
> +}
> +#endif
> +
> +
>  #ifdef CONFIG_SMP
>  extern irqreturn_t handle_IPI (int irq, void *dev_id, struct pt_regs
> *regs);
>  
> diff -puN arch/ia64/kernel/iosapic.c~migrate_irq 
> arch/ia64/kernel/iosapic.c
> --- linux-2.6.5-lhcs/arch/ia64/kernel/iosapic.c~migrate_irq	2004-04-23
> 23:11:22.979129615 -0700
> +++ linux-2.6.5-lhcs-root/arch/ia64/kernel/iosapic.c	2004-04-23
> 23:11:22.983035867 -0700
> @@ -32,6 +32,8 @@
>   * 03/02/19	B. Helgaas	Make pcat_compat system-wide, not
> per-IOSAPIC.
>   *				Remove iosapic_address & gsi_base from
> external interfaces.
>   *				Rationalize __init/__devinit attributes.
> + * 04/12/04 Ashok Raj	<ashok.raj@intel.com> Intel Corporation 2004
> + *				Updated to work with irq migration necessary
> for CPU Hotplug
>   */
>  /*
>   * Here is what the interrupt logic between a PCI device and the kernel
> looks like:
> @@ -99,6 +101,8 @@
>  
>  static spinlock_t iosapic_lock = SPIN_LOCK_UNLOCKED;
>  
> +cpumask_t	__cacheline_aligned pending_irq_cpumask[NR_IRQS];
> +
>  /* These tables map IA-64 vectors to the IOSAPIC pin that generates this
> vector. */
>  
>  static struct iosapic_intr_info {
> @@ -188,8 +192,10 @@ set_rte (unsigned int vector, unsigned i
>  	pol     = iosapic_intr_info[vector].polarity;
>  	trigger = iosapic_intr_info[vector].trigger;
>  	dmode   = iosapic_intr_info[vector].dmode;
> +	vector &= (~IA64_IRQ_REDIRECTED);
>  
>  	redir = (dmode = IOSAPIC_LOWEST_PRIORITY) ? 1 : 0;
> +
>  #ifdef CONFIG_SMP
>  	{
>  		unsigned int irq;
> @@ -307,9 +313,8 @@ iosapic_set_affinity (unsigned int irq, 
>  
>  	spin_lock_irqsave(&iosapic_lock, flags);
>  	{
> -		/* get current delivery mode by reading the low32 */
> -		writel(IOSAPIC_RTE_LOW(rte_index), addr +
> IOSAPIC_REG_SELECT);
>  		low32 = iosapic_intr_info[vec].low32 & ~(7 <<
> IOSAPIC_DELIVERY_SHIFT);
> +
>  		if (redir)
>  		        /* change delivery mode to lowest priority */
>  			low32 |= (IOSAPIC_LOWEST_PRIORITY <<
> IOSAPIC_DELIVERY_SHIFT);
> @@ -327,6 +332,21 @@ iosapic_set_affinity (unsigned int irq, 
>  #endif
>  }
>  
> +static inline void move_irq(int irq)
> +{
> +	/* note - we hold desc->lock */
> +	cpumask_t tmp;
> +	irq_desc_t *desc = irq_descp(irq);
> +
> +	if (!cpus_empty(pending_irq_cpumask[irq])) {
> +		cpus_and(tmp, pending_irq_cpumask[irq], cpu_online_map);
> +		if (unlikely(!cpus_empty(tmp))) {
> +			desc->handler->set_affinity(irq,
> pending_irq_cpumask[irq]);
> +		}
> +		cpus_clear(pending_irq_cpumask[irq]);
> +	}
> +}
> +
>  /*
>   * Handlers for level-triggered interrupts.
>   */
> @@ -343,6 +363,8 @@ iosapic_end_level_irq (unsigned int irq)
>  {
>  	ia64_vector vec = irq_to_vector(irq);
>  
> +	move_irq(irq);
> +
>  	writel(vec, iosapic_intr_info[vec].addr + IOSAPIC_EOI);
>  }
>  
> @@ -382,6 +404,8 @@ static void
>  iosapic_ack_edge_irq (unsigned int irq)
>  {
>  	irq_desc_t *idesc = irq_descp(irq);
> +
> +	move_irq(irq);
>  	/*
>  	 * Once we have recorded IRQ_PENDING already, we can mask the
>  	 * interrupt for real. This prevents IRQ storms from unhandled
> diff -puN arch/ia64/kernel/sal.c~migrate_irq arch/ia64/kernel/sal.c
> --- linux-2.6.5-lhcs/arch/ia64/kernel/sal.c~migrate_irq	2004-04-23
> 23:11:22.980106178 -0700
> +++ linux-2.6.5-lhcs-root/arch/ia64/kernel/sal.c	2004-04-23
> 23:11:22.984012430 -0700
> @@ -122,10 +122,23 @@ sal_desc_entry_point (void *p)
>  static void __init
>  set_smp_redirect (int flag)
>  {
> +#ifndef CONFIG_HOTPLUG_CPU
>  	if (no_int_routing)
>  		smp_int_redirect &= ~flag;
>  	else
>  		smp_int_redirect |= flag;
> +#else
> +	/*
> +	 * For CPU Hotplug we dont want to do any chipset supported
> +	 * interrupt redirection. The reason is this would require that
> +	 * All interrupts be stopped and hard bind the irq to a cpu.
> +	 * Later when the interrupt is fired we need to set the redir hint
> +	 * on again in the vector. This is combersome for something that the
> +	 * user mode irq balancer will solve anyways.
> +	 */
> +	no_int_routing=1;
> +	smp_int_redirect &= ~flag;
> +#endif
>  }
>  #else
>  #define set_smp_redirect(flag)	do { } while (0)
> 
> _
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
