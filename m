From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 04 Dec 2003 06:06:07 +0000
Subject: [PATCH] switching MCA handling by machvecs [1/2]
Message-Id: <marc-linux-ia64-107051813204135@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106975273502765@msgid-missing>
In-Reply-To: <marc-linux-ia64-106975273502765@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Sorry, I had made a careless miss on previous patch code.
Here is a modified version.

This is a trial patch that helps platform to having special MCA handlers.
You can choose handler between platform specific one and default one 
by well defined machvecs linked to your platform.

I think this is just a part of what machvecs originally intend to implement,
and also think this encourages many ambitious platform venders.

I would appreciate if you give me your comment.


Thanks.

------

H.Seto <seto.hidetoshi@jp.fujitsu.com>

------

diff -Nur linux-2.6.0-test11.org/arch/ia64/kernel/mca.c linux-2.6.0-test11/arch/ia64/kernel/mca.c
--- linux-2.6.0-test11.org/arch/ia64/kernel/mca.c 2003-11-27 05:44:02.000000000 +0900
+++ linux-2.6.0-test11/arch/ia64/kernel/mca.c 2003-12-03 18:18:06.090569935 +0900
@@ -90,7 +90,7 @@
 extern struct hw_interrupt_type irq_type_iosapic_level;
 
 static struct irqaction cmci_irqaction = {
- .handler = ia64_mca_cmc_int_handler,
+ .handler = platform_cmci_handler_name,
  .flags = SA_INTERRUPT,
  .name =  "cmc_hndlr"
 };
@@ -115,7 +115,7 @@
 
 #ifdef CONFIG_ACPI
 static struct irqaction mca_cpe_irqaction = {
- .handler = ia64_mca_cpe_int_handler,
+ .handler = platform_cpei_handler_name,
  .flags = SA_INTERRUPT,
  .name =  "cpe_hndlr"
 };
@@ -186,9 +186,8 @@
 /*
  * platform dependent error handling
  */
-#ifndef PLATFORM_MCA_HANDLERS
 void
-mca_handler_platform (void)
+ia64_mca_handler_platform (void)
 {
 
 }
@@ -346,8 +345,8 @@
 }
 
 void
-init_handler_platform (pal_min_state_area_t *ms,
-         struct pt_regs *pt, struct switch_stack *sw)
+ia64_init_handler_platform (pal_min_state_area_t *ms,
+          struct pt_regs *pt, struct switch_stack *sw)
 {
  struct unw_frame_info info;
 
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
  ms = (pal_min_state_area_t *)(ia64_sal_to_os_handoff_state.pal_min_state | (6ul<<61));
 
- init_handler_platform(ms, pt, sw); /* call platform specific routines */
+ platform_init_handler(ms, pt, sw); /* call platform specific routines */
 }
 
 /*
diff -Nur linux-2.6.0-test11.org/include/asm-ia64/machvec.h linux-2.6.0-test11/include/asm-ia64/machvec.h
--- linux-2.6.0-test11.org/include/asm-ia64/machvec.h 2003-11-27 05:44:18.000000000 +0900
+++ linux-2.6.0-test11/include/asm-ia64/machvec.h 2003-12-03 18:18:06.091546497 +0900
@@ -12,6 +12,8 @@
 
 #include <linux/config.h>
 #include <linux/types.h>
+#include <asm/ptrace.h>
+#include <asm/pal.h>
 
 /* forward declarations: */
 struct device;
@@ -23,9 +25,11 @@
 typedef void ia64_mv_setup_t (char **);
 typedef void ia64_mv_cpu_init_t(void);
 typedef void ia64_mv_irq_init_t (void);
+typedef void ia64_mv_init_handler_t (pal_min_state_area_t *, struct pt_regs *, struct switch_stack *);
 typedef void ia64_mv_mca_init_t (void);
 typedef void ia64_mv_mca_handler_t (void);
 typedef void ia64_mv_cmci_handler_t (int, void *, struct pt_regs *);
+typedef void ia64_mv_cpei_handler_t (int, void *, struct pt_regs *);
 typedef void ia64_mv_log_print_t (void);
 typedef void ia64_mv_send_ipi_t (int, int, int, int);
 typedef void ia64_mv_global_tlb_purge_t (unsigned long, unsigned long, unsigned long);
@@ -67,6 +71,9 @@
 
 extern void machvec_noop (void);
 extern void machvec_memory_fence (void);
+extern void ia64_init_handler_platform (pal_min_state_area_t *, struct pt_regs *, struct switch_stack *);
+extern void ia64_mca_init_platform (void);
+extern void ia64_mca_handler_platform (void);
 
 # if defined (CONFIG_IA64_HP_SIM)
 #  include <asm/machvec_hpsim.h>
@@ -85,9 +92,15 @@
 #  define platform_setup ia64_mv.setup
 #  define platform_cpu_init ia64_mv.cpu_init
 #  define platform_irq_init ia64_mv.irq_init
+#  define platform_init_handler ia64_mv.init_handler
 #  define platform_mca_init ia64_mv.mca_init
 #  define platform_mca_handler ia64_mv.mca_handler
 #  define platform_cmci_handler ia64_mv.cmci_handler
+#  define platform_cmci_handler_name \
+   (irqreturn_t (*)(int,void *,struct pt_regs *))(&ia64_mv.cmci_handler)
+#  define platform_cpei_handler ia64_mv.cpei_handler
+#  define platform_cpei_handler_name \
+   (irqreturn_t (*)(int,void *,struct pt_regs *))(&ia64_mv.cpei_handler)
 #  define platform_log_print ia64_mv.log_print
 #  define platform_send_ipi ia64_mv.send_ipi
 #  define platform_global_tlb_purge ia64_mv.global_tlb_purge
@@ -126,9 +139,11 @@
  ia64_mv_setup_t *setup;
  ia64_mv_cpu_init_t *cpu_init;
  ia64_mv_irq_init_t *irq_init;
+ ia64_mv_init_handler_t *init_handler;
  ia64_mv_mca_init_t *mca_init;
  ia64_mv_mca_handler_t *mca_handler;
  ia64_mv_cmci_handler_t *cmci_handler;
+ ia64_mv_cpei_handler_t *cpei_handler;
  ia64_mv_log_print_t *log_print;
  ia64_mv_send_ipi_t *send_ipi;
  ia64_mv_global_tlb_purge_t *global_tlb_purge;
@@ -163,9 +178,11 @@
  platform_setup,    \
  platform_cpu_init,   \
  platform_irq_init,   \
+ platform_init_handler,   \
  platform_mca_init,   \
  platform_mca_handler,   \
  platform_cmci_handler,   \
+ platform_cpei_handler,   \
  platform_log_print,   \
  platform_send_ipi,   \
  platform_global_tlb_purge,  \
@@ -228,14 +245,22 @@
 #ifndef platform_irq_init
 # define platform_irq_init ((ia64_mv_irq_init_t *) machvec_noop)
 #endif
+#ifndef platform_init_handler
+# define platform_init_handler ((ia64_mv_init_handler_t *) ia64_init_handler_platform)
+#endif
 #ifndef platform_mca_init
-# define platform_mca_init ((ia64_mv_mca_init_t *) machvec_noop)
+# define platform_mca_init ((ia64_mv_mca_init_t *) ia64_mca_init_platform)
 #endif
 #ifndef platform_mca_handler
-# define platform_mca_handler ((ia64_mv_mca_handler_t *) machvec_noop)
+# define platform_mca_handler ((ia64_mv_mca_handler_t *) ia64_mca_handler_platform)
 #endif
 #ifndef platform_cmci_handler
-# define platform_cmci_handler ((ia64_mv_cmci_handler_t *) machvec_noop)
+# define platform_cmci_handler ((ia64_mv_cmci_handler_t *) ia64_mca_cmc_int_handler)
+# define platform_cmci_handler_name ia64_mca_cmc_int_handler
+#endif
+#ifndef platform_cpei_handler
+# define platform_cpei_handler ((ia64_mv_cpei_handler_t *) ia64_mca_cpe_int_handler)
+# define platform_cpei_handler_name ia64_mca_cpe_int_handler
 #endif
 #ifndef platform_log_print
 # define platform_log_print ((ia64_mv_log_print_t *) machvec_noop)
diff -Nur linux-2.6.0-test11.org/include/asm-ia64/machvec_init.h linux-2.6.0-test11/include/asm-ia64/machvec_init.h
--- linux-2.6.0-test11.org/include/asm-ia64/machvec_init.h 2003-11-27 05:42:51.000000000 +0900
+++ linux-2.6.0-test11/include/asm-ia64/machvec_init.h 2003-12-03 18:18:06.091546497 +0900
@@ -17,6 +17,12 @@
 extern ia64_mv_readl_t __ia64_readl;
 extern ia64_mv_readq_t __ia64_readq;
 
+extern ia64_mv_init_handler_t ia64_init_handler_platform;
+extern ia64_mv_mca_init_t ia64_mca_init_platform;
+extern ia64_mv_mca_handler_t ia64_mca_handler_platform;
+extern ia64_mv_cmci_handler_t ia64_mca_cmc_int_handler;
+extern ia64_mv_cpei_handler_t ia64_mca_cpe_int_handler;
+
 #define MACHVEC_HELPER(name)         \
  struct ia64_machine_vector machvec_##name __attribute__ ((unused, __section__ (".machvec"))) \
  = MACHVEC_INIT(name);

