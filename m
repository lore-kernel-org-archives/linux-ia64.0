From: "Ashok Raj" <ashok.raj@intel.com>
Date: Sun, 25 Apr 2004 06:46:34 +0000
Subject: [RFC IA64 Hotplug] [Patch 4/7] hotcpu_ia64.patch
Message-Id: <ORSMSX4041XvpFVjCRG0000016f@orsmsx404.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Patch 4/7

Cheers,
ashok raj
- Linux Core Software Group
   

Name: hotcpu_ia64.patch
Author: Ashok Raj (Intel Corporation)
D: Supports basic ability to enable hotplug functions for IA64.
D: Code is just evolving, and there are several loose ends to tie up.
D:
D: What this code drop does
D: - Support logical online and offline
D: - Handles interrupt migration without loss of interrupts.
D: - Handles stress fine > 8+ hrs with make -j/ftp/rcp workloads
D: What needs to be done
D: - Boot CPU removal support, with platform level authentication
D: - Putting cpu being removed in BOOT_RENDEZ mode.
---



---

 linux-2.6.5-lhcs-root/arch/ia64/Kconfig          |   87 +++++++++++++++
 linux-2.6.5-lhcs-root/arch/ia64/kernel/irq.c     |   35 ++++++
 linux-2.6.5-lhcs-root/arch/ia64/kernel/process.c |   44 +++++++
 linux-2.6.5-lhcs-root/arch/ia64/kernel/smp.c     |   26 ++++
 linux-2.6.5-lhcs-root/arch/ia64/kernel/smpboot.c |  130
+++++++++++++++++++++--
 linux-2.6.5-lhcs-root/arch/ia64/kernel/time.c    |    5 
 linux-2.6.5-lhcs-root/include/asm-ia64/smp.h     |    2 
 7 files changed, 319 insertions(+), 10 deletions(-)

diff -puN arch/ia64/Kconfig~hotcpu_ia64 arch/ia64/Kconfig
--- linux-2.6.5-lhcs/arch/ia64/Kconfig~hotcpu_ia64	2004-04-23
23:11:13.585570118 -0700
+++ linux-2.6.5-lhcs-root/arch/ia64/Kconfig	2004-04-23
23:11:13.596312311 -0700
@@ -367,6 +367,14 @@ config PCI_DOMAINS
 
 source "drivers/pci/Kconfig"
 
+config HOTPLUG_CPU
+    bool "Support for hot-pluggable CPUs (EXPERIMENTAL)"
+    depends on SMP && HOTPLUG && EXPERIMENTAL
+    ---help---
+      Say Y here to experiment with turning CPUs off and on.  CPUs
+      can be controlled through /sys/cpu.
+      Say N.
+
 source "drivers/pci/hotplug/Kconfig"
 
 source "drivers/pcmcia/Kconfig"
@@ -411,6 +419,85 @@ config DEBUG_KERNEL
 	  Say Y here if you are developing drivers or trying to debug and
 	  identify kernel problems.
 
+config KDB
+	bool "Built-in Kernel Debugger support"
+	depends on DEBUG_KERNEL
+	help
+	  This option provides a built-in kernel debugger.  The built-in
+	  kernel debugger contains commands which allow memory to be
examined,
+	  instructions to be disassembled and breakpoints to be set.  For
details,
+	  see Documentation/kdb/kdb.mm and the manual pages kdb_bt, kdb_ss,
etc.
+	  Kdb can also be used via the serial port.  Set up the system to
+	  have a serial console (see Documentation/serial-console.txt).
+	  The Control-A key sequence on the serial port will cause the
+	  kernel debugger to be entered with input from the serial port and
+	  output to the serial console.  If unsure, say N.
+
+config KDB_MODULES
+	tristate "KDB modules"
+	depends on KDB
+	help
+	  KDB can be extended by adding your own modules, in directory
+	  kdb/modules.  This option selects the way that these modules
should
+	  be compiled, as free standing modules (select M) or built into the
+	  kernel (select Y).  If unsure say M.
+
+config KDB_OFF
+	bool "KDB off by default"
+	depends on KDB
+	help
+	  Normally kdb is activated by default, as long as CONFIG_KDB is
set.
+	  If you want to ship a kernel with kdb support but only have kdb
+	  turned on when the user requests it then select this option.  When
+	  compiled with CONFIG_KDB_OFF, kdb ignores all events unless you
boot
+	  with kdb=on or you echo "1" > /proc/sys/kernel/kdb.  This option
also
+	  works in reverse, if kdb is normally activated, you can boot with
+	  kdb=off or echo "0" > /proc/sys/kernel/kdb to deactivate kdb. If
+	  unsure, say N.
+
+config KDB_CONTINUE_CATASTROPHIC
+	int "KDB continues after catastrophic errors"
+	depends on KDB
+	default "0"
+	help
+	  This integer controls the behaviour of kdb when the kernel gets a
+  	  catastrophic error, i.e. for a panic, oops, NMI or other watchdog
+  	  tripping.  CONFIG_KDB_CONTINUE_CATASTROPHIC interacts with
+  	  /proc/sys/kernel/kdb and CONFIG_DUMP (if your kernel has the LKCD
+  	  patch).
+  	  When KDB is active (/proc/sys/kernel/kdb = 1) and a catastrophic
+  	  error occurs, nothing extra happens until you type 'go'.
+	  CONFIG_KDB_CONTINUE_CATASTROPHIC = 0 (default).  The first time
+    	  you type 'go', kdb warns you.  The second time you type 'go', KDB
+    	  tries to continue - no guarantees that the kernel is still usable.
+    	  CONFIG_KDB_CONTINUE_CATASTROPHIC = 1.  KDB tries to continue - no
+    	  guarantees that the kernel is still usable.
+    	  CONFIG_KDB_CONTINUE_CATASTROPHIC = 2.  If your kernel has the
LKCD
+    	  patch and LKCD is configured to take a dump then KDB forces a
dump.
+    	  Whether or not a dump is taken, KDB forces a reboot.
+  	  When KDB is not active (/proc/sys/kernel/kdb = 0) and a
catastrophic
+  	  error occurs, the following steps are automatic, no human
+  	  intervention is required.
+    	  CONFIG_KDB_CONTINUE_CATASTROPHIC = 0 (default) or 1.  KDB
attempts
+    	  to continue - no guarantees that the kernel is still usable.
+    	  CONFIG_KDB_CONTINUE_CATASTROPHIC = 2.  If your kernel has the
LKCD
+    	  patch and LKCD is configured to take a dump then KDB automatically
+    	  forces a dump.  Whether or not a dump is taken, KDB forces a
+    	  reboot.
+  	  If you are not sure, say 0.  Read Documentation/kdb/dump.txt
before
+  	  setting to 2.
+
+# KDB_USB does not work, the usb code needs to be
+# converted from 2.4.19 to 2.5.40 APIs.  Omit it until somebody
+# fixes CONFIG_KDB_USB.
+#config KDB_USB
+#	bool "Support for USB Keyboard in KDB"
+#	depends on KDB && USB
+#	help
+#	  If you want to use kdb from a USB keyboard then say Y here.  If
you
+#	  say N then kdb can only be used from a PC (AT) keyboard or a
serial
+#	  console.
+
 config IA64_PRINT_HAZARDS
 	bool "Print possible IA-64 dependency violations to console"
 	depends on DEBUG_KERNEL
diff -puN arch/ia64/kernel/irq.c~hotcpu_ia64 arch/ia64/kernel/irq.c
--- linux-2.6.5-lhcs/arch/ia64/kernel/irq.c~hotcpu_ia64	2004-04-23
23:11:13.586546681 -0700
+++ linux-2.6.5-lhcs-root/arch/ia64/kernel/irq.c	2004-04-23
23:11:13.597288874 -0700
@@ -35,6 +35,8 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/kallsyms.h>
+#include <linux/notifier.h>
+#include <linux/cpu.h>
 
 #include <asm/atomic.h>
 #include <asm/io.h>
@@ -45,6 +47,8 @@
 #include <asm/pgalloc.h>
 #include <asm/delay.h>
 #include <asm/irq.h>
+#include <asm/tlbflush.h>
+#include <asm/cpu.h>
 
 
 
@@ -432,6 +436,7 @@ void enable_irq(unsigned int irq)
 }
 EXPORT_SYMBOL(enable_irq);
 
+
 /*
  * do_IRQ handles all normal device IRQ's (the special
  * SMP cross-CPU interrupts have their own specific
@@ -1000,6 +1005,36 @@ static int irq_affinity_write_proc (stru
 
 #endif /* CONFIG_SMP */
 
+#ifdef CONFIG_HOTPLUG_CPU
+void fixup_irqs(void)
+{
+	cpumask_t	mask;
+	unsigned int irq, redir;
+	irq_desc_t *desc;
+	static int warned;
+
+	for (irq = 0; irq < NR_IRQS; irq++) {
+		cpus_and(mask, irq_affinity[irq], cpu_online_map);
+		if (any_online_cpu(mask) = NR_CPUS) {
+			printk("Breaking affinity for irq %ui\n", irq);
+			mask = any_online_cpu(cpu_online_map);
+		}
+		desc = irq_descp(irq);
+		if (desc->handler->set_affinity) {
+			redir = irq_redir[irq];
+			desc->handler->set_affinity(irq | (redir ?
IA64_IRQ_REDIRECTED : 0),
+
mask);
+		}
+		else if (desc->action && !(warned++))
+			printk("Cannot set affinity for irq %i\n", irq);
+	}
+	max_xtp();
+	local_irq_disable();
+	__get_cpu_var(cpu_state) = CPU_DEAD;
+}
+
+#endif
+
 static int prof_cpu_mask_read_proc (char *page, char **start, off_t off,
 			int count, int *eof, void *data)
 {
diff -puN arch/ia64/kernel/process.c~hotcpu_ia64 arch/ia64/kernel/process.c
--- linux-2.6.5-lhcs/arch/ia64/kernel/process.c~hotcpu_ia64	2004-04-23
23:11:13.588499807 -0700
+++ linux-2.6.5-lhcs-root/arch/ia64/kernel/process.c	2004-04-23
23:11:13.598265437 -0700
@@ -9,6 +9,8 @@
 
 #include <linux/pm.h>
 #include <linux/elf.h>
+#include <linux/notifier.h>
+#include <linux/cpu.h>
 #include <linux/errno.h>
 #include <linux/kallsyms.h>
 #include <linux/kernel.h>
@@ -22,6 +24,7 @@
 #include <linux/thread_info.h>
 #include <linux/unistd.h>
 #include <linux/efi.h>
+#include <linux/interrupt.h>
 
 #include <asm/delay.h>
 #include <asm/elf.h>
@@ -30,8 +33,12 @@
 #include <asm/processor.h>
 #include <asm/sal.h>
 #include <asm/uaccess.h>
+#include <asm/irq.h>
+#include <asm/tlbflush.h>
+#include <asm/cpu.h>
 #include <asm/unwind.h>
 #include <asm/user.h>
+#include <asm/delay.h>
 
 #ifdef CONFIG_PERFMON
 # include <asm/perfmon.h>
@@ -180,6 +187,40 @@ default_idle (void)
 			safe_halt();
 }
 
+#ifdef CONFIG_HOTPLUG_CPU
+/* We don't actually take CPU down, just spin without interrupts. */
+static inline void play_dead(void)
+{
+	extern void ia64_cpu_local_tick (void);
+	/* Ack it */
+	__get_cpu_var(cpu_state) = CPU_DEAD;
+
+	/* We shouldn't have to disable interrupts while dead, but
+	 * some interrupts just don't seem to go away, and this makes
+	 * it "work" for testing purposes. */
+	max_xtp();
+	local_irq_disable();
+	/* Death loop */
+	while (__get_cpu_var(cpu_state) != CPU_UP_PREPARE)
+		cpu_relax();
+
+	/*
+	 * Enable timer interrupts from now on
+	 * Not required if we put processor in SAL_BOOT_RENDEZ mode.
+	 */
+	local_flush_tlb_all();
+	cpu_set(smp_processor_id(), cpu_online_map);
+	wmb();
+	ia64_cpu_local_tick ();
+	local_irq_enable();
+}
+#else
+static inline void play_dead(void)
+{
+	BUG();
+}
+#endif /* CONFIG_HOTPLUG_CPU */
+
 void __attribute__((noreturn))
 cpu_idle (void *unused)
 {
@@ -195,7 +236,6 @@ cpu_idle (void *unused)
 		if (!need_resched())
 			min_xtp();
 #endif
-
 		while (!need_resched()) {
 			if (mark_idle)
 				(*mark_idle)(1);
@@ -210,6 +250,8 @@ cpu_idle (void *unused)
 #endif
 		schedule();
 		check_pgt_cache();
+		if (cpu_is_offline(smp_processor_id()))
+			play_dead();
 	}
 }
 
diff -puN arch/ia64/kernel/smpboot.c~hotcpu_ia64 arch/ia64/kernel/smpboot.c
--- linux-2.6.5-lhcs/arch/ia64/kernel/smpboot.c~hotcpu_ia64	2004-04-23
23:11:13.590452933 -0700
+++ linux-2.6.5-lhcs-root/arch/ia64/kernel/smpboot.c	2004-04-23
23:11:13.599242000 -0700
@@ -18,6 +18,8 @@
 #include <linux/delay.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
+#include <linux/notifier.h>
+#include <linux/cpu.h>
 #include <linux/irq.h>
 #include <linux/kernel.h>
 #include <linux/kernel_stat.h>
@@ -26,6 +28,7 @@
 #include <linux/smp_lock.h>
 #include <linux/spinlock.h>
 #include <linux/efi.h>
+#include <linux/percpu.h>
 
 #include <asm/atomic.h>
 #include <asm/bitops.h>
@@ -45,6 +48,7 @@
 #include <asm/sal.h>
 #include <asm/system.h>
 #include <asm/unistd.h>
+#include <asm/tlbflush.h>
 
 #define SMP_DEBUG 0
 
@@ -75,6 +79,11 @@ extern unsigned long ia64_iobase;
 
 task_t *task_for_booting_cpu;
 
+/*
+ * State for each CPU
+ */
+DEFINE_PER_CPU(int, cpu_state) = { 0 };
+
 /* Bitmask of currently online CPUs */
 cpumask_t cpu_online_map;
 EXPORT_SYMBOL(cpu_online_map);
@@ -280,12 +289,16 @@ smp_callin (void)
 	cpuid = smp_processor_id();
 	phys_id = hard_smp_processor_id();
 
-	if (cpu_test_and_set(cpuid, cpu_online_map)) {
+	if (cpu_online(cpuid)) {
 		printk(KERN_ERR "huh, phys CPU#0x%x, CPU#0x%x already
present??\n",
 		       phys_id, cpuid);
 		BUG();
 	}
 
+	lock_ipi_calllock();
+	cpu_set(cpuid, cpu_online_map);
+	unlock_ipi_calllock();
+
 	smp_setup_percpu_timer();
 
 	/*
@@ -356,29 +369,51 @@ fork_by_hand (void)
 	return copy_process(CLONE_VM|CLONE_IDLETASK, 0, 0, 0, NULL, NULL);
 }
 
+struct create_idle {
+	struct task_struct *idle;
+	struct completion done;
+};
+
+void
+do_fork_idle(void *_c_idle)
+{
+	struct create_idle *c_idle = _c_idle;
+
+	c_idle->idle = fork_by_hand();
+	complete(&c_idle->done);
+}
+
 static int __devinit
 do_boot_cpu (int sapicid, int cpu)
 {
-	struct task_struct *idle;
 	int timeout;
+	struct create_idle c_idle;
+	DECLARE_WORK(work, do_fork_idle, &c_idle);
 
+	init_completion(&c_idle.done);
 	/*
 	 * We can't use kernel_thread since we must avoid to reschedule the
child.
 	 */
-	idle = fork_by_hand();
-	if (IS_ERR(idle))
+	if (!keventd_up() || current_is_keventd())
+		work.func(work.data);
+	else {
+		schedule_work(&work);
+		wait_for_completion(&c_idle.done);
+	}
+
+	if (IS_ERR(c_idle.idle))
 		panic("failed fork for CPU %d", cpu);
-	wake_up_forked_process(idle);
+	wake_up_forked_process(c_idle.idle);
 
 	/*
 	 * We remove it from the pidhash and the runqueue
 	 * once we got the process:
 	 */
-	init_idle(idle, cpu);
+	init_idle(c_idle.idle, cpu);
 
-	unhash_process(idle);
+	unhash_process(c_idle.idle);
 
-	task_for_booting_cpu = idle;
+	task_for_booting_cpu = c_idle.idle;
 
 	Dprintk("Sending wakeup vector %lu to AP 0x%x/0x%x.\n",
ap_wakeup_vector, cpu, sapicid);
 
@@ -542,6 +577,74 @@ void __devinit smp_prepare_boot_cpu(void
 	cpu_set(smp_processor_id(), cpu_callin_map);
 }
 
+#ifdef CONFIG_HOTPLUG_CPU
+extern void fixup_irqs(void);
+/* must be called with cpucontrol mutex held */
+static int __devinit cpu_enable(unsigned int cpu)
+{
+	per_cpu(cpu_state,cpu) = CPU_UP_PREPARE;
+	wmb();
+
+	while (!cpu_online(cpu))
+		cpu_relax();
+	return 0;
+}
+
+int __cpu_disable(void)
+{
+	int cpu = smp_processor_id();
+
+	/*
+	 * dont permit boot processor for now
+	 */
+	if (cpu = 0)
+		return -EBUSY;
+
+	fixup_irqs();
+	local_flush_tlb_all();
+	printk ("Disabled cpu %u\n", smp_processor_id());
+	return 0;
+}
+
+void __cpu_die(unsigned int cpu)
+{
+	unsigned int i;
+
+	for (i = 0; i < 100; i++) {
+		/* They ack this in play_dead by setting CPU_DEAD */
+		if (per_cpu(cpu_state, cpu) = CPU_DEAD)
+		{
+			/*
+			 * TBD: Enable this when physical removal
+			 * or when we put the processor is put in
+			 * SAL_BOOT_RENDEZ mode
+			 * cpu_clear(cpu, cpu_callin_map);
+			 */
+			return;
+		}
+		current->state = TASK_UNINTERRUPTIBLE;
+		schedule_timeout(HZ/10);
+	}
+ 	printk(KERN_ERR "CPU %u didn't die...\n", cpu);
+}
+#else /* !CONFIG_HOTPLUG_CPU */
+static int __devinit cpu_enable(unsigned int cpu)
+{
+	return 0;
+}
+
+int __cpu_disable(void)
+{
+	return -ENOSYS;
+}
+
+void __cpu_die(unsigned int cpu)
+{
+	/* We said "no" in __cpu_disable */
+	BUG();
+}
+#endif /* CONFIG_HOTPLUG_CPU */
+
 void
 smp_cpus_done (unsigned int dummy)
 {
@@ -570,6 +673,17 @@ __cpu_up (unsigned int cpu)
 	if (sapicid = -1)
 		return -EINVAL;
 
+	/*
+	 * Already booted.. just enable and get outa idle lool
+	 */
+	if (cpu_isset(cpu, cpu_callin_map))
+	{
+		cpu_enable(cpu);
+		local_irq_enable();
+		while (!cpu_isset(cpu, cpu_online_map))
+			mb();
+		return 0;
+	}
 	/* Processor goes to start_secondary(), sets online flag */
 	ret = do_boot_cpu(sapicid, cpu);
 	if (ret < 0)
diff -puN arch/ia64/kernel/smp.c~hotcpu_ia64 arch/ia64/kernel/smp.c
--- linux-2.6.5-lhcs/arch/ia64/kernel/smp.c~hotcpu_ia64	2004-04-23
23:11:13.591429496 -0700
+++ linux-2.6.5-lhcs-root/arch/ia64/kernel/smp.c	2004-04-23
23:11:13.599242000 -0700
@@ -71,10 +71,23 @@ static volatile struct call_data_struct 
 /* This needs to be cacheline aligned because it is written to by *other*
CPUs.  */
 static DEFINE_PER_CPU(u64, ipi_operation) ____cacheline_aligned;
 
+extern void cpu_halt (void);
+
+void
+lock_ipi_calllock(void)
+{
+	spin_lock_irq(&call_lock);
+}
+
+void
+unlock_ipi_calllock(void)
+{
+	spin_unlock_irq(&call_lock);
+}
+
 static void
 stop_this_cpu (void)
 {
-	extern void cpu_halt (void);
 	/*
 	 * Remove this CPU:
 	 */
@@ -84,6 +97,17 @@ stop_this_cpu (void)
 	cpu_halt();
 }
 
+void
+cpu_die(void)
+{
+	max_xtp();
+	local_irq_disable();
+	cpu_halt();
+	/* Should never be here */
+	BUG();
+	for (;;);
+}
+
 irqreturn_t
 handle_IPI (int irq, void *dev_id, struct pt_regs *regs)
 {
diff -puN arch/ia64/kernel/time.c~hotcpu_ia64 arch/ia64/kernel/time.c
--- linux-2.6.5-lhcs/arch/ia64/kernel/time.c~hotcpu_ia64	2004-04-23
23:11:13.593382622 -0700
+++ linux-2.6.5-lhcs-root/arch/ia64/kernel/time.c	2004-04-23
23:11:13.599242000 -0700
@@ -20,6 +20,7 @@
 #include <linux/efi.h>
 #include <linux/profile.h>
 #include <linux/timex.h>
+#include <linux/cpu.h>
 
 #include <asm/machvec.h>
 #include <asm/delay.h>
@@ -244,6 +245,10 @@ timer_interrupt (int irq, void *dev_id, 
 {
 	unsigned long new_itm;
 
+	if (unlikely(cpu_is_offline(smp_processor_id()))) {
+		return IRQ_HANDLED;
+	}
+
 	platform_timer_interrupt(irq, dev_id, regs);
 
 	new_itm = local_cpu_data->itm_next;
diff -puN include/asm-ia64/smp.h~hotcpu_ia64 include/asm-ia64/smp.h
--- linux-2.6.5-lhcs/include/asm-ia64/smp.h~hotcpu_ia64	2004-04-23
23:11:13.594359185 -0700
+++ linux-2.6.5-lhcs-root/include/asm-ia64/smp.h	2004-04-23
23:11:13.600218563 -0700
@@ -123,6 +123,8 @@ extern void smp_do_timer (struct pt_regs
 extern int smp_call_function_single (int cpuid, void (*func) (void *info),
void *info,
 				     int retry, int wait);
 extern void smp_send_reschedule (int cpu);
+extern void lock_ipi_calllock(void);
+extern void unlock_ipi_calllock(void);
 
 #endif /* CONFIG_SMP */
 #endif /* _ASM_IA64_SMP_H */

_


