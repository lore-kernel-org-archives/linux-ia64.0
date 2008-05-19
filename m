From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Mon, 19 May 2008 23:08:08 +0000
Subject: [PATCH 21/23] ia64/pv_ops/xen: implement xen pv_time_ops.
Message-Id: <12112384923990-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12077166302786-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12077166302786-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

implement xen pv_time_ops to account steal time.

Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Signed-off-by: Alex Williamson <alex.williamson@hp.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/xen/Makefile     |    2 +-
 arch/ia64/xen/time.c       |  165 ++++++++++++++++++++++++++++++++++++++++++++
 arch/ia64/xen/time.h       |   23 ++++++
 arch/ia64/xen/xen_pv_ops.c |    2 +
 4 files changed, 191 insertions(+), 1 deletions(-)
 create mode 100644 arch/ia64/xen/time.c
 create mode 100644 arch/ia64/xen/time.h

diff --git a/arch/ia64/xen/Makefile b/arch/ia64/xen/Makefile
index 01c4289..ed31c76 100644
--- a/arch/ia64/xen/Makefile
+++ b/arch/ia64/xen/Makefile
@@ -3,7 +3,7 @@
 #
 
 obj-y := hypercall.o xenivt.o xensetup.o xen_pv_ops.o irq_xen.o \
-	 hypervisor.o xencomm.o xcom_hcall.o grant-table.o
+	 hypervisor.o xencomm.o xcom_hcall.o grant-table.o time.o
 
 AFLAGS_xenivt.o += -D__IA64_ASM_PARAVIRTUALIZED_XEN
 
diff --git a/arch/ia64/xen/time.c b/arch/ia64/xen/time.c
new file mode 100644
index 0000000..43d483d
--- /dev/null
+++ b/arch/ia64/xen/time.c
@@ -0,0 +1,165 @@
+/******************************************************************************
+ * arch/ia64/xen/time.c
+ *
+ * Copyright (c) 2008 Isaku Yamahata <yamahata at valinux co jp>
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
+#include <linux/delay.h>
+#include <linux/kernel_stat.h>
+#include <linux/posix-timers.h>
+#include <linux/irq.h>
+#include <linux/clocksource.h>
+
+#include <asm/xen/hypervisor.h>
+
+#include <xen/interface/vcpu.h>
+
+#include "../kernel/fsyscall_gtod_data.h"
+
+DEFINE_PER_CPU(struct vcpu_runstate_info, runstate);
+DEFINE_PER_CPU(unsigned long, processed_stolen_time);
+DEFINE_PER_CPU(unsigned long, processed_blocked_time);
+
+/* taken from i386/kernel/time-xen.c */
+static void xen_init_missing_ticks_accounting(int cpu)
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
+#define NS_PER_TICK (1000000000LL/HZ)
+
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
+
+static int xen_do_steal_accounting(unsigned long *new_itm)
+{
+	unsigned long delta_itm;
+	delta_itm = consider_steal_time(*new_itm);
+	*new_itm += delta_itm;
+	if (time_after(*new_itm, ia64_get_itc()) && delta_itm)
+		return 1;
+
+	return 0;
+}
+
+static void xen_itc_jitter_data_reset(void)
+{
+	u64 lcycle, ret;
+
+	do {
+		lcycle = itc_jitter_data.itc_lastcycle;
+		ret = cmpxchg(&itc_jitter_data.itc_lastcycle, lcycle, 0);
+	} while (unlikely(ret != lcycle));
+}
+
+struct pv_time_ops xen_time_ops __initdata = {
+	.init_missing_ticks_accounting	= xen_init_missing_ticks_accounting,
+	.do_steal_accounting		= xen_do_steal_accounting,
+	.clocksource_resume		= xen_itc_jitter_data_reset,
+};
diff --git a/arch/ia64/xen/time.h b/arch/ia64/xen/time.h
new file mode 100644
index 0000000..b9c7ec5
--- /dev/null
+++ b/arch/ia64/xen/time.h
@@ -0,0 +1,23 @@
+/******************************************************************************
+ * arch/ia64/xen/time.h
+ *
+ * Copyright (c) 2008 Isaku Yamahata <yamahata at valinux co jp>
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
+extern struct pv_time_ops xen_time_ops __initdata;
diff --git a/arch/ia64/xen/xen_pv_ops.c b/arch/ia64/xen/xen_pv_ops.c
index bfaf42b..482711d 100644
--- a/arch/ia64/xen/xen_pv_ops.c
+++ b/arch/ia64/xen/xen_pv_ops.c
@@ -30,6 +30,7 @@
 #include <asm/xen/privop.h>
 
 #include "irq_xen.h"
+#include "time.h"
 
 /***************************************************************************
  * general info
@@ -355,6 +356,7 @@ xen_setup_pv_ops(void)
 	pv_cpu_ops = xen_cpu_ops;
 	pv_iosapic_ops = xen_iosapic_ops;
 	pv_irq_ops = xen_irq_ops;
+	pv_time_ops = xen_time_ops;
 
 	paravirt_cpu_asm_init(&xen_cpu_asm_switch);
 }
-- 
1.5.3

