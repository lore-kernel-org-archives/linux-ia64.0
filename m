From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 30 Apr 2008 12:29:28 +0000
Subject: [PATCH 15/15] ia64/pv_ops: add to hooks, pv_time_ops, for steal time accounting.
Message-Id: <1209558568127-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1207716549108-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1207716549108-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Introduce pv_time_ops which adds hook to steal time accounting.
On virtualized environment, cpus are shared by many guests and
steal time is the time which is used for other guests.
On virtualized environtment, streal time should be accounted.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/paravirt.c |   15 +++++++++++++++
 arch/ia64/kernel/time.c     |   23 +++++++++++++++++++++++
 include/asm-ia64/paravirt.h |   32 ++++++++++++++++++++++++++++++++
 3 files changed, 70 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/paravirt.c b/arch/ia64/kernel/paravirt.c
index ba5383b..afaf5b9 100644
--- a/arch/ia64/kernel/paravirt.c
+++ b/arch/ia64/kernel/paravirt.c
@@ -352,3 +352,18 @@ struct pv_irq_ops pv_irq_ops = {
 
 	.resend_irq = ia64_native_resend_irq,
 };
+
+/***************************************************************************
+ * pv_time_ops
+ * time operations
+ */
+
+static int
+ia64_native_do_steal_accounting(unsigned long *new_itm)
+{
+	return 0;
+}
+
+struct pv_time_ops pv_time_ops = {
+	.do_steal_accounting = ia64_native_do_steal_accounting,
+};
diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index 48e15a5..744247c 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -24,6 +24,7 @@
 #include <asm/machvec.h>
 #include <asm/delay.h>
 #include <asm/hw_irq.h>
+#include <asm/paravirt.h>
 #include <asm/ptrace.h>
 #include <asm/sal.h>
 #include <asm/sections.h>
@@ -48,6 +49,15 @@ EXPORT_SYMBOL(last_cli_ip);
 
 #endif
 
+#ifdef CONFIG_PARAVIRT
+static void
+paravirt_clocksource_resume(void)
+{
+	if (pv_time_ops.clocksource_resume)
+		pv_time_ops.clocksource_resume();
+}
+#endif
+
 static struct clocksource clocksource_itc = {
 	.name           = "itc",
 	.rating         = 350,
@@ -56,6 +66,9 @@ static struct clocksource clocksource_itc = {
 	.mult           = 0, /*to be calculated*/
 	.shift          = 16,
 	.flags          = CLOCK_SOURCE_IS_CONTINUOUS,
+#ifdef CONFIG_PARAVIRT
+	.resume		= paravirt_clocksource_resume,
+#endif
 };
 static struct clocksource *itc_clocksource;
 
@@ -156,6 +169,9 @@ timer_interrupt (int irq, void *dev_id)
 
 	profile_tick(CPU_PROFILING);
 
+	if (paravirt_do_steal_accounting(&new_itm))
+		goto skip_process_time_accounting;
+
 	while (1) {
 		update_process_times(user_mode(get_irq_regs()));
 
@@ -185,6 +201,8 @@ timer_interrupt (int irq, void *dev_id)
 		local_irq_disable();
 	}
 
+skip_process_time_accounting:
+
 	do {
 		/*
 		 * If we're too close to the next clock tick for
@@ -334,6 +352,11 @@ ia64_init_itm (void)
 		 */
 		clocksource_itc.rating = 50;
 
+	paravirt_init_missing_ticks_accounting(smp_processor_id());
+
+	/* avoid softlock up message when cpu is unplug and plugged again. */
+	touch_softlockup_watchdog();
+
 	/* Setup the CPU local timer tick */
 	ia64_cpu_local_tick();
 
diff --git a/include/asm-ia64/paravirt.h b/include/asm-ia64/paravirt.h
index 2203e9a..44017c1 100644
--- a/include/asm-ia64/paravirt.h
+++ b/include/asm-ia64/paravirt.h
@@ -197,6 +197,35 @@ ia64_resend_irq(unsigned int vector)
 	pv_irq_ops.resend_irq(vector);
 }
 
+/******************************************************************************
+ * replacement of time operations.
+ */
+
+extern struct itc_jitter_data_t itc_jitter_data;
+extern volatile int time_keeper_id;
+
+struct pv_time_ops {
+	void (*init_missing_ticks_accounting)(int cpu);
+	int (*do_steal_accounting)(unsigned long *new_itm);
+
+	void (*clocksource_resume)(void);
+};
+
+extern struct pv_time_ops pv_time_ops;
+
+static inline void
+paravirt_init_missing_ticks_accounting(int cpu)
+{
+	if (pv_time_ops.init_missing_ticks_accounting)
+		pv_time_ops.init_missing_ticks_accounting(cpu);
+}
+
+static inline int
+paravirt_do_steal_accounting(unsigned long *new_itm)
+{
+	return pv_time_ops.do_steal_accounting(new_itm);
+}
+
 #endif /* !__ASSEMBLY__ */
 
 #else
@@ -212,6 +241,9 @@ ia64_resend_irq(unsigned int vector)
 #define paravirt_arch_setup_nomca()			0
 #define paravirt_post_smp_prepare_boot_cpu()		do { } while (0)
 
+#define paravirt_init_missing_ticks_accounting(cpu)	do { } while (0)
+#define paravirt_do_steal_accounting(new_itm)		0
+
 #endif /* __ASSEMBLY__ */
 
 
-- 
1.5.3

