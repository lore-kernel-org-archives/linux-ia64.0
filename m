From: Ingo Molnar <mingo@elte.hu>
Date: Sat, 28 Mar 2009 21:24:34 +0000
Subject: Re: [GIT PULL] percpu, cpumask, x86 updates for v2.6.30
Message-Id: <20090328212434.GA11629@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.LFD.2.00.0903281341100.3994@localhost.localdomain>
In-Reply-To: <alpine.LFD.2.00.0903281341100.3994@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


* Ingo Molnar <mingo@elte.hu> wrote:

> > Ingo, I think you ia64 stuff was broken. It used "vector" to get 
> > to the irq descriptor. Which is not the same as an "irq" at all.
> > 
> > The reason I noticed is that it clashed with the ia64 pull, 
> > which had fixed this up.

that's the fallout of:

  d2287f5: irq: update all arches for new irq_desc, fix

it's this change:

        while (vector != IA64_SPURIOUS_INT_VECTOR) {
+               struct irq_desc *desc = irq_to_desc(vector);
+
                if (unlikely(IS_LOCAL_TLB_FLUSH(vector))) {
                        smp_local_flush_tlb();
-                       kstat_this_cpu.irqs[vector]++;
+                       kstat_incr_irqs_this_cpu(vector, desc);
                } else if (unlikely(IS_RESCHEDULE(vector)))
-                       kstat_this_cpu.irqs[vector]++;
+                       kstat_incr_irqs_this_cpu(vector, desc);

and the original code addressed kstat-irqs (which was a [NR_IRQS] 
array) via 'vector'.

And i think you are right that there is an irq<->vector mismatch 
here. I also think that ia64's use of [vector] there was probably 
buggy to begin with - the kstat array is really addressed by 'irq'.

With the irq_to_desc() change we did above it became even more 
incorrect.

It didnt crash though: this commit has been in linux-next for 2 
months. Maybe nobody noticed because it's "just" about IRQ 
statistics? I have no ia64 box to check though, and the code in 
arch/ia64/kernel/ivt.S looks rather cryptic.

> > 
> > I tried to fix it all up. But I'm just about the last person in 
> > the universe who wants to compile ia64, so I have not tested, or 
> > even been able to see that it compiles.  Somebody should 
> > double-check it.
> 
> Sure, i'm on it, i'll check your resolution of 
> arch/ia64/kernel/irq_ia64.c.

Your version builds fine on ia64 defconfig - and i think the 
resolution you did is correct.

Detail: i _think_ you could have picked the ia64-branch version 
instead of doing a manual resolution - i.e. could have kept the ia64 
version via the patch below. The reason is that IA64 does not 
support SPARSE_IRQ yet. But your resolution is cleaner and 
sparseirq-correct.

	Ingo

diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index acc4d19..977a6ef 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -493,15 +493,16 @@ ia64_handle_irq (ia64_vector vector, struct pt_regs *regs)
 	saved_tpr = ia64_getreg(_IA64_REG_CR_TPR);
 	ia64_srlz_d();
 	while (vector != IA64_SPURIOUS_INT_VECTOR) {
+		struct irq_desc *desc;
 		int irq = local_vector_to_irq(vector);
-		struct irq_desc *desc = irq_to_desc(irq);
 
+		desc = irq_desc + irq;
 		if (unlikely(IS_LOCAL_TLB_FLUSH(vector))) {
 			smp_local_flush_tlb();
 			kstat_incr_irqs_this_cpu(irq, desc);
-		} else if (unlikely(IS_RESCHEDULE(vector))) {
+		} else if (unlikely(IS_RESCHEDULE(vector)))
 			kstat_incr_irqs_this_cpu(irq, desc);
-		} else {
+		else {
 			ia64_setreg(_IA64_REG_CR_TPR, vector);
 			ia64_srlz_d();
 
@@ -552,15 +553,16 @@ void ia64_process_pending_intr(void)
 	  * Perform normal interrupt style processing
 	  */
 	while (vector != IA64_SPURIOUS_INT_VECTOR) {
+		struct irq_desc *desc;
 		int irq = local_vector_to_irq(vector);
-		struct irq_desc *desc = irq_to_desc(irq);
+		desc = irq_desc + irq;
 
 		if (unlikely(IS_LOCAL_TLB_FLUSH(vector))) {
 			smp_local_flush_tlb();
 			kstat_incr_irqs_this_cpu(irq, desc);
-		} else if (unlikely(IS_RESCHEDULE(vector))) {
+		} else if (unlikely(IS_RESCHEDULE(vector)))
 			kstat_incr_irqs_this_cpu(irq, desc);
-		} else {
+		else {
 			struct pt_regs *old_regs = set_irq_regs(NULL);
 
 			ia64_setreg(_IA64_REG_CR_TPR, vector);
