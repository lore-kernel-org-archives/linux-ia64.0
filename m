From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 16 Oct 2007 13:37:46 +0000
Subject: [PATCH 4/9] ia64: VIRT_CPU_ACCOUNTING (accurate cpu time accounting)
Message-Id: <4714BEAA.5050008@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> [4/9] ia64_self_update_process_times.patch

Next, we need to stop sampling in timer interrupt which
used for tick-based cpu time accounting.

Now the stime/utime of threads are updated in a function
update_process_times(), that is called from timer_interrupt().

[arch/ia64/kernel/time.c]
  46 static irqreturn_t
  47 timer_interrupt (int irq, void *dev_id)
  48 {
　:
  65         while (1) {
  66                 update_process_times(user_mode(get_irq_regs()));
　:
  70                 if (smp_processor_id() = time_keeper_id) {
　:
  78                         do_timer(1);
　:
  84                 if (time_after(new_itm, ia64_get_itc()))
  85                         break;
　:
  92         }

This update_process_times() is defined in kernel/timer.c.
Therefore, I copied this function into ia64 region to ready to
modify it as we like.

This patch just do copy. Later change will be done.

Thanks,
H.Seto

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

---
 arch/ia64/kernel/time.c |   30 +++++++++++++++++++++++++++++-
 1 files changed, 29 insertions(+), 1 deletion(-)

Index: linux-2.6.23/arch/ia64/kernel/time.c
=================================--- linux-2.6.23.orig/arch/ia64/kernel/time.c
+++ linux-2.6.23/arch/ia64/kernel/time.c
@@ -61,6 +61,9 @@

 #ifdef CONFIG_VIRT_CPU_ACCOUNTING

+#include <linux/kernel_stat.h>
+#include <linux/posix-timers.h>
+
 /*
  * Account time for a transition between system, hard irq
  * or soft irq state.
@@ -70,6 +73,31 @@

 }

+/*
+ * Called from the timer interrupt handler to charge one tick to the current
+ * process.  user_tick is 1 if the tick is user time, 0 for system.
+ */
+static inline void ia64_update_process_times(int user_tick)
+{
+	struct task_struct *p = current;
+	int cpu = smp_processor_id();
+
+	/* Note: this timer irq context must be accounted for as well. */
+	if (user_tick)
+		account_user_time(p, jiffies_to_cputime(1));
+	else
+		account_system_time(p, HARDIRQ_OFFSET, jiffies_to_cputime(1));
+	run_local_timers();
+	if (rcu_pending(cpu))
+		rcu_check_callbacks(cpu, user_tick);
+	scheduler_tick();
+	run_posix_cpu_timers(p);
+}
+
+#else /* CONFIG_VIRT_CPU_ACCOUNTING */
+
+#define ia64_update_process_times(utick) update_process_times(utick)
+
 #endif /* CONFIG_VIRT_CPU_ACCOUNTING */

 static irqreturn_t
@@ -92,7 +120,7 @@
 	profile_tick(CPU_PROFILING);

 	while (1) {
-		update_process_times(user_mode(get_irq_regs()));
+		ia64_update_process_times(user_mode(get_irq_regs()));

 		new_itm += local_cpu_data->itm_delta;


