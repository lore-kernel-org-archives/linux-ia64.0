From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 17 Nov 2004 21:46:57 +0000
Subject: Re: [PATCH] remove dead wood from asm-ia64/hardirq.h
Message-Id: <200411172146.iAHLkvl18768@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041116091408.GA3050@lst.de>
In-Reply-To: <20041116091408.GA3050@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

New version of switch to CONFIG_GENERIC_HARDIRQS.  Lots more
testing on this version:

	tiger_defconfig	built & booted
	sn2_defconfig	built & booted (by Jesse, but I changed more stuff after)
	zx1_defconfig	built and booted (uni-processor)
	sim_defconfig	built
	defconfig	built & booted (on Tiger)

CONFIG_HOTPLUG_CPU=3Dy for many of those builds, but I didn't test that
the code kicking around at the end of arch/ia64/kernel/irq.c still
works.

 arch/ia64/Kconfig           |   11=20
 arch/ia64/kernel/irq.c      |  986 +--------------------------------------=
-----
 arch/ia64/kernel/irq_ia64.c |    2=20
 arch/ia64/sn/kernel/irq.c   |    4=20
 include/asm-ia64/hw_irq.h   |    4=20
 include/asm-ia64/msi.h      |    1=20
 6 files changed, 46 insertions(+), 962 deletions(-)


=3D=3D=3D arch/ia64/Kconfig 1.82 vs edited =3D=3D--- 1.82/arch/ia64/Kconfig=
	2004-09-30 11:49:13 -07:00
+++ edited/arch/ia64/Kconfig	2004-11-16 11:44:44 -08:00
@@ -381,6 +381,17 @@
=20
 source "lib/Kconfig"
=20
+#
+# Use the generic interrupt handling code in kernel/irq/:
+#
+config GENERIC_HARDIRQS
+	bool
+	default y
+
+config GENERIC_IRQ_PROBE
+	bool
+	default y
+
 source "arch/ia64/hp/sim/Kconfig"
=20
 source "arch/ia64/oprofile/Kconfig"
=3D=3D=3D arch/ia64/kernel/irq.c 1.52 vs edited =3D=3D--- 1.52/arch/ia64/ke=
rnel/irq.c	2004-11-16 11:09:53 -08:00
+++ edited/arch/ia64/kernel/irq.c	2004-11-17 11:27:51 -08:00
@@ -16,73 +16,31 @@
  *			architecture.
  */
=20
-/*
- * (mostly architecture independent, will move to kernel/irq.c in 2.5.)
- *
- * IRQs are in fact implemented a bit like signal handlers for the kernel.
- * Naturally it's not a 1:1 relation, but there are similarities.
- */
-
-#include <linux/config.h>
-#include <linux/errno.h>
+#include <asm/delay.h>
+#include <asm/uaccess.h>
 #include <linux/module.h>
-#include <linux/signal.h>
-#include <linux/sched.h>
-#include <linux/ioport.h>
+#include <linux/seq_file.h>
 #include <linux/interrupt.h>
-#include <linux/timex.h>
-#include <linux/slab.h>
-#include <linux/random.h>
-#include <linux/cpu.h>
-#include <linux/ctype.h>
-#include <linux/smp_lock.h>
-#include <linux/init.h>
 #include <linux/kernel_stat.h>
-#include <linux/irq.h>
-#include <linux/proc_fs.h>
-#include <linux/seq_file.h>
-#include <linux/kallsyms.h>
-#include <linux/notifier.h>
-#include <linux/bitops.h>
-
-#include <asm/atomic.h>
-#include <asm/cpu.h>
-#include <asm/io.h>
-#include <asm/smp.h>
-#include <asm/system.h>
-#include <asm/uaccess.h>
-#include <asm/pgalloc.h>
-#include <asm/tlbflush.h>
-#include <asm/delay.h>
-#include <asm/irq.h>
-
=20
 /*
- * Linux has a controller-independent x86 interrupt architecture.
- * every controller has a 'controller-template', that is used
- * by the main code to do the right thing. Each driver-visible
- * interrupt source is transparently wired to the appropriate
- * controller. Thus drivers need not be aware of the
- * interrupt-controller.
- *
- * Various interrupt controllers we handle: 8259 PIC, SMP IO-APIC,
- * PIIX4's internal 8259 PIC and SGI's Visual Workstation Cobalt (IO-)APIC.
- * (IO-APICs assumed to be messaging to Pentium local-APICs)
- *
- * the code is designed to be easily extended with new/different
- * interrupt controllers, without having to do assembly magic.
+ * 'what should we do if we get a hw irq event on an illegal vector'.
+ * each architecture has to answer this themselves.
  */
+void ack_bad_irq(unsigned int irq)
+{
+	printk(KERN_ERR "Unexpected irq vector 0x%x on CPU %u!\n", irq, smp_proce=
ssor_id());
+}
=20
 /*
- * Controller mappings for all interrupt sources:
+ * do_IRQ handles all normal device IRQ's (the special
+ * SMP cross-CPU interrupts have their own specific
+ * handlers).
  */
-irq_desc_t _irq_desc[NR_IRQS] __cacheline_aligned =3D {
-	[0 ... NR_IRQS-1] =3D {
-		.status =3D IRQ_DISABLED,
-		.handler =3D &no_irq_type,
-		.lock =3D SPIN_LOCK_UNLOCKED
-	}
-};
+unsigned int do_IRQ(unsigned long irq, struct pt_regs *regs)
+{
+	return __do_IRQ(irq, regs);
+}
=20
 #ifdef CONFIG_SMP
 /*
@@ -95,7 +53,7 @@
 #ifdef CONFIG_IA64_GENERIC
 irq_desc_t * __ia64_irq_desc (unsigned int irq)
 {
-	return _irq_desc + irq;
+	return irq_desc + irq;
 }
=20
 ia64_vector __ia64_irq_to_vector (unsigned int irq)
@@ -109,82 +67,24 @@
 }
 #endif
=20
-static void register_irq_proc (unsigned int irq);
-
 /*
- * Special irq handlers.
+ * Interrupt statistics:
  */
=20
-irqreturn_t no_action(int cpl, void *dev_id, struct pt_regs *regs)
-{ return IRQ_NONE; }
-
-/*
- * Generic no controller code
- */
-
-static void enable_none(unsigned int irq) { }
-static unsigned int startup_none(unsigned int irq) { return 0; }
-static void disable_none(unsigned int irq) { }
-static void ack_none(unsigned int irq)
-{
-/*
- * 'what should we do if we get a hw irq event on an illegal vector'.
- * each architecture has to answer this themselves, it doesn't deserve
- * a generic callback i think.
- */
-#ifdef CONFIG_X86
-	printk(KERN_ERR "unexpected IRQ trap at vector %02x\n", irq);
-#ifdef CONFIG_X86_LOCAL_APIC
-	/*
-	 * Currently unexpected vectors happen only on SMP and APIC.
-	 * We _must_ ack these because every local APIC has only N
-	 * irq slots per priority level, and a 'hanging, unacked' IRQ
-	 * holds up an irq slot - in excessive cases (when multiple
-	 * unexpected vectors occur) that might lock up the APIC
-	 * completely.
-	 */
-	ack_APIC_irq();
-#endif
-#endif
-#ifdef CONFIG_IA64
-	printk(KERN_ERR "Unexpected irq vector 0x%x on CPU %u!\n", irq, smp_proce=
ssor_id());
-#endif
-}
-
-/* startup is the same as "enable", shutdown is same as "disable" */
-#define shutdown_none	disable_none
-#define end_none	enable_none
-
-struct hw_interrupt_type no_irq_type =3D {
-	"none",
-	startup_none,
-	shutdown_none,
-	enable_none,
-	disable_none,
-	ack_none,
-	end_none
-};
-
 atomic_t irq_err_count;
-#ifdef CONFIG_X86_IO_APIC
-#ifdef APIC_MISMATCH_DEBUG
-atomic_t irq_mis_count;
-#endif
-#endif
=20
 /*
- * Generic, controller-independent functions:
+ * /proc/interrupts printing:
  */
=20
 int show_interrupts(struct seq_file *p, void *v)
 {
-	int j, i =3D *(loff_t *) v;
+	int i =3D *(loff_t *) v, j;
 	struct irqaction * action;
-	irq_desc_t *idesc;
 	unsigned long flags;
=20
 	if (i =3D 0) {
-		seq_puts(p, "           ");
+		seq_printf(p, "           ");
 		for (j=3D0; j<NR_CPUS; j++)
 			if (cpu_online(j))
 				seq_printf(p, "CPU%d       ",j);
@@ -192,9 +92,8 @@
 	}
=20
 	if (i < NR_IRQS) {
-		idesc =3D irq_descp(i);
-		spin_lock_irqsave(&idesc->lock, flags);
-		action =3D idesc->action;
+		spin_lock_irqsave(&irq_desc[i].lock, flags);
+		action =3D irq_desc[i].action;
 		if (!action)
 			goto skip;
 		seq_printf(p, "%3d: ",i);
@@ -205,7 +104,7 @@
 			if (cpu_online(j))
 				seq_printf(p, "%10u ", kstat_cpu(j).irqs[i]);
 #endif
-		seq_printf(p, " %14s", idesc->handler->typename);
+		seq_printf(p, " %14s", irq_desc[i].handler->typename);
 		seq_printf(p, "  %s", action->name);
=20
 		for (action=ACtion->next; action; action =3D action->next)
@@ -213,725 +112,25 @@
=20
 		seq_putc(p, '\n');
 skip:
-		spin_unlock_irqrestore(&idesc->lock, flags);
+		spin_unlock_irqrestore(&irq_desc[i].lock, flags);
 	} else if (i =3D NR_IRQS) {
-#ifdef CONFIG_X86_LOCAL_APIC
+#if defined(CONFIG_X86_LOCAL_APIC)
 		seq_puts(p, "LOC: ");
 		for (j =3D 0; j < NR_CPUS; j++)
 			if (cpu_online(j))
-				seq_printf(p, "%10u ", irq_stat[j].apic_timer_irqs);
+				seq_printf(p, "%10u ",
+					   irq_stat[j].apic_timer_irqs);
 		seq_putc(p, '\n');
 #endif
 		seq_printf(p, "ERR: %10u\n", atomic_read(&irq_err_count));
-#ifdef CONFIG_X86_IO_APIC
-#ifdef APIC_MISMATCH_DEBUG
+#if defined(CONFIG_X86_IO_APIC)
 		seq_printf(p, "MIS: %10u\n", atomic_read(&irq_mis_count));
 #endif
-#endif
 	}
 	return 0;
 }
=20
 #ifdef CONFIG_SMP
-inline void synchronize_irq(unsigned int irq)
-{
-	while (irq_descp(irq)->status & IRQ_INPROGRESS)
-		cpu_relax();
-}
-EXPORT_SYMBOL(synchronize_irq);
-#endif
-
-/*
- * This should really return information about whether
- * we should do bottom half handling etc. Right now we
- * end up _always_ checking the bottom half, which is a
- * waste of time and is not what some drivers would
- * prefer.
- */
-int handle_IRQ_event(unsigned int irq,
-		struct pt_regs *regs, struct irqaction *action)
-{
-	int status =3D 1;	/* Force the "do bottom halves" bit */
-	int ret, retval =3D 0;
-
-	if (!(action->flags & SA_INTERRUPT))
-		local_irq_enable();
-
-	do {
-		ret =3D action->handler(irq, action->dev_id, regs);
-		if (ret =3D IRQ_HANDLED)
-			status |=3D action->flags;
-		retval |=3D ret;
-		action =3D action->next;
-	} while (action);
-	if (status & SA_SAMPLE_RANDOM)
-		add_interrupt_randomness(irq);
-	local_irq_disable();
-	return retval;
-}
-
-static void __report_bad_irq(int irq, irq_desc_t *desc, irqreturn_t action=
_ret)
-{
-	struct irqaction *action;
-
-	if (action_ret !=3D IRQ_HANDLED && action_ret !=3D IRQ_NONE) {
-		printk(KERN_ERR "irq event %d: bogus return value %x\n",
-				irq, action_ret);
-	} else {
-		printk(KERN_ERR "irq %d: nobody cared!\n", irq);
-	}
-	dump_stack();
-	printk(KERN_ERR "handlers:\n");
-	action =3D desc->action;
-	do {
-		printk(KERN_ERR "[<%p>]", action->handler);
-		print_symbol(" (%s)",
-			(unsigned long)action->handler);
-		printk("\n");
-		action =3D action->next;
-	} while (action);
-}
-
-static void report_bad_irq(int irq, irq_desc_t *desc, irqreturn_t action_r=
et)
-{
-	static int count =3D 100;
-
-	if (count) {
-		count--;
-		__report_bad_irq(irq, desc, action_ret);
-	}
-}
-
-static int noirqdebug;
-
-static int __init noirqdebug_setup(char *str)
-{
-	noirqdebug =3D 1;
-	printk("IRQ lockup detection disabled\n");
-	return 1;
-}
-
-__setup("noirqdebug", noirqdebug_setup);
-
-/*
- * If 99,900 of the previous 100,000 interrupts have not been handled then
- * assume that the IRQ is stuck in some manner.  Drop a diagnostic and try=
 to
- * turn the IRQ off.
- *
- * (The other 100-of-100,000 interrupts may have been a correctly-function=
ing
- *  device sharing an IRQ with the failing one)
- *
- * Called under desc->lock
- */
-static void note_interrupt(int irq, irq_desc_t *desc, irqreturn_t action_r=
et)
-{
-	if (action_ret !=3D IRQ_HANDLED) {
-		desc->irqs_unhandled++;
-		if (action_ret !=3D IRQ_NONE)
-			report_bad_irq(irq, desc, action_ret);
-	}
-
-	desc->irq_count++;
-	if (desc->irq_count < 100000)
-		return;
-
-	desc->irq_count =3D 0;
-	if (desc->irqs_unhandled > 99900) {
-		/*
-		 * The interrupt is stuck
-		 */
-		__report_bad_irq(irq, desc, action_ret);
-		/*
-		 * Now kill the IRQ
-		 */
-		printk(KERN_EMERG "Disabling IRQ #%d\n", irq);
-		desc->status |=3D IRQ_DISABLED;
-		desc->handler->disable(irq);
-	}
-	desc->irqs_unhandled =3D 0;
-}
-
-/*
- * Generic enable/disable code: this just calls
- * down into the PIC-specific version for the actual
- * hardware disable after having gotten the irq
- * controller lock.
- */
-
-/**
- *	disable_irq_nosync - disable an irq without waiting
- *	@irq: Interrupt to disable
- *
- *	Disable the selected interrupt line.  Disables and Enables are
- *	nested.
- *	Unlike disable_irq(), this function does not ensure existing
- *	instances of the IRQ handler have completed before returning.
- *
- *	This function may be called from IRQ context.
- */
-
-inline void disable_irq_nosync(unsigned int irq)
-{
-	irq_desc_t *desc =3D irq_descp(irq);
-	unsigned long flags;
-
-	spin_lock_irqsave(&desc->lock, flags);
-	if (!desc->depth++) {
-		desc->status |=3D IRQ_DISABLED;
-		desc->handler->disable(irq);
-	}
-	spin_unlock_irqrestore(&desc->lock, flags);
-}
-EXPORT_SYMBOL(disable_irq_nosync);
-
-/**
- *	disable_irq - disable an irq and wait for completion
- *	@irq: Interrupt to disable
- *
- *	Disable the selected interrupt line.  Enables and Disables are
- *	nested.
- *	This function waits for any pending IRQ handlers for this interrupt
- *	to complete before returning. If you use this function while
- *	holding a resource the IRQ handler may need you will deadlock.
- *
- *	This function may be called - with care - from IRQ context.
- */
-
-void disable_irq(unsigned int irq)
-{
-	irq_desc_t *desc =3D irq_descp(irq);
-
-	disable_irq_nosync(irq);
-	if (desc->action)
-		synchronize_irq(irq);
-}
-EXPORT_SYMBOL(disable_irq);
-
-/**
- *	enable_irq - enable handling of an irq
- *	@irq: Interrupt to enable
- *
- *	Undoes the effect of one call to disable_irq().  If this
- *	matches the last disable, processing of interrupts on this
- *	IRQ line is re-enabled.
- *
- *	This function may be called from IRQ context.
- */
-
-void enable_irq(unsigned int irq)
-{
-	irq_desc_t *desc =3D irq_descp(irq);
-	unsigned long flags;
-
-	spin_lock_irqsave(&desc->lock, flags);
-	switch (desc->depth) {
-	case 1: {
-		unsigned int status =3D desc->status & ~IRQ_DISABLED;
-		desc->status =3D status;
-		if ((status & (IRQ_PENDING | IRQ_REPLAY)) =3D IRQ_PENDING) {
-			desc->status =3D status | IRQ_REPLAY;
-			hw_resend_irq(desc->handler,irq);
-		}
-		desc->handler->enable(irq);
-		/* fall-through */
-	}
-	default:
-		desc->depth--;
-		break;
-	case 0:
-		printk(KERN_ERR "enable_irq(%u) unbalanced from %p\n",
-		       irq, (void *) __builtin_return_address(0));
-	}
-	spin_unlock_irqrestore(&desc->lock, flags);
-}
-EXPORT_SYMBOL(enable_irq);
-
-/*
- * do_IRQ handles all normal device IRQ's (the special
- * SMP cross-CPU interrupts have their own specific
- * handlers).
- */
-unsigned int do_IRQ(unsigned long irq, struct pt_regs *regs)
-{
-	/*
-	 * We ack quickly, we don't want the irq controller
-	 * thinking we're snobs just because some other CPU has
-	 * disabled global interrupts (we have already done the
-	 * INT_ACK cycles, it's too late to try to pretend to the
-	 * controller that we aren't taking the interrupt).
-	 *
-	 * 0 return value means that this irq is already being
-	 * handled by some other CPU. (or is disabled)
-	 */
-	irq_desc_t *desc =3D irq_descp(irq);
-	struct irqaction * action;
-	irqreturn_t action_ret;
-	unsigned int status;
-	int cpu;
-
-	cpu =3D smp_processor_id(); /* for CONFIG_PREEMPT, this must come after i=
rq_enter()! */
-
-	kstat_cpu(cpu).irqs[irq]++;
-
-	if (desc->status & IRQ_PER_CPU) {
-		/* no locking required for CPU-local interrupts: */
-		desc->handler->ack(irq);
-		action_ret =3D handle_IRQ_event(irq, regs, desc->action);
-		desc->handler->end(irq);
-	} else {
-		spin_lock(&desc->lock);
-		desc->handler->ack(irq);
-		/*
-		 * REPLAY is when Linux resends an IRQ that was dropped earlier
-		 * WAITING is used by probe to mark irqs that are being tested
-		 */
-		status =3D desc->status & ~(IRQ_REPLAY | IRQ_WAITING);
-		status |=3D IRQ_PENDING; /* we _want_ to handle it */
-
-		/*
-		 * If the IRQ is disabled for whatever reason, we cannot
-		 * use the action we have.
-		 */
-		action =3D NULL;
-		if (likely(!(status & (IRQ_DISABLED | IRQ_INPROGRESS)))) {
-			action =3D desc->action;
-			status &=3D ~IRQ_PENDING; /* we commit to handling */
-			status |=3D IRQ_INPROGRESS; /* we are handling it */
-		}
-		desc->status =3D status;
-
-		/*
-		 * If there is no IRQ handler or it was disabled, exit early.
-		 * Since we set PENDING, if another processor is handling
-		 * a different instance of this same irq, the other processor
-		 * will take care of it.
-		 */
-		if (unlikely(!action))
-			goto out;
-
-		/*
-		 * Edge triggered interrupts need to remember
-		 * pending events.
-		 * This applies to any hw interrupts that allow a second
-		 * instance of the same irq to arrive while we are in do_IRQ
-		 * or in the handler. But the code here only handles the _second_
-		 * instance of the irq, not the third or fourth. So it is mostly
-		 * useful for irq hardware that does not mask cleanly in an
-		 * SMP environment.
-		 */
-		for (;;) {
-			spin_unlock(&desc->lock);
-			action_ret =3D handle_IRQ_event(irq, regs, action);
-			spin_lock(&desc->lock);
-			if (!noirqdebug)
-				note_interrupt(irq, desc, action_ret);
-			if (!(desc->status & IRQ_PENDING))
-				break;
-			desc->status &=3D ~IRQ_PENDING;
-		}
-		desc->status &=3D ~IRQ_INPROGRESS;
-	  out:
-		/*
-		 * The ->end() handler has to deal with interrupts which got
-		 * disabled while the handler was running.
-		 */
-		desc->handler->end(irq);
-		spin_unlock(&desc->lock);
-	}
-	return 1;
-}
-
-/**
- *	request_irq - allocate an interrupt line
- *	@irq: Interrupt line to allocate
- *	@handler: Function to be called when the IRQ occurs
- *	@irqflags: Interrupt type flags
- *	@devname: An ascii name for the claiming device
- *	@dev_id: A cookie passed back to the handler function
- *
- *	This call allocates interrupt resources and enables the
- *	interrupt line and IRQ handling. From the point this
- *	call is made your handler function may be invoked. Since
- *	your handler function must clear any interrupt the board=20
- *	raises, you must take care both to initialise your hardware
- *	and to set up the interrupt handler in the right order.
- *
- *	Dev_id must be globally unique. Normally the address of the
- *	device data structure is used as the cookie. Since the handler
- *	receives this value it makes sense to use it.
- *
- *	If your interrupt is shared you must pass a non NULL dev_id
- *	as this is required when freeing the interrupt.
- *
- *	Flags:
- *
- *	SA_SHIRQ		Interrupt is shared
- *
- *	SA_INTERRUPT		Disable local interrupts while processing
- *
- *	SA_SAMPLE_RANDOM	The interrupt can be used for entropy
- *
- */
-
-int request_irq(unsigned int irq,
-		irqreturn_t (*handler)(int, void *, struct pt_regs *),
-		unsigned long irqflags,
-		const char * devname,
-		void *dev_id)
-{
-	int retval;
-	struct irqaction * action;
-
-#if 1
-	/*
-	 * Sanity-check: shared interrupts should REALLY pass in
-	 * a real dev-ID, otherwise we'll have trouble later trying
-	 * to figure out which interrupt is which (messes up the
-	 * interrupt freeing logic etc).
-	 */
-	if (irqflags & SA_SHIRQ) {
-		if (!dev_id)
-			printk(KERN_ERR "Bad boy: %s called us without a dev_id!\n", devname);
-	}
-#endif
-
-	if (irq >=3D NR_IRQS)
-		return -EINVAL;
-	if (!handler)
-		return -EINVAL;
-
-	action =3D (struct irqaction *)
-			kmalloc(sizeof(struct irqaction), GFP_ATOMIC);
-	if (!action)
-		return -ENOMEM;
-
-	action->handler =3D handler;
-	action->flags =3D irqflags;
-	cpus_clear(action->mask);
-	action->name =3D devname;
-	action->next =3D NULL;
-	action->dev_id =3D dev_id;
-
-	retval =3D setup_irq(irq, action);
-	if (retval)
-		kfree(action);
-	return retval;
-}
-
-EXPORT_SYMBOL(request_irq);
-
-/**
- *	free_irq - free an interrupt
- *	@irq: Interrupt line to free
- *	@dev_id: Device identity to free
- *
- *	Remove an interrupt handler. The handler is removed and if the
- *	interrupt line is no longer in use by any driver it is disabled.
- *	On a shared IRQ the caller must ensure the interrupt is disabled
- *	on the card it drives before calling this function. The function
- *	does not return until any executing interrupts for this IRQ
- *	have completed.
- *
- *	This function must not be called from interrupt context.
- */
-
-void free_irq(unsigned int irq, void *dev_id)
-{
-	irq_desc_t *desc;
-	struct irqaction **p;
-	unsigned long flags;
-
-	if (irq >=3D NR_IRQS)
-		return;
-
-	desc =3D irq_descp(irq);
-	spin_lock_irqsave(&desc->lock,flags);
-	p =3D &desc->action;
-	for (;;) {
-		struct irqaction * action =3D *p;
-		if (action) {
-			struct irqaction **pp =3D p;
-			p =3D &action->next;
-			if (action->dev_id !=3D dev_id)
-				continue;
-
-			/* Found it - now remove it from the list of entries */
-			*pp =3D action->next;
-			if (!desc->action) {
-				desc->status |=3D IRQ_DISABLED;
-				desc->handler->shutdown(irq);
-			}
-			spin_unlock_irqrestore(&desc->lock,flags);
-
-			/* Wait to make sure it's not being used on another CPU */
-			synchronize_irq(irq);
-			kfree(action);
-			return;
-		}
-		printk(KERN_ERR "Trying to free free IRQ%d\n",irq);
-		spin_unlock_irqrestore(&desc->lock,flags);
-		return;
-	}
-}
-
-EXPORT_SYMBOL(free_irq);
-
-/*
- * IRQ autodetection code..
- *
- * This depends on the fact that any interrupt that
- * comes in on to an unassigned handler will get stuck
- * with "IRQ_WAITING" cleared and the interrupt
- * disabled.
- */
-
-static DECLARE_MUTEX(probe_sem);
-
-/**
- *	probe_irq_on	- begin an interrupt autodetect
- *
- *	Commence probing for an interrupt. The interrupts are scanned
- *	and a mask of potential interrupt lines is returned.
- *
- */
-
-unsigned long probe_irq_on(void)
-{
-	unsigned int i;
-	irq_desc_t *desc;
-	unsigned long val;
-	unsigned long delay;
-
-	down(&probe_sem);
-	/*
-	 * something may have generated an irq long ago and we want to
-	 * flush such a longstanding irq before considering it as spurious.
-	 */
-	for (i =3D NR_IRQS-1; i > 0; i--)  {
-		desc =3D irq_descp(i);
-
-		spin_lock_irq(&desc->lock);
-		if (!desc->action)
-			desc->handler->startup(i);
-		spin_unlock_irq(&desc->lock);
-	}
-
-	/* Wait for longstanding interrupts to trigger. */
-	for (delay =3D jiffies + HZ/50; time_after(delay, jiffies); )
-		/* about 20ms delay */ barrier();
-
-	/*
-	 * enable any unassigned irqs
-	 * (we must startup again here because if a longstanding irq
-	 * happened in the previous stage, it may have masked itself)
-	 */
-	for (i =3D NR_IRQS-1; i > 0; i--) {
-		desc =3D irq_descp(i);
-
-		spin_lock_irq(&desc->lock);
-		if (!desc->action) {
-			desc->status |=3D IRQ_AUTODETECT | IRQ_WAITING;
-			if (desc->handler->startup(i))
-				desc->status |=3D IRQ_PENDING;
-		}
-		spin_unlock_irq(&desc->lock);
-	}
-
-	/*
-	 * Wait for spurious interrupts to trigger
-	 */
-	for (delay =3D jiffies + HZ/10; time_after(delay, jiffies); )
-		/* about 100ms delay */ barrier();
-
-	/*
-	 * Now filter out any obviously spurious interrupts
-	 */
-	val =3D 0;
-	for (i =3D 0; i < NR_IRQS; i++) {
-		irq_desc_t *desc =3D irq_descp(i);
-		unsigned int status;
-
-		spin_lock_irq(&desc->lock);
-		status =3D desc->status;
-
-		if (status & IRQ_AUTODETECT) {
-			/* It triggered already - consider it spurious. */
-			if (!(status & IRQ_WAITING)) {
-				desc->status =3D status & ~IRQ_AUTODETECT;
-				desc->handler->shutdown(i);
-			} else
-				if (i < 32)
-					val |=3D 1 << i;
-		}
-		spin_unlock_irq(&desc->lock);
-	}
-
-	return val;
-}
-
-EXPORT_SYMBOL(probe_irq_on);
-
-/**
- *	probe_irq_mask - scan a bitmap of interrupt lines
- *	@val:	mask of interrupts to consider
- *
- *	Scan the ISA bus interrupt lines and return a bitmap of
- *	active interrupts. The interrupt probe logic state is then
- *	returned to its previous value.
- *
- *	Note: we need to scan all the irq's even though we will
- *	only return ISA irq numbers - just so that we reset them
- *	all to a known state.
- */
-unsigned int probe_irq_mask(unsigned long val)
-{
-	int i;
-	unsigned int mask;
-
-	mask =3D 0;
-	for (i =3D 0; i < 16; i++) {
-		irq_desc_t *desc =3D irq_descp(i);
-		unsigned int status;
-
-		spin_lock_irq(&desc->lock);
-		status =3D desc->status;
-
-		if (status & IRQ_AUTODETECT) {
-			if (!(status & IRQ_WAITING))
-				mask |=3D 1 << i;
-
-			desc->status =3D status & ~IRQ_AUTODETECT;
-			desc->handler->shutdown(i);
-		}
-		spin_unlock_irq(&desc->lock);
-	}
-	up(&probe_sem);
-
-	return mask & val;
-}
-EXPORT_SYMBOL(probe_irq_mask);
-
-/**
- *	probe_irq_off	- end an interrupt autodetect
- *	@val: mask of potential interrupts (unused)
- *
- *	Scans the unused interrupt lines and returns the line which
- *	appears to have triggered the interrupt. If no interrupt was
- *	found then zero is returned. If more than one interrupt is
- *	found then minus the first candidate is returned to indicate
- *	their is doubt.
- *
- *	The interrupt probe logic state is returned to its previous
- *	value.
- *
- *	BUGS: When used in a module (which arguably shouldn't happen)
- *	nothing prevents two IRQ probe callers from overlapping. The
- *	results of this are non-optimal.
- */
-
-int probe_irq_off(unsigned long val)
-{
-	int i, irq_found, nr_irqs;
-
-	nr_irqs =3D 0;
-	irq_found =3D 0;
-	for (i =3D 0; i < NR_IRQS; i++) {
-		irq_desc_t *desc =3D irq_descp(i);
-		unsigned int status;
-
-		spin_lock_irq(&desc->lock);
-		status =3D desc->status;
-
-		if (status & IRQ_AUTODETECT) {
-			if (!(status & IRQ_WAITING)) {
-				if (!nr_irqs)
-					irq_found =3D i;
-				nr_irqs++;
-			}
-			desc->status =3D status & ~IRQ_AUTODETECT;
-			desc->handler->shutdown(i);
-		}
-		spin_unlock_irq(&desc->lock);
-	}
-	up(&probe_sem);
-
-	if (nr_irqs > 1)
-		irq_found =3D -irq_found;
-	return irq_found;
-}
-
-EXPORT_SYMBOL(probe_irq_off);
-
-int setup_irq(unsigned int irq, struct irqaction * new)
-{
-	int shared =3D 0;
-	unsigned long flags;
-	struct irqaction *old, **p;
-	irq_desc_t *desc =3D irq_descp(irq);
-
-	if (desc->handler =3D &no_irq_type)
-		return -ENOSYS;
-	/*
-	 * Some drivers like serial.c use request_irq() heavily,
-	 * so we have to be careful not to interfere with a
-	 * running system.
-	 */
-	if (new->flags & SA_SAMPLE_RANDOM) {
-		/*
-		 * This function might sleep, we want to call it first,
-		 * outside of the atomic block.
-		 * Yes, this might clear the entropy pool if the wrong
-		 * driver is attempted to be loaded, without actually
-		 * installing a new handler, but is this really a problem,
-		 * only the sysadmin is able to do this.
-		 */
-		rand_initialize_irq(irq);
-	}
-
-	if (new->flags & SA_PERCPU_IRQ) {
-		desc->status |=3D IRQ_PER_CPU;
-		desc->handler =3D &irq_type_ia64_lsapic;
-	}
-
-	/*
-	 * The following block of code has to be executed atomically
-	 */
-	spin_lock_irqsave(&desc->lock,flags);
-	p =3D &desc->action;
-	if ((old =3D *p) !=3D NULL) {
-		/* Can't share interrupts unless both agree to */
-		if (!(old->flags & new->flags & SA_SHIRQ)) {
-			spin_unlock_irqrestore(&desc->lock,flags);
-			return -EBUSY;
-		}
-
-		/* add new interrupt at end of irq queue */
-		do {
-			p =3D &old->next;
-			old =3D *p;
-		} while (old);
-		shared =3D 1;
-	}
-
-	*p =3D new;
-
-	if (!shared) {
-		desc->depth =3D 0;
-		desc->status &=3D ~(IRQ_DISABLED | IRQ_AUTODETECT | IRQ_WAITING | IRQ_IN=
PROGRESS);
-		desc->handler->startup(irq);
-	}
-	spin_unlock_irqrestore(&desc->lock,flags);
-
-	register_irq_proc(irq);
-	return 0;
-}
-
-static struct proc_dir_entry * root_irq_dir;
-static struct proc_dir_entry * irq_dir [NR_IRQS];
-
-#ifdef CONFIG_SMP
-
-static struct proc_dir_entry * smp_affinity_entry [NR_IRQS];
=20
 static cpumask_t irq_affinity [NR_IRQS] =3D { [0 ... NR_IRQS-1] =3D CPU_MA=
SK_ALL };
=20
@@ -949,79 +148,6 @@
 	}
 }
=20
-static int irq_affinity_read_proc (char *page, char **start, off_t off,
-			int count, int *eof, void *data)
-{
-	int len =3D sprintf(page, "%s", irq_redir[(long)data] ? "r " : "");
-
-	len +=3D cpumask_scnprintf(page+len, count, irq_affinity[(long)data]);
-	if (count - len < 2)
-		return -EINVAL;
-	len +=3D sprintf(page + len, "\n");
-	return len;
-}
-
-static int irq_affinity_write_proc (struct file *file, const char __user *=
buffer,
-				    unsigned long count, void *data)
-{
-	unsigned int irq =3D (unsigned long) data;
-	int full_count =3D count, err;
-	cpumask_t new_value, tmp;
-#	define R_PREFIX_LEN 16
-	char rbuf[R_PREFIX_LEN];
-	int rlen;
-	int prelen;
-	irq_desc_t *desc =3D irq_descp(irq);
-	unsigned long flags;
-	int redir =3D 0;
-
-	if (!desc->handler->set_affinity)
-		return -EIO;
-
-	/*
-	 * If string being written starts with a prefix of 'r' or 'R'
-	 * and some limited number of spaces, set IA64_IRQ_REDIRECTED.
-	 * If more than (R_PREFIX_LEN - 2) spaces are passed, they won't
-	 * all be trimmed as part of prelen, the untrimmed spaces will
-	 * cause the hex parsing to fail, and this write() syscall will
-	 * fail with EINVAL.
-	 */
-
-	if (!count)
-		return -EINVAL;
-	rlen =3D min(sizeof(rbuf)-1, count);
-	if (copy_from_user(rbuf, buffer, rlen))
-		return -EFAULT;
-	rbuf[rlen] =3D 0;
-	prelen =3D 0;
-	if (tolower(*rbuf) =3D 'r') {
-		prelen =3D strspn(rbuf, "Rr ");
-		redir++;
-	}
-
-	err =3D cpumask_parse(buffer+prelen, count-prelen, new_value);
-	if (err)
-		return err;
-
-	/*
-	 * Do not allow disabling IRQs completely - it's a too easy
-	 * way to make the system unusable accidentally :-) At least
-	 * one online CPU still has to be targeted.
-	 */
-	cpus_and(tmp, new_value, cpu_online_map);
-	if (cpus_empty(tmp))
-		return -EINVAL;
-
-	spin_lock_irqsave(&desc->lock, flags);
-	pending_irq_cpumask[irq] =3D new_value;
-	if (redir)
-		set_bit(irq, pending_irq_redir);
-	else
-		clear_bit(irq, pending_irq_redir);
-	spin_unlock_irqrestore(&desc->lock, flags);
-
-	return full_count;
-}
=20
 void move_irq(int irq)
 {
@@ -1135,57 +261,3 @@
 	local_irq_disable();
 }
 #endif
-
-#define MAX_NAMELEN 10
-
-static void register_irq_proc (unsigned int irq)
-{
-	char name [MAX_NAMELEN];
-
-	if (!root_irq_dir || (irq_descp(irq)->handler =3D &no_irq_type) || irq_di=
r[irq])
-		return;
-
-	memset(name, 0, MAX_NAMELEN);
-	sprintf(name, "%d", irq);
-
-	/* create /proc/irq/1234 */
-	irq_dir[irq] =3D proc_mkdir(name, root_irq_dir);
-
-#ifdef CONFIG_SMP
-	{
-		struct proc_dir_entry *entry;
-
-		/* create /proc/irq/1234/smp_affinity */
-		entry =3D create_proc_entry("smp_affinity", 0600, irq_dir[irq]);
-
-		if (entry) {
-			entry->nlink =3D 1;
-			entry->data =3D (void *)(long)irq;
-			entry->read_proc =3D irq_affinity_read_proc;
-			entry->write_proc =3D irq_affinity_write_proc;
-		}
-
-		smp_affinity_entry[irq] =3D entry;
-	}
-#endif
-}
-
-void init_irq_proc (void)
-{
-	int i;
-
-	/* create /proc/irq */
-	root_irq_dir =3D proc_mkdir("irq", NULL);
-
-	/* create /proc/irq/prof_cpu_mask */
-	create_prof_cpu_mask(root_irq_dir);
-
-	/*
-	 * Create entries for all existing IRQs.
-	 */
-	for (i =3D 0; i < NR_IRQS; i++) {
-		if (irq_descp(i)->handler =3D &no_irq_type)
-			continue;
-		register_irq_proc(i);
-	}
-}
=3D=3D=3D arch/ia64/kernel/irq_ia64.c 1.22 vs edited =3D=3D--- 1.22/arch/ia=
64/kernel/irq_ia64.c	2004-10-20 01:37:14 -07:00
+++ edited/arch/ia64/kernel/irq_ia64.c	2004-11-16 14:11:53 -08:00
@@ -60,6 +60,7 @@
 };
 EXPORT_SYMBOL(isa_irq_to_vector_map);
=20
+#ifndef CONFIG_GENERIC_HARDIRQS
 static inline void
 irq_enter (void)
 {
@@ -74,6 +75,7 @@
 		do_softirq();
 	preempt_enable_no_resched();
 }
+#endif
=20
 int
 assign_irq_vector (int irq)
=3D=3D=3D arch/ia64/sn/kernel/irq.c 1.28 vs edited =3D=3D--- 1.28/arch/ia64=
/sn/kernel/irq.c	2004-10-26 16:42:36 -07:00
+++ edited/arch/ia64/sn/kernel/irq.c	2004-11-17 10:21:51 -08:00
@@ -204,7 +204,7 @@
=20
 struct irq_desc *sn_irq_desc(unsigned int irq)
 {
-	return (_irq_desc + irq);
+	return (irq_desc + irq);
 }
=20
 u8 sn_irq_to_vector(unsigned int irq)
@@ -220,7 +220,7 @@
 void sn_irq_init(void)
 {
 	int i;
-	irq_desc_t *base_desc =3D _irq_desc;
+	irq_desc_t *base_desc =3D irq_desc;
=20
 	for (i =3D 0; i < NR_IRQS; i++) {
 		if (base_desc[i].handler =3D &no_irq_type) {
=3D=3D=3D include/asm-ia64/hw_irq.h 1.12 vs edited =3D=3D--- 1.12/include/a=
sm-ia64/hw_irq.h	2004-10-05 11:30:39 -07:00
+++ edited/include/asm-ia64/hw_irq.h	2004-11-16 15:36:05 -08:00
@@ -94,13 +94,13 @@
  * Default implementations for the irq-descriptor API:
  */
=20
-extern irq_desc_t _irq_desc[NR_IRQS];
+extern irq_desc_t irq_desc[NR_IRQS];
=20
 #ifndef CONFIG_IA64_GENERIC
 static inline irq_desc_t *
 __ia64_irq_desc (unsigned int irq)
 {
-	return _irq_desc + irq;
+	return irq_desc + irq;
 }
=20
 static inline ia64_vector
=3D=3D=3D include/asm-ia64/msi.h 1.2 vs edited =3D=3D--- 1.2/include/asm-ia=
64/msi.h	2004-04-13 16:59:44 -07:00
+++ edited/include/asm-ia64/msi.h	2004-11-16 15:36:42 -08:00
@@ -12,7 +12,6 @@
 static inline void set_intr_gate (int nr, void *func) {}
 #define IO_APIC_VECTOR(irq)	(irq)
 #define ack_APIC_irq		ia64_eoi
-#define irq_desc		_irq_desc
 #define cpu_mask_to_apicid(mask) cpu_physical_id(first_cpu(mask))
 #define MSI_DEST_MODE		MSI_PHYSICAL_MODE
 #define MSI_TARGET_CPU	((ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff)
