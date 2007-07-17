From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date: Tue, 17 Jul 2007 12:22:55 +0000
Subject: [PATCH take3 11/12] Enable percpu vector domain for IA64_GENERIC
Message-Id: <469CB49F.102@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add per-CPU vector domain support for IA64_GENERIC. It is enabled by
adding the "vector=percpu" boot option.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

 Documentation/kernel-parameters.txt |    3 +++
 arch/ia64/kernel/irq_ia64.c         |   26 ++++++++++++++++++++++++++
 2 files changed, 29 insertions(+)

Index: linux-2.6.22/arch/ia64/kernel/irq_ia64.c
=================================--- linux-2.6.22.orig/arch/ia64/kernel/irq_ia64.c	2007-07-17 12:09:47.000000000 +0900
+++ linux-2.6.22/arch/ia64/kernel/irq_ia64.c	2007-07-17 12:10:37.000000000 +0900
@@ -267,10 +267,36 @@ void __setup_vector_irq(int cpu)
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


 void destroy_and_reserve_irq(unsigned int irq)
Index: linux-2.6.22/Documentation/kernel-parameters.txt
=================================--- linux-2.6.22.orig/Documentation/kernel-parameters.txt	2007-07-17 12:08:13.000000000 +0900
+++ linux-2.6.22/Documentation/kernel-parameters.txt	2007-07-17 12:10:37.000000000 +0900
@@ -1917,6 +1917,9 @@ and is between 256 and 4096 characters.
 			vdso=1: enable VDSO (default)
 			vdso=0: disable VDSO mapping

+	vector=		[IA-64,SMP]
+			vector=percpu: enable percpu vector domain
+
 	video=		[FB] Frame buffer configuration
 			See Documentation/fb/modedb.txt.

