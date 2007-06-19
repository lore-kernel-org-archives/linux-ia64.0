From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date: Tue, 19 Jun 2007 08:18:05 +0000
Subject: [PATCH take2 11/13] Enable percpu vector domain for IA64_GENERIC
Message-Id: <4677913D.4030002@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add per-CPU vector domain support for IA64_GENERIC. It is enabled by
adding the "vector=percpu" boot option.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

---
 arch/ia64/kernel/irq_ia64.c |   26 ++++++++++++++++++++++++++
 1 files changed, 26 insertions(+)

Index: linux-2.6.22-rc5/arch/ia64/kernel/irq_ia64.c
=================================--- linux-2.6.22-rc5.orig/arch/ia64/kernel/irq_ia64.c	2007-06-19 15:33:47.000000000 +0900
+++ linux-2.6.22-rc5/arch/ia64/kernel/irq_ia64.c	2007-06-19 15:33:50.000000000 +0900
@@ -227,10 +227,36 @@ void __setup_vector_irq(int cpu)
 	}
 }

+#if defined(CONFIG_IA64_GENERIC)
+static enum vector_domain_type {
+	VECTOR_DOMAIN_NONE,
+	VECTOR_DOMAIN_PERCPU
+} vector_domain_type = VECTOR_DOMAIN_NONE;
+
+static cpumask_t vector_allocation_domain(int cpu)
+{
+	if (vector_domain_type = VECTOR_DOMAIN_PERCPU)
+		return cpumask_of_cpu(cpu);
+	return CPU_MASK_ALL;
+}
+
+static int __init parse_vector_domain(char *arg)
+{
+	if (!arg)
+		return -EINVAL;
+	if (!strcmp(arg, "percpu")) {
+		vector_domain_type = VECTOR_DOMAIN_PERCPU;
+		no_int_routing = 1;
+	}
+	return 1;
+}
+early_param("vector", parse_vector_domain);
+#else
 static cpumask_t vector_allocation_domain(int cpu)
 {
 	return CPU_MASK_ALL;
 }
+#endif

 static int __reassign_irq_vector(int irq, int cpu)
 {

