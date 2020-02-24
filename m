From: afzal mohammed <afzal.mohd.ma@gmail.com>
Date: Mon, 24 Feb 2020 00:49:58 +0000
Subject: [PATCH v2 05/18] ia64: replace setup_irq() by request_irq()
Message-Id: <336789c09434b468a2443f5cb2063e2530ca4a1e.1582471508.git.afzal.mohd.ma@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1582471508.git.afzal.mohd.ma@gmail.com>
In-Reply-To: <cover.1582471508.git.afzal.mohd.ma@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Tom Vaden <tom.vaden@hpe.com>, Mike Rapoport <rppt@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

request_irq() is preferred over setup_irq(). The early boot setup_irq()
invocations happen either via 'init_IRQ()' or 'time_init()', while
memory allocators are ready by 'mm_init()'.

Per tglx[1], setup_irq() existed in olden days when allocators were not
ready by the time early interrupts were initialized.

Hence replace setup_irq() by request_irq().

Seldom remove_irq() usage has been observed coupled with setup_irq(),
wherever that has been found, it too has been replaced by free_irq().

[1] https://lkml.kernel.org/r/alpine.DEB.2.20.1710191609480.1971@nanos

Signed-off-by: afzal mohammed <afzal.mohd.ma@gmail.com>
---

v2:
 * Replace pr_err("request_irq() on %s failed" by
           pr_err("%s: request_irq() failed"
 * Commit message massage

 arch/ia64/kernel/irq_ia64.c | 42 ++++++++++--------------------
 arch/ia64/kernel/mca.c      | 51 +++++++++++--------------------------
 2 files changed, 29 insertions(+), 64 deletions(-)

diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 8e91c86e8072..166a38dae663 100644
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
+ia64_native_register_percpu_irq(ia64_vector vec, const char *name,
+				irq_handler_t handler)
 {
 	unsigned int irq;
 
@@ -615,8 +597,9 @@ ia64_native_register_percpu_irq (ia64_vector vec, struct irqaction *action)
 	BUG_ON(bind_irq_vector(irq, vec, CPU_MASK_ALL));
 	irq_set_status_flags(irq, IRQ_PER_CPU);
 	irq_set_chip(irq, &irq_type_ia64_lsapic);
-	if (action)
-		setup_irq(irq, action);
+	if (handler)
+		if (request_irq(irq, handler, 0, name, NULL))
+			pr_err("request_irq() for %s failed", name);
 	irq_set_handler(irq, handle_percpu_irq);
 }
 
@@ -624,9 +607,10 @@ void __init
 ia64_native_register_ipi(void)
 {
 #ifdef CONFIG_SMP
-	register_percpu_irq(IA64_IPI_VECTOR, &ipi_irqaction);
-	register_percpu_irq(IA64_IPI_RESCHEDULE, &resched_irqaction);
-	register_percpu_irq(IA64_IPI_LOCAL_TLB_FLUSH, &tlb_irqaction);
+	register_percpu_irq(IA64_IPI_VECTOR, "IPI", handle_IPI);
+	register_percpu_irq(IA64_IPI_RESCHEDULE, "resched", dummy_handler);
+	register_percpu_irq(IA64_IPI_LOCAL_TLB_FLUSH, "tlb_flush",
+			    dummy_handler);
 #endif
 }
 
@@ -635,10 +619,12 @@ init_IRQ (void)
 {
 	acpi_boot_init();
 	ia64_register_ipi();
-	register_percpu_irq(IA64_SPURIOUS_INT_VECTOR, NULL);
+	register_percpu_irq(IA64_SPURIOUS_INT_VECTOR, NULL, NULL);
 #ifdef CONFIG_SMP
-	if (vector_domain_type != VECTOR_DOMAIN_NONE)
-		register_percpu_irq(IA64_IRQ_MOVE_VECTOR, &irq_move_irqaction);
+	if (vector_domain_type != VECTOR_DOMAIN_NONE) {
+		register_percpu_irq(IA64_IRQ_MOVE_VECTOR, "irq_move",
+				    smp_irq_move_cleanup_interrupt);
+	}
 #endif
 #ifdef CONFIG_PERFMON
 	pfm_init_percpu();
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index bf2cb9294795..e3d12b376f92 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -1766,36 +1766,6 @@ ia64_mca_disable_cpe_polling(char *str)
 
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
@@ -2056,18 +2026,23 @@ void __init ia64_mca_irq_init(void)
 	 *  Configure the CMCI/P vector and handler. Interrupts for CMC are
 	 *  per-processor, so AP CMC interrupts are setup in smp_callin() (smpboot.c).
 	 */
-	register_percpu_irq(IA64_CMC_VECTOR, &cmci_irqaction);
-	register_percpu_irq(IA64_CMCP_VECTOR, &cmcp_irqaction);
+	register_percpu_irq(IA64_CMC_VECTOR, "cmc_hndlr",
+			    ia64_mca_cmc_int_handler);
+	register_percpu_irq(IA64_CMCP_VECTOR, "cmc_poll",
+			    ia64_mca_cmc_int_caller);
 	ia64_mca_cmc_vector_setup();       /* Setup vector on BSP */
 
 	/* Setup the MCA rendezvous interrupt vector */
-	register_percpu_irq(IA64_MCA_RENDEZ_VECTOR, &mca_rdzv_irqaction);
+	register_percpu_irq(IA64_MCA_RENDEZ_VECTOR, "mca_rdzv",
+			    ia64_mca_rendez_int_handler);
 
 	/* Setup the MCA wakeup interrupt vector */
-	register_percpu_irq(IA64_MCA_WAKEUP_VECTOR, &mca_wkup_irqaction);
+	register_percpu_irq(IA64_MCA_WAKEUP_VECTOR, "mca_wkup",
+			    ia64_mca_wakeup_int_handler);
 
 	/* Setup the CPEI/P handler */
-	register_percpu_irq(IA64_CPEP_VECTOR, &mca_cpep_irqaction);
+	register_percpu_irq(IA64_CPEP_VECTOR, "cpe_poll",
+			    ia64_mca_cpe_int_caller);
 }
 
 /*
@@ -2108,7 +2083,11 @@ ia64_mca_late_init(void)
 			if (irq > 0) {
 				cpe_poll_enabled = 0;
 				irq_set_status_flags(irq, IRQ_PER_CPU);
-				setup_irq(irq, &mca_cpe_irqaction);
+				if (request_irq(irq, ia64_mca_cpe_int_handler,
+						0, "cpe_hndlr", NULL)) {
+					pr_err("%s: request_irq() failed\n",
+					       "cpe_hndlr");
+				}
 				ia64_cpe_irq = irq;
 				ia64_mca_register_cpev(cpe_vector);
 				IA64_MCA_DEBUG("%s: CPEI/P setup and enabled.\n",
-- 
2.25.1
