From: Pat Gefre <pfg@sgi.com>
Date: Tue, 22 Jun 2004 17:58:56 +0000
Subject: Re: [PATCH] fix interrupt rerouting for Altix
Message-Id: <Pine.SGI.3.96.1040622125800.17971N-100000@fsgi900.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200406171546.i5HFk3wF407364@fsgi900.americas.sgi.com>
In-Reply-To: <200406171546.i5HFk3wF407364@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Sure.  I'll apply your change, test it and then send it out.

-- Pat



On Fri, 18 Jun 2004, Ashok Raj wrote:

+ On Fri, Jun 18, 2004 at 01:17:37PM -0400, Jesse Barnes wrote:
+ > This looks like a duplicate of what's in iosapic.c.  Maybe we should just have 
+ > one version of it in irq.c?  Ashok?
+ 
+ Yep.. i think it will be nice to integrate them into irq.c. I have
+ the patch to do that attached below.
+ 
+ Pat, could you go ahead and submit the patch to work with this attached
+ patch? i was not able to apply yours clean, patch reported
+ garbled patch, and i didnt take time to fix it manually...
+ 
+ -
+ Cheers,
+ Ashok Raj
+ - Linux OS Technologies Team
+ 
+ 
+ Signed-off-by: Ashok Raj <ashok.raj@intel.com>
+ 
+ D: This patch makes move_irq() function from iospic.c to irq.c to make this common for
+ D: ia64 archs. Both that use iosapic, and the SN2 versions. 
+ 
+ 
+ ---
+ 
+  linux-2.6.7-root/arch/ia64/kernel/iosapic.c |   16 ----------------
+  linux-2.6.7-root/arch/ia64/kernel/irq.c     |   16 ++++++++++++++++
+  linux-2.6.7-root/include/asm-ia64/irq.h     |    6 ++++++
+  3 files changed, 22 insertions(+), 16 deletions(-)
+ 
+ diff -puN arch/ia64/kernel/irq.c~make_moveirq_common arch/ia64/kernel/irq.c
+ --- linux-2.6.7/arch/ia64/kernel/irq.c~make_moveirq_common	2004-06-18 15:22:57.297836562 -0700
+ +++ linux-2.6.7-root/arch/ia64/kernel/irq.c	2004-06-18 15:22:57.303695940 -0700
+ @@ -1018,6 +1018,22 @@ static int irq_affinity_write_proc (stru
+  	return full_count;
+  }
+  
+ +void move_irq(int irq)
+ +{
+ +	/* note - we hold desc->lock */
+ +	cpumask_t tmp;
+ +	irq_desc_t *desc = irq_descp(irq);
+ +
+ +	if (!cpus_empty(pending_irq_cpumask[irq])) {
+ +		cpus_and(tmp, pending_irq_cpumask[irq], cpu_online_map);
+ +		if (unlikely(!cpus_empty(tmp))) {
+ +			desc->handler->set_affinity(irq, pending_irq_cpumask[irq]);
+ +		}
+ +		cpus_clear(pending_irq_cpumask[irq]);
+ +	}
+ +}
+ +
+ +
+  #endif /* CONFIG_SMP */
+  
+  #ifdef CONFIG_HOTPLUG_CPU
+ diff -puN arch/ia64/kernel/iosapic.c~make_moveirq_common arch/ia64/kernel/iosapic.c
+ --- linux-2.6.7/arch/ia64/kernel/iosapic.c~make_moveirq_common	2004-06-18 15:22:57.298813125 -0700
+ +++ linux-2.6.7-root/arch/ia64/kernel/iosapic.c	2004-06-18 15:22:57.303695940 -0700
+ @@ -100,7 +100,6 @@
+  #endif
+  
+  static spinlock_t iosapic_lock = SPIN_LOCK_UNLOCKED;
+ -extern cpumask_t	__cacheline_aligned pending_irq_cpumask[NR_IRQS];
+  
+  /* These tables map IA-64 vectors to the IOSAPIC pin that generates this vector. */
+  
+ @@ -335,21 +334,6 @@ iosapic_set_affinity (unsigned int irq, 
+  #endif
+  }
+  
+ -static inline void move_irq(int irq)
+ -{
+ -	/* note - we hold desc->lock */
+ -	cpumask_t tmp;
+ -	irq_desc_t *desc = irq_descp(irq);
+ -
+ -	if (!cpus_empty(pending_irq_cpumask[irq])) {
+ -		cpus_and(tmp, pending_irq_cpumask[irq], cpu_online_map);
+ -		if (unlikely(!cpus_empty(tmp))) {
+ -			desc->handler->set_affinity(irq, pending_irq_cpumask[irq]);
+ -		}
+ -		cpus_clear(pending_irq_cpumask[irq]);
+ -	}
+ -}
+ -
+  /*
+   * Handlers for level-triggered interrupts.
+   */
+ diff -puN include/asm-ia64/irq.h~make_moveirq_common include/asm-ia64/irq.h
+ --- linux-2.6.7/include/asm-ia64/irq.h~make_moveirq_common	2004-06-18 15:22:57.300766251 -0700
+ +++ linux-2.6.7-root/include/asm-ia64/irq.h	2004-06-18 15:22:57.303695940 -0700
+ @@ -30,6 +30,12 @@ extern void disable_irq_nosync (unsigned
+  extern void enable_irq (unsigned int);
+  extern void set_irq_affinity_info (unsigned int irq, int dest, int redir);
+  
+ +#ifdef CONFIG_SMP
+ +extern void move_irq(int irq);
+ +#else
+ +#define move_irq(irq)
+ +#endif
+ +
+  struct irqaction;
+  struct pt_regs;
+  int handle_IRQ_event(unsigned int, struct pt_regs *, struct irqaction *);
+ 
+ _
+ 


