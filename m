From: "Dong, Eddie" <eddie.dong@intel.com>
Date: Tue, 25 Mar 2008 06:13:43 +0000
Subject: RE: Xen common code across architecture
Message-Id: <10EA09EFD8728347A513008B6B0DA77A02F37916@pdsmsx411.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C88E3F.619D5D07"
List-Id: <linux-ia64.vger.kernel.org>
References: <12047411453864-git-send-email-yamahata@valinux.co.jp>	<12047411473158-git-send-email-yamahata@valinux.co.jp> <10EA09EFD8728347A513008B6B0DA77A02EF8C3A@pdsmsx411.ccr.corp.intel.com> <47E27348.5090705@goop.org>
In-Reply-To: <47E27348.5090705@goop.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, kvm-ia64-devel@lists.sourceforge.net, xen-ia64-devel@lists.xensource.com

This is a multi-part message in MIME format.

------_=_NextPart_001_01C88E3F.619D5D07
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Jeremy/Andrew:

	Isaku Yamahata, I and some other IA64/Xen community memebers are

working together to enable pv_ops for IA64 Linux. This patch is a
preparation to=20
move common arch/x86/xen/events.c to drivers/xen (contents are
identical) against
mm tree, it is based on Yamahata's IA64/pv_ops patch serie.
	In case you want to have a brief view of whole pv_ops/IA64 patch
serie,=20
please refer to IA64 Linux mailinglist.

Thanks, Eddie
=09

    Move events.c to drivers/xen for IA64/Xen
    support.


    Signed-off-by: Yaozu (Eddie) Dong <eddie.dong@intel.com>

diff -urN old/arch/x86/xen/events.c linux/arch/x86/xen/events.c
--- old/arch/x86/xen/events.c	2008-03-10 13:22:27.000000000 +0800
+++ linux/arch/x86/xen/events.c	1970-01-01 08:00:00.000000000 +0800
@@ -1,591 +0,0 @@
-/*
- * Xen event channels
- *
- * Xen models interrupts with abstract event channels.  Because each
- * domain gets 1024 event channels, but NR_IRQ is not that large, we
- * must dynamically map irqs<->event channels.  The event channels
- * interface with the rest of the kernel by defining a xen interrupt
- * chip.  When an event is recieved, it is mapped to an irq and sent
- * through the normal interrupt processing path.
- *
- * There are four kinds of events which can be mapped to an event
- * channel:
- *
- * 1. Inter-domain notifications.  This includes all the virtual
- *    device events, since they're driven by front-ends in another
domain
- *    (typically dom0).
- * 2. VIRQs, typically used for timers.  These are per-cpu events.
- * 3. IPIs.
- * 4. Hardware interrupts. Not supported at present.
- *
- * Jeremy Fitzhardinge <jeremy@xensource.com>, XenSource Inc, 2007
- */
-
-#include <linux/linkage.h>
-#include <linux/interrupt.h>
-#include <linux/irq.h>
-#include <linux/module.h>
-#include <linux/string.h>
-
-#include <asm/ptrace.h>
-#include <asm/irq.h>
-#include <asm/sync_bitops.h>
-#include <asm/xen/hypercall.h>
-#include <asm/xen/hypervisor.h>
-
-#include <xen/events.h>
-#include <xen/interface/xen.h>
-#include <xen/interface/event_channel.h>
-
-#include "xen-ops.h"
-
-/*
- * This lock protects updates to the following mapping and
reference-count
- * arrays. The lock does not need to be acquired to read the mapping
tables.
- */
-static DEFINE_SPINLOCK(irq_mapping_update_lock);
-
-/* IRQ <-> VIRQ mapping. */
-static DEFINE_PER_CPU(int, virq_to_irq[NR_VIRQS]) =3D {[0 ... =
NR_VIRQS-1]
=3D -1};
-
-/* IRQ <-> IPI mapping */
-static DEFINE_PER_CPU(int, ipi_to_irq[XEN_NR_IPIS]) =3D {[0 ...
XEN_NR_IPIS-1] =3D -1};
-
-/* Packed IRQ information: binding type, sub-type index, and event
channel. */
-struct packed_irq
-{
-	unsigned short evtchn;
-	unsigned char index;
-	unsigned char type;
-};
-
-static struct packed_irq irq_info[NR_IRQS];
-
-/* Binding types. */
-enum {
-	IRQT_UNBOUND,
-	IRQT_PIRQ,
-	IRQT_VIRQ,
-	IRQT_IPI,
-	IRQT_EVTCHN
-};
-
-/* Convenient shorthand for packed representation of an unbound IRQ. */
-#define IRQ_UNBOUND	mk_irq_info(IRQT_UNBOUND, 0, 0)
-
-static int evtchn_to_irq[NR_EVENT_CHANNELS] =3D {
-	[0 ... NR_EVENT_CHANNELS-1] =3D -1
-};
-static unsigned long
cpu_evtchn_mask[NR_CPUS][NR_EVENT_CHANNELS/BITS_PER_LONG];
-static u8 cpu_evtchn[NR_EVENT_CHANNELS];
-
-/* Reference counts for bindings to IRQs. */
-static int irq_bindcount[NR_IRQS];
-
-/* Xen will never allocate port zero for any purpose. */
-#define VALID_EVTCHN(chn)	((chn) !=3D 0)
-
-/*
- * Force a proper event-channel callback from Xen after clearing the
- * callback mask. We do this in a very simple manner, by making a call
- * down into Xen. The pending flag will be checked by Xen on return.
- */
-void force_evtchn_callback(void)
-{
-	(void)HYPERVISOR_xen_version(0, NULL);
-}
-EXPORT_SYMBOL_GPL(force_evtchn_callback);
-
-static struct irq_chip xen_dynamic_chip;
-
-/* Constructor for packed IRQ information. */
-static inline struct packed_irq mk_irq_info(u32 type, u32 index, u32
evtchn)
-{
-	return (struct packed_irq) { evtchn, index, type };
-}
-
-/*
- * Accessors for packed IRQ information.
- */
-static inline unsigned int evtchn_from_irq(int irq)
-{
-	return irq_info[irq].evtchn;
-}
-
-static inline unsigned int index_from_irq(int irq)
-{
-	return irq_info[irq].index;
-}
-
-static inline unsigned int type_from_irq(int irq)
-{
-	return irq_info[irq].type;
-}
-
-static inline unsigned long active_evtchns(unsigned int cpu,
-					   struct shared_info *sh,
-					   unsigned int idx)
-{
-	return (sh->evtchn_pending[idx] &
-		cpu_evtchn_mask[cpu][idx] &
-		~sh->evtchn_mask[idx]);
-}
-
-static void bind_evtchn_to_cpu(unsigned int chn, unsigned int cpu)
-{
-	int irq =3D evtchn_to_irq[chn];
-
-	BUG_ON(irq =3D=3D -1);
-#ifdef CONFIG_SMP
-	irq_desc[irq].affinity =3D cpumask_of_cpu(cpu);
-#endif
-
-	__clear_bit(chn, cpu_evtchn_mask[cpu_evtchn[chn]]);
-	__set_bit(chn, cpu_evtchn_mask[cpu]);
-
-	cpu_evtchn[chn] =3D cpu;
-}
-
-static void init_evtchn_cpu_bindings(void)
-{
-#ifdef CONFIG_SMP
-	int i;
-	/* By default all event channels notify CPU#0. */
-	for (i =3D 0; i < NR_IRQS; i++)
-		irq_desc[i].affinity =3D cpumask_of_cpu(0);
-#endif
-
-	memset(cpu_evtchn, 0, sizeof(cpu_evtchn));
-	memset(cpu_evtchn_mask[0], ~0, sizeof(cpu_evtchn_mask[0]));
-}
-
-static inline unsigned int cpu_from_evtchn(unsigned int evtchn)
-{
-	return cpu_evtchn[evtchn];
-}
-
-static inline void clear_evtchn(int port)
-{
-	struct shared_info *s =3D HYPERVISOR_shared_info;
-	sync_clear_bit(port, &s->evtchn_pending[0]);
-}
-
-static inline void set_evtchn(int port)
-{
-	struct shared_info *s =3D HYPERVISOR_shared_info;
-	sync_set_bit(port, &s->evtchn_pending[0]);
-}
-
-
-/**
- * notify_remote_via_irq - send event to remote end of event channel
via irq
- * @irq: irq of event channel to send event to
- *
- * Unlike notify_remote_via_evtchn(), this is safe to use across
- * save/restore. Notifications on a broken connection are silently
- * dropped.
- */
-void notify_remote_via_irq(int irq)
-{
-	int evtchn =3D evtchn_from_irq(irq);
-
-	if (VALID_EVTCHN(evtchn))
-		notify_remote_via_evtchn(evtchn);
-}
-EXPORT_SYMBOL_GPL(notify_remote_via_irq);
-
-static void mask_evtchn(int port)
-{
-	struct shared_info *s =3D HYPERVISOR_shared_info;
-	sync_set_bit(port, &s->evtchn_mask[0]);
-}
-
-static void unmask_evtchn(int port)
-{
-	struct shared_info *s =3D HYPERVISOR_shared_info;
-	unsigned int cpu =3D get_cpu();
-
-	BUG_ON(!irqs_disabled());
-
-	/* Slow path (hypercall) if this is a non-local port. */
-	if (unlikely(cpu !=3D cpu_from_evtchn(port))) {
-		struct evtchn_unmask unmask =3D { .port =3D port };
-		(void)HYPERVISOR_event_channel_op(EVTCHNOP_unmask,
&unmask);
-	} else {
-		struct vcpu_info *vcpu_info =3D __get_cpu_var(xen_vcpu);
-
-		sync_clear_bit(port, &s->evtchn_mask[0]);
-
-		/*
-		 * The following is basically the equivalent of
-		 * 'hw_resend_irq'. Just like a real IO-APIC we 'lose
-		 * the interrupt edge' if the channel is masked.
-		 */
-		if (sync_test_bit(port, &s->evtchn_pending[0]) &&
-		    !sync_test_and_set_bit(port / BITS_PER_LONG,
-
&vcpu_info->evtchn_pending_sel))
-			vcpu_info->evtchn_upcall_pending =3D 1;
-	}
-
-	put_cpu();
-}
-
-static int find_unbound_irq(void)
-{
-	int irq;
-
-	/* Only allocate from dynirq range */
-	for (irq =3D 0; irq < NR_IRQS; irq++)
-		if (irq_bindcount[irq] =3D=3D 0)
-			break;
-
-	if (irq =3D=3D NR_IRQS)
-		panic("No available IRQ to bind to: increase
NR_IRQS!\n");
-
-	return irq;
-}
-
-int bind_evtchn_to_irq(unsigned int evtchn)
-{
-	int irq;
-
-	spin_lock(&irq_mapping_update_lock);
-
-	irq =3D evtchn_to_irq[evtchn];
-
-	if (irq =3D=3D -1) {
-		irq =3D find_unbound_irq();
-
-		dynamic_irq_init(irq);
-		set_irq_chip_and_handler_name(irq, &xen_dynamic_chip,
-					      handle_level_irq,
"event");
-
-		evtchn_to_irq[evtchn] =3D irq;
-		irq_info[irq] =3D mk_irq_info(IRQT_EVTCHN, 0, evtchn);
-	}
-
-	irq_bindcount[irq]++;
-
-	spin_unlock(&irq_mapping_update_lock);
-
-	return irq;
-}
-EXPORT_SYMBOL_GPL(bind_evtchn_to_irq);
-
-static int bind_ipi_to_irq(unsigned int ipi, unsigned int cpu)
-{
-	struct evtchn_bind_ipi bind_ipi;
-	int evtchn, irq;
-
-	spin_lock(&irq_mapping_update_lock);
-
-	irq =3D per_cpu(ipi_to_irq, cpu)[ipi];
-	if (irq =3D=3D -1) {
-		irq =3D find_unbound_irq();
-		if (irq < 0)
-			goto out;
-
-		dynamic_irq_init(irq);
-		set_irq_chip_and_handler_name(irq, &xen_dynamic_chip,
-					      handle_level_irq, "ipi");
-
-		bind_ipi.vcpu =3D cpu;
-		if (HYPERVISOR_event_channel_op(EVTCHNOP_bind_ipi,
-						&bind_ipi) !=3D 0)
-			BUG();
-		evtchn =3D bind_ipi.port;
-
-		evtchn_to_irq[evtchn] =3D irq;
-		irq_info[irq] =3D mk_irq_info(IRQT_IPI, ipi, evtchn);
-
-		per_cpu(ipi_to_irq, cpu)[ipi] =3D irq;
-
-		bind_evtchn_to_cpu(evtchn, cpu);
-	}
-
-	irq_bindcount[irq]++;
-
- out:
-	spin_unlock(&irq_mapping_update_lock);
-	return irq;
-}
-
-
-static int bind_virq_to_irq(unsigned int virq, unsigned int cpu)
-{
-	struct evtchn_bind_virq bind_virq;
-	int evtchn, irq;
-
-	spin_lock(&irq_mapping_update_lock);
-
-	irq =3D per_cpu(virq_to_irq, cpu)[virq];
-
-	if (irq =3D=3D -1) {
-		bind_virq.virq =3D virq;
-		bind_virq.vcpu =3D cpu;
-		if (HYPERVISOR_event_channel_op(EVTCHNOP_bind_virq,
-						&bind_virq) !=3D 0)
-			BUG();
-		evtchn =3D bind_virq.port;
-
-		irq =3D find_unbound_irq();
-
-		dynamic_irq_init(irq);
-		set_irq_chip_and_handler_name(irq, &xen_dynamic_chip,
-					      handle_level_irq, "virq");
-
-		evtchn_to_irq[evtchn] =3D irq;
-		irq_info[irq] =3D mk_irq_info(IRQT_VIRQ, virq, evtchn);
-
-		per_cpu(virq_to_irq, cpu)[virq] =3D irq;
-
-		bind_evtchn_to_cpu(evtchn, cpu);
-	}
-
-	irq_bindcount[irq]++;
-
-	spin_unlock(&irq_mapping_update_lock);
-
-	return irq;
-}
-
-static void unbind_from_irq(unsigned int irq)
-{
-	struct evtchn_close close;
-	int evtchn =3D evtchn_from_irq(irq);
-
-	spin_lock(&irq_mapping_update_lock);
-
-	if (VALID_EVTCHN(evtchn) && (--irq_bindcount[irq] =3D=3D 0)) {
-		close.port =3D evtchn;
-		if (HYPERVISOR_event_channel_op(EVTCHNOP_close, &close)
!=3D 0)
-			BUG();
-
-		switch (type_from_irq(irq)) {
-		case IRQT_VIRQ:
-			per_cpu(virq_to_irq, cpu_from_evtchn(evtchn))
-				[index_from_irq(irq)] =3D -1;
-			break;
-		default:
-			break;
-		}
-
-		/* Closed ports are implicitly re-bound to VCPU0. */
-		bind_evtchn_to_cpu(evtchn, 0);
-
-		evtchn_to_irq[evtchn] =3D -1;
-		irq_info[irq] =3D IRQ_UNBOUND;
-
-		dynamic_irq_init(irq);
-	}
-
-	spin_unlock(&irq_mapping_update_lock);
-}
-
-int bind_evtchn_to_irqhandler(unsigned int evtchn,
-			      irq_handler_t handler,
-			      unsigned long irqflags,
-			      const char *devname, void *dev_id)
-{
-	unsigned int irq;
-	int retval;
-
-	irq =3D bind_evtchn_to_irq(evtchn);
-	retval =3D request_irq(irq, handler, irqflags, devname, dev_id);
-	if (retval !=3D 0) {
-		unbind_from_irq(irq);
-		return retval;
-	}
-
-	return irq;
-}
-EXPORT_SYMBOL_GPL(bind_evtchn_to_irqhandler);
-
-int bind_virq_to_irqhandler(unsigned int virq, unsigned int cpu,
-			    irq_handler_t handler,
-			    unsigned long irqflags, const char *devname,
void *dev_id)
-{
-	unsigned int irq;
-	int retval;
-
-	irq =3D bind_virq_to_irq(virq, cpu);
-	retval =3D request_irq(irq, handler, irqflags, devname, dev_id);
-	if (retval !=3D 0) {
-		unbind_from_irq(irq);
-		return retval;
-	}
-
-	return irq;
-}
-EXPORT_SYMBOL_GPL(bind_virq_to_irqhandler);
-
-int bind_ipi_to_irqhandler(enum ipi_vector ipi,
-			   unsigned int cpu,
-			   irq_handler_t handler,
-			   unsigned long irqflags,
-			   const char *devname,
-			   void *dev_id)
-{
-	int irq, retval;
-
-	irq =3D bind_ipi_to_irq(ipi, cpu);
-	if (irq < 0)
-		return irq;
-
-	retval =3D request_irq(irq, handler, irqflags, devname, dev_id);
-	if (retval !=3D 0) {
-		unbind_from_irq(irq);
-		return retval;
-	}
-
-	return irq;
-}
-
-void unbind_from_irqhandler(unsigned int irq, void *dev_id)
-{
-	free_irq(irq, dev_id);
-	unbind_from_irq(irq);
-}
-EXPORT_SYMBOL_GPL(unbind_from_irqhandler);
-
-void xen_send_IPI_one(unsigned int cpu, enum ipi_vector vector)
-{
-	int irq =3D per_cpu(ipi_to_irq, cpu)[vector];
-	BUG_ON(irq < 0);
-	notify_remote_via_irq(irq);
-}
-
-
-/*
- * Search the CPUs pending events bitmasks.  For each one found, map
- * the event number to an irq, and feed it into do_IRQ() for
- * handling.
- *
- * Xen uses a two-level bitmap to speed searching.  The first level is
- * a bitset of words which contain pending event bits.  The second
- * level is a bitset of pending events themselves.
- */
-void xen_evtchn_do_upcall(struct pt_regs *regs)
-{
-	int cpu =3D get_cpu();
-	struct shared_info *s =3D HYPERVISOR_shared_info;
-	struct vcpu_info *vcpu_info =3D __get_cpu_var(xen_vcpu);
-	unsigned long pending_words;
-
-	vcpu_info->evtchn_upcall_pending =3D 0;
-
-	/* NB. No need for a barrier here -- XCHG is a barrier on x86.
*/
-	pending_words =3D xchg(&vcpu_info->evtchn_pending_sel, 0);
-	while (pending_words !=3D 0) {
-		unsigned long pending_bits;
-		int word_idx =3D __ffs(pending_words);
-		pending_words &=3D ~(1UL << word_idx);
-
-		while ((pending_bits =3D active_evtchns(cpu, s, word_idx))
!=3D 0) {
-			int bit_idx =3D __ffs(pending_bits);
-			int port =3D (word_idx * BITS_PER_LONG) + bit_idx;
-			int irq =3D evtchn_to_irq[port];
-
-			if (irq !=3D -1) {
-				regs->orig_ax =3D ~irq;
-				do_IRQ(regs);
-			}
-		}
-	}
-
-	put_cpu();
-}
-
-/* Rebind an evtchn so that it gets delivered to a specific cpu */
-static void rebind_irq_to_cpu(unsigned irq, unsigned tcpu)
-{
-	struct evtchn_bind_vcpu bind_vcpu;
-	int evtchn =3D evtchn_from_irq(irq);
-
-	if (!VALID_EVTCHN(evtchn))
-		return;
-
-	/* Send future instances of this interrupt to other vcpu. */
-	bind_vcpu.port =3D evtchn;
-	bind_vcpu.vcpu =3D tcpu;
-
-	/*
-	 * If this fails, it usually just indicates that we're dealing
with a
-	 * virq or IPI channel, which don't actually need to be rebound.
Ignore
-	 * it, but don't do the xenlinux-level rebind in that case.
-	 */
-	if (HYPERVISOR_event_channel_op(EVTCHNOP_bind_vcpu, &bind_vcpu)
>=3D 0)
-		bind_evtchn_to_cpu(evtchn, tcpu);
-}
-
-
-static void set_affinity_irq(unsigned irq, cpumask_t dest)
-{
-	unsigned tcpu =3D first_cpu(dest);
-	rebind_irq_to_cpu(irq, tcpu);
-}
-
-static void enable_dynirq(unsigned int irq)
-{
-	int evtchn =3D evtchn_from_irq(irq);
-
-	if (VALID_EVTCHN(evtchn))
-		unmask_evtchn(evtchn);
-}
-
-static void disable_dynirq(unsigned int irq)
-{
-	int evtchn =3D evtchn_from_irq(irq);
-
-	if (VALID_EVTCHN(evtchn))
-		mask_evtchn(evtchn);
-}
-
-static void ack_dynirq(unsigned int irq)
-{
-	int evtchn =3D evtchn_from_irq(irq);
-
-	move_native_irq(irq);
-
-	if (VALID_EVTCHN(evtchn))
-		clear_evtchn(evtchn);
-}
-
-static int retrigger_dynirq(unsigned int irq)
-{
-	int evtchn =3D evtchn_from_irq(irq);
-	int ret =3D 0;
-
-	if (VALID_EVTCHN(evtchn)) {
-		set_evtchn(evtchn);
-		ret =3D 1;
-	}
-
-	return ret;
-}
-
-static struct irq_chip xen_dynamic_chip __read_mostly =3D {
-	.name		=3D "xen-dyn",
-	.mask		=3D disable_dynirq,
-	.unmask		=3D enable_dynirq,
-	.ack		=3D ack_dynirq,
-	.set_affinity	=3D set_affinity_irq,
-	.retrigger	=3D retrigger_dynirq,
-};
-
-void __init xen_init_IRQ(void)
-{
-	int i;
-
-	init_evtchn_cpu_bindings();
-
-	/* No event channels are 'live' right now. */
-	for (i =3D 0; i < NR_EVENT_CHANNELS; i++)
-		mask_evtchn(i);
-
-	/* Dynamic IRQ space is currently unbound. Zero the refcnts. */
-	for (i =3D 0; i < NR_IRQS; i++)
-		irq_bindcount[i] =3D 0;
-
-	irq_ctx_init(smp_processor_id());
-}
diff -urN old/arch/x86/xen/Makefile linux/arch/x86/xen/Makefile
--- old/arch/x86/xen/Makefile	2008-03-10 13:22:27.000000000 +0800
+++ linux/arch/x86/xen/Makefile	2008-03-25 13:56:41.367764448 +0800
@@ -1,4 +1,4 @@
 obj-y		:=3D enlighten.o setup.o features.o multicalls.o mmu.o \
-			events.o time.o manage.o xen-asm.o
+			time.o manage.o xen-asm.o
=20
 obj-$(CONFIG_SMP)	+=3D smp.o
diff -urN old/arch/x86/xen/xen-ops.h linux/arch/x86/xen/xen-ops.h
--- old/arch/x86/xen/xen-ops.h	2008-03-25 13:21:09.996527604 +0800
+++ linux/arch/x86/xen/xen-ops.h	2008-03-25 13:59:16.349809137
+0800
@@ -2,6 +2,7 @@
 #define XEN_OPS_H
=20
 #include <linux/init.h>
+#include <xen/xen-ops.h>
=20
 /* These are code, but not functions.  Defined in entry.S */
 extern const char xen_hypervisor_callback[];
@@ -9,7 +10,6 @@
=20
 void xen_copy_trap_info(struct trap_info *traps);
=20
-DECLARE_PER_CPU(struct vcpu_info *, xen_vcpu);
 DECLARE_PER_CPU(unsigned long, xen_cr3);
 DECLARE_PER_CPU(unsigned long, xen_current_cr3);
=20
diff -urN old/drivers/xen/events.c linux/drivers/xen/events.c
--- old/drivers/xen/events.c	1970-01-01 08:00:00.000000000 +0800
+++ linux/drivers/xen/events.c	2008-03-25 13:56:41.368764287 +0800
@@ -0,0 +1,591 @@
+/*
+ * Xen event channels
+ *
+ * Xen models interrupts with abstract event channels.  Because each
+ * domain gets 1024 event channels, but NR_IRQ is not that large, we
+ * must dynamically map irqs<->event channels.  The event channels
+ * interface with the rest of the kernel by defining a xen interrupt
+ * chip.  When an event is recieved, it is mapped to an irq and sent
+ * through the normal interrupt processing path.
+ *
+ * There are four kinds of events which can be mapped to an event
+ * channel:
+ *
+ * 1. Inter-domain notifications.  This includes all the virtual
+ *    device events, since they're driven by front-ends in another
domain
+ *    (typically dom0).
+ * 2. VIRQs, typically used for timers.  These are per-cpu events.
+ * 3. IPIs.
+ * 4. Hardware interrupts. Not supported at present.
+ *
+ * Jeremy Fitzhardinge <jeremy@xensource.com>, XenSource Inc, 2007
+ */
+
+#include <linux/linkage.h>
+#include <linux/interrupt.h>
+#include <linux/irq.h>
+#include <linux/module.h>
+#include <linux/string.h>
+
+#include <asm/ptrace.h>
+#include <asm/irq.h>
+#include <asm/sync_bitops.h>
+#include <asm/xen/hypercall.h>
+#include <asm/xen/hypervisor.h>
+
+#include <xen/events.h>
+#include <xen/interface/xen.h>
+#include <xen/interface/event_channel.h>
+
+#include "xen-ops.h"
+
+/*
+ * This lock protects updates to the following mapping and
reference-count
+ * arrays. The lock does not need to be acquired to read the mapping
tables.
+ */
+static DEFINE_SPINLOCK(irq_mapping_update_lock);
+
+/* IRQ <-> VIRQ mapping. */
+static DEFINE_PER_CPU(int, virq_to_irq[NR_VIRQS]) =3D {[0 ... =
NR_VIRQS-1]
=3D -1};
+
+/* IRQ <-> IPI mapping */
+static DEFINE_PER_CPU(int, ipi_to_irq[XEN_NR_IPIS]) =3D {[0 ...
XEN_NR_IPIS-1] =3D -1};
+
+/* Packed IRQ information: binding type, sub-type index, and event
channel. */
+struct packed_irq
+{
+	unsigned short evtchn;
+	unsigned char index;
+	unsigned char type;
+};
+
+static struct packed_irq irq_info[NR_IRQS];
+
+/* Binding types. */
+enum {
+	IRQT_UNBOUND,
+	IRQT_PIRQ,
+	IRQT_VIRQ,
+	IRQT_IPI,
+	IRQT_EVTCHN
+};
+
+/* Convenient shorthand for packed representation of an unbound IRQ. */
+#define IRQ_UNBOUND	mk_irq_info(IRQT_UNBOUND, 0, 0)
+
+static int evtchn_to_irq[NR_EVENT_CHANNELS] =3D {
+	[0 ... NR_EVENT_CHANNELS-1] =3D -1
+};
+static unsigned long
cpu_evtchn_mask[NR_CPUS][NR_EVENT_CHANNELS/BITS_PER_LONG];
+static u8 cpu_evtchn[NR_EVENT_CHANNELS];
+
+/* Reference counts for bindings to IRQs. */
+static int irq_bindcount[NR_IRQS];
+
+/* Xen will never allocate port zero for any purpose. */
+#define VALID_EVTCHN(chn)	((chn) !=3D 0)
+
+/*
+ * Force a proper event-channel callback from Xen after clearing the
+ * callback mask. We do this in a very simple manner, by making a call
+ * down into Xen. The pending flag will be checked by Xen on return.
+ */
+void force_evtchn_callback(void)
+{
+	(void)HYPERVISOR_xen_version(0, NULL);
+}
+EXPORT_SYMBOL_GPL(force_evtchn_callback);
+
+static struct irq_chip xen_dynamic_chip;
+
+/* Constructor for packed IRQ information. */
+static inline struct packed_irq mk_irq_info(u32 type, u32 index, u32
evtchn)
+{
+	return (struct packed_irq) { evtchn, index, type };
+}
+
+/*
+ * Accessors for packed IRQ information.
+ */
+static inline unsigned int evtchn_from_irq(int irq)
+{
+	return irq_info[irq].evtchn;
+}
+
+static inline unsigned int index_from_irq(int irq)
+{
+	return irq_info[irq].index;
+}
+
+static inline unsigned int type_from_irq(int irq)
+{
+	return irq_info[irq].type;
+}
+
+static inline unsigned long active_evtchns(unsigned int cpu,
+					   struct shared_info *sh,
+					   unsigned int idx)
+{
+	return (sh->evtchn_pending[idx] &
+		cpu_evtchn_mask[cpu][idx] &
+		~sh->evtchn_mask[idx]);
+}
+
+static void bind_evtchn_to_cpu(unsigned int chn, unsigned int cpu)
+{
+	int irq =3D evtchn_to_irq[chn];
+
+	BUG_ON(irq =3D=3D -1);
+#ifdef CONFIG_SMP
+	irq_desc[irq].affinity =3D cpumask_of_cpu(cpu);
+#endif
+
+	__clear_bit(chn, cpu_evtchn_mask[cpu_evtchn[chn]]);
+	__set_bit(chn, cpu_evtchn_mask[cpu]);
+
+	cpu_evtchn[chn] =3D cpu;
+}
+
+static void init_evtchn_cpu_bindings(void)
+{
+#ifdef CONFIG_SMP
+	int i;
+	/* By default all event channels notify CPU#0. */
+	for (i =3D 0; i < NR_IRQS; i++)
+		irq_desc[i].affinity =3D cpumask_of_cpu(0);
+#endif
+
+	memset(cpu_evtchn, 0, sizeof(cpu_evtchn));
+	memset(cpu_evtchn_mask[0], ~0, sizeof(cpu_evtchn_mask[0]));
+}
+
+static inline unsigned int cpu_from_evtchn(unsigned int evtchn)
+{
+	return cpu_evtchn[evtchn];
+}
+
+static inline void clear_evtchn(int port)
+{
+	struct shared_info *s =3D HYPERVISOR_shared_info;
+	sync_clear_bit(port, &s->evtchn_pending[0]);
+}
+
+static inline void set_evtchn(int port)
+{
+	struct shared_info *s =3D HYPERVISOR_shared_info;
+	sync_set_bit(port, &s->evtchn_pending[0]);
+}
+
+
+/**
+ * notify_remote_via_irq - send event to remote end of event channel
via irq
+ * @irq: irq of event channel to send event to
+ *
+ * Unlike notify_remote_via_evtchn(), this is safe to use across
+ * save/restore. Notifications on a broken connection are silently
+ * dropped.
+ */
+void notify_remote_via_irq(int irq)
+{
+	int evtchn =3D evtchn_from_irq(irq);
+
+	if (VALID_EVTCHN(evtchn))
+		notify_remote_via_evtchn(evtchn);
+}
+EXPORT_SYMBOL_GPL(notify_remote_via_irq);
+
+static void mask_evtchn(int port)
+{
+	struct shared_info *s =3D HYPERVISOR_shared_info;
+	sync_set_bit(port, &s->evtchn_mask[0]);
+}
+
+static void unmask_evtchn(int port)
+{
+	struct shared_info *s =3D HYPERVISOR_shared_info;
+	unsigned int cpu =3D get_cpu();
+
+	BUG_ON(!irqs_disabled());
+
+	/* Slow path (hypercall) if this is a non-local port. */
+	if (unlikely(cpu !=3D cpu_from_evtchn(port))) {
+		struct evtchn_unmask unmask =3D { .port =3D port };
+		(void)HYPERVISOR_event_channel_op(EVTCHNOP_unmask,
&unmask);
+	} else {
+		struct vcpu_info *vcpu_info =3D __get_cpu_var(xen_vcpu);
+
+		sync_clear_bit(port, &s->evtchn_mask[0]);
+
+		/*
+		 * The following is basically the equivalent of
+		 * 'hw_resend_irq'. Just like a real IO-APIC we 'lose
+		 * the interrupt edge' if the channel is masked.
+		 */
+		if (sync_test_bit(port, &s->evtchn_pending[0]) &&
+		    !sync_test_and_set_bit(port / BITS_PER_LONG,
+
&vcpu_info->evtchn_pending_sel))
+			vcpu_info->evtchn_upcall_pending =3D 1;
+	}
+
+	put_cpu();
+}
+
+static int find_unbound_irq(void)
+{
+	int irq;
+
+	/* Only allocate from dynirq range */
+	for (irq =3D 0; irq < NR_IRQS; irq++)
+		if (irq_bindcount[irq] =3D=3D 0)
+			break;
+
+	if (irq =3D=3D NR_IRQS)
+		panic("No available IRQ to bind to: increase
NR_IRQS!\n");
+
+	return irq;
+}
+
+int bind_evtchn_to_irq(unsigned int evtchn)
+{
+	int irq;
+
+	spin_lock(&irq_mapping_update_lock);
+
+	irq =3D evtchn_to_irq[evtchn];
+
+	if (irq =3D=3D -1) {
+		irq =3D find_unbound_irq();
+
+		dynamic_irq_init(irq);
+		set_irq_chip_and_handler_name(irq, &xen_dynamic_chip,
+					      handle_level_irq,
"event");
+
+		evtchn_to_irq[evtchn] =3D irq;
+		irq_info[irq] =3D mk_irq_info(IRQT_EVTCHN, 0, evtchn);
+	}
+
+	irq_bindcount[irq]++;
+
+	spin_unlock(&irq_mapping_update_lock);
+
+	return irq;
+}
+EXPORT_SYMBOL_GPL(bind_evtchn_to_irq);
+
+static int bind_ipi_to_irq(unsigned int ipi, unsigned int cpu)
+{
+	struct evtchn_bind_ipi bind_ipi;
+	int evtchn, irq;
+
+	spin_lock(&irq_mapping_update_lock);
+
+	irq =3D per_cpu(ipi_to_irq, cpu)[ipi];
+	if (irq =3D=3D -1) {
+		irq =3D find_unbound_irq();
+		if (irq < 0)
+			goto out;
+
+		dynamic_irq_init(irq);
+		set_irq_chip_and_handler_name(irq, &xen_dynamic_chip,
+					      handle_level_irq, "ipi");
+
+		bind_ipi.vcpu =3D cpu;
+		if (HYPERVISOR_event_channel_op(EVTCHNOP_bind_ipi,
+						&bind_ipi) !=3D 0)
+			BUG();
+		evtchn =3D bind_ipi.port;
+
+		evtchn_to_irq[evtchn] =3D irq;
+		irq_info[irq] =3D mk_irq_info(IRQT_IPI, ipi, evtchn);
+
+		per_cpu(ipi_to_irq, cpu)[ipi] =3D irq;
+
+		bind_evtchn_to_cpu(evtchn, cpu);
+	}
+
+	irq_bindcount[irq]++;
+
+ out:
+	spin_unlock(&irq_mapping_update_lock);
+	return irq;
+}
+
+
+static int bind_virq_to_irq(unsigned int virq, unsigned int cpu)
+{
+	struct evtchn_bind_virq bind_virq;
+	int evtchn, irq;
+
+	spin_lock(&irq_mapping_update_lock);
+
+	irq =3D per_cpu(virq_to_irq, cpu)[virq];
+
+	if (irq =3D=3D -1) {
+		bind_virq.virq =3D virq;
+		bind_virq.vcpu =3D cpu;
+		if (HYPERVISOR_event_channel_op(EVTCHNOP_bind_virq,
+						&bind_virq) !=3D 0)
+			BUG();
+		evtchn =3D bind_virq.port;
+
+		irq =3D find_unbound_irq();
+
+		dynamic_irq_init(irq);
+		set_irq_chip_and_handler_name(irq, &xen_dynamic_chip,
+					      handle_level_irq, "virq");
+
+		evtchn_to_irq[evtchn] =3D irq;
+		irq_info[irq] =3D mk_irq_info(IRQT_VIRQ, virq, evtchn);
+
+		per_cpu(virq_to_irq, cpu)[virq] =3D irq;
+
+		bind_evtchn_to_cpu(evtchn, cpu);
+	}
+
+	irq_bindcount[irq]++;
+
+	spin_unlock(&irq_mapping_update_lock);
+
+	return irq;
+}
+
+static void unbind_from_irq(unsigned int irq)
+{
+	struct evtchn_close close;
+	int evtchn =3D evtchn_from_irq(irq);
+
+	spin_lock(&irq_mapping_update_lock);
+
+	if (VALID_EVTCHN(evtchn) && (--irq_bindcount[irq] =3D=3D 0)) {
+		close.port =3D evtchn;
+		if (HYPERVISOR_event_channel_op(EVTCHNOP_close, &close)
!=3D 0)
+			BUG();
+
+		switch (type_from_irq(irq)) {
+		case IRQT_VIRQ:
+			per_cpu(virq_to_irq, cpu_from_evtchn(evtchn))
+				[index_from_irq(irq)] =3D -1;
+			break;
+		default:
+			break;
+		}
+
+		/* Closed ports are implicitly re-bound to VCPU0. */
+		bind_evtchn_to_cpu(evtchn, 0);
+
+		evtchn_to_irq[evtchn] =3D -1;
+		irq_info[irq] =3D IRQ_UNBOUND;
+
+		dynamic_irq_init(irq);
+	}
+
+	spin_unlock(&irq_mapping_update_lock);
+}
+
+int bind_evtchn_to_irqhandler(unsigned int evtchn,
+			      irq_handler_t handler,
+			      unsigned long irqflags,
+			      const char *devname, void *dev_id)
+{
+	unsigned int irq;
+	int retval;
+
+	irq =3D bind_evtchn_to_irq(evtchn);
+	retval =3D request_irq(irq, handler, irqflags, devname, dev_id);
+	if (retval !=3D 0) {
+		unbind_from_irq(irq);
+		return retval;
+	}
+
+	return irq;
+}
+EXPORT_SYMBOL_GPL(bind_evtchn_to_irqhandler);
+
+int bind_virq_to_irqhandler(unsigned int virq, unsigned int cpu,
+			    irq_handler_t handler,
+			    unsigned long irqflags, const char *devname,
void *dev_id)
+{
+	unsigned int irq;
+	int retval;
+
+	irq =3D bind_virq_to_irq(virq, cpu);
+	retval =3D request_irq(irq, handler, irqflags, devname, dev_id);
+	if (retval !=3D 0) {
+		unbind_from_irq(irq);
+		return retval;
+	}
+
+	return irq;
+}
+EXPORT_SYMBOL_GPL(bind_virq_to_irqhandler);
+
+int bind_ipi_to_irqhandler(enum ipi_vector ipi,
+			   unsigned int cpu,
+			   irq_handler_t handler,
+			   unsigned long irqflags,
+			   const char *devname,
+			   void *dev_id)
+{
+	int irq, retval;
+
+	irq =3D bind_ipi_to_irq(ipi, cpu);
+	if (irq < 0)
+		return irq;
+
+	retval =3D request_irq(irq, handler, irqflags, devname, dev_id);
+	if (retval !=3D 0) {
+		unbind_from_irq(irq);
+		return retval;
+	}
+
+	return irq;
+}
+
+void unbind_from_irqhandler(unsigned int irq, void *dev_id)
+{
+	free_irq(irq, dev_id);
+	unbind_from_irq(irq);
+}
+EXPORT_SYMBOL_GPL(unbind_from_irqhandler);
+
+void xen_send_IPI_one(unsigned int cpu, enum ipi_vector vector)
+{
+	int irq =3D per_cpu(ipi_to_irq, cpu)[vector];
+	BUG_ON(irq < 0);
+	notify_remote_via_irq(irq);
+}
+
+
+/*
+ * Search the CPUs pending events bitmasks.  For each one found, map
+ * the event number to an irq, and feed it into do_IRQ() for
+ * handling.
+ *
+ * Xen uses a two-level bitmap to speed searching.  The first level is
+ * a bitset of words which contain pending event bits.  The second
+ * level is a bitset of pending events themselves.
+ */
+void xen_evtchn_do_upcall(struct pt_regs *regs)
+{
+	int cpu =3D get_cpu();
+	struct shared_info *s =3D HYPERVISOR_shared_info;
+	struct vcpu_info *vcpu_info =3D __get_cpu_var(xen_vcpu);
+	unsigned long pending_words;
+
+	vcpu_info->evtchn_upcall_pending =3D 0;
+
+	/* NB. No need for a barrier here -- XCHG is a barrier on x86.
*/
+	pending_words =3D xchg(&vcpu_info->evtchn_pending_sel, 0);
+	while (pending_words !=3D 0) {
+		unsigned long pending_bits;
+		int word_idx =3D __ffs(pending_words);
+		pending_words &=3D ~(1UL << word_idx);
+
+		while ((pending_bits =3D active_evtchns(cpu, s, word_idx))
!=3D 0) {
+			int bit_idx =3D __ffs(pending_bits);
+			int port =3D (word_idx * BITS_PER_LONG) + bit_idx;
+			int irq =3D evtchn_to_irq[port];
+
+			if (irq !=3D -1) {
+				regs->orig_ax =3D ~irq;
+				do_IRQ(regs);
+			}
+		}
+	}
+
+	put_cpu();
+}
+
+/* Rebind an evtchn so that it gets delivered to a specific cpu */
+static void rebind_irq_to_cpu(unsigned irq, unsigned tcpu)
+{
+	struct evtchn_bind_vcpu bind_vcpu;
+	int evtchn =3D evtchn_from_irq(irq);
+
+	if (!VALID_EVTCHN(evtchn))
+		return;
+
+	/* Send future instances of this interrupt to other vcpu. */
+	bind_vcpu.port =3D evtchn;
+	bind_vcpu.vcpu =3D tcpu;
+
+	/*
+	 * If this fails, it usually just indicates that we're dealing
with a
+	 * virq or IPI channel, which don't actually need to be rebound.
Ignore
+	 * it, but don't do the xenlinux-level rebind in that case.
+	 */
+	if (HYPERVISOR_event_channel_op(EVTCHNOP_bind_vcpu, &bind_vcpu)
>=3D 0)
+		bind_evtchn_to_cpu(evtchn, tcpu);
+}
+
+
+static void set_affinity_irq(unsigned irq, cpumask_t dest)
+{
+	unsigned tcpu =3D first_cpu(dest);
+	rebind_irq_to_cpu(irq, tcpu);
+}
+
+static void enable_dynirq(unsigned int irq)
+{
+	int evtchn =3D evtchn_from_irq(irq);
+
+	if (VALID_EVTCHN(evtchn))
+		unmask_evtchn(evtchn);
+}
+
+static void disable_dynirq(unsigned int irq)
+{
+	int evtchn =3D evtchn_from_irq(irq);
+
+	if (VALID_EVTCHN(evtchn))
+		mask_evtchn(evtchn);
+}
+
+static void ack_dynirq(unsigned int irq)
+{
+	int evtchn =3D evtchn_from_irq(irq);
+
+	move_native_irq(irq);
+
+	if (VALID_EVTCHN(evtchn))
+		clear_evtchn(evtchn);
+}
+
+static int retrigger_dynirq(unsigned int irq)
+{
+	int evtchn =3D evtchn_from_irq(irq);
+	int ret =3D 0;
+
+	if (VALID_EVTCHN(evtchn)) {
+		set_evtchn(evtchn);
+		ret =3D 1;
+	}
+
+	return ret;
+}
+
+static struct irq_chip xen_dynamic_chip __read_mostly =3D {
+	.name		=3D "xen-dyn",
+	.mask		=3D disable_dynirq,
+	.unmask		=3D enable_dynirq,
+	.ack		=3D ack_dynirq,
+	.set_affinity	=3D set_affinity_irq,
+	.retrigger	=3D retrigger_dynirq,
+};
+
+void __init xen_init_IRQ(void)
+{
+	int i;
+
+	init_evtchn_cpu_bindings();
+
+	/* No event channels are 'live' right now. */
+	for (i =3D 0; i < NR_EVENT_CHANNELS; i++)
+		mask_evtchn(i);
+
+	/* Dynamic IRQ space is currently unbound. Zero the refcnts. */
+	for (i =3D 0; i < NR_IRQS; i++)
+		irq_bindcount[i] =3D 0;
+
+	irq_ctx_init(smp_processor_id());
+}
diff -urN old/drivers/xen/Makefile linux/drivers/xen/Makefile
--- old/drivers/xen/Makefile	2008-03-10 13:22:27.000000000 +0800
+++ linux/drivers/xen/Makefile	2008-03-25 13:56:41.368764287 +0800
@@ -1,2 +1,2 @@
-obj-y	+=3D grant-table.o
+obj-y	+=3D grant-table.o events.o
 obj-y	+=3D xenbus/
diff -urN old/include/xen/xen-ops.h linux/include/xen/xen-ops.h
--- old/include/xen/xen-ops.h	1970-01-01 08:00:00.000000000 +0800
+++ linux/include/xen/xen-ops.h	2008-03-25 14:00:09.041321546 +0800
@@ -0,0 +1,6 @@
+#ifndef INCLUDE_XEN_OPS_H
+#define INCLUDE_XEN_OPS_H
+
+DECLARE_PER_CPU(struct vcpu_info *, xen_vcpu);
+
+#endif /* INCLUDE_XEN_OPS_H */

------_=_NextPart_001_01C88E3F.619D5D07
Content-Type: application/octet-stream;
	name="move_xenirq3.patch"
Content-Transfer-Encoding: base64
Content-Description: move_xenirq3.patch
Content-Disposition: attachment;
	filename="move_xenirq3.patch"

ICAgIE1vdmUgZXZlbnRzLmMgdG8gZHJpdmVycy94ZW4gZm9yIElBNjQvWGVuCiAgICBzdXBwb3J0
LgoKCiAgICBTaWduZWQtb2ZmLWJ5OiBZYW96dSAoRWRkaWUpIERvbmcgPGVkZGllLmRvbmdAaW50
ZWwuY29tPgoKZGlmZiAtdXJOIG9sZC9hcmNoL3g4Ni94ZW4vZXZlbnRzLmMgbGludXgvYXJjaC94
ODYveGVuL2V2ZW50cy5jCi0tLSBvbGQvYXJjaC94ODYveGVuL2V2ZW50cy5jCTIwMDgtMDMtMTAg
MTM6MjI6MjcuMDAwMDAwMDAwICswODAwCisrKyBsaW51eC9hcmNoL3g4Ni94ZW4vZXZlbnRzLmMJ
MTk3MC0wMS0wMSAwODowMDowMC4wMDAwMDAwMDAgKzA4MDAKQEAgLTEsNTkxICswLDAgQEAKLS8q
Ci0gKiBYZW4gZXZlbnQgY2hhbm5lbHMKLSAqCi0gKiBYZW4gbW9kZWxzIGludGVycnVwdHMgd2l0
aCBhYnN0cmFjdCBldmVudCBjaGFubmVscy4gIEJlY2F1c2UgZWFjaAotICogZG9tYWluIGdldHMg
MTAyNCBldmVudCBjaGFubmVscywgYnV0IE5SX0lSUSBpcyBub3QgdGhhdCBsYXJnZSwgd2UKLSAq
IG11c3QgZHluYW1pY2FsbHkgbWFwIGlycXM8LT5ldmVudCBjaGFubmVscy4gIFRoZSBldmVudCBj
aGFubmVscwotICogaW50ZXJmYWNlIHdpdGggdGhlIHJlc3Qgb2YgdGhlIGtlcm5lbCBieSBkZWZp
bmluZyBhIHhlbiBpbnRlcnJ1cHQKLSAqIGNoaXAuICBXaGVuIGFuIGV2ZW50IGlzIHJlY2lldmVk
LCBpdCBpcyBtYXBwZWQgdG8gYW4gaXJxIGFuZCBzZW50Ci0gKiB0aHJvdWdoIHRoZSBub3JtYWwg
aW50ZXJydXB0IHByb2Nlc3NpbmcgcGF0aC4KLSAqCi0gKiBUaGVyZSBhcmUgZm91ciBraW5kcyBv
ZiBldmVudHMgd2hpY2ggY2FuIGJlIG1hcHBlZCB0byBhbiBldmVudAotICogY2hhbm5lbDoKLSAq
Ci0gKiAxLiBJbnRlci1kb21haW4gbm90aWZpY2F0aW9ucy4gIFRoaXMgaW5jbHVkZXMgYWxsIHRo
ZSB2aXJ0dWFsCi0gKiAgICBkZXZpY2UgZXZlbnRzLCBzaW5jZSB0aGV5J3JlIGRyaXZlbiBieSBm
cm9udC1lbmRzIGluIGFub3RoZXIgZG9tYWluCi0gKiAgICAodHlwaWNhbGx5IGRvbTApLgotICog
Mi4gVklSUXMsIHR5cGljYWxseSB1c2VkIGZvciB0aW1lcnMuICBUaGVzZSBhcmUgcGVyLWNwdSBl
dmVudHMuCi0gKiAzLiBJUElzLgotICogNC4gSGFyZHdhcmUgaW50ZXJydXB0cy4gTm90IHN1cHBv
cnRlZCBhdCBwcmVzZW50LgotICoKLSAqIEplcmVteSBGaXR6aGFyZGluZ2UgPGplcmVteUB4ZW5z
b3VyY2UuY29tPiwgWGVuU291cmNlIEluYywgMjAwNwotICovCi0KLSNpbmNsdWRlIDxsaW51eC9s
aW5rYWdlLmg+Ci0jaW5jbHVkZSA8bGludXgvaW50ZXJydXB0Lmg+Ci0jaW5jbHVkZSA8bGludXgv
aXJxLmg+Ci0jaW5jbHVkZSA8bGludXgvbW9kdWxlLmg+Ci0jaW5jbHVkZSA8bGludXgvc3RyaW5n
Lmg+Ci0KLSNpbmNsdWRlIDxhc20vcHRyYWNlLmg+Ci0jaW5jbHVkZSA8YXNtL2lycS5oPgotI2lu
Y2x1ZGUgPGFzbS9zeW5jX2JpdG9wcy5oPgotI2luY2x1ZGUgPGFzbS94ZW4vaHlwZXJjYWxsLmg+
Ci0jaW5jbHVkZSA8YXNtL3hlbi9oeXBlcnZpc29yLmg+Ci0KLSNpbmNsdWRlIDx4ZW4vZXZlbnRz
Lmg+Ci0jaW5jbHVkZSA8eGVuL2ludGVyZmFjZS94ZW4uaD4KLSNpbmNsdWRlIDx4ZW4vaW50ZXJm
YWNlL2V2ZW50X2NoYW5uZWwuaD4KLQotI2luY2x1ZGUgInhlbi1vcHMuaCIKLQotLyoKLSAqIFRo
aXMgbG9jayBwcm90ZWN0cyB1cGRhdGVzIHRvIHRoZSBmb2xsb3dpbmcgbWFwcGluZyBhbmQgcmVm
ZXJlbmNlLWNvdW50Ci0gKiBhcnJheXMuIFRoZSBsb2NrIGRvZXMgbm90IG5lZWQgdG8gYmUgYWNx
dWlyZWQgdG8gcmVhZCB0aGUgbWFwcGluZyB0YWJsZXMuCi0gKi8KLXN0YXRpYyBERUZJTkVfU1BJ
TkxPQ0soaXJxX21hcHBpbmdfdXBkYXRlX2xvY2spOwotCi0vKiBJUlEgPC0+IFZJUlEgbWFwcGlu
Zy4gKi8KLXN0YXRpYyBERUZJTkVfUEVSX0NQVShpbnQsIHZpcnFfdG9faXJxW05SX1ZJUlFTXSkg
PSB7WzAgLi4uIE5SX1ZJUlFTLTFdID0gLTF9OwotCi0vKiBJUlEgPC0+IElQSSBtYXBwaW5nICov
Ci1zdGF0aWMgREVGSU5FX1BFUl9DUFUoaW50LCBpcGlfdG9faXJxW1hFTl9OUl9JUElTXSkgPSB7
WzAgLi4uIFhFTl9OUl9JUElTLTFdID0gLTF9OwotCi0vKiBQYWNrZWQgSVJRIGluZm9ybWF0aW9u
OiBiaW5kaW5nIHR5cGUsIHN1Yi10eXBlIGluZGV4LCBhbmQgZXZlbnQgY2hhbm5lbC4gKi8KLXN0
cnVjdCBwYWNrZWRfaXJxCi17Ci0JdW5zaWduZWQgc2hvcnQgZXZ0Y2huOwotCXVuc2lnbmVkIGNo
YXIgaW5kZXg7Ci0JdW5zaWduZWQgY2hhciB0eXBlOwotfTsKLQotc3RhdGljIHN0cnVjdCBwYWNr
ZWRfaXJxIGlycV9pbmZvW05SX0lSUVNdOwotCi0vKiBCaW5kaW5nIHR5cGVzLiAqLwotZW51bSB7
Ci0JSVJRVF9VTkJPVU5ELAotCUlSUVRfUElSUSwKLQlJUlFUX1ZJUlEsCi0JSVJRVF9JUEksCi0J
SVJRVF9FVlRDSE4KLX07Ci0KLS8qIENvbnZlbmllbnQgc2hvcnRoYW5kIGZvciBwYWNrZWQgcmVw
cmVzZW50YXRpb24gb2YgYW4gdW5ib3VuZCBJUlEuICovCi0jZGVmaW5lIElSUV9VTkJPVU5ECW1r
X2lycV9pbmZvKElSUVRfVU5CT1VORCwgMCwgMCkKLQotc3RhdGljIGludCBldnRjaG5fdG9faXJx
W05SX0VWRU5UX0NIQU5ORUxTXSA9IHsKLQlbMCAuLi4gTlJfRVZFTlRfQ0hBTk5FTFMtMV0gPSAt
MQotfTsKLXN0YXRpYyB1bnNpZ25lZCBsb25nIGNwdV9ldnRjaG5fbWFza1tOUl9DUFVTXVtOUl9F
VkVOVF9DSEFOTkVMUy9CSVRTX1BFUl9MT05HXTsKLXN0YXRpYyB1OCBjcHVfZXZ0Y2huW05SX0VW
RU5UX0NIQU5ORUxTXTsKLQotLyogUmVmZXJlbmNlIGNvdW50cyBmb3IgYmluZGluZ3MgdG8gSVJR
cy4gKi8KLXN0YXRpYyBpbnQgaXJxX2JpbmRjb3VudFtOUl9JUlFTXTsKLQotLyogWGVuIHdpbGwg
bmV2ZXIgYWxsb2NhdGUgcG9ydCB6ZXJvIGZvciBhbnkgcHVycG9zZS4gKi8KLSNkZWZpbmUgVkFM
SURfRVZUQ0hOKGNobikJKChjaG4pICE9IDApCi0KLS8qCi0gKiBGb3JjZSBhIHByb3BlciBldmVu
dC1jaGFubmVsIGNhbGxiYWNrIGZyb20gWGVuIGFmdGVyIGNsZWFyaW5nIHRoZQotICogY2FsbGJh
Y2sgbWFzay4gV2UgZG8gdGhpcyBpbiBhIHZlcnkgc2ltcGxlIG1hbm5lciwgYnkgbWFraW5nIGEg
Y2FsbAotICogZG93biBpbnRvIFhlbi4gVGhlIHBlbmRpbmcgZmxhZyB3aWxsIGJlIGNoZWNrZWQg
YnkgWGVuIG9uIHJldHVybi4KLSAqLwotdm9pZCBmb3JjZV9ldnRjaG5fY2FsbGJhY2sodm9pZCkK
LXsKLQkodm9pZClIWVBFUlZJU09SX3hlbl92ZXJzaW9uKDAsIE5VTEwpOwotfQotRVhQT1JUX1NZ
TUJPTF9HUEwoZm9yY2VfZXZ0Y2huX2NhbGxiYWNrKTsKLQotc3RhdGljIHN0cnVjdCBpcnFfY2hp
cCB4ZW5fZHluYW1pY19jaGlwOwotCi0vKiBDb25zdHJ1Y3RvciBmb3IgcGFja2VkIElSUSBpbmZv
cm1hdGlvbi4gKi8KLXN0YXRpYyBpbmxpbmUgc3RydWN0IHBhY2tlZF9pcnEgbWtfaXJxX2luZm8o
dTMyIHR5cGUsIHUzMiBpbmRleCwgdTMyIGV2dGNobikKLXsKLQlyZXR1cm4gKHN0cnVjdCBwYWNr
ZWRfaXJxKSB7IGV2dGNobiwgaW5kZXgsIHR5cGUgfTsKLX0KLQotLyoKLSAqIEFjY2Vzc29ycyBm
b3IgcGFja2VkIElSUSBpbmZvcm1hdGlvbi4KLSAqLwotc3RhdGljIGlubGluZSB1bnNpZ25lZCBp
bnQgZXZ0Y2huX2Zyb21faXJxKGludCBpcnEpCi17Ci0JcmV0dXJuIGlycV9pbmZvW2lycV0uZXZ0
Y2huOwotfQotCi1zdGF0aWMgaW5saW5lIHVuc2lnbmVkIGludCBpbmRleF9mcm9tX2lycShpbnQg
aXJxKQotewotCXJldHVybiBpcnFfaW5mb1tpcnFdLmluZGV4OwotfQotCi1zdGF0aWMgaW5saW5l
IHVuc2lnbmVkIGludCB0eXBlX2Zyb21faXJxKGludCBpcnEpCi17Ci0JcmV0dXJuIGlycV9pbmZv
W2lycV0udHlwZTsKLX0KLQotc3RhdGljIGlubGluZSB1bnNpZ25lZCBsb25nIGFjdGl2ZV9ldnRj
aG5zKHVuc2lnbmVkIGludCBjcHUsCi0JCQkJCSAgIHN0cnVjdCBzaGFyZWRfaW5mbyAqc2gsCi0J
CQkJCSAgIHVuc2lnbmVkIGludCBpZHgpCi17Ci0JcmV0dXJuIChzaC0+ZXZ0Y2huX3BlbmRpbmdb
aWR4XSAmCi0JCWNwdV9ldnRjaG5fbWFza1tjcHVdW2lkeF0gJgotCQl+c2gtPmV2dGNobl9tYXNr
W2lkeF0pOwotfQotCi1zdGF0aWMgdm9pZCBiaW5kX2V2dGNobl90b19jcHUodW5zaWduZWQgaW50
IGNobiwgdW5zaWduZWQgaW50IGNwdSkKLXsKLQlpbnQgaXJxID0gZXZ0Y2huX3RvX2lycVtjaG5d
OwotCi0JQlVHX09OKGlycSA9PSAtMSk7Ci0jaWZkZWYgQ09ORklHX1NNUAotCWlycV9kZXNjW2ly
cV0uYWZmaW5pdHkgPSBjcHVtYXNrX29mX2NwdShjcHUpOwotI2VuZGlmCi0KLQlfX2NsZWFyX2Jp
dChjaG4sIGNwdV9ldnRjaG5fbWFza1tjcHVfZXZ0Y2huW2Nobl1dKTsKLQlfX3NldF9iaXQoY2hu
LCBjcHVfZXZ0Y2huX21hc2tbY3B1XSk7Ci0KLQljcHVfZXZ0Y2huW2Nobl0gPSBjcHU7Ci19Ci0K
LXN0YXRpYyB2b2lkIGluaXRfZXZ0Y2huX2NwdV9iaW5kaW5ncyh2b2lkKQotewotI2lmZGVmIENP
TkZJR19TTVAKLQlpbnQgaTsKLQkvKiBCeSBkZWZhdWx0IGFsbCBldmVudCBjaGFubmVscyBub3Rp
ZnkgQ1BVIzAuICovCi0JZm9yIChpID0gMDsgaSA8IE5SX0lSUVM7IGkrKykKLQkJaXJxX2Rlc2Nb
aV0uYWZmaW5pdHkgPSBjcHVtYXNrX29mX2NwdSgwKTsKLSNlbmRpZgotCi0JbWVtc2V0KGNwdV9l
dnRjaG4sIDAsIHNpemVvZihjcHVfZXZ0Y2huKSk7Ci0JbWVtc2V0KGNwdV9ldnRjaG5fbWFza1sw
XSwgfjAsIHNpemVvZihjcHVfZXZ0Y2huX21hc2tbMF0pKTsKLX0KLQotc3RhdGljIGlubGluZSB1
bnNpZ25lZCBpbnQgY3B1X2Zyb21fZXZ0Y2huKHVuc2lnbmVkIGludCBldnRjaG4pCi17Ci0JcmV0
dXJuIGNwdV9ldnRjaG5bZXZ0Y2huXTsKLX0KLQotc3RhdGljIGlubGluZSB2b2lkIGNsZWFyX2V2
dGNobihpbnQgcG9ydCkKLXsKLQlzdHJ1Y3Qgc2hhcmVkX2luZm8gKnMgPSBIWVBFUlZJU09SX3No
YXJlZF9pbmZvOwotCXN5bmNfY2xlYXJfYml0KHBvcnQsICZzLT5ldnRjaG5fcGVuZGluZ1swXSk7
Ci19Ci0KLXN0YXRpYyBpbmxpbmUgdm9pZCBzZXRfZXZ0Y2huKGludCBwb3J0KQotewotCXN0cnVj
dCBzaGFyZWRfaW5mbyAqcyA9IEhZUEVSVklTT1Jfc2hhcmVkX2luZm87Ci0Jc3luY19zZXRfYml0
KHBvcnQsICZzLT5ldnRjaG5fcGVuZGluZ1swXSk7Ci19Ci0KLQotLyoqCi0gKiBub3RpZnlfcmVt
b3RlX3ZpYV9pcnEgLSBzZW5kIGV2ZW50IHRvIHJlbW90ZSBlbmQgb2YgZXZlbnQgY2hhbm5lbCB2
aWEgaXJxCi0gKiBAaXJxOiBpcnEgb2YgZXZlbnQgY2hhbm5lbCB0byBzZW5kIGV2ZW50IHRvCi0g
KgotICogVW5saWtlIG5vdGlmeV9yZW1vdGVfdmlhX2V2dGNobigpLCB0aGlzIGlzIHNhZmUgdG8g
dXNlIGFjcm9zcwotICogc2F2ZS9yZXN0b3JlLiBOb3RpZmljYXRpb25zIG9uIGEgYnJva2VuIGNv
bm5lY3Rpb24gYXJlIHNpbGVudGx5Ci0gKiBkcm9wcGVkLgotICovCi12b2lkIG5vdGlmeV9yZW1v
dGVfdmlhX2lycShpbnQgaXJxKQotewotCWludCBldnRjaG4gPSBldnRjaG5fZnJvbV9pcnEoaXJx
KTsKLQotCWlmIChWQUxJRF9FVlRDSE4oZXZ0Y2huKSkKLQkJbm90aWZ5X3JlbW90ZV92aWFfZXZ0
Y2huKGV2dGNobik7Ci19Ci1FWFBPUlRfU1lNQk9MX0dQTChub3RpZnlfcmVtb3RlX3ZpYV9pcnEp
OwotCi1zdGF0aWMgdm9pZCBtYXNrX2V2dGNobihpbnQgcG9ydCkKLXsKLQlzdHJ1Y3Qgc2hhcmVk
X2luZm8gKnMgPSBIWVBFUlZJU09SX3NoYXJlZF9pbmZvOwotCXN5bmNfc2V0X2JpdChwb3J0LCAm
cy0+ZXZ0Y2huX21hc2tbMF0pOwotfQotCi1zdGF0aWMgdm9pZCB1bm1hc2tfZXZ0Y2huKGludCBw
b3J0KQotewotCXN0cnVjdCBzaGFyZWRfaW5mbyAqcyA9IEhZUEVSVklTT1Jfc2hhcmVkX2luZm87
Ci0JdW5zaWduZWQgaW50IGNwdSA9IGdldF9jcHUoKTsKLQotCUJVR19PTighaXJxc19kaXNhYmxl
ZCgpKTsKLQotCS8qIFNsb3cgcGF0aCAoaHlwZXJjYWxsKSBpZiB0aGlzIGlzIGEgbm9uLWxvY2Fs
IHBvcnQuICovCi0JaWYgKHVubGlrZWx5KGNwdSAhPSBjcHVfZnJvbV9ldnRjaG4ocG9ydCkpKSB7
Ci0JCXN0cnVjdCBldnRjaG5fdW5tYXNrIHVubWFzayA9IHsgLnBvcnQgPSBwb3J0IH07Ci0JCSh2
b2lkKUhZUEVSVklTT1JfZXZlbnRfY2hhbm5lbF9vcChFVlRDSE5PUF91bm1hc2ssICZ1bm1hc2sp
OwotCX0gZWxzZSB7Ci0JCXN0cnVjdCB2Y3B1X2luZm8gKnZjcHVfaW5mbyA9IF9fZ2V0X2NwdV92
YXIoeGVuX3ZjcHUpOwotCi0JCXN5bmNfY2xlYXJfYml0KHBvcnQsICZzLT5ldnRjaG5fbWFza1sw
XSk7Ci0KLQkJLyoKLQkJICogVGhlIGZvbGxvd2luZyBpcyBiYXNpY2FsbHkgdGhlIGVxdWl2YWxl
bnQgb2YKLQkJICogJ2h3X3Jlc2VuZF9pcnEnLiBKdXN0IGxpa2UgYSByZWFsIElPLUFQSUMgd2Ug
J2xvc2UKLQkJICogdGhlIGludGVycnVwdCBlZGdlJyBpZiB0aGUgY2hhbm5lbCBpcyBtYXNrZWQu
Ci0JCSAqLwotCQlpZiAoc3luY190ZXN0X2JpdChwb3J0LCAmcy0+ZXZ0Y2huX3BlbmRpbmdbMF0p
ICYmCi0JCSAgICAhc3luY190ZXN0X2FuZF9zZXRfYml0KHBvcnQgLyBCSVRTX1BFUl9MT05HLAot
CQkJCQkgICAmdmNwdV9pbmZvLT5ldnRjaG5fcGVuZGluZ19zZWwpKQotCQkJdmNwdV9pbmZvLT5l
dnRjaG5fdXBjYWxsX3BlbmRpbmcgPSAxOwotCX0KLQotCXB1dF9jcHUoKTsKLX0KLQotc3RhdGlj
IGludCBmaW5kX3VuYm91bmRfaXJxKHZvaWQpCi17Ci0JaW50IGlycTsKLQotCS8qIE9ubHkgYWxs
b2NhdGUgZnJvbSBkeW5pcnEgcmFuZ2UgKi8KLQlmb3IgKGlycSA9IDA7IGlycSA8IE5SX0lSUVM7
IGlycSsrKQotCQlpZiAoaXJxX2JpbmRjb3VudFtpcnFdID09IDApCi0JCQlicmVhazsKLQotCWlm
IChpcnEgPT0gTlJfSVJRUykKLQkJcGFuaWMoIk5vIGF2YWlsYWJsZSBJUlEgdG8gYmluZCB0bzog
aW5jcmVhc2UgTlJfSVJRUyFcbiIpOwotCi0JcmV0dXJuIGlycTsKLX0KLQotaW50IGJpbmRfZXZ0
Y2huX3RvX2lycSh1bnNpZ25lZCBpbnQgZXZ0Y2huKQotewotCWludCBpcnE7Ci0KLQlzcGluX2xv
Y2soJmlycV9tYXBwaW5nX3VwZGF0ZV9sb2NrKTsKLQotCWlycSA9IGV2dGNobl90b19pcnFbZXZ0
Y2huXTsKLQotCWlmIChpcnEgPT0gLTEpIHsKLQkJaXJxID0gZmluZF91bmJvdW5kX2lycSgpOwot
Ci0JCWR5bmFtaWNfaXJxX2luaXQoaXJxKTsKLQkJc2V0X2lycV9jaGlwX2FuZF9oYW5kbGVyX25h
bWUoaXJxLCAmeGVuX2R5bmFtaWNfY2hpcCwKLQkJCQkJICAgICAgaGFuZGxlX2xldmVsX2lycSwg
ImV2ZW50Iik7Ci0KLQkJZXZ0Y2huX3RvX2lycVtldnRjaG5dID0gaXJxOwotCQlpcnFfaW5mb1tp
cnFdID0gbWtfaXJxX2luZm8oSVJRVF9FVlRDSE4sIDAsIGV2dGNobik7Ci0JfQotCi0JaXJxX2Jp
bmRjb3VudFtpcnFdKys7Ci0KLQlzcGluX3VubG9jaygmaXJxX21hcHBpbmdfdXBkYXRlX2xvY2sp
OwotCi0JcmV0dXJuIGlycTsKLX0KLUVYUE9SVF9TWU1CT0xfR1BMKGJpbmRfZXZ0Y2huX3RvX2ly
cSk7Ci0KLXN0YXRpYyBpbnQgYmluZF9pcGlfdG9faXJxKHVuc2lnbmVkIGludCBpcGksIHVuc2ln
bmVkIGludCBjcHUpCi17Ci0Jc3RydWN0IGV2dGNobl9iaW5kX2lwaSBiaW5kX2lwaTsKLQlpbnQg
ZXZ0Y2huLCBpcnE7Ci0KLQlzcGluX2xvY2soJmlycV9tYXBwaW5nX3VwZGF0ZV9sb2NrKTsKLQot
CWlycSA9IHBlcl9jcHUoaXBpX3RvX2lycSwgY3B1KVtpcGldOwotCWlmIChpcnEgPT0gLTEpIHsK
LQkJaXJxID0gZmluZF91bmJvdW5kX2lycSgpOwotCQlpZiAoaXJxIDwgMCkKLQkJCWdvdG8gb3V0
OwotCi0JCWR5bmFtaWNfaXJxX2luaXQoaXJxKTsKLQkJc2V0X2lycV9jaGlwX2FuZF9oYW5kbGVy
X25hbWUoaXJxLCAmeGVuX2R5bmFtaWNfY2hpcCwKLQkJCQkJICAgICAgaGFuZGxlX2xldmVsX2ly
cSwgImlwaSIpOwotCi0JCWJpbmRfaXBpLnZjcHUgPSBjcHU7Ci0JCWlmIChIWVBFUlZJU09SX2V2
ZW50X2NoYW5uZWxfb3AoRVZUQ0hOT1BfYmluZF9pcGksCi0JCQkJCQkmYmluZF9pcGkpICE9IDAp
Ci0JCQlCVUcoKTsKLQkJZXZ0Y2huID0gYmluZF9pcGkucG9ydDsKLQotCQlldnRjaG5fdG9faXJx
W2V2dGNobl0gPSBpcnE7Ci0JCWlycV9pbmZvW2lycV0gPSBta19pcnFfaW5mbyhJUlFUX0lQSSwg
aXBpLCBldnRjaG4pOwotCi0JCXBlcl9jcHUoaXBpX3RvX2lycSwgY3B1KVtpcGldID0gaXJxOwot
Ci0JCWJpbmRfZXZ0Y2huX3RvX2NwdShldnRjaG4sIGNwdSk7Ci0JfQotCi0JaXJxX2JpbmRjb3Vu
dFtpcnFdKys7Ci0KLSBvdXQ6Ci0Jc3Bpbl91bmxvY2soJmlycV9tYXBwaW5nX3VwZGF0ZV9sb2Nr
KTsKLQlyZXR1cm4gaXJxOwotfQotCi0KLXN0YXRpYyBpbnQgYmluZF92aXJxX3RvX2lycSh1bnNp
Z25lZCBpbnQgdmlycSwgdW5zaWduZWQgaW50IGNwdSkKLXsKLQlzdHJ1Y3QgZXZ0Y2huX2JpbmRf
dmlycSBiaW5kX3ZpcnE7Ci0JaW50IGV2dGNobiwgaXJxOwotCi0Jc3Bpbl9sb2NrKCZpcnFfbWFw
cGluZ191cGRhdGVfbG9jayk7Ci0KLQlpcnEgPSBwZXJfY3B1KHZpcnFfdG9faXJxLCBjcHUpW3Zp
cnFdOwotCi0JaWYgKGlycSA9PSAtMSkgewotCQliaW5kX3ZpcnEudmlycSA9IHZpcnE7Ci0JCWJp
bmRfdmlycS52Y3B1ID0gY3B1OwotCQlpZiAoSFlQRVJWSVNPUl9ldmVudF9jaGFubmVsX29wKEVW
VENITk9QX2JpbmRfdmlycSwKLQkJCQkJCSZiaW5kX3ZpcnEpICE9IDApCi0JCQlCVUcoKTsKLQkJ
ZXZ0Y2huID0gYmluZF92aXJxLnBvcnQ7Ci0KLQkJaXJxID0gZmluZF91bmJvdW5kX2lycSgpOwot
Ci0JCWR5bmFtaWNfaXJxX2luaXQoaXJxKTsKLQkJc2V0X2lycV9jaGlwX2FuZF9oYW5kbGVyX25h
bWUoaXJxLCAmeGVuX2R5bmFtaWNfY2hpcCwKLQkJCQkJICAgICAgaGFuZGxlX2xldmVsX2lycSwg
InZpcnEiKTsKLQotCQlldnRjaG5fdG9faXJxW2V2dGNobl0gPSBpcnE7Ci0JCWlycV9pbmZvW2ly
cV0gPSBta19pcnFfaW5mbyhJUlFUX1ZJUlEsIHZpcnEsIGV2dGNobik7Ci0KLQkJcGVyX2NwdSh2
aXJxX3RvX2lycSwgY3B1KVt2aXJxXSA9IGlycTsKLQotCQliaW5kX2V2dGNobl90b19jcHUoZXZ0
Y2huLCBjcHUpOwotCX0KLQotCWlycV9iaW5kY291bnRbaXJxXSsrOwotCi0Jc3Bpbl91bmxvY2so
JmlycV9tYXBwaW5nX3VwZGF0ZV9sb2NrKTsKLQotCXJldHVybiBpcnE7Ci19Ci0KLXN0YXRpYyB2
b2lkIHVuYmluZF9mcm9tX2lycSh1bnNpZ25lZCBpbnQgaXJxKQotewotCXN0cnVjdCBldnRjaG5f
Y2xvc2UgY2xvc2U7Ci0JaW50IGV2dGNobiA9IGV2dGNobl9mcm9tX2lycShpcnEpOwotCi0Jc3Bp
bl9sb2NrKCZpcnFfbWFwcGluZ191cGRhdGVfbG9jayk7Ci0KLQlpZiAoVkFMSURfRVZUQ0hOKGV2
dGNobikgJiYgKC0taXJxX2JpbmRjb3VudFtpcnFdID09IDApKSB7Ci0JCWNsb3NlLnBvcnQgPSBl
dnRjaG47Ci0JCWlmIChIWVBFUlZJU09SX2V2ZW50X2NoYW5uZWxfb3AoRVZUQ0hOT1BfY2xvc2Us
ICZjbG9zZSkgIT0gMCkKLQkJCUJVRygpOwotCi0JCXN3aXRjaCAodHlwZV9mcm9tX2lycShpcnEp
KSB7Ci0JCWNhc2UgSVJRVF9WSVJROgotCQkJcGVyX2NwdSh2aXJxX3RvX2lycSwgY3B1X2Zyb21f
ZXZ0Y2huKGV2dGNobikpCi0JCQkJW2luZGV4X2Zyb21faXJxKGlycSldID0gLTE7Ci0JCQlicmVh
azsKLQkJZGVmYXVsdDoKLQkJCWJyZWFrOwotCQl9Ci0KLQkJLyogQ2xvc2VkIHBvcnRzIGFyZSBp
bXBsaWNpdGx5IHJlLWJvdW5kIHRvIFZDUFUwLiAqLwotCQliaW5kX2V2dGNobl90b19jcHUoZXZ0
Y2huLCAwKTsKLQotCQlldnRjaG5fdG9faXJxW2V2dGNobl0gPSAtMTsKLQkJaXJxX2luZm9baXJx
XSA9IElSUV9VTkJPVU5EOwotCi0JCWR5bmFtaWNfaXJxX2luaXQoaXJxKTsKLQl9Ci0KLQlzcGlu
X3VubG9jaygmaXJxX21hcHBpbmdfdXBkYXRlX2xvY2spOwotfQotCi1pbnQgYmluZF9ldnRjaG5f
dG9faXJxaGFuZGxlcih1bnNpZ25lZCBpbnQgZXZ0Y2huLAotCQkJICAgICAgaXJxX2hhbmRsZXJf
dCBoYW5kbGVyLAotCQkJICAgICAgdW5zaWduZWQgbG9uZyBpcnFmbGFncywKLQkJCSAgICAgIGNv
bnN0IGNoYXIgKmRldm5hbWUsIHZvaWQgKmRldl9pZCkKLXsKLQl1bnNpZ25lZCBpbnQgaXJxOwot
CWludCByZXR2YWw7Ci0KLQlpcnEgPSBiaW5kX2V2dGNobl90b19pcnEoZXZ0Y2huKTsKLQlyZXR2
YWwgPSByZXF1ZXN0X2lycShpcnEsIGhhbmRsZXIsIGlycWZsYWdzLCBkZXZuYW1lLCBkZXZfaWQp
OwotCWlmIChyZXR2YWwgIT0gMCkgewotCQl1bmJpbmRfZnJvbV9pcnEoaXJxKTsKLQkJcmV0dXJu
IHJldHZhbDsKLQl9Ci0KLQlyZXR1cm4gaXJxOwotfQotRVhQT1JUX1NZTUJPTF9HUEwoYmluZF9l
dnRjaG5fdG9faXJxaGFuZGxlcik7Ci0KLWludCBiaW5kX3ZpcnFfdG9faXJxaGFuZGxlcih1bnNp
Z25lZCBpbnQgdmlycSwgdW5zaWduZWQgaW50IGNwdSwKLQkJCSAgICBpcnFfaGFuZGxlcl90IGhh
bmRsZXIsCi0JCQkgICAgdW5zaWduZWQgbG9uZyBpcnFmbGFncywgY29uc3QgY2hhciAqZGV2bmFt
ZSwgdm9pZCAqZGV2X2lkKQotewotCXVuc2lnbmVkIGludCBpcnE7Ci0JaW50IHJldHZhbDsKLQot
CWlycSA9IGJpbmRfdmlycV90b19pcnEodmlycSwgY3B1KTsKLQlyZXR2YWwgPSByZXF1ZXN0X2ly
cShpcnEsIGhhbmRsZXIsIGlycWZsYWdzLCBkZXZuYW1lLCBkZXZfaWQpOwotCWlmIChyZXR2YWwg
IT0gMCkgewotCQl1bmJpbmRfZnJvbV9pcnEoaXJxKTsKLQkJcmV0dXJuIHJldHZhbDsKLQl9Ci0K
LQlyZXR1cm4gaXJxOwotfQotRVhQT1JUX1NZTUJPTF9HUEwoYmluZF92aXJxX3RvX2lycWhhbmRs
ZXIpOwotCi1pbnQgYmluZF9pcGlfdG9faXJxaGFuZGxlcihlbnVtIGlwaV92ZWN0b3IgaXBpLAot
CQkJICAgdW5zaWduZWQgaW50IGNwdSwKLQkJCSAgIGlycV9oYW5kbGVyX3QgaGFuZGxlciwKLQkJ
CSAgIHVuc2lnbmVkIGxvbmcgaXJxZmxhZ3MsCi0JCQkgICBjb25zdCBjaGFyICpkZXZuYW1lLAot
CQkJICAgdm9pZCAqZGV2X2lkKQotewotCWludCBpcnEsIHJldHZhbDsKLQotCWlycSA9IGJpbmRf
aXBpX3RvX2lycShpcGksIGNwdSk7Ci0JaWYgKGlycSA8IDApCi0JCXJldHVybiBpcnE7Ci0KLQly
ZXR2YWwgPSByZXF1ZXN0X2lycShpcnEsIGhhbmRsZXIsIGlycWZsYWdzLCBkZXZuYW1lLCBkZXZf
aWQpOwotCWlmIChyZXR2YWwgIT0gMCkgewotCQl1bmJpbmRfZnJvbV9pcnEoaXJxKTsKLQkJcmV0
dXJuIHJldHZhbDsKLQl9Ci0KLQlyZXR1cm4gaXJxOwotfQotCi12b2lkIHVuYmluZF9mcm9tX2ly
cWhhbmRsZXIodW5zaWduZWQgaW50IGlycSwgdm9pZCAqZGV2X2lkKQotewotCWZyZWVfaXJxKGly
cSwgZGV2X2lkKTsKLQl1bmJpbmRfZnJvbV9pcnEoaXJxKTsKLX0KLUVYUE9SVF9TWU1CT0xfR1BM
KHVuYmluZF9mcm9tX2lycWhhbmRsZXIpOwotCi12b2lkIHhlbl9zZW5kX0lQSV9vbmUodW5zaWdu
ZWQgaW50IGNwdSwgZW51bSBpcGlfdmVjdG9yIHZlY3RvcikKLXsKLQlpbnQgaXJxID0gcGVyX2Nw
dShpcGlfdG9faXJxLCBjcHUpW3ZlY3Rvcl07Ci0JQlVHX09OKGlycSA8IDApOwotCW5vdGlmeV9y
ZW1vdGVfdmlhX2lycShpcnEpOwotfQotCi0KLS8qCi0gKiBTZWFyY2ggdGhlIENQVXMgcGVuZGlu
ZyBldmVudHMgYml0bWFza3MuICBGb3IgZWFjaCBvbmUgZm91bmQsIG1hcAotICogdGhlIGV2ZW50
IG51bWJlciB0byBhbiBpcnEsIGFuZCBmZWVkIGl0IGludG8gZG9fSVJRKCkgZm9yCi0gKiBoYW5k
bGluZy4KLSAqCi0gKiBYZW4gdXNlcyBhIHR3by1sZXZlbCBiaXRtYXAgdG8gc3BlZWQgc2VhcmNo
aW5nLiAgVGhlIGZpcnN0IGxldmVsIGlzCi0gKiBhIGJpdHNldCBvZiB3b3JkcyB3aGljaCBjb250
YWluIHBlbmRpbmcgZXZlbnQgYml0cy4gIFRoZSBzZWNvbmQKLSAqIGxldmVsIGlzIGEgYml0c2V0
IG9mIHBlbmRpbmcgZXZlbnRzIHRoZW1zZWx2ZXMuCi0gKi8KLXZvaWQgeGVuX2V2dGNobl9kb191
cGNhbGwoc3RydWN0IHB0X3JlZ3MgKnJlZ3MpCi17Ci0JaW50IGNwdSA9IGdldF9jcHUoKTsKLQlz
dHJ1Y3Qgc2hhcmVkX2luZm8gKnMgPSBIWVBFUlZJU09SX3NoYXJlZF9pbmZvOwotCXN0cnVjdCB2
Y3B1X2luZm8gKnZjcHVfaW5mbyA9IF9fZ2V0X2NwdV92YXIoeGVuX3ZjcHUpOwotCXVuc2lnbmVk
IGxvbmcgcGVuZGluZ193b3JkczsKLQotCXZjcHVfaW5mby0+ZXZ0Y2huX3VwY2FsbF9wZW5kaW5n
ID0gMDsKLQotCS8qIE5CLiBObyBuZWVkIGZvciBhIGJhcnJpZXIgaGVyZSAtLSBYQ0hHIGlzIGEg
YmFycmllciBvbiB4ODYuICovCi0JcGVuZGluZ193b3JkcyA9IHhjaGcoJnZjcHVfaW5mby0+ZXZ0
Y2huX3BlbmRpbmdfc2VsLCAwKTsKLQl3aGlsZSAocGVuZGluZ193b3JkcyAhPSAwKSB7Ci0JCXVu
c2lnbmVkIGxvbmcgcGVuZGluZ19iaXRzOwotCQlpbnQgd29yZF9pZHggPSBfX2ZmcyhwZW5kaW5n
X3dvcmRzKTsKLQkJcGVuZGluZ193b3JkcyAmPSB+KDFVTCA8PCB3b3JkX2lkeCk7Ci0KLQkJd2hp
bGUgKChwZW5kaW5nX2JpdHMgPSBhY3RpdmVfZXZ0Y2hucyhjcHUsIHMsIHdvcmRfaWR4KSkgIT0g
MCkgewotCQkJaW50IGJpdF9pZHggPSBfX2ZmcyhwZW5kaW5nX2JpdHMpOwotCQkJaW50IHBvcnQg
PSAod29yZF9pZHggKiBCSVRTX1BFUl9MT05HKSArIGJpdF9pZHg7Ci0JCQlpbnQgaXJxID0gZXZ0
Y2huX3RvX2lycVtwb3J0XTsKLQotCQkJaWYgKGlycSAhPSAtMSkgewotCQkJCXJlZ3MtPm9yaWdf
YXggPSB+aXJxOwotCQkJCWRvX0lSUShyZWdzKTsKLQkJCX0KLQkJfQotCX0KLQotCXB1dF9jcHUo
KTsKLX0KLQotLyogUmViaW5kIGFuIGV2dGNobiBzbyB0aGF0IGl0IGdldHMgZGVsaXZlcmVkIHRv
IGEgc3BlY2lmaWMgY3B1ICovCi1zdGF0aWMgdm9pZCByZWJpbmRfaXJxX3RvX2NwdSh1bnNpZ25l
ZCBpcnEsIHVuc2lnbmVkIHRjcHUpCi17Ci0Jc3RydWN0IGV2dGNobl9iaW5kX3ZjcHUgYmluZF92
Y3B1OwotCWludCBldnRjaG4gPSBldnRjaG5fZnJvbV9pcnEoaXJxKTsKLQotCWlmICghVkFMSURf
RVZUQ0hOKGV2dGNobikpCi0JCXJldHVybjsKLQotCS8qIFNlbmQgZnV0dXJlIGluc3RhbmNlcyBv
ZiB0aGlzIGludGVycnVwdCB0byBvdGhlciB2Y3B1LiAqLwotCWJpbmRfdmNwdS5wb3J0ID0gZXZ0
Y2huOwotCWJpbmRfdmNwdS52Y3B1ID0gdGNwdTsKLQotCS8qCi0JICogSWYgdGhpcyBmYWlscywg
aXQgdXN1YWxseSBqdXN0IGluZGljYXRlcyB0aGF0IHdlJ3JlIGRlYWxpbmcgd2l0aCBhCi0JICog
dmlycSBvciBJUEkgY2hhbm5lbCwgd2hpY2ggZG9uJ3QgYWN0dWFsbHkgbmVlZCB0byBiZSByZWJv
dW5kLiBJZ25vcmUKLQkgKiBpdCwgYnV0IGRvbid0IGRvIHRoZSB4ZW5saW51eC1sZXZlbCByZWJp
bmQgaW4gdGhhdCBjYXNlLgotCSAqLwotCWlmIChIWVBFUlZJU09SX2V2ZW50X2NoYW5uZWxfb3Ao
RVZUQ0hOT1BfYmluZF92Y3B1LCAmYmluZF92Y3B1KSA+PSAwKQotCQliaW5kX2V2dGNobl90b19j
cHUoZXZ0Y2huLCB0Y3B1KTsKLX0KLQotCi1zdGF0aWMgdm9pZCBzZXRfYWZmaW5pdHlfaXJxKHVu
c2lnbmVkIGlycSwgY3B1bWFza190IGRlc3QpCi17Ci0JdW5zaWduZWQgdGNwdSA9IGZpcnN0X2Nw
dShkZXN0KTsKLQlyZWJpbmRfaXJxX3RvX2NwdShpcnEsIHRjcHUpOwotfQotCi1zdGF0aWMgdm9p
ZCBlbmFibGVfZHluaXJxKHVuc2lnbmVkIGludCBpcnEpCi17Ci0JaW50IGV2dGNobiA9IGV2dGNo
bl9mcm9tX2lycShpcnEpOwotCi0JaWYgKFZBTElEX0VWVENITihldnRjaG4pKQotCQl1bm1hc2tf
ZXZ0Y2huKGV2dGNobik7Ci19Ci0KLXN0YXRpYyB2b2lkIGRpc2FibGVfZHluaXJxKHVuc2lnbmVk
IGludCBpcnEpCi17Ci0JaW50IGV2dGNobiA9IGV2dGNobl9mcm9tX2lycShpcnEpOwotCi0JaWYg
KFZBTElEX0VWVENITihldnRjaG4pKQotCQltYXNrX2V2dGNobihldnRjaG4pOwotfQotCi1zdGF0
aWMgdm9pZCBhY2tfZHluaXJxKHVuc2lnbmVkIGludCBpcnEpCi17Ci0JaW50IGV2dGNobiA9IGV2
dGNobl9mcm9tX2lycShpcnEpOwotCi0JbW92ZV9uYXRpdmVfaXJxKGlycSk7Ci0KLQlpZiAoVkFM
SURfRVZUQ0hOKGV2dGNobikpCi0JCWNsZWFyX2V2dGNobihldnRjaG4pOwotfQotCi1zdGF0aWMg
aW50IHJldHJpZ2dlcl9keW5pcnEodW5zaWduZWQgaW50IGlycSkKLXsKLQlpbnQgZXZ0Y2huID0g
ZXZ0Y2huX2Zyb21faXJxKGlycSk7Ci0JaW50IHJldCA9IDA7Ci0KLQlpZiAoVkFMSURfRVZUQ0hO
KGV2dGNobikpIHsKLQkJc2V0X2V2dGNobihldnRjaG4pOwotCQlyZXQgPSAxOwotCX0KLQotCXJl
dHVybiByZXQ7Ci19Ci0KLXN0YXRpYyBzdHJ1Y3QgaXJxX2NoaXAgeGVuX2R5bmFtaWNfY2hpcCBf
X3JlYWRfbW9zdGx5ID0gewotCS5uYW1lCQk9ICJ4ZW4tZHluIiwKLQkubWFzawkJPSBkaXNhYmxl
X2R5bmlycSwKLQkudW5tYXNrCQk9IGVuYWJsZV9keW5pcnEsCi0JLmFjawkJPSBhY2tfZHluaXJx
LAotCS5zZXRfYWZmaW5pdHkJPSBzZXRfYWZmaW5pdHlfaXJxLAotCS5yZXRyaWdnZXIJPSByZXRy
aWdnZXJfZHluaXJxLAotfTsKLQotdm9pZCBfX2luaXQgeGVuX2luaXRfSVJRKHZvaWQpCi17Ci0J
aW50IGk7Ci0KLQlpbml0X2V2dGNobl9jcHVfYmluZGluZ3MoKTsKLQotCS8qIE5vIGV2ZW50IGNo
YW5uZWxzIGFyZSAnbGl2ZScgcmlnaHQgbm93LiAqLwotCWZvciAoaSA9IDA7IGkgPCBOUl9FVkVO
VF9DSEFOTkVMUzsgaSsrKQotCQltYXNrX2V2dGNobihpKTsKLQotCS8qIER5bmFtaWMgSVJRIHNw
YWNlIGlzIGN1cnJlbnRseSB1bmJvdW5kLiBaZXJvIHRoZSByZWZjbnRzLiAqLwotCWZvciAoaSA9
IDA7IGkgPCBOUl9JUlFTOyBpKyspCi0JCWlycV9iaW5kY291bnRbaV0gPSAwOwotCi0JaXJxX2N0
eF9pbml0KHNtcF9wcm9jZXNzb3JfaWQoKSk7Ci19CmRpZmYgLXVyTiBvbGQvYXJjaC94ODYveGVu
L01ha2VmaWxlIGxpbnV4L2FyY2gveDg2L3hlbi9NYWtlZmlsZQotLS0gb2xkL2FyY2gveDg2L3hl
bi9NYWtlZmlsZQkyMDA4LTAzLTEwIDEzOjIyOjI3LjAwMDAwMDAwMCArMDgwMAorKysgbGludXgv
YXJjaC94ODYveGVuL01ha2VmaWxlCTIwMDgtMDMtMjUgMTM6NTY6NDEuMzY3NzY0NDQ4ICswODAw
CkBAIC0xLDQgKzEsNCBAQAogb2JqLXkJCTo9IGVubGlnaHRlbi5vIHNldHVwLm8gZmVhdHVyZXMu
byBtdWx0aWNhbGxzLm8gbW11Lm8gXAotCQkJZXZlbnRzLm8gdGltZS5vIG1hbmFnZS5vIHhlbi1h
c20ubworCQkJdGltZS5vIG1hbmFnZS5vIHhlbi1hc20ubwogCiBvYmotJChDT05GSUdfU01QKQkr
PSBzbXAubwpkaWZmIC11ck4gb2xkL2FyY2gveDg2L3hlbi94ZW4tb3BzLmggbGludXgvYXJjaC94
ODYveGVuL3hlbi1vcHMuaAotLS0gb2xkL2FyY2gveDg2L3hlbi94ZW4tb3BzLmgJMjAwOC0wMy0y
NSAxMzoyMTowOS45OTY1Mjc2MDQgKzA4MDAKKysrIGxpbnV4L2FyY2gveDg2L3hlbi94ZW4tb3Bz
LmgJMjAwOC0wMy0yNSAxMzo1OToxNi4zNDk4MDkxMzcgKzA4MDAKQEAgLTIsNiArMiw3IEBACiAj
ZGVmaW5lIFhFTl9PUFNfSAogCiAjaW5jbHVkZSA8bGludXgvaW5pdC5oPgorI2luY2x1ZGUgPHhl
bi94ZW4tb3BzLmg+CiAKIC8qIFRoZXNlIGFyZSBjb2RlLCBidXQgbm90IGZ1bmN0aW9ucy4gIERl
ZmluZWQgaW4gZW50cnkuUyAqLwogZXh0ZXJuIGNvbnN0IGNoYXIgeGVuX2h5cGVydmlzb3JfY2Fs
bGJhY2tbXTsKQEAgLTksNyArMTAsNiBAQAogCiB2b2lkIHhlbl9jb3B5X3RyYXBfaW5mbyhzdHJ1
Y3QgdHJhcF9pbmZvICp0cmFwcyk7CiAKLURFQ0xBUkVfUEVSX0NQVShzdHJ1Y3QgdmNwdV9pbmZv
ICosIHhlbl92Y3B1KTsKIERFQ0xBUkVfUEVSX0NQVSh1bnNpZ25lZCBsb25nLCB4ZW5fY3IzKTsK
IERFQ0xBUkVfUEVSX0NQVSh1bnNpZ25lZCBsb25nLCB4ZW5fY3VycmVudF9jcjMpOwogCmRpZmYg
LXVyTiBvbGQvZHJpdmVycy94ZW4vZXZlbnRzLmMgbGludXgvZHJpdmVycy94ZW4vZXZlbnRzLmMK
LS0tIG9sZC9kcml2ZXJzL3hlbi9ldmVudHMuYwkxOTcwLTAxLTAxIDA4OjAwOjAwLjAwMDAwMDAw
MCArMDgwMAorKysgbGludXgvZHJpdmVycy94ZW4vZXZlbnRzLmMJMjAwOC0wMy0yNSAxMzo1Njo0
MS4zNjg3NjQyODcgKzA4MDAKQEAgLTAsMCArMSw1OTEgQEAKKy8qCisgKiBYZW4gZXZlbnQgY2hh
bm5lbHMKKyAqCisgKiBYZW4gbW9kZWxzIGludGVycnVwdHMgd2l0aCBhYnN0cmFjdCBldmVudCBj
aGFubmVscy4gIEJlY2F1c2UgZWFjaAorICogZG9tYWluIGdldHMgMTAyNCBldmVudCBjaGFubmVs
cywgYnV0IE5SX0lSUSBpcyBub3QgdGhhdCBsYXJnZSwgd2UKKyAqIG11c3QgZHluYW1pY2FsbHkg
bWFwIGlycXM8LT5ldmVudCBjaGFubmVscy4gIFRoZSBldmVudCBjaGFubmVscworICogaW50ZXJm
YWNlIHdpdGggdGhlIHJlc3Qgb2YgdGhlIGtlcm5lbCBieSBkZWZpbmluZyBhIHhlbiBpbnRlcnJ1
cHQKKyAqIGNoaXAuICBXaGVuIGFuIGV2ZW50IGlzIHJlY2lldmVkLCBpdCBpcyBtYXBwZWQgdG8g
YW4gaXJxIGFuZCBzZW50CisgKiB0aHJvdWdoIHRoZSBub3JtYWwgaW50ZXJydXB0IHByb2Nlc3Np
bmcgcGF0aC4KKyAqCisgKiBUaGVyZSBhcmUgZm91ciBraW5kcyBvZiBldmVudHMgd2hpY2ggY2Fu
IGJlIG1hcHBlZCB0byBhbiBldmVudAorICogY2hhbm5lbDoKKyAqCisgKiAxLiBJbnRlci1kb21h
aW4gbm90aWZpY2F0aW9ucy4gIFRoaXMgaW5jbHVkZXMgYWxsIHRoZSB2aXJ0dWFsCisgKiAgICBk
ZXZpY2UgZXZlbnRzLCBzaW5jZSB0aGV5J3JlIGRyaXZlbiBieSBmcm9udC1lbmRzIGluIGFub3Ro
ZXIgZG9tYWluCisgKiAgICAodHlwaWNhbGx5IGRvbTApLgorICogMi4gVklSUXMsIHR5cGljYWxs
eSB1c2VkIGZvciB0aW1lcnMuICBUaGVzZSBhcmUgcGVyLWNwdSBldmVudHMuCisgKiAzLiBJUElz
LgorICogNC4gSGFyZHdhcmUgaW50ZXJydXB0cy4gTm90IHN1cHBvcnRlZCBhdCBwcmVzZW50Lgor
ICoKKyAqIEplcmVteSBGaXR6aGFyZGluZ2UgPGplcmVteUB4ZW5zb3VyY2UuY29tPiwgWGVuU291
cmNlIEluYywgMjAwNworICovCisKKyNpbmNsdWRlIDxsaW51eC9saW5rYWdlLmg+CisjaW5jbHVk
ZSA8bGludXgvaW50ZXJydXB0Lmg+CisjaW5jbHVkZSA8bGludXgvaXJxLmg+CisjaW5jbHVkZSA8
bGludXgvbW9kdWxlLmg+CisjaW5jbHVkZSA8bGludXgvc3RyaW5nLmg+CisKKyNpbmNsdWRlIDxh
c20vcHRyYWNlLmg+CisjaW5jbHVkZSA8YXNtL2lycS5oPgorI2luY2x1ZGUgPGFzbS9zeW5jX2Jp
dG9wcy5oPgorI2luY2x1ZGUgPGFzbS94ZW4vaHlwZXJjYWxsLmg+CisjaW5jbHVkZSA8YXNtL3hl
bi9oeXBlcnZpc29yLmg+CisKKyNpbmNsdWRlIDx4ZW4vZXZlbnRzLmg+CisjaW5jbHVkZSA8eGVu
L2ludGVyZmFjZS94ZW4uaD4KKyNpbmNsdWRlIDx4ZW4vaW50ZXJmYWNlL2V2ZW50X2NoYW5uZWwu
aD4KKworI2luY2x1ZGUgInhlbi1vcHMuaCIKKworLyoKKyAqIFRoaXMgbG9jayBwcm90ZWN0cyB1
cGRhdGVzIHRvIHRoZSBmb2xsb3dpbmcgbWFwcGluZyBhbmQgcmVmZXJlbmNlLWNvdW50CisgKiBh
cnJheXMuIFRoZSBsb2NrIGRvZXMgbm90IG5lZWQgdG8gYmUgYWNxdWlyZWQgdG8gcmVhZCB0aGUg
bWFwcGluZyB0YWJsZXMuCisgKi8KK3N0YXRpYyBERUZJTkVfU1BJTkxPQ0soaXJxX21hcHBpbmdf
dXBkYXRlX2xvY2spOworCisvKiBJUlEgPC0+IFZJUlEgbWFwcGluZy4gKi8KK3N0YXRpYyBERUZJ
TkVfUEVSX0NQVShpbnQsIHZpcnFfdG9faXJxW05SX1ZJUlFTXSkgPSB7WzAgLi4uIE5SX1ZJUlFT
LTFdID0gLTF9OworCisvKiBJUlEgPC0+IElQSSBtYXBwaW5nICovCitzdGF0aWMgREVGSU5FX1BF
Ul9DUFUoaW50LCBpcGlfdG9faXJxW1hFTl9OUl9JUElTXSkgPSB7WzAgLi4uIFhFTl9OUl9JUElT
LTFdID0gLTF9OworCisvKiBQYWNrZWQgSVJRIGluZm9ybWF0aW9uOiBiaW5kaW5nIHR5cGUsIHN1
Yi10eXBlIGluZGV4LCBhbmQgZXZlbnQgY2hhbm5lbC4gKi8KK3N0cnVjdCBwYWNrZWRfaXJxCit7
CisJdW5zaWduZWQgc2hvcnQgZXZ0Y2huOworCXVuc2lnbmVkIGNoYXIgaW5kZXg7CisJdW5zaWdu
ZWQgY2hhciB0eXBlOworfTsKKworc3RhdGljIHN0cnVjdCBwYWNrZWRfaXJxIGlycV9pbmZvW05S
X0lSUVNdOworCisvKiBCaW5kaW5nIHR5cGVzLiAqLworZW51bSB7CisJSVJRVF9VTkJPVU5ELAor
CUlSUVRfUElSUSwKKwlJUlFUX1ZJUlEsCisJSVJRVF9JUEksCisJSVJRVF9FVlRDSE4KK307CisK
Ky8qIENvbnZlbmllbnQgc2hvcnRoYW5kIGZvciBwYWNrZWQgcmVwcmVzZW50YXRpb24gb2YgYW4g
dW5ib3VuZCBJUlEuICovCisjZGVmaW5lIElSUV9VTkJPVU5ECW1rX2lycV9pbmZvKElSUVRfVU5C
T1VORCwgMCwgMCkKKworc3RhdGljIGludCBldnRjaG5fdG9faXJxW05SX0VWRU5UX0NIQU5ORUxT
XSA9IHsKKwlbMCAuLi4gTlJfRVZFTlRfQ0hBTk5FTFMtMV0gPSAtMQorfTsKK3N0YXRpYyB1bnNp
Z25lZCBsb25nIGNwdV9ldnRjaG5fbWFza1tOUl9DUFVTXVtOUl9FVkVOVF9DSEFOTkVMUy9CSVRT
X1BFUl9MT05HXTsKK3N0YXRpYyB1OCBjcHVfZXZ0Y2huW05SX0VWRU5UX0NIQU5ORUxTXTsKKwor
LyogUmVmZXJlbmNlIGNvdW50cyBmb3IgYmluZGluZ3MgdG8gSVJRcy4gKi8KK3N0YXRpYyBpbnQg
aXJxX2JpbmRjb3VudFtOUl9JUlFTXTsKKworLyogWGVuIHdpbGwgbmV2ZXIgYWxsb2NhdGUgcG9y
dCB6ZXJvIGZvciBhbnkgcHVycG9zZS4gKi8KKyNkZWZpbmUgVkFMSURfRVZUQ0hOKGNobikJKChj
aG4pICE9IDApCisKKy8qCisgKiBGb3JjZSBhIHByb3BlciBldmVudC1jaGFubmVsIGNhbGxiYWNr
IGZyb20gWGVuIGFmdGVyIGNsZWFyaW5nIHRoZQorICogY2FsbGJhY2sgbWFzay4gV2UgZG8gdGhp
cyBpbiBhIHZlcnkgc2ltcGxlIG1hbm5lciwgYnkgbWFraW5nIGEgY2FsbAorICogZG93biBpbnRv
IFhlbi4gVGhlIHBlbmRpbmcgZmxhZyB3aWxsIGJlIGNoZWNrZWQgYnkgWGVuIG9uIHJldHVybi4K
KyAqLwordm9pZCBmb3JjZV9ldnRjaG5fY2FsbGJhY2sodm9pZCkKK3sKKwkodm9pZClIWVBFUlZJ
U09SX3hlbl92ZXJzaW9uKDAsIE5VTEwpOworfQorRVhQT1JUX1NZTUJPTF9HUEwoZm9yY2VfZXZ0
Y2huX2NhbGxiYWNrKTsKKworc3RhdGljIHN0cnVjdCBpcnFfY2hpcCB4ZW5fZHluYW1pY19jaGlw
OworCisvKiBDb25zdHJ1Y3RvciBmb3IgcGFja2VkIElSUSBpbmZvcm1hdGlvbi4gKi8KK3N0YXRp
YyBpbmxpbmUgc3RydWN0IHBhY2tlZF9pcnEgbWtfaXJxX2luZm8odTMyIHR5cGUsIHUzMiBpbmRl
eCwgdTMyIGV2dGNobikKK3sKKwlyZXR1cm4gKHN0cnVjdCBwYWNrZWRfaXJxKSB7IGV2dGNobiwg
aW5kZXgsIHR5cGUgfTsKK30KKworLyoKKyAqIEFjY2Vzc29ycyBmb3IgcGFja2VkIElSUSBpbmZv
cm1hdGlvbi4KKyAqLworc3RhdGljIGlubGluZSB1bnNpZ25lZCBpbnQgZXZ0Y2huX2Zyb21faXJx
KGludCBpcnEpCit7CisJcmV0dXJuIGlycV9pbmZvW2lycV0uZXZ0Y2huOworfQorCitzdGF0aWMg
aW5saW5lIHVuc2lnbmVkIGludCBpbmRleF9mcm9tX2lycShpbnQgaXJxKQoreworCXJldHVybiBp
cnFfaW5mb1tpcnFdLmluZGV4OworfQorCitzdGF0aWMgaW5saW5lIHVuc2lnbmVkIGludCB0eXBl
X2Zyb21faXJxKGludCBpcnEpCit7CisJcmV0dXJuIGlycV9pbmZvW2lycV0udHlwZTsKK30KKwor
c3RhdGljIGlubGluZSB1bnNpZ25lZCBsb25nIGFjdGl2ZV9ldnRjaG5zKHVuc2lnbmVkIGludCBj
cHUsCisJCQkJCSAgIHN0cnVjdCBzaGFyZWRfaW5mbyAqc2gsCisJCQkJCSAgIHVuc2lnbmVkIGlu
dCBpZHgpCit7CisJcmV0dXJuIChzaC0+ZXZ0Y2huX3BlbmRpbmdbaWR4XSAmCisJCWNwdV9ldnRj
aG5fbWFza1tjcHVdW2lkeF0gJgorCQl+c2gtPmV2dGNobl9tYXNrW2lkeF0pOworfQorCitzdGF0
aWMgdm9pZCBiaW5kX2V2dGNobl90b19jcHUodW5zaWduZWQgaW50IGNobiwgdW5zaWduZWQgaW50
IGNwdSkKK3sKKwlpbnQgaXJxID0gZXZ0Y2huX3RvX2lycVtjaG5dOworCisJQlVHX09OKGlycSA9
PSAtMSk7CisjaWZkZWYgQ09ORklHX1NNUAorCWlycV9kZXNjW2lycV0uYWZmaW5pdHkgPSBjcHVt
YXNrX29mX2NwdShjcHUpOworI2VuZGlmCisKKwlfX2NsZWFyX2JpdChjaG4sIGNwdV9ldnRjaG5f
bWFza1tjcHVfZXZ0Y2huW2Nobl1dKTsKKwlfX3NldF9iaXQoY2huLCBjcHVfZXZ0Y2huX21hc2tb
Y3B1XSk7CisKKwljcHVfZXZ0Y2huW2Nobl0gPSBjcHU7Cit9CisKK3N0YXRpYyB2b2lkIGluaXRf
ZXZ0Y2huX2NwdV9iaW5kaW5ncyh2b2lkKQoreworI2lmZGVmIENPTkZJR19TTVAKKwlpbnQgaTsK
KwkvKiBCeSBkZWZhdWx0IGFsbCBldmVudCBjaGFubmVscyBub3RpZnkgQ1BVIzAuICovCisJZm9y
IChpID0gMDsgaSA8IE5SX0lSUVM7IGkrKykKKwkJaXJxX2Rlc2NbaV0uYWZmaW5pdHkgPSBjcHVt
YXNrX29mX2NwdSgwKTsKKyNlbmRpZgorCisJbWVtc2V0KGNwdV9ldnRjaG4sIDAsIHNpemVvZihj
cHVfZXZ0Y2huKSk7CisJbWVtc2V0KGNwdV9ldnRjaG5fbWFza1swXSwgfjAsIHNpemVvZihjcHVf
ZXZ0Y2huX21hc2tbMF0pKTsKK30KKworc3RhdGljIGlubGluZSB1bnNpZ25lZCBpbnQgY3B1X2Zy
b21fZXZ0Y2huKHVuc2lnbmVkIGludCBldnRjaG4pCit7CisJcmV0dXJuIGNwdV9ldnRjaG5bZXZ0
Y2huXTsKK30KKworc3RhdGljIGlubGluZSB2b2lkIGNsZWFyX2V2dGNobihpbnQgcG9ydCkKK3sK
KwlzdHJ1Y3Qgc2hhcmVkX2luZm8gKnMgPSBIWVBFUlZJU09SX3NoYXJlZF9pbmZvOworCXN5bmNf
Y2xlYXJfYml0KHBvcnQsICZzLT5ldnRjaG5fcGVuZGluZ1swXSk7Cit9CisKK3N0YXRpYyBpbmxp
bmUgdm9pZCBzZXRfZXZ0Y2huKGludCBwb3J0KQoreworCXN0cnVjdCBzaGFyZWRfaW5mbyAqcyA9
IEhZUEVSVklTT1Jfc2hhcmVkX2luZm87CisJc3luY19zZXRfYml0KHBvcnQsICZzLT5ldnRjaG5f
cGVuZGluZ1swXSk7Cit9CisKKworLyoqCisgKiBub3RpZnlfcmVtb3RlX3ZpYV9pcnEgLSBzZW5k
IGV2ZW50IHRvIHJlbW90ZSBlbmQgb2YgZXZlbnQgY2hhbm5lbCB2aWEgaXJxCisgKiBAaXJxOiBp
cnEgb2YgZXZlbnQgY2hhbm5lbCB0byBzZW5kIGV2ZW50IHRvCisgKgorICogVW5saWtlIG5vdGlm
eV9yZW1vdGVfdmlhX2V2dGNobigpLCB0aGlzIGlzIHNhZmUgdG8gdXNlIGFjcm9zcworICogc2F2
ZS9yZXN0b3JlLiBOb3RpZmljYXRpb25zIG9uIGEgYnJva2VuIGNvbm5lY3Rpb24gYXJlIHNpbGVu
dGx5CisgKiBkcm9wcGVkLgorICovCit2b2lkIG5vdGlmeV9yZW1vdGVfdmlhX2lycShpbnQgaXJx
KQoreworCWludCBldnRjaG4gPSBldnRjaG5fZnJvbV9pcnEoaXJxKTsKKworCWlmIChWQUxJRF9F
VlRDSE4oZXZ0Y2huKSkKKwkJbm90aWZ5X3JlbW90ZV92aWFfZXZ0Y2huKGV2dGNobik7Cit9CitF
WFBPUlRfU1lNQk9MX0dQTChub3RpZnlfcmVtb3RlX3ZpYV9pcnEpOworCitzdGF0aWMgdm9pZCBt
YXNrX2V2dGNobihpbnQgcG9ydCkKK3sKKwlzdHJ1Y3Qgc2hhcmVkX2luZm8gKnMgPSBIWVBFUlZJ
U09SX3NoYXJlZF9pbmZvOworCXN5bmNfc2V0X2JpdChwb3J0LCAmcy0+ZXZ0Y2huX21hc2tbMF0p
OworfQorCitzdGF0aWMgdm9pZCB1bm1hc2tfZXZ0Y2huKGludCBwb3J0KQoreworCXN0cnVjdCBz
aGFyZWRfaW5mbyAqcyA9IEhZUEVSVklTT1Jfc2hhcmVkX2luZm87CisJdW5zaWduZWQgaW50IGNw
dSA9IGdldF9jcHUoKTsKKworCUJVR19PTighaXJxc19kaXNhYmxlZCgpKTsKKworCS8qIFNsb3cg
cGF0aCAoaHlwZXJjYWxsKSBpZiB0aGlzIGlzIGEgbm9uLWxvY2FsIHBvcnQuICovCisJaWYgKHVu
bGlrZWx5KGNwdSAhPSBjcHVfZnJvbV9ldnRjaG4ocG9ydCkpKSB7CisJCXN0cnVjdCBldnRjaG5f
dW5tYXNrIHVubWFzayA9IHsgLnBvcnQgPSBwb3J0IH07CisJCSh2b2lkKUhZUEVSVklTT1JfZXZl
bnRfY2hhbm5lbF9vcChFVlRDSE5PUF91bm1hc2ssICZ1bm1hc2spOworCX0gZWxzZSB7CisJCXN0
cnVjdCB2Y3B1X2luZm8gKnZjcHVfaW5mbyA9IF9fZ2V0X2NwdV92YXIoeGVuX3ZjcHUpOworCisJ
CXN5bmNfY2xlYXJfYml0KHBvcnQsICZzLT5ldnRjaG5fbWFza1swXSk7CisKKwkJLyoKKwkJICog
VGhlIGZvbGxvd2luZyBpcyBiYXNpY2FsbHkgdGhlIGVxdWl2YWxlbnQgb2YKKwkJICogJ2h3X3Jl
c2VuZF9pcnEnLiBKdXN0IGxpa2UgYSByZWFsIElPLUFQSUMgd2UgJ2xvc2UKKwkJICogdGhlIGlu
dGVycnVwdCBlZGdlJyBpZiB0aGUgY2hhbm5lbCBpcyBtYXNrZWQuCisJCSAqLworCQlpZiAoc3lu
Y190ZXN0X2JpdChwb3J0LCAmcy0+ZXZ0Y2huX3BlbmRpbmdbMF0pICYmCisJCSAgICAhc3luY190
ZXN0X2FuZF9zZXRfYml0KHBvcnQgLyBCSVRTX1BFUl9MT05HLAorCQkJCQkgICAmdmNwdV9pbmZv
LT5ldnRjaG5fcGVuZGluZ19zZWwpKQorCQkJdmNwdV9pbmZvLT5ldnRjaG5fdXBjYWxsX3BlbmRp
bmcgPSAxOworCX0KKworCXB1dF9jcHUoKTsKK30KKworc3RhdGljIGludCBmaW5kX3VuYm91bmRf
aXJxKHZvaWQpCit7CisJaW50IGlycTsKKworCS8qIE9ubHkgYWxsb2NhdGUgZnJvbSBkeW5pcnEg
cmFuZ2UgKi8KKwlmb3IgKGlycSA9IDA7IGlycSA8IE5SX0lSUVM7IGlycSsrKQorCQlpZiAoaXJx
X2JpbmRjb3VudFtpcnFdID09IDApCisJCQlicmVhazsKKworCWlmIChpcnEgPT0gTlJfSVJRUykK
KwkJcGFuaWMoIk5vIGF2YWlsYWJsZSBJUlEgdG8gYmluZCB0bzogaW5jcmVhc2UgTlJfSVJRUyFc
biIpOworCisJcmV0dXJuIGlycTsKK30KKworaW50IGJpbmRfZXZ0Y2huX3RvX2lycSh1bnNpZ25l
ZCBpbnQgZXZ0Y2huKQoreworCWludCBpcnE7CisKKwlzcGluX2xvY2soJmlycV9tYXBwaW5nX3Vw
ZGF0ZV9sb2NrKTsKKworCWlycSA9IGV2dGNobl90b19pcnFbZXZ0Y2huXTsKKworCWlmIChpcnEg
PT0gLTEpIHsKKwkJaXJxID0gZmluZF91bmJvdW5kX2lycSgpOworCisJCWR5bmFtaWNfaXJxX2lu
aXQoaXJxKTsKKwkJc2V0X2lycV9jaGlwX2FuZF9oYW5kbGVyX25hbWUoaXJxLCAmeGVuX2R5bmFt
aWNfY2hpcCwKKwkJCQkJICAgICAgaGFuZGxlX2xldmVsX2lycSwgImV2ZW50Iik7CisKKwkJZXZ0
Y2huX3RvX2lycVtldnRjaG5dID0gaXJxOworCQlpcnFfaW5mb1tpcnFdID0gbWtfaXJxX2luZm8o
SVJRVF9FVlRDSE4sIDAsIGV2dGNobik7CisJfQorCisJaXJxX2JpbmRjb3VudFtpcnFdKys7CisK
KwlzcGluX3VubG9jaygmaXJxX21hcHBpbmdfdXBkYXRlX2xvY2spOworCisJcmV0dXJuIGlycTsK
K30KK0VYUE9SVF9TWU1CT0xfR1BMKGJpbmRfZXZ0Y2huX3RvX2lycSk7CisKK3N0YXRpYyBpbnQg
YmluZF9pcGlfdG9faXJxKHVuc2lnbmVkIGludCBpcGksIHVuc2lnbmVkIGludCBjcHUpCit7CisJ
c3RydWN0IGV2dGNobl9iaW5kX2lwaSBiaW5kX2lwaTsKKwlpbnQgZXZ0Y2huLCBpcnE7CisKKwlz
cGluX2xvY2soJmlycV9tYXBwaW5nX3VwZGF0ZV9sb2NrKTsKKworCWlycSA9IHBlcl9jcHUoaXBp
X3RvX2lycSwgY3B1KVtpcGldOworCWlmIChpcnEgPT0gLTEpIHsKKwkJaXJxID0gZmluZF91bmJv
dW5kX2lycSgpOworCQlpZiAoaXJxIDwgMCkKKwkJCWdvdG8gb3V0OworCisJCWR5bmFtaWNfaXJx
X2luaXQoaXJxKTsKKwkJc2V0X2lycV9jaGlwX2FuZF9oYW5kbGVyX25hbWUoaXJxLCAmeGVuX2R5
bmFtaWNfY2hpcCwKKwkJCQkJICAgICAgaGFuZGxlX2xldmVsX2lycSwgImlwaSIpOworCisJCWJp
bmRfaXBpLnZjcHUgPSBjcHU7CisJCWlmIChIWVBFUlZJU09SX2V2ZW50X2NoYW5uZWxfb3AoRVZU
Q0hOT1BfYmluZF9pcGksCisJCQkJCQkmYmluZF9pcGkpICE9IDApCisJCQlCVUcoKTsKKwkJZXZ0
Y2huID0gYmluZF9pcGkucG9ydDsKKworCQlldnRjaG5fdG9faXJxW2V2dGNobl0gPSBpcnE7CisJ
CWlycV9pbmZvW2lycV0gPSBta19pcnFfaW5mbyhJUlFUX0lQSSwgaXBpLCBldnRjaG4pOworCisJ
CXBlcl9jcHUoaXBpX3RvX2lycSwgY3B1KVtpcGldID0gaXJxOworCisJCWJpbmRfZXZ0Y2huX3Rv
X2NwdShldnRjaG4sIGNwdSk7CisJfQorCisJaXJxX2JpbmRjb3VudFtpcnFdKys7CisKKyBvdXQ6
CisJc3Bpbl91bmxvY2soJmlycV9tYXBwaW5nX3VwZGF0ZV9sb2NrKTsKKwlyZXR1cm4gaXJxOwor
fQorCisKK3N0YXRpYyBpbnQgYmluZF92aXJxX3RvX2lycSh1bnNpZ25lZCBpbnQgdmlycSwgdW5z
aWduZWQgaW50IGNwdSkKK3sKKwlzdHJ1Y3QgZXZ0Y2huX2JpbmRfdmlycSBiaW5kX3ZpcnE7CisJ
aW50IGV2dGNobiwgaXJxOworCisJc3Bpbl9sb2NrKCZpcnFfbWFwcGluZ191cGRhdGVfbG9jayk7
CisKKwlpcnEgPSBwZXJfY3B1KHZpcnFfdG9faXJxLCBjcHUpW3ZpcnFdOworCisJaWYgKGlycSA9
PSAtMSkgeworCQliaW5kX3ZpcnEudmlycSA9IHZpcnE7CisJCWJpbmRfdmlycS52Y3B1ID0gY3B1
OworCQlpZiAoSFlQRVJWSVNPUl9ldmVudF9jaGFubmVsX29wKEVWVENITk9QX2JpbmRfdmlycSwK
KwkJCQkJCSZiaW5kX3ZpcnEpICE9IDApCisJCQlCVUcoKTsKKwkJZXZ0Y2huID0gYmluZF92aXJx
LnBvcnQ7CisKKwkJaXJxID0gZmluZF91bmJvdW5kX2lycSgpOworCisJCWR5bmFtaWNfaXJxX2lu
aXQoaXJxKTsKKwkJc2V0X2lycV9jaGlwX2FuZF9oYW5kbGVyX25hbWUoaXJxLCAmeGVuX2R5bmFt
aWNfY2hpcCwKKwkJCQkJICAgICAgaGFuZGxlX2xldmVsX2lycSwgInZpcnEiKTsKKworCQlldnRj
aG5fdG9faXJxW2V2dGNobl0gPSBpcnE7CisJCWlycV9pbmZvW2lycV0gPSBta19pcnFfaW5mbyhJ
UlFUX1ZJUlEsIHZpcnEsIGV2dGNobik7CisKKwkJcGVyX2NwdSh2aXJxX3RvX2lycSwgY3B1KVt2
aXJxXSA9IGlycTsKKworCQliaW5kX2V2dGNobl90b19jcHUoZXZ0Y2huLCBjcHUpOworCX0KKwor
CWlycV9iaW5kY291bnRbaXJxXSsrOworCisJc3Bpbl91bmxvY2soJmlycV9tYXBwaW5nX3VwZGF0
ZV9sb2NrKTsKKworCXJldHVybiBpcnE7Cit9CisKK3N0YXRpYyB2b2lkIHVuYmluZF9mcm9tX2ly
cSh1bnNpZ25lZCBpbnQgaXJxKQoreworCXN0cnVjdCBldnRjaG5fY2xvc2UgY2xvc2U7CisJaW50
IGV2dGNobiA9IGV2dGNobl9mcm9tX2lycShpcnEpOworCisJc3Bpbl9sb2NrKCZpcnFfbWFwcGlu
Z191cGRhdGVfbG9jayk7CisKKwlpZiAoVkFMSURfRVZUQ0hOKGV2dGNobikgJiYgKC0taXJxX2Jp
bmRjb3VudFtpcnFdID09IDApKSB7CisJCWNsb3NlLnBvcnQgPSBldnRjaG47CisJCWlmIChIWVBF
UlZJU09SX2V2ZW50X2NoYW5uZWxfb3AoRVZUQ0hOT1BfY2xvc2UsICZjbG9zZSkgIT0gMCkKKwkJ
CUJVRygpOworCisJCXN3aXRjaCAodHlwZV9mcm9tX2lycShpcnEpKSB7CisJCWNhc2UgSVJRVF9W
SVJROgorCQkJcGVyX2NwdSh2aXJxX3RvX2lycSwgY3B1X2Zyb21fZXZ0Y2huKGV2dGNobikpCisJ
CQkJW2luZGV4X2Zyb21faXJxKGlycSldID0gLTE7CisJCQlicmVhazsKKwkJZGVmYXVsdDoKKwkJ
CWJyZWFrOworCQl9CisKKwkJLyogQ2xvc2VkIHBvcnRzIGFyZSBpbXBsaWNpdGx5IHJlLWJvdW5k
IHRvIFZDUFUwLiAqLworCQliaW5kX2V2dGNobl90b19jcHUoZXZ0Y2huLCAwKTsKKworCQlldnRj
aG5fdG9faXJxW2V2dGNobl0gPSAtMTsKKwkJaXJxX2luZm9baXJxXSA9IElSUV9VTkJPVU5EOwor
CisJCWR5bmFtaWNfaXJxX2luaXQoaXJxKTsKKwl9CisKKwlzcGluX3VubG9jaygmaXJxX21hcHBp
bmdfdXBkYXRlX2xvY2spOworfQorCitpbnQgYmluZF9ldnRjaG5fdG9faXJxaGFuZGxlcih1bnNp
Z25lZCBpbnQgZXZ0Y2huLAorCQkJICAgICAgaXJxX2hhbmRsZXJfdCBoYW5kbGVyLAorCQkJICAg
ICAgdW5zaWduZWQgbG9uZyBpcnFmbGFncywKKwkJCSAgICAgIGNvbnN0IGNoYXIgKmRldm5hbWUs
IHZvaWQgKmRldl9pZCkKK3sKKwl1bnNpZ25lZCBpbnQgaXJxOworCWludCByZXR2YWw7CisKKwlp
cnEgPSBiaW5kX2V2dGNobl90b19pcnEoZXZ0Y2huKTsKKwlyZXR2YWwgPSByZXF1ZXN0X2lycShp
cnEsIGhhbmRsZXIsIGlycWZsYWdzLCBkZXZuYW1lLCBkZXZfaWQpOworCWlmIChyZXR2YWwgIT0g
MCkgeworCQl1bmJpbmRfZnJvbV9pcnEoaXJxKTsKKwkJcmV0dXJuIHJldHZhbDsKKwl9CisKKwly
ZXR1cm4gaXJxOworfQorRVhQT1JUX1NZTUJPTF9HUEwoYmluZF9ldnRjaG5fdG9faXJxaGFuZGxl
cik7CisKK2ludCBiaW5kX3ZpcnFfdG9faXJxaGFuZGxlcih1bnNpZ25lZCBpbnQgdmlycSwgdW5z
aWduZWQgaW50IGNwdSwKKwkJCSAgICBpcnFfaGFuZGxlcl90IGhhbmRsZXIsCisJCQkgICAgdW5z
aWduZWQgbG9uZyBpcnFmbGFncywgY29uc3QgY2hhciAqZGV2bmFtZSwgdm9pZCAqZGV2X2lkKQor
eworCXVuc2lnbmVkIGludCBpcnE7CisJaW50IHJldHZhbDsKKworCWlycSA9IGJpbmRfdmlycV90
b19pcnEodmlycSwgY3B1KTsKKwlyZXR2YWwgPSByZXF1ZXN0X2lycShpcnEsIGhhbmRsZXIsIGly
cWZsYWdzLCBkZXZuYW1lLCBkZXZfaWQpOworCWlmIChyZXR2YWwgIT0gMCkgeworCQl1bmJpbmRf
ZnJvbV9pcnEoaXJxKTsKKwkJcmV0dXJuIHJldHZhbDsKKwl9CisKKwlyZXR1cm4gaXJxOworfQor
RVhQT1JUX1NZTUJPTF9HUEwoYmluZF92aXJxX3RvX2lycWhhbmRsZXIpOworCitpbnQgYmluZF9p
cGlfdG9faXJxaGFuZGxlcihlbnVtIGlwaV92ZWN0b3IgaXBpLAorCQkJICAgdW5zaWduZWQgaW50
IGNwdSwKKwkJCSAgIGlycV9oYW5kbGVyX3QgaGFuZGxlciwKKwkJCSAgIHVuc2lnbmVkIGxvbmcg
aXJxZmxhZ3MsCisJCQkgICBjb25zdCBjaGFyICpkZXZuYW1lLAorCQkJICAgdm9pZCAqZGV2X2lk
KQoreworCWludCBpcnEsIHJldHZhbDsKKworCWlycSA9IGJpbmRfaXBpX3RvX2lycShpcGksIGNw
dSk7CisJaWYgKGlycSA8IDApCisJCXJldHVybiBpcnE7CisKKwlyZXR2YWwgPSByZXF1ZXN0X2ly
cShpcnEsIGhhbmRsZXIsIGlycWZsYWdzLCBkZXZuYW1lLCBkZXZfaWQpOworCWlmIChyZXR2YWwg
IT0gMCkgeworCQl1bmJpbmRfZnJvbV9pcnEoaXJxKTsKKwkJcmV0dXJuIHJldHZhbDsKKwl9CisK
KwlyZXR1cm4gaXJxOworfQorCit2b2lkIHVuYmluZF9mcm9tX2lycWhhbmRsZXIodW5zaWduZWQg
aW50IGlycSwgdm9pZCAqZGV2X2lkKQoreworCWZyZWVfaXJxKGlycSwgZGV2X2lkKTsKKwl1bmJp
bmRfZnJvbV9pcnEoaXJxKTsKK30KK0VYUE9SVF9TWU1CT0xfR1BMKHVuYmluZF9mcm9tX2lycWhh
bmRsZXIpOworCit2b2lkIHhlbl9zZW5kX0lQSV9vbmUodW5zaWduZWQgaW50IGNwdSwgZW51bSBp
cGlfdmVjdG9yIHZlY3RvcikKK3sKKwlpbnQgaXJxID0gcGVyX2NwdShpcGlfdG9faXJxLCBjcHUp
W3ZlY3Rvcl07CisJQlVHX09OKGlycSA8IDApOworCW5vdGlmeV9yZW1vdGVfdmlhX2lycShpcnEp
OworfQorCisKKy8qCisgKiBTZWFyY2ggdGhlIENQVXMgcGVuZGluZyBldmVudHMgYml0bWFza3Mu
ICBGb3IgZWFjaCBvbmUgZm91bmQsIG1hcAorICogdGhlIGV2ZW50IG51bWJlciB0byBhbiBpcnEs
IGFuZCBmZWVkIGl0IGludG8gZG9fSVJRKCkgZm9yCisgKiBoYW5kbGluZy4KKyAqCisgKiBYZW4g
dXNlcyBhIHR3by1sZXZlbCBiaXRtYXAgdG8gc3BlZWQgc2VhcmNoaW5nLiAgVGhlIGZpcnN0IGxl
dmVsIGlzCisgKiBhIGJpdHNldCBvZiB3b3JkcyB3aGljaCBjb250YWluIHBlbmRpbmcgZXZlbnQg
Yml0cy4gIFRoZSBzZWNvbmQKKyAqIGxldmVsIGlzIGEgYml0c2V0IG9mIHBlbmRpbmcgZXZlbnRz
IHRoZW1zZWx2ZXMuCisgKi8KK3ZvaWQgeGVuX2V2dGNobl9kb191cGNhbGwoc3RydWN0IHB0X3Jl
Z3MgKnJlZ3MpCit7CisJaW50IGNwdSA9IGdldF9jcHUoKTsKKwlzdHJ1Y3Qgc2hhcmVkX2luZm8g
KnMgPSBIWVBFUlZJU09SX3NoYXJlZF9pbmZvOworCXN0cnVjdCB2Y3B1X2luZm8gKnZjcHVfaW5m
byA9IF9fZ2V0X2NwdV92YXIoeGVuX3ZjcHUpOworCXVuc2lnbmVkIGxvbmcgcGVuZGluZ193b3Jk
czsKKworCXZjcHVfaW5mby0+ZXZ0Y2huX3VwY2FsbF9wZW5kaW5nID0gMDsKKworCS8qIE5CLiBO
byBuZWVkIGZvciBhIGJhcnJpZXIgaGVyZSAtLSBYQ0hHIGlzIGEgYmFycmllciBvbiB4ODYuICov
CisJcGVuZGluZ193b3JkcyA9IHhjaGcoJnZjcHVfaW5mby0+ZXZ0Y2huX3BlbmRpbmdfc2VsLCAw
KTsKKwl3aGlsZSAocGVuZGluZ193b3JkcyAhPSAwKSB7CisJCXVuc2lnbmVkIGxvbmcgcGVuZGlu
Z19iaXRzOworCQlpbnQgd29yZF9pZHggPSBfX2ZmcyhwZW5kaW5nX3dvcmRzKTsKKwkJcGVuZGlu
Z193b3JkcyAmPSB+KDFVTCA8PCB3b3JkX2lkeCk7CisKKwkJd2hpbGUgKChwZW5kaW5nX2JpdHMg
PSBhY3RpdmVfZXZ0Y2hucyhjcHUsIHMsIHdvcmRfaWR4KSkgIT0gMCkgeworCQkJaW50IGJpdF9p
ZHggPSBfX2ZmcyhwZW5kaW5nX2JpdHMpOworCQkJaW50IHBvcnQgPSAod29yZF9pZHggKiBCSVRT
X1BFUl9MT05HKSArIGJpdF9pZHg7CisJCQlpbnQgaXJxID0gZXZ0Y2huX3RvX2lycVtwb3J0XTsK
KworCQkJaWYgKGlycSAhPSAtMSkgeworCQkJCXJlZ3MtPm9yaWdfYXggPSB+aXJxOworCQkJCWRv
X0lSUShyZWdzKTsKKwkJCX0KKwkJfQorCX0KKworCXB1dF9jcHUoKTsKK30KKworLyogUmViaW5k
IGFuIGV2dGNobiBzbyB0aGF0IGl0IGdldHMgZGVsaXZlcmVkIHRvIGEgc3BlY2lmaWMgY3B1ICov
CitzdGF0aWMgdm9pZCByZWJpbmRfaXJxX3RvX2NwdSh1bnNpZ25lZCBpcnEsIHVuc2lnbmVkIHRj
cHUpCit7CisJc3RydWN0IGV2dGNobl9iaW5kX3ZjcHUgYmluZF92Y3B1OworCWludCBldnRjaG4g
PSBldnRjaG5fZnJvbV9pcnEoaXJxKTsKKworCWlmICghVkFMSURfRVZUQ0hOKGV2dGNobikpCisJ
CXJldHVybjsKKworCS8qIFNlbmQgZnV0dXJlIGluc3RhbmNlcyBvZiB0aGlzIGludGVycnVwdCB0
byBvdGhlciB2Y3B1LiAqLworCWJpbmRfdmNwdS5wb3J0ID0gZXZ0Y2huOworCWJpbmRfdmNwdS52
Y3B1ID0gdGNwdTsKKworCS8qCisJICogSWYgdGhpcyBmYWlscywgaXQgdXN1YWxseSBqdXN0IGlu
ZGljYXRlcyB0aGF0IHdlJ3JlIGRlYWxpbmcgd2l0aCBhCisJICogdmlycSBvciBJUEkgY2hhbm5l
bCwgd2hpY2ggZG9uJ3QgYWN0dWFsbHkgbmVlZCB0byBiZSByZWJvdW5kLiBJZ25vcmUKKwkgKiBp
dCwgYnV0IGRvbid0IGRvIHRoZSB4ZW5saW51eC1sZXZlbCByZWJpbmQgaW4gdGhhdCBjYXNlLgor
CSAqLworCWlmIChIWVBFUlZJU09SX2V2ZW50X2NoYW5uZWxfb3AoRVZUQ0hOT1BfYmluZF92Y3B1
LCAmYmluZF92Y3B1KSA+PSAwKQorCQliaW5kX2V2dGNobl90b19jcHUoZXZ0Y2huLCB0Y3B1KTsK
K30KKworCitzdGF0aWMgdm9pZCBzZXRfYWZmaW5pdHlfaXJxKHVuc2lnbmVkIGlycSwgY3B1bWFz
a190IGRlc3QpCit7CisJdW5zaWduZWQgdGNwdSA9IGZpcnN0X2NwdShkZXN0KTsKKwlyZWJpbmRf
aXJxX3RvX2NwdShpcnEsIHRjcHUpOworfQorCitzdGF0aWMgdm9pZCBlbmFibGVfZHluaXJxKHVu
c2lnbmVkIGludCBpcnEpCit7CisJaW50IGV2dGNobiA9IGV2dGNobl9mcm9tX2lycShpcnEpOwor
CisJaWYgKFZBTElEX0VWVENITihldnRjaG4pKQorCQl1bm1hc2tfZXZ0Y2huKGV2dGNobik7Cit9
CisKK3N0YXRpYyB2b2lkIGRpc2FibGVfZHluaXJxKHVuc2lnbmVkIGludCBpcnEpCit7CisJaW50
IGV2dGNobiA9IGV2dGNobl9mcm9tX2lycShpcnEpOworCisJaWYgKFZBTElEX0VWVENITihldnRj
aG4pKQorCQltYXNrX2V2dGNobihldnRjaG4pOworfQorCitzdGF0aWMgdm9pZCBhY2tfZHluaXJx
KHVuc2lnbmVkIGludCBpcnEpCit7CisJaW50IGV2dGNobiA9IGV2dGNobl9mcm9tX2lycShpcnEp
OworCisJbW92ZV9uYXRpdmVfaXJxKGlycSk7CisKKwlpZiAoVkFMSURfRVZUQ0hOKGV2dGNobikp
CisJCWNsZWFyX2V2dGNobihldnRjaG4pOworfQorCitzdGF0aWMgaW50IHJldHJpZ2dlcl9keW5p
cnEodW5zaWduZWQgaW50IGlycSkKK3sKKwlpbnQgZXZ0Y2huID0gZXZ0Y2huX2Zyb21faXJxKGly
cSk7CisJaW50IHJldCA9IDA7CisKKwlpZiAoVkFMSURfRVZUQ0hOKGV2dGNobikpIHsKKwkJc2V0
X2V2dGNobihldnRjaG4pOworCQlyZXQgPSAxOworCX0KKworCXJldHVybiByZXQ7Cit9CisKK3N0
YXRpYyBzdHJ1Y3QgaXJxX2NoaXAgeGVuX2R5bmFtaWNfY2hpcCBfX3JlYWRfbW9zdGx5ID0gewor
CS5uYW1lCQk9ICJ4ZW4tZHluIiwKKwkubWFzawkJPSBkaXNhYmxlX2R5bmlycSwKKwkudW5tYXNr
CQk9IGVuYWJsZV9keW5pcnEsCisJLmFjawkJPSBhY2tfZHluaXJxLAorCS5zZXRfYWZmaW5pdHkJ
PSBzZXRfYWZmaW5pdHlfaXJxLAorCS5yZXRyaWdnZXIJPSByZXRyaWdnZXJfZHluaXJxLAorfTsK
Kwordm9pZCBfX2luaXQgeGVuX2luaXRfSVJRKHZvaWQpCit7CisJaW50IGk7CisKKwlpbml0X2V2
dGNobl9jcHVfYmluZGluZ3MoKTsKKworCS8qIE5vIGV2ZW50IGNoYW5uZWxzIGFyZSAnbGl2ZScg
cmlnaHQgbm93LiAqLworCWZvciAoaSA9IDA7IGkgPCBOUl9FVkVOVF9DSEFOTkVMUzsgaSsrKQor
CQltYXNrX2V2dGNobihpKTsKKworCS8qIER5bmFtaWMgSVJRIHNwYWNlIGlzIGN1cnJlbnRseSB1
bmJvdW5kLiBaZXJvIHRoZSByZWZjbnRzLiAqLworCWZvciAoaSA9IDA7IGkgPCBOUl9JUlFTOyBp
KyspCisJCWlycV9iaW5kY291bnRbaV0gPSAwOworCisJaXJxX2N0eF9pbml0KHNtcF9wcm9jZXNz
b3JfaWQoKSk7Cit9CmRpZmYgLXVyTiBvbGQvZHJpdmVycy94ZW4vTWFrZWZpbGUgbGludXgvZHJp
dmVycy94ZW4vTWFrZWZpbGUKLS0tIG9sZC9kcml2ZXJzL3hlbi9NYWtlZmlsZQkyMDA4LTAzLTEw
IDEzOjIyOjI3LjAwMDAwMDAwMCArMDgwMAorKysgbGludXgvZHJpdmVycy94ZW4vTWFrZWZpbGUJ
MjAwOC0wMy0yNSAxMzo1Njo0MS4zNjg3NjQyODcgKzA4MDAKQEAgLTEsMiArMSwyIEBACi1vYmot
eQkrPSBncmFudC10YWJsZS5vCitvYmoteQkrPSBncmFudC10YWJsZS5vIGV2ZW50cy5vCiBvYmot
eQkrPSB4ZW5idXMvCmRpZmYgLXVyTiBvbGQvaW5jbHVkZS94ZW4veGVuLW9wcy5oIGxpbnV4L2lu
Y2x1ZGUveGVuL3hlbi1vcHMuaAotLS0gb2xkL2luY2x1ZGUveGVuL3hlbi1vcHMuaAkxOTcwLTAx
LTAxIDA4OjAwOjAwLjAwMDAwMDAwMCArMDgwMAorKysgbGludXgvaW5jbHVkZS94ZW4veGVuLW9w
cy5oCTIwMDgtMDMtMjUgMTQ6MDA6MDkuMDQxMzIxNTQ2ICswODAwCkBAIC0wLDAgKzEsNiBAQAor
I2lmbmRlZiBJTkNMVURFX1hFTl9PUFNfSAorI2RlZmluZSBJTkNMVURFX1hFTl9PUFNfSAorCitE
RUNMQVJFX1BFUl9DUFUoc3RydWN0IHZjcHVfaW5mbyAqLCB4ZW5fdmNwdSk7CisKKyNlbmRpZiAv
KiBJTkNMVURFX1hFTl9PUFNfSCAqLwo=

------_=_NextPart_001_01C88E3F.619D5D07--
