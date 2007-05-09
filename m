From: Ishimatsu Yasuaki <isimatu.yasuaki@jp.fujitsu.com>
Date: Wed, 09 May 2007 07:57:08 +0000
Subject: [PATCH 11/12] Enable percpu vector domain for IA64_GENERIC
Message-Id: <46417ED4.4080009@jp.fujitsu.com>
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

Index: linux-2.6.21/arch/ia64/kernel/irq_ia64.c
=================================--- linux-2.6.21.orig/arch/ia64/kernel/irq_ia64.c	2007-05-08 12:13:39.000000000 +0900
+++ linux-2.6.21/arch/ia64/kernel/irq_ia64.c	2007-05-08 12:14:11.000000000 +0900
@@ -227,10 +227,36 @@
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


