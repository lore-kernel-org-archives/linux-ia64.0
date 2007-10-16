From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 16 Oct 2007 13:41:48 +0000
Subject: [PATCH 9/9] ia64: VIRT_CPU_ACCOUNTING (accurate cpu time accounting)
Message-Id: <4714BF9C.6090308@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> [9/9] ia64_acct_get_vtime.patch

Now all check points are ready.

We already cumulate cycles for stime/utime on kernel
entrance/exit, so what we need to do is reflecting them
into stime/utime of the thread, after translating cycles
to nsec.

As I already mentioned, this reflection are required to
be done in:

 - context switch
 - account_system_vtime()
    - irq_enter
    - irq_exit
    - softirq entrance
    - softirq exit

From these points, we add calls of followings:
　account_system_time()
　account_user_time()
to reflect the state-transition based cpu time.
And beside of this, we delete these calls from timer_interrupt
not to reflect the tick-sampling based cpu time.

After all, we get feature of VIRT_CPU_ACCOUNTING on ia64.

Thanks,
H.Seto

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

---
 arch/ia64/kernel/time.c |   47 ++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 42 insertions(+), 5 deletions(-)

Index: linux-2.6.23/arch/ia64/kernel/time.c
=================================--- linux-2.6.23.orig/arch/ia64/kernel/time.c
+++ linux-2.6.23/arch/ia64/kernel/time.c
@@ -64,9 +64,32 @@
 #include <linux/kernel_stat.h>
 #include <linux/posix-timers.h>

+#define cycle_to_cputime(cyc)	\
+  (cputime_t)(((cyc)*local_cpu_data->nsec_per_cyc) >> IA64_NSEC_PER_CYC_SHIFT)
+
 void ia64_account_on_switch(struct task_struct *prev, struct task_struct *next)
 {
+	struct thread_info *pi = task_thread_info(prev);
+	struct thread_info *ni = task_thread_info(next);
+	unsigned long flags;
+	__u64 now;
+
+	local_irq_save(flags);
+
+	now = ia64_get_itc();
+
+	account_system_time(prev, 0,
+			cycle_to_cputime(pi->ac_stime + (now - pi->ac_stamp)));
+	pi->ac_stime = 0;
+
+	if (pi->ac_utime) {
+		account_user_time(prev, cycle_to_cputime(pi->ac_utime));
+		pi->ac_utime = 0;
+	}
+
+	pi->ac_stamp = ni->ac_stamp = now;

+	local_irq_restore(flags);
 }

 /*
@@ -75,7 +98,26 @@
  */
 void account_system_vtime(struct task_struct *tsk)
 {
+	struct thread_info *ti = task_thread_info(tsk);
+	unsigned long flags;
+	__u64 now;
+
+	local_irq_save(flags);
+
+	now = ia64_get_itc();
+
+	account_system_time(tsk, 0,
+			cycle_to_cputime(ti->ac_stime + (now - ti->ac_stamp)));
+	ti->ac_stime = 0;
+
+	if (ti->ac_utime) {
+		account_user_time(tsk, cycle_to_cputime(ti->ac_utime));
+		ti->ac_utime = 0;
+	}
+
+	ti->ac_stamp = now;

+	local_irq_restore(flags);
 }

 /*
@@ -87,11 +129,6 @@
 	struct task_struct *p = current;
 	int cpu = smp_processor_id();

-	/* Note: this timer irq context must be accounted for as well. */
-	if (user_tick)
-		account_user_time(p, jiffies_to_cputime(1));
-	else
-		account_system_time(p, HARDIRQ_OFFSET, jiffies_to_cputime(1));
 	run_local_timers();
 	if (rcu_pending(cpu))
 		rcu_check_callbacks(cpu, user_tick);



