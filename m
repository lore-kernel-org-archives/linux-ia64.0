From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 14 Jul 2005 09:24:14 +0000
Subject: [RFC][patch 3/10] Multiple vector domain support - introduce gsv
Message-Id: <42D62F3E.2090609@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch adds "Global System Vector" to make it easier to handle
vectors and domains. The concept of GSV is sililar to globbal system
interrupt (GSI). Suppose that there are two domains, domain 0 and
domain 1, and suppose that each of them have 256 interrupt vectors. In
this case, GSV 10 would be corresponding to vector 10 in domain 0, and
GSV 266 would be corresponding to vector 10 in domain 1.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---

 linux-2.6.13-rc1-kanesige/arch/ia64/kernel/irq_ia64.c |   17 ++++
 linux-2.6.13-rc1-kanesige/include/asm-ia64/hw_irq.h   |   66 +++++++++++++++++-
 linux-2.6.13-rc1-kanesige/include/asm-ia64/irq.h      |    2 
 3 files changed, 84 insertions(+), 1 deletion(-)

diff -puN arch/ia64/kernel/irq_ia64.c~vector-domain-ia64-handle-gsv arch/ia64/kernel/irq_ia64.c
--- linux-2.6.13-rc1/arch/ia64/kernel/irq_ia64.c~vector-domain-ia64-handle-gsv	2005-07-13 14:51:41.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/arch/ia64/kernel/irq_ia64.c	2005-07-13 14:51:41.000000000 +0900
@@ -60,6 +60,9 @@ __u8 isa_irq_to_vector_map[16] = {
 };
 EXPORT_SYMBOL(isa_irq_to_vector_map);
 
+int ia64_irq_to_gsv_map[NR_IRQS] = { [0 ... NR_IRQS-1] = -1 };
+int ia64_gsv_to_irq_map[NR_GSVS] = { [0 ... NR_GSVS-1] = -1 };
+
 static unsigned long ia64_vector_mask[BITS_TO_LONGS(IA64_NUM_DEVICE_VECTORS)];
 
 int
@@ -290,8 +293,22 @@ ia64_send_ipi (int cpu, int vector, int 
 void __init
 ia64_vector_domain_init (void)
 {
+	int domain, vec, gsv;
+
 	/* Attach BSP to domain #0 */
 	ia64_attach_cpu_to_domain(0);
+
+	/*
+	 * Make special mapping between per CPU IRQs and GSVs
+	 */
+	for (gsv = 0; gsv < NR_GSVS; gsv++) {
+		vec = gsv_to_vector(gsv);
+		if (vec < IA64_FIRST_DEVICE_VECTOR ||
+		    vec > IA64_LAST_DEVICE_VECTOR) {
+			ia64_gsv_to_irq_map[gsv] = vec;
+			ia64_irq_to_gsv_map[vec] = vec;
+		}
+	}
 }
 
 #ifdef CONFIG_VECTOR_DOMAIN
diff -puN include/asm-ia64/hw_irq.h~vector-domain-ia64-handle-gsv include/asm-ia64/hw_irq.h
--- linux-2.6.13-rc1/include/asm-ia64/hw_irq.h~vector-domain-ia64-handle-gsv	2005-07-13 14:51:41.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/include/asm-ia64/hw_irq.h	2005-07-13 14:51:41.000000000 +0900
@@ -107,6 +107,71 @@ hw_resend_irq (struct hw_interrupt_type 
 }
 
 /*
+ * Global System Vector
+ * --------------------
+ * Global System Vector (GSV) is introduced to make it easier to
+ * handle vectors and domains. The concept of GSV is sililar to
+ * globbal system interrupt (GSI). Suppose that there are two domains,
+ * domain 0 and domain 1, and suppose that each of them have 256
+ * interrupt vectors. In this case, GSV 10 would be corresponding to
+ * vector 10 in domain 0, and GSV 266 would be corresponding to vector
+ * 10 in domain 1.
+ */
+
+extern int ia64_irq_to_gsv_map[NR_IRQS];
+extern int ia64_gsv_to_irq_map[NR_GSVS];
+
+/*
+ * Convert global system vector to the corresponding IRQ.
+ */
+static inline int
+gsv_to_irq (unsigned int gsv)
+{
+	if (gsv > NR_GSVS)
+		return -1;
+	return ia64_gsv_to_irq_map[gsv];
+}
+
+/*
+ * Convert global system vector to the corresponding vector number.
+ */
+static inline int
+gsv_to_vector (unsigned int gsv)
+{
+	return (gsv & 0xff);
+}
+
+/*
+ * Convert global system vector to the corresponding domain number.
+ */
+static inline int
+gsv_to_domain (unsigned int gsv)
+{
+	return (gsv >> 8);
+}
+
+/*
+ * Convert IRQ to the corresponding global system vector.
+ */
+static inline int
+irq_to_gsv (unsigned int irq)
+{
+	if (irq > NR_IRQS)
+		return -1;
+	return ia64_irq_to_gsv_map[irq];
+}
+
+/*
+ * Convert vector and domain number to the corresponding global system
+ * vector number.
+ */
+static inline int
+domain_vector_to_gsv (unsigned int domain, unsigned int vector)
+{
+	return ((domain << 8) | vector);
+}
+
+/*
  * Default implementations for the irq-descriptor API:
  */
 
@@ -154,5 +219,4 @@ local_vector_to_irq (ia64_vector vec)
 {
 	return platform_local_vector_to_irq(vec);
 }
-
 #endif /* _ASM_IA64_HW_IRQ_H */
diff -puN include/asm-ia64/irq.h~vector-domain-ia64-handle-gsv include/asm-ia64/irq.h
--- linux-2.6.13-rc1/include/asm-ia64/irq.h~vector-domain-ia64-handle-gsv	2005-07-13 14:51:41.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/include/asm-ia64/irq.h	2005-07-13 14:51:41.000000000 +0900
@@ -20,6 +20,8 @@
 #define NR_IRQS		(256 * NR_VECTOR_DOMAINS)
 #define NR_IRQ_VECTORS	NR_IRQS
 
+#define NR_GSVS		(IA64_NUM_VECTORS * NR_VECTOR_DOMAINS)
+
 static __inline__ int
 irq_canonicalize (int irq)
 {

_


