From: Thomas Gleixner <tglx@linutronix.de>
Date: Wed, 08 Sep 2010 18:14:14 +0000
Subject: [RFC trollpatch 1/1] genirq: Remove the fits all and nothing
Message-Id: <20100908152036.643594727@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Christoph Hellwig <hch@infradead.org>, linux-alpha@vger.kernel.org, linux-cris-kernel@axis.com, Haavard Skinnemoen <hskinnemoen@atmel.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Hirokazu Takata <takata@linux-m32r.org>, Greg Ungerer <gerg@uclinux.org>, Jeff Dike <jdike@addtoit.com>, linux-parisc@vger.kernel.org, Chris Zankel <chris@zankel.net>, linux-arch@vger.kernel.org

__do_IRQ() has been deprecated after a two years migration phase in
commit 0e57aa1. Since then another 18 month have gone by.

So here's the status three and a half years after the flow based
infrastructure was merged:

 The following architectures are fully converted to the new flow
 handler code:

  arm, avr32, blackfin, frv, microblaze, mips, mn10300, powerpc, score, sh,
  sparc 64bit, tile, x86, xtensa

  (avr32 and xtensa should set CONFIG_GENERIC_HARDIRQS_NO__DO_IRQ
  though)

 The following architectures are not using the generic interrupt
 infrastructure at all and are therefor unaffected:

  s390, m68k, sparc 32bit

 The following architectures are still using __do_IRQ():

  alpha, cris, ia64, h8300, m32r, m68knommu, parisc, um

So now the question arises what to do with __do_IRQ().

Removing it would be the right thing, but that'll break 8 archs, so
it's probably not considered a good idea, though for most of them the
conversion should be reasonably trivial.

I'm happy to move that code into kernel/irq/cruft.c forever if there
is no way to get the remaining users converted in the forseeable
future. It looks like they can cope with the annoying build warning
nicely.

Either that or moving everything what breaks into staging/arch/* and
hand it over to GregKH :)

Thoughts ?

Not-Signed-off-by-yet: Thomas Gleixner <tglx@linutronix.de>

---
 Documentation/DocBook/genericirq.tmpl      |   29 -------
 Documentation/feature-removal-schedule.txt |    8 --
 include/linux/irq.h                        |   20 -----
 kernel/irq/handle.c                        |  111 -----------------------------
 4 files changed, 2 insertions(+), 166 deletions(-)

Index: linux-2.6/Documentation/DocBook/genericirq.tmpl
=================================--- linux-2.6.orig/Documentation/DocBook/genericirq.tmpl
+++ linux-2.6/Documentation/DocBook/genericirq.tmpl
@@ -147,13 +147,6 @@
 	use a generic irq-flow implementation for 'level type' interrupts
 	and add a (sub)architecture specific 'edge type' implementation.
 	</para>
-	<para>
-	To make the transition to the new model easier and prevent the
-	breakage of existing implementations, the __do_IRQ() super-handler
-	is still available. This leads to a kind of duality for the time
-	being. Over time the new model should be used in more and more
-	architectures, as it enables smaller and cleaner IRQ subsystems.
-	</para>
   </chapter>
   <chapter id="bugs">
     <title>Known Bugs And Assumptions</title>
@@ -402,28 +395,6 @@ desc->chip->end();
     </sect1>
   </chapter>
 
-  <chapter id="doirq">
-     <title>__do_IRQ entry point</title>
-     <para>
- 	The original implementation __do_IRQ() is an alternative entry
-	point for all types of interrupts.
-     </para>
-     <para>
-	This handler turned out to be not suitable for all
-	interrupt hardware and was therefore reimplemented with split
-	functionality for egde/level/simple/percpu interrupts. This is not
-	only a functional optimization. It also shortens code paths for
-	interrupts.
-      </para>
-      <para>
-	To make use of the split implementation, replace the call to
-	__do_IRQ by a call to desc->handle_irq() and associate
-        the appropriate handler function to desc->handle_irq().
-	In most cases the generic handler implementations should
-	be sufficient.
-     </para>
-  </chapter>
-
   <chapter id="locking">
      <title>Locking on SMP</title>
      <para>
Index: linux-2.6/Documentation/feature-removal-schedule.txt
=================================--- linux-2.6.orig/Documentation/feature-removal-schedule.txt
+++ linux-2.6/Documentation/feature-removal-schedule.txt
@@ -315,14 +315,6 @@ Who:	Dave Jones <davej@redhat.com>, Matt
 
 -----------------------------
 
-What:	__do_IRQ all in one fits nothing interrupt handler
-When:	2.6.32
-Why:	__do_IRQ was kept for easy migration to the type flow handlers.
-	More than two years of migration time is enough.
-Who:	Thomas Gleixner <tglx@linutronix.de>
-
------------------------------
-
 What:	fakephp and associated sysfs files in /sys/bus/pci/slots/
 When:	2011
 Why:	In 2.6.27, the semantics of /sys/bus/pci/slots was redefined to
Index: linux-2.6/include/linux/irq.h
=================================--- linux-2.6.orig/include/linux/irq.h
+++ linux-2.6/include/linux/irq.h
@@ -150,7 +150,7 @@ struct irq_2_iommu;
  * @timer_rand_state:	pointer to timer rand state struct
  * @kstat_irqs:		irq stats per cpu
  * @irq_2_iommu:	iommu with this irq
- * @handle_irq:		highlevel irq-events handler [if NULL, __do_IRQ()]
+ * @handle_irq:		highlevel irq-events handler
  * @chip:		low level interrupt hardware access
  * @msi_desc:		MSI descriptor
  * @handler_data:	per-IRQ data for the irq_chip methods
@@ -294,28 +294,12 @@ extern void handle_bad_irq(unsigned int 
 extern void handle_nested_irq(unsigned int irq);
 
 /*
- * Monolithic do_IRQ implementation.
- */
-#ifndef CONFIG_GENERIC_HARDIRQS_NO__DO_IRQ
-extern unsigned int __do_IRQ(unsigned int irq);
-#endif
-
-/*
  * Architectures call this to let the generic IRQ layer
- * handle an interrupt. If the descriptor is attached to an
- * irqchip-style controller then we call the ->handle_irq() handler,
- * and it calls __do_IRQ() if it's attached to an irqtype-style controller.
+ * handle an interrupt.
  */
 static inline void generic_handle_irq_desc(unsigned int irq, struct irq_desc *desc)
 {
-#ifdef CONFIG_GENERIC_HARDIRQS_NO__DO_IRQ
 	desc->handle_irq(irq, desc);
-#else
-	if (likely(desc->handle_irq))
-		desc->handle_irq(irq, desc);
-	else
-		__do_IRQ(irq);
-#endif
 }
 
 static inline void generic_handle_irq(unsigned int irq)
Index: linux-2.6/kernel/irq/handle.c
=================================--- linux-2.6.orig/kernel/irq/handle.c
+++ linux-2.6/kernel/irq/handle.c
@@ -426,117 +426,6 @@ irqreturn_t handle_IRQ_event(unsigned in
 	return retval;
 }
 
-#ifndef CONFIG_GENERIC_HARDIRQS_NO__DO_IRQ
-
-#ifdef CONFIG_ENABLE_WARN_DEPRECATED
-# warning __do_IRQ is deprecated. Please convert to proper flow handlers
-#endif
-
-/**
- * __do_IRQ - original all in one highlevel IRQ handler
- * @irq:	the interrupt number
- *
- * __do_IRQ handles all normal device IRQ's (the special
- * SMP cross-CPU interrupts have their own specific
- * handlers).
- *
- * This is the original x86 implementation which is used for every
- * interrupt type.
- */
-unsigned int __do_IRQ(unsigned int irq)
-{
-	struct irq_desc *desc = irq_to_desc(irq);
-	struct irqaction *action;
-	unsigned int status;
-
-	kstat_incr_irqs_this_cpu(irq, desc);
-
-	if (CHECK_IRQ_PER_CPU(desc->status)) {
-		irqreturn_t action_ret;
-
-		/*
-		 * No locking required for CPU-local interrupts:
-		 */
-		if (desc->chip->ack)
-			desc->chip->ack(irq);
-		if (likely(!(desc->status & IRQ_DISABLED))) {
-			action_ret = handle_IRQ_event(irq, desc->action);
-			if (!noirqdebug)
-				note_interrupt(irq, desc, action_ret);
-		}
-		desc->chip->end(irq);
-		return 1;
-	}
-
-	raw_spin_lock(&desc->lock);
-	if (desc->chip->ack)
-		desc->chip->ack(irq);
-	/*
-	 * REPLAY is when Linux resends an IRQ that was dropped earlier
-	 * WAITING is used by probe to mark irqs that are being tested
-	 */
-	status = desc->status & ~(IRQ_REPLAY | IRQ_WAITING);
-	status |= IRQ_PENDING; /* we _want_ to handle it */
-
-	/*
-	 * If the IRQ is disabled for whatever reason, we cannot
-	 * use the action we have.
-	 */
-	action = NULL;
-	if (likely(!(status & (IRQ_DISABLED | IRQ_INPROGRESS)))) {
-		action = desc->action;
-		status &= ~IRQ_PENDING; /* we commit to handling */
-		status |= IRQ_INPROGRESS; /* we are handling it */
-	}
-	desc->status = status;
-
-	/*
-	 * If there is no IRQ handler or it was disabled, exit early.
-	 * Since we set PENDING, if another processor is handling
-	 * a different instance of this same irq, the other processor
-	 * will take care of it.
-	 */
-	if (unlikely(!action))
-		goto out;
-
-	/*
-	 * Edge triggered interrupts need to remember
-	 * pending events.
-	 * This applies to any hw interrupts that allow a second
-	 * instance of the same irq to arrive while we are in do_IRQ
-	 * or in the handler. But the code here only handles the _second_
-	 * instance of the irq, not the third or fourth. So it is mostly
-	 * useful for irq hardware that does not mask cleanly in an
-	 * SMP environment.
-	 */
-	for (;;) {
-		irqreturn_t action_ret;
-
-		raw_spin_unlock(&desc->lock);
-
-		action_ret = handle_IRQ_event(irq, action);
-		if (!noirqdebug)
-			note_interrupt(irq, desc, action_ret);
-
-		raw_spin_lock(&desc->lock);
-		if (likely(!(desc->status & IRQ_PENDING)))
-			break;
-		desc->status &= ~IRQ_PENDING;
-	}
-	desc->status &= ~IRQ_INPROGRESS;
-
-out:
-	/*
-	 * The ->end() handler has to deal with interrupts which got
-	 * disabled while the handler was running.
-	 */
-	desc->chip->end(irq);
-	raw_spin_unlock(&desc->lock);
-
-	return 1;
-}
-#endif
-
 void early_init_irq_lock_class(void)
 {
 	struct irq_desc *desc;


