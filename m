From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 22 Feb 2008 05:10:43 +0000
Subject: [PATCH 24/28] ia64/xen: time paravirtualization
Message-Id: <1203657047492-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <47BE0508.7080203@goop.org>
In-Reply-To: <47BE0508.7080203@goop.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/time.c |  204 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 204 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index 17fda52..1bb0362 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -29,6 +29,14 @@
 #include <asm/sections.h>
 #include <asm/system.h>
 
+#include <asm/xen/hypervisor.h>
+#ifdef CONFIG_XEN
+#include <linux/kernel_stat.h>
+#include <linux/posix-timers.h>
+#include <xen/interface/vcpu.h>
+#include <asm/percpu.h>
+#endif
+
 #include "fsyscall_gtod_data.h"
 
 static cycle_t itc_get_cycles(void);
@@ -38,6 +46,17 @@ struct fsyscall_gtod_data_t fsyscall_gtod_data = {
 };
 
 struct itc_jitter_data_t itc_jitter_data;
+#ifdef CONFIG_XEN
+static void itc_jitter_data_reset(void)
+{
+	u64 lcycle, ret;
+
+	do {
+		lcycle = itc_jitter_data.itc_lastcycle;
+		ret = cmpxchg(&itc_jitter_data.itc_lastcycle, lcycle, 0);
+	} while (unlikely(ret != lcycle));
+}
+#endif
 
 volatile int time_keeper_id = 0; /* smp_processor_id() of time-keeper */
 
@@ -56,13 +75,105 @@ static struct clocksource clocksource_itc = {
 	.mult           = 0, /*to be calculated*/
 	.shift          = 16,
 	.flags          = CLOCK_SOURCE_IS_CONTINUOUS,
+#ifdef CONFIG_XEN
+	.resume		= itc_jitter_data_reset,
+#endif
 };
 static struct clocksource *itc_clocksource;
 
+#ifdef CONFIG_XEN
+DEFINE_PER_CPU(struct vcpu_runstate_info, runstate);
+DEFINE_PER_CPU(unsigned long, processed_stolen_time);
+DEFINE_PER_CPU(unsigned long, processed_blocked_time);
+#define NS_PER_TICK (1000000000LL/HZ)
+static unsigned long
+consider_steal_time(unsigned long new_itm)
+{
+	unsigned long stolen, blocked, sched_time;
+	unsigned long delta_itm = 0, stolentick = 0;
+	int cpu = smp_processor_id();
+	struct vcpu_runstate_info *runstate;
+	struct task_struct *p = current;
+
+	runstate = &per_cpu(runstate, smp_processor_id());
+
+	do {
+		sched_time = runstate->state_entry_time;
+		mb();
+		stolen = runstate->time[RUNSTATE_runnable] +
+			 runstate->time[RUNSTATE_offline] -
+			 per_cpu(processed_stolen_time, cpu);
+		blocked = runstate->time[RUNSTATE_blocked] -
+			  per_cpu(processed_blocked_time, cpu);
+		mb();
+	} while (sched_time != runstate->state_entry_time);
+
+	/*
+	 * Check for vcpu migration effect
+	 * In this case, itc value is reversed.
+	 * This causes huge stolen value.
+	 * This function just checks and reject this effect.
+	 */
+	if (!time_after_eq(runstate->time[RUNSTATE_blocked],
+			   per_cpu(processed_blocked_time, cpu)))
+		blocked = 0;
+
+	if (!time_after_eq(runstate->time[RUNSTATE_runnable] +
+			   runstate->time[RUNSTATE_offline],
+			   per_cpu(processed_stolen_time, cpu)))
+		stolen = 0;
+
+	if (!time_after(delta_itm + new_itm, ia64_get_itc()))
+		stolentick = ia64_get_itc() - delta_itm - new_itm;
+
+	do_div(stolentick, NS_PER_TICK);
+	stolentick++;
+
+	do_div(stolen, NS_PER_TICK);
+
+	if (stolen > stolentick)
+		stolen = stolentick;
+
+	stolentick -= stolen;
+	do_div(blocked, NS_PER_TICK);
+
+	if (blocked > stolentick)
+		blocked = stolentick;
+
+	if (stolen > 0 || blocked > 0) {
+		account_steal_time(NULL, jiffies_to_cputime(stolen));
+		account_steal_time(idle_task(cpu), jiffies_to_cputime(blocked));
+		run_local_timers();
+
+		if (rcu_pending(cpu))
+			rcu_check_callbacks(cpu, user_mode(get_irq_regs()));
+
+		scheduler_tick();
+		run_posix_cpu_timers(p);
+		delta_itm += local_cpu_data->itm_delta * (stolen + blocked);
+
+		if (cpu = time_keeper_id) {
+			write_seqlock(&xtime_lock);
+			do_timer(stolen + blocked);
+			local_cpu_data->itm_next = delta_itm + new_itm;
+			write_sequnlock(&xtime_lock);
+		} else {
+			local_cpu_data->itm_next = delta_itm + new_itm;
+		}
+		per_cpu(processed_stolen_time, cpu) += NS_PER_TICK * stolen;
+		per_cpu(processed_blocked_time, cpu) += NS_PER_TICK * blocked;
+	}
+	return delta_itm;
+}
+#else
+#define consider_steal_time(new_itm) (0)
+#endif
+
 static irqreturn_t
 timer_interrupt (int irq, void *dev_id)
 {
 	unsigned long new_itm;
+	unsigned long delta_itm; /* XEN */
 
 	if (unlikely(cpu_is_offline(smp_processor_id()))) {
 		return IRQ_HANDLED;
@@ -78,6 +189,13 @@ timer_interrupt (int irq, void *dev_id)
 
 	profile_tick(CPU_PROFILING);
 
+	if (is_running_on_xen()) {
+		delta_itm = consider_steal_time(new_itm);
+		new_itm += delta_itm;
+		if (time_after(new_itm, ia64_get_itc()) && delta_itm)
+			goto skip_process_time_accounting;
+	}
+
 	while (1) {
 		update_process_times(user_mode(get_irq_regs()));
 
@@ -107,6 +225,8 @@ timer_interrupt (int irq, void *dev_id)
 		local_irq_disable();
 	}
 
+skip_process_time_accounting:	/* XEN */
+
 	do {
 		/*
 		 * If we're too close to the next clock tick for
@@ -161,6 +281,84 @@ static int __init nojitter_setup(char *str)
 
 __setup("nojitter", nojitter_setup);
 
+#ifdef CONFIG_XEN
+/* taken from i386/kernel/time-xen.c */
+static void init_missing_ticks_accounting(int cpu)
+{
+	struct vcpu_register_runstate_memory_area area;
+	struct vcpu_runstate_info *runstate = &per_cpu(runstate, cpu);
+	int rc;
+
+	memset(runstate, 0, sizeof(*runstate));
+
+	area.addr.v = runstate;
+	rc = HYPERVISOR_vcpu_op(VCPUOP_register_runstate_memory_area, cpu,
+				&area);
+	WARN_ON(rc && rc != -ENOSYS);
+
+	per_cpu(processed_blocked_time, cpu) = runstate->time[RUNSTATE_blocked];
+	per_cpu(processed_stolen_time, cpu) = runstate->time[RUNSTATE_runnable]
+					    + runstate->time[RUNSTATE_offline];
+}
+
+static int xen_ia64_settimefoday_after_resume;
+
+static int __init __xen_ia64_settimeofday_after_resume(char *str)
+{
+	xen_ia64_settimefoday_after_resume = 1;
+	return 1;
+}
+
+__setup("xen_ia64_settimefoday_after_resume",
+	 __xen_ia64_settimeofday_after_resume);
+
+/* Called after suspend, to resume time.  */
+void
+time_resume(void)
+{
+	unsigned int cpu;
+
+	/* Just trigger a tick.  */
+	ia64_cpu_local_tick();
+
+	if (xen_ia64_settimefoday_after_resume) {
+		/* do_settimeofday() resets timer interplator */
+		struct timespec xen_time;
+		int ret;
+		efi_gettimeofday(&xen_time);
+
+		ret = do_settimeofday(&xen_time);
+		WARN_ON(ret);
+	} else {
+#if 0
+		/* adjust EFI time */
+		struct timespec my_time = CURRENT_TIME;
+		struct timespec xen_time;
+		static timespec diff;
+		struct xen_domctl domctl;
+		int ret;
+
+		efi_gettimeofday(&xen_time);
+		diff = timespec_sub(&xen_time, &my_time);
+		domctl.cmd = XEN_DOMCTL_settimeoffset;
+		domctl.domain = DOMID_SELF;
+		domctl.u.settimeoffset.timeoffset_seconds = diff.tv_sec;
+		ret = HYPERVISOR_domctl_op(&domctl);
+		WARN_ON(ret);
+#endif
+		/* itc_clocksource remembers the last timer status in
+		 * itc_jitter_data. Forget it */
+		clocksource_resume();
+	}
+
+	for_each_online_cpu(cpu)
+		init_missing_ticks_accounting(cpu);
+
+	touch_softlockup_watchdog();
+}
+#else
+#define init_missing_ticks_accounting(cpu) do {} while (0)
+#endif
 
 void __devinit
 ia64_init_itm (void)
@@ -256,6 +454,12 @@ ia64_init_itm (void)
 		 */
 		clocksource_itc.rating = 50;
 
+	if (is_running_on_xen())
+		init_missing_ticks_accounting(smp_processor_id());
+
+	/* avoid softlock up message when cpu is unplug and plugged again. */
+	touch_softlockup_watchdog();
+
 	/* Setup the CPU local timer tick */
 	ia64_cpu_local_tick();
 
-- 
1.5.3

