From: Will Cohen <wcohen@redhat.com>
Date: Mon, 05 May 2003 21:36:03 +0000
Subject: [Linux-ia64] patch for ia64 oprofile support for 2.5.67 kernel
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------040905070502040303020201"
Message-Id: <marc-linux-ia64-105590723705641@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------040905070502040303020201
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

I started with the most recent 2.5 kernel for ia64 I could find, the 
stock 2.5.67 kernel from kernel.org with the  linuxia64.org patch 
(linux-2.5.67-ia64-030416.diff.bz2). Attached is a patch that provides 
oprofile kernel support that works oprofile 0.5.2. It is built on top of 
the perfmon support. For the oprofile to use the performance monitoring 
hardware CONFIG_PERFMON also needs to be enabled in .config. If perfmon 
support is not enabled, oprofile will just supply the basic TIMER_INT 
implementation.

The patch applies cleanly to the 2.5.67 kernel with the linuxia64.org 
patchs. I have built the kernel, with required code compiled in (no 
modules) and booted the resulting kernel successfully on an Intanium 2 
SMP machine. I am sure some revison is required for the patch for the 
2.5.69 kernel. There was some refactoring of the code TIMER_INT code.

Comments?

-Will

--------------040905070502040303020201
Content-Type: text/plain;
 name="linux-2.5.67-ia64-oprofile.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.5.67-ia64-oprofile.patch"

--- linux-2.5.67oprof/arch/ia64/kernel/time.c.orig	2003-05-05 12:34:14.000000000 -0400
+++ linux-2.5.67oprof/arch/ia64/kernel/time.c	2003-05-05 12:37:02.000000000 -0400
@@ -17,6 +17,7 @@
 #include <linux/time.h>
 #include <linux/interrupt.h>
 #include <linux/efi.h>
+#include <linux/profile.h>
 
 #include <asm/delay.h>
 #include <asm/hw_irq.h>
@@ -35,30 +36,6 @@
 
 #endif
 
-static void
-do_profile (unsigned long ip)
-{
-	extern unsigned long prof_cpu_mask;
-	extern char _stext;
-
-	if (!prof_buffer)
-		return;
-
-	if (!((1UL << smp_processor_id()) & prof_cpu_mask))
-		return;
-
-	ip -= (unsigned long) &_stext;
-	ip >>= prof_shift;
-	/*
-	 * Don't ignore out-of-bounds IP values silently, put them into the last
-	 * histogram slot, so if present, they will show up as a sharp peak.
-	 */
-	if (ip > prof_len - 1)
-		ip = prof_len - 1;
-
-	atomic_inc((atomic_t *) &prof_buffer[ip]);
-}
-
 /*
  * Return the number of nano-seconds that elapsed since the last update to jiffy.  The
  * xtime_lock must be at least read-locked when calling this routine.
@@ -186,14 +163,9 @@
 		printk(KERN_ERR "Oops: timer tick before it's due (itc=%lx,itm=%lx)\n",
 		       ia64_get_itc(), new_itm);
 
+	ia64_do_profile(regs);
+
 	while (1) {
-		/*
-		 * Do kernel PC profiling here.  We multiply the instruction number by
-		 * four so that we can use a prof_shift of 2 to get instruction-level
-		 * instead of just bundle-level accuracy.
-		 */
-		if (!user_mode(regs))
-			do_profile(regs->cr_iip + 4*ia64_psr(regs)->ri);
 
 #ifdef CONFIG_SMP
 		smp_do_timer(regs);
--- linux-2.5.67oprof/arch/ia64/kernel/perfmon.c.orig	2003-05-05 14:51:47.000000000 -0400
+++ linux-2.5.67oprof/arch/ia64/kernel/perfmon.c	2003-05-05 14:52:05.000000000 -0400
@@ -132,9 +132,6 @@
 
 #define PFM_REG_RETFLAG_SET(flags, val)	do { flags &= ~PFM_REG_RETFL_MASK; flags |= (val); } while(0)
 
-#define PFM_CPUINFO_CLEAR(v)	__get_cpu_var(pfm_syst_info) &= ~(v)
-#define PFM_CPUINFO_SET(v)	__get_cpu_var(pfm_syst_info) |= (v)
-
 /*
  * debugging
  */
--- linux-2.5.67oprof/arch/ia64/Makefile.orig	2003-05-05 12:34:14.000000000 -0400
+++ linux-2.5.67oprof/arch/ia64/Makefile	2003-05-05 12:46:20.000000000 -0400
@@ -56,6 +56,8 @@
 drivers-$(CONFIG_IA64_HP_SIM)	+= arch/ia64/hp/sim/
 drivers-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/
 drivers-$(CONFIG_IA64_GENERIC)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/ arch/ia64/hp/sim/
+# must be linked after kernel/
+drivers-$(CONFIG_OPROFILE)	+= arch/ia64/oprofile/
 
 boot := arch/ia64/boot
 tools := arch/ia64/tools
--- linux-2.5.67oprof/arch/ia64/oprofile/Kconfig.orig	2003-05-05 13:47:55.000000000 -0400
+++ linux-2.5.67oprof/arch/ia64/oprofile/Kconfig	2003-05-05 14:02:34.000000000 -0400
@@ -0,0 +1,23 @@
+
+menu "Profiling support"
+	depends on EXPERIMENTAL
+
+config PROFILING
+	bool "Profiling support (EXPERIMENTAL)"
+	help
+	  Say Y here to enable the extended profiling support mechanisms used
+	  by profilers such as OProfile.
+	  
+
+config OPROFILE
+	tristate "OProfile system profiling (EXPERIMENTAL)"
+	depends on PROFILING
+	help
+	  OProfile is a profiling system capable of profiling the
+	  whole system, include the kernel, kernel modules, libraries,
+	  and applications.
+
+	  If unsure, say N.
+
+endmenu
+
--- linux-2.5.67oprof/arch/ia64/oprofile/init.c.orig	2003-05-05 12:37:21.000000000 -0400
+++ linux-2.5.67oprof/arch/ia64/oprofile/init.c	2003-05-05 12:37:21.000000000 -0400
@@ -0,0 +1,29 @@
+/**
+ * @file init.c
+ *
+ * @remark Copyright 2002-2003 OProfile authors
+ * @remark Read the file COPYING
+ *
+ * @author John Levon <levon@movementarian.org>
+ * @author Will Cohen <wcohen@redhat.com>
+ */
+
+#include <linux/kernel.h>
+#include <linux/oprofile.h>
+#include <linux/init.h>
+ 
+/* We support CPUs that have performance counters like the IA64
+ * with irq mode samples.
+ */
+ 
+extern int irq_init(struct oprofile_operations ** ops);
+extern void timer_init(struct oprofile_operations ** ops);
+
+int __init oprofile_arch_init(struct oprofile_operations ** ops)
+{
+#ifdef CONFIG_PERFMON
+	if (!irq_init(ops))
+#endif
+		timer_init(ops);
+	return 0;
+}
--- linux-2.5.67oprof/arch/ia64/oprofile/irq_int.c.orig	2003-05-05 12:37:21.000000000 -0400
+++ linux-2.5.67oprof/arch/ia64/oprofile/irq_int.c	2003-05-05 14:53:51.000000000 -0400
@@ -0,0 +1,253 @@
+/**
+ * @file irq_int.c
+ *
+ * @remark Copyright 2002-2003 OProfile authors
+ * @remark Read the file COPYING
+ *
+ * @author John Levon
+ * @author Will Cohen
+ */
+
+#include <linux/config.h>
+#include <linux/sched.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/notifier.h>
+#include <linux/smp.h>
+#include <linux/oprofile.h>
+#include <linux/pm.h>
+#include <asm/ptrace.h>
+#include <asm/bitops.h>
+#include <asm/processor.h>
+ 
+#include "op_counter.h"
+#include "op_ia64_model.h"
+
+unsigned long op_pmd_mask = IA64_2_PMD_MASK_VAL;
+ 
+static volatile struct op_ia64_model_spec const * model;
+static struct op_msrs cpu_msrs[NR_CPUS];
+ 
+static int irq_start(void);
+static void irq_stop(void);
+
+static void
+irq_pmu_interrupt_handler(int irq, void *arg, struct pt_regs *regs)
+{
+	u64 pmc0 = ia64_get_pmc(0);
+
+	if (IA64_PMU_FREEZE(pmc0)) {
+		uint cpu = smp_processor_id();
+
+		(model->check_ctrs(cpu, &cpu_msrs[cpu], regs));
+		/* unfreeze PMU */
+		ia64_set_pmc(0, 0);
+		ia64_srlz_d();
+	}
+}
+
+
+static pfm_intr_handler_desc_t irq_handler={
+	handler: irq_pmu_interrupt_handler
+};
+
+ 
+static void irq_save_registers(struct op_msrs * msrs)
+{
+	unsigned int const nr_ctrs = model->num_counters;
+	unsigned int const nr_ctrls = model->num_controls; 
+	struct op_msr_group * counters = &msrs->counters;
+	struct op_msr_group * controls = &msrs->controls;
+	int i;
+
+	for (i = 0; i < nr_ctrs; ++i) {
+		counters->saved[i].low = get_pmd(i);
+	}
+ 
+	for (i = 0; i < nr_ctrls; ++i) {
+		controls->saved[i].low = get_pmc(i);
+	}
+}
+
+ 
+static void irq_cpu_setup(void * dummy)
+{
+	int cpu = smp_processor_id();
+	struct op_msrs * msrs = &cpu_msrs[cpu];
+	model->fill_in_addresses(msrs);
+	irq_save_registers(msrs);
+	spin_lock(&oprofilefs_lock);
+	model->setup_ctrs(msrs);
+	spin_unlock(&oprofilefs_lock);
+}
+ 
+
+static int irq_setup(void)
+{
+	int ret;
+
+	/*
+	 * first we must reserve all the CPUs for our full system-wide
+	 * session.
+	 */
+	ret = pfm_install_alternate_syswide_subsystem(&irq_handler);
+	if (ret) {
+		printk(KERN_INFO "cannot reserve alternate system wide session: %d\n",
+		       ret);
+		return 1;
+	}
+	printk(KERN_INFO "succesfully allocated all PMUs for system wide session, handler redirected\n");
+	/*
+	 * upon return, you are guaranteed:
+	 * 	- that no perfmon context was alive 
+	 * 	- no new perfmon context will be created until you unreserve
+	 * 	- any new overflow interrupt will go to our handler
+	 *
+	 * This call only does software reservation, the PMU is not touched
+	 * at all. 
+	 *
+	 * For 2.4 kernels, the PMU is guaranteed frozen on all CPUs at this point.
+	 */
+	printk(KERN_INFO "succesfully install new PMU overflow handler\n");
+
+	/* local work with the PMU can begin here */
+
+	smp_call_function(irq_cpu_setup, NULL, 0, 1);
+	irq_cpu_setup(0);
+	return 0;
+}
+
+
+static void irq_restore_registers(struct op_msrs * msrs)
+{
+	unsigned int const nr_ctrs = model->num_counters;
+	unsigned int const nr_ctrls = model->num_controls; 
+	struct op_msr_group * counters = &msrs->counters;
+	struct op_msr_group * controls = &msrs->controls;
+	int i;
+
+	for (i = 0; i < nr_ctrls; ++i) {
+		set_pmc(controls->saved[i].low, i);
+	}
+ 
+	for (i = 0; i < nr_ctrs; ++i) {
+		set_pmd(counters->saved[i].low, i);
+	}
+}
+ 
+
+static void irq_cpu_shutdown(void * dummy)
+{
+	int cpu = smp_processor_id();
+	struct op_msrs * msrs = &cpu_msrs[cpu];
+ 
+	irq_restore_registers(msrs);
+}
+
+ 
+static void irq_shutdown(void)
+{
+	printk(KERN_INFO "entering irq_shutdown()\n");
+	/*
+	 * this call will:
+	 * 	- remove our local PMU interrupt handler
+	 * 	- release our system wide session on all CPU indicated by the provided cpu_mask
+	 *
+	 * The caller must leave the PMU as follows (i.e. as it was when this got started):
+	 * 	- frozen on all CPUs
+	 * 	- local_cpu_data->pfm_dcr_pp = 0 and local_cpu_data->pfm_syst_wide = 0
+	 */
+	smp_call_function(irq_cpu_shutdown, NULL, 0, 1);
+	irq_cpu_shutdown(0);
+	pfm_remove_alternate_syswide_subsystem(&irq_handler);
+}
+
+ 
+static void irq_cpu_start(void * dummy)
+{
+	struct op_msrs const * msrs = &cpu_msrs[smp_processor_id()];
+	model->start(msrs);
+}
+ 
+
+static int irq_start(void)
+{
+	smp_call_function(irq_cpu_start, NULL, 0, 1);
+	irq_cpu_start(0);
+	return 0;
+}
+ 
+ 
+static void irq_cpu_stop(void * dummy)
+{
+	struct op_msrs const * msrs = &cpu_msrs[smp_processor_id()];
+	model->stop(msrs);
+}
+ 
+ 
+static void irq_stop(void)
+{
+	smp_call_function(irq_cpu_stop, NULL, 0, 1);
+	irq_cpu_stop(0);
+}
+
+
+struct op_counter_config counter_config[OP_MAX_COUNTER];
+
+static int irq_create_files(struct super_block * sb, struct dentry * root)
+{
+	int i;
+
+	for (i = 0; i < model->num_counters; ++i) {
+		struct dentry * dir;
+		char buf[2];
+ 
+		snprintf(buf, 2, "%d", i);
+		dir = oprofilefs_mkdir(sb, root, buf);
+		oprofilefs_create_ulong(sb, dir, "enabled", &counter_config[i].enabled); 
+		oprofilefs_create_ulong(sb, dir, "event", &counter_config[i].event); 
+		oprofilefs_create_ulong(sb, dir, "count", &counter_config[i].count); 
+		oprofilefs_create_ulong(sb, dir, "unit_mask", &counter_config[i].unit_mask); 
+		oprofilefs_create_ulong(sb, dir, "kernel", &counter_config[i].kernel); 
+		oprofilefs_create_ulong(sb, dir, "user", &counter_config[i].user); 
+	}
+
+	return 0;
+}
+ 
+ 
+struct oprofile_operations irq_ops = {
+	.create_files 	= irq_create_files,
+	.setup 		= irq_setup,
+	.shutdown	= irq_shutdown,
+	.start		= irq_start,
+	.stop		= irq_stop
+};
+ 
+ 
+int __init irq_init(struct oprofile_operations ** ops)
+{
+	__u8 family = local_cpu_data->family;
+
+
+	/* FIXME: There should be a bit more checking here. */
+	switch (family) {
+	case 0x07: /* Itanium */
+		irq_ops.cpu_type = "ia64/itanium";
+		model = &op_ia64_1_spec;
+		break;
+	case 0x1f: /* Itanium 2 */
+		irq_ops.cpu_type = "ia64/itanium2";
+		model = &op_ia64_2_spec;
+		break;
+	default:
+		irq_ops.cpu_type = "ia64/ia64";
+		model = &op_ia64_spec;
+		break;
+	}
+
+	*ops = &irq_ops;
+	op_pmd_mask = model->pmd_mask;
+	printk(KERN_INFO "oprofile: using IRQ interrupt.\n");
+	return 1;
+}
--- linux-2.5.67oprof/arch/ia64/oprofile/Makefile.orig	2003-05-05 12:37:21.000000000 -0400
+++ linux-2.5.67oprof/arch/ia64/oprofile/Makefile	2003-05-05 14:38:53.000000000 -0400
@@ -0,0 +1,11 @@
+# arch/ia64/oprofile/Makefile
+
+obj-$(CONFIG_OPROFILE) += oprofile.o
+
+DRIVER_OBJS = $(addprefix ../../../drivers/oprofile/, \
+		oprof.o cpu_buffer.o buffer_sync.o \
+		event_buffer.o oprofile_files.o \
+		oprofilefs.o oprofile_stats.o )
+
+oprofile-y				:= $(DRIVER_OBJS) init.o timer_int.o
+oprofile-$(CONFIG_PERFMON)	 	+= irq_int.o op_model_ia64.o
--- linux-2.5.67oprof/arch/ia64/oprofile/op_counter.h.orig	2003-05-05 12:37:21.000000000 -0400
+++ linux-2.5.67oprof/arch/ia64/oprofile/op_counter.h	2003-05-05 12:37:21.000000000 -0400
@@ -0,0 +1,29 @@
+/**
+ * @file op_counter.h
+ *
+ * @remark Copyright 2002 OProfile authors
+ * @remark Read the file COPYING
+ *
+ * @author John Levon
+ */
+ 
+#ifndef OP_COUNTER_H
+#define OP_COUNTER_H
+ 
+#define OP_MAX_COUNTER 8
+ 
+/* Per-perfctr configuration as set via
+ * oprofilefs.
+ */
+struct op_counter_config {
+        unsigned long count;
+        unsigned long enabled;
+        unsigned long event;
+        unsigned long kernel;
+        unsigned long user;
+        unsigned long unit_mask;
+};
+
+extern struct op_counter_config counter_config[];
+
+#endif /* OP_COUNTER_H */
--- linux-2.5.67oprof/arch/ia64/oprofile/op_ia64_model.h.orig	2003-05-05 12:37:21.000000000 -0400
+++ linux-2.5.67oprof/arch/ia64/oprofile/op_ia64_model.h	2003-05-05 12:37:21.000000000 -0400
@@ -0,0 +1,80 @@
+/**
+ * @file op_ia64_model.h
+ * interface to ia64 model-specific MSR operations
+ *
+ * @remark Copyright 2002-2003 OProfile authors
+ * @remark Read the file COPYING
+ *
+ * @author Graydon Hoare
+ * @author Will Cohen
+ */
+
+#ifndef OP_IA64_MODEL_H
+#define OP_IA64_MODEL_H
+
+#include <asm/perfmon.h>
+
+/* the Pentium IV has quite a lot of control registers */
+#define MAX_MSR 63
+
+/* Valid bits in PMD registers */
+#define IA64_1_PMD_MASK_VAL	((1UL << 32) - 1)
+#define IA64_2_PMD_MASK_VAL	((1UL << 47) - 1)
+
+#define IA64_PMU_FREEZE(v)	((v) & (~0x1UL))
+
+/* performance counters are in pairs: pmcN and pmdN.  The pmc register acts
+ * as the event selection; the pmd register is the counter. */
+#define perf_reg(c)	((c)+4)
+
+#define pmd_overflowed(r,c) ((r) & (1 << perf_reg(c)))
+#define set_pmd_neg(v,c) do { \
+	ia64_set_pmd(perf_reg(c), -(ulong)(v) & op_pmd_mask); \
+	ia64_srlz_d(); } while (0)
+#define set_pmd(v,c) do { \
+	ia64_set_pmd(perf_reg(c), (v) & op_pmd_mask); \
+	ia64_srlz_d(); } while (0)
+#define set_pmc(v,c) do { ia64_set_pmc(perf_reg(c), (v)); ia64_srlz_d(); } while (0)
+#define get_pmd(c) ia64_get_pmd(perf_reg(c))
+#define get_pmc(c) ia64_get_pmc(perf_reg(c))
+ 
+struct op_saved_msr {
+	unsigned int high;
+	unsigned int low;
+};
+
+struct op_msr_group {
+	unsigned int addrs[MAX_MSR];
+	struct op_saved_msr saved[MAX_MSR];
+};
+
+struct op_msrs {
+	struct op_msr_group counters;
+	struct op_msr_group controls;
+};
+
+struct pt_regs;
+
+/* The model vtable abstracts the differences between
+ * various ia64 CPU model's perfctr support.
+ */
+struct op_ia64_model_spec {
+	unsigned int const num_counters;
+	unsigned int const num_controls;
+	unsigned long const pmd_mask;
+	void (*fill_in_addresses)(struct op_msrs * const msrs);
+	void (*setup_ctrs)(struct op_msrs const * const msrs);
+	int (*check_ctrs)(unsigned int const cpu, 
+		struct op_msrs const * const msrs,
+		struct pt_regs * const regs);
+	void (*start)(struct op_msrs const * const msrs);
+	void (*stop)(struct op_msrs const * const msrs);
+};
+
+extern unsigned long op_pmd_mask;
+
+extern struct op_ia64_model_spec const op_ia64_spec;
+extern struct op_ia64_model_spec const op_ia64_1_spec;
+extern struct op_ia64_model_spec const op_ia64_2_spec;
+
+#endif /* OP_IA64_MODEL_H */
--- linux-2.5.67oprof/arch/ia64/oprofile/op_model_ia64.c.orig	2003-05-05 12:37:21.000000000 -0400
+++ linux-2.5.67oprof/arch/ia64/oprofile/op_model_ia64.c	2003-05-05 12:37:21.000000000 -0400
@@ -0,0 +1,210 @@
+/**
+ * @file op_model_ia64.c
+ * ia64 model-specific MSR operations
+ *
+ * @remark Copyright 2002-2003 OProfile authors
+ * @remark Read the file COPYING
+ *
+ * @author John Levon
+ * @author Philippe Elie
+ * @author Graydon Hoare
+ * @author Will Cohen
+ */
+
+#include <linux/oprofile.h>
+#include <linux/sched.h>
+#include <linux/smp.h>
+#include <asm/ptrace.h>
+#include <asm/processor.h>
+#include <asm/perfmon.h>
+ 
+#include "op_ia64_model.h"
+#include "op_counter.h"
+
+#define NUM_COUNTERS 4
+#define NUM_CONTROLS 4
+
+static unsigned long reset_value[NUM_COUNTERS];
+
+static void ia64_fill_in_addresses(struct op_msrs * const msrs)
+{
+	/* empty */
+}
+
+/* ---------------- PMU setup ------------------ */
+
+/* This is kind of artificial.  The proc interface might really want to
+ * accept register values directly.  There are other features not exposed 
+ * by this limited interface.  Of course that might require all sorts of
+ * validity checking??? */
+static void
+pmc_fill_in(ulong *val, u8 kernel, u8 user, u8 event, u8 um)
+{
+	/* enable interrupt generation */
+	*val |= (1<<5);
+
+	/* setup as a privileged monitor */
+	*val |= (1<<6);
+
+	/* McKinley requires pmc4 to have bit 23 set (enable PMU).
+	 * It is supposedly ignored in other pmc registers.
+	 * Try assuming it's ignored in Itanium, too, and just
+	 * set it for everyone.
+	 */
+
+	*val |= (1<<23);
+
+	/* enable/disable chosen OS and USR counting */
+	(user)   ? (*val |= (1<<3))
+		 : (*val &= ~(1<<3));
+
+	(kernel) ? (*val |= (1<<0))
+		 : (*val &= ~(1<<0));
+
+	/* what are we counting ? */
+	*val &= ~(0x7f << 8);
+	*val |= ((event & 0x7f) << 8);
+	*val &= ~(0xf << 16);
+	*val |= ((um & 0xf) << 16);
+}
+
+
+static void ia64_setup_ctrs(struct op_msrs const * const msrs)
+{
+	ulong pmc_val;
+	int i;
+ 
+	/* clear all counters */
+	for (i = 0 ; i < NUM_CONTROLS; ++i) {
+		set_pmd(0,i);
+	}
+	
+	/* avoid a false detection of ctr overflows in IRQ handler */
+	for (i = 0; i < NUM_COUNTERS; ++i) {
+	  /* CTR_WRITE(1, msrs, i); */
+	}
+
+	/* Make sure that the pmu  hardware is turn on */
+	pmc_val = get_pmc(0);
+	pmc_val |= (1<<23);
+	set_pmc(pmc_val, 0);
+
+	/* enable active counters */
+	for (i = 0; i < NUM_COUNTERS; ++i) {
+		if (counter_config[i].event) {
+			pmc_val = 0;
+
+			reset_value[i] = counter_config[i].count;
+
+			set_pmd_neg(reset_value[i], i);
+
+			pmc_fill_in(&pmc_val, counter_config[i].kernel, 
+				counter_config[i].user,
+				counter_config[i].event, 
+				counter_config[i].unit_mask);
+
+			set_pmc(pmc_val, i);
+		} else {
+			reset_value[i] = 0;
+		}
+	}
+
+	/* unfreeze PMU */
+	ia64_set_pmc(0, 0);
+	ia64_srlz_d();
+}
+
+
+static int ia64_check_ctrs(unsigned int const cpu, 
+			      struct op_msrs const * const msrs, 
+			      struct pt_regs * const regs)
+{
+	int i;
+	u64 pmc0;
+	unsigned long eip = instruction_pointer(regs);
+	int is_kernel = !user_mode(regs);
+
+	pmc0 = ia64_get_pmc(0);
+
+	for (i = 0 ; i < NUM_COUNTERS ; ++i) {
+		if (pmd_overflowed(pmc0, i)) {
+			oprofile_add_sample(eip, is_kernel, i, cpu);
+			set_pmd_neg(reset_value[i], i);
+		}
+	}
+	return 1;
+}
+
+ 
+static void ia64_start(struct op_msrs const * const msrs)
+{
+	/* turn on profiling */
+	PFM_CPUINFO_SET(PFM_CPUINFO_DCR_PP | PFM_CPUINFO_SYST_WIDE);
+
+	/* start monitoring at kernel level */
+	__asm__ __volatile__ ("ssm psr.pp;;"::: "memory");
+
+	/* enable dcr pp */
+	ia64_set_dcr(ia64_get_dcr()|IA64_DCR_PP);
+
+	ia64_srlz_i();
+
+	/* unfreeze PMU */
+	ia64_set_pmc(0, 0);
+	ia64_srlz_d();
+}
+
+
+static void ia64_stop(struct op_msrs const * const msrs)
+{
+	/* freeze PMU */
+	ia64_set_pmc(0, 1);
+	ia64_srlz_d();
+
+	/* disable the dcr pp */
+	ia64_set_dcr(ia64_get_dcr() & ~IA64_DCR_PP);
+
+	/* stop in my current state */
+	 __asm__ __volatile__ ("rsm psr.pp;;"::: "memory");
+
+	ia64_srlz_i();
+
+	/* turn off profiling */
+	PFM_CPUINFO_CLEAR(PFM_CPUINFO_DCR_PP | PFM_CPUINFO_SYST_WIDE);
+}
+
+
+struct op_ia64_model_spec const op_ia64_spec = {
+	.num_counters = NUM_COUNTERS,
+	.num_controls = NUM_CONTROLS,
+	.pmd_mask = IA64_2_PMD_MASK_VAL,
+	.fill_in_addresses = &ia64_fill_in_addresses,
+	.setup_ctrs = &ia64_setup_ctrs,
+	.check_ctrs = &ia64_check_ctrs,
+	.start = &ia64_start,
+	.stop = &ia64_stop,
+};
+
+
+struct op_ia64_model_spec const op_ia64_1_spec = {
+	.num_counters = NUM_COUNTERS,
+	.num_controls = NUM_CONTROLS,
+	.pmd_mask = IA64_1_PMD_MASK_VAL,
+	.fill_in_addresses = &ia64_fill_in_addresses,
+	.setup_ctrs = &ia64_setup_ctrs,
+	.check_ctrs = &ia64_check_ctrs,
+	.start = &ia64_start,
+	.stop = &ia64_stop
+};
+
+
+struct op_ia64_model_spec const op_ia64_2_spec = {
+	.num_counters = NUM_COUNTERS,
+	.num_controls = NUM_CONTROLS,
+	.pmd_mask = IA64_2_PMD_MASK_VAL,
+	.fill_in_addresses = &ia64_fill_in_addresses,
+	.setup_ctrs = &ia64_setup_ctrs,
+	.check_ctrs = &ia64_check_ctrs,
+	.start = &ia64_start,
+	.stop = &ia64_stop
+};
--- linux-2.5.67oprof/arch/ia64/oprofile/timer_int.c.orig	2003-05-05 12:37:21.000000000 -0400
+++ linux-2.5.67oprof/arch/ia64/oprofile/timer_int.c	2003-05-05 12:37:21.000000000 -0400
@@ -0,0 +1,57 @@
+/**
+ * @file timer_int.c
+ *
+ * @remark Copyright 2002 OProfile authors
+ * @remark Read the file COPYING
+ *
+ * @author John Levon <levon@movementarian.org>
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/notifier.h>
+#include <linux/smp.h>
+#include <linux/irq.h>
+#include <linux/oprofile.h>
+#include <asm/ptrace.h>
+ 
+static int timer_notify(struct notifier_block * self, unsigned long val, void * data)
+{
+	struct pt_regs * regs = (struct pt_regs *)data;
+	int cpu = smp_processor_id();
+ 	unsigned long eip = instruction_pointer(regs);
+ 
+	oprofile_add_sample(eip, !user_mode(regs), 0, cpu);
+	return 0;
+}
+ 
+ 
+static struct notifier_block timer_notifier = {
+	.notifier_call	= timer_notify,
+};
+ 
+
+static int timer_start(void)
+{
+	return register_profile_notifier(&timer_notifier);
+}
+
+
+static void timer_stop(void)
+{
+	unregister_profile_notifier(&timer_notifier);
+}
+
+
+static struct oprofile_operations timer_ops = {
+	.start	= timer_start,
+	.stop	= timer_stop,
+	.cpu_type = "timer"
+};
+
+ 
+void __init timer_init(struct oprofile_operations ** ops)
+{
+	*ops = &timer_ops;
+	printk(KERN_INFO "oprofile: using timer interrupt.\n");
+}
--- linux-2.5.67oprof/arch/ia64/Kconfig.orig	2003-05-05 13:53:58.000000000 -0400
+++ linux-2.5.67oprof/arch/ia64/Kconfig	2003-05-05 13:53:16.000000000 -0400
@@ -782,6 +782,7 @@
 
 source "arch/ia64/hp/sim/Kconfig"
 
+source "arch/ia64/oprofile/Kconfig"
 
 menu "Kernel hacking"
 
--- linux-2.5.67oprof/include/asm-ia64/hw_irq.h.orig	2003-04-07 13:31:18.000000000 -0400
+++ linux-2.5.67oprof/include/asm-ia64/hw_irq.h	2003-05-05 12:37:02.000000000 -0400
@@ -9,6 +9,7 @@
 #include <linux/interrupt.h>
 #include <linux/sched.h>
 #include <linux/types.h>
+#include <linux/profile.h>
 
 #include <asm/machvec.h>
 #include <asm/ptrace.h>
@@ -148,4 +149,46 @@
 	return platform_local_vector_to_irq(vec);
 }
 
+extern char _stext, _etext;
+
+/*
+ * The profiling function is SMP safe. (nothing can mess
+ * around with "current", and the profiling counters are
+ * updated with atomic operations). This is especially
+ * useful with a profiling multiplier != 1
+ */
+static inline void ia64_do_profile(struct pt_regs * regs)
+{
+	unsigned long eip;
+	extern unsigned long prof_cpu_mask;
+ 
+	profile_hook(regs);
+ 
+	if (user_mode(regs))
+		return;
+ 
+	if (!prof_buffer)
+		return;
+
+	eip = instruction_pointer(regs);
+ 
+	/*
+	 * Only measure the CPUs specified by /proc/irq/prof_cpu_mask.
+	 * (default is all CPUs.)
+	 */
+	if (!((1<<smp_processor_id()) & prof_cpu_mask))
+		return;
+
+	eip -= (unsigned long) &_stext;
+	eip >>= prof_shift;
+	/*
+	 * Don't ignore out-of-bounds EIP values silently,
+	 * put them into the last histogram slot, so if
+	 * present, they will show up as a sharp peak.
+	 */
+	if (eip > prof_len-1)
+		eip = prof_len-1;
+	atomic_inc((atomic_t *)&prof_buffer[eip]);
+}
+
 #endif /* _ASM_IA64_HW_IRQ_H */
--- linux-2.5.67oprof/include/asm-ia64/perfmon.h.orig	2003-04-07 13:31:45.000000000 -0400
+++ linux-2.5.67oprof/include/asm-ia64/perfmon.h	2003-05-05 14:52:04.000000000 -0400
@@ -199,6 +199,9 @@
 #define PFM_CPUINFO_EXCL_IDLE	0x4	/* the system wide session excludes the idle task */
 
 
+#define PFM_CPUINFO_CLEAR(v)	__get_cpu_var(pfm_syst_info) &= ~(v)
+#define PFM_CPUINFO_SET(v)	__get_cpu_var(pfm_syst_info) |= (v)
+
 #endif /* __KERNEL__ */
 
 #endif /* _ASM_IA64_PERFMON_H */
--- linux-2.5.67oprof/include/asm-ia64/ptrace.h.orig	2003-05-05 12:34:15.000000000 -0400
+++ linux-2.5.67oprof/include/asm-ia64/ptrace.h	2003-05-05 12:37:02.000000000 -0400
@@ -214,6 +214,7 @@
 };
 
 #ifdef __KERNEL__
+#define instruction_pointer(regs) ((regs)->cr_iip)
   /* given a pointer to a task_struct, return the user's pt_regs */
 # define ia64_task_regs(t)		(((struct pt_regs *) ((char *) (t) + IA64_STK_OFFSET)) - 1)
 # define ia64_psr(regs)			((struct ia64_psr *) &(regs)->cr_ipsr)

--------------040905070502040303020201--


