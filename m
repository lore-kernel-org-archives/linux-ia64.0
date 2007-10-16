From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 16 Oct 2007 13:33:59 +0000
Subject: [PATCH 1/9] ia64: VIRT_CPU_ACCOUNTING (accurate cpu time accounting)
Message-Id: <4714BDC7.1070702@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> [1/9] ia64_add_config_virt_cpu_accounting.patch

The VIRT_CPU_ACCOUNTING option is already implemented s390
and powerpc archs.

By enabling this option, the arch can hook a function named
account_system_vtime() to irq_enter(), irq_exit(), and
head and tail of do_softirq().

This patch just add the Kconfig option to ia64, and enable
to hook ia64 specific account_system_vtime() function,
currently nop as generic one.

Thanks,
H.Seto

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

---
 arch/ia64/Kconfig         |   11 +++++++++++
 arch/ia64/kernel/time.c   |   13 +++++++++++++
 include/asm-ia64/system.h |    4 ++++
 3 files changed, 28 insertions(+)

Index: linux-2.6.23/arch/ia64/Kconfig
=================================--- linux-2.6.23.orig/arch/ia64/Kconfig
+++ linux-2.6.23/arch/ia64/Kconfig
@@ -257,6 +257,17 @@
 	default "17" if HUGETLB_PAGE
 	default "11"

+config VIRT_CPU_ACCOUNTING
+	bool "Deterministic task and CPU time accounting"
+	default y
+	help
+	  Select this option to enable more accurate task and CPU time
+	  accounting.  This is done by reading a CPU counter on each
+	  kernel entry and exit and on transitions within the kernel
+	  between system, softirq and hardirq state, so there is a
+	  small performance impact.
+	  If in doubt, say Y here.
+
 config SMP
 	bool "Symmetric multi-processing support"
 	help
Index: linux-2.6.23/arch/ia64/kernel/time.c
=================================--- linux-2.6.23.orig/arch/ia64/kernel/time.c
+++ linux-2.6.23/arch/ia64/kernel/time.c
@@ -59,6 +59,19 @@
 };
 static struct clocksource *itc_clocksource;

+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+
+/*
+ * Account time for a transition between system, hard irq
+ * or soft irq state.
+ */
+void account_system_vtime(struct task_struct *tsk)
+{
+
+}
+
+#endif /* CONFIG_VIRT_CPU_ACCOUNTING */
+
 static irqreturn_t
 timer_interrupt (int irq, void *dev_id)
 {
Index: linux-2.6.23/include/asm-ia64/system.h
=================================--- linux-2.6.23.orig/include/asm-ia64/system.h
+++ linux-2.6.23/include/asm-ia64/system.h
@@ -264,6 +264,10 @@

 void default_idle(void);

+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+extern void account_system_vtime(struct task_struct *);
+#endif
+
 #endif /* __KERNEL__ */

 #endif /* __ASSEMBLY__ */


