From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 04 Dec 2003 06:06:22 +0000
Subject: [PATCH] switching MCA handling by machvecs [2/2]
Message-Id: <marc-linux-ia64-107051813204137@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106975273502765@msgid-missing>
In-Reply-To: <marc-linux-ia64-106975273502765@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following code is a sample of handler implementation using machvecs
for notional platform "AAA".


Thanks.

------

H.Seto <seto.hidetoshi@jp.fujitsu.com>

------

diff -Nur linux-2.6.0-test11/arch/ia64/Kconfig linux-2.6.0-test11-2/arch/ia64/Kconfig
--- linux-2.6.0-test11/arch/ia64/Kconfig 2003-11-27 05:45:39.000000000 +0900
+++ linux-2.6.0-test11-2/arch/ia64/Kconfig 2003-12-03 18:19:14.702873782 +0900
@@ -96,6 +96,9 @@
 config IA64_SGI_SN2
  bool "SGI-SN2"
 
+config IA64_AAA
+ bool "AAA"
+
 endchoice
 
 choice
@@ -274,7 +277,7 @@
 
 config IOSAPIC
  bool
- depends on IA64_GENERIC || IA64_DIG || IA64_HP_ZX1 || IA64_SGI_SN2
+ depends on IA64_GENERIC || IA64_DIG || IA64_HP_ZX1 || IA64_SGI_SN2 || IA64_AAA
  default y
 
 config IA64_SGI_SN_SIM
diff -Nur linux-2.6.0-test11/arch/ia64/Makefile linux-2.6.0-test11-2/arch/ia64/Makefile
--- linux-2.6.0-test11/arch/ia64/Makefile 2003-11-27 05:42:54.000000000 +0900
+++ linux-2.6.0-test11-2/arch/ia64/Makefile 2003-12-03 18:19:14.702873782 +0900
@@ -60,6 +60,7 @@
 core-$(CONFIG_IA64_GENERIC)  += arch/ia64/dig/
 core-$(CONFIG_IA64_HP_ZX1) += arch/ia64/dig/
 core-$(CONFIG_IA64_SGI_SN2) += arch/ia64/sn/
+core-$(CONFIG_IA64_AAA)  += arch/ia64/aaa/
 
 drivers-$(CONFIG_PCI)  += arch/ia64/pci/
 drivers-$(CONFIG_IA64_HP_SIM) += arch/ia64/hp/sim/
diff -Nur linux-2.6.0-test11/arch/ia64/aaa/Makefile linux-2.6.0-test11-2/arch/ia64/aaa/Makefile
--- linux-2.6.0-test11/arch/ia64/aaa/Makefile 1970-01-01 09:00:00.000000000 +0900
+++ linux-2.6.0-test11-2/arch/ia64/aaa/Makefile 2003-12-03 18:19:14.703850344 +0900
@@ -0,0 +1,5 @@
+#
+# ia64/platform/aaa/Makefile
+#
+
+obj-y := mca_handler.o
diff -Nur linux-2.6.0-test11/arch/ia64/aaa/mca_handler.c linux-2.6.0-test11-2/arch/ia64/aaa/mca_handler.c
--- linux-2.6.0-test11/arch/ia64/aaa/mca_handler.c 1970-01-01 09:00:00.000000000 +0900
+++ linux-2.6.0-test11-2/arch/ia64/aaa/mca_handler.c 2003-12-03 18:19:14.703850344 +0900
@@ -0,0 +1,39 @@
+/*
+ * Platform dependent support for AAA platforms.
+ */
+
+#include <linux/interrupt.h>
+#include <asm/ptrace.h>
+#include <asm/pal.h>
+
+void
+aaa_init_handler_platform
+(pal_min_state_area_t *ms, struct pt_regs *pt, struct switch_stack *sw)
+{
+
+}
+
+void
+aaa_mca_init_platform (void)
+{
+
+}
+
+void
+aaa_mca_handler_platform (void)
+{
+
+}
+
+void
+aaa_mca_cmc_int_handler (int cpe_irq, void *arg, struct pt_regs *ptregs)
+{
+
+}
+
+void
+aaa_mca_cpe_int_handler (int cpe_irq, void *arg, struct pt_regs *ptregs)
+{
+
+}
+
diff -Nur linux-2.6.0-test11/arch/ia64/kernel/acpi.c linux-2.6.0-test11-2/arch/ia64/kernel/acpi.c
--- linux-2.6.0-test11/arch/ia64/kernel/acpi.c 2003-11-27 05:44:07.000000000 +0900
+++ linux-2.6.0-test11-2/arch/ia64/kernel/acpi.c 2003-12-03 18:19:14.703850344 +0900
@@ -105,6 +105,8 @@
  return "sn2";
 # elif defined (CONFIG_IA64_DIG)
  return "dig";
+# elif defined (CONFIG_IA64_AAA)
+ return "dig";
 # else
 # error Unknown platform.  Fix acpi.c.
 # endif
diff -Nur linux-2.6.0-test11/include/asm-ia64/machvec.h linux-2.6.0-test11-2/include/asm-ia64/machvec.h
--- linux-2.6.0-test11/include/asm-ia64/machvec.h 2003-12-03 18:18:06.091546497 +0900
+++ linux-2.6.0-test11-2/include/asm-ia64/machvec.h 2003-12-03 18:19:14.704826907 +0900
@@ -83,6 +83,8 @@
 #  include <asm/machvec_hpzx1.h>
 # elif defined (CONFIG_IA64_SGI_SN2)
 #  include <asm/machvec_sn2.h>
+# elif defined (CONFIG_IA64_AAA)
+#  include <asm/machvec_aaa.h>
 # elif defined (CONFIG_IA64_GENERIC)
 
 # ifdef MACHVEC_PLATFORM_HEADER
diff -Nur linux-2.6.0-test11/include/asm-ia64/machvec_aaa.h linux-2.6.0-test11-2/include/asm-ia64/machvec_aaa.h
--- linux-2.6.0-test11/include/asm-ia64/machvec_aaa.h 1970-01-01 09:00:00.000000000 +0900
+++ linux-2.6.0-test11-2/include/asm-ia64/machvec_aaa.h 2003-12-03 18:19:14.704826907 +0900
@@ -0,0 +1,21 @@
+#ifndef _ASM_IA64_MACHVEC_AAA_h
+#define _ASM_IA64_MACHVEC_AAA_h
+
+extern ia64_mv_init_handler_t aaa_init_handler_platform;
+extern ia64_mv_mca_init_t     aaa_mca_init_platform;
+extern ia64_mv_mca_handler_t  aaa_mca_handler_platform;
+extern ia64_mv_cmci_handler_t aaa_mca_cmc_int_handler;
+extern ia64_mv_cpei_handler_t aaa_mca_cpe_int_handler;
+
+#define platform_name  "aaa"
+#define platform_init_handler aaa_init_handler_platform
+#define platform_mca_init aaa_mca_init_platform
+#define platform_mca_handler aaa_mca_handler_platform
+#define platform_cmci_handler aaa_mca_cmc_int_handler
+#define platform_cmci_handler_name \
+ (irqreturn_t (*)(int,void *,struct pt_regs *))(&aaa_mca_cmc_int_handler)
+#define platform_cpei_handler aaa_mca_cpe_int_handler
+#define platform_cpei_handler_name \
+ (irqreturn_t (*)(int,void *,struct pt_regs *))(&aaa_mca_cpe_int_handler)
+
+#endif /* _ASM_IA64_MACHVEC_AAA_h */

