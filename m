From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 05 Mar 2008 18:18:43 +0000
Subject: [PATCH 28/50] ia64/pv_ops: introduce pv_irq_ops and its hooks.
Message-Id: <12047411461988-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/irq_ia64.c |   21 ++++++++++----
 arch/ia64/kernel/paravirt.c |   22 +++++++++++++++
 include/asm-ia64/hw_irq.h   |   20 ++++++++++---
 include/asm-ia64/paravirt.h |   63 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 115 insertions(+), 11 deletions(-)

diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 2b8cf6e..5259faa 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -196,7 +196,7 @@ static void clear_irq_vector(int irq)
 }
 
 int
-assign_irq_vector (int irq)
+native_assign_irq_vector (int irq)
 {
 	unsigned long flags;
 	int vector, cpu;
@@ -222,7 +222,7 @@ assign_irq_vector (int irq)
 }
 
 void
-free_irq_vector (int vector)
+native_free_irq_vector (int vector)
 {
 	if (vector < IA64_FIRST_DEVICE_VECTOR ||
 	    vector > IA64_LAST_DEVICE_VECTOR)
@@ -623,7 +623,7 @@ static struct irqaction tlb_irqaction = {
 #endif
 
 void
-register_percpu_irq (ia64_vector vec, struct irqaction *action)
+native_register_percpu_irq (ia64_vector vec, struct irqaction *action)
 {
 	irq_desc_t *desc;
 	unsigned int irq;
@@ -638,13 +638,21 @@ register_percpu_irq (ia64_vector vec, struct irqaction *action)
 }
 
 void __init
+native_init_IRQ_early(void)
+{
+#ifdef CONFIG_SMP
+	register_percpu_irq(IA64_IPI_RESCHEDULE, &resched_irqaction);
+	register_percpu_irq(IA64_IPI_LOCAL_TLB_FLUSH, &tlb_irqaction);
+#endif
+}
+
+void __init
 init_IRQ (void)
 {
+	paravirt_init_IRQ_early();
 	register_percpu_irq(IA64_SPURIOUS_INT_VECTOR, NULL);
 #ifdef CONFIG_SMP
 	register_percpu_irq(IA64_IPI_VECTOR, &ipi_irqaction);
-	register_percpu_irq(IA64_IPI_RESCHEDULE, &resched_irqaction);
-	register_percpu_irq(IA64_IPI_LOCAL_TLB_FLUSH, &tlb_irqaction);
 #if defined(CONFIG_IA64_GENERIC) || defined(CONFIG_IA64_DIG)
 	if (vector_domain_type != VECTOR_DOMAIN_NONE) {
 		BUG_ON(IA64_FIRST_DEVICE_VECTOR != IA64_IRQ_MOVE_VECTOR);
@@ -657,10 +665,11 @@ init_IRQ (void)
 	pfm_init_percpu();
 #endif
 	platform_irq_init();
+	paravirt_init_IRQ_late();
 }
 
 void
-ia64_send_ipi (int cpu, int vector, int delivery_mode, int redirect)
+native_send_ipi (int cpu, int vector, int delivery_mode, int redirect)
 {
 	void __iomem *ipi_addr;
 	unsigned long ipi_data;
diff --git a/arch/ia64/kernel/paravirt.c b/arch/ia64/kernel/paravirt.c
index 7e6a2d0..ce0b23b 100644
--- a/arch/ia64/kernel/paravirt.c
+++ b/arch/ia64/kernel/paravirt.c
@@ -70,3 +70,25 @@ struct pv_iosapic_ops pv_iosapic_ops = {
 	.__read = native_iosapic_read,
 	.__write = native_iosapic_write,
 };
+
+/***************************************************************************
+ * pv_irq_ops
+ * irq operations
+ */
+
+void
+ia64_send_ipi(int cpu, int vector, int delivery_mode, int redirect)
+{
+	pv_irq_ops.send_ipi(cpu, vector, delivery_mode, redirect);
+}
+
+struct pv_irq_ops pv_irq_ops = {
+	.init_IRQ_early = native_init_IRQ_early,
+
+	.assign_irq_vector = native_assign_irq_vector,
+	.free_irq_vector = native_free_irq_vector,
+	.register_percpu_irq = native_register_percpu_irq,
+
+	.send_ipi = native_send_ipi,
+	.resend_irq = native_resend_irq,
+};
diff --git a/include/asm-ia64/hw_irq.h b/include/asm-ia64/hw_irq.h
index 76366dc..678efec 100644
--- a/include/asm-ia64/hw_irq.h
+++ b/include/asm-ia64/hw_irq.h
@@ -104,13 +104,23 @@ DECLARE_PER_CPU(int[IA64_NUM_VECTORS], vector_irq);
 
 extern struct hw_interrupt_type irq_type_ia64_lsapic;	/* CPU-internal interrupt controller */
 
+#ifdef CONFIG_PARAVIRT_GUEST
+#include <asm/paravirt.h>
+#else
+#define assign_irq_vector	native_assign_irq_vector
+#define free_irq_vector		native_free_irq_vector
+#define ia64_send_ipi		native_send_ipi
+#define ia64_resend_irq		native_resend_irq
+#endif
+
+extern void native_init_IRQ_early(void);
 extern int bind_irq_vector(int irq, int vector, cpumask_t domain);
-extern int assign_irq_vector (int irq);	/* allocate a free vector */
-extern void free_irq_vector (int vector);
+extern int native_assign_irq_vector (int irq);	/* allocate a free vector */
+extern void native_free_irq_vector (int vector);
 extern int reserve_irq_vector (int vector);
 extern void __setup_vector_irq(int cpu);
-extern void ia64_send_ipi (int cpu, int vector, int delivery_mode, int redirect);
-extern void register_percpu_irq (ia64_vector vec, struct irqaction *action);
+extern void native_send_ipi (int cpu, int vector, int delivery_mode, int redirect);
+extern void native_register_percpu_irq (ia64_vector vec, struct irqaction *action);
 extern int check_irq_used (int irq);
 extern void destroy_and_reserve_irq (unsigned int irq);
 
@@ -122,7 +132,7 @@ static inline int irq_prepare_move(int irq, int cpu) { return 0; }
 static inline void irq_complete_move(unsigned int irq) {}
 #endif
 
-static inline void ia64_resend_irq(unsigned int vector)
+static inline void native_resend_irq(unsigned int vector)
 {
 	platform_send_ipi(smp_processor_id(), vector, IA64_IPI_DM_INT, 0);
 }
diff --git a/include/asm-ia64/paravirt.h b/include/asm-ia64/paravirt.h
index 9efeda9..ace6653 100644
--- a/include/asm-ia64/paravirt.h
+++ b/include/asm-ia64/paravirt.h
@@ -28,6 +28,7 @@
 
 #ifndef __ASSEMBLY__
 
+#include <asm/hw_irq.h>
 #include <asm/meminit.h>
 
 /******************************************************************************
@@ -192,6 +193,65 @@ __iosapic_write(char __iomem *iosapic, unsigned int reg, u32 val)
 	return pv_iosapic_ops.__write(iosapic, reg, val);
 }
 
+/******************************************************************************
+ * replacement of irq operations.
+ */
+
+struct pv_irq_ops {
+	void (*init_IRQ_early)(void);
+	void (*init_IRQ_late)(void);
+
+	int (*assign_irq_vector)(int irq);
+	void (*free_irq_vector)(int vector);
+
+	void (*register_percpu_irq)(ia64_vector vec,
+				    struct irqaction *action);
+
+	void (*send_ipi)(int cpu, int vector, int delivery_mode, int redirect);
+	void (*resend_irq)(unsigned int vector);
+};
+
+extern struct pv_irq_ops pv_irq_ops;
+
+static inline void
+paravirt_init_IRQ_early(void)
+{
+	pv_irq_ops.init_IRQ_early();
+}
+
+static inline void
+paravirt_init_IRQ_late(void)
+{
+	if (pv_irq_ops.init_IRQ_late)
+		pv_irq_ops.init_IRQ_late();
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
+void ia64_send_ipi(int cpu, int vector, int delivery_mode, int redirect);
+
+static inline void
+ia64_resend_irq(unsigned int vector)
+{
+	pv_irq_ops.resend_irq(vector);
+}
+
 #endif /* __ASSEMBLY__ */
 
 #else
@@ -213,6 +273,9 @@ __iosapic_write(char __iomem *iosapic, unsigned int reg, u32 val)
 #define paravirt_bundle_patch_module(start, end)	do { } while (0)
 #define paravirt_inst_patch_module(start, end)		do { } while (0)
 
+#define paravirt_init_IRQ_early()			do { } while (0)
+#define paravirt_init_IRQ_late()			do { } while (0)
+
 #endif /* __ASSEMBLY__ */
 
 
-- 
1.5.3

