From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 14 Jul 2005 09:20:51 +0000
Subject: [RFC][patch 2/10] Multiple vector domain support - cpu and domain
Message-Id: <42D62E73.1050108@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch add the code to handle the relationship between cpu and
domains. We need more consideration about how to separate vector
domains.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---

 linux-2.6.13-rc1-kanesige/arch/ia64/kernel/irq_ia64.c |   24 ++++++++++++++++++
 linux-2.6.13-rc1-kanesige/arch/ia64/kernel/setup.c    |    2 +
 linux-2.6.13-rc1-kanesige/arch/ia64/kernel/smpboot.c  |    2 +
 linux-2.6.13-rc1-kanesige/include/asm-ia64/hw_irq.h   |   13 +++++++++
 4 files changed, 41 insertions(+)

diff -puN arch/ia64/kernel/irq_ia64.c~vector-domain-ia64-attach-cpu arch/ia64/kernel/irq_ia64.c
--- linux-2.6.13-rc1/arch/ia64/kernel/irq_ia64.c~vector-domain-ia64-attach-cpu	2005-07-13 14:51:40.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/arch/ia64/kernel/irq_ia64.c	2005-07-13 14:51:40.000000000 +0900
@@ -286,3 +286,27 @@ ia64_send_ipi (int cpu, int vector, int 
 
 	writeq(ipi_data, ipi_addr);
 }
+
+void __init
+ia64_vector_domain_init (void)
+{
+	/* Attach BSP to domain #0 */
+	ia64_attach_cpu_to_domain(0);
+}
+
+#ifdef CONFIG_VECTOR_DOMAIN
+int ia64_cpu_domain_map[NR_CPUS];
+cpumask_t ia64_domain_cpumask[NR_VECTOR_DOMAINS];
+
+void __devinit
+ia64_attach_cpu_to_domain (int cpu)
+{
+	static int domain = -1;
+
+	/* Simple Round Robin for now */
+	if (++domain >= NR_VECTOR_DOMAINS)
+		domain = 0;
+	ia64_cpu_domain_map[cpu] = domain;
+	cpu_set(cpu, ia64_domain_cpumask[domain]);
+}
+#endif /* CONFIG_VECTOR_DOMAIN */
diff -puN arch/ia64/kernel/setup.c~vector-domain-ia64-attach-cpu arch/ia64/kernel/setup.c
--- linux-2.6.13-rc1/arch/ia64/kernel/setup.c~vector-domain-ia64-attach-cpu	2005-07-13 14:51:40.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/arch/ia64/kernel/setup.c	2005-07-13 14:51:40.000000000 +0900
@@ -406,6 +406,8 @@ setup_arch (char **cmdline_p)
 
 	cpu_init();	/* initialize the bootstrap CPU */
 
+	ia64_vector_domain_init();
+
 #ifdef CONFIG_ACPI_BOOT
 	acpi_boot_init();
 #endif
diff -puN arch/ia64/kernel/smpboot.c~vector-domain-ia64-attach-cpu arch/ia64/kernel/smpboot.c
--- linux-2.6.13-rc1/arch/ia64/kernel/smpboot.c~vector-domain-ia64-attach-cpu	2005-07-13 14:51:40.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/arch/ia64/kernel/smpboot.c	2005-07-13 14:51:40.000000000 +0900
@@ -766,6 +766,8 @@ __cpu_up (unsigned int cpu)
 	int ret;
 	int sapicid;
 
+	ia64_attach_cpu_to_domain(cpu);
+
 	sapicid = ia64_cpu_to_sapicid[cpu];
 	if (sapicid = -1)
 		return -EINVAL;
diff -puN include/asm-ia64/hw_irq.h~vector-domain-ia64-attach-cpu include/asm-ia64/hw_irq.h
--- linux-2.6.13-rc1/include/asm-ia64/hw_irq.h~vector-domain-ia64-attach-cpu	2005-07-13 14:51:40.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/include/asm-ia64/hw_irq.h	2005-07-13 14:51:40.000000000 +0900
@@ -79,6 +79,18 @@ enum {
 extern __u8 isa_irq_to_vector_map[16];
 #define isa_irq_to_vector(x)	isa_irq_to_vector_map[(x)]
 
+#ifdef CONFIG_VECTOR_DOMAIN
+extern void ia64_attach_cpu_to_domain(int cpu);
+extern int ia64_cpu_domain_map[NR_CPUS];
+extern cpumask_t ia64_domain_cpumask[NR_VECTOR_DOMAINS];
+#define ia64_cpu_to_domain(cpu)			(ia64_cpu_domain_map[cpu])
+#define ia64_domain_to_cpumask(domain)		(ia64_domain_cpumask[domain])
+#else
+#define ia64_attach_cpu_to_domain(cpu)		do {} while (0)
+#define ia64_cpu_to_domain(cpu)			(cpu^cpu)
+#define ia64_domain_to_cpumask(domain)		(cpu_online_map)
+#endif /* CONFIG_VECTOR_DOMAIN */
+
 extern struct hw_interrupt_type irq_type_ia64_lsapic;	/* CPU-internal interrupt controller */
 
 extern int assign_irq_vector_nopanic (int irq); /* allocate a free vector without panic */
@@ -86,6 +98,7 @@ extern int assign_irq_vector (int irq);	
 extern void free_irq_vector (int vector);
 extern void ia64_send_ipi (int cpu, int vector, int delivery_mode, int redirect);
 extern void register_percpu_irq (ia64_vector vec, struct irqaction *action);
+extern void __init ia64_vector_domain_init(void);
 
 static inline void
 hw_resend_irq (struct hw_interrupt_type *h, unsigned int vector)

_



