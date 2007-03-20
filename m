From: Bernhard Walle <bwalle@suse.de>
Date: Tue, 20 Mar 2007 14:59:35 +0000
Subject: [PATCH] Fix irqpoll on IA64 (timer interrupt != 0)
Message-Id: <20070320150027.GA18143@strauss.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>

On IA64, the timer interrupt is not (always?) zero as it is on x86 platforms.
Also, the timer interrupt is CPU-local. Two things need to be changed to make
the irqpoll option make also working on IA64:

  o Call note_interrupt() also on CPU-local interrupts in __do_IRQ().
  o Set a variable timer_irq to the value of the timer interrupt
    after the timer interrupt has been registered and assigned.

That requires changes in Linux-generic files. The default of timer_irq is 0, so
the patch doesn't break i386/x86_64. However, other platforms also may also
have a timer interrupt non-equal to zero, so they can also use the new
set_timer_interrupt() function.


Signed-off-by: Bernhard Walle <bwalle@suse.de>
Acked-by: Thomas Gleixner <tglx@linutronix.de>

---
 arch/ia64/kernel/irq_ia64.c |    6 +++++-
 arch/ia64/kernel/time.c     |    6 +++++-
 include/asm-ia64/hw_irq.h   |    2 +-
 include/linux/irq.h         |    3 +++
 kernel/irq/handle.c         |    2 ++
 kernel/irq/spurious.c       |    9 ++++++++-
 6 files changed, 24 insertions(+), 4 deletions(-)

Index: mainline-msi-init/arch/ia64/kernel/irq_ia64.c
=================================--- mainline-msi-init.orig/arch/ia64/kernel/irq_ia64.c
+++ mainline-msi-init/arch/ia64/kernel/irq_ia64.c
@@ -280,11 +280,12 @@ static struct irqaction resched_irqactio
 };
 #endif
 
-void
+int
 register_percpu_irq (ia64_vector vec, struct irqaction *action)
 {
 	irq_desc_t *desc;
 	unsigned int irq;
+	int first_match = -1;
 
 	for (irq = 0; irq < NR_IRQS; ++irq)
 		if (irq_to_vector(irq) = vec) {
@@ -293,7 +294,10 @@ register_percpu_irq (ia64_vector vec, st
 			desc->chip = &irq_type_ia64_lsapic;
 			if (action)
 				setup_irq(irq, action);
+			first_match = irq;
 		}
+
+	return first_match;
 }
 
 void __init
Index: mainline-msi-init/arch/ia64/kernel/time.c
=================================--- mainline-msi-init.orig/arch/ia64/kernel/time.c
+++ mainline-msi-init/arch/ia64/kernel/time.c
@@ -247,7 +247,11 @@ void __devinit ia64_disable_timer(void)
 void __init
 time_init (void)
 {
-	register_percpu_irq(IA64_TIMER_VECTOR, &timer_irqaction);
+	int timer_irq;
+
+	timer_irq = register_percpu_irq(IA64_TIMER_VECTOR, &timer_irqaction);
+	set_timer_interrupt(timer_irq);
+
 	efi_gettimeofday(&xtime);
 	ia64_init_itm();
 
Index: mainline-msi-init/include/linux/irq.h
=================================--- mainline-msi-init.orig/include/linux/irq.h
+++ mainline-msi-init/include/linux/irq.h
@@ -272,6 +272,9 @@ static inline int irq_balancing_disabled
 /* Handle irq action chains: */
 extern int handle_IRQ_event(unsigned int irq, struct irqaction *action);
 
+/* sets the timer interrupt number for irqpoll handling (kernel/irq/spurious.c) */
+extern void set_timer_interrupt(unsigned int irq);
+
 /*
  * Built-in IRQ handlers for various IRQ types,
  * callable via desc->chip->handle_irq()
Index: mainline-msi-init/kernel/irq/spurious.c
=================================--- mainline-msi-init.orig/kernel/irq/spurious.c
+++ mainline-msi-init/kernel/irq/spurious.c
@@ -12,6 +12,7 @@
 #include <linux/interrupt.h>
 
 static int irqfixup __read_mostly;
+static unsigned int timer_irq __read_mostly;
 
 /*
  * Recovery handler for misrouted interrupts.
@@ -146,7 +147,7 @@ void note_interrupt(unsigned int irq, st
 
 	if (unlikely(irqfixup)) {
 		/* Don't punish working computers */
-		if ((irqfixup = 2 && irq = 0) || action_ret = IRQ_NONE) {
+		if ((irqfixup = 2 && irq = timer_irq) || action_ret = IRQ_NONE) {
 			int ok = misrouted_irq(irq);
 			if (action_ret = IRQ_NONE)
 				desc->irqs_unhandled -= ok;
@@ -174,6 +175,12 @@ void note_interrupt(unsigned int irq, st
 	desc->irqs_unhandled = 0;
 }
 
+void set_timer_interrupt(unsigned int irq)
+{
+	timer_irq = irq;
+}
+EXPORT_SYMBOL_GPL(set_timer_interrupt);
+
 int noirqdebug __read_mostly;
 
 int noirqdebug_setup(char *str)
Index: mainline-msi-init/include/asm-ia64/hw_irq.h
=================================--- mainline-msi-init.orig/include/asm-ia64/hw_irq.h
+++ mainline-msi-init/include/asm-ia64/hw_irq.h
@@ -95,7 +95,7 @@ extern int assign_irq_vector (int irq);	
 extern void free_irq_vector (int vector);
 extern int reserve_irq_vector (int vector);
 extern void ia64_send_ipi (int cpu, int vector, int delivery_mode, int redirect);
-extern void register_percpu_irq (ia64_vector vec, struct irqaction *action);
+extern int register_percpu_irq (ia64_vector vec, struct irqaction *action);
 
 static inline void ia64_resend_irq(unsigned int vector)
 {
Index: mainline-msi-init/kernel/irq/handle.c
=================================--- mainline-msi-init.orig/kernel/irq/handle.c
+++ mainline-msi-init/kernel/irq/handle.c
@@ -180,6 +180,8 @@ fastcall unsigned int __do_IRQ(unsigned 
 		if (desc->chip->ack)
 			desc->chip->ack(irq);
 		action_ret = handle_IRQ_event(irq, desc->action);
+		if (!noirqdebug)
+			note_interrupt(irq, desc, action_ret);
 		desc->chip->end(irq);
 		return 1;
 	}
