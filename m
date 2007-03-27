From: Jack Steiner <steiner@sgi.com>
Date: Tue, 27 Mar 2007 19:39:25 +0000
Subject: [PATCH] - Optional method to purge the TLB on SN systems
Message-Id: <20070327193925.GA8615@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch adds an optional method for purging the TLB on SN IA64 systems.
The change should not affect any non-SN system.

	Signed-off-by: Jack Steiner <steiner@sgi.com>

---

Instead of using the chipset (SHUB) MMRs for issuing PTC flushes, the new
code sends IPIs to all affected nodes.  Each node then issues local PTC flushes.
The purpose of this change is work around performance issues that have
been seen on very large SSI systems. Small to medium size systems will continue
to use the original algorithm.

I would like to make the selection of the algorithm automatic but unfortunately 
the optimum algorithm is workload specific. The intent is that only sites that
encounter problems will use the new algorithm.


Index: linux/arch/ia64/kernel/irq_ia64.c
=================================--- linux.orig/arch/ia64/kernel/irq_ia64.c	2007-03-27 10:08:06.935647573 -0500
+++ linux/arch/ia64/kernel/irq_ia64.c	2007-03-27 10:15:41.859634603 -0500
@@ -39,6 +39,7 @@
 #include <asm/machvec.h>
 #include <asm/pgtable.h>
 #include <asm/system.h>
+#include <asm/tlbflush.h>
 
 #ifdef CONFIG_PERFMON
 # include <asm/perfmon.h>
@@ -127,8 +128,10 @@ void destroy_irq(unsigned int irq)
 
 #ifdef CONFIG_SMP
 #	define IS_RESCHEDULE(vec)	(vec = IA64_IPI_RESCHEDULE)
+#	define IS_LOCAL_TLB_FLUSH(vec)	(vec = IA64_IPI_LOCAL_TLB_FLUSH)
 #else
 #	define IS_RESCHEDULE(vec)	(0)
+#	define IS_LOCAL_TLB_FLUSH(vec)	(0)
 #endif
 /*
  * That's where the IVT branches when we get an external
@@ -182,7 +185,10 @@ ia64_handle_irq (ia64_vector vector, str
 	while (vector != IA64_SPURIOUS_INT_VECTOR) {
 		if (unlikely(IS_RESCHEDULE(vector)))
 			 kstat_this_cpu.irqs[vector]++;
-		else {
+		else if (unlikely(IS_LOCAL_TLB_FLUSH(vector))) {
+			smp_local_flush_tlb();
+			kstat_this_cpu.irqs[vector]++;
+		} else {
 			ia64_setreg(_IA64_REG_CR_TPR, vector);
 			ia64_srlz_d();
 
@@ -229,7 +235,10 @@ void ia64_process_pending_intr(void)
 	while (vector != IA64_SPURIOUS_INT_VECTOR) {
 		if (unlikely(IS_RESCHEDULE(vector)))
 			 kstat_this_cpu.irqs[vector]++;
-		else {
+		else if (unlikely(IS_LOCAL_TLB_FLUSH(vector))) {
+			smp_local_flush_tlb();
+			kstat_this_cpu.irqs[vector]++;
+		} else {
 			struct pt_regs *old_regs = set_irq_regs(NULL);
 
 			ia64_setreg(_IA64_REG_CR_TPR, vector);
@@ -267,6 +276,12 @@ static irqreturn_t dummy_handler (int ir
 	BUG();
 }
 
+static struct irqaction tlb_irqaction = {
+	.handler =	dummy_handler,
+	.flags =	SA_INTERRUPT,
+	.name =		"tlb_flush"
+};
+
 static struct irqaction ipi_irqaction = {
 	.handler =	handle_IPI,
 	.flags =	IRQF_DISABLED,
@@ -303,6 +318,7 @@ init_IRQ (void)
 #ifdef CONFIG_SMP
 	register_percpu_irq(IA64_IPI_VECTOR, &ipi_irqaction);
 	register_percpu_irq(IA64_IPI_RESCHEDULE, &resched_irqaction);
+	register_percpu_irq(IA64_IPI_LOCAL_TLB_FLUSH, &tlb_irqaction);
 #endif
 #ifdef CONFIG_PERFMON
 	pfm_init_percpu();
Index: linux/arch/ia64/kernel/smp.c
=================================--- linux.orig/arch/ia64/kernel/smp.c	2007-03-27 10:08:06.935647573 -0500
+++ linux/arch/ia64/kernel/smp.c	2007-03-27 10:15:41.859634603 -0500
@@ -50,6 +50,12 @@
 #include <asm/mca.h>
 
 /*
+ * Per-cpu counts of the number of local TLB flushes that are done via an IPI.
+ *   Note: keep structure small - local copies are made on the task's stack.
+ */
+static DEFINE_PER_CPU(unsigned short, local_flush_count) ____cacheline_aligned;
+
+/*
  * Structure and data for smp_call_function(). This is designed to minimise static memory
  * requirements. It also looks cleaner.
  */
@@ -248,6 +254,64 @@ smp_send_reschedule (int cpu)
 	platform_send_ipi(cpu, IA64_IPI_RESCHEDULE, IA64_IPI_DM_INT, 0);
 }
 
+/*
+ * Called with preeemption disabled.
+ */
+static void
+smp_send_local_flush_tlb (int cpu)
+{
+	platform_send_ipi(cpu, IA64_IPI_LOCAL_TLB_FLUSH, IA64_IPI_DM_INT, 0);
+}
+
+void
+smp_local_flush_tlb(void)
+{
+	__ia64_per_cpu_var(local_flush_count)++;
+	local_flush_tlb_all();
+}
+
+/*
+ * Flush counts are kept in a "short" to preserve stack space. It is possible (but
+ * highly unlikely) that a count could wrap & the flush would not be seen as complete.
+ * Retry the flush IPI after a long time...
+ */
+#define FLUSH_RETRY_COUNT	10000
+
+void
+smp_flush_tlb_cpumask (cpumask_t xcpumask)
+{
+	unsigned short counts[NR_CPUS];
+	cpumask_t cpumask = xcpumask;
+	int count, mycpu, cpu, flush_mycpu = 0;
+
+	preempt_disable();
+	mycpu = smp_processor_id();
+
+	for_each_cpu_mask(cpu, cpumask) {
+		counts[cpu] = per_cpu(local_flush_count, cpu);
+		mb();
+		if (cpu = mycpu)
+			flush_mycpu = 1;
+		else
+			smp_send_local_flush_tlb(cpu);
+	}
+
+	if (flush_mycpu)
+		smp_local_flush_tlb();
+
+	for_each_cpu_mask(cpu, cpumask) {
+		count = 0;
+		while(counts[cpu] = per_cpu(local_flush_count, cpu)) {
+			udelay(1);
+			if (count++ >= FLUSH_RETRY_COUNT) {
+				count = 0;
+				smp_send_local_flush_tlb(cpu);
+			}
+		}
+	}
+	preempt_enable();
+}
+
 void
 smp_flush_tlb_all (void)
 {
Index: linux/arch/ia64/sn/kernel/sn2/sn2_smp.c
=================================--- linux.orig/arch/ia64/sn/kernel/sn2/sn2_smp.c	2007-03-27 10:08:06.935647573 -0500
+++ linux/arch/ia64/sn/kernel/sn2/sn2_smp.c	2007-03-27 11:21:53.285791962 -0500
@@ -46,6 +46,9 @@ DECLARE_PER_CPU(struct ptc_stats, ptcsta
 
 static  __cacheline_aligned DEFINE_SPINLOCK(sn2_global_ptc_lock);
 
+/* 0 = old algorithm (no IPI flushes), 1 = ipi deadlock flush, 2 = ipi instead of SHUB ptc, >2 = always ipi */
+static int sn2_flush_opt = 0;
+
 extern unsigned long
 sn2_ptc_deadlock_recovery_core(volatile unsigned long *, unsigned long,
 			       volatile unsigned long *, unsigned long,
@@ -76,6 +79,8 @@ struct ptc_stats {
 	unsigned long shub_itc_clocks;
 	unsigned long shub_itc_clocks_max;
 	unsigned long shub_ptc_flushes_not_my_mm;
+	unsigned long shub_ipi_flushes;
+	unsigned long shub_ipi_flushes_itc_clocks;
 };
 
 #define sn2_ptctest	0
@@ -121,6 +126,18 @@ void sn_tlb_migrate_finish(struct mm_str
 		flush_tlb_mm(mm);
 }
 
+static void
+sn2_ipi_flush_all_tlb(struct mm_struct *mm)
+{
+	unsigned long itc;
+
+	itc = ia64_get_itc();
+	smp_flush_tlb_cpumask(mm->cpu_vm_mask);
+	itc = ia64_get_itc() - itc;
+	__get_cpu_var(ptcstats).shub_ipi_flushes_itc_clocks += itc;
+	__get_cpu_var(ptcstats).shub_ipi_flushes++;
+}
+
 /**
  * sn2_global_tlb_purge - globally purge translation cache of virtual address range
  * @mm: mm_struct containing virtual address range
@@ -154,7 +171,12 @@ sn2_global_tlb_purge(struct mm_struct *m
 	unsigned long itc, itc2, flags, data0 = 0, data1 = 0, rr_value, old_rr = 0;
 	short nasids[MAX_NUMNODES], nix;
 	nodemask_t nodes_flushed;
-	int active, max_active, deadlock;
+	int active, max_active, deadlock, flush_opt = sn2_flush_opt;
+
+	if (flush_opt > 2) {
+		sn2_ipi_flush_all_tlb(mm);
+		return;
+	}
 
 	nodes_clear(nodes_flushed);
 	i = 0;
@@ -189,6 +211,12 @@ sn2_global_tlb_purge(struct mm_struct *m
 		return;
 	}
 
+	if (flush_opt = 2) {
+		sn2_ipi_flush_all_tlb(mm);
+		preempt_enable();
+		return;
+	}
+
 	itc = ia64_get_itc();
 	nix = 0;
 	for_each_node_mask(cnode, nodes_flushed)
@@ -256,6 +284,8 @@ sn2_global_tlb_purge(struct mm_struct *m
 			}
 			if (active >= max_active || i = (nix - 1)) {
 				if ((deadlock = wait_piowc())) {
+					if (flush_opt = 1)
+						goto done;
 					sn2_ptc_deadlock_recovery(nasids, ibegin, i, mynasid, ptc0, data0, ptc1, data1);
 					if (reset_max_active_on_deadlock())
 						max_active = 1;
@@ -267,6 +297,7 @@ sn2_global_tlb_purge(struct mm_struct *m
 		start += (1UL << nbits);
 	} while (start < end);
 
+done:
 	itc2 = ia64_get_itc() - itc2;
 	__get_cpu_var(ptcstats).shub_itc_clocks += itc2;
 	if (itc2 > __get_cpu_var(ptcstats).shub_itc_clocks_max)
@@ -279,6 +310,11 @@ sn2_global_tlb_purge(struct mm_struct *m
 
 	spin_unlock_irqrestore(PTC_LOCK(shub1), flags);
 
+	if (flush_opt = 1 && deadlock) {
+		__get_cpu_var(ptcstats).deadlocks++;
+		sn2_ipi_flush_all_tlb(mm);
+	}
+
 	preempt_enable();
 }
 
@@ -425,24 +461,42 @@ static int sn2_ptc_seq_show(struct seq_f
 
 	if (!cpu) {
 		seq_printf(file,
-			   "# cpu ptc_l newrid ptc_flushes nodes_flushed deadlocks lock_nsec shub_nsec shub_nsec_max not_my_mm deadlock2\n");
-		seq_printf(file, "# ptctest %d\n", sn2_ptctest);
+			   "# cpu ptc_l newrid ptc_flushes nodes_flushed deadlocks lock_nsec shub_nsec shub_nsec_max not_my_mm deadlock2 ipi_fluches ipi_nsec\n");
+		seq_printf(file, "# ptctest %d, flushopt %d\n", sn2_ptctest, sn2_flush_opt);
 	}
 
 	if (cpu < NR_CPUS && cpu_online(cpu)) {
 		stat = &per_cpu(ptcstats, cpu);
-		seq_printf(file, "cpu %d %ld %ld %ld %ld %ld %ld %ld %ld %ld %ld\n", cpu, stat->ptc_l,
+		seq_printf(file, "cpu %d %ld %ld %ld %ld %ld %ld %ld %ld %ld %ld %ld %ld\n", cpu, stat->ptc_l,
 				stat->change_rid, stat->shub_ptc_flushes, stat->nodes_flushed,
 				stat->deadlocks,
 				1000 * stat->lock_itc_clocks / per_cpu(cpu_info, cpu).cyc_per_usec,
 				1000 * stat->shub_itc_clocks / per_cpu(cpu_info, cpu).cyc_per_usec,
 				1000 * stat->shub_itc_clocks_max / per_cpu(cpu_info, cpu).cyc_per_usec,
 				stat->shub_ptc_flushes_not_my_mm,
-				stat->deadlocks2);
+				stat->deadlocks2,
+				stat->shub_ipi_flushes,
+				1000 * stat->shub_ipi_flushes_itc_clocks / per_cpu(cpu_info, cpu).cyc_per_usec);
 	}
 	return 0;
 }
 
+static ssize_t sn2_ptc_proc_write(struct file *file, const char __user *user, size_t count, loff_t *data)
+{
+	int cpu;
+	char optstr[64];
+
+	if (copy_from_user(optstr, user, count))
+		return -EFAULT;
+	optstr[count - 1] = '\0';
+	sn2_flush_opt = simple_strtoul(optstr, NULL, 0);
+
+	for_each_online_cpu(cpu)
+		memset(&per_cpu(ptcstats, cpu), 0, sizeof(struct ptc_stats));
+
+	return count;
+}
+
 static struct seq_operations sn2_ptc_seq_ops = {
 	.start = sn2_ptc_seq_start,
 	.next = sn2_ptc_seq_next,
@@ -458,6 +512,7 @@ static int sn2_ptc_proc_open(struct inod
 static const struct file_operations proc_sn2_ptc_operations = {
 	.open = sn2_ptc_proc_open,
 	.read = seq_read,
+	.write = sn2_ptc_proc_write,
 	.llseek = seq_lseek,
 	.release = seq_release,
 };
Index: linux/include/asm-ia64/hw_irq.h
=================================--- linux.orig/include/asm-ia64/hw_irq.h	2007-03-27 10:08:06.935647573 -0500
+++ linux/include/asm-ia64/hw_irq.h	2007-03-27 10:15:41.875636572 -0500
@@ -66,6 +66,7 @@ extern int ia64_last_device_vector;
 #define IA64_PERFMON_VECTOR		0xee	/* performanc monitor interrupt vector */
 #define IA64_TIMER_VECTOR		0xef	/* use highest-prio group 15 interrupt for timer */
 #define	IA64_MCA_WAKEUP_VECTOR		0xf0	/* MCA wakeup (must be >MCA_RENDEZ_VECTOR) */
+#define IA64_IPI_LOCAL_TLB_FLUSH	0xfc	/* SMP reschedule */
 #define IA64_IPI_RESCHEDULE		0xfd	/* SMP reschedule */
 #define IA64_IPI_VECTOR			0xfe	/* inter-processor interrupt vector */
 
Index: linux/include/asm-ia64/tlbflush.h
=================================--- linux.orig/include/asm-ia64/tlbflush.h	2007-03-27 10:08:06.939648066 -0500
+++ linux/include/asm-ia64/tlbflush.h	2007-03-27 10:15:41.879637065 -0500
@@ -27,9 +27,11 @@ extern void local_flush_tlb_all (void);
 #ifdef CONFIG_SMP
   extern void smp_flush_tlb_all (void);
   extern void smp_flush_tlb_mm (struct mm_struct *mm);
+  extern void smp_flush_tlb_cpumask (cpumask_t xcpumask);
 # define flush_tlb_all()	smp_flush_tlb_all()
 #else
 # define flush_tlb_all()	local_flush_tlb_all()
+# define smp_flush_tlb_cpumask() local_flush_tlb_all()
 #endif
 
 static inline void
@@ -94,6 +96,15 @@ flush_tlb_pgtables (struct mm_struct *mm
 	 */
 }
 
+/*
+ * Flush the local TLB. Invoked from another cpu using an IPI.
+ */
+#ifdef CONFIG_SMP
+void smp_local_flush_tlb(void);
+#else
+#define smp_local_flush_tlb()
+#endif
+
 #define flush_tlb_kernel_range(start, end)	flush_tlb_all()	/* XXX fix me */
 
 #endif /* _ASM_IA64_TLBFLUSH_H */
