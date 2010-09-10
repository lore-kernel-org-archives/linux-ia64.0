From: David Howells <dhowells@redhat.com>
Date: Fri, 10 Sep 2010 16:25:09 +0000
Subject: [PATCH 12/17] Fix IA64 irqflags
Message-Id: <20100910162509.20817.314.stgit@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100910162407.20817.34359.stgit@warthog.procyon.org.uk>
In-Reply-To: <20100910162407.20817.34359.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arch@vger.kernel.org
Cc: torvalds@osdl.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

This (sub)patch is separated out for reviewing purposes.  Once ACK'd it will
need to be rolled into the main patch.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---

 arch/ia64/include/asm/irqflags.h |   94 ++++++++++++++++++++++++++++++++++++++
 arch/ia64/include/asm/system.h   |   76 -------------------------------
 2 files changed, 94 insertions(+), 76 deletions(-)
 create mode 100644 arch/ia64/include/asm/irqflags.h

diff --git a/arch/ia64/include/asm/irqflags.h b/arch/ia64/include/asm/irqflags.h
new file mode 100644
index 0000000..f82d6be
--- /dev/null
+++ b/arch/ia64/include/asm/irqflags.h
@@ -0,0 +1,94 @@
+/*
+ * IRQ flags defines.
+ *
+ * Copyright (C) 1998-2003 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999 Asit Mallick <asit.k.mallick@intel.com>
+ * Copyright (C) 1999 Don Dugger <don.dugger@intel.com>
+ */
+
+#ifndef _ASM_IA64_IRQFLAGS_H
+#define _ASM_IA64_IRQFLAGS_H
+
+#ifdef CONFIG_IA64_DEBUG_IRQ
+extern unsigned long last_cli_ip;
+static inline void arch_maybe_save_ip(unsigned long flags)
+{
+	if (flags & IA64_PSR_I)
+		last_cli_ip = ia64_getreg(_IA64_REG_IP);
+}
+#else
+#define arch_maybe_save_ip(flags) do {} while (0)
+#endif
+
+/*
+ * - clearing psr.i is implicitly serialized (visible by next insn)
+ * - setting psr.i requires data serialization
+ * - we need a stop-bit before reading PSR because we sometimes
+ *   write a floating-point register right before reading the PSR
+ *   and that writes to PSR.mfl
+ */
+
+static inline unsigned long arch_local_save_flags(void)
+{
+	ia64_stop();
+#ifdef CONFIG_PARAVIRT
+	return ia64_get_psr_i();
+#else
+	return ia64_getreg(_IA64_REG_PSR);
+#endif
+}
+
+static inline unsigned long arch_local_irq_save(void)
+{
+	unsigned long flags = arch_local_save_flags();
+
+	ia64_stop();
+	ia64_rsm(IA64_PSR_I);
+	arch_maybe_save_ip(flags);
+	return flags;
+}
+
+static inline void arch_local_irq_disable(void)
+{
+#ifdef CONFIG_IA64_DEBUG_IRQ
+	arch_local_irq_save();
+#else
+	ia64_stop();
+	ia64_rsm(IA64_PSR_I);
+#endif
+}
+
+static inline void arch_local_irq_enable(void)
+{
+	ia64_stop();
+	ia64_ssm(IA64_PSR_I);
+	ia64_srlz_d();
+}
+
+static inline void arch_local_irq_restore(unsigned long flags)
+{
+#ifdef CONFIG_IA64_DEBUG_IRQ
+	unsigned long old_psr = arch_local_save_flags();
+#endif
+	ia64_intrin_local_irq_restore(flags & IA64_PSR_I);
+	arch_maybe_save_ip(old_psr & ~flags);
+}
+
+static inline bool arch_irqs_disabled_flags(unsigned long flags)
+{
+	return (flags & IA64_PSR_I) = 0;
+}
+
+static inline bool arch_irqs_disabled(void)
+{
+	return arch_irqs_disabled_flags(arch_local_save_flags());
+}
+
+static inline void arch_safe_halt(void)
+{
+	ia64_pal_halt_light();	/* PAL_HALT_LIGHT */
+}
+
+
+#endif /* _ASM_IA64_IRQFLAGS_H */
diff --git a/arch/ia64/include/asm/system.h b/arch/ia64/include/asm/system.h
index 9f342a5..2feb7f6 100644
--- a/arch/ia64/include/asm/system.h
+++ b/arch/ia64/include/asm/system.h
@@ -107,87 +107,11 @@ extern struct ia64_boot_param {
  */
 #define set_mb(var, value)	do { (var) = (value); mb(); } while (0)
 
-#define safe_halt()         ia64_pal_halt_light()    /* PAL_HALT_LIGHT */
-
 /*
  * The group barrier in front of the rsm & ssm are necessary to ensure
  * that none of the previous instructions in the same group are
  * affected by the rsm/ssm.
  */
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
-# define local_irq_disable()	do { unsigned long __x; local_irq_save(__x); } while (0)
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
-#define local_irq_enable()	({ ia64_stop(); ia64_ssm(IA64_PSR_I); ia64_srlz_d(); })
-#define local_save_flags(flags)	({ ia64_stop(); (flags) = __local_save_flags(); })
-
-#define irqs_disabled()				\
-({						\
-	unsigned long __ia64_id_flags;		\
-	local_save_flags(__ia64_id_flags);	\
-	(__ia64_id_flags & IA64_PSR_I) = 0;	\
-})
 
 #ifdef __KERNEL__
 

