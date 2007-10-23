From: Jeff Garzik <jeff@garzik.org>
Date: Tue, 23 Oct 2007 23:09:08 +0000
Subject: [PATCH] IA64/perfmon: kill dead code, clean irq handling
Message-Id: <20071023230908.GA12417@havoc.gtf.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, linux-ia64@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>


By deleting unused code, this makes perfmon irq handling more efficient,
as well as reducing code size.

* remove unused pfm_install_alt_pmu_interrupt()
* remove unused pfm_remove_alt_pmu_interrupt()

* remove now-unused pfm_alt_intr_handler pointer, and associated
  function call in perfmon interrupt handler.

* remove unused 'irq' argument from pfm_do_interrupt_handler()

* un-indent code in pfm_interrupt_handler() now that
  pfm_alt_intr_handler is no longer used.

Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
---
 arch/ia64/kernel/perfmon.c |  123 ++++++---------------------------------------
 include/asm-ia64/perfmon.h |    2 
 2 files changed, 17 insertions(+), 108 deletions(-)

42a3391c5a27b411c80e942853e0b913911119d5
diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 59169bf..12fc846 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -504,9 +504,6 @@ typedef struct {
 static pfm_stats_t		pfm_stats[NR_CPUS];
 static pfm_session_t		pfm_sessions;	/* global sessions information */
 
-static DEFINE_SPINLOCK(pfm_alt_install_check);
-static pfm_intr_handler_desc_t  *pfm_alt_intr_handler;
-
 static struct proc_dir_entry 	*perfmon_dir;
 static pfm_uuid_t		pfm_null_uuid = {0,};
 
@@ -5526,7 +5523,7 @@ stop_monitoring:
 }
 
 static int
-pfm_do_interrupt_handler(int irq, void *arg, struct pt_regs *regs)
+pfm_do_interrupt_handler(void *arg, struct pt_regs *regs)
 {
 	struct task_struct *task;
 	pfm_context_t *ctx;
@@ -5600,30 +5597,28 @@ pfm_interrupt_handler(int irq, void *arg)
 	struct pt_regs *regs = get_irq_regs();
 
 	this_cpu = get_cpu();
-	if (likely(!pfm_alt_intr_handler)) {
-		min = pfm_stats[this_cpu].pfm_ovfl_intr_cycles_min;
-		max = pfm_stats[this_cpu].pfm_ovfl_intr_cycles_max;
 
-		start_cycles = ia64_get_itc();
+	min = pfm_stats[this_cpu].pfm_ovfl_intr_cycles_min;
+	max = pfm_stats[this_cpu].pfm_ovfl_intr_cycles_max;
 
-		ret = pfm_do_interrupt_handler(irq, arg, regs);
+	start_cycles = ia64_get_itc();
 
-		total_cycles = ia64_get_itc();
+	ret = pfm_do_interrupt_handler(arg, regs);
 
-		/*
-		 * don't measure spurious interrupts
-		 */
-		if (likely(ret = 0)) {
-			total_cycles -= start_cycles;
+	total_cycles = ia64_get_itc();
 
-			if (total_cycles < min) pfm_stats[this_cpu].pfm_ovfl_intr_cycles_min = total_cycles;
-			if (total_cycles > max) pfm_stats[this_cpu].pfm_ovfl_intr_cycles_max = total_cycles;
+	/*
+	 * don't measure spurious interrupts
+	 */
+	if (likely(ret = 0)) {
+		total_cycles -= start_cycles;
 
-			pfm_stats[this_cpu].pfm_ovfl_intr_cycles += total_cycles;
-		}
-	}
-	else {
-		(*pfm_alt_intr_handler->handler)(irq, arg, regs);
+		if (total_cycles < min)
+			pfm_stats[this_cpu].pfm_ovfl_intr_cycles_min = total_cycles;
+		if (total_cycles > max)
+			pfm_stats[this_cpu].pfm_ovfl_intr_cycles_max = total_cycles;
+
+		pfm_stats[this_cpu].pfm_ovfl_intr_cycles += total_cycles;
 	}
 
 	put_cpu_no_resched();
@@ -6520,90 +6515,6 @@ pfm_alt_restore_pmu_state(void *data)
 	ia64_srlz_d();
 }
 
-int
-pfm_install_alt_pmu_interrupt(pfm_intr_handler_desc_t *hdl)
-{
-	int ret, i;
-	int reserve_cpu;
-
-	/* some sanity checks */
-	if (hdl = NULL || hdl->handler = NULL) return -EINVAL;
-
-	/* do the easy test first */
-	if (pfm_alt_intr_handler) return -EBUSY;
-
-	/* one at a time in the install or remove, just fail the others */
-	if (!spin_trylock(&pfm_alt_install_check)) {
-		return -EBUSY;
-	}
-
-	/* reserve our session */
-	for_each_online_cpu(reserve_cpu) {
-		ret = pfm_reserve_session(NULL, 1, reserve_cpu);
-		if (ret) goto cleanup_reserve;
-	}
-
-	/* save the current system wide pmu states */
-	ret = on_each_cpu(pfm_alt_save_pmu_state, NULL, 0, 1);
-	if (ret) {
-		DPRINT(("on_each_cpu() failed: %d\n", ret));
-		goto cleanup_reserve;
-	}
-
-	/* officially change to the alternate interrupt handler */
-	pfm_alt_intr_handler = hdl;
-
-	spin_unlock(&pfm_alt_install_check);
-
-	return 0;
-
-cleanup_reserve:
-	for_each_online_cpu(i) {
-		/* don't unreserve more than we reserved */
-		if (i >= reserve_cpu) break;
-
-		pfm_unreserve_session(NULL, 1, i);
-	}
-
-	spin_unlock(&pfm_alt_install_check);
-
-	return ret;
-}
-EXPORT_SYMBOL_GPL(pfm_install_alt_pmu_interrupt);
-
-int
-pfm_remove_alt_pmu_interrupt(pfm_intr_handler_desc_t *hdl)
-{
-	int i;
-	int ret;
-
-	if (hdl = NULL) return -EINVAL;
-
-	/* cannot remove someone else's handler! */
-	if (pfm_alt_intr_handler != hdl) return -EINVAL;
-
-	/* one at a time in the install or remove, just fail the others */
-	if (!spin_trylock(&pfm_alt_install_check)) {
-		return -EBUSY;
-	}
-
-	pfm_alt_intr_handler = NULL;
-
-	ret = on_each_cpu(pfm_alt_restore_pmu_state, NULL, 0, 1);
-	if (ret) {
-		DPRINT(("on_each_cpu() failed: %d\n", ret));
-	}
-
-	for_each_online_cpu(i) {
-		pfm_unreserve_session(NULL, 1, i);
-	}
-
-	spin_unlock(&pfm_alt_install_check);
-
-	return 0;
-}
-EXPORT_SYMBOL_GPL(pfm_remove_alt_pmu_interrupt);
-
 /*
  * perfmon initialization routine, called from the initcall() table
  */
diff --git a/include/asm-ia64/perfmon.h b/include/asm-ia64/perfmon.h
index 7f3333d..811db64 100644
--- a/include/asm-ia64/perfmon.h
+++ b/include/asm-ia64/perfmon.h
@@ -191,8 +191,6 @@ extern void pfm_syst_wide_update_task(struct task_struct *, unsigned long info,
 extern void pfm_inherit(struct task_struct *task, struct pt_regs *regs);
 extern void pfm_init_percpu(void);
 extern void pfm_handle_work(void);
-extern int  pfm_install_alt_pmu_interrupt(pfm_intr_handler_desc_t *h);
-extern int  pfm_remove_alt_pmu_interrupt(pfm_intr_handler_desc_t *h);
 
 
 
