From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 11 Nov 2003 00:12:20 +0000
Subject: [PATCH] enable platform dependent MCA handling
Message-Id: <marc-linux-ia64-106850974125144@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi.

This is a patch that makes #ifdef mechanism in /arch/ia64/kernel/mca.c
to work properly, and enable switching platform dependent error handling.
For example, this supports OS to have an OEM call-back function for MCAs.
Since this is a roughly scratched prototype, please give me your comments.

------

H.Seto <seto.hidetoshi@jp.fujitsu.com>


diff -Nur linux-2.6.0-test9.org/arch/ia64/Kconfig
linux-2.6.0-test9/arch/ia64/Kconfig
--- linux-2.6.0-test9.org/arch/ia64/Kconfig 2003-10-26 03:44:46.000000000 +0900
+++ linux-2.6.0-test9/arch/ia64/Kconfig 2003-11-10 16:52:37.257689953 +0900
@@ -250,6 +250,11 @@
    Say Y here to enable machine check support for IA-64.  If you're
    unsure, answer Y.

+config PLATFORM_MCA_HANDLERS
+ bool "Enable platform dependent error handling"
+ depends on IA64_MCA
+ default n
+
 config PM
  bool "Power Management support"
  depends on IA64_GENERIC || IA64_DIG || IA64_HP_ZX1
diff -Nur linux-2.6.0-test9.org/arch/ia64/kernel/Makefile
linux-2.6.0-test9/arch/ia64/kernel/Makefile
--- linux-2.6.0-test9.org/arch/ia64/kernel/Makefile 2003-10-26
03:44:55.000000000 +0900
+++ linux-2.6.0-test9/arch/ia64/kernel/Makefile 2003-11-10 14:30:51.884747269
+0900
@@ -13,6 +13,7 @@
 obj-$(CONFIG_IA64_GENERIC) += acpi-ext.o
 obj-$(CONFIG_IA64_HP_ZX1) += acpi-ext.o
 obj-$(CONFIG_IA64_MCA)  += mca.o mca_asm.o
+obj-$(CONFIG_PLATFORM_MCA_HANDLERS) += plat_mca.o
 obj-$(CONFIG_IA64_PALINFO) += palinfo.o
 obj-$(CONFIG_IA64_SALINFO) += salinfo.o
 obj-$(CONFIG_IOSAPIC)  += iosapic.o
diff -Nur linux-2.6.0-test9.org/arch/ia64/kernel/mca.c
linux-2.6.0-test9/arch/ia64/kernel/mca.c
--- linux-2.6.0-test9.org/arch/ia64/kernel/mca.c 2003-10-26 03:43:35.000000000
+0900
+++ linux-2.6.0-test9/arch/ia64/kernel/mca.c 2003-11-10 16:51:07.314331680 +0900
@@ -186,7 +186,18 @@
 /*
  * platform dependent error handling
  */
-#ifndef PLATFORM_MCA_HANDLERS
+#ifdef CONFIG_PLATFORM_MCA_HANDLERS
+extern void mca_handler_platform(void);
+extern irqreturn_t ia64_mca_cpe_int_handler(int cpe_t,
+         void *arg, struct pt_regs *ptregs);
+extern void init_handler_platform(pal_min_state_area_t *ms,
+      struct pt_regs *pt, struct switch_stack *sw);
+extern void ia64_mca_init_platform(void);
+extern int ia64_mca_check_errors(void);
+#ifdef CONFIG_ACPI
+extern void ia64_mca_register_cpev(int cpev);
+#endif /* CONFIG_ACPI */
+#else
 void
 mca_handler_platform (void)
 {
@@ -461,7 +472,7 @@
 }
 #endif /* CONFIG_ACPI */

-#endif /* PLATFORM_MCA_HANDLERS */
+#endif /* CONFIG_PLATFORM_MCA_HANDLERS */

 /*
  * ia64_mca_cmc_vector_setup
diff -Nur linux-2.6.0-test9.org/arch/ia64/kernel/plat_mca.c
linux-2.6.0-test9/arch/ia64/kernel/plat_mca.c
--- linux-2.6.0-test9.org/arch/ia64/kernel/plat_mca.c 1970-01-01
09:00:00.000000000 +0900
+++ linux-2.6.0-test9/arch/ia64/kernel/plat_mca.c 2003-11-10 16:51:35.258667275
+0900
@@ -0,0 +1,47 @@
+/*
+ * File: plat_mca.c
+ * Purpose: platform dependent error handling
+ *
+ */
+#include <linux/irq.h>
+#include <asm/ptrace.h>
+#include <asm/sal.h>
+
+void
+mca_handler_platform (void)
+{
+
+}
+
+irqreturn_t
+ia64_mca_cpe_int_handler (int cpe_irq, void *arg, struct pt_regs *ptregs)
+{
+
+}
+
+void
+init_handler_platform (pal_min_state_area_t *ms,
+         struct pt_regs *pt, struct switch_stack *sw)
+{
+
+}
+
+void
+ia64_mca_init_platform (void)
+{
+
+}
+
+int
+ia64_mca_check_errors (void)
+{
+
+}
+
+#ifdef CONFIG_ACPI
+void
+ia64_mca_register_cpev (int cpev)
+{
+
+}
+#endif /* CONFIG_ACPI */


