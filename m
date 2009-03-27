From: Jes Sorensen <jes@sgi.com>
Date: Fri, 27 Mar 2009 15:55:41 +0000
Subject: [patch] kstat_this_cpu breakage in Linus' tree
Message-Id: <49CCF6FD.5010008@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------030403090302030408000903"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------030403090302030408000903
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

Due to a patch getting pulled in overnight, Linus' kernel failed to
build here. Not sure if anybody else already fixed this, if so feel
free to just hit delete here. Otherwise here's a patch that boots for
me - thought it could be I got something wrong :-)

Cheers,
Jes

--------------030403090302030408000903
Content-Type: text/x-patch;
 name="4000-ia64-fix-kstat-irq.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="4000-ia64-fix-kstat-irq.patch"

Fix build breakage due to recent kstat_this_cpu changes in
d7e51e66899f95dabc89b4d4c6674a6e50fa37fc

Signed-off-by: Jes Sorensen <jes@sgi.com>


---
 arch/ia64/kernel/irq_ia64.c |   24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

Index: linux-2.6.git/arch/ia64/kernel/irq_ia64.c
===================================================================
--- linux-2.6.git.orig/arch/ia64/kernel/irq_ia64.c
+++ linux-2.6.git/arch/ia64/kernel/irq_ia64.c
@@ -493,14 +493,16 @@
 	saved_tpr = ia64_getreg(_IA64_REG_CR_TPR);
 	ia64_srlz_d();
 	while (vector != IA64_SPURIOUS_INT_VECTOR) {
+		struct irq_desc *desc;
+		int irq = local_vector_to_irq(vector);
+
+		desc = irq_desc + irq;
 		if (unlikely(IS_LOCAL_TLB_FLUSH(vector))) {
 			smp_local_flush_tlb();
-			kstat_this_cpu.irqs[vector]++;
+			kstat_incr_irqs_this_cpu(irq, desc);
 		} else if (unlikely(IS_RESCHEDULE(vector)))
-			kstat_this_cpu.irqs[vector]++;
+			kstat_incr_irqs_this_cpu(irq, desc);
 		else {
-			int irq = local_vector_to_irq(vector);
-
 			ia64_setreg(_IA64_REG_CR_TPR, vector);
 			ia64_srlz_d();
 
@@ -543,22 +545,24 @@
 
 	vector = ia64_get_ivr();
 
-	 irq_enter();
-	 saved_tpr = ia64_getreg(_IA64_REG_CR_TPR);
-	 ia64_srlz_d();
+	irq_enter();
+	saved_tpr = ia64_getreg(_IA64_REG_CR_TPR);
+	ia64_srlz_d();
 
 	 /*
 	  * Perform normal interrupt style processing
 	  */
 	while (vector != IA64_SPURIOUS_INT_VECTOR) {
+		struct irq_desc *desc;
+		int irq = local_vector_to_irq(vector);
+		desc = irq_desc + irq;
 		if (unlikely(IS_LOCAL_TLB_FLUSH(vector))) {
 			smp_local_flush_tlb();
-			kstat_this_cpu.irqs[vector]++;
+			kstat_incr_irqs_this_cpu(irq, desc);
 		} else if (unlikely(IS_RESCHEDULE(vector)))
-			kstat_this_cpu.irqs[vector]++;
+			kstat_incr_irqs_this_cpu(irq, desc);
 		else {
 			struct pt_regs *old_regs = set_irq_regs(NULL);
-			int irq = local_vector_to_irq(vector);
 
 			ia64_setreg(_IA64_REG_CR_TPR, vector);
 			ia64_srlz_d();

--------------030403090302030408000903--
