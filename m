From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 09 Apr 2008 04:49:07 +0000
Subject: [PATCH 14/15] ia64/pv_ops: add hooks, pv_irq_ops, to paravirtualized irq related operations.
Message-Id: <12077165493286-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

introduce pv_irq_ops which adds hooks to paravirtualize irq related
operations.
On virtualized environment, interruption may be replaced by something
virtualization friendly. So the irq related operation also may need
paravirtualization.
This patch adds necessary hooks to paravirtualize irq related operations.

Signed-off-by: Yaozu (Eddie) Dong <eddie.dong@intel.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/irq_ia64.c |   18 +++++++++++----
 arch/ia64/kernel/paravirt.c |   15 +++++++++++++
 include/asm-ia64/hw_irq.h   |   23 +++++++++++++++++---
 include/asm-ia64/paravirt.h |   48 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 95 insertions(+), 9 deletions(-)

diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 711635d..d5e2a14 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -196,7 +196,7 @@ static void clear_irq_vector(int irq)
 }
 
 int
-assign_irq_vector (int irq)
+ia64_native_assign_irq_vector (int irq)
 {
 	unsigned long flags;
 	int vector, cpu;
@@ -222,7 +222,7 @@ assign_irq_vector (int irq)
 }
 
 void
-free_irq_vector (int vector)
+ia64_native_free_irq_vector (int vector)
 {
 	if (vector < IA64_FIRST_DEVICE_VECTOR ||
 	    vector > IA64_LAST_DEVICE_VECTOR)
@@ -622,7 +622,7 @@ static struct irqaction tlb_irqaction = {
 #endif
 
 void
-register_percpu_irq (ia64_vector vec, struct irqaction *action)
+ia64_native_register_percpu_irq (ia64_vector vec, struct irqaction *action)
 {
 	irq_desc_t *desc;
 	unsigned int irq;
@@ -637,13 +637,21 @@ register_percpu_irq (ia64_vector vec, struct irqaction *action)
 }
 
 void __init
-init_IRQ (void)
+ia64_native_register_ipi(void)
 {
-	register_percpu_irq(IA64_SPURIOUS_INT_VECTOR, NULL);
 #ifdef CONFIG_SMP
 	register_percpu_irq(IA64_IPI_VECTOR, &ipi_irqaction);
 	register_percpu_irq(IA64_IPI_RESCHEDULE, &resched_irqaction);
 	register_percpu_irq(IA64_IPI_LOCAL_TLB_FLUSH, &tlb_irqaction);
+#endif
+}
+
+void __init
+init_IRQ (void)
+{
+	ia64_register_ipi();
+	register_percpu_irq(IA64_SPURIOUS_INT_VECTOR, NULL);
+#ifdef CONFIG_SMP
 #if defined(CONFIG_IA64_GENERIC) || defined(CONFIG_IA64_DIG)
 	if (vector_domain_type != VECTOR_DOMAIN_NONE) {
 		BUG_ON(IA64_FIRST_DEVICE_VECTOR != IA64_IRQ_MOVE_VECTOR);
diff --git a/arch/ia64/kernel/paravirt.c b/arch/ia64/kernel/paravirt.c
index 4c54319..8e47c3f 100644
--- a/arch/ia64/kernel/paravirt.c
+++ b/arch/ia64/kernel/paravirt.c
@@ -335,3 +335,18 @@ struct pv_iosapic_ops pv_iosapic_ops = {
 	.__read = ia64_native_iosapic_read,
 	.__write = ia64_native_iosapic_write,
 };
+
+/***************************************************************************
+ * pv_irq_ops
+ * irq operations
+ */
+
+struct pv_irq_ops pv_irq_ops = {
+	.register_ipi = ia64_native_register_ipi,
+
+	.assign_irq_vector = ia64_native_assign_irq_vector,
+	.free_irq_vector = ia64_native_free_irq_vector,
+	.register_percpu_irq = ia64_native_register_percpu_irq,
+
+	.resend_irq = ia64_native_resend_irq,
+};
diff --git a/include/asm-ia64/hw_irq.h b/include/asm-ia64/hw_irq.h
index 76366dc..5c99cbc 100644
--- a/include/asm-ia64/hw_irq.h
+++ b/include/asm-ia64/hw_irq.h
@@ -15,7 +15,11 @@
 #include <asm/ptrace.h>
 #include <asm/smp.h>
 
+#ifndef CONFIG_PARAVIRT
 typedef u8 ia64_vector;
+#else
+typedef u16 ia64_vector;
+#endif
 
 /*
  * 0 special
@@ -104,13 +108,24 @@ DECLARE_PER_CPU(int[IA64_NUM_VECTORS], vector_irq);
 
 extern struct hw_interrupt_type irq_type_ia64_lsapic;	/* CPU-internal interrupt controller */
 
+#ifdef CONFIG_PARAVIRT_GUEST
+#include <asm/paravirt.h>
+#else
+#define ia64_register_ipi	ia64_native_register_ipi
+#define assign_irq_vector	ia64_native_assign_irq_vector
+#define free_irq_vector		ia64_native_free_irq_vector
+#define register_percpu_irq	ia64_native_register_percpu_irq
+#define ia64_resend_irq		ia64_native_resend_irq
+#endif
+
+extern void ia64_native_register_ipi(void);
 extern int bind_irq_vector(int irq, int vector, cpumask_t domain);
-extern int assign_irq_vector (int irq);	/* allocate a free vector */
-extern void free_irq_vector (int vector);
+extern int ia64_native_assign_irq_vector (int irq);	/* allocate a free vector */
+extern void ia64_native_free_irq_vector (int vector);
 extern int reserve_irq_vector (int vector);
 extern void __setup_vector_irq(int cpu);
 extern void ia64_send_ipi (int cpu, int vector, int delivery_mode, int redirect);
-extern void register_percpu_irq (ia64_vector vec, struct irqaction *action);
+extern void ia64_native_register_percpu_irq (ia64_vector vec, struct irqaction *action);
 extern int check_irq_used (int irq);
 extern void destroy_and_reserve_irq (unsigned int irq);
 
@@ -122,7 +137,7 @@ static inline int irq_prepare_move(int irq, int cpu) { return 0; }
 static inline void irq_complete_move(unsigned int irq) {}
 #endif
 
-static inline void ia64_resend_irq(unsigned int vector)
+static inline void ia64_native_resend_irq(unsigned int vector)
 {
 	platform_send_ipi(smp_processor_id(), vector, IA64_IPI_DM_INT, 0);
 }
diff --git a/include/asm-ia64/paravirt.h b/include/asm-ia64/paravirt.h
index 48887a4..2203e9a 100644
--- a/include/asm-ia64/paravirt.h
+++ b/include/asm-ia64/paravirt.h
@@ -149,6 +149,54 @@ __iosapic_write(char __iomem *iosapic, unsigned int reg, u32 val)
 	return pv_iosapic_ops.__write(iosapic, reg, val);
 }
 
+/******************************************************************************
+ * replacement of irq operations.
+ */
+
+struct pv_irq_ops {
+	void (*register_ipi)(void);
+
+	int (*assign_irq_vector)(int irq);
+	void (*free_irq_vector)(int vector);
+
+	void (*register_percpu_irq)(ia64_vector vec,
+				    struct irqaction *action);
+
+	void (*resend_irq)(unsigned int vector);
+};
+
+extern struct pv_irq_ops pv_irq_ops;
+
+static inline void
+ia64_register_ipi(void)
+{
+	pv_irq_ops.register_ipi();
+}
+
+static inline int
+assign_irq_vector(int irq)
+{
+	return pv_irq_ops.assign_irq_vector(irq);
+}
+
+static inline void
+free_irq_vector(int vector)
+{
+	return pv_irq_ops.free_irq_vector(vector);
+}
+
+static inline void
+register_percpu_irq(ia64_vector vec, struct irqaction *action)
+{
+	pv_irq_ops.register_percpu_irq(vec, action);
+}
+
+static inline void
+ia64_resend_irq(unsigned int vector)
+{
+	pv_irq_ops.resend_irq(vector);
+}
+
 #endif /* !__ASSEMBLY__ */
 
 #else
-- 
1.5.3

