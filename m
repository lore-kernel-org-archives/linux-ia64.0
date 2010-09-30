From: Kyle McMartin <kyle@mcmartin.ca>
Date: Thu, 30 Sep 2010 01:26:41 +0000
Subject: Re: [RFC trollpatch 1/1] genirq: Remove the fits all and nothing
Message-Id: <20100930012641.GA2604@bombadil.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100908152036.643594727@linutronix.de>
In-Reply-To: <20100908152036.643594727@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Christoph Hellwig <hch@infradead.org>, linux-alpha@vger.kernel.org, linux-cris-kernel@axis.com, Haavard Skinnemoen <hskinnemoen@atmel.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Hirokazu Takata <takata@linux-m32r.org>, Greg Ungerer <gerg@uclinux.org>, Jeff Dike <jdike@addtoit.com>, linux-parisc@vger.kernel.org, Chris Zankel <chris@zankel.net>, linux-arch@vger.kernel.org, starvik@axis.com, jesper.nilsson@axis.com

On Wed, Sep 08, 2010 at 06:14:14PM -0000, Thomas Gleixner wrote:
> __do_IRQ() has been deprecated after a two years migration phase in
> commit 0e57aa1. Since then another 18 month have gone by.
> 
>  The following architectures are still using __do_IRQ():
> 
>   alpha, cris, ia64, h8300, m32r, m68knommu, parisc, um
> 
> So now the question arises what to do with __do_IRQ().
> 

In penance while I finish testing what I can on parisc this week
(conversion is done, I just need to find time to plug in ancient crap
 and see if it still handles interrupts...) I've killed __do_IRQ on
cris. Sort of. I have no idea if it builds or anything, but it was
pretty low-hanging fruit since it does all its own masking in its
entry point, so as near as I can tell, aside from disabling spurious
irqs, none of the irq_chip handlers aside from affinity are needed
on cris.

(Since it's masking/unmasking itself, it looks like handle_simple_irq
 will work for the common irqs, and on v32 we can use handle_percpu_irq
 for the timer and ipi.)

Visual compilation at least gives me a logical flow that seems generally
sensible.

I'd appreciate a second pair of eyes, and if it's ok, I'll clean it up
and submit it.

regards, Kyle

---

 arch-v10/kernel/irq.c |   26 +++++---------------------
 arch-v32/kernel/irq.c |   49 ++++++++++++-------------------------------------
 kernel/irq.c          |    2 +-
 3 files changed, 18 insertions(+), 59 deletions(-)

diff --git a/arch/cris/arch-v10/kernel/irq.c b/arch/cris/arch-v10/kernel/irq.c
index a0c0df8..07f17ce 100644
--- a/arch/cris/arch-v10/kernel/irq.c
+++ b/arch/cris/arch-v10/kernel/irq.c
@@ -104,16 +104,6 @@ static void (*interrupt[NR_IRQS])(void) = {
 	IRQ31_interrupt
 };
 
-static void enable_crisv10_irq(unsigned int irq);
-
-static unsigned int startup_crisv10_irq(unsigned int irq)
-{
-	enable_crisv10_irq(irq);
-	return 0;
-}
-
-#define shutdown_crisv10_irq	disable_crisv10_irq
-
 static void enable_crisv10_irq(unsigned int irq)
 {
 	crisv10_unmask_irq(irq);
@@ -124,22 +114,16 @@ static void disable_crisv10_irq(unsigned int irq)
 	crisv10_mask_irq(irq);
 }
 
-static void ack_crisv10_irq(unsigned int irq)
-{
-}
-
-static void end_crisv10_irq(unsigned int irq)
+static void crisv10_noop(unsigned int irq)
 {
 }
 
 static struct irq_chip crisv10_irq_type = {
 	.name =        "CRISv10",
-	.startup =     startup_crisv10_irq,
-	.shutdown =    shutdown_crisv10_irq,
-	.enable =      enable_crisv10_irq,
+	.unmask =      enable_crisv10_irq,
+	.mask =        disable_crisv10_irq,
 	.disable =     disable_crisv10_irq,
-	.ack =         ack_crisv10_irq,
-	.end =         end_crisv10_irq,
+	.ack =         crisv10_noop,
 	.set_affinity = NULL
 };
 
@@ -221,7 +205,7 @@ init_IRQ(void)
 
 	/* Initialize IRQ handler descriptors. */
 	for(i = 2; i < NR_IRQS; i++) {
-		irq_desc[i].chip = &crisv10_irq_type;
+		set_irq_chip_and_handler(i, &crisv10_irq_type, handle_simple_irq);
 		set_int_vector(i, interrupt[i]);
 	}
 
diff --git a/arch/cris/arch-v32/kernel/irq.c b/arch/cris/arch-v32/kernel/irq.c
index 2ed48ae..2efc98c 100644
--- a/arch/cris/arch-v32/kernel/irq.c
+++ b/arch/cris/arch-v32/kernel/irq.c
@@ -290,36 +290,6 @@ void crisv32_unmask_irq(int irq)
 	unblock_irq(irq, irq_cpu(irq));
 }
 
-
-static unsigned int startup_crisv32_irq(unsigned int irq)
-{
-	crisv32_unmask_irq(irq);
-	return 0;
-}
-
-static void shutdown_crisv32_irq(unsigned int irq)
-{
-	crisv32_mask_irq(irq);
-}
-
-static void enable_crisv32_irq(unsigned int irq)
-{
-	crisv32_unmask_irq(irq);
-}
-
-static void disable_crisv32_irq(unsigned int irq)
-{
-	crisv32_mask_irq(irq);
-}
-
-static void ack_crisv32_irq(unsigned int irq)
-{
-}
-
-static void end_crisv32_irq(unsigned int irq)
-{
-}
-
 int set_affinity_crisv32_irq(unsigned int irq, const struct cpumask *dest)
 {
 	unsigned long flags;
@@ -330,14 +300,16 @@ int set_affinity_crisv32_irq(unsigned int irq, const struct cpumask *dest)
 	return 0;
 }
 
+static void crisv32_noop(unsigned int irq)
+{
+}
+
 static struct irq_chip crisv32_irq_type = {
 	.name =        "CRISv32",
-	.startup =     startup_crisv32_irq,
-	.shutdown =    shutdown_crisv32_irq,
-	.enable =      enable_crisv32_irq,
-	.disable =     disable_crisv32_irq,
-	.ack =         ack_crisv32_irq,
-	.end =         end_crisv32_irq,
+	.mask =        crisv32_mask_irq,
+	.disable =     crisv32_mask_irq,
+	.unmask =      crisv32_unmask_irq,
+	.ack =         crisv32_noop,
 	.set_affinity = set_affinity_crisv32_irq
 };
 
@@ -472,15 +444,18 @@ init_IRQ(void)
 
 	/* Point all IRQ's to bad handlers. */
 	for (i = FIRST_IRQ, j = 0; j < NR_IRQS; i++, j++) {
-		irq_desc[j].chip = &crisv32_irq_type;
+		set_irq_chip_and_handler(j, &crisv32_irq_type,
+			handle_simple_irq);
 		set_exception_vector(i, interrupt[j]);
 	}
 
         /* Mark Timer and IPI IRQs as CPU local */
 	irq_allocations[TIMER0_INTR_VECT - FIRST_IRQ].cpu = CPU_FIXED;
 	irq_desc[TIMER0_INTR_VECT].status |= IRQ_PER_CPU;
+	set_irq_handler(TIMER0_INTR_VECT, handle_percpu_irq);
 	irq_allocations[IPI_INTR_VECT - FIRST_IRQ].cpu = CPU_FIXED;
 	irq_desc[IPI_INTR_VECT].status |= IRQ_PER_CPU;
+	set_irq_handler(IPI_INTR_VECT, handle_percpu_irq);
 
 	set_exception_vector(0x00, nmi_interrupt);
 	set_exception_vector(0x30, multiple_interrupt);
diff --git a/arch/cris/kernel/irq.c b/arch/cris/kernel/irq.c
index 469f7f9..14d9ce9 100644
--- a/arch/cris/kernel/irq.c
+++ b/arch/cris/kernel/irq.c
@@ -93,7 +93,7 @@ asmlinkage void do_IRQ(int irq, struct pt_regs * regs)
 		printk("do_IRQ: stack overflow: %lX\n", sp);
 		show_stack(NULL, (unsigned long *)sp);
 	}
-	__do_IRQ(irq);
+	generic_handle_irq(irq);
         irq_exit();
 	set_irq_regs(old_regs);
 }
