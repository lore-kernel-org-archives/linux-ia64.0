From: Keith Owens <kaos@sgi.com>
Date: Wed, 02 Nov 2005 03:29:21 +0000
Subject: [Patch 2.6.14] Extend notify_die() hooks for IA64
Message-Id: <7073.1130902161@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5844.1130898771@kao2.melbourne.sgi.com>
In-Reply-To: <5844.1130898771@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

notify_die() added for MCA_{MONARCH,SLAVE,RENDEZVOUS}_{ENTER,PROCESS,LEAVE} and
INIT_{MONARCH,SLAVE}_{ENTER,PROCESS,LEAVE}.  We need multiple
notification points for these events because they can take many seconds
to run which has nasty effects on the behaviour of the rest of the
system.

DIE_SS replaced by a generic DIE_FAULT which checks the vector number,
to allow interception of faults other than SS.

DIE_MACHINE_{HALT,RESTART} added to allow last minute close down
processing, especially when the halt/restart routines are called from
error handlers.

DIE_OOPS added.

The check for kprobe's break numbers has been moved from traps.c to
kprobes.c, allowing DIE_BREAK to be used for any additional break
numbers, i.e. it is no longer kprobes specific.

Hooks for kernel debuggers and kernel dumpers added, ENTER and LEAVE.
Both of these disable the system for long periods which impact on
watchdogs and heartbeat systems in general.  More patches to come that
use these events to reset watchdogs and heartbeats.

unregister_die_notifier() added and both routines exported.  Requested
by Dean Nelson.

Lock removed from {un,}register_die_notifier.  notifier_chain_register()
already takes a lock.  Also the generic notifier chain locking is being
reworked to distinguish between callbacks that can block and those that
cannot, the lock in {un,}register_die_notifier would interfere with
that change.  http://marc.theaimsgroup.com/?l=linux-kernel&m3018709002036&w=2

Leading white space removed from arch/ia64/kernel/kprobes.c.

Signed-off-by: Keith Owens <kaos@sgi.com>

---

Resend, forgot the the signed off line.

 arch/ia64/kernel/kprobes.c |   32 ++++++------
 arch/ia64/kernel/mca.c     |  120 +++++++++++++++++++++++++++++++++++----------
 arch/ia64/kernel/process.c |    6 ++
 arch/ia64/kernel/traps.c   |   44 +++++++---------
 include/asm-ia64/kdebug.h  |   30 ++++++++++-
 5 files changed, 167 insertions(+), 65 deletions(-)

Index: linux/arch/ia64/kernel/mca.c
=================================--- linux.orig/arch/ia64/kernel/mca.c	2005-11-02 12:22:42.734161437 +1100
+++ linux/arch/ia64/kernel/mca.c	2005-11-02 12:23:04.327859153 +1100
@@ -51,6 +51,9 @@
  *
  * 2005-08-12 Keith Owens <kaos@sgi.com>
  *	      Convert MCA/INIT handlers to use per event stacks and SAL/OS state.
+ *
+ * 2005-10-07 Keith Owens <kaos@sgi.com>
+ *	      Add notify_die() hooks.
  */
 #include <linux/config.h>
 #include <linux/types.h>
@@ -58,7 +61,6 @@
 #include <linux/sched.h>
 #include <linux/interrupt.h>
 #include <linux/irq.h>
-#include <linux/kallsyms.h>
 #include <linux/smp_lock.h>
 #include <linux/bootmem.h>
 #include <linux/acpi.h>
@@ -69,6 +71,7 @@
 #include <linux/workqueue.h>
 
 #include <asm/delay.h>
+#include <asm/kdebug.h>
 #include <asm/machvec.h>
 #include <asm/meminit.h>
 #include <asm/page.h>
@@ -132,6 +135,14 @@ extern void salinfo_log_wakeup(int type,
 
 static int mca_init;
 
+
+static void inline
+ia64_mca_spin(const char *func)
+{
+	printk(KERN_EMERG "%s: spinning here, not returning to SAL\n", func);
+	while (1)
+		cpu_relax();
+}
 /*
  * IA64_MCA log support
  */
@@ -528,13 +539,16 @@ ia64_mca_wakeup_all(void)
  *  Outputs :   None
  */
 static irqreturn_t
-ia64_mca_rendez_int_handler(int rendez_irq, void *arg, struct pt_regs *ptregs)
+ia64_mca_rendez_int_handler(int rendez_irq, void *arg, struct pt_regs *regs)
 {
 	unsigned long flags;
 	int cpu = smp_processor_id();
 
 	/* Mask all interrupts */
 	local_irq_save(flags);
+	if (notify_die(DIE_MCA_RENDZVOUS_ENTER, "MCA", regs, 0, 0, 0)
+			= NOTIFY_STOP)
+		ia64_mca_spin(__FUNCTION__);
 
 	ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_DONE;
 	/* Register with the SAL monarch that the slave has
@@ -542,10 +556,18 @@ ia64_mca_rendez_int_handler(int rendez_i
 	 */
 	ia64_sal_mc_rendez();
 
+	if (notify_die(DIE_MCA_RENDZVOUS_PROCESS, "MCA", regs, 0, 0, 0)
+			= NOTIFY_STOP)
+		ia64_mca_spin(__FUNCTION__);
+
 	/* Wait for the monarch cpu to exit. */
 	while (monarch_cpu != -1)
 	       cpu_relax();	/* spin until monarch leaves */
 
+	if (notify_die(DIE_MCA_RENDZVOUS_LEAVE, "MCA", regs, 0, 0, 0)
+			= NOTIFY_STOP)
+		ia64_mca_spin(__FUNCTION__);
+
 	/* Enable all interrupts */
 	local_irq_restore(flags);
 	return IRQ_HANDLED;
@@ -935,6 +957,9 @@ ia64_mca_handler(struct pt_regs *regs, s
 	oops_in_progress = 1;	/* FIXME: make printk NMI/MCA/INIT safe */
 	previous_current = ia64_mca_modify_original_stack(regs, sw, sos, "MCA");
 	monarch_cpu = cpu;
+	if (notify_die(DIE_MCA_MONARCH_ENTER, "MCA", regs, 0, 0, 0)
+			= NOTIFY_STOP)
+		ia64_mca_spin(__FUNCTION__);
 	ia64_wait_for_slaves(cpu);
 
 	/* Wakeup all the processors which are spinning in the rendezvous loop.
@@ -944,6 +969,9 @@ ia64_mca_handler(struct pt_regs *regs, s
 	 * spinning in SAL does not work.
 	 */
 	ia64_mca_wakeup_all();
+	if (notify_die(DIE_MCA_MONARCH_PROCESS, "MCA", regs, 0, 0, 0)
+			= NOTIFY_STOP)
+		ia64_mca_spin(__FUNCTION__);
 
 	/* Get the MCA error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA);
@@ -962,6 +990,9 @@ ia64_mca_handler(struct pt_regs *regs, s
 		ia64_sal_clear_state_info(SAL_INFO_TYPE_MCA);
 		sos->os_status = IA64_MCA_CORRECTED;
 	}
+	if (notify_die(DIE_MCA_MONARCH_LEAVE, "MCA", regs, 0, 0, recover)
+			= NOTIFY_STOP)
+		ia64_mca_spin(__FUNCTION__);
 
 	set_curr_task(cpu, previous_current);
 	monarch_cpu = -1;
@@ -1190,6 +1221,37 @@ ia64_mca_cpe_poll (unsigned long dummy)
 
 #endif /* CONFIG_ACPI */
 
+static int
+default_monarch_init_process(struct notifier_block *self, unsigned long val, void *data)
+{
+	int c;
+	struct task_struct *g, *t;
+	if (val != DIE_INIT_MONARCH_PROCESS)
+		return NOTIFY_DONE;
+	printk(KERN_ERR "Processes interrupted by INIT -");
+	for_each_online_cpu(c) {
+		struct ia64_sal_os_state *s;
+		t = __va(__per_cpu_mca[c] + IA64_MCA_CPU_INIT_STACK_OFFSET);
+		s = (struct ia64_sal_os_state *)((char *)t + MCA_SOS_OFFSET);
+		g = s->prev_task;
+		if (g) {
+			if (g->pid)
+				printk(" %d", g->pid);
+			else
+				printk(" %d (cpu %d task 0x%p)", g->pid, task_cpu(g), g);
+		}
+	}
+	printk("\n\n");
+	if (read_trylock(&tasklist_lock)) {
+		do_each_thread (g, t) {
+			printk("\nBacktrace of pid %d (%s)\n", t->pid, t->comm);
+			show_stack(t, NULL);
+		} while_each_thread (g, t);
+		read_unlock(&tasklist_lock);
+	}
+	return NOTIFY_DONE;
+}
+
 /*
  * C portion of the OS INIT handler
  *
@@ -1214,8 +1276,7 @@ ia64_init_handler(struct pt_regs *regs, 
 	static atomic_t slaves;
 	static atomic_t monarchs;
 	task_t *previous_current;
-	int cpu = smp_processor_id(), c;
-	struct task_struct *g, *t;
+	int cpu = smp_processor_id();
 
 	oops_in_progress = 1;	/* FIXME: make printk NMI/MCA/INIT safe */
 	console_loglevel = 15;	/* make sure printks make it to console */
@@ -1255,8 +1316,17 @@ ia64_init_handler(struct pt_regs *regs, 
 		ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_INIT;
 		while (monarch_cpu = -1)
 		       cpu_relax();	/* spin until monarch enters */
+		if (notify_die(DIE_INIT_SLAVE_ENTER, "INIT", regs, 0, 0, 0)
+				= NOTIFY_STOP)
+			ia64_mca_spin(__FUNCTION__);
+		if (notify_die(DIE_INIT_SLAVE_PROCESS, "INIT", regs, 0, 0, 0)
+				= NOTIFY_STOP)
+			ia64_mca_spin(__FUNCTION__);
 		while (monarch_cpu != -1)
 		       cpu_relax();	/* spin until monarch leaves */
+		if (notify_die(DIE_INIT_SLAVE_LEAVE, "INIT", regs, 0, 0, 0)
+				= NOTIFY_STOP)
+			ia64_mca_spin(__FUNCTION__);
 		printk("Slave on cpu %d returning to normal service.\n", cpu);
 		set_curr_task(cpu, previous_current);
 		ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
@@ -1265,6 +1335,9 @@ ia64_init_handler(struct pt_regs *regs, 
 	}
 
 	monarch_cpu = cpu;
+	if (notify_die(DIE_INIT_MONARCH_ENTER, "INIT", regs, 0, 0, 0)
+			= NOTIFY_STOP)
+		ia64_mca_spin(__FUNCTION__);
 
 	/*
 	 * Wait for a bit.  On some machines (e.g., HP's zx2000 and zx6000, INIT can be
@@ -1275,27 +1348,16 @@ ia64_init_handler(struct pt_regs *regs, 
 	printk("Delaying for 5 seconds...\n");
 	udelay(5*1000000);
 	ia64_wait_for_slaves(cpu);
-	printk(KERN_ERR "Processes interrupted by INIT -");
-	for_each_online_cpu(c) {
-		struct ia64_sal_os_state *s;
-		t = __va(__per_cpu_mca[c] + IA64_MCA_CPU_INIT_STACK_OFFSET);
-		s = (struct ia64_sal_os_state *)((char *)t + MCA_SOS_OFFSET);
-		g = s->prev_task;
-		if (g) {
-			if (g->pid)
-				printk(" %d", g->pid);
-			else
-				printk(" %d (cpu %d task 0x%p)", g->pid, task_cpu(g), g);
-		}
-	}
-	printk("\n\n");
-	if (read_trylock(&tasklist_lock)) {
-		do_each_thread (g, t) {
-			printk("\nBacktrace of pid %d (%s)\n", t->pid, t->comm);
-			show_stack(t, NULL);
-		} while_each_thread (g, t);
-		read_unlock(&tasklist_lock);
-	}
+	/* If nobody intercepts DIE_INIT_MONARCH_PROCESS then we drop through
+	 * to default_monarch_init_process() above and just print all the
+	 * tasks.
+	 */
+	if (notify_die(DIE_INIT_MONARCH_PROCESS, "INIT", regs, 0, 0, 0)
+			= NOTIFY_STOP)
+		ia64_mca_spin(__FUNCTION__);
+	if (notify_die(DIE_INIT_MONARCH_LEAVE, "INIT", regs, 0, 0, 0)
+			= NOTIFY_STOP)
+		ia64_mca_spin(__FUNCTION__);
 	printk("\nINIT dump complete.  Monarch on cpu %d returning to normal service.\n", cpu);
 	atomic_dec(&monarchs);
 	set_curr_task(cpu, previous_current);
@@ -1464,6 +1526,10 @@ ia64_mca_init(void)
 	s64 rc;
 	struct ia64_sal_retval isrv;
 	u64 timeout = IA64_MCA_RENDEZ_TIMEOUT;	/* platform specific */
+	static struct notifier_block default_init_monarch_nb = {
+		.notifier_call = default_monarch_init_process,
+		.priority = 0/* we need to notified last */
+	};
 
 	IA64_MCA_DEBUG("%s: begin\n", __FUNCTION__);
 
@@ -1557,6 +1623,10 @@ ia64_mca_init(void)
 		       "(status %ld)\n", rc);
 		return;
 	}
+	if (!register_die_notifier(&default_init_monarch_nb)) {
+		printk(KERN_ERR "Failed to register default monarch INIT process\n");
+		return;
+	}
 
 	IA64_MCA_DEBUG("%s: registered OS INIT handler with SAL\n", __FUNCTION__);
 
Index: linux/include/asm-ia64/kdebug.h
=================================--- linux.orig/include/asm-ia64/kdebug.h	2005-10-28 10:02:08.000000000 +1000
+++ linux/include/asm-ia64/kdebug.h	2005-11-02 12:56:47.936571162 +1100
@@ -22,6 +22,9 @@
  * 2005-Apr     Rusty Lynch <rusty.lynch@intel.com> and Anil S Keshavamurthy
  *              <anil.s.keshavamurthy@intel.com> adopted from
  *              include/asm-x86_64/kdebug.h
+ *
+ * 2005-Oct	Keith Owens <kaos@sgi.com>.  Expand notify_die to cover more
+ *		events.
  */
 #include <linux/notifier.h>
 
@@ -35,13 +38,36 @@ struct die_args {
 	int signr;
 };
 
-int register_die_notifier(struct notifier_block *nb);
+extern int register_die_notifier(struct notifier_block *);
+extern int unregister_die_notifier(struct notifier_block *);
 extern struct notifier_block *ia64die_chain;
 
 enum die_val {
 	DIE_BREAK = 1,
-	DIE_SS,
+	DIE_FAULT,
+	DIE_OOPS,
 	DIE_PAGE_FAULT,
+	DIE_MACHINE_HALT,
+	DIE_MACHINE_RESTART,
+	DIE_MCA_MONARCH_ENTER,
+	DIE_MCA_MONARCH_PROCESS,
+	DIE_MCA_MONARCH_LEAVE,
+	DIE_MCA_SLAVE_ENTER,
+	DIE_MCA_SLAVE_PROCESS,
+	DIE_MCA_SLAVE_LEAVE,
+	DIE_MCA_RENDZVOUS_ENTER,
+	DIE_MCA_RENDZVOUS_PROCESS,
+	DIE_MCA_RENDZVOUS_LEAVE,
+	DIE_INIT_MONARCH_ENTER,
+	DIE_INIT_MONARCH_PROCESS,
+	DIE_INIT_MONARCH_LEAVE,
+	DIE_INIT_SLAVE_ENTER,
+	DIE_INIT_SLAVE_PROCESS,
+	DIE_INIT_SLAVE_LEAVE,
+	DIE_KDEBUG_ENTER,
+	DIE_KDEBUG_LEAVE,
+	DIE_KDUMP_ENTER,
+	DIE_KDUMP_LEAVE,
 };
 
 static inline int notify_die(enum die_val val, char *str, struct pt_regs *regs,
Index: linux/arch/ia64/kernel/kprobes.c
=================================--- linux.orig/arch/ia64/kernel/kprobes.c	2005-10-28 10:02:08.000000000 +1000
+++ linux/arch/ia64/kernel/kprobes.c	2005-11-02 12:23:04.344458424 +1100
@@ -351,7 +351,7 @@ int __kprobes trampoline_probe_handler(s
 	unsigned long trampoline_address  		((struct fnptr *)kretprobe_trampoline)->ip;
 
-        head = kretprobe_inst_table_head(current);
+	head = kretprobe_inst_table_head(current);
 
 	/*
 	 * It is possible to have multiple instances associated with a given
@@ -367,9 +367,9 @@ int __kprobes trampoline_probe_handler(s
 	 *       kretprobe_trampoline
 	 */
 	hlist_for_each_entry_safe(ri, node, tmp, head, hlist) {
-                if (ri->task != current)
+		if (ri->task != current)
 			/* another task is sharing our hash bucket */
-                        continue;
+			continue;
 
 		if (ri->rp && ri->rp->handler)
 			ri->rp->handler(ri, regs);
@@ -392,12 +392,12 @@ int __kprobes trampoline_probe_handler(s
 	unlock_kprobes();
 	preempt_enable_no_resched();
 
-        /*
-         * By returning a non-zero value, we are telling
-         * kprobe_handler() that we have handled unlocking
-         * and re-enabling preemption.
-         */
-        return 1;
+	/*
+	 * By returning a non-zero value, we are telling
+	 * kprobe_handler() that we have handled unlocking
+	 * and re-enabling preemption.
+	 */
+	return 1;
 }
 
 void __kprobes arch_prepare_kretprobe(struct kretprobe *rp,
@@ -735,12 +735,16 @@ int __kprobes kprobe_exceptions_notify(s
 	struct die_args *args = (struct die_args *)data;
 	switch(val) {
 	case DIE_BREAK:
-		if (pre_kprobes_handler(args))
-			return NOTIFY_STOP;
+		/* err is break number from ia64_bad_break() */
+		if (data->err = 0x80200 || data->err = 0x80300)
+			if (pre_kprobes_handler(args))
+				return NOTIFY_STOP;
 		break;
-	case DIE_SS:
-		if (post_kprobes_handler(args->regs))
-			return NOTIFY_STOP;
+	case DIE_FAULT:
+		/* err is vector number from ia64_fault() */
+		if (data->err = 36)
+			if (post_kprobes_handler(args->regs))
+				return NOTIFY_STOP;
 		break;
 	case DIE_PAGE_FAULT:
 		if (kprobes_fault_handler(args->regs, args->trapnr))
Index: linux/arch/ia64/kernel/process.c
=================================--- linux.orig/arch/ia64/kernel/process.c	2005-10-28 10:02:08.000000000 +1000
+++ linux/arch/ia64/kernel/process.c	2005-11-02 12:23:04.348364134 +1100
@@ -4,6 +4,9 @@
  * Copyright (C) 1998-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  * 04/11/17 Ashok Raj	<ashok.raj@intel.com> Added CPU Hotplug Support
+ *
+ * 2005-10-07 Keith Owens <kaos@sgi.com>
+ *	      Add notify_die() hooks.
  */
 #define __KERNEL_SYSCALLS__	/* see <asm/unistd.h> */
 #include <linux/config.h>
@@ -34,6 +37,7 @@
 #include <asm/elf.h>
 #include <asm/ia32.h>
 #include <asm/irq.h>
+#include <asm/kdebug.h>
 #include <asm/pgalloc.h>
 #include <asm/processor.h>
 #include <asm/sal.h>
@@ -804,12 +808,14 @@ cpu_halt (void)
 void
 machine_restart (char *restart_cmd)
 {
+	(void) notify_die(DIE_MACHINE_RESTART, restart_cmd, NULL, 0, 0, 0);
 	(*efi.reset_system)(EFI_RESET_WARM, 0, 0, NULL);
 }
 
 void
 machine_halt (void)
 {
+	(void) notify_die(DIE_MACHINE_HALT, "", NULL, 0, 0, 0);
 	cpu_halt();
 }
 
Index: linux/arch/ia64/kernel/traps.c
=================================--- linux.orig/arch/ia64/kernel/traps.c	2005-11-02 12:22:42.734161437 +1100
+++ linux/arch/ia64/kernel/traps.c	2005-11-02 12:56:47.935594734 +1100
@@ -30,17 +30,20 @@ fpswa_interface_t *fpswa_interface;
 EXPORT_SYMBOL(fpswa_interface);
 
 struct notifier_block *ia64die_chain;
-static DEFINE_SPINLOCK(die_notifier_lock);
 
-int register_die_notifier(struct notifier_block *nb)
+int
+register_die_notifier(struct notifier_block *nb)
 {
-	int err = 0;
-	unsigned long flags;
-	spin_lock_irqsave(&die_notifier_lock, flags);
-	err = notifier_chain_register(&ia64die_chain, nb);
-	spin_unlock_irqrestore(&die_notifier_lock, flags);
-	return err;
+	return notifier_chain_register(&ia64die_chain, nb);
 }
+EXPORT_SYMBOL_GPL(register_die_notifier);
+
+int
+unregister_die_notifier(struct notifier_block *nb)
+{
+	return notifier_chain_unregister(&ia64die_chain, nb);
+}
+EXPORT_SYMBOL_GPL(unregister_die_notifier);
 
 void __init
 trap_init (void)
@@ -105,6 +108,7 @@ die (const char *str, struct pt_regs *re
 	if (++die.lock_owner_depth < 3) {
 		printk("%s[%d]: %s %ld [%d]\n",
 			current->comm, current->pid, str, err, ++die_counter);
+		(void) notify_die(DIE_OOPS, (char *)str, regs, err, 255, SIGSEGV);
 		show_regs(regs);
   	} else
 		printk(KERN_ERR "Recursive die() failure, output suppressed\n");
@@ -155,9 +159,8 @@ __kprobes ia64_bad_break (unsigned long 
 	switch (break_num) {
 	      case 0: /* unknown error (used by GCC for __builtin_abort()) */
 		if (notify_die(DIE_BREAK, "break 0", regs, break_num, TRAP_BRKPT, SIGTRAP)
-			       	= NOTIFY_STOP) {
+			       	= NOTIFY_STOP)
 			return;
-		}
 		die_if_kernel("bugcheck!", regs, break_num);
 		sig = SIGILL; code = ILL_ILLOPC;
 		break;
@@ -210,15 +213,6 @@ __kprobes ia64_bad_break (unsigned long 
 		sig = SIGILL; code = __ILL_BNDMOD;
 		break;
 
-	      case 0x80200:
-	      case 0x80300:
-		if (notify_die(DIE_BREAK, "kprobe", regs, break_num, TRAP_BRKPT, SIGTRAP)
-			       	= NOTIFY_STOP) {
-			return;
-		}
-		sig = SIGTRAP; code = TRAP_BRKPT;
-		break;
-
 	      default:
 		if (break_num < 0x40000 || break_num > 0x100000)
 			die_if_kernel("Bad break", regs, break_num);
@@ -226,6 +220,9 @@ __kprobes ia64_bad_break (unsigned long 
 		if (break_num < 0x80000) {
 			sig = SIGILL; code = __ILL_BREAK;
 		} else {
+			if (notify_die(DIE_BREAK, "bad break", regs, break_num, TRAP_BRKPT, SIGTRAP)
+					= NOTIFY_STOP)
+				return;
 			sig = SIGTRAP; code = TRAP_BRKPT;
 		}
 	}
@@ -578,12 +575,11 @@ ia64_fault (unsigned long vector, unsign
 #endif
 			break;
 		      case 35: siginfo.si_code = TRAP_BRANCH; ifa = 0; break;
-		      case 36:
-			      if (notify_die(DIE_SS, "ss", &regs, vector,
-					     vector, SIGTRAP) = NOTIFY_STOP)
-				      return;
-			      siginfo.si_code = TRAP_TRACE; ifa = 0; break;
+		      case 36: siginfo.si_code = TRAP_TRACE; ifa = 0; break;
 		}
+		if (notify_die(DIE_FAULT, "ia64_fault", &regs, vector, siginfo.si_code, SIGTRAP)
+			       	= NOTIFY_STOP)
+			return;
 		siginfo.si_signo = SIGTRAP;
 		siginfo.si_errno = 0;
 		siginfo.si_addr  = (void __user *) ifa;


