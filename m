From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 25 Nov 2003 09:29:28 +0000
Subject: [PATCH] switching MCA handling by machvecs
Message-Id: <marc-linux-ia64-106975273502765@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch enables switching MCA handlers by machvecs.
Detail is as follows. Definitely your comment is always welcomed.

[Outline]:
 This patch arranges calling each MCA/INIT/CMC/CPE handlers in
 arch/ia64/kernel/mca.c to refer definition in machvecs. In the beginning of
 mca.c, there is a "#ifndef PLATFORM_MCA_HANDLERS" block which includes:
   mca_handler_platform
   ia64_mca_cpe_int_handler
   init_handler_platform
   ia64_mca_init_platform
 and the outside of the block includes:
   ia64_mca_cmc_int_handler

 Each of these functions is assigned as a default that called when the platform
 specific handler was not defined in machvecs. Therefor, I delete "#ifndef" to
 compile all of these function independently of the situation whether
 PLATFORM_MCA_HANDLERS is defined or not.

[Modified Sources]:
 - arch/ia64/kernel/mca.c
 - include/asm-ia64/machvec.h


Thanks.

------

H.Seto <seto.hidetoshi@jp.fujitsu.com>

------

diff -Nur linux-2.6.0-test9.org/arch/ia64/kernel/mca.c
linux-2.6.0-test9/arch/ia64/kernel/mca.c
--- linux-2.6.0-test9.org/arch/ia64/kernel/mca.c 2003-10-26 03:43:35.000000000
+0900
+++ linux-2.6.0-test9/arch/ia64/kernel/mca.c 2003-11-17 11:22:46.354039217 +0900
@@ -90,7 +90,7 @@
 extern struct hw_interrupt_type irq_type_iosapic_level;

 static struct irqaction cmci_irqaction = {
- .handler = ia64_mca_cmc_int_handler,
+ .handler = platform_cmci_handler,
  .flags = SA_INTERRUPT,
  .name =  "cmc_hndlr"
 };
@@ -115,7 +115,7 @@

 #ifdef CONFIG_ACPI
 static struct irqaction mca_cpe_irqaction = {
- .handler = ia64_mca_cpe_int_handler,
+ .handler = platform_cpei_handler,
  .flags = SA_INTERRUPT,
  .name =  "cpe_hndlr"
 };
@@ -184,9 +184,8 @@
 }

 /*
- * platform dependent error handling
+ * platform dependent error handling (default)
  */
-#ifndef PLATFORM_MCA_HANDLERS
 void
 mca_handler_platform (void)
 {
@@ -461,8 +460,6 @@
 }
 #endif /* CONFIG_ACPI */

-#endif /* PLATFORM_MCA_HANDLERS */
-
 /*
  * ia64_mca_cmc_vector_setup
  *
@@ -971,7 +968,7 @@
   *  Do Platform-specific mca error handling if required.
   */
  if (platform_err)
-  mca_handler_platform();
+  platform_mca_handler();

  /*
   *  Wakeup all the processors which are spinning in the rendezvous
@@ -1200,7 +1197,7 @@
  if (start_count = -1)
   start_count = IA64_LOG_COUNT(SAL_INFO_TYPE_CPE);

- ia64_mca_cpe_int_handler(cpe_irq, arg, ptregs);
+ platform_cpei_handler(cpe_irq, arg, ptregs);

  for (++cpuid ; cpuid < NR_CPUS && !cpu_online(cpuid) ; cpuid++);

@@ -1302,7 +1299,7 @@
   */
  ms = (pal_min_state_area_t *)(ia64_sal_to_os_handoff_state.pal_min_state |
(6ul<<61));

- init_handler_platform(ms, pt, sw); /* call platform specific routines */
+ platform_init_handler(ms, pt, sw); /* call platform specific routines */
 }

 /*
diff -Nur linux-2.6.0-test9.org/include/asm-ia64/machvec.h
linux-2.6.0-test9/include/asm-ia64/machvec.h
--- linux-2.6.0-test9.org/include/asm-ia64/machvec.h 2003-10-26
03:43:47.000000000 +0900
+++ linux-2.6.0-test9/include/asm-ia64/machvec.h 2003-11-14 19:06:08.463319154
+0900
@@ -12,6 +12,8 @@

 #include <linux/config.h>
 #include <linux/types.h>
+#include <asm/ptrace.h>
+#include <asm/pal.h>

 /* forward declarations: */
 struct device;
@@ -24,8 +26,10 @@
 typedef void ia64_mv_cpu_init_t(void);
 typedef void ia64_mv_irq_init_t (void);
 typedef void ia64_mv_mca_init_t (void);
+typedef void ia64_mv_init_handler_t (pal_min_state_area_t *, struct pt_regs *,
struct switch_stack *);
 typedef void ia64_mv_mca_handler_t (void);
 typedef void ia64_mv_cmci_handler_t (int, void *, struct pt_regs *);
+typedef void ia64_mv_cpei_handler_t (int, void *, struct pt_regs *);
 typedef void ia64_mv_log_print_t (void);
 typedef void ia64_mv_send_ipi_t (int, int, int, int);
 typedef void ia64_mv_global_tlb_purge_t (unsigned long, unsigned long, unsigned
long);
@@ -86,8 +90,10 @@
 #  define platform_cpu_init ia64_mv.cpu_init
 #  define platform_irq_init ia64_mv.irq_init
 #  define platform_mca_init ia64_mv.mca_init
+#  define platform_init_handler ia64_mv.init_handler
 #  define platform_mca_handler ia64_mv.mca_handler
 #  define platform_cmci_handler ia64_mv.cmci_handler
+#  define platform_cpei_handler ia64_mv.cpei_handler
 #  define platform_log_print ia64_mv.log_print
 #  define platform_send_ipi ia64_mv.send_ipi
 #  define platform_global_tlb_purge ia64_mv.global_tlb_purge
@@ -127,8 +133,10 @@
  ia64_mv_cpu_init_t *cpu_init;
  ia64_mv_irq_init_t *irq_init;
  ia64_mv_mca_init_t *mca_init;
+ ia64_mv_init_handler_t *init_handler;
  ia64_mv_mca_handler_t *mca_handler;
  ia64_mv_cmci_handler_t *cmci_handler;
+ ia64_mv_cpei_handler_t *cpei_handler;
  ia64_mv_log_print_t *log_print;
  ia64_mv_send_ipi_t *send_ipi;
  ia64_mv_global_tlb_purge_t *global_tlb_purge;
@@ -164,8 +172,10 @@
  platform_cpu_init,   \
  platform_irq_init,   \
  platform_mca_init,   \
+ platform_init_handler,   \
  platform_mca_handler,   \
  platform_cmci_handler,   \
+ platform_cpei_handler,   \
  platform_log_print,   \
  platform_send_ipi,   \
  platform_global_tlb_purge,  \
@@ -229,13 +239,19 @@
 # define platform_irq_init ((ia64_mv_irq_init_t *) machvec_noop)
 #endif
 #ifndef platform_mca_init
-# define platform_mca_init ((ia64_mv_mca_init_t *) machvec_noop)
+# define platform_mca_init ia64_mca_init_platform
+#endif
+#ifndef platform_init_handler
+# define platform_init_handler  init_handler_platform
 #endif
 #ifndef platform_mca_handler
-# define platform_mca_handler ((ia64_mv_mca_handler_t *) machvec_noop)
+# define platform_mca_handler mca_handler_platform
 #endif
 #ifndef platform_cmci_handler
-# define platform_cmci_handler ((ia64_mv_cmci_handler_t *) machvec_noop)
+# define platform_cmci_handler ia64_mca_cmc_int_handler
+#endif
+#ifndef platform_cpei_handler
+# define platform_cpei_handler  ia64_mca_cpe_int_handler
 #endif
 #ifndef platform_log_print
 # define platform_log_print ((ia64_mv_log_print_t *) machvec_noop)

