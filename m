From: Luming Yu <luming.yu@gmail.com>
Date: Fri, 28 Aug 2009 03:18:15 +0000
Subject: [RFC PATCH] Add TRACE_IRQFLAGS_SUPPORT, LOCKDEP_SUPPORT then enable
Message-Id: <3877989d0908272018va6ee8f7n7ab2838fdf1b26e6@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="00504502c14d8e437e04722b22ef"
List-Id: <linux-ia64.vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, "Yu, Fenghua" <fenghua.yu@intel.com>, "Luck, Tony" <tony.luck@intel.com>
Cc: Felix Blyakher <felixb@sgi.com>, Shaohua Li <shaohua.li@intel.com>, Bob Picco <bob.picco@hp.com>

--00504502c14d8e437e04722b22ef
Content-Type: text/plain; charset=UTF-8

Hi there,

The following rfc patch is to add lockdep support and IRQ-flags
state tracing support for ia64 architecture based on instructions
described in irqflags-tracing.

The next step is to fix issues. I plan to target it for -32 or -33.

Ps. Bob Picco had done similar things before.

Ps. The patch is enclosed in attachment. The inlined one
is c&p of it for reading.


Thanks,
Luming

Signed-off-by: Bob Picco <bob.picco@hp.com>
Signed-off-by: Yu Luming <luming.yu@intel.com>

 arch/ia64/Kconfig              |    7 +++
 arch/ia64/Kconfig.debug        |    4 +
 arch/ia64/include/asm/page.h   |    2
 arch/ia64/include/asm/rwsem.h  |    3 +
 arch/ia64/include/asm/system.h |   84 -------------------------------------
 arch/ia64/kernel/Makefile      |    1
 arch/ia64/kernel/ivt.S         |    5 ++
 arch/ia64/kernel/smpboot.c     |    2
 arch/ia64/kernel/stacktrace.c  |   23 ++++++++++
 include/asm-ia64/irqflags.h    |   92 +++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/stacktrace.h  |    7 +++
 include/linux/lockdep.h        |    2
 lib/Kconfig.debug              |    2
 13 files changed, 147 insertions(+), 87 deletions(-)

diff -BruN linux-2.6.31-rc6/arch/ia64/include/asm/page.h
linux-2.6.31-rc6-lockdep/arch/ia64/include/asm/page.h
--- linux-2.6.31-rc6/arch/ia64/include/asm/page.h	2009-08-13
15:43:34.000000000 -0700
+++ linux-2.6.31-rc6-lockdep/arch/ia64/include/asm/page.h	2009-08-23
18:59:00.000000000 -0700
@@ -41,7 +41,7 @@
 #define PAGE_SIZE		(__IA64_UL_CONST(1) << PAGE_SHIFT)
 #define PAGE_MASK		(~(PAGE_SIZE - 1))

-#define PERCPU_PAGE_SHIFT	16	/* log2() of max. size of per-CPU area */
+#define PERCPU_PAGE_SHIFT	20	/*16 log2() of max. size of per-CPU area */
 #define PERCPU_PAGE_SIZE	(__IA64_UL_CONST(1) << PERCPU_PAGE_SHIFT)


diff -BruN linux-2.6.31-rc6/arch/ia64/include/asm/rwsem.h
linux-2.6.31-rc6-lockdep/arch/ia64/include/asm/rwsem.h
--- linux-2.6.31-rc6/arch/ia64/include/asm/rwsem.h	2009-08-13
15:43:34.000000000 -0700
+++ linux-2.6.31-rc6-lockdep/arch/ia64/include/asm/rwsem.h	2009-08-23
18:59:00.000000000 -0700
@@ -37,6 +37,9 @@
 	signed long		count;
 	spinlock_t		wait_lock;
 	struct list_head	wait_list;
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+	struct lockdep_map dep_map;
+#endif
 };

 #define RWSEM_UNLOCKED_VALUE		__IA64_UL_CONST(0x0000000000000000)
diff -BruN linux-2.6.31-rc6/arch/ia64/include/asm/system.h
linux-2.6.31-rc6-lockdep/arch/ia64/include/asm/system.h
--- linux-2.6.31-rc6/arch/ia64/include/asm/system.h	2009-08-13
15:43:34.000000000 -0700
+++ linux-2.6.31-rc6-lockdep/arch/ia64/include/asm/system.h	2009-08-23
18:59:00.000000000 -0700
@@ -107,88 +107,6 @@
  */
 #define set_mb(var, value)	do { (var) = (value); mb(); } while (0)

-#define safe_halt()         ia64_pal_halt_light()    /* PAL_HALT_LIGHT */
-
-/*
- * The group barrier in front of the rsm & ssm are necessary to ensure
- * that none of the previous instructions in the same group are
- * affected by the rsm/ssm.
- */
-/* For spinlocks etc */
-
-/*
- * - clearing psr.i is implicitly serialized (visible by next insn)
- * - setting psr.i requires data serialization
- * - we need a stop-bit before reading PSR because we sometimes
- *   write a floating-point register right before reading the PSR
- *   and that writes to PSR.mfl
- */
-#ifdef CONFIG_PARAVIRT
-#define __local_save_flags()	ia64_get_psr_i()
-#else
-#define __local_save_flags()	ia64_getreg(_IA64_REG_PSR)
-#endif
-
-#define __local_irq_save(x)			\
-do {						\
-	ia64_stop();				\
-	(x) = __local_save_flags();		\
-	ia64_stop();				\
-	ia64_rsm(IA64_PSR_I);			\
-} while (0)
-
-#define __local_irq_disable()			\
-do {						\
-	ia64_stop();				\
-	ia64_rsm(IA64_PSR_I);			\
-} while (0)
-
-#define __local_irq_restore(x)	ia64_intrin_local_irq_restore((x) & IA64_PSR_I)
-
-#ifdef CONFIG_IA64_DEBUG_IRQ
-
-  extern unsigned long last_cli_ip;
-
-# define __save_ip()		last_cli_ip = ia64_getreg(_IA64_REG_IP)
-
-# define local_irq_save(x)					\
-do {								\
-	unsigned long __psr;					\
-								\
-	__local_irq_save(__psr);				\
-	if (__psr & IA64_PSR_I)					\
-		__save_ip();					\
-	(x) = __psr;						\
-} while (0)
-
-# define local_irq_disable()	do { unsigned long __x;
local_irq_save(__x); } while (0)
-
-# define local_irq_restore(x)					\
-do {								\
-	unsigned long __old_psr, __psr = (x);			\
-								\
-	local_save_flags(__old_psr);				\
-	__local_irq_restore(__psr);				\
-	if ((__old_psr & IA64_PSR_I) && !(__psr & IA64_PSR_I))	\
-		__save_ip();					\
-} while (0)
-
-#else /* !CONFIG_IA64_DEBUG_IRQ */
-# define local_irq_save(x)	__local_irq_save(x)
-# define local_irq_disable()	__local_irq_disable()
-# define local_irq_restore(x)	__local_irq_restore(x)
-#endif /* !CONFIG_IA64_DEBUG_IRQ */
-
-#define local_irq_enable()	({ ia64_stop(); ia64_ssm(IA64_PSR_I);
ia64_srlz_d(); })
-#define local_save_flags(flags)	({ ia64_stop(); (flags) =
__local_save_flags(); })
-
-#define irqs_disabled()				\
-({						\
-	unsigned long __ia64_id_flags;		\
-	local_save_flags(__ia64_id_flags);	\
-	(__ia64_id_flags & IA64_PSR_I) == 0;	\
-})
-
 #ifdef __KERNEL__

 #ifdef CONFIG_IA32_SUPPORT
@@ -274,7 +192,7 @@
 #define __ARCH_WANT_UNLOCKED_CTXSW
 #define ARCH_HAS_PREFETCH_SWITCH_STACK
 #define ia64_platform_is(x) (strcmp(x, platform_name) == 0)
-
+#include <linux/irqflags.h>
 void cpu_idle_wait(void);

 #define arch_align_stack(x) (x)
diff -BruN linux-2.6.31-rc6/arch/ia64/Kconfig
linux-2.6.31-rc6-lockdep/arch/ia64/Kconfig
--- linux-2.6.31-rc6/arch/ia64/Kconfig	2009-08-13 15:43:34.000000000 -0700
+++ linux-2.6.31-rc6-lockdep/arch/ia64/Kconfig	2009-08-23
18:59:00.000000000 -0700
@@ -143,6 +143,13 @@

 endif

+config LOCKDEP_SUPPORT
+	bool
+	default y
+
+config STACKTRACE_SUPPORT
+	bool
+	default y
 choice
 	prompt "System type"
 	default IA64_GENERIC
diff -BruN linux-2.6.31-rc6/arch/ia64/Kconfig.debug
linux-2.6.31-rc6-lockdep/arch/ia64/Kconfig.debug
--- linux-2.6.31-rc6/arch/ia64/Kconfig.debug	2009-08-13 15:43:34.000000000 -0700
+++ linux-2.6.31-rc6-lockdep/arch/ia64/Kconfig.debug	2009-08-23
18:58:59.000000000 -0700
@@ -2,6 +2,10 @@

 source "lib/Kconfig.debug"

+config TRACE_IRQFLAGS_SUPPORT
+	bool
+	default y
+
 choice
 	prompt "Physical memory granularity"
 	default IA64_GRANULE_64MB
diff -BruN linux-2.6.31-rc6/arch/ia64/kernel/ivt.S
linux-2.6.31-rc6-lockdep/arch/ia64/kernel/ivt.S
--- linux-2.6.31-rc6/arch/ia64/kernel/ivt.S	2009-08-13 15:43:34.000000000 -0700
+++ linux-2.6.31-rc6-lockdep/arch/ia64/kernel/ivt.S	2009-08-23
18:58:59.000000000 -0700
@@ -1603,6 +1603,11 @@
 	SAVE_REST
 	;;
 	MCA_RECOVER_RANGE(interrupt)
+#ifdef CONFIG_TRACE_IRQFLAGS
+	;;
+	br.call.sptk.many rp=trace_hardirqs_off
+	;;
+#endif
 	alloc r14=ar.pfs,0,0,2,0 // must be first in an insn group
 	MOV_FROM_IVR(out0, r8)	// pass cr.ivr as first arg
 	add out1=16,sp		// pass pointer to pt_regs as second arg
diff -BruN linux-2.6.31-rc6/arch/ia64/kernel/Makefile
linux-2.6.31-rc6-lockdep/arch/ia64/kernel/Makefile
--- linux-2.6.31-rc6/arch/ia64/kernel/Makefile	2009-08-13
15:43:34.000000000 -0700
+++ linux-2.6.31-rc6-lockdep/arch/ia64/kernel/Makefile	2009-08-23
18:58:59.000000000 -0700
@@ -40,6 +40,7 @@
 obj-$(CONFIG_PCI_MSI)		+= msi_ia64.o
 mca_recovery-y			+= mca_drv.o mca_drv_asm.o
 obj-$(CONFIG_IA64_MC_ERR_INJECT)+= err_inject.o
+obj-$(CONFIG_STACKTRACE)	+= stacktrace.o

 obj-$(CONFIG_PARAVIRT)		+= paravirt.o paravirtentry.o \
 				   paravirt_patch.o
diff -BruN linux-2.6.31-rc6/arch/ia64/kernel/smpboot.c
linux-2.6.31-rc6-lockdep/arch/ia64/kernel/smpboot.c
--- linux-2.6.31-rc6/arch/ia64/kernel/smpboot.c	2009-08-13
15:43:34.000000000 -0700
+++ linux-2.6.31-rc6-lockdep/arch/ia64/kernel/smpboot.c	2009-08-23
18:58:59.000000000 -0700
@@ -504,7 +504,7 @@
 	struct create_idle c_idle = {
 		.work = __WORK_INITIALIZER(c_idle.work, do_fork_idle),
 		.cpu	= cpu,
-		.done	= COMPLETION_INITIALIZER(c_idle.done),
+		.done	= COMPLETION_INITIALIZER_ONSTACK(c_idle.done),
 	};

  	c_idle.idle = get_idle_for_cpu(cpu);
diff -BruN linux-2.6.31-rc6/arch/ia64/kernel/stacktrace.c
linux-2.6.31-rc6-lockdep/arch/ia64/kernel/stacktrace.c
--- linux-2.6.31-rc6/arch/ia64/kernel/stacktrace.c	1969-12-31
16:00:00.000000000 -0800
+++ linux-2.6.31-rc6-lockdep/arch/ia64/kernel/stacktrace.c	2009-08-23
18:58:59.000000000 -0700
@@ -0,0 +1,23 @@
+/*
+ * arch/x86_64/kernel/stacktrace.c
+ *
+ * Stack trace management functions
+ *
+ *  Copyright (C) 2006 Red Hat, Inc., Ingo Molnar <mingo@redhat.com>
+ */
+#include <linux/sched.h>
+#include <linux/stacktrace.h>
+#include <linux/module.h>
+#include <asm/stacktrace.h>
+
+/*
+ * Save stack-backtrace addresses into a stack_trace buffer.
+ */
+void save_stack_trace(struct stack_trace *trace)
+{
+}
+EXPORT_SYMBOL(save_stack_trace);
+void __ia64_save_stack_nonlocal(struct stack_trace *trace)
+{
+}
+EXPORT_SYMBOL(__ia64_save_stack_nonlocal);
diff -BruN linux-2.6.31-rc6/include/asm-ia64/irqflags.h
linux-2.6.31-rc6-lockdep/include/asm-ia64/irqflags.h
--- linux-2.6.31-rc6/include/asm-ia64/irqflags.h	1969-12-31
16:00:00.000000000 -0800
+++ linux-2.6.31-rc6-lockdep/include/asm-ia64/irqflags.h	2009-08-23
18:59:14.000000000 -0700
@@ -0,0 +1,92 @@
+#ifndef _ASM_IRQFLAGS_H
+#define _ASM_IRQFLAGS_H
+#include <asm/kregs.h>
+#include <asm/pal.h>
+/*
+ * The group barrier in front of the rsm & ssm are necessary to ensure
+ * that none of the previous instructions in the same group are
+ * affected by the rsm/ssm.
+ */
+/* For spinlocks etc */
+
+/*
+ * - clearing psr.i is implicitly serialized (visible by next insn)
+ * - setting psr.i requires data serialization
+ * - we need a stop-bit before reading PSR because we sometimes
+ *   write a floating-point register right before reading the PSR
+ *   and that writes to PSR.mfl
+ */
+#define __local_irq_save(x)			\
+do {						\
+	ia64_stop();				\
+	(x) = ia64_getreg(_IA64_REG_PSR);	\
+	ia64_stop();				\
+	ia64_rsm(IA64_PSR_I);			\
+} while (0)
+
+#define __local_irq_disable()			\
+do {						\
+	ia64_stop();				\
+	ia64_rsm(IA64_PSR_I);			\
+} while (0)
+
+#define __local_irq_restore(x)	ia64_intrin_local_irq_restore((x) & IA64_PSR_I)
+
+#ifdef CONFIG_IA64_DEBUG_IRQ
+
+  extern unsigned long last_cli_ip;
+
+# define __save_ip()		last_cli_ip = ia64_getreg(_IA64_REG_IP)
+
+# define raw_local_irq_save(x)					\
+do {								\
+	unsigned long psr;					\
+								\
+	__local_irq_save(psr);					\
+	if (psr & IA64_PSR_I)					\
+		__save_ip();					\
+	(x) = psr;						\
+} while (0)
+
+# define raw_local_irq_disable()	do { unsigned long x;
raw_local_irq_save(x); } while (0)
+
+# define raw_local_irq_restore(x)					\
+do {								\
+	unsigned long old_psr, psr = (x);			\
+								\
+	local_save_flags(old_psr);				\
+	__local_irq_restore(psr);				\
+	if ((old_psr & IA64_PSR_I) && !(psr & IA64_PSR_I))	\
+		__save_ip();					\
+} while (0)
+
+#else /* !CONFIG_IA64_DEBUG_IRQ */
+# define raw_local_irq_save(x)	__local_irq_save(x)
+# define raw_local_irq_disable()	__local_irq_disable()
+# define raw_local_irq_restore(x)	__local_irq_restore(x)
+#endif /* !CONFIG_IA64_DEBUG_IRQ */
+
+#define raw_local_irq_enable()	({ ia64_stop(); ia64_ssm(IA64_PSR_I);
ia64_srlz_d(); })
+#define raw_local_save_flags(flags)	({ ia64_stop(); (flags) =
ia64_getreg(_IA64_REG_PSR); })
+
+#define raw_irqs_disabled()				\
+({						\
+	unsigned long __ia64_id_flags;		\
+	raw_local_save_flags(__ia64_id_flags);	\
+	(__ia64_id_flags & IA64_PSR_I) == 0;	\
+})
+
+#define raw_safe_halt()         ia64_pal_halt_light()    /* PAL_HALT_LIGHT */
+#define raw_irqs_disabled_flags(flags)	\
+({						\
+	(int)((flags) & IA64_PSR_I) == 0;	\
+})
+	
+#ifdef CONFIG_TRACE_IRQFLAGS
+#define TRACE_IRQS_ON br.call.sptk.many b0=trace_hardirqs_on
+#define TRACE_IRQS_OFF br.call.sptk.many b0=trace_hardirqs_off
+#else
+#define TRACE_IRQS_ON
+#define TRACE_IRQS_OFF
+#endif
+#endif
diff -BruN linux-2.6.31-rc6/include/asm-ia64/stacktrace.h
linux-2.6.31-rc6-lockdep/include/asm-ia64/stacktrace.h
--- linux-2.6.31-rc6/include/asm-ia64/stacktrace.h	1969-12-31
16:00:00.000000000 -0800
+++ linux-2.6.31-rc6-lockdep/include/asm-ia64/stacktrace.h	2009-08-23
18:59:14.000000000 -0700
@@ -0,0 +1,7 @@
+#ifndef _ASM_STACKTRACE_H
+#define _ASM_STACKTRACE_H 1
+
+/* Generic stack tracer with callbacks */
+
+
+#endif
diff -BruN linux-2.6.31-rc6/include/linux/lockdep.h
linux-2.6.31-rc6-lockdep/include/linux/lockdep.h
--- linux-2.6.31-rc6/include/linux/lockdep.h	2009-08-13 15:43:34.000000000 -0700
+++ linux-2.6.31-rc6-lockdep/include/linux/lockdep.h	2009-08-23
18:59:20.000000000 -0700
@@ -162,7 +162,7 @@
 	u64				chain_key;
 };

-#define MAX_LOCKDEP_KEYS_BITS		13
+#define MAX_LOCKDEP_KEYS_BITS		10
 /*
  * Subtract one because we offset hlock->class_idx by 1 in order
  * to make 0 mean no class. This avoids overflowing the class_idx
diff -BruN linux-2.6.31-rc6/lib/Kconfig.debug
linux-2.6.31-rc6-lockdep/lib/Kconfig.debug
--- linux-2.6.31-rc6/lib/Kconfig.debug	2009-08-13 15:43:34.000000000 -0700
+++ linux-2.6.31-rc6-lockdep/lib/Kconfig.debug	2009-08-23
18:59:06.000000000 -0700
@@ -504,7 +504,7 @@

 config DEBUG_LOCKDEP
 	bool "Lock dependency engine debugging"
-	depends on DEBUG_KERNEL && LOCKDEP
+	depends on DEBUG_KERNEL && LOCKDEP && !IA64
 	help
 	  If you say Y here, the lock dependency engine will do
 	  additional runtime checks to debug itself, at the price

--00504502c14d8e437e04722b22ef
Content-Type: application/octet-stream; 
	name="ia64-lockdep-linux-2.6.31-rc6.patch"
Content-Disposition: attachment; 
	filename="ia64-lockdep-linux-2.6.31-rc6.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fywd05qz0

ZGlmZiAtQnJ1TiBsaW51eC0yLjYuMzEtcmM2L2FyY2gvaWE2NC9pbmNsdWRlL2FzbS9wYWdlLmgg
bGludXgtMi42LjMxLXJjNi1sb2NrZGVwL2FyY2gvaWE2NC9pbmNsdWRlL2FzbS9wYWdlLmgKLS0t
IGxpbnV4LTIuNi4zMS1yYzYvYXJjaC9pYTY0L2luY2x1ZGUvYXNtL3BhZ2UuaAkyMDA5LTA4LTEz
IDE1OjQzOjM0LjAwMDAwMDAwMCAtMDcwMAorKysgbGludXgtMi42LjMxLXJjNi1sb2NrZGVwL2Fy
Y2gvaWE2NC9pbmNsdWRlL2FzbS9wYWdlLmgJMjAwOS0wOC0yMyAxODo1OTowMC4wMDAwMDAwMDAg
LTA3MDAKQEAgLTQxLDcgKzQxLDcgQEAKICNkZWZpbmUgUEFHRV9TSVpFCQkoX19JQTY0X1VMX0NP
TlNUKDEpIDw8IFBBR0VfU0hJRlQpCiAjZGVmaW5lIFBBR0VfTUFTSwkJKH4oUEFHRV9TSVpFIC0g
MSkpCiAKLSNkZWZpbmUgUEVSQ1BVX1BBR0VfU0hJRlQJMTYJLyogbG9nMigpIG9mIG1heC4gc2l6
ZSBvZiBwZXItQ1BVIGFyZWEgKi8KKyNkZWZpbmUgUEVSQ1BVX1BBR0VfU0hJRlQJMjAJLyoxNiBs
b2cyKCkgb2YgbWF4LiBzaXplIG9mIHBlci1DUFUgYXJlYSAqLwogI2RlZmluZSBQRVJDUFVfUEFH
RV9TSVpFCShfX0lBNjRfVUxfQ09OU1QoMSkgPDwgUEVSQ1BVX1BBR0VfU0hJRlQpCiAKIApkaWZm
IC1CcnVOIGxpbnV4LTIuNi4zMS1yYzYvYXJjaC9pYTY0L2luY2x1ZGUvYXNtL3J3c2VtLmggbGlu
dXgtMi42LjMxLXJjNi1sb2NrZGVwL2FyY2gvaWE2NC9pbmNsdWRlL2FzbS9yd3NlbS5oCi0tLSBs
aW51eC0yLjYuMzEtcmM2L2FyY2gvaWE2NC9pbmNsdWRlL2FzbS9yd3NlbS5oCTIwMDktMDgtMTMg
MTU6NDM6MzQuMDAwMDAwMDAwIC0wNzAwCisrKyBsaW51eC0yLjYuMzEtcmM2LWxvY2tkZXAvYXJj
aC9pYTY0L2luY2x1ZGUvYXNtL3J3c2VtLmgJMjAwOS0wOC0yMyAxODo1OTowMC4wMDAwMDAwMDAg
LTA3MDAKQEAgLTM3LDYgKzM3LDkgQEAKIAlzaWduZWQgbG9uZwkJY291bnQ7CiAJc3BpbmxvY2tf
dAkJd2FpdF9sb2NrOwogCXN0cnVjdCBsaXN0X2hlYWQJd2FpdF9saXN0OworI2lmZGVmIENPTkZJ
R19ERUJVR19MT0NLX0FMTE9DCisJc3RydWN0IGxvY2tkZXBfbWFwIGRlcF9tYXA7CisjZW5kaWYg
CiB9OwogCiAjZGVmaW5lIFJXU0VNX1VOTE9DS0VEX1ZBTFVFCQlfX0lBNjRfVUxfQ09OU1QoMHgw
MDAwMDAwMDAwMDAwMDAwKQpkaWZmIC1CcnVOIGxpbnV4LTIuNi4zMS1yYzYvYXJjaC9pYTY0L2lu
Y2x1ZGUvYXNtL3N5c3RlbS5oIGxpbnV4LTIuNi4zMS1yYzYtbG9ja2RlcC9hcmNoL2lhNjQvaW5j
bHVkZS9hc20vc3lzdGVtLmgKLS0tIGxpbnV4LTIuNi4zMS1yYzYvYXJjaC9pYTY0L2luY2x1ZGUv
YXNtL3N5c3RlbS5oCTIwMDktMDgtMTMgMTU6NDM6MzQuMDAwMDAwMDAwIC0wNzAwCisrKyBsaW51
eC0yLjYuMzEtcmM2LWxvY2tkZXAvYXJjaC9pYTY0L2luY2x1ZGUvYXNtL3N5c3RlbS5oCTIwMDkt
MDgtMjMgMTg6NTk6MDAuMDAwMDAwMDAwIC0wNzAwCkBAIC0xMDcsODggKzEwNyw2IEBACiAgKi8K
ICNkZWZpbmUgc2V0X21iKHZhciwgdmFsdWUpCWRvIHsgKHZhcikgPSAodmFsdWUpOyBtYigpOyB9
IHdoaWxlICgwKQogCi0jZGVmaW5lIHNhZmVfaGFsdCgpICAgICAgICAgaWE2NF9wYWxfaGFsdF9s
aWdodCgpICAgIC8qIFBBTF9IQUxUX0xJR0hUICovCi0KLS8qCi0gKiBUaGUgZ3JvdXAgYmFycmll
ciBpbiBmcm9udCBvZiB0aGUgcnNtICYgc3NtIGFyZSBuZWNlc3NhcnkgdG8gZW5zdXJlCi0gKiB0
aGF0IG5vbmUgb2YgdGhlIHByZXZpb3VzIGluc3RydWN0aW9ucyBpbiB0aGUgc2FtZSBncm91cCBh
cmUKLSAqIGFmZmVjdGVkIGJ5IHRoZSByc20vc3NtLgotICovCi0vKiBGb3Igc3BpbmxvY2tzIGV0
YyAqLwotCi0vKgotICogLSBjbGVhcmluZyBwc3IuaSBpcyBpbXBsaWNpdGx5IHNlcmlhbGl6ZWQg
KHZpc2libGUgYnkgbmV4dCBpbnNuKQotICogLSBzZXR0aW5nIHBzci5pIHJlcXVpcmVzIGRhdGEg
c2VyaWFsaXphdGlvbgotICogLSB3ZSBuZWVkIGEgc3RvcC1iaXQgYmVmb3JlIHJlYWRpbmcgUFNS
IGJlY2F1c2Ugd2Ugc29tZXRpbWVzCi0gKiAgIHdyaXRlIGEgZmxvYXRpbmctcG9pbnQgcmVnaXN0
ZXIgcmlnaHQgYmVmb3JlIHJlYWRpbmcgdGhlIFBTUgotICogICBhbmQgdGhhdCB3cml0ZXMgdG8g
UFNSLm1mbAotICovCi0jaWZkZWYgQ09ORklHX1BBUkFWSVJUCi0jZGVmaW5lIF9fbG9jYWxfc2F2
ZV9mbGFncygpCWlhNjRfZ2V0X3Bzcl9pKCkKLSNlbHNlCi0jZGVmaW5lIF9fbG9jYWxfc2F2ZV9m
bGFncygpCWlhNjRfZ2V0cmVnKF9JQTY0X1JFR19QU1IpCi0jZW5kaWYKLQotI2RlZmluZSBfX2xv
Y2FsX2lycV9zYXZlKHgpCQkJXAotZG8gewkJCQkJCVwKLQlpYTY0X3N0b3AoKTsJCQkJXAotCSh4
KSA9IF9fbG9jYWxfc2F2ZV9mbGFncygpOwkJXAotCWlhNjRfc3RvcCgpOwkJCQlcCi0JaWE2NF9y
c20oSUE2NF9QU1JfSSk7CQkJXAotfSB3aGlsZSAoMCkKLQotI2RlZmluZSBfX2xvY2FsX2lycV9k
aXNhYmxlKCkJCQlcCi1kbyB7CQkJCQkJXAotCWlhNjRfc3RvcCgpOwkJCQlcCi0JaWE2NF9yc20o
SUE2NF9QU1JfSSk7CQkJXAotfSB3aGlsZSAoMCkKLQotI2RlZmluZSBfX2xvY2FsX2lycV9yZXN0
b3JlKHgpCWlhNjRfaW50cmluX2xvY2FsX2lycV9yZXN0b3JlKCh4KSAmIElBNjRfUFNSX0kpCi0K
LSNpZmRlZiBDT05GSUdfSUE2NF9ERUJVR19JUlEKLQotICBleHRlcm4gdW5zaWduZWQgbG9uZyBs
YXN0X2NsaV9pcDsKLQotIyBkZWZpbmUgX19zYXZlX2lwKCkJCWxhc3RfY2xpX2lwID0gaWE2NF9n
ZXRyZWcoX0lBNjRfUkVHX0lQKQotCi0jIGRlZmluZSBsb2NhbF9pcnFfc2F2ZSh4KQkJCQkJXAot
ZG8gewkJCQkJCQkJXAotCXVuc2lnbmVkIGxvbmcgX19wc3I7CQkJCQlcCi0JCQkJCQkJCVwKLQlf
X2xvY2FsX2lycV9zYXZlKF9fcHNyKTsJCQkJXAotCWlmIChfX3BzciAmIElBNjRfUFNSX0kpCQkJ
CQlcCi0JCV9fc2F2ZV9pcCgpOwkJCQkJXAotCSh4KSA9IF9fcHNyOwkJCQkJCVwKLX0gd2hpbGUg
KDApCi0KLSMgZGVmaW5lIGxvY2FsX2lycV9kaXNhYmxlKCkJZG8geyB1bnNpZ25lZCBsb25nIF9f
eDsgbG9jYWxfaXJxX3NhdmUoX194KTsgfSB3aGlsZSAoMCkKLQotIyBkZWZpbmUgbG9jYWxfaXJx
X3Jlc3RvcmUoeCkJCQkJCVwKLWRvIHsJCQkJCQkJCVwKLQl1bnNpZ25lZCBsb25nIF9fb2xkX3Bz
ciwgX19wc3IgPSAoeCk7CQkJXAotCQkJCQkJCQlcCi0JbG9jYWxfc2F2ZV9mbGFncyhfX29sZF9w
c3IpOwkJCQlcCi0JX19sb2NhbF9pcnFfcmVzdG9yZShfX3Bzcik7CQkJCVwKLQlpZiAoKF9fb2xk
X3BzciAmIElBNjRfUFNSX0kpICYmICEoX19wc3IgJiBJQTY0X1BTUl9JKSkJXAotCQlfX3NhdmVf
aXAoKTsJCQkJCVwKLX0gd2hpbGUgKDApCi0KLSNlbHNlIC8qICFDT05GSUdfSUE2NF9ERUJVR19J
UlEgKi8KLSMgZGVmaW5lIGxvY2FsX2lycV9zYXZlKHgpCV9fbG9jYWxfaXJxX3NhdmUoeCkKLSMg
ZGVmaW5lIGxvY2FsX2lycV9kaXNhYmxlKCkJX19sb2NhbF9pcnFfZGlzYWJsZSgpCi0jIGRlZmlu
ZSBsb2NhbF9pcnFfcmVzdG9yZSh4KQlfX2xvY2FsX2lycV9yZXN0b3JlKHgpCi0jZW5kaWYgLyog
IUNPTkZJR19JQTY0X0RFQlVHX0lSUSAqLwotCi0jZGVmaW5lIGxvY2FsX2lycV9lbmFibGUoKQko
eyBpYTY0X3N0b3AoKTsgaWE2NF9zc20oSUE2NF9QU1JfSSk7IGlhNjRfc3Jsel9kKCk7IH0pCi0j
ZGVmaW5lIGxvY2FsX3NhdmVfZmxhZ3MoZmxhZ3MpCSh7IGlhNjRfc3RvcCgpOyAoZmxhZ3MpID0g
X19sb2NhbF9zYXZlX2ZsYWdzKCk7IH0pCi0KLSNkZWZpbmUgaXJxc19kaXNhYmxlZCgpCQkJCVwK
LSh7CQkJCQkJXAotCXVuc2lnbmVkIGxvbmcgX19pYTY0X2lkX2ZsYWdzOwkJXAotCWxvY2FsX3Nh
dmVfZmxhZ3MoX19pYTY0X2lkX2ZsYWdzKTsJXAotCShfX2lhNjRfaWRfZmxhZ3MgJiBJQTY0X1BT
Ul9JKSA9PSAwOwlcCi19KQotCiAjaWZkZWYgX19LRVJORUxfXwogCiAjaWZkZWYgQ09ORklHX0lB
MzJfU1VQUE9SVApAQCAtMjc0LDcgKzE5Miw3IEBACiAjZGVmaW5lIF9fQVJDSF9XQU5UX1VOTE9D
S0VEX0NUWFNXCiAjZGVmaW5lIEFSQ0hfSEFTX1BSRUZFVENIX1NXSVRDSF9TVEFDSwogI2RlZmlu
ZSBpYTY0X3BsYXRmb3JtX2lzKHgpIChzdHJjbXAoeCwgcGxhdGZvcm1fbmFtZSkgPT0gMCkKLQor
I2luY2x1ZGUgPGxpbnV4L2lycWZsYWdzLmg+CiB2b2lkIGNwdV9pZGxlX3dhaXQodm9pZCk7CiAK
ICNkZWZpbmUgYXJjaF9hbGlnbl9zdGFjayh4KSAoeCkKZGlmZiAtQnJ1TiBsaW51eC0yLjYuMzEt
cmM2L2FyY2gvaWE2NC9LY29uZmlnIGxpbnV4LTIuNi4zMS1yYzYtbG9ja2RlcC9hcmNoL2lhNjQv
S2NvbmZpZwotLS0gbGludXgtMi42LjMxLXJjNi9hcmNoL2lhNjQvS2NvbmZpZwkyMDA5LTA4LTEz
IDE1OjQzOjM0LjAwMDAwMDAwMCAtMDcwMAorKysgbGludXgtMi42LjMxLXJjNi1sb2NrZGVwL2Fy
Y2gvaWE2NC9LY29uZmlnCTIwMDktMDgtMjMgMTg6NTk6MDAuMDAwMDAwMDAwIC0wNzAwCkBAIC0x
NDMsNiArMTQzLDEzIEBACiAKIGVuZGlmCiAKK2NvbmZpZyBMT0NLREVQX1NVUFBPUlQKKwlib29s
CisJZGVmYXVsdCB5CisKK2NvbmZpZyBTVEFDS1RSQUNFX1NVUFBPUlQKKwlib29sCisJZGVmYXVs
dCB5CiBjaG9pY2UKIAlwcm9tcHQgIlN5c3RlbSB0eXBlIgogCWRlZmF1bHQgSUE2NF9HRU5FUklD
CmRpZmYgLUJydU4gbGludXgtMi42LjMxLXJjNi9hcmNoL2lhNjQvS2NvbmZpZy5kZWJ1ZyBsaW51
eC0yLjYuMzEtcmM2LWxvY2tkZXAvYXJjaC9pYTY0L0tjb25maWcuZGVidWcKLS0tIGxpbnV4LTIu
Ni4zMS1yYzYvYXJjaC9pYTY0L0tjb25maWcuZGVidWcJMjAwOS0wOC0xMyAxNTo0MzozNC4wMDAw
MDAwMDAgLTA3MDAKKysrIGxpbnV4LTIuNi4zMS1yYzYtbG9ja2RlcC9hcmNoL2lhNjQvS2NvbmZp
Zy5kZWJ1ZwkyMDA5LTA4LTIzIDE4OjU4OjU5LjAwMDAwMDAwMCAtMDcwMApAQCAtMiw2ICsyLDEw
IEBACiAKIHNvdXJjZSAibGliL0tjb25maWcuZGVidWciCiAKK2NvbmZpZyBUUkFDRV9JUlFGTEFH
U19TVVBQT1JUCisJYm9vbAorCWRlZmF1bHQgeQorCiBjaG9pY2UKIAlwcm9tcHQgIlBoeXNpY2Fs
IG1lbW9yeSBncmFudWxhcml0eSIKIAlkZWZhdWx0IElBNjRfR1JBTlVMRV82NE1CCmRpZmYgLUJy
dU4gbGludXgtMi42LjMxLXJjNi9hcmNoL2lhNjQva2VybmVsL2l2dC5TIGxpbnV4LTIuNi4zMS1y
YzYtbG9ja2RlcC9hcmNoL2lhNjQva2VybmVsL2l2dC5TCi0tLSBsaW51eC0yLjYuMzEtcmM2L2Fy
Y2gvaWE2NC9rZXJuZWwvaXZ0LlMJMjAwOS0wOC0xMyAxNTo0MzozNC4wMDAwMDAwMDAgLTA3MDAK
KysrIGxpbnV4LTIuNi4zMS1yYzYtbG9ja2RlcC9hcmNoL2lhNjQva2VybmVsL2l2dC5TCTIwMDkt
MDgtMjMgMTg6NTg6NTkuMDAwMDAwMDAwIC0wNzAwCkBAIC0xNjAzLDYgKzE2MDMsMTEgQEAKIAlT
QVZFX1JFU1QKIAk7OwogCU1DQV9SRUNPVkVSX1JBTkdFKGludGVycnVwdCkKKyNpZmRlZiBDT05G
SUdfVFJBQ0VfSVJRRkxBR1MKKwk7OworCWJyLmNhbGwuc3B0ay5tYW55IHJwPXRyYWNlX2hhcmRp
cnFzX29mZgorCTs7CisjZW5kaWYKIAlhbGxvYyByMTQ9YXIucGZzLDAsMCwyLDAgLy8gbXVzdCBi
ZSBmaXJzdCBpbiBhbiBpbnNuIGdyb3VwCiAJTU9WX0ZST01fSVZSKG91dDAsIHI4KQkvLyBwYXNz
IGNyLml2ciBhcyBmaXJzdCBhcmcKIAlhZGQgb3V0MT0xNixzcAkJLy8gcGFzcyBwb2ludGVyIHRv
IHB0X3JlZ3MgYXMgc2Vjb25kIGFyZwpkaWZmIC1CcnVOIGxpbnV4LTIuNi4zMS1yYzYvYXJjaC9p
YTY0L2tlcm5lbC9NYWtlZmlsZSBsaW51eC0yLjYuMzEtcmM2LWxvY2tkZXAvYXJjaC9pYTY0L2tl
cm5lbC9NYWtlZmlsZQotLS0gbGludXgtMi42LjMxLXJjNi9hcmNoL2lhNjQva2VybmVsL01ha2Vm
aWxlCTIwMDktMDgtMTMgMTU6NDM6MzQuMDAwMDAwMDAwIC0wNzAwCisrKyBsaW51eC0yLjYuMzEt
cmM2LWxvY2tkZXAvYXJjaC9pYTY0L2tlcm5lbC9NYWtlZmlsZQkyMDA5LTA4LTIzIDE4OjU4OjU5
LjAwMDAwMDAwMCAtMDcwMApAQCAtNDAsNiArNDAsNyBAQAogb2JqLSQoQ09ORklHX1BDSV9NU0kp
CQkrPSBtc2lfaWE2NC5vCiBtY2FfcmVjb3ZlcnkteQkJCSs9IG1jYV9kcnYubyBtY2FfZHJ2X2Fz
bS5vCiBvYmotJChDT05GSUdfSUE2NF9NQ19FUlJfSU5KRUNUKSs9IGVycl9pbmplY3Qubworb2Jq
LSQoQ09ORklHX1NUQUNLVFJBQ0UpCSs9IHN0YWNrdHJhY2UubwogCiBvYmotJChDT05GSUdfUEFS
QVZJUlQpCQkrPSBwYXJhdmlydC5vIHBhcmF2aXJ0ZW50cnkubyBcCiAJCQkJICAgcGFyYXZpcnRf
cGF0Y2gubwpkaWZmIC1CcnVOIGxpbnV4LTIuNi4zMS1yYzYvYXJjaC9pYTY0L2tlcm5lbC9zbXBi
b290LmMgbGludXgtMi42LjMxLXJjNi1sb2NrZGVwL2FyY2gvaWE2NC9rZXJuZWwvc21wYm9vdC5j
Ci0tLSBsaW51eC0yLjYuMzEtcmM2L2FyY2gvaWE2NC9rZXJuZWwvc21wYm9vdC5jCTIwMDktMDgt
MTMgMTU6NDM6MzQuMDAwMDAwMDAwIC0wNzAwCisrKyBsaW51eC0yLjYuMzEtcmM2LWxvY2tkZXAv
YXJjaC9pYTY0L2tlcm5lbC9zbXBib290LmMJMjAwOS0wOC0yMyAxODo1ODo1OS4wMDAwMDAwMDAg
LTA3MDAKQEAgLTUwNCw3ICs1MDQsNyBAQAogCXN0cnVjdCBjcmVhdGVfaWRsZSBjX2lkbGUgPSB7
CiAJCS53b3JrID0gX19XT1JLX0lOSVRJQUxJWkVSKGNfaWRsZS53b3JrLCBkb19mb3JrX2lkbGUp
LAogCQkuY3B1CT0gY3B1LAotCQkuZG9uZQk9IENPTVBMRVRJT05fSU5JVElBTElaRVIoY19pZGxl
LmRvbmUpLAorCQkuZG9uZQk9IENPTVBMRVRJT05fSU5JVElBTElaRVJfT05TVEFDSyhjX2lkbGUu
ZG9uZSksCiAJfTsKIAogIAljX2lkbGUuaWRsZSA9IGdldF9pZGxlX2Zvcl9jcHUoY3B1KTsKZGlm
ZiAtQnJ1TiBsaW51eC0yLjYuMzEtcmM2L2FyY2gvaWE2NC9rZXJuZWwvc3RhY2t0cmFjZS5jIGxp
bnV4LTIuNi4zMS1yYzYtbG9ja2RlcC9hcmNoL2lhNjQva2VybmVsL3N0YWNrdHJhY2UuYwotLS0g
bGludXgtMi42LjMxLXJjNi9hcmNoL2lhNjQva2VybmVsL3N0YWNrdHJhY2UuYwkxOTY5LTEyLTMx
IDE2OjAwOjAwLjAwMDAwMDAwMCAtMDgwMAorKysgbGludXgtMi42LjMxLXJjNi1sb2NrZGVwL2Fy
Y2gvaWE2NC9rZXJuZWwvc3RhY2t0cmFjZS5jCTIwMDktMDgtMjMgMTg6NTg6NTkuMDAwMDAwMDAw
IC0wNzAwCkBAIC0wLDAgKzEsMjMgQEAKKy8qCisgKiBhcmNoL3g4Nl82NC9rZXJuZWwvc3RhY2t0
cmFjZS5jCisgKgorICogU3RhY2sgdHJhY2UgbWFuYWdlbWVudCBmdW5jdGlvbnMKKyAqCisgKiAg
Q29weXJpZ2h0IChDKSAyMDA2IFJlZCBIYXQsIEluYy4sIEluZ28gTW9sbmFyIDxtaW5nb0ByZWRo
YXQuY29tPgorICovCisjaW5jbHVkZSA8bGludXgvc2NoZWQuaD4KKyNpbmNsdWRlIDxsaW51eC9z
dGFja3RyYWNlLmg+CisjaW5jbHVkZSA8bGludXgvbW9kdWxlLmg+CisjaW5jbHVkZSA8YXNtL3N0
YWNrdHJhY2UuaD4KKworLyoKKyAqIFNhdmUgc3RhY2stYmFja3RyYWNlIGFkZHJlc3NlcyBpbnRv
IGEgc3RhY2tfdHJhY2UgYnVmZmVyLgorICovCit2b2lkIHNhdmVfc3RhY2tfdHJhY2Uoc3RydWN0
IHN0YWNrX3RyYWNlICp0cmFjZSkKK3sKK30KK0VYUE9SVF9TWU1CT0woc2F2ZV9zdGFja190cmFj
ZSk7Cit2b2lkIF9faWE2NF9zYXZlX3N0YWNrX25vbmxvY2FsKHN0cnVjdCBzdGFja190cmFjZSAq
dHJhY2UpCit7Cit9CitFWFBPUlRfU1lNQk9MKF9faWE2NF9zYXZlX3N0YWNrX25vbmxvY2FsKTsK
ZGlmZiAtQnJ1TiBsaW51eC0yLjYuMzEtcmM2L2luY2x1ZGUvYXNtLWlhNjQvaXJxZmxhZ3MuaCBs
aW51eC0yLjYuMzEtcmM2LWxvY2tkZXAvaW5jbHVkZS9hc20taWE2NC9pcnFmbGFncy5oCi0tLSBs
aW51eC0yLjYuMzEtcmM2L2luY2x1ZGUvYXNtLWlhNjQvaXJxZmxhZ3MuaAkxOTY5LTEyLTMxIDE2
OjAwOjAwLjAwMDAwMDAwMCAtMDgwMAorKysgbGludXgtMi42LjMxLXJjNi1sb2NrZGVwL2luY2x1
ZGUvYXNtLWlhNjQvaXJxZmxhZ3MuaAkyMDA5LTA4LTIzIDE4OjU5OjE0LjAwMDAwMDAwMCAtMDcw
MApAQCAtMCwwICsxLDkyIEBACisjaWZuZGVmIF9BU01fSVJRRkxBR1NfSAorI2RlZmluZSBfQVNN
X0lSUUZMQUdTX0gKKyNpbmNsdWRlIDxhc20va3JlZ3MuaD4KKyNpbmNsdWRlIDxhc20vcGFsLmg+
CisvKgorICogVGhlIGdyb3VwIGJhcnJpZXIgaW4gZnJvbnQgb2YgdGhlIHJzbSAmIHNzbSBhcmUg
bmVjZXNzYXJ5IHRvIGVuc3VyZQorICogdGhhdCBub25lIG9mIHRoZSBwcmV2aW91cyBpbnN0cnVj
dGlvbnMgaW4gdGhlIHNhbWUgZ3JvdXAgYXJlCisgKiBhZmZlY3RlZCBieSB0aGUgcnNtL3NzbS4K
KyAqLworLyogRm9yIHNwaW5sb2NrcyBldGMgKi8KKworLyoKKyAqIC0gY2xlYXJpbmcgcHNyLmkg
aXMgaW1wbGljaXRseSBzZXJpYWxpemVkICh2aXNpYmxlIGJ5IG5leHQgaW5zbikKKyAqIC0gc2V0
dGluZyBwc3IuaSByZXF1aXJlcyBkYXRhIHNlcmlhbGl6YXRpb24KKyAqIC0gd2UgbmVlZCBhIHN0
b3AtYml0IGJlZm9yZSByZWFkaW5nIFBTUiBiZWNhdXNlIHdlIHNvbWV0aW1lcworICogICB3cml0
ZSBhIGZsb2F0aW5nLXBvaW50IHJlZ2lzdGVyIHJpZ2h0IGJlZm9yZSByZWFkaW5nIHRoZSBQU1IK
KyAqICAgYW5kIHRoYXQgd3JpdGVzIHRvIFBTUi5tZmwKKyAqLworI2RlZmluZSBfX2xvY2FsX2ly
cV9zYXZlKHgpCQkJXAorZG8gewkJCQkJCVwKKwlpYTY0X3N0b3AoKTsJCQkJXAorCSh4KSA9IGlh
NjRfZ2V0cmVnKF9JQTY0X1JFR19QU1IpOwlcCisJaWE2NF9zdG9wKCk7CQkJCVwKKwlpYTY0X3Jz
bShJQTY0X1BTUl9JKTsJCQlcCit9IHdoaWxlICgwKQorCisjZGVmaW5lIF9fbG9jYWxfaXJxX2Rp
c2FibGUoKQkJCVwKK2RvIHsJCQkJCQlcCisJaWE2NF9zdG9wKCk7CQkJCVwKKwlpYTY0X3JzbShJ
QTY0X1BTUl9JKTsJCQlcCit9IHdoaWxlICgwKQorCisjZGVmaW5lIF9fbG9jYWxfaXJxX3Jlc3Rv
cmUoeCkJaWE2NF9pbnRyaW5fbG9jYWxfaXJxX3Jlc3RvcmUoKHgpICYgSUE2NF9QU1JfSSkKKwor
I2lmZGVmIENPTkZJR19JQTY0X0RFQlVHX0lSUQorCisgIGV4dGVybiB1bnNpZ25lZCBsb25nIGxh
c3RfY2xpX2lwOworCisjIGRlZmluZSBfX3NhdmVfaXAoKQkJbGFzdF9jbGlfaXAgPSBpYTY0X2dl
dHJlZyhfSUE2NF9SRUdfSVApCisKKyMgZGVmaW5lIHJhd19sb2NhbF9pcnFfc2F2ZSh4KQkJCQkJ
XAorZG8gewkJCQkJCQkJXAorCXVuc2lnbmVkIGxvbmcgcHNyOwkJCQkJXAorCQkJCQkJCQlcCisJ
X19sb2NhbF9pcnFfc2F2ZShwc3IpOwkJCQkJXAorCWlmIChwc3IgJiBJQTY0X1BTUl9JKQkJCQkJ
XAorCQlfX3NhdmVfaXAoKTsJCQkJCVwKKwkoeCkgPSBwc3I7CQkJCQkJXAorfSB3aGlsZSAoMCkK
KworIyBkZWZpbmUgcmF3X2xvY2FsX2lycV9kaXNhYmxlKCkJZG8geyB1bnNpZ25lZCBsb25nIHg7
IHJhd19sb2NhbF9pcnFfc2F2ZSh4KTsgfSB3aGlsZSAoMCkKKworIyBkZWZpbmUgcmF3X2xvY2Fs
X2lycV9yZXN0b3JlKHgpCQkJCQlcCitkbyB7CQkJCQkJCQlcCisJdW5zaWduZWQgbG9uZyBvbGRf
cHNyLCBwc3IgPSAoeCk7CQkJXAorCQkJCQkJCQlcCisJbG9jYWxfc2F2ZV9mbGFncyhvbGRfcHNy
KTsJCQkJXAorCV9fbG9jYWxfaXJxX3Jlc3RvcmUocHNyKTsJCQkJXAorCWlmICgob2xkX3BzciAm
IElBNjRfUFNSX0kpICYmICEocHNyICYgSUE2NF9QU1JfSSkpCVwKKwkJX19zYXZlX2lwKCk7CQkJ
CQlcCit9IHdoaWxlICgwKQorCisjZWxzZSAvKiAhQ09ORklHX0lBNjRfREVCVUdfSVJRICovCisj
IGRlZmluZSByYXdfbG9jYWxfaXJxX3NhdmUoeCkJX19sb2NhbF9pcnFfc2F2ZSh4KQorIyBkZWZp
bmUgcmF3X2xvY2FsX2lycV9kaXNhYmxlKCkJX19sb2NhbF9pcnFfZGlzYWJsZSgpCisjIGRlZmlu
ZSByYXdfbG9jYWxfaXJxX3Jlc3RvcmUoeCkJX19sb2NhbF9pcnFfcmVzdG9yZSh4KQorI2VuZGlm
IC8qICFDT05GSUdfSUE2NF9ERUJVR19JUlEgKi8KKworI2RlZmluZSByYXdfbG9jYWxfaXJxX2Vu
YWJsZSgpCSh7IGlhNjRfc3RvcCgpOyBpYTY0X3NzbShJQTY0X1BTUl9JKTsgaWE2NF9zcmx6X2Qo
KTsgfSkKKyNkZWZpbmUgcmF3X2xvY2FsX3NhdmVfZmxhZ3MoZmxhZ3MpCSh7IGlhNjRfc3RvcCgp
OyAoZmxhZ3MpID0gaWE2NF9nZXRyZWcoX0lBNjRfUkVHX1BTUik7IH0pCisKKyNkZWZpbmUgcmF3
X2lycXNfZGlzYWJsZWQoKQkJCQlcCisoewkJCQkJCVwKKwl1bnNpZ25lZCBsb25nIF9faWE2NF9p
ZF9mbGFnczsJCVwKKwlyYXdfbG9jYWxfc2F2ZV9mbGFncyhfX2lhNjRfaWRfZmxhZ3MpOwlcCisJ
KF9faWE2NF9pZF9mbGFncyAmIElBNjRfUFNSX0kpID09IDA7CVwKK30pCisKKyNkZWZpbmUgcmF3
X3NhZmVfaGFsdCgpICAgICAgICAgaWE2NF9wYWxfaGFsdF9saWdodCgpICAgIC8qIFBBTF9IQUxU
X0xJR0hUICovCisjZGVmaW5lIHJhd19pcnFzX2Rpc2FibGVkX2ZsYWdzKGZsYWdzKQlcCisoewkJ
CQkJCVwKKwkoaW50KSgoZmxhZ3MpICYgSUE2NF9QU1JfSSkgPT0gMDsJXAorfSkKKwkKKyNpZmRl
ZiBDT05GSUdfVFJBQ0VfSVJRRkxBR1MKKyNkZWZpbmUgVFJBQ0VfSVJRU19PTiBici5jYWxsLnNw
dGsubWFueSBiMD10cmFjZV9oYXJkaXJxc19vbgorI2RlZmluZSBUUkFDRV9JUlFTX09GRiBici5j
YWxsLnNwdGsubWFueSBiMD10cmFjZV9oYXJkaXJxc19vZmYKKyNlbHNlCisjZGVmaW5lIFRSQUNF
X0lSUVNfT04KKyNkZWZpbmUgVFJBQ0VfSVJRU19PRkYKKyNlbmRpZgorI2VuZGlmCmRpZmYgLUJy
dU4gbGludXgtMi42LjMxLXJjNi9pbmNsdWRlL2FzbS1pYTY0L3N0YWNrdHJhY2UuaCBsaW51eC0y
LjYuMzEtcmM2LWxvY2tkZXAvaW5jbHVkZS9hc20taWE2NC9zdGFja3RyYWNlLmgKLS0tIGxpbnV4
LTIuNi4zMS1yYzYvaW5jbHVkZS9hc20taWE2NC9zdGFja3RyYWNlLmgJMTk2OS0xMi0zMSAxNjow
MDowMC4wMDAwMDAwMDAgLTA4MDAKKysrIGxpbnV4LTIuNi4zMS1yYzYtbG9ja2RlcC9pbmNsdWRl
L2FzbS1pYTY0L3N0YWNrdHJhY2UuaAkyMDA5LTA4LTIzIDE4OjU5OjE0LjAwMDAwMDAwMCAtMDcw
MApAQCAtMCwwICsxLDcgQEAKKyNpZm5kZWYgX0FTTV9TVEFDS1RSQUNFX0gKKyNkZWZpbmUgX0FT
TV9TVEFDS1RSQUNFX0ggMQorCisvKiBHZW5lcmljIHN0YWNrIHRyYWNlciB3aXRoIGNhbGxiYWNr
cyAqLworCisKKyNlbmRpZgpkaWZmIC1CcnVOIGxpbnV4LTIuNi4zMS1yYzYvaW5jbHVkZS9saW51
eC9sb2NrZGVwLmggbGludXgtMi42LjMxLXJjNi1sb2NrZGVwL2luY2x1ZGUvbGludXgvbG9ja2Rl
cC5oCi0tLSBsaW51eC0yLjYuMzEtcmM2L2luY2x1ZGUvbGludXgvbG9ja2RlcC5oCTIwMDktMDgt
MTMgMTU6NDM6MzQuMDAwMDAwMDAwIC0wNzAwCisrKyBsaW51eC0yLjYuMzEtcmM2LWxvY2tkZXAv
aW5jbHVkZS9saW51eC9sb2NrZGVwLmgJMjAwOS0wOC0yMyAxODo1OToyMC4wMDAwMDAwMDAgLTA3
MDAKQEAgLTE2Miw3ICsxNjIsNyBAQAogCXU2NAkJCQljaGFpbl9rZXk7CiB9OwogCi0jZGVmaW5l
IE1BWF9MT0NLREVQX0tFWVNfQklUUwkJMTMKKyNkZWZpbmUgTUFYX0xPQ0tERVBfS0VZU19CSVRT
CQkxMAogLyoKICAqIFN1YnRyYWN0IG9uZSBiZWNhdXNlIHdlIG9mZnNldCBobG9jay0+Y2xhc3Nf
aWR4IGJ5IDEgaW4gb3JkZXIKICAqIHRvIG1ha2UgMCBtZWFuIG5vIGNsYXNzLiBUaGlzIGF2b2lk
cyBvdmVyZmxvd2luZyB0aGUgY2xhc3NfaWR4CmRpZmYgLUJydU4gbGludXgtMi42LjMxLXJjNi9s
aWIvS2NvbmZpZy5kZWJ1ZyBsaW51eC0yLjYuMzEtcmM2LWxvY2tkZXAvbGliL0tjb25maWcuZGVi
dWcKLS0tIGxpbnV4LTIuNi4zMS1yYzYvbGliL0tjb25maWcuZGVidWcJMjAwOS0wOC0xMyAxNTo0
MzozNC4wMDAwMDAwMDAgLTA3MDAKKysrIGxpbnV4LTIuNi4zMS1yYzYtbG9ja2RlcC9saWIvS2Nv
bmZpZy5kZWJ1ZwkyMDA5LTA4LTIzIDE4OjU5OjA2LjAwMDAwMDAwMCAtMDcwMApAQCAtNTA0LDcg
KzUwNCw3IEBACiAKIGNvbmZpZyBERUJVR19MT0NLREVQCiAJYm9vbCAiTG9jayBkZXBlbmRlbmN5
IGVuZ2luZSBkZWJ1Z2dpbmciCi0JZGVwZW5kcyBvbiBERUJVR19LRVJORUwgJiYgTE9DS0RFUAor
CWRlcGVuZHMgb24gREVCVUdfS0VSTkVMICYmIExPQ0tERVAgJiYgIUlBNjQKIAloZWxwCiAJICBJ
ZiB5b3Ugc2F5IFkgaGVyZSwgdGhlIGxvY2sgZGVwZW5kZW5jeSBlbmdpbmUgd2lsbCBkbwogCSAg
YWRkaXRpb25hbCBydW50aW1lIGNoZWNrcyB0byBkZWJ1ZyBpdHNlbGYsIGF0IHRoZSBwcmljZQo=
--00504502c14d8e437e04722b22ef--
