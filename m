From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 05 Mar 2008 18:19:05 +0000
Subject: [PATCH 50/50] ia64/pv_ops/xen: define xen pv_irq_ops.
Message-Id: <12047411473158-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/xen/Makefile     |    2 +-
 arch/ia64/xen/hypercall.S  |   10 +
 arch/ia64/xen/irq_xen.c    |  435 ++++++++++++++++++++++++++++++++++++++++++++
 arch/ia64/xen/irq_xen.h    |    8 +
 arch/ia64/xen/xen_pv_ops.c |    3 +
 include/asm-ia64/hw_irq.h  |    4 +
 include/asm-ia64/irq.h     |   33 ++++
 7 files changed, 494 insertions(+), 1 deletions(-)
 create mode 100644 arch/ia64/xen/irq_xen.c
 create mode 100644 arch/ia64/xen/irq_xen.h

diff --git a/arch/ia64/xen/Makefile b/arch/ia64/xen/Makefile
index 4b1db56..ff7a58d 100644
--- a/arch/ia64/xen/Makefile
+++ b/arch/ia64/xen/Makefile
@@ -2,7 +2,7 @@
 # Makefile for Xen components
 #
 
-obj-y := xen_pv_ops.o
+obj-y := xen_pv_ops.o irq_xen.o 
 
 obj-$(CONFIG_PARAVIRT_ALT) += paravirt_xen.o privops_asm.o privops_c.o
 obj-$(CONFIG_PARAVIRT_NOP_B_PATCH) += paravirt_xen.o
diff --git a/arch/ia64/xen/hypercall.S b/arch/ia64/xen/hypercall.S
index 7c5242b..3fad2fe 100644
--- a/arch/ia64/xen/hypercall.S
+++ b/arch/ia64/xen/hypercall.S
@@ -123,6 +123,16 @@ END(xen_set_eflag)
 #endif /* CONFIG_IA32_SUPPORT */
 #endif /* ASM_SUPPORTED */
 
+GLOBAL_ENTRY(xen_send_ipi)
+	mov r14=r32
+	mov r15=r33
+	mov r2=0x400
+	break 0x1000
+	;;
+	br.ret.sptk.many rp
+	;;
+END(xen_send_ipi)
+
 GLOBAL_ENTRY(__hypercall)
 	mov r2=r37
 	break 0x1000
diff --git a/arch/ia64/xen/irq_xen.c b/arch/ia64/xen/irq_xen.c
new file mode 100644
index 0000000..57fab2b
--- /dev/null
+++ b/arch/ia64/xen/irq_xen.c
@@ -0,0 +1,435 @@
+/******************************************************************************
+ * arch/ia64/xen/irq_xen.c
+ *
+ * Copyright (c) 2006 Isaku Yamahata <yamahata at valinux co jp>
+ *                    VA Linux Systems Japan K.K.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#include <linux/cpu.h>
+
+#include <xen/events.h>
+#include <xen/interface/callback.h>
+
+#include "irq_xen.h"
+
+/***************************************************************************
+ * pv_irq_ops
+ * irq operations
+ */
+
+static int
+xen_assign_irq_vector(int irq)
+{
+	struct physdev_irq irq_op;
+
+	irq_op.irq = irq;
+	if (HYPERVISOR_physdev_op(PHYSDEVOP_alloc_irq_vector, &irq_op))
+		return -ENOSPC;
+
+	return irq_op.vector;
+}
+
+static void
+xen_free_irq_vector(int vector)
+{
+	struct physdev_irq irq_op;
+
+	if (vector < IA64_FIRST_DEVICE_VECTOR ||
+	    vector > IA64_LAST_DEVICE_VECTOR)
+		return;
+
+	irq_op.vector = vector;
+	if (HYPERVISOR_physdev_op(PHYSDEVOP_free_irq_vector, &irq_op))
+		printk(KERN_WARNING "%s: xen_free_irq_vecotr fail vector=%d\n",
+		       __func__, vector);
+}
+
+
+static DEFINE_PER_CPU(int, timer_irq) = -1;
+static DEFINE_PER_CPU(int, ipi_irq) = -1;
+static DEFINE_PER_CPU(int, resched_irq) = -1;
+static DEFINE_PER_CPU(int, cmc_irq) = -1;
+static DEFINE_PER_CPU(int, cmcp_irq) = -1;
+static DEFINE_PER_CPU(int, cpep_irq) = -1;
+#define NAME_SIZE	15
+static DEFINE_PER_CPU(char[NAME_SIZE], timer_name);
+static DEFINE_PER_CPU(char[NAME_SIZE], ipi_name);
+static DEFINE_PER_CPU(char[NAME_SIZE], resched_name);
+static DEFINE_PER_CPU(char[NAME_SIZE], cmc_name);
+static DEFINE_PER_CPU(char[NAME_SIZE], cmcp_name);
+static DEFINE_PER_CPU(char[NAME_SIZE], cpep_name);
+#undef NAME_SIZE
+
+struct saved_irq {
+	unsigned int irq;
+	struct irqaction *action;
+};
+/* 16 should be far optimistic value, since only several percpu irqs
+ * are registered early.
+ */
+#define MAX_LATE_IRQ	16
+static struct saved_irq saved_percpu_irqs[MAX_LATE_IRQ];
+static unsigned short late_irq_cnt = 0;
+static unsigned short saved_irq_cnt = 0;
+static int xen_slab_ready = 0;
+
+#ifdef CONFIG_SMP
+/* Dummy stub. Though we may check RESCHEDULE_VECTOR before __do_IRQ,
+ * it ends up to issue several memory accesses upon percpu data and
+ * thus adds unnecessary traffic to other paths.
+ */
+static irqreturn_t
+xen_dummy_handler(int irq, void *dev_id)
+{
+
+	return IRQ_HANDLED;
+}
+
+static struct irqaction xen_resched_irqaction = {
+	.handler =	xen_dummy_handler,
+	.flags =	IRQF_DISABLED,
+	.name =		"resched"
+};
+
+static struct irqaction xen_tlb_irqaction = {
+	.handler =	xen_dummy_handler,
+	.flags =	IRQF_DISABLED,
+	.name =		"tlb_flush"
+};
+#endif
+
+/*
+ * This is xen version percpu irq registration, which needs bind
+ * to xen specific evtchn sub-system. One trick here is that xen
+ * evtchn binding interface depends on kmalloc because related
+ * port needs to be freed at device/cpu down. So we cache the
+ * registration on BSP before slab is ready and then deal them
+ * at later point. For rest instances happening after slab ready,
+ * we hook them to xen evtchn immediately.
+ *
+ * FIXME: MCA is not supported by far, and thus "nomca" boot param is
+ * required.
+ */
+static void
+__xen_register_percpu_irq(unsigned int cpu, unsigned int vec,
+			struct irqaction *action, int save)
+{
+	irq_desc_t *desc;
+	int irq = 0;
+
+	if (xen_slab_ready) {
+		switch (vec) {
+		case IA64_TIMER_VECTOR:
+			snprintf(per_cpu(timer_name, cpu),
+				 sizeof(per_cpu(timer_name, cpu)),
+				 "%s%d", action->name, cpu);
+			irq = bind_virq_to_irqhandler(VIRQ_ITC, cpu,
+				action->handler, action->flags,
+				per_cpu(timer_name, cpu), action->dev_id);
+			per_cpu(timer_irq, cpu) = irq;
+			break;
+		case IA64_IPI_RESCHEDULE:
+			snprintf(per_cpu(resched_name, cpu),
+				 sizeof(per_cpu(resched_name, cpu)),
+				 "%s%d", action->name, cpu);
+			irq = bind_ipi_to_irqhandler(RESCHEDULE_VECTOR, cpu,
+				action->handler, action->flags,
+				per_cpu(resched_name, cpu), action->dev_id);
+			per_cpu(resched_irq, cpu) = irq;
+			break;
+		case IA64_IPI_VECTOR:
+			snprintf(per_cpu(ipi_name, cpu),
+				 sizeof(per_cpu(ipi_name, cpu)),
+				 "%s%d", action->name, cpu);
+			irq = bind_ipi_to_irqhandler(IPI_VECTOR, cpu,
+				action->handler, action->flags,
+				per_cpu(ipi_name, cpu), action->dev_id);
+			per_cpu(ipi_irq, cpu) = irq;
+			break;
+		case IA64_CMC_VECTOR:
+			snprintf(per_cpu(cmc_name, cpu),
+				 sizeof(per_cpu(cmc_name, cpu)),
+				 "%s%d", action->name, cpu);
+			irq = bind_virq_to_irqhandler(VIRQ_MCA_CMC, cpu,
+						      action->handler,
+						      action->flags,
+						      per_cpu(cmc_name, cpu),
+						      action->dev_id);
+			per_cpu(cmc_irq, cpu) = irq;
+			break;
+		case IA64_CMCP_VECTOR:
+			snprintf(per_cpu(cmcp_name, cpu),
+				 sizeof(per_cpu(cmcp_name, cpu)),
+				 "%s%d", action->name, cpu);
+			irq = bind_ipi_to_irqhandler(CMCP_VECTOR, cpu,
+						     action->handler,
+						     action->flags,
+						     per_cpu(cmcp_name, cpu),
+						     action->dev_id);
+			per_cpu(cmcp_irq, cpu) = irq;
+			break;
+		case IA64_CPEP_VECTOR:
+			snprintf(per_cpu(cpep_name, cpu),
+				 sizeof(per_cpu(cpep_name, cpu)),
+				 "%s%d", action->name, cpu);
+			irq = bind_ipi_to_irqhandler(CPEP_VECTOR, cpu,
+						     action->handler,
+						     action->flags,
+						     per_cpu(cpep_name, cpu),
+						     action->dev_id);
+			per_cpu(cpep_irq, cpu) = irq;
+			break;
+		case IA64_CPE_VECTOR:
+		case IA64_MCA_RENDEZ_VECTOR:
+		case IA64_PERFMON_VECTOR:
+		case IA64_MCA_WAKEUP_VECTOR:
+		case IA64_SPURIOUS_INT_VECTOR:
+			/* No need to complain, these aren't supported. */
+			break;
+		default:
+			printk(KERN_WARNING "Percpu irq %d is unsupported "
+			       "by xen!\n", vec);
+			break;
+		}
+		BUG_ON(irq < 0);
+
+		if (irq > 0) {
+			/*
+			 * Mark percpu.  Without this, migrate_irqs() will
+			 * mark the interrupt for migrations and trigger it
+			 * on cpu hotplug.
+			 */
+			desc = irq_desc + irq;
+			desc->status |= IRQ_PER_CPU;
+		}
+	}
+
+	/* For BSP, we cache registered percpu irqs, and then re-walk
+	 * them when initializing APs
+	 */
+	if (!cpu && save) {
+		BUG_ON(saved_irq_cnt = MAX_LATE_IRQ);
+		saved_percpu_irqs[saved_irq_cnt].irq = vec;
+		saved_percpu_irqs[saved_irq_cnt].action = action;
+		saved_irq_cnt++;
+		if (!xen_slab_ready)
+			late_irq_cnt++;
+	}
+}
+
+static void
+xen_register_percpu_irq(ia64_vector vec, struct irqaction *action)
+{
+	__xen_register_percpu_irq(smp_processor_id(), vec, action, 1);
+}
+
+static void
+xen_bind_early_percpu_irq(void)
+{
+	int i;
+
+	xen_slab_ready = 1;
+	/* There's no race when accessing this cached array, since only
+	 * BSP will face with such step shortly
+	 */
+	for (i = 0; i < late_irq_cnt; i++)
+		__xen_register_percpu_irq(smp_processor_id(),
+					  saved_percpu_irqs[i].irq,
+					  saved_percpu_irqs[i].action, 0);
+}
+
+/* FIXME: There's no obvious point to check whether slab is ready. So
+ * a hack is used here by utilizing a late time hook.
+ */
+extern void (*late_time_init)(void);
+extern char xen_event_callback;
+extern void xen_init_IRQ(void);
+
+#ifdef CONFIG_HOTPLUG_CPU
+static int __devinit
+unbind_evtchn_callback(struct notifier_block *nfb,
+		       unsigned long action, void *hcpu)
+{
+	unsigned int cpu = (unsigned long)hcpu;
+
+	if (action = CPU_DEAD) {
+		/* Unregister evtchn.  */
+		if (per_cpu(cpep_irq, cpu) >= 0) {
+			unbind_from_irqhandler(per_cpu(cpep_irq, cpu), NULL);
+			per_cpu(cpep_irq, cpu) = -1;
+		}
+		if (per_cpu(cmcp_irq, cpu) >= 0) {
+			unbind_from_irqhandler(per_cpu(cmcp_irq, cpu), NULL);
+			per_cpu(cmcp_irq, cpu) = -1;
+		}
+		if (per_cpu(cmc_irq, cpu) >= 0) {
+			unbind_from_irqhandler(per_cpu(cmc_irq, cpu), NULL);
+			per_cpu(cmc_irq, cpu) = -1;
+		}
+		if (per_cpu(ipi_irq, cpu) >= 0) {
+			unbind_from_irqhandler(per_cpu(ipi_irq, cpu), NULL);
+			per_cpu(ipi_irq, cpu) = -1;
+		}
+		if (per_cpu(resched_irq, cpu) >= 0) {
+			unbind_from_irqhandler(per_cpu(resched_irq, cpu),
+						NULL);
+			per_cpu(resched_irq, cpu) = -1;
+		}
+		if (per_cpu(timer_irq, cpu) >= 0) {
+			unbind_from_irqhandler(per_cpu(timer_irq, cpu), NULL);
+			per_cpu(timer_irq, cpu) = -1;
+		}
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block unbind_evtchn_notifier = {
+	.notifier_call = unbind_evtchn_callback,
+	.priority = 0
+};
+#endif
+
+DECLARE_PER_CPU(int, ipi_to_irq[NR_IPIS]);
+void xen_smp_intr_init_early(unsigned int cpu)
+{
+#ifdef CONFIG_SMP
+	unsigned int i;
+
+	for (i = 0; i < saved_irq_cnt; i++)
+		__xen_register_percpu_irq(cpu, saved_percpu_irqs[i].irq,
+					  saved_percpu_irqs[i].action, 0);
+#endif
+}
+
+void xen_smp_intr_init(void)
+{
+#ifdef CONFIG_SMP
+	unsigned int cpu = smp_processor_id();
+	struct callback_register event = {
+		.type = CALLBACKTYPE_event,
+		.address = (unsigned long)&xen_event_callback,
+	};
+
+	if (cpu = 0) {
+		/* Initialization was already done for boot cpu.  */
+#ifdef CONFIG_HOTPLUG_CPU
+		/* Register the notifier only once.  */
+		register_cpu_notifier(&unbind_evtchn_notifier);
+#endif
+		return;
+	}
+
+	/* This should be piggyback when setup vcpu guest context */
+	BUG_ON(HYPERVISOR_callback_op(CALLBACKOP_register, &event));
+#endif /* CONFIG_SMP */
+}
+
+void __init
+xen_irq_init(void)
+{
+	struct callback_register event = {
+		.type = CALLBACKTYPE_event,
+		.address = (unsigned long)&xen_event_callback,
+	};
+
+	xen_init_IRQ();
+	BUG_ON(HYPERVISOR_callback_op(CALLBACKOP_register, &event));
+	late_time_init = xen_bind_early_percpu_irq;
+}
+
+void
+xen_platform_send_ipi(int cpu, int vector, int delivery_mode, int redirect)
+{
+	int irq = -1;
+
+#ifdef CONFIG_SMP
+	/* TODO: we need to call vcpu_up here */
+	if (unlikely(vector = ap_wakeup_vector)) {
+		/* XXX
+		 * This should be in __cpu_up(cpu) in ia64 smpboot.c
+		 * like x86. But don't want to modify it,
+		 * keep it untouched.
+		 */
+		xen_smp_intr_init_early(cpu);
+
+		xen_send_ipi(cpu, vector);
+		/* vcpu_prepare_and_up(cpu); */
+		return;
+	}
+#endif
+
+	switch (vector) {
+	case IA64_IPI_VECTOR:
+		irq = per_cpu(ipi_to_irq, cpu)[IPI_VECTOR];
+		break;
+	case IA64_IPI_RESCHEDULE:
+		irq = per_cpu(ipi_to_irq, cpu)[RESCHEDULE_VECTOR];
+		break;
+	case IA64_CMCP_VECTOR:
+		irq = per_cpu(ipi_to_irq, cpu)[CMCP_VECTOR];
+		break;
+	case IA64_CPEP_VECTOR:
+		irq = per_cpu(ipi_to_irq, cpu)[CPEP_VECTOR];
+		break;
+	default:
+		printk(KERN_WARNING "Unsupported IPI type 0x%x\n",
+		       vector);
+		irq = 0;
+		break;
+	}
+
+	BUG_ON(irq < 0);
+	notify_remote_via_irq(irq);
+	return;
+}
+
+static void __init
+xen_init_IRQ_early(void)
+{
+#ifdef CONFIG_SMP
+	register_percpu_irq(IA64_IPI_RESCHEDULE, &xen_resched_irqaction);
+	register_percpu_irq(IA64_IPI_LOCAL_TLB_FLUSH, &xen_tlb_irqaction);
+#endif
+}
+
+static void __init
+xen_init_IRQ_late(void)
+{
+#ifdef CONFIG_XEN_PRIVILEGED_GUEST
+	if (is_running_on_xen() && !ia64_platform_is("xen"))
+		xen_irq_init();
+#endif
+}
+
+static void
+xen_resend_irq(unsigned int vector)
+{
+	(void)resend_irq_on_evtchn(vector);
+}
+
+const struct pv_irq_ops xen_irq_ops __initdata = {
+	.init_IRQ_early = xen_init_IRQ_early,
+	.init_IRQ_late = xen_init_IRQ_late,
+
+	.assign_irq_vector = xen_assign_irq_vector,
+	.free_irq_vector = xen_free_irq_vector,
+	.register_percpu_irq = xen_register_percpu_irq,
+
+	.send_ipi = xen_platform_send_ipi,
+	.resend_irq = xen_resend_irq,
+};
diff --git a/arch/ia64/xen/irq_xen.h b/arch/ia64/xen/irq_xen.h
new file mode 100644
index 0000000..a2c3ed9
--- /dev/null
+++ b/arch/ia64/xen/irq_xen.h
@@ -0,0 +1,8 @@
+#ifndef IRQ_XEN_H
+#define IRQ_XEN_H
+
+extern const struct pv_irq_ops xen_irq_ops __initdata;
+extern void xen_smp_intr_init(void);
+extern void xen_send_ipi(int cpu, int vec);
+
+#endif /* IRQ_XEN_H */
diff --git a/arch/ia64/xen/xen_pv_ops.c b/arch/ia64/xen/xen_pv_ops.c
index c35bb23..93a5c64 100644
--- a/arch/ia64/xen/xen_pv_ops.c
+++ b/arch/ia64/xen/xen_pv_ops.c
@@ -35,6 +35,8 @@
 #include <asm/xen/hypervisor.h>
 #include <asm/xen/xencomm.h>
 
+#include "irq_xen.h"
+
 /***************************************************************************
  * general info
  */
@@ -313,4 +315,5 @@ xen_setup_pv_ops(void)
 	pv_info = xen_info;
 	pv_init_ops = xen_init_ops;
 	pv_iosapic_ops = xen_iosapic_ops;
+	pv_irq_ops = xen_irq_ops;
 }
diff --git a/include/asm-ia64/hw_irq.h b/include/asm-ia64/hw_irq.h
index 678efec..80009cd 100644
--- a/include/asm-ia64/hw_irq.h
+++ b/include/asm-ia64/hw_irq.h
@@ -15,7 +15,11 @@
 #include <asm/ptrace.h>
 #include <asm/smp.h>
 
+#ifndef CONFIG_XEN
 typedef u8 ia64_vector;
+#else
+typedef u16 ia64_vector;
+#endif
 
 /*
  * 0 special
diff --git a/include/asm-ia64/irq.h b/include/asm-ia64/irq.h
index a66d268..aead249 100644
--- a/include/asm-ia64/irq.h
+++ b/include/asm-ia64/irq.h
@@ -14,6 +14,7 @@
 #include <linux/types.h>
 #include <linux/cpumask.h>
 
+#ifndef CONFIG_XEN
 #define NR_VECTORS	256
 
 #if (NR_VECTORS + 32 * NR_CPUS) < 1024
@@ -21,6 +22,38 @@
 #else
 #define NR_IRQS 1024
 #endif
+#else
+/*
+ * The flat IRQ space is divided into two regions:
+ *  1. A one-to-one mapping of real physical IRQs. This space is only used
+ *     if we have physical device-access privilege. This region is at the
+ *     start of the IRQ space so that existing device drivers do not need
+ *     to be modified to translate physical IRQ numbers into our IRQ space.
+ *  3. A dynamic mapping of inter-domain and Xen-sourced virtual IRQs. These
+ *     are bound using the provided bind/unbind functions.
+ */
+
+#define PIRQ_BASE		0
+#define NR_PIRQS		256
+
+#define DYNIRQ_BASE		(PIRQ_BASE + NR_PIRQS)
+#define NR_DYNIRQS		(CONFIG_NR_CPUS * 8)
+
+#define NR_IRQS			(NR_PIRQS + NR_DYNIRQS)
+#define NR_IRQ_VECTORS		NR_IRQS
+
+#define pirq_to_irq(_x)		((_x) + PIRQ_BASE)
+#define irq_to_pirq(_x)		((_x) - PIRQ_BASE)
+
+#define dynirq_to_irq(_x)	((_x) + DYNIRQ_BASE)
+#define irq_to_dynirq(_x)	((_x) - DYNIRQ_BASE)
+
+#define RESCHEDULE_VECTOR	0
+#define IPI_VECTOR		1
+#define CMCP_VECTOR		2
+#define CPEP_VECTOR		3
+#define NR_IPIS			4
+#endif /* CONFIG_XEN */
 
 static __inline__ int
 irq_canonicalize (int irq)
-- 
1.5.3

