From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 17 Apr 2008 08:00:37 +0000
Subject: [PATCH 2/2] ia64: simplify notify hooks in mca.c
Message-Id: <480703A5.2020908@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

(this patch is made against tony's git/test tree)

There are many notify_die() and almost all take same style with
ia64_mca_spin().  This patch defines macros and replace them all,
to reduce lines and to improve readability.

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
---
 arch/ia64/kernel/crash.c |    4 +-
 arch/ia64/kernel/mca.c   |   74 +++++++++++++++++++++------------------------
 include/asm-ia64/mca.h   |    1 +
 3 files changed, 38 insertions(+), 41 deletions(-)

diff --git a/arch/ia64/kernel/crash.c b/arch/ia64/kernel/crash.c
index e74e15a..83233a2 100644
--- a/arch/ia64/kernel/crash.c
+++ b/arch/ia64/kernel/crash.c
@@ -193,8 +193,8 @@ kdump_init_notifier(struct notifier_block *self, unsigned long val, void *data)
 			unw_init_running(kdump_cpu_freeze, NULL);
 		break;
 	case DIE_MCA_MONARCH_LEAVE:
-		/* die_register->signr indicate if MCA is recoverable */
-		if (kdump_on_fatal_mca && !args->signr) {
+		/* *(nd->data) indicate if MCA is recoverable */
+		if (kdump_on_fatal_mca && !(*(nd->data))) {
 			atomic_set(&kdump_in_progress, 1);
 			*(nd->monarch_cpu) = -1;
 			machine_kdump_on_init();
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 3ba091b..705176b 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -109,6 +109,20 @@
 # define IA64_MCA_DEBUG(fmt...)
 #endif

+#define NOTIFY_INIT(event, regs, arg, spin)				\
+do {									\
+	if ((notify_die((event), "INIT", (regs), (arg), 0, 0)		\
+			= NOTIFY_STOP) && ((spin) = 1))		\
+		ia64_mca_spin(__func__);				\
+} while (0)
+
+#define NOTIFY_MCA(event, regs, arg, spin)				\
+do {									\
+	if ((notify_die((event), "MCA", (regs), (arg), 0, 0)		\
+			= NOTIFY_STOP) && ((spin) = 1))		\
+		ia64_mca_spin(__func__);				\
+} while (0)
+
 /* Used by mca_asm.S */
 DEFINE_PER_CPU(u64, ia64_mca_data); /* = __per_cpu_mca[smp_processor_id()] */
 DEFINE_PER_CPU(u64, ia64_mca_per_cpu_pte); /* PTE to map per-CPU area */
@@ -766,9 +780,8 @@ ia64_mca_rendez_int_handler(int rendez_irq, void *arg)

 	/* Mask all interrupts */
 	local_irq_save(flags);
-	if (notify_die(DIE_MCA_RENDZVOUS_ENTER, "MCA", get_irq_regs(),
-		       (long)&nd, 0, 0) = NOTIFY_STOP)
-		ia64_mca_spin(__func__);
+
+	NOTIFY_MCA(DIE_MCA_RENDZVOUS_ENTER, get_irq_regs(), (long)&nd, 1);

 	ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_DONE;
 	/* Register with the SAL monarch that the slave has
@@ -776,17 +789,13 @@ ia64_mca_rendez_int_handler(int rendez_irq, void *arg)
 	 */
 	ia64_sal_mc_rendez();

-	if (notify_die(DIE_MCA_RENDZVOUS_PROCESS, "MCA", get_irq_regs(),
-		       (long)&nd, 0, 0) = NOTIFY_STOP)
-		ia64_mca_spin(__func__);
+	NOTIFY_MCA(DIE_MCA_RENDZVOUS_PROCESS, get_irq_regs(), (long)&nd, 1);

 	/* Wait for the monarch cpu to exit. */
 	while (monarch_cpu != -1)
 	       cpu_relax();	/* spin until monarch leaves */

-	if (notify_die(DIE_MCA_RENDZVOUS_LEAVE, "MCA", get_irq_regs(),
-		       (long)&nd, 0, 0) = NOTIFY_STOP)
-		ia64_mca_spin(__func__);
+	NOTIFY_MCA(DIE_MCA_RENDZVOUS_LEAVE, get_irq_regs(), (long)&nd, 1);

 	ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
 	/* Enable all interrupts */
@@ -1256,7 +1265,7 @@ ia64_mca_handler(struct pt_regs *regs, struct switch_stack *sw,
 	int recover, cpu = smp_processor_id();
 	struct task_struct *previous_current;
 	struct ia64_mca_notify_die nd -		{ .sos = sos, .monarch_cpu = &monarch_cpu };
+		{ .sos = sos, .monarch_cpu = &monarch_cpu, .data = &recover };
 	static atomic_t mca_count;
 	static cpumask_t mca_cpu;

@@ -1272,9 +1281,7 @@ ia64_mca_handler(struct pt_regs *regs, struct switch_stack *sw,

 	previous_current = ia64_mca_modify_original_stack(regs, sw, sos, "MCA");

-	if (notify_die(DIE_MCA_MONARCH_ENTER, "MCA", regs, (long)&nd, 0, 0)
-			= NOTIFY_STOP)
-		ia64_mca_spin(__func__);
+	NOTIFY_MCA(DIE_MCA_MONARCH_ENTER, regs, (long)&nd, 1);

 	ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_CONCURRENT_MCA;
 	if (sos->monarch) {
@@ -1293,9 +1300,7 @@ ia64_mca_handler(struct pt_regs *regs, struct switch_stack *sw,
 			cpu_relax();	/* spin until monarch wakes us */
 	}

-	if (notify_die(DIE_MCA_MONARCH_PROCESS, "MCA", regs, (long)&nd, 0, 0)
-			= NOTIFY_STOP)
-		ia64_mca_spin(__func__);
+	NOTIFY_MCA(DIE_MCA_MONARCH_PROCESS, regs, (long)&nd, 1);

 	/* Get the MCA error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA);
@@ -1321,9 +1326,7 @@ ia64_mca_handler(struct pt_regs *regs, struct switch_stack *sw,
 		mca_insert_tr(0x2); /*Reload dynamic itrs*/
 	}

-	if (notify_die(DIE_MCA_MONARCH_LEAVE, "MCA", regs, (long)&nd, 0, recover)
-			= NOTIFY_STOP)
-		ia64_mca_spin(__func__);
+	NOTIFY_MCA(DIE_MCA_MONARCH_LEAVE, regs, (long)&nd, 1);

 	if (atomic_dec_return(&mca_count) > 0) {
 		int i;
@@ -1644,7 +1647,7 @@ ia64_init_handler(struct pt_regs *regs, struct switch_stack *sw,
 	struct ia64_mca_notify_die nd  		{ .sos = sos, .monarch_cpu = &monarch_cpu };

-	(void) notify_die(DIE_INIT_ENTER, "INIT", regs, (long)&nd, 0, 0);
+	NOTIFY_INIT(DIE_INIT_ENTER, regs, (long)&nd, 0);

 	mprintk(KERN_INFO "Entered OS INIT handler. PSP=%lx cpu=%d monarch=%ld\n",
 		sos->proc_state_param, cpu, sos->monarch);
@@ -1681,17 +1684,15 @@ ia64_init_handler(struct pt_regs *regs, struct switch_stack *sw,
 		ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_INIT;
 		while (monarch_cpu = -1)
 		       cpu_relax();	/* spin until monarch enters */
-		if (notify_die(DIE_INIT_SLAVE_ENTER, "INIT", regs, (long)&nd, 0, 0)
-				= NOTIFY_STOP)
-			ia64_mca_spin(__func__);
-		if (notify_die(DIE_INIT_SLAVE_PROCESS, "INIT", regs, (long)&nd, 0, 0)
-				= NOTIFY_STOP)
-			ia64_mca_spin(__func__);
+
+		NOTIFY_INIT(DIE_INIT_SLAVE_ENTER, regs, (long)&nd, 1);
+		NOTIFY_INIT(DIE_INIT_SLAVE_PROCESS, regs, (long)&nd, 1);
+
 		while (monarch_cpu != -1)
 		       cpu_relax();	/* spin until monarch leaves */
-		if (notify_die(DIE_INIT_SLAVE_LEAVE, "INIT", regs, (long)&nd, 0, 0)
-				= NOTIFY_STOP)
-			ia64_mca_spin(__func__);
+
+		NOTIFY_INIT(DIE_INIT_SLAVE_LEAVE, regs, (long)&nd, 1);
+
 		mprintk("Slave on cpu %d returning to normal service.\n", cpu);
 		set_curr_task(cpu, previous_current);
 		ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
@@ -1700,9 +1701,7 @@ ia64_init_handler(struct pt_regs *regs, struct switch_stack *sw,
 	}

 	monarch_cpu = cpu;
-	if (notify_die(DIE_INIT_MONARCH_ENTER, "INIT", regs, (long)&nd, 0, 0)
-			= NOTIFY_STOP)
-		ia64_mca_spin(__func__);
+	NOTIFY_INIT(DIE_INIT_MONARCH_ENTER, regs, (long)&nd, 1);

 	/*
 	 * Wait for a bit.  On some machines (e.g., HP's zx2000 and zx6000, INIT can be
@@ -1717,12 +1716,9 @@ ia64_init_handler(struct pt_regs *regs, struct switch_stack *sw,
 	 * to default_monarch_init_process() above and just print all the
 	 * tasks.
 	 */
-	if (notify_die(DIE_INIT_MONARCH_PROCESS, "INIT", regs, (long)&nd, 0, 0)
-			= NOTIFY_STOP)
-		ia64_mca_spin(__func__);
-	if (notify_die(DIE_INIT_MONARCH_LEAVE, "INIT", regs, (long)&nd, 0, 0)
-			= NOTIFY_STOP)
-		ia64_mca_spin(__func__);
+	NOTIFY_INIT(DIE_INIT_MONARCH_PROCESS, regs, (long)&nd, 1);
+	NOTIFY_INIT(DIE_INIT_MONARCH_LEAVE, regs, (long)&nd, 1);
+
 	mprintk("\nINIT dump complete.  Monarch on cpu %d returning to normal service.\n", cpu);
 	atomic_dec(&monarchs);
 	set_curr_task(cpu, previous_current);
@@ -1954,7 +1950,7 @@ ia64_mca_init(void)
 			printk(KERN_INFO "Increasing MCA rendezvous timeout from "
 				"%ld to %ld milliseconds\n", timeout, isrv.v0);
 			timeout = isrv.v0;
-			(void) notify_die(DIE_MCA_NEW_TIMEOUT, "MCA", NULL, timeout, 0, 0);
+			NOTIFY_MCA(DIE_MCA_NEW_TIMEOUT, NULL, timeout, 0);
 			continue;
 		}
 		printk(KERN_ERR "Failed to register rendezvous interrupt "
diff --git a/include/asm-ia64/mca.h b/include/asm-ia64/mca.h
index f1663aa..18a4321 100644
--- a/include/asm-ia64/mca.h
+++ b/include/asm-ia64/mca.h
@@ -157,6 +157,7 @@ extern void ia64_mca_printk(const char * fmt, ...)
 struct ia64_mca_notify_die {
 	struct ia64_sal_os_state *sos;
 	int *monarch_cpu;
+	int *data;
 };

 DECLARE_PER_CPU(u64, ia64_mca_pal_base);

