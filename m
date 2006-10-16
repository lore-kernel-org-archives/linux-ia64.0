From: Jack Steiner <steiner@sgi.com>
Date: Mon, 16 Oct 2006 21:17:43 +0000
Subject: [PATCH] - Count resched interrupts
Message-Id: <20061016211743.GA24855@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Count the number of "resched" interrupts that each cpu receives.

	Signed-off-by: Jack Steiner <steiner@sgi.com>


Index: linux/arch/ia64/kernel/irq_ia64.c
=================================--- linux.orig/arch/ia64/kernel/irq_ia64.c	2006-10-16 13:22:45.076625369 -0500
+++ linux/arch/ia64/kernel/irq_ia64.c	2006-10-16 13:56:14.262158773 -0500
@@ -180,7 +180,9 @@ ia64_handle_irq (ia64_vector vector, str
 	saved_tpr = ia64_getreg(_IA64_REG_CR_TPR);
 	ia64_srlz_d();
 	while (vector != IA64_SPURIOUS_INT_VECTOR) {
-		if (!IS_RESCHEDULE(vector)) {
+		if (unlikely(IS_RESCHEDULE(vector)))
+			 kstat_this_cpu.irqs[vector]++;
+		else {
 			ia64_setreg(_IA64_REG_CR_TPR, vector);
 			ia64_srlz_d();
 
@@ -225,7 +227,9 @@ void ia64_process_pending_intr(void)
 	  * Perform normal interrupt style processing
 	  */
 	while (vector != IA64_SPURIOUS_INT_VECTOR) {
-		if (!IS_RESCHEDULE(vector)) {
+		if (unlikely(IS_RESCHEDULE(vector)))
+			 kstat_this_cpu.irqs[vector]++;
+		else {
 			struct pt_regs *old_regs = set_irq_regs(NULL);
 
 			ia64_setreg(_IA64_REG_CR_TPR, vector);
@@ -258,11 +262,22 @@ void ia64_process_pending_intr(void)
 #ifdef CONFIG_SMP
 extern irqreturn_t handle_IPI (int irq, void *dev_id);
 
+static irqreturn_t dummy_handler (int irq, void *dev_id)
+{
+	BUG();
+}
+
 static struct irqaction ipi_irqaction = {
 	.handler =	handle_IPI,
 	.flags =	IRQF_DISABLED,
 	.name =		"IPI"
 };
+
+static struct irqaction resched_irqaction = {
+	.handler =	dummy_handler,
+	.flags =	SA_INTERRUPT,
+	.name =		"resched"
+};
 #endif
 
 void
@@ -287,6 +302,7 @@ init_IRQ (void)
 	register_percpu_irq(IA64_SPURIOUS_INT_VECTOR, NULL);
 #ifdef CONFIG_SMP
 	register_percpu_irq(IA64_IPI_VECTOR, &ipi_irqaction);
+	register_percpu_irq(IA64_IPI_RESCHEDULE, &resched_irqaction);
 #endif
 #ifdef CONFIG_PERFMON
 	pfm_init_percpu();
