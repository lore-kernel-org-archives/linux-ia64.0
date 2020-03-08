From: afzal mohammed <afzal.mohd.ma@gmail.com>
Date: Sun, 08 Mar 2020 12:15:49 +0000
Subject: [PATCH v4] ia64: replace setup_irq() by request_irq()
Message-Id: <20200308120350.19117-1-afzal.mohd.ma@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200304004936.4955-1-afzal.mohd.ma@gmail.com>
In-Reply-To: <20200304004936.4955-1-afzal.mohd.ma@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: afzal mohammed <afzal.mohd.ma@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

request_irq() is preferred over setup_irq(). Invocations of setup_irq()
occur after memory allocators are ready.

Per tglx[1], setup_irq() existed in olden days when allocators were not
ready by the time early interrupts were initialized.

Hence replace setup_irq() by request_irq().

Changing 'ia64_native_register_percpu_irq' decleration to include
'irq_handler_t' as an argument type in arch/ia64/include/asm/hw_irq.h
was causing build error - 'unknown type name 'irq_handler_t''

This was due to below header file sequence,
+ include/interrupt.h
 + include/hardirq.h
  + asm/hardirq.h
   + include/irq.h
    + asm/hw_irq.h
       [ 'ia64_native_register_percpu_irq' declared w/ 'irq_handler_t']
 [ 'irq_handler_t' typedef'ed here in 'include/interrupt.h']

'register_percpu_irq' defined to 'ia64_native_register_percpu_irq' is
the one invoked by the caller, not the latter directly. This was done
to support paravirtualization which was removed around 4 years back.
And 'register_percpu_irq' is invoked only inside 'arch/ia64/kernel'.

So 'register_percpu_irq' define to 'ia64_native_register_percpu_irq' is
removed, instead 'ia64_native_register_percpu_irq' is renamed to
'register_precpu_irq()' & it is directly invoked. Also,
'register_precpu_irq()' is declared in a new header file 'irq.h' inside
'arch/ia64/kernel/', this header file is included by C files invoking
'register_percpu_irq()'.

[1] https://lkml.kernel.org/r/alpine.DEB.2.20.1710191609480.1971@nanos

Signed-off-by: afzal mohammed <afzal.mohd.ma@gmail.com>
---

Link to v3, v2 & v1,
[v3] https://lkml.kernel.org/r/20200304004936.4955-1-afzal.mohd.ma@gmail.com
[v2] https://lkml.kernel.org/r/cover.1582471508.git.afzal.mohd.ma@gmail.com
[v1] https://lkml.kernel.org/r/cover.1581478323.git.afzal.mohd.ma@gmail.com

v4:
 * Fix build errors
 * Include modifications to callers of 'register_percpu_irq()' at two
	instances left out (as it's signature changed)
v3:
 * Split out from tree wide series, as Thomas suggested to get it thr'
	respective maintainers
 * Modify pr_err displayed in case of error
 * Re-arrange code & choose pr_err args as required to improve readability
 * Remove irrelevant parts from commit message & improve
 
v2:
 * Replace pr_err("request_irq() on %s failed" by
           pr_err("%s: request_irq() failed"
 * Commit message massage

 arch/ia64/include/asm/hw_irq.h |  2 --
 arch/ia64/kernel/irq.h         |  3 ++
 arch/ia64/kernel/irq_ia64.c    | 43 ++++++++++-------------------
 arch/ia64/kernel/mca.c         | 50 ++++++++++------------------------
 arch/ia64/kernel/perfmon.c     | 10 +++----
 arch/ia64/kernel/time.c        | 11 ++------
 6 files changed, 39 insertions(+), 80 deletions(-)
 create mode 100644 arch/ia64/kernel/irq.h

diff --git a/arch/ia64/include/asm/hw_irq.h b/arch/ia64/include/asm/hw_irq.h
index e6385c7bdeb0..f6ff95b4ecb1 100644
--- a/arch/ia64/include/asm/hw_irq.h
+++ b/arch/ia64/include/asm/hw_irq.h
@@ -113,7 +113,6 @@ extern struct irq_chip irq_type_ia64_lsapic;	/* CPU-internal interrupt controlle
 #define ia64_register_ipi	ia64_native_register_ipi
 #define assign_irq_vector	ia64_native_assign_irq_vector
 #define free_irq_vector		ia64_native_free_irq_vector
-#define register_percpu_irq	ia64_native_register_percpu_irq
 #define ia64_resend_irq		ia64_native_resend_irq
 
 extern void ia64_native_register_ipi(void);
@@ -123,7 +122,6 @@ extern void ia64_native_free_irq_vector (int vector);
 extern int reserve_irq_vector (int vector);
 extern void __setup_vector_irq(int cpu);
 extern void ia64_send_ipi (int cpu, int vector, int delivery_mode, int redirect);
-extern void ia64_native_register_percpu_irq (ia64_vector vec, struct irqaction *action);
 extern void destroy_and_reserve_irq (unsigned int irq);
 
 #ifdef CONFIG_SMP
diff --git a/arch/ia64/kernel/irq.h b/arch/ia64/kernel/irq.h
new file mode 100644
index 000000000000..4d16f3cbeb1d
--- /dev/null
+++ b/arch/ia64/kernel/irq.h
@@ -0,0 +1,3 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+extern void register_percpu_irq(ia64_vector vec, irq_handler_t handler,
+				unsigned long flags, const char *name);
diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 8e91c86e8072..e7862e4cb1e7 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -351,11 +351,6 @@ static irqreturn_t smp_irq_move_cleanup_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-static struct irqaction irq_move_irqaction = {
-	.handler =	smp_irq_move_cleanup_interrupt,
-	.name =		"irq_move"
-};
-
 static int __init parse_vector_domain(char *arg)
 {
 	if (!arg)
@@ -586,28 +581,15 @@ static irqreturn_t dummy_handler (int irq, void *dev_id)
 	return IRQ_NONE;
 }
 
-static struct irqaction ipi_irqaction = {
-	.handler =	handle_IPI,
-	.name =		"IPI"
-};
-
 /*
  * KVM uses this interrupt to force a cpu out of guest mode
  */
-static struct irqaction resched_irqaction = {
-	.handler =	dummy_handler,
-	.name =		"resched"
-};
-
-static struct irqaction tlb_irqaction = {
-	.handler =	dummy_handler,
-	.name =		"tlb_flush"
-};
 
 #endif
 
 void
-ia64_native_register_percpu_irq (ia64_vector vec, struct irqaction *action)
+register_percpu_irq(ia64_vector vec, irq_handler_t handler, unsigned long flags,
+		    const char *name)
 {
 	unsigned int irq;
 
@@ -615,8 +597,9 @@ ia64_native_register_percpu_irq (ia64_vector vec, struct irqaction *action)
 	BUG_ON(bind_irq_vector(irq, vec, CPU_MASK_ALL));
 	irq_set_status_flags(irq, IRQ_PER_CPU);
 	irq_set_chip(irq, &irq_type_ia64_lsapic);
-	if (action)
-		setup_irq(irq, action);
+	if (handler)
+		if (request_irq(irq, handler, flags, name, NULL))
+			pr_err("Failed to request irq %u (%s)\n", irq, name);
 	irq_set_handler(irq, handle_percpu_irq);
 }
 
@@ -624,9 +607,10 @@ void __init
 ia64_native_register_ipi(void)
 {
 #ifdef CONFIG_SMP
-	register_percpu_irq(IA64_IPI_VECTOR, &ipi_irqaction);
-	register_percpu_irq(IA64_IPI_RESCHEDULE, &resched_irqaction);
-	register_percpu_irq(IA64_IPI_LOCAL_TLB_FLUSH, &tlb_irqaction);
+	register_percpu_irq(IA64_IPI_VECTOR, handle_IPI, 0, "IPI");
+	register_percpu_irq(IA64_IPI_RESCHEDULE, dummy_handler, 0, "resched");
+	register_percpu_irq(IA64_IPI_LOCAL_TLB_FLUSH, dummy_handler, 0,
+			    "tlb_flush");
 #endif
 }
 
@@ -635,10 +619,13 @@ init_IRQ (void)
 {
 	acpi_boot_init();
 	ia64_register_ipi();
-	register_percpu_irq(IA64_SPURIOUS_INT_VECTOR, NULL);
+	register_percpu_irq(IA64_SPURIOUS_INT_VECTOR, NULL, 0, NULL);
 #ifdef CONFIG_SMP
-	if (vector_domain_type != VECTOR_DOMAIN_NONE)
-		register_percpu_irq(IA64_IRQ_MOVE_VECTOR, &irq_move_irqaction);
+	if (vector_domain_type != VECTOR_DOMAIN_NONE) {
+		register_percpu_irq(IA64_IRQ_MOVE_VECTOR,
+				    smp_irq_move_cleanup_interrupt, 0,
+				    "irq_move");
+	}
 #endif
 #ifdef CONFIG_PERFMON
 	pfm_init_percpu();
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index bf2cb9294795..6fb54dfa1350 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -104,6 +104,7 @@
 
 #include "mca_drv.h"
 #include "entry.h"
+#include "irq.h"
 
 #if defined(IA64_MCA_DEBUG_INFO)
 # define IA64_MCA_DEBUG(fmt...)	printk(fmt)
@@ -1766,36 +1767,6 @@ ia64_mca_disable_cpe_polling(char *str)
 
 __setup("disable_cpe_poll", ia64_mca_disable_cpe_polling);
 
-static struct irqaction cmci_irqaction = {
-	.handler =	ia64_mca_cmc_int_handler,
-	.name =		"cmc_hndlr"
-};
-
-static struct irqaction cmcp_irqaction = {
-	.handler =	ia64_mca_cmc_int_caller,
-	.name =		"cmc_poll"
-};
-
-static struct irqaction mca_rdzv_irqaction = {
-	.handler =	ia64_mca_rendez_int_handler,
-	.name =		"mca_rdzv"
-};
-
-static struct irqaction mca_wkup_irqaction = {
-	.handler =	ia64_mca_wakeup_int_handler,
-	.name =		"mca_wkup"
-};
-
-static struct irqaction mca_cpe_irqaction = {
-	.handler =	ia64_mca_cpe_int_handler,
-	.name =		"cpe_hndlr"
-};
-
-static struct irqaction mca_cpep_irqaction = {
-	.handler =	ia64_mca_cpe_int_caller,
-	.name =		"cpe_poll"
-};
-
 /* Minimal format of the MCA/INIT stacks.  The pseudo processes that run on
  * these stacks can never sleep, they cannot return from the kernel to user
  * space, they do not appear in a normal ps listing.  So there is no need to
@@ -2056,18 +2027,23 @@ void __init ia64_mca_irq_init(void)
 	 *  Configure the CMCI/P vector and handler. Interrupts for CMC are
 	 *  per-processor, so AP CMC interrupts are setup in smp_callin() (smpboot.c).
 	 */
-	register_percpu_irq(IA64_CMC_VECTOR, &cmci_irqaction);
-	register_percpu_irq(IA64_CMCP_VECTOR, &cmcp_irqaction);
+	register_percpu_irq(IA64_CMC_VECTOR, ia64_mca_cmc_int_handler, 0,
+			    "cmc_hndlr");
+	register_percpu_irq(IA64_CMCP_VECTOR, ia64_mca_cmc_int_caller, 0,
+			    "cmc_poll");
 	ia64_mca_cmc_vector_setup();       /* Setup vector on BSP */
 
 	/* Setup the MCA rendezvous interrupt vector */
-	register_percpu_irq(IA64_MCA_RENDEZ_VECTOR, &mca_rdzv_irqaction);
+	register_percpu_irq(IA64_MCA_RENDEZ_VECTOR, ia64_mca_rendez_int_handler,
+			    0, "mca_rdzv");
 
 	/* Setup the MCA wakeup interrupt vector */
-	register_percpu_irq(IA64_MCA_WAKEUP_VECTOR, &mca_wkup_irqaction);
+	register_percpu_irq(IA64_MCA_WAKEUP_VECTOR, ia64_mca_wakeup_int_handler,
+			    0, "mca_wkup");
 
 	/* Setup the CPEI/P handler */
-	register_percpu_irq(IA64_CPEP_VECTOR, &mca_cpep_irqaction);
+	register_percpu_irq(IA64_CPEP_VECTOR, ia64_mca_cpe_int_caller, 0,
+			    "cpe_poll");
 }
 
 /*
@@ -2108,7 +2084,9 @@ ia64_mca_late_init(void)
 			if (irq > 0) {
 				cpe_poll_enabled = 0;
 				irq_set_status_flags(irq, IRQ_PER_CPU);
-				setup_irq(irq, &mca_cpe_irqaction);
+				if (request_irq(irq, ia64_mca_cpe_int_handler,
+						0, "cpe_hndlr", NULL))
+					pr_err("Failed to register cpe_hndlr interrupt\n");
 				ia64_cpe_irq = irq;
 				ia64_mca_register_cpev(cpe_vector);
 				IA64_MCA_DEBUG("%s: CPEI/P setup and enabled.\n",
diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index a23c3938a1c4..df257002950e 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -57,6 +57,8 @@
 #include <linux/uaccess.h>
 #include <asm/delay.h>
 
+#include "irq.h"
+
 #ifdef CONFIG_PERFMON
 /*
  * perfmon context state
@@ -6313,11 +6315,6 @@ pfm_flush_pmds(struct task_struct *task, pfm_context_t *ctx)
 	}
 }
 
-static struct irqaction perfmon_irqaction = {
-	.handler = pfm_interrupt_handler,
-	.name    = "perfmon"
-};
-
 static void
 pfm_alt_save_pmu_state(void *data)
 {
@@ -6591,7 +6588,8 @@ pfm_init_percpu (void)
 	pfm_unfreeze_pmu();
 
 	if (first_time) {
-		register_percpu_irq(IA64_PERFMON_VECTOR, &perfmon_irqaction);
+		register_percpu_irq(IA64_PERFMON_VECTOR, pfm_interrupt_handler,
+				    0, "perfmon");
 		first_time=0;
 	}
 
diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index 91b4024c9351..7abc5f37bfaf 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -32,6 +32,7 @@
 #include <asm/sections.h>
 
 #include "fsyscall_gtod_data.h"
+#include "irq.h"
 
 static u64 itc_get_cycles(struct clocksource *cs);
 
@@ -380,13 +381,6 @@ static u64 itc_get_cycles(struct clocksource *cs)
 	return now;
 }
 
-
-static struct irqaction timer_irqaction = {
-	.handler =	timer_interrupt,
-	.flags =	IRQF_IRQPOLL,
-	.name =		"timer"
-};
-
 void read_persistent_clock64(struct timespec64 *ts)
 {
 	efi_gettimeofday(ts);
@@ -395,7 +389,8 @@ void read_persistent_clock64(struct timespec64 *ts)
 void __init
 time_init (void)
 {
-	register_percpu_irq(IA64_TIMER_VECTOR, &timer_irqaction);
+	register_percpu_irq(IA64_TIMER_VECTOR, timer_interrupt, IRQF_IRQPOLL,
+			    "timer");
 	ia64_init_itm();
 }
 
-- 
2.18.0
