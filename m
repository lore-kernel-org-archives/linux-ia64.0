From: Alex Williamson <alex.williamson@hp.com>
Date: Fri, 02 Jun 2006 19:09:14 +0000
Subject: [RFC 1/2] Xen/ia64 modified files
Message-Id: <1149275354.5999.83.camel@lappy>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-mW5fLDhrMg8Cvz4+RS4P"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--=-mW5fLDhrMg8Cvz4+RS4P
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


   This patch includes only the modifications to existing Linux/ia64
files to support both privileged and un-privileged guests on Xen/ia64.

 arch/ia64/Kconfig               |   16 +++
 arch/ia64/Makefile              |   18 +++
 arch/ia64/hp/sim/Makefile       |    2
 arch/ia64/kernel/entry.S        |   32 +++---
 arch/ia64/kernel/head.S         |    6 +
 arch/ia64/kernel/iosapic.c      |   68 +++++++++++++
 arch/ia64/kernel/irq_ia64.c     |  200 ++++++++++++++++++++++++++++++++++++++++
 arch/ia64/kernel/pal.S          |    5 -
 arch/ia64/kernel/setup.c        |   54 ++++++++++
 arch/ia64/mm/ioremap.c          |    3
 include/asm-ia64/agp.h          |   31 ++++++
 include/asm-ia64/dma-mapping.h  |   69 +++++++++++++
 include/asm-ia64/gcc_intrin.h   |   68 +++++++------
 include/asm-ia64/hw_irq.h       |    8 +
 include/asm-ia64/intel_intrin.h |   68 +++++++------
 include/asm-ia64/io.h           |   34 ++++++
 include/asm-ia64/iosapic.h      |    2
 include/asm-ia64/irq.h          |   31 ++++++
 include/asm-ia64/machvec.h      |   15 +++
 include/asm-ia64/meminit.h      |    5 +
 include/asm-ia64/page.h         |  102 ++++++++++++++++++++
 include/asm-ia64/pal.h          |    1
 include/asm-ia64/pgalloc.h      |    2
 include/asm-ia64/processor.h    |    1
 include/asm-ia64/system.h       |    4
 25 files changed, 758 insertions(+), 87 deletions(-)

-- 
Alex Williamson                             HP Open Source & Linux Org.

--=-mW5fLDhrMg8Cvz4+RS4P
Content-Disposition: attachment; filename=xen_ia64_mods.diff
Content-Type: text/x-patch; name=xen_ia64_mods.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -r 016512c08f6b -r 4489a633a5de arch/ia64/Kconfig
--- a/arch/ia64/Kconfig	Thu May 25 03:00:07 2006 +0000
+++ b/arch/ia64/Kconfig	Fri Jun 02 09:54:29 2006 -0600
@@ -57,6 +57,20 @@ config GENERIC_IOMAP
 config GENERIC_IOMAP
 	bool
 	default y
+
+config XEN
+	bool "Xen hypervisor support"
+	default y
+	help
+	  Enable Xen hypervisor support.  Resulting kernel runs
+	  both as a guest OS on Xen and natively on hardware.
+
+config ARCH_XEN
+	bool
+	default y
+	depends on XEN
+	help
+	  TEMP ONLY. Needs to be on for drivers/xen to build.
 
 config SCHED_NO_NO_OMIT_FRAME_POINTER
 	bool
@@ -506,3 +520,5 @@ source "security/Kconfig"
 source "security/Kconfig"
 
 source "crypto/Kconfig"
+
+source "drivers/xen/Kconfig"
diff -r 016512c08f6b -r 4489a633a5de arch/ia64/Makefile
--- a/arch/ia64/Makefile	Thu May 25 03:00:07 2006 +0000
+++ b/arch/ia64/Makefile	Fri Jun 02 09:54:29 2006 -0600
@@ -45,6 +45,12 @@ endif
 endif
 
 CFLAGS += $(cflags-y)
+
+cppflags-$(CONFIG_XEN) += \
+	-D__XEN_INTERFACE_VERSION__=$(CONFIG_XEN_INTERFACE_VERSION)
+
+CPPFLAGS += $(cppflags-y)
+
 head-y := arch/ia64/kernel/head.o arch/ia64/kernel/init_task.o
 
 libs-y				+= arch/ia64/lib/
@@ -55,9 +61,15 @@ core-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/
 core-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/dig/
 core-$(CONFIG_IA64_HP_ZX1_SWIOTLB) += arch/ia64/dig/
 core-$(CONFIG_IA64_SGI_SN2)	+= arch/ia64/sn/
+core-$(CONFIG_XEN)		+= arch/ia64/xen/
 
 drivers-$(CONFIG_PCI)		+= arch/ia64/pci/
+ifneq ($(CONFIG_XEN),y)
 drivers-$(CONFIG_IA64_HP_SIM)	+= arch/ia64/hp/sim/
+endif
+ifneq ($(CONFIG_IA64_GENERIC),y)
+drivers-$(CONFIG_XEN)		+= arch/ia64/hp/sim/
+endif
 drivers-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/
 drivers-$(CONFIG_IA64_HP_ZX1_SWIOTLB) += arch/ia64/hp/common/ arch/ia64/hp/zx1/
 drivers-$(CONFIG_IA64_GENERIC)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/ arch/ia64/hp/sim/ arch/ia64/sn/
@@ -70,6 +82,8 @@ all: compressed unwcheck
 all: compressed unwcheck
 
 compressed: vmlinux.gz
+
+vmlinuz: vmlinux.gz
 
 vmlinux.gz: vmlinux
 	$(Q)$(MAKE) $(build)=$(boot) $@
@@ -85,8 +99,8 @@ boot:	lib/lib.a vmlinux
 boot:	lib/lib.a vmlinux
 	$(Q)$(MAKE) $(build)=$(boot) $@
 
-install: vmlinux.gz
-	sh $(srctree)/arch/ia64/install.sh $(KERNELRELEASE) $< System.map "$(INSTALL_PATH)"
+install:
+	-yes | sh $(srctree)/arch/ia64/install.sh $(KERNELRELEASE) vmlinux.gz System.map "$(INSTALL_PATH)"
 
 define archhelp
   echo '* compressed	- Build compressed kernel image'
diff -r 016512c08f6b -r 4489a633a5de arch/ia64/hp/sim/Makefile
--- a/arch/ia64/hp/sim/Makefile	Thu May 25 03:00:07 2006 +0000
+++ b/arch/ia64/hp/sim/Makefile	Fri Jun 02 09:54:29 2006 -0600
@@ -14,3 +14,5 @@ obj-$(CONFIG_HP_SIMSERIAL) += simserial.
 obj-$(CONFIG_HP_SIMSERIAL) += simserial.o
 obj-$(CONFIG_HP_SIMSERIAL_CONSOLE) += hpsim_console.o
 obj-$(CONFIG_HP_SIMSCSI) += simscsi.o
+obj-$(CONFIG_XEN) += simserial.o
+obj-$(CONFIG_XEN) += hpsim_console.o
diff -r 016512c08f6b -r 4489a633a5de arch/ia64/kernel/entry.S
--- a/arch/ia64/kernel/entry.S	Thu May 25 03:00:07 2006 +0000
+++ b/arch/ia64/kernel/entry.S	Fri Jun 02 09:54:29 2006 -0600
@@ -181,7 +181,7 @@ END(sys_clone)
  *	called.  The code starting at .map relies on this.  The rest of the code
  *	doesn't care about the interrupt masking status.
  */
-GLOBAL_ENTRY(ia64_switch_to)
+GLOBAL_ENTRY(__ia64_switch_to)
 	.prologue
 	alloc r16=ar.pfs,1,0,0,0
 	DO_SAVE_SWITCH_STACK
@@ -235,7 +235,7 @@ GLOBAL_ENTRY(ia64_switch_to)
 	;;
 	srlz.d
 	br.cond.sptk .done
-END(ia64_switch_to)
+END(__ia64_switch_to)
 
 /*
  * Note that interrupts are enabled during save_switch_stack and load_switch_stack.  This
@@ -376,7 +376,7 @@ END(save_switch_stack)
  *	- b7 holds address to return to
  *	- must not touch r8-r11
  */
-ENTRY(load_switch_stack)
+GLOBAL_ENTRY(load_switch_stack)
 	.prologue
 	.altrp b7
 
@@ -511,7 +511,7 @@ END(clone)
 	 * because some system calls (such as ia64_execve) directly
 	 * manipulate ar.pfs.
 	 */
-GLOBAL_ENTRY(ia64_trace_syscall)
+GLOBAL_ENTRY(__ia64_trace_syscall)
 	PT_REGS_UNWIND_INFO(0)
 	/*
 	 * We need to preserve the scratch registers f6-f11 in case the system
@@ -583,7 +583,7 @@ strace_error:
 (p6)	mov r10=-1
 (p6)	mov r8=r9
 	br.cond.sptk .strace_save_retval
-END(ia64_trace_syscall)
+END(__ia64_trace_syscall)
 
 	/*
 	 * When traced and returning from sigreturn, we invoke syscall_trace but then
@@ -636,8 +636,11 @@ GLOBAL_ENTRY(ia64_ret_from_syscall)
 	adds r2=PT(R8)+16,sp			// r2 = &pt_regs.r8
 	mov r10=r0				// clear error indication in r10
 (p7)	br.cond.spnt handle_syscall_error	// handle potential syscall failure
+	;;
+	// don't fall through, ia64_leave_syscall may be #define'd
+	br.cond.sptk.few ia64_leave_syscall
+	;;
 END(ia64_ret_from_syscall)
-	// fall through
 /*
  * ia64_leave_syscall(): Same as ia64_leave_kernel, except that it doesn't
  *	need to switch to bank 0 and doesn't restore the scratch registers.
@@ -682,7 +685,7 @@ END(ia64_ret_from_syscall)
  *	      ar.csd: cleared
  *	      ar.ssd: cleared
  */
-ENTRY(ia64_leave_syscall)
+GLOBAL_ENTRY(__ia64_leave_syscall)
 	PT_REGS_UNWIND_INFO(0)
 	/*
 	 * work.need_resched etc. mustn't get changed by this CPU before it returns to
@@ -790,7 +793,7 @@ ENTRY(ia64_leave_syscall)
 	mov.m ar.ssd=r0			// M2   clear ar.ssd
 	mov f11=f0			// F    clear f11
 	br.cond.sptk.many rbs_switch	// B
-END(ia64_leave_syscall)
+END(__ia64_leave_syscall)
 
 #ifdef CONFIG_IA32_SUPPORT
 GLOBAL_ENTRY(ia64_ret_from_ia32_execve)
@@ -802,10 +805,13 @@ GLOBAL_ENTRY(ia64_ret_from_ia32_execve)
 	st8.spill [r2]=r8	// store return value in slot for r8 and set unat bit
 	.mem.offset 8,0
 	st8.spill [r3]=r0	// clear error indication in slot for r10 and set unat bit
+	;;
+	// don't fall through, ia64_leave_kernel may be #define'd
+	br.cond.sptk.few ia64_leave_kernel
+	;;
 END(ia64_ret_from_ia32_execve)
-	// fall through
 #endif /* CONFIG_IA32_SUPPORT */
-GLOBAL_ENTRY(ia64_leave_kernel)
+GLOBAL_ENTRY(__ia64_leave_kernel)
 	PT_REGS_UNWIND_INFO(0)
 	/*
 	 * work.need_resched etc. mustn't get changed by this CPU before it returns to
@@ -1136,7 +1142,7 @@ skip_rbs_switch:
 	ld8 r10=[r3]
 	br.cond.sptk.many .work_processed_syscall	// re-check
 
-END(ia64_leave_kernel)
+END(__ia64_leave_kernel)
 
 ENTRY(handle_syscall_error)
 	/*
@@ -1176,7 +1182,7 @@ END(ia64_invoke_schedule_tail)
 	 * be set up by the caller.  We declare 8 input registers so the system call
 	 * args get preserved, in case we need to restart a system call.
 	 */
-ENTRY(notify_resume_user)
+GLOBAL_ENTRY(notify_resume_user)
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
 	alloc loc1=ar.pfs,8,2,3,0 // preserve all eight input regs in case of syscall restart!
 	mov r9=ar.unat
@@ -1264,7 +1270,7 @@ ENTRY(sys_rt_sigreturn)
 	adds sp=16,sp
 	;;
 	ld8 r9=[sp]				// load new ar.unat
-	mov.sptk b7=r8,ia64_leave_kernel
+	mov.sptk b7=r8,__ia64_leave_kernel
 	;;
 	mov ar.unat=r9
 	br.many b7
diff -r 016512c08f6b -r 4489a633a5de arch/ia64/kernel/head.S
--- a/arch/ia64/kernel/head.S	Thu May 25 03:00:07 2006 +0000
+++ b/arch/ia64/kernel/head.S	Fri Jun 02 09:54:29 2006 -0600
@@ -362,6 +362,12 @@ 1:	// now we are in virtual mode
 (isBP)	movl r2=ia64_boot_param
 	;;
 (isBP)	st8 [r2]=r28		// save the address of the boot param area passed by the bootloader
+
+#ifdef CONFIG_XEN
+	//  Note: isBP is used by the subprogram.
+	br.call.sptk.many rp=early_xen_setup
+	;;
+#endif
 
 #ifdef CONFIG_SMP
 (isAP)	br.call.sptk.many rp=start_secondary
diff -r 016512c08f6b -r 4489a633a5de arch/ia64/kernel/iosapic.c
--- a/arch/ia64/kernel/iosapic.c	Thu May 25 03:00:07 2006 +0000
+++ b/arch/ia64/kernel/iosapic.c	Fri Jun 02 09:54:29 2006 -0600
@@ -160,6 +160,65 @@ static int iosapic_kmalloc_ok;
 static int iosapic_kmalloc_ok;
 static LIST_HEAD(free_rte_list);
 
+#ifdef CONFIG_XEN
+#include <xen/interface/xen.h>
+#include <xen/interface/physdev.h>
+#include <asm/hypervisor.h>
+static inline unsigned int xen_iosapic_read(char __iomem *iosapic, unsigned int reg)
+{
+	struct physdev_apic apic_op;
+	int ret;
+
+	apic_op.apic_physbase = (unsigned long)iosapic -
+					__IA64_UNCACHED_OFFSET;
+	apic_op.reg = reg;
+	ret = HYPERVISOR_physdev_op(PHYSDEVOP_apic_read, &apic_op);
+	if (ret)
+		return ret;
+	return apic_op.value;
+}
+
+static inline void xen_iosapic_write(char __iomem *iosapic, unsigned int reg, u32 val)
+{
+	struct physdev_apic apic_op;
+
+	apic_op.apic_physbase = (unsigned long)iosapic - 
+					__IA64_UNCACHED_OFFSET;
+	apic_op.reg = reg;
+	apic_op.value = val;
+	HYPERVISOR_physdev_op(PHYSDEVOP_apic_write, &apic_op);
+}
+
+static inline unsigned int iosapic_read(char __iomem *iosapic, unsigned int reg)
+{
+	if (!is_running_on_xen()) {
+		writel(reg, iosapic + IOSAPIC_REG_SELECT);
+		return readl(iosapic + IOSAPIC_WINDOW);
+	} else
+		return xen_iosapic_read(iosapic, reg);
+}
+
+static inline void iosapic_write(char __iomem *iosapic, unsigned int reg, u32 val)
+{
+	if (!is_running_on_xen()) {
+		writel(reg, iosapic + IOSAPIC_REG_SELECT);
+		writel(val, iosapic + IOSAPIC_WINDOW);
+	} else
+		xen_iosapic_write(iosapic, reg, val);
+}
+
+int xen_assign_irq_vector(int irq)
+{
+	struct physdev_irq irq_op;
+
+	irq_op.irq = irq;
+	if (HYPERVISOR_physdev_op(PHYSDEVOP_alloc_irq_vector, &irq_op))
+		return -ENOSPC;
+
+	return irq_op.vector;
+}
+#endif /* XEN */
+
 /*
  * Find an IOSAPIC associated with a GSI
  */
@@ -653,6 +712,11 @@ register_intr (unsigned int gsi, int vec
 	iosapic_intr_info[vector].polarity = polarity;
 	iosapic_intr_info[vector].dmode    = delivery;
 	iosapic_intr_info[vector].trigger  = trigger;
+
+#ifdef CONFIG_XEN
+	if (is_running_on_xen())
+		return 0;
+#endif
 
 	if (trigger == IOSAPIC_EDGE)
 		irq_type = &irq_type_iosapic_edge;
@@ -1016,6 +1080,10 @@ iosapic_system_init (int system_pcat_com
 	}
 
 	pcat_compat = system_pcat_compat;
+#ifdef CONFIG_XEN
+	if (is_running_on_xen())
+		return;
+#endif
 	if (pcat_compat) {
 		/*
 		 * Disable the compatibility mode interrupts (8259 style),
diff -r 016512c08f6b -r 4489a633a5de arch/ia64/kernel/irq_ia64.c
--- a/arch/ia64/kernel/irq_ia64.c	Thu May 25 03:00:07 2006 +0000
+++ b/arch/ia64/kernel/irq_ia64.c	Fri Jun 02 09:54:29 2006 -0600
@@ -66,6 +66,11 @@ assign_irq_vector (int irq)
 assign_irq_vector (int irq)
 {
 	int pos, vector;
+#ifdef CONFIG_XEN
+	extern int xen_assign_irq_vector(int);
+	if (is_running_on_xen())
+		return xen_assign_irq_vector(irq);
+#endif /* CONFIG_XEN */
  again:
 	pos = find_first_zero_bit(ia64_vector_mask, IA64_NUM_DEVICE_VECTORS);
 	vector = IA64_FIRST_DEVICE_VECTOR + pos;
@@ -224,6 +229,151 @@ static struct irqaction ipi_irqaction = 
 };
 #endif
 
+#ifdef CONFIG_XEN
+#include <xen/evtchn.h>
+#include <xen/interface/callback.h>
+
+static char timer_name[NR_CPUS][15];
+static char ipi_name[NR_CPUS][15];
+static char resched_name[NR_CPUS][15];
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
+/* Dummy stub. Though we may check RESCHEDULE_VECTOR before __do_IRQ,
+ * it ends up to issue several memory accesses upon percpu data and
+ * thus adds unnecessary traffic to other paths.
+ */
+static irqreturn_t
+handle_reschedule(int irq, void *dev_id, struct pt_regs *regs)
+{
+
+	return IRQ_HANDLED;
+}
+
+static struct irqaction resched_irqaction = {
+	.handler =	handle_reschedule,
+	.flags =	SA_INTERRUPT,
+	.name =		"RESCHED"
+};
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
+void
+xen_register_percpu_irq (unsigned int irq, struct irqaction *action, int save)
+{
+	char name[15];
+	unsigned int cpu = smp_processor_id();
+	int ret = 0;
+
+	if (xen_slab_ready) {
+		switch (irq) {
+		case IA64_TIMER_VECTOR:
+			sprintf(timer_name[cpu], "%s%d", action->name, cpu);
+			ret = bind_virq_to_irqhandler(VIRQ_ITC, cpu,
+				action->handler, action->flags,
+				timer_name[cpu], action->dev_id);
+			printk(KERN_INFO "register VIRQ_ITC (%s) to xen irq (%d)\n", name, ret);
+			break;
+		case IA64_IPI_RESCHEDULE:
+			sprintf(resched_name[cpu], "%s%d", action->name, cpu);
+			ret = bind_ipi_to_irqhandler(RESCHEDULE_VECTOR, cpu,
+				action->handler, action->flags,
+				resched_name[cpu], action->dev_id);
+			printk(KERN_INFO "register RESCHEDULE_VECTOR (%s) to xen irq (%d)\n", name, ret);
+			break;
+		case IA64_IPI_VECTOR:
+			sprintf(ipi_name[cpu], "%s%d", action->name, cpu);
+			ret = bind_ipi_to_irqhandler(IPI_VECTOR, cpu,
+				action->handler, action->flags,
+				ipi_name[cpu], action->dev_id);
+			printk(KERN_INFO "register IPI_VECTOR (%s) to xen irq (%d)\n", name, ret);
+			break;
+		default:
+			printk(KERN_WARNING "Percpu irq %d is unsupported by xen!\n", irq);
+			break;
+		}
+		BUG_ON(ret < 0);
+	} 
+
+	/* For BSP, we cache registered percpu irqs, and then re-walk
+	 * them when initializing APs
+	 */
+	if (!cpu && save) {
+		BUG_ON(saved_irq_cnt == MAX_LATE_IRQ);
+		saved_percpu_irqs[saved_irq_cnt].irq = irq;
+		saved_percpu_irqs[saved_irq_cnt].action = action;
+		saved_irq_cnt++;
+		if (!xen_slab_ready)
+			late_irq_cnt++;
+	}
+}
+
+static void
+xen_bind_early_percpu_irq (void)
+{
+	int i;
+
+	xen_slab_ready = 1;
+	/* There's no race when accessing this cached array, since only
+	 * BSP will face with such step shortly
+	 */
+	for (i = 0; i < late_irq_cnt; i++)
+		xen_register_percpu_irq(saved_percpu_irqs[i].irq,
+			saved_percpu_irqs[i].action, 0);
+}
+
+/* FIXME: There's no obvious point to check whether slab is ready. So
+ * a hack is used here by utilizing a late time hook.
+ */
+extern void (*late_time_init)(void);
+extern char xen_event_callback;
+extern void xen_init_IRQ(void);
+
+DECLARE_PER_CPU(int, ipi_to_irq[NR_IPIS]);
+void xen_smp_intr_init(void)
+{
+#ifdef CONFIG_SMP
+	unsigned int cpu = smp_processor_id();
+	unsigned int i = 0;
+	struct callback_register event = {
+		.type = CALLBACKTYPE_event,
+		.address = (unsigned long)&xen_event_callback,
+	};
+
+	if (!cpu)
+		return;
+
+	/* This should be piggyback when setup vcpu guest context */
+	BUG_ON(HYPERVISOR_callback_op(CALLBACKOP_register, &event));
+
+	for (i = 0; i < saved_irq_cnt; i++)
+		xen_register_percpu_irq(saved_percpu_irqs[i].irq,
+			saved_percpu_irqs[i].action, 0);
+#endif /* CONFIG_SMP */
+}
+#endif /* CONFIG_XEN */
+
 void
 register_percpu_irq (ia64_vector vec, struct irqaction *action)
 {
@@ -232,6 +382,10 @@ register_percpu_irq (ia64_vector vec, st
 
 	for (irq = 0; irq < NR_IRQS; ++irq)
 		if (irq_to_vector(irq) == vec) {
+#ifdef CONFIG_XEN
+			if (is_running_on_xen())
+				return xen_register_percpu_irq(vec, action, 1);
+#endif
 			desc = irq_descp(irq);
 			desc->status |= IRQ_PER_CPU;
 			desc->handler = &irq_type_ia64_lsapic;
@@ -243,6 +397,21 @@ void __init
 void __init
 init_IRQ (void)
 {
+#ifdef CONFIG_XEN
+	/* Maybe put into platform_irq_init later */
+	if (is_running_on_xen()) {
+		struct callback_register event = {
+			.type = CALLBACKTYPE_event,
+			.address = (unsigned long)&xen_event_callback,
+		};
+		xen_init_IRQ();
+		BUG_ON(HYPERVISOR_callback_op(CALLBACKOP_register, &event));
+		late_time_init = xen_bind_early_percpu_irq;
+#ifdef CONFIG_SMP
+		register_percpu_irq(IA64_IPI_RESCHEDULE, &resched_irqaction);
+#endif /* CONFIG_SMP */
+	}
+#endif /* CONFIG_XEN */
 	register_percpu_irq(IA64_SPURIOUS_INT_VECTOR, NULL);
 #ifdef CONFIG_SMP
 	register_percpu_irq(IA64_IPI_VECTOR, &ipi_irqaction);
@@ -260,6 +429,37 @@ ia64_send_ipi (int cpu, int vector, int 
 	unsigned long ipi_data;
 	unsigned long phys_cpu_id;
 
+#ifdef CONFIG_XEN
+        if (is_running_on_xen()) {
+		int irq = -1;
+
+		/* TODO: we need to call vcpu_up here */
+		if (unlikely(vector == ap_wakeup_vector)) {
+			extern void xen_send_ipi (int cpu, int vec);
+			xen_send_ipi (cpu, vector);
+			//vcpu_prepare_and_up(cpu);
+			return;
+		}
+
+		switch(vector) {
+		case IA64_IPI_VECTOR:
+			irq = per_cpu(ipi_to_irq, cpu)[IPI_VECTOR];
+			break;
+		case IA64_IPI_RESCHEDULE:
+			irq = per_cpu(ipi_to_irq, cpu)[RESCHEDULE_VECTOR];
+			break;
+		default:
+			printk(KERN_WARNING"Unsupported IPI type 0x%x\n", vector);
+			irq = 0;
+			break;
+		}		
+	
+		BUG_ON(irq < 0);
+		notify_remote_via_irq(irq);
+		return;
+        }
+#endif /* CONFIG_XEN */
+
 #ifdef CONFIG_SMP
 	phys_cpu_id = cpu_physical_id(cpu);
 #else
diff -r 016512c08f6b -r 4489a633a5de arch/ia64/kernel/pal.S
--- a/arch/ia64/kernel/pal.S	Thu May 25 03:00:07 2006 +0000
+++ b/arch/ia64/kernel/pal.S	Fri Jun 02 09:54:29 2006 -0600
@@ -16,6 +16,7 @@
 #include <asm/processor.h>
 
 	.data
+	.globl pal_entry_point
 pal_entry_point:
 	data8 ia64_pal_default_handler
 	.text
@@ -53,7 +54,7 @@ END(ia64_pal_default_handler)
  * in4	       1 ==> clear psr.ic,  0 ==> don't clear psr.ic
  *
  */
-GLOBAL_ENTRY(ia64_pal_call_static)
+GLOBAL_ENTRY(__ia64_pal_call_static)
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(5)
 	alloc loc1 = ar.pfs,5,5,0,0
 	movl loc2 = pal_entry_point
@@ -90,7 +91,7 @@ 1:	mov psr.l = loc3
 	;;
 	srlz.d				// seralize restoration of psr.l
 	br.ret.sptk.many b0
-END(ia64_pal_call_static)
+END(__ia64_pal_call_static)
 
 /*
  * Make a PAL call using the stacked registers calling convention.
diff -r 016512c08f6b -r 4489a633a5de arch/ia64/kernel/setup.c
--- a/arch/ia64/kernel/setup.c	Thu May 25 03:00:07 2006 +0000
+++ b/arch/ia64/kernel/setup.c	Fri Jun 02 09:54:29 2006 -0600
@@ -61,6 +61,10 @@
 #include <asm/system.h>
 #include <asm/unistd.h>
 #include <asm/system.h>
+#ifdef CONFIG_XEN
+#include <asm/hypervisor.h>
+#endif
+#include <linux/dma-mapping.h>
 
 #if defined(CONFIG_SMP) && (IA64_CPU_SIZE > PAGE_SIZE)
 # error "struct cpuinfo_ia64 too big!"
@@ -243,6 +247,14 @@ reserve_memory (void)
 	rsvd_region[n].end   = (unsigned long) ia64_imva(_end);
 	n++;
 
+#ifdef CONFIG_XEN
+	if (is_running_on_xen()) {
+		rsvd_region[n].start = (unsigned long)__va((HYPERVISOR_shared_info->arch.start_info_pfn << PAGE_SHIFT));
+		rsvd_region[n].end   = rsvd_region[n].start + PAGE_SIZE;
+		n++;
+ 	}
+#endif
+
 #ifdef CONFIG_BLK_DEV_INITRD
 	if (ia64_boot_param->initrd_start) {
 		rsvd_region[n].start = (unsigned long)__va(ia64_boot_param->initrd_start);
@@ -260,6 +272,7 @@ reserve_memory (void)
 	n++;
 
 	num_rsvd_regions = n;
+	BUG_ON(IA64_MAX_RSVD_REGIONS + 1 < n);
 
 	sort_regions(rsvd_region, num_rsvd_regions);
 }
@@ -333,6 +346,16 @@ early_console_setup (char *cmdline)
 {
 	int earlycons = 0;
 
+#ifdef CONFIG_XEN
+#ifndef CONFIG_IA64_HP_SIM
+	if (is_running_on_xen()) {
+		extern struct console hpsim_cons;
+		hpsim_cons.flags |= CON_BOOT;
+		register_console(&hpsim_cons);
+		earlycons++;
+	}
+#endif
+#endif
 #ifdef CONFIG_SERIAL_SGI_L1_CONSOLE
 	{
 		extern int sn_serial_console_early_setup(void);
@@ -401,6 +424,10 @@ setup_arch (char **cmdline_p)
 setup_arch (char **cmdline_p)
 {
 	unw_init();
+#ifdef CONFIG_XEN
+	if (is_running_on_xen())
+		setup_xen_features();
+#endif
 
 	ia64_patch_vtop((u64) __start___vtop_patchlist, (u64) __end___vtop_patchlist);
 
@@ -478,6 +505,25 @@ setup_arch (char **cmdline_p)
 			conswitchp = &vga_con;
 # endif
 	}
+#ifdef CONFIG_XEN
+	if (is_running_on_xen()) {
+		extern shared_info_t *HYPERVISOR_shared_info;
+		extern int xen_init (void);
+
+		xen_init ();
+
+		/* xen_start_info isn't setup yet, get the flags manually */
+		if (HYPERVISOR_shared_info->arch.flags & SIF_INITDOMAIN) {
+			if (!(HYPERVISOR_shared_info->arch.flags & SIF_PRIVILEGED))
+				panic("Xen granted us console access "
+				      "but not privileged status");
+		} else {
+			extern int console_use_vt;
+			conswitchp = NULL;
+			console_use_vt = 0;
+		}
+	}
+#endif
 #endif
 
 	/* enable IA-64 Machine Check Abort Handling unless disabled */
@@ -486,6 +532,7 @@ setup_arch (char **cmdline_p)
 
 	platform_setup(cmdline_p);
 	paging_init();
+	contiguous_bitmap_init(max_pfn);
 }
 
 /*
@@ -870,6 +917,13 @@ cpu_init (void)
 	/* size of physical stacked register partition plus 8 bytes: */
 	__get_cpu_var(ia64_phys_stacked_size_p8) = num_phys_stacked*8 + 8;
 	platform_cpu_init();
+#ifdef CONFIG_XEN
+	/* Need to be moved into platform_cpu_init later */
+	if (is_running_on_xen()) {
+		extern void xen_smp_intr_init(void);
+		xen_smp_intr_init();
+	}
+#endif
 	pm_idle = default_idle;
 }
 
diff -r 016512c08f6b -r 4489a633a5de arch/ia64/mm/ioremap.c
--- a/arch/ia64/mm/ioremap.c	Thu May 25 03:00:07 2006 +0000
+++ b/arch/ia64/mm/ioremap.c	Fri Jun 02 09:54:29 2006 -0600
@@ -15,6 +15,9 @@ static inline void __iomem *
 static inline void __iomem *
 __ioremap (unsigned long offset, unsigned long size)
 {
+#ifdef CONFIG_XEN
+	offset = HYPERVISOR_ioremap(offset, size);
+#endif
 	return (void __iomem *) (__IA64_UNCACHED_OFFSET | offset);
 }
 
diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/agp.h
--- a/include/asm-ia64/agp.h	Thu May 25 03:00:07 2006 +0000
+++ b/include/asm-ia64/agp.h	Fri Jun 02 09:54:29 2006 -0600
@@ -19,13 +19,44 @@
 #define flush_agp_cache()		mb()
 
 /* Convert a physical address to an address suitable for the GART. */
+#ifndef CONFIG_XEN
 #define phys_to_gart(x) (x)
 #define gart_to_phys(x) (x)
+#else
+#define phys_to_gart(x) phys_to_machine_for_dma(x)
+#define gart_to_phys(x) machine_to_phys_for_dma(x)
+#endif
 
 /* GATT allocation. Returns/accepts GATT kernel virtual address. */
+#ifndef CONFIG_XEN
 #define alloc_gatt_pages(order)		\
 	((char *)__get_free_pages(GFP_KERNEL, (order)))
 #define free_gatt_pages(table, order)	\
 	free_pages((unsigned long)(table), (order))
+#else
+#include <asm/hypervisor.h>
+static inline char*
+alloc_gatt_pages(unsigned int order)
+{
+	unsigned long error;
+	unsigned long ret = __get_free_pages(GFP_KERNEL, (order));
+	if (ret == 0) {
+		goto out;
+	}
+	error = xen_create_contiguous_region(ret, order, 0);
+	if (error) {
+		free_pages(ret, order);
+		ret = 0;
+	}
+out:
+	return (char*)ret;
+}
+static inline void
+free_gatt_pages(void* table, unsigned int order)
+{
+	xen_destroy_contiguous_region((unsigned long)table, order);
+	free_pages((unsigned long)table, order);
+}
+#endif /* CONFIG_XEN */
 
 #endif /* _ASM_IA64_AGP_H */
diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/dma-mapping.h
--- a/include/asm-ia64/dma-mapping.h	Thu May 25 03:00:07 2006 +0000
+++ b/include/asm-ia64/dma-mapping.h	Fri Jun 02 09:54:29 2006 -0600
@@ -7,7 +7,13 @@
  */
 #include <linux/config.h>
 #include <asm/machvec.h>
+#ifdef CONFIG_XEN
+#include <asm/hypervisor.h> //XXX to compile arch/i386/kernel/swiotlb.c
+                            //    and arch/i386/kernel/pci-dma-xen.c
+#include <asm-i386/mach-xen/asm/swiotlb.h> //XXX to compile arch/i386/kernel/swiotlb.c
+#endif
 
+#ifndef CONFIG_XEN
 #define dma_alloc_coherent	platform_dma_alloc_coherent
 #define dma_alloc_noncoherent	platform_dma_alloc_coherent	/* coherent mem. is cheap */
 #define dma_free_coherent	platform_dma_free_coherent
@@ -21,6 +27,46 @@
 #define dma_sync_single_for_device platform_dma_sync_single_for_device
 #define dma_sync_sg_for_device	platform_dma_sync_sg_for_device
 #define dma_mapping_error	platform_dma_mapping_error
+#else
+int dma_map_sg(struct device *hwdev, struct scatterlist *sg, int nents,
+               enum dma_data_direction direction);
+void dma_unmap_sg(struct device *hwdev, struct scatterlist *sg, int nents,
+                  enum dma_data_direction direction);
+int dma_supported(struct device *dev, u64 mask);
+void *dma_alloc_coherent(struct device *dev, size_t size,
+                         dma_addr_t *dma_handle, gfp_t gfp);
+void dma_free_coherent(struct device *dev, size_t size, void *vaddr,
+                       dma_addr_t dma_handle);
+dma_addr_t dma_map_single(struct device *dev, void *ptr, size_t size,
+                          enum dma_data_direction direction);
+void dma_unmap_single(struct device *dev, dma_addr_t dma_addr, size_t size,
+                      enum dma_data_direction direction);
+void dma_sync_single_for_cpu(struct device *dev, dma_addr_t dma_handle,
+                             size_t size, enum dma_data_direction direction);
+void dma_sync_single_for_device(struct device *dev, dma_addr_t dma_handle,
+                                size_t size,
+                                enum dma_data_direction direction);
+int dma_mapping_error(dma_addr_t dma_addr);
+
+#define flush_write_buffers()	do { } while (0)
+static inline void
+dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg, int nelems,
+                    enum dma_data_direction direction)
+{
+	if (swiotlb)
+		swiotlb_sync_sg_for_cpu(dev,sg,nelems,direction);
+	flush_write_buffers();
+}
+
+static inline void
+dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg, int nelems,
+                       enum dma_data_direction direction)
+{
+	if (swiotlb)
+		swiotlb_sync_sg_for_device(dev,sg,nelems,direction);
+	flush_write_buffers();
+}
+#endif
 
 #define dma_map_page(dev, pg, off, size, dir)				\
 	dma_map_single(dev, page_address(pg) + (off), (size), (dir))
@@ -62,4 +108,27 @@ dma_cache_sync (void *vaddr, size_t size
 
 #define dma_is_consistent(dma_handle)	(1)	/* all we do is coherent memory... */
 
+#ifdef CONFIG_XEN
+// arch/i386/kernel/swiotlb.o requires
+void contiguous_bitmap_init(unsigned long end_pfn);
+
+static inline int
+address_needs_mapping(struct device *hwdev, dma_addr_t addr)
+{
+	dma_addr_t mask = DMA_64BIT_MASK;
+	/* If the device has a mask, use it, otherwise default to 64 bits */
+	if (hwdev && hwdev->dma_mask)
+		mask = *hwdev->dma_mask;
+	return (addr & ~mask) != 0;
+}
+
+static inline int
+range_straddles_page_boundary(void *p, size_t size)
+{
+	extern unsigned long *contiguous_bitmap;
+	return (((((unsigned long)p & ~PAGE_MASK) + size) > PAGE_SIZE) &&
+	        !test_bit(__pa(p) >> PAGE_SHIFT, contiguous_bitmap));
+}
+#endif
+
 #endif /* _ASM_IA64_DMA_MAPPING_H */
diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/gcc_intrin.h
--- a/include/asm-ia64/gcc_intrin.h	Thu May 25 03:00:07 2006 +0000
+++ b/include/asm-ia64/gcc_intrin.h	Fri Jun 02 09:54:29 2006 -0600
@@ -26,7 +26,7 @@ extern void ia64_bad_param_for_getreg (v
 
 register unsigned long ia64_r13 asm ("r13") __attribute_used__;
 
-#define ia64_setreg(regnum, val)						\
+#define __ia64_setreg(regnum, val)						\
 ({										\
 	switch (regnum) {							\
 	    case _IA64_REG_PSR_L:						\
@@ -55,7 +55,7 @@ register unsigned long ia64_r13 asm ("r1
 	}									\
 })
 
-#define ia64_getreg(regnum)							\
+#define __ia64_getreg(regnum)							\
 ({										\
 	__u64 ia64_intri_res;							\
 										\
@@ -92,7 +92,7 @@ register unsigned long ia64_r13 asm ("r1
 
 #define ia64_hint_pause 0
 
-#define ia64_hint(mode)						\
+#define __ia64_hint(mode)						\
 ({								\
 	switch (mode) {						\
 	case ia64_hint_pause:					\
@@ -374,7 +374,7 @@ register unsigned long ia64_r13 asm ("r1
 
 #define ia64_invala() asm volatile ("invala" ::: "memory")
 
-#define ia64_thash(addr)							\
+#define __ia64_thash(addr)							\
 ({										\
 	__u64 ia64_intri_res;							\
 	asm volatile ("thash %0=%1" : "=r"(ia64_intri_res) : "r" (addr));	\
@@ -394,18 +394,18 @@ register unsigned long ia64_r13 asm ("r1
 
 #define ia64_nop(x)	asm volatile ("nop %0"::"i"(x));
 
-#define ia64_itci(addr)	asm volatile ("itc.i %0;;" :: "r"(addr) : "memory")
-
-#define ia64_itcd(addr)	asm volatile ("itc.d %0;;" :: "r"(addr) : "memory")
-
-
-#define ia64_itri(trnum, addr) asm volatile ("itr.i itr[%0]=%1"				\
+#define __ia64_itci(addr)	asm volatile ("itc.i %0;;" :: "r"(addr) : "memory")
+
+#define __ia64_itcd(addr)	asm volatile ("itc.d %0;;" :: "r"(addr) : "memory")
+
+
+#define __ia64_itri(trnum, addr) asm volatile ("itr.i itr[%0]=%1"			\
 					     :: "r"(trnum), "r"(addr) : "memory")
 
-#define ia64_itrd(trnum, addr) asm volatile ("itr.d dtr[%0]=%1"				\
+#define __ia64_itrd(trnum, addr) asm volatile ("itr.d dtr[%0]=%1"			\
 					     :: "r"(trnum), "r"(addr) : "memory")
 
-#define ia64_tpa(addr)								\
+#define __ia64_tpa(addr)							\
 ({										\
 	__u64 ia64_pa;								\
 	asm volatile ("tpa %0 = %1" : "=r"(ia64_pa) : "r"(addr) : "memory");	\
@@ -415,22 +415,22 @@ register unsigned long ia64_r13 asm ("r1
 #define __ia64_set_dbr(index, val)						\
 	asm volatile ("mov dbr[%0]=%1" :: "r"(index), "r"(val) : "memory")
 
-#define ia64_set_ibr(index, val)						\
+#define __ia64_set_ibr(index, val)						\
 	asm volatile ("mov ibr[%0]=%1" :: "r"(index), "r"(val) : "memory")
 
-#define ia64_set_pkr(index, val)						\
+#define __ia64_set_pkr(index, val)						\
 	asm volatile ("mov pkr[%0]=%1" :: "r"(index), "r"(val) : "memory")
 
-#define ia64_set_pmc(index, val)						\
+#define __ia64_set_pmc(index, val)						\
 	asm volatile ("mov pmc[%0]=%1" :: "r"(index), "r"(val) : "memory")
 
-#define ia64_set_pmd(index, val)						\
+#define __ia64_set_pmd(index, val)						\
 	asm volatile ("mov pmd[%0]=%1" :: "r"(index), "r"(val) : "memory")
 
-#define ia64_set_rr(index, val)							\
+#define __ia64_set_rr(index, val)							\
 	asm volatile ("mov rr[%0]=%1" :: "r"(index), "r"(val) : "memory");
 
-#define ia64_get_cpuid(index)								\
+#define __ia64_get_cpuid(index)								\
 ({											\
 	__u64 ia64_intri_res;								\
 	asm volatile ("mov %0=cpuid[%r1]" : "=r"(ia64_intri_res) : "rO"(index));	\
@@ -444,21 +444,21 @@ register unsigned long ia64_r13 asm ("r1
 	ia64_intri_res;								\
 })
 
-#define ia64_get_ibr(index)							\
+#define __ia64_get_ibr(index)							\
 ({										\
 	__u64 ia64_intri_res;							\
 	asm volatile ("mov %0=ibr[%1]" : "=r"(ia64_intri_res) : "r"(index));	\
 	ia64_intri_res;								\
 })
 
-#define ia64_get_pkr(index)							\
+#define __ia64_get_pkr(index)							\
 ({										\
 	__u64 ia64_intri_res;							\
 	asm volatile ("mov %0=pkr[%1]" : "=r"(ia64_intri_res) : "r"(index));	\
 	ia64_intri_res;								\
 })
 
-#define ia64_get_pmc(index)							\
+#define __ia64_get_pmc(index)							\
 ({										\
 	__u64 ia64_intri_res;							\
 	asm volatile ("mov %0=pmc[%1]" : "=r"(ia64_intri_res) : "r"(index));	\
@@ -466,48 +466,48 @@ register unsigned long ia64_r13 asm ("r1
 })
 
 
-#define ia64_get_pmd(index)							\
+#define __ia64_get_pmd(index)							\
 ({										\
 	__u64 ia64_intri_res;							\
 	asm volatile ("mov %0=pmd[%1]" : "=r"(ia64_intri_res) : "r"(index));	\
 	ia64_intri_res;								\
 })
 
-#define ia64_get_rr(index)							\
+#define __ia64_get_rr(index)							\
 ({										\
 	__u64 ia64_intri_res;							\
 	asm volatile ("mov %0=rr[%1]" : "=r"(ia64_intri_res) : "r" (index));	\
 	ia64_intri_res;								\
 })
 
-#define ia64_fc(addr)	asm volatile ("fc %0" :: "r"(addr) : "memory")
+#define __ia64_fc(addr)	asm volatile ("fc %0" :: "r"(addr) : "memory")
 
 
 #define ia64_sync_i()	asm volatile (";; sync.i" ::: "memory")
 
-#define ia64_ssm(mask)	asm volatile ("ssm %0":: "i"((mask)) : "memory")
-#define ia64_rsm(mask)	asm volatile ("rsm %0":: "i"((mask)) : "memory")
+#define __ia64_ssm(mask)	asm volatile ("ssm %0":: "i"((mask)) : "memory")
+#define __ia64_rsm(mask)	asm volatile ("rsm %0":: "i"((mask)) : "memory")
 #define ia64_sum(mask)	asm volatile ("sum %0":: "i"((mask)) : "memory")
 #define ia64_rum(mask)	asm volatile ("rum %0":: "i"((mask)) : "memory")
 
-#define ia64_ptce(addr)	asm volatile ("ptc.e %0" :: "r"(addr))
-
-#define ia64_ptcga(addr, size)							\
+#define __ia64_ptce(addr)	asm volatile ("ptc.e %0" :: "r"(addr))
+
+#define __ia64_ptcga(addr, size)							\
 do {										\
 	asm volatile ("ptc.ga %0,%1" :: "r"(addr), "r"(size) : "memory");	\
 	ia64_dv_serialize_data();						\
 } while (0)
 
-#define ia64_ptcl(addr, size)							\
+#define __ia64_ptcl(addr, size)							\
 do {										\
 	asm volatile ("ptc.l %0,%1" :: "r"(addr), "r"(size) : "memory");	\
 	ia64_dv_serialize_data();						\
 } while (0)
 
-#define ia64_ptri(addr, size)						\
+#define __ia64_ptri(addr, size)						\
 	asm volatile ("ptr.i %0,%1" :: "r"(addr), "r"(size) : "memory")
 
-#define ia64_ptrd(addr, size)						\
+#define __ia64_ptrd(addr, size)						\
 	asm volatile ("ptr.d %0,%1" :: "r"(addr), "r"(size) : "memory")
 
 /* Values for lfhint in ia64_lfetch and ia64_lfetch_fault */
@@ -589,7 +589,7 @@ do {										\
         }								\
 })
 
-#define ia64_intrin_local_irq_restore(x)			\
+#define __ia64_intrin_local_irq_restore(x)			\
 do {								\
 	asm volatile (";;   cmp.ne p6,p7=%0,r0;;"		\
 		      "(p6) ssm psr.i;"				\
@@ -598,4 +598,6 @@ do {								\
 		      :: "r"((x)) : "p6", "p7", "memory");	\
 } while (0)
 
+#define __ia64_get_psr_i()	(__ia64_getreg(_IA64_REG_PSR) & 0x4000UL)
+
 #endif /* _ASM_IA64_GCC_INTRIN_H */
diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/hw_irq.h
--- a/include/asm-ia64/hw_irq.h	Thu May 25 03:00:07 2006 +0000
+++ b/include/asm-ia64/hw_irq.h	Fri Jun 02 09:54:29 2006 -0600
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
@@ -86,11 +90,15 @@ extern void ia64_send_ipi (int cpu, int 
 extern void ia64_send_ipi (int cpu, int vector, int delivery_mode, int redirect);
 extern void register_percpu_irq (ia64_vector vec, struct irqaction *action);
 
+#ifndef CONFIG_XEN
 static inline void
 hw_resend_irq (struct hw_interrupt_type *h, unsigned int vector)
 {
 	platform_send_ipi(smp_processor_id(), vector, IA64_IPI_DM_INT, 0);
 }
+#else
+extern void hw_resend_irq(struct hw_interrupt_type *h, unsigned int i);
+#endif /* CONFIG_XEN */
 
 /*
  * Default implementations for the irq-descriptor API:
diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/intel_intrin.h
--- a/include/asm-ia64/intel_intrin.h	Thu May 25 03:00:07 2006 +0000
+++ b/include/asm-ia64/intel_intrin.h	Fri Jun 02 09:54:29 2006 -0600
@@ -16,10 +16,10 @@
 		 	 * intrinsic
 		 	 */
 
-#define ia64_getreg		__getReg
-#define ia64_setreg		__setReg
+#define __ia64_getreg		__getReg
+#define __ia64_setreg		__setReg
 
-#define ia64_hint		__hint
+#define __ia64_hint		__hint
 #define ia64_hint_pause		__hint_pause
 
 #define ia64_mux1_brcst		_m64_mux1_brcst
@@ -33,16 +33,16 @@
 #define ia64_getf_exp		__getf_exp
 #define ia64_shrp		_m64_shrp
 
-#define ia64_tpa		__tpa
+#define __ia64_tpa		__tpa
 #define ia64_invala		__invala
 #define ia64_invala_gr		__invala_gr
 #define ia64_invala_fr		__invala_fr
 #define ia64_nop		__nop
 #define ia64_sum		__sum
-#define ia64_ssm		__ssm
+#define __ia64_ssm		__ssm
 #define ia64_rum		__rum
-#define ia64_rsm		__rsm
-#define ia64_fc 		__fc
+#define __ia64_rsm		__rsm
+#define __ia64_fc 		__fc
 
 #define ia64_ldfs		__ldfs
 #define ia64_ldfd		__ldfd
@@ -80,24 +80,24 @@
 
 #define __ia64_set_dbr(index, val)	\
 		__setIndReg(_IA64_REG_INDR_DBR, index, val)
-#define ia64_set_ibr(index, val)	\
+#define __ia64_set_ibr(index, val)	\
 		__setIndReg(_IA64_REG_INDR_IBR, index, val)
-#define ia64_set_pkr(index, val)	\
+#define __ia64_set_pkr(index, val)	\
 		__setIndReg(_IA64_REG_INDR_PKR, index, val)
-#define ia64_set_pmc(index, val)	\
+#define __ia64_set_pmc(index, val)	\
 		__setIndReg(_IA64_REG_INDR_PMC, index, val)
-#define ia64_set_pmd(index, val)	\
+#define __ia64_set_pmd(index, val)	\
 		__setIndReg(_IA64_REG_INDR_PMD, index, val)
-#define ia64_set_rr(index, val)	\
+#define __ia64_set_rr(index, val)	\
 		__setIndReg(_IA64_REG_INDR_RR, index, val)
 
-#define ia64_get_cpuid(index) 	__getIndReg(_IA64_REG_INDR_CPUID, index)
+#define __ia64_get_cpuid(index) 	__getIndReg(_IA64_REG_INDR_CPUID, index)
 #define __ia64_get_dbr(index) 	__getIndReg(_IA64_REG_INDR_DBR, index)
-#define ia64_get_ibr(index) 	__getIndReg(_IA64_REG_INDR_IBR, index)
-#define ia64_get_pkr(index) 	__getIndReg(_IA64_REG_INDR_PKR, index)
-#define ia64_get_pmc(index) 	__getIndReg(_IA64_REG_INDR_PMC, index)
-#define ia64_get_pmd(index)  	__getIndReg(_IA64_REG_INDR_PMD, index)
-#define ia64_get_rr(index) 	__getIndReg(_IA64_REG_INDR_RR, index)
+#define __ia64_get_ibr(index) 	__getIndReg(_IA64_REG_INDR_IBR, index)
+#define __ia64_get_pkr(index) 	__getIndReg(_IA64_REG_INDR_PKR, index)
+#define __ia64_get_pmc(index) 	__getIndReg(_IA64_REG_INDR_PMC, index)
+#define __ia64_get_pmd(index)  	__getIndReg(_IA64_REG_INDR_PMD, index)
+#define __ia64_get_rr(index) 	__getIndReg(_IA64_REG_INDR_RR, index)
 
 #define ia64_srlz_d		__dsrlz
 #define ia64_srlz_i		__isrlz
@@ -116,18 +116,18 @@
 #define ia64_ld8_acq		__ld8_acq
 
 #define ia64_sync_i		__synci
-#define ia64_thash		__thash
-#define ia64_ttag		__ttag
-#define ia64_itcd		__itcd
-#define ia64_itci		__itci
-#define ia64_itrd		__itrd
-#define ia64_itri		__itri
-#define ia64_ptce		__ptce
-#define ia64_ptcl		__ptcl
-#define ia64_ptcg		__ptcg
-#define ia64_ptcga		__ptcga
-#define ia64_ptri		__ptri
-#define ia64_ptrd		__ptrd
+#define __ia64_thash		__thash
+#define __ia64_ttag		__ttag
+#define __ia64_itcd		__itcd
+#define __ia64_itci		__itci
+#define __ia64_itrd		__itrd
+#define __ia64_itri		__itri
+#define __ia64_ptce		__ptce
+#define __ia64_ptcl		__ptcl
+#define __ia64_ptcg		__ptcg
+#define __ia64_ptcga		__ptcga
+#define __ia64_ptri		__ptri
+#define __ia64_ptrd		__ptrd
 #define ia64_dep_mi		_m64_dep_mi
 
 /* Values for lfhint in __lfetch and __lfetch_fault */
@@ -142,15 +142,17 @@
 #define ia64_lfetch_fault	__lfetch_fault
 #define ia64_lfetch_fault_excl	__lfetch_fault_excl
 
-#define ia64_intrin_local_irq_restore(x)		\
+#define __ia64_intrin_local_irq_restore(x)		\
 do {							\
 	if ((x) != 0) {					\
-		ia64_ssm(IA64_PSR_I);			\
+		__ia64_ssm(IA64_PSR_I);			\
 		ia64_srlz_d();				\
 	} else {					\
-		ia64_rsm(IA64_PSR_I);			\
+		__ia64_rsm(IA64_PSR_I);			\
 	}						\
 } while (0)
+
+#define __ia64_get_psr_i()	(__ia64_getreg(_IA64_REG_PSR) & 0x4000UL)
 
 #define __builtin_trap()	__break(0);
 
diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/io.h
--- a/include/asm-ia64/io.h	Thu May 25 03:00:07 2006 +0000
+++ b/include/asm-ia64/io.h	Fri Jun 02 09:54:29 2006 -0600
@@ -71,6 +71,10 @@ extern unsigned int num_io_spaces;
 #include <asm/page.h>
 #include <asm/system.h>
 #include <asm-generic/iomap.h>
+#ifdef CONFIG_XEN
+#include <asm/privop.h>
+#include <asm/hypervisor.h>
+#endif
 
 /*
  * Change virtual addresses to physical addresses and vv.
@@ -95,9 +99,39 @@ extern int valid_mmap_phys_addr_range (u
  * The following two macros are deprecated and scheduled for removal.
  * Please use the PCI-DMA interface defined in <asm/pci.h> instead.
  */
+#ifndef CONFIG_XEN
 #define bus_to_virt	phys_to_virt
 #define virt_to_bus	virt_to_phys
 #define page_to_bus	page_to_phys
+#define page_to_phys(page)		(page_to_pfn(page) << PAGE_SHIFT)
+#define page_to_pseudophys(page)	page_to_phys(page)
+#else
+#define bus_to_virt(bus)	\
+	phys_to_virt(machine_to_phys_for_dma(bus))
+#define virt_to_bus(virt)	\
+	phys_to_machine_for_dma(virt_to_phys(virt))
+#define page_to_bus(page)	\
+	phys_to_machine_for_dma(page_to_pseudophys(page))
+
+#define page_to_pseudophys(page) \
+	((dma_addr_t)page_to_pfn(page) << PAGE_SHIFT)
+// XXX
+// the following drivers are broken because they use page_to_phys() to
+// get bus address. fix them.
+// drivers/ide/cris/ide-cris.c
+// drivers/scsi/dec_esp.c
+#define page_to_phys(page)	(page_to_pseudophys(page))
+#define bvec_to_bus(bv)		(page_to_bus((bv)->bv_page) + \
+				(unsigned long) (bv)->bv_offset)
+#define bio_to_pseudophys(bio)	(page_to_pseudophys(bio_page((bio))) +	\
+				 (unsigned long) bio_offset((bio)))
+#define bvec_to_pseudophys(bv)  (page_to_pseudophys((bv)->bv_page) +	\
+				 (unsigned long) (bv)->bv_offset)
+#define BIOVEC_PHYS_MERGEABLE(vec1, vec2)				\
+	(((bvec_to_bus((vec1)) + (vec1)->bv_len) == bvec_to_bus((vec2))) && \
+	 ((bvec_to_pseudophys((vec1)) + (vec1)->bv_len) ==		\
+	  bvec_to_pseudophys((vec2))))
+#endif
 
 # endif /* KERNEL */
 
diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/iosapic.h
--- a/include/asm-ia64/iosapic.h	Thu May 25 03:00:07 2006 +0000
+++ b/include/asm-ia64/iosapic.h	Fri Jun 02 09:54:29 2006 -0600
@@ -53,6 +53,7 @@
 
 #define NR_IOSAPICS			256
 
+#ifndef CONFIG_XEN
 static inline unsigned int iosapic_read(char __iomem *iosapic, unsigned int reg)
 {
 	writel(reg, iosapic + IOSAPIC_REG_SELECT);
@@ -64,6 +65,7 @@ static inline void iosapic_write(char __
 	writel(reg, iosapic + IOSAPIC_REG_SELECT);
 	writel(val, iosapic + IOSAPIC_WINDOW);
 }
+#endif
 
 static inline void iosapic_eoi(char __iomem *iosapic, u32 vector)
 {
diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/irq.h
--- a/include/asm-ia64/irq.h	Thu May 25 03:00:07 2006 +0000
+++ b/include/asm-ia64/irq.h	Fri Jun 02 09:54:29 2006 -0600
@@ -11,8 +11,39 @@
  * 02/29/00     D.Mosberger	moved most things into hw_irq.h
  */
 
+#ifndef CONFIG_XEN
 #define NR_IRQS		256
 #define NR_IRQ_VECTORS	NR_IRQS
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
+#define NR_DYNIRQS		256
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
+#define NR_IPIS			2
+#endif /* CONFIG_XEN */
 
 /*
  * IRQ line status macro IRQ_PER_CPU is used
diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/machvec.h
--- a/include/asm-ia64/machvec.h	Thu May 25 03:00:07 2006 +0000
+++ b/include/asm-ia64/machvec.h	Fri Jun 02 09:54:29 2006 -0600
@@ -257,6 +257,21 @@ extern void machvec_init (const char *na
 #  error Unknown configuration.  Update asm-ia64/machvec.h.
 # endif /* CONFIG_IA64_GENERIC */
 
+#ifdef CONFIG_XEN
+# define platform_dma_map_sg		dma_map_sg
+# define platform_dma_unmap_sg		dma_unmap_sg
+# define platform_dma_mapping_error	dma_mapping_error
+# define platform_dma_supported		dma_supported
+# define platform_dma_alloc_coherent	dma_alloc_coherent
+# define platform_dma_free_coherent	dma_free_coherent
+# define platform_dma_map_single	dma_map_single
+# define platform_dma_unmap_single	dma_unmap_single
+# define platform_dma_sync_single_for_cpu \
+					dma_sync_single_for_cpu
+# define platform_dma_sync_single_for_device \
+					dma_sync_single_for_device
+#endif
+
 /*
  * Declare default routines which aren't declared anywhere else:
  */
diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/meminit.h
--- a/include/asm-ia64/meminit.h	Thu May 25 03:00:07 2006 +0000
+++ b/include/asm-ia64/meminit.h	Fri Jun 02 09:54:29 2006 -0600
@@ -17,10 +17,15 @@
  * 	- command line string
  * 	- kernel code & data
  * 	- Kernel memory map built from EFI memory map
+ *	- xen start info
  *
  * More could be added if necessary
  */
+#ifndef CONFIG_XEN
 #define IA64_MAX_RSVD_REGIONS 6
+#else
+#define IA64_MAX_RSVD_REGIONS 7
+#endif
 
 struct rsvd_region {
 	unsigned long start;	/* virtual address of beginning of element */
diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/page.h
--- a/include/asm-ia64/page.h	Thu May 25 03:00:07 2006 +0000
+++ b/include/asm-ia64/page.h	Fri Jun 02 09:54:29 2006 -0600
@@ -127,7 +127,6 @@ extern unsigned long max_low_pfn;
 # define pfn_valid(pfn)		(((pfn) >= min_low_pfn) && ((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))
 #endif
 
-#define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
 #define pfn_to_kaddr(pfn)	__va((pfn) << PAGE_SHIFT)
 
@@ -229,4 +228,105 @@ get_order (unsigned long size)
 					 (((current->personality & READ_IMPLIES_EXEC) != 0)	\
 					  ? VM_EXEC : 0))
 
+#ifndef __ASSEMBLY__
+#ifdef CONFIG_XEN
+
+#define INVALID_P2M_ENTRY	(~0UL)
+
+#include <linux/kernel.h>
+#include <asm/hypervisor.h>
+#include <xen/features.h>	// to compile netback, netfront
+typedef unsigned long maddr_t;	// to compile netback, netfront
+
+// XXX hack!
+//     Linux/IA64 uses PG_arch_1.
+//     This hack will be removed once PG_foreign bit is taken.
+//#include <xen/foreign_page.h>
+#ifdef __ASM_XEN_FOREIGN_PAGE_H__
+# error "don't include include/xen/foreign_page.h!"
+#endif
+
+extern struct address_space xen_ia64_foreign_dummy_mapping;
+#define PageForeign(page)	\
+	((page)->mapping == &xen_ia64_foreign_dummy_mapping)
+
+#define SetPageForeign(page, dtor) do {				\
+	set_page_private((page), (unsigned long)(dtor));	\
+	(page)->mapping = &xen_ia64_foreign_dummy_mapping;	\
+	smp_rmb();						\
+} while (0)
+
+#define ClearPageForeign(page) do {	\
+	(page)->mapping = NULL;		\
+	smp_rmb();			\
+	set_page_private((page), 0);	\
+} while (0)
+
+#define PageForeignDestructor(page)	\
+	( (void (*) (struct page *)) page_private(page) )
+
+#define arch_free_page(_page,_order)			\
+({      int foreign = PageForeign(_page);               \
+	if (foreign)                                    \
+		(PageForeignDestructor(_page))(_page);  \
+	foreign;                                        \
+})
+#define HAVE_ARCH_FREE_PAGE
+
+//XXX xen page size != page size
+
+static inline unsigned long
+pfn_to_mfn_for_dma(unsigned long pfn)
+{
+	unsigned long mfn;
+	mfn = HYPERVISOR_phystomach(pfn);
+	BUG_ON(mfn == 0); // XXX
+	BUG_ON(mfn == INVALID_P2M_ENTRY); // XXX
+	BUG_ON(mfn == INVALID_MFN);
+	return mfn;
+}
+
+static inline unsigned long
+phys_to_machine_for_dma(unsigned long phys)
+{
+	unsigned long machine =
+	              pfn_to_mfn_for_dma(phys >> PAGE_SHIFT) << PAGE_SHIFT;
+	machine |= (phys & ~PAGE_MASK);
+	return machine;
+}
+
+static inline unsigned long
+mfn_to_pfn_for_dma(unsigned long mfn)
+{
+	unsigned long pfn;
+	pfn = HYPERVISOR_machtophys(mfn);
+	BUG_ON(pfn == 0);
+	//BUG_ON(pfn == INVALID_M2P_ENTRY);
+	return pfn;
+}
+
+static inline unsigned long
+machine_to_phys_for_dma(unsigned long machine)
+{
+	unsigned long phys =
+	              mfn_to_pfn_for_dma(machine >> PAGE_SHIFT) << PAGE_SHIFT;
+	phys |= (machine & ~PAGE_MASK);
+	return phys;
+}
+
+#define set_phys_to_machine(pfn, mfn) do { } while (0)
+#define xen_machphys_update(mfn, pfn) do { } while (0)
+
+//XXX to compile set_phys_to_machine(vaddr, FOREIGN_FRAME(m))
+#define FOREIGN_FRAME(m)        (INVALID_P2M_ENTRY)
+
+#define mfn_to_pfn(mfn)			(mfn)
+#define mfn_to_virt(mfn)		(__va((mfn) << PAGE_SHIFT))
+#define pfn_to_mfn(pfn)			(pfn)
+#define virt_to_mfn(virt)		(__pa(virt) >> PAGE_SHIFT)
+#define virt_to_machine(virt)		__pa(virt) // for tpmfront.c
+
+#endif /* CONFIG_XEN */
+#endif /* __ASSEMBLY__ */
+
 #endif /* _ASM_IA64_PAGE_H */
diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/pal.h
--- a/include/asm-ia64/pal.h	Thu May 25 03:00:07 2006 +0000
+++ b/include/asm-ia64/pal.h	Fri Jun 02 09:54:29 2006 -0600
@@ -82,6 +82,7 @@
 #ifndef __ASSEMBLY__
 
 #include <linux/types.h>
+#include <asm/processor.h>
 #include <asm/fpu.h>
 
 /*
diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/pgalloc.h
--- a/include/asm-ia64/pgalloc.h	Thu May 25 03:00:07 2006 +0000
+++ b/include/asm-ia64/pgalloc.h	Fri Jun 02 09:54:29 2006 -0600
@@ -126,7 +126,7 @@ static inline void
 static inline void
 pmd_populate(struct mm_struct *mm, pmd_t * pmd_entry, struct page *pte)
 {
-	pmd_val(*pmd_entry) = page_to_phys(pte);
+	pmd_val(*pmd_entry) = page_to_pseudophys(pte);
 }
 
 static inline void
diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/processor.h
--- a/include/asm-ia64/processor.h	Thu May 25 03:00:07 2006 +0000
+++ b/include/asm-ia64/processor.h	Fri Jun 02 09:54:29 2006 -0600
@@ -19,6 +19,7 @@
 #include <asm/kregs.h>
 #include <asm/ptrace.h>
 #include <asm/ustack.h>
+#include <asm/privop.h>
 
 #define IA64_NUM_DBG_REGS	8
 /*
diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/system.h
--- a/include/asm-ia64/system.h	Thu May 25 03:00:07 2006 +0000
+++ b/include/asm-ia64/system.h	Fri Jun 02 09:54:29 2006 -0600
@@ -125,7 +125,7 @@ extern struct ia64_boot_param {
 #define __local_irq_save(x)			\
 do {						\
 	ia64_stop();				\
-	(x) = ia64_getreg(_IA64_REG_PSR);	\
+	(x) = ia64_get_psr_i();			\
 	ia64_stop();				\
 	ia64_rsm(IA64_PSR_I);			\
 } while (0)
@@ -173,7 +173,7 @@ do {								\
 #endif /* !CONFIG_IA64_DEBUG_IRQ */
 
 #define local_irq_enable()	({ ia64_stop(); ia64_ssm(IA64_PSR_I); ia64_srlz_d(); })
-#define local_save_flags(flags)	({ ia64_stop(); (flags) = ia64_getreg(_IA64_REG_PSR); })
+#define local_save_flags(flags)	({ ia64_stop(); (flags) = ia64_get_psr_i(); })
 
 #define irqs_disabled()				\
 ({						\

--=-mW5fLDhrMg8Cvz4+RS4P--

