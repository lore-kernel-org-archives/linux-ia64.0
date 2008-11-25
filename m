From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 25 Nov 2008 12:57:51 +0000
Subject: [PATCH 08/13] ia64/pv_ops/xen/pv_time_ops: implement sched_clock.
Message-Id: <1227618131-3755-9-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

paravirtualize sched_clock.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/xen/Kconfig |    1 +
 arch/ia64/xen/time.c  |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 49 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/xen/Kconfig b/arch/ia64/xen/Kconfig
index f1683a2..48839da 100644
--- a/arch/ia64/xen/Kconfig
+++ b/arch/ia64/xen/Kconfig
@@ -8,6 +8,7 @@ config XEN
 	depends on PARAVIRT && MCKINLEY && IA64_PAGE_SIZE_16KB && EXPERIMENTAL
 	select XEN_XENCOMM
 	select NO_IDLE_HZ
+	select HAVE_UNSTABLE_SCHED_CLOCK
 
 	# those are required to save/restore.
 	select ARCH_SUSPEND_POSSIBLE
diff --git a/arch/ia64/xen/time.c b/arch/ia64/xen/time.c
index d15a94c..c85d319 100644
--- a/arch/ia64/xen/time.c
+++ b/arch/ia64/xen/time.c
@@ -175,10 +175,58 @@ static void xen_itc_jitter_data_reset(void)
 	} while (unlikely(ret != lcycle));
 }
 
+/* based on xen_sched_clock() in arch/x86/xen/time.c. */
+/*
+ * This relies on HAVE_UNSTABLE_SCHED_CLOCK. If it can't be defined,
+ * something similar logic should be implemented here.
+ */
+/*
+ * Xen sched_clock implementation.  Returns the number of unstolen
+ * nanoseconds, which is nanoseconds the VCPU spent in RUNNING+BLOCKED
+ * states.
+ */
+static unsigned long long xen_sched_clock(void)
+{
+	struct vcpu_runstate_info runstate;
+
+	unsigned long long now;
+	unsigned long long offset;
+	unsigned long long ret;
+
+	/*
+	 * Ideally sched_clock should be called on a per-cpu basis
+	 * anyway, so preempt should already be disabled, but that's
+	 * not current practice at the moment.
+	 */
+	preempt_disable();
+
+	/*
+	 * both ia64_native_sched_clock() and xen's runstate are
+	 * based on mAR.ITC. So difference of them makes sense.
+	 */
+	now = ia64_native_sched_clock();
+
+	get_runstate_snapshot(&runstate);
+
+	WARN_ON(runstate.state != RUNSTATE_running);
+
+	offset = 0;
+	if (now > runstate.state_entry_time)
+		offset = now - runstate.state_entry_time;
+	ret = runstate.time[RUNSTATE_blocked] +
+		runstate.time[RUNSTATE_running] +
+		offset;
+
+	preempt_enable();
+
+	return ret;
+}
+
 struct pv_time_ops xen_time_ops __initdata = {
 	.init_missing_ticks_accounting	= xen_init_missing_ticks_accounting,
 	.do_steal_accounting		= xen_do_steal_accounting,
 	.clocksource_resume		= xen_itc_jitter_data_reset,
+	.sched_clock			= xen_sched_clock,
 };
 
 /* Called after suspend, to resume time.  */
-- 
1.6.0.2

