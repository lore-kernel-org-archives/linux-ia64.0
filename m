From: David Howells <dhowells@redhat.com>
Date: Fri, 10 Sep 2010 16:25:04 +0000
Subject: [PATCH 11/17] Fix IRQ flag handling naming
Message-Id: <20100910162504.20817.44955.stgit@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100910162407.20817.34359.stgit@warthog.procyon.org.uk>
In-Reply-To: <20100910162407.20817.34359.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arch@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Chen Liqin <liqin.chen@sunplusct.com>, paulus@samba.org, Greg Ungerer <gerg@uclinux.org>, Lennox Wu <lennox.wu@gmail.com>, jesper.nilsson@axis.com, Hirokazu Takata <takata@linux-m32r.org>, Haavard Skinnemoen <haavard.skinnemoen@atmel.com>, Fenghua Yu <fenghua.yu@intel.com>, Chris Metcalf <cmetcalf@tilera.com>, starvik@axis.com, torvalds@osdl.org, Thomas Gleixner <tglx@linutronix.de>, Chris Zankel <chris@zankel.net>, Michal Simek <monstr@monstr.eu>, Tony Luck <tony.luck@intel.com>, linux-cris-kernel@axis.com, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, Paul Mundt <lethal@linux-sh.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

Fix the IRQ flag handling naming.  In linux/irqflags.h under one configuration,
it maps:

	local_irq_enable() -> raw_local_irq_enable()
	local_irq_disable() -> raw_local_irq_disable()
	local_irq_save() -> raw_local_irq_save()
	...

and under the other configuration, it maps:

	raw_local_irq_enable() -> local_irq_enable()
	raw_local_irq_disable() -> local_irq_disable()
	raw_local_irq_save() -> local_irq_save()
	...

This is quite confusing.  There should be one set of names expected of the
arch, and this should be wrapped to give another set of names that are expected
by users of this facility.

Change this to have the arch provide:

	flags = arch_local_save_flags()
	flags = arch_local_irq_save()
	arch_local_irq_restore(flags)
	arch_local_irq_disable()
	arch_local_irq_enable()
	arch_irqs_disabled_flags(flags)
	arch_irqs_disabled()
	arch_safe_halt()

Then linux/irqflags.h wraps these to provide:

	raw_local_save_flags(flags)
	raw_local_irq_save(flags)
	raw_local_irq_restore(flags)
	raw_local_irq_disable()
	raw_local_irq_enable()
	raw_irqs_disabled_flags(flags)
	raw_irqs_disabled()
	raw_safe_halt()

with type checking on the flags 'arguments', and then wraps those to provide:

	local_save_flags(flags)
	local_irq_save(flags)
	local_irq_restore(flags)
	local_irq_disable()
	local_irq_enable()
	irqs_disabled_flags(flags)
	irqs_disabled()
	safe_halt()

with tracing included if enabled.

The arch functions can now all be inline functions rather than some of them
having to be macros.

[Note that this patch only alters X86, FRV, MN10300, ARM and Blackfin at the
 moment.  The other arches will need altering too as part of this patch].

Signed-off-by: David Howells <dhowells@redhat.com>
Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
Signed-off-by: Michal Simek <monstr@monstr.eu>
Tested-by: Catalin Marinas <catalin.marinas@arm.com>
Acked-by: Thomas Gleixner <tglx@linutronix.de>
Acked-by: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Acked-by: Hirokazu Takata <takata@linux-m32r.org>
Acked-by: Greg Ungerer <gerg@uclinux.org>
Acked-by: Ralf Baechle <ralf@linux-mips.org>
Acked-by: Kyle McMartin <kyle@mcmartin.ca>
Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Acked-by: David S. Miller <davem@davemloft.net>
Reviewed-by: Richard Henderson <rth@twiddle.net>
Reviewed-by: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Cc: starvik@axis.com
Cc: jesper.nilsson@axis.com
Cc: linux-cris-kernel@axis.com
Cc: benh@kernel.crashing.org
Cc: paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: Paul Mundt <lethal@linux-sh.org>
Cc: linux-sh@vger.kernel.org
Cc: Chris Zankel <chris@zankel.net>
Cc: Chen Liqin <liqin.chen@sunplusct.com>
Cc: Lennox Wu <lennox.wu@gmail.com>
---

 arch/alpha/include/asm/irqflags.h       |   65 ++++++++++
 arch/alpha/include/asm/system.h         |   28 ----
 arch/arm/include/asm/irqflags.h         |  145 +++++++++++++----------
 arch/avr32/include/asm/irqflags.h       |   29 ++---
 arch/blackfin/include/asm/irqflags.h    |   12 --
 arch/blackfin/kernel/trace.c            |    1 
 arch/frv/include/asm/irqflags.h         |  158 +++++++++++++++++++++++++
 arch/frv/include/asm/system.h           |  136 ----------------------
 arch/h8300/include/asm/irqflags.h       |   43 +++++++
 arch/h8300/include/asm/system.h         |   24 ----
 arch/m32r/include/asm/irqflags.h        |  104 +++++++++++++++++
 arch/m32r/include/asm/system.h          |   66 -----------
 arch/m68k/include/asm/entry_no.h        |    2 
 arch/m68k/include/asm/irqflags.h        |   76 ++++++++++++
 arch/m68k/include/asm/system_mm.h       |   25 ----
 arch/m68k/include/asm/system_no.h       |   57 ---------
 arch/m68knommu/kernel/asm-offsets.c     |    2 
 arch/m68knommu/platform/coldfire/head.S |    1 
 arch/microblaze/include/asm/irqflags.h  |  193 ++++++++++++++++---------------
 arch/mips/include/asm/irqflags.h        |   53 +++++----
 arch/mips/kernel/smtc.c                 |    4 -
 arch/mn10300/include/asm/irqflags.h     |  119 +++++++++++++++++++
 arch/mn10300/include/asm/system.h       |  109 ------------------
 arch/mn10300/kernel/entry.S             |    1 
 arch/parisc/include/asm/irqflags.h      |   46 +++++++
 arch/parisc/include/asm/system.h        |   19 ---
 arch/s390/include/asm/irqflags.h        |   51 ++++----
 arch/s390/include/asm/system.h          |    2 
 arch/s390/kernel/mem_detect.c           |    4 -
 arch/s390/mm/init.c                     |    2 
 arch/s390/mm/maccess.c                  |    4 -
 arch/sparc/include/asm/irqflags_32.h    |   35 +++---
 arch/sparc/include/asm/irqflags_64.h    |   29 +----
 arch/sparc/kernel/irq_32.c              |   13 +-
 arch/sparc/prom/p1275.c                 |    2 
 arch/tile/include/asm/irqflags.h        |   36 +++---
 arch/x86/include/asm/irqflags.h         |   32 ++---
 arch/x86/include/asm/paravirt.h         |   16 +--
 drivers/s390/char/sclp.c                |    2 
 include/asm-generic/atomic.h            |    5 -
 include/asm-generic/cmpxchg-local.h     |    1 
 include/asm-generic/hardirq.h           |    1 
 include/asm-generic/irqflags.h          |   52 ++++----
 include/linux/irqflags.h                |  107 ++++++++++-------
 include/linux/spinlock.h                |    1 
 45 files changed, 1052 insertions(+), 861 deletions(-)
 create mode 100644 arch/alpha/include/asm/irqflags.h
 create mode 100644 arch/frv/include/asm/irqflags.h
 create mode 100644 arch/h8300/include/asm/irqflags.h
 create mode 100644 arch/m32r/include/asm/irqflags.h
 create mode 100644 arch/m68k/include/asm/irqflags.h
 create mode 100644 arch/mn10300/include/asm/irqflags.h
 create mode 100644 arch/parisc/include/asm/irqflags.h

diff --git a/arch/alpha/include/asm/irqflags.h b/arch/alpha/include/asm/irqflags.h
new file mode 100644
index 0000000..75dfe395
--- /dev/null
+++ b/arch/alpha/include/asm/irqflags.h
@@ -0,0 +1,65 @@
+#ifndef __ALPHA_IRQFLAGS_H
+#define __ALPHA_IRQFLAGS_H
+
+#define IPL_MIN		0
+#define IPL_SW0		1
+#define IPL_SW1		2
+#define IPL_DEV0	3
+#define IPL_DEV1	4
+#define IPL_TIMER	5
+#define IPL_PERF	6
+#define IPL_POWERFAIL	6
+#define IPL_MCHECK	7
+#define IPL_MAX		7
+
+#ifdef CONFIG_ALPHA_BROKEN_IRQ_MASK
+#undef IPL_MIN
+#define IPL_MIN		__min_ipl
+extern int __min_ipl;
+#endif
+
+#define getipl()		(rdps() & 7)
+#define setipl(ipl)		((void) swpipl(ipl))
+
+static inline unsigned long arch_local_save_flags(void)
+{
+	return rdps();
+}
+
+static inline void arch_local_irq_disable(void)
+{
+	setipl(IPL_MAX);
+	barrier();
+}
+
+static inline unsigned long arch_local_irq_save(void)
+{
+	unsigned long flags = swpipl(IPL_MAX);
+	barrier();
+	return flags;
+}
+
+static inline void arch_local_irq_enable(void)
+{
+	barrier();
+	setipl(IPL_MIN);
+}
+
+static inline void arch_local_irq_restore(unsigned long flags)
+{
+	barrier();
+	setipl(flags);
+	barrier();
+}
+
+static inline bool arch_irqs_disabled_flags(unsigned long flags)
+{
+	return flags = IPL_MAX;
+}
+
+static inline bool arch_irqs_disabled(void)
+{
+	return arch_irqs_disabled_flags(getipl());
+}
+
+#endif /* __ALPHA_IRQFLAGS_H */
diff --git a/arch/alpha/include/asm/system.h b/arch/alpha/include/asm/system.h
index 5aa40cc..9f78e69 100644
--- a/arch/alpha/include/asm/system.h
+++ b/arch/alpha/include/asm/system.h
@@ -259,34 +259,6 @@ __CALL_PAL_RW2(wrperfmon, unsigned long, unsigned long, unsigned long);
 __CALL_PAL_W1(wrusp, unsigned long);
 __CALL_PAL_W1(wrvptptr, unsigned long);
 
-#define IPL_MIN		0
-#define IPL_SW0		1
-#define IPL_SW1		2
-#define IPL_DEV0	3
-#define IPL_DEV1	4
-#define IPL_TIMER	5
-#define IPL_PERF	6
-#define IPL_POWERFAIL	6
-#define IPL_MCHECK	7
-#define IPL_MAX		7
-
-#ifdef CONFIG_ALPHA_BROKEN_IRQ_MASK
-#undef IPL_MIN
-#define IPL_MIN		__min_ipl
-extern int __min_ipl;
-#endif
-
-#define getipl()		(rdps() & 7)
-#define setipl(ipl)		((void) swpipl(ipl))
-
-#define local_irq_disable()			do { setipl(IPL_MAX); barrier(); } while(0)
-#define local_irq_enable()			do { barrier(); setipl(IPL_MIN); } while(0)
-#define local_save_flags(flags)	((flags) = rdps())
-#define local_irq_save(flags)	do { (flags) = swpipl(IPL_MAX); barrier(); } while(0)
-#define local_irq_restore(flags)	do { barrier(); setipl(flags); barrier(); } while(0)
-
-#define irqs_disabled()	(getipl() = IPL_MAX)
-
 /*
  * TB routines..
  */
diff --git a/arch/arm/include/asm/irqflags.h b/arch/arm/include/asm/irqflags.h
index 6d09974..1e6cca5 100644
--- a/arch/arm/include/asm/irqflags.h
+++ b/arch/arm/include/asm/irqflags.h
@@ -10,66 +10,85 @@
  */
 #if __LINUX_ARM_ARCH__ >= 6
 
-#define raw_local_irq_save(x)					\
-	({							\
-	__asm__ __volatile__(					\
-	"mrs	%0, cpsr		@ local_irq_save\n"	\
-	"cpsid	i"						\
-	: "=r" (x) : : "memory", "cc");				\
-	})
+static inline unsigned long arch_local_irq_save(void)
+{
+	unsigned long flags;
+
+	asm volatile(
+		"	mrs	%0, cpsr	@ arch_local_irq_save\n"
+		"	cpsid	i"
+		: "=r" (flags) : : "memory", "cc");
+	return flags;
+}
+
+static inline void arch_local_irq_enable(void)
+{
+	asm volatile(
+		"	cpsie i			@ arch_local_irq_enable"
+		:
+		:
+		: "memory", "cc");
+}
+
+static inline void arch_local_irq_disable(void)
+{
+	asm volatile(
+		"	cpsid i			@ arch_local_irq_disable"
+		:
+		:
+		: "memory", "cc");
+}
 
-#define raw_local_irq_enable()  __asm__("cpsie i	@ __sti" : : : "memory", "cc")
-#define raw_local_irq_disable() __asm__("cpsid i	@ __cli" : : : "memory", "cc")
 #define local_fiq_enable()  __asm__("cpsie f	@ __stf" : : : "memory", "cc")
 #define local_fiq_disable() __asm__("cpsid f	@ __clf" : : : "memory", "cc")
-
 #else
 
 /*
  * Save the current interrupt enable state & disable IRQs
  */
-#define raw_local_irq_save(x)					\
-	({							\
-		unsigned long temp;				\
-		(void) (&temp = &x);				\
-	__asm__ __volatile__(					\
-	"mrs	%0, cpsr		@ local_irq_save\n"	\
-"	orr	%1, %0, #128\n"					\
-"	msr	cpsr_c, %1"					\
-	: "=r" (x), "=r" (temp)					\
-	:							\
-	: "memory", "cc");					\
-	})
-	
+static inline unsigned long arch_local_irq_save(void)
+{
+	unsigned long flags, temp;
+
+	asm volatile(
+		"	mrs	%0, cpsr	@ arch_local_irq_save\n"
+		"	orr	%1, %0, #128\n"
+		"	msr	cpsr_c, %1"
+		: "=r" (flags), "=r" (temp)
+		:
+		: "memory", "cc");
+	return flags;
+}
+
 /*
  * Enable IRQs
  */
-#define raw_local_irq_enable()					\
-	({							\
-		unsigned long temp;				\
-	__asm__ __volatile__(					\
-	"mrs	%0, cpsr		@ local_irq_enable\n"	\
-"	bic	%0, %0, #128\n"					\
-"	msr	cpsr_c, %0"					\
-	: "=r" (temp)						\
-	:							\
-	: "memory", "cc");					\
-	})
+static inline void arch_local_irq_enable(void)
+{
+	unsigned long temp;
+	asm volatile(
+		"	mrs	%0, cpsr	@ arch_local_irq_enable\n"
+		"	bic	%0, %0, #128\n"
+		"	msr	cpsr_c, %0"
+		: "=r" (temp)
+		:
+		: "memory", "cc");
+}
 
 /*
  * Disable IRQs
  */
-#define raw_local_irq_disable()					\
-	({							\
-		unsigned long temp;				\
-	__asm__ __volatile__(					\
-	"mrs	%0, cpsr		@ local_irq_disable\n"	\
-"	orr	%0, %0, #128\n"					\
-"	msr	cpsr_c, %0"					\
-	: "=r" (temp)						\
-	:							\
-	: "memory", "cc");					\
-	})
+static inline void arch_local_irq_disable(void)
+{
+	unsigned long temp;
+	asm volatile(
+		"	mrs	%0, cpsr	@ arch_local_irq_disable\n"
+		"	orr	%0, %0, #128\n"
+		"	msr	cpsr_c, %0"
+		: "=r" (temp)
+		:
+		: "memory", "cc");
+}
 
 /*
  * Enable FIQs
@@ -106,27 +125,31 @@
 /*
  * Save the current interrupt enable state.
  */
-#define raw_local_save_flags(x)					\
-	({							\
-	__asm__ __volatile__(					\
-	"mrs	%0, cpsr		@ local_save_flags"	\
-	: "=r" (x) : : "memory", "cc");				\
-	})
+static inline unsigned long arch_local_save_flags(void)
+{
+	unsigned long flags;
+	asm volatile(
+		"	mrs	%0, cpsr	@ local_save_flags"
+		: "=r" (flags) : : "memory", "cc");
+	return flags;
+}
 
 /*
  * restore saved IRQ & FIQ state
  */
-#define raw_local_irq_restore(x)				\
-	__asm__ __volatile__(					\
-	"msr	cpsr_c, %0		@ local_irq_restore\n"	\
-	:							\
-	: "r" (x)						\
-	: "memory", "cc")
+static inline void arch_local_irq_restore(unsigned long flags)
+{
+	asm volatile(
+		"	msr	cpsr_c, %0	@ local_irq_restore"
+		:
+		: "r" (flags)
+		: "memory", "cc");
+}
 
-#define raw_irqs_disabled_flags(flags)	\
-({					\
-	(int)((flags) & PSR_I_BIT);	\
-})
+static inline int arch_irqs_disabled_flags(unsigned long flags)
+{
+	return flags & PSR_I_BIT;
+}
 
 #endif
 #endif
diff --git a/arch/avr32/include/asm/irqflags.h b/arch/avr32/include/asm/irqflags.h
index 93570da..006e948 100644
--- a/arch/avr32/include/asm/irqflags.h
+++ b/arch/avr32/include/asm/irqflags.h
@@ -8,16 +8,14 @@
 #ifndef __ASM_AVR32_IRQFLAGS_H
 #define __ASM_AVR32_IRQFLAGS_H
 
+#include <linux/types.h>
 #include <asm/sysreg.h>
 
-static inline unsigned long __raw_local_save_flags(void)
+static inline unsigned long arch_local_save_flags(void)
 {
 	return sysreg_read(SR);
 }
 
-#define raw_local_save_flags(x)					\
-	do { (x) = __raw_local_save_flags(); } while (0)
-
 /*
  * This will restore ALL status register flags, not only the interrupt
  * mask flag.
@@ -25,44 +23,39 @@ static inline unsigned long __raw_local_save_flags(void)
  * The empty asm statement informs the compiler of this fact while
  * also serving as a barrier.
  */
-static inline void raw_local_irq_restore(unsigned long flags)
+static inline void arch_local_irq_restore(unsigned long flags)
 {
 	sysreg_write(SR, flags);
 	asm volatile("" : : : "memory", "cc");
 }
 
-static inline void raw_local_irq_disable(void)
+static inline void arch_local_irq_disable(void)
 {
 	asm volatile("ssrf %0" : : "n"(SYSREG_GM_OFFSET) : "memory");
 }
 
-static inline void raw_local_irq_enable(void)
+static inline void arch_local_irq_enable(void)
 {
 	asm volatile("csrf %0" : : "n"(SYSREG_GM_OFFSET) : "memory");
 }
 
-static inline int raw_irqs_disabled_flags(unsigned long flags)
+static inline bool arch_irqs_disabled_flags(unsigned long flags)
 {
 	return (flags & SYSREG_BIT(GM)) != 0;
 }
 
-static inline int raw_irqs_disabled(void)
+static inline bool arch_irqs_disabled(void)
 {
-	unsigned long flags = __raw_local_save_flags();
-
-	return raw_irqs_disabled_flags(flags);
+	return arch_irqs_disabled_flags(arch_local_save_flags());
 }
 
-static inline unsigned long __raw_local_irq_save(void)
+static inline unsigned long arch_local_irq_save(void)
 {
-	unsigned long flags = __raw_local_save_flags();
+	unsigned long flags = arch_local_save_flags();
 
-	raw_local_irq_disable();
+	arch_local_irq_disable();
 
 	return flags;
 }
 
-#define raw_local_irq_save(flags)				\
-	do { (flags) = __raw_local_irq_save(); } while (0)
-
 #endif /* __ASM_AVR32_IRQFLAGS_H */
diff --git a/arch/blackfin/include/asm/irqflags.h b/arch/blackfin/include/asm/irqflags.h
index 994d767..41c4d70 100644
--- a/arch/blackfin/include/asm/irqflags.h
+++ b/arch/blackfin/include/asm/irqflags.h
@@ -218,16 +218,4 @@ static inline void hard_local_irq_restore(unsigned long flags)
 
 
 #endif /* !CONFIG_IPIPE */
-
-/*
- * Raw interface to linux/irqflags.h.
- */
-#define raw_local_save_flags(flags)	do { (flags) = arch_local_save_flags(); } while (0)
-#define raw_local_irq_save(flags)	do { (flags) = arch_local_irq_save(); } while (0)
-#define raw_local_irq_restore(flags)	arch_local_irq_restore(flags)
-#define raw_local_irq_enable()		arch_local_irq_enable()
-#define raw_local_irq_disable()		arch_local_irq_disable()
-#define raw_irqs_disabled_flags(flags)	arch_irqs_disabled_flags(flags)
-#define raw_irqs_disabled()		arch_irqs_disabled()
-
 #endif
diff --git a/arch/blackfin/kernel/trace.c b/arch/blackfin/kernel/trace.c
index 59fcdf6..05b5508 100644
--- a/arch/blackfin/kernel/trace.c
+++ b/arch/blackfin/kernel/trace.c
@@ -15,6 +15,7 @@
 #include <linux/kallsyms.h>
 #include <linux/err.h>
 #include <linux/fs.h>
+#include <linux/irq.h>
 #include <asm/dma.h>
 #include <asm/trace.h>
 #include <asm/fixed_code.h>
diff --git a/arch/frv/include/asm/irqflags.h b/arch/frv/include/asm/irqflags.h
new file mode 100644
index 0000000..82f0b53
--- /dev/null
+++ b/arch/frv/include/asm/irqflags.h
@@ -0,0 +1,158 @@
+/* FR-V interrupt handling
+ *
+ * Copyright (C) 2010 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+#ifndef _ASM_IRQFLAGS_H
+#define _ASM_IRQFLAGS_H
+
+/*
+ * interrupt flag manipulation
+ * - use virtual interrupt management since touching the PSR is slow
+ *   - ICC2.Z: T if interrupts virtually disabled
+ *   - ICC2.C: F if interrupts really disabled
+ * - if Z=1 upon interrupt:
+ *   - C is set to 0
+ *   - interrupts are really disabled
+ *   - entry.S returns immediately
+ * - uses TIHI (TRAP if Z=0 && C=0) #2 to really reenable interrupts
+ *   - if taken, the trap:
+ *     - sets ICC2.C
+ *     - enables interrupts
+ */
+static inline void arch_local_irq_disable(void)
+{
+	/* set Z flag, but don't change the C flag */
+	asm volatile("	andcc	gr0,gr0,gr0,icc2	\n"
+		     :
+		     :
+		     : "memory", "icc2"
+		     );
+}
+
+static inline void arch_local_irq_enable(void)
+{
+	/* clear Z flag and then test the C flag */
+	asm volatile("  oricc	gr0,#1,gr0,icc2		\n"
+		     "	tihi	icc2,gr0,#2		\n"
+		     :
+		     :
+		     : "memory", "icc2"
+		     );
+}
+
+static inline unsigned long arch_local_save_flags(void)
+{
+	unsigned long flags;
+
+	asm volatile("movsg ccr,%0"
+		     : "=r"(flags)
+		     :
+		     : "memory");
+
+	/* shift ICC2.Z to bit 0 */
+	flags >>= 26;
+
+	/* make flags 1 if interrupts disabled, 0 otherwise */
+	return flags & 1UL;
+
+}
+
+static inline unsigned long arch_local_irq_save(void)
+{
+	unsigned long flags = arch_local_save_flags();
+	arch_local_irq_disable();
+	return flags;
+}
+
+static inline void arch_local_irq_restore(unsigned long flags)
+{
+	/* load the Z flag by turning 1 if disabled into 0 if disabled
+	 * and thus setting the Z flag but not the C flag */
+	asm volatile("  xoricc	%0,#1,gr0,icc2		\n"
+		     /* then trap if Z=0 and C=0 */
+		     "	tihi	icc2,gr0,#2		\n"
+		     :
+		     : "r"(flags)
+		     : "memory", "icc2"
+		     );
+
+}
+
+static inline bool arch_irqs_disabled_flags(unsigned long flags)
+{
+	return flags;
+}
+
+static inline bool arch_irqs_disabled(void)
+{
+	return arch_irqs_disabled_flags(arch_local_save_flags());
+}
+
+/*
+ * real interrupt flag manipulation
+ */
+#define __arch_local_irq_disable()			\
+do {							\
+	unsigned long psr;				\
+	asm volatile("	movsg	psr,%0		\n"	\
+		     "	andi	%0,%2,%0	\n"	\
+		     "	ori	%0,%1,%0	\n"	\
+		     "	movgs	%0,psr		\n"	\
+		     : "=r"(psr)			\
+		     : "i" (PSR_PIL_14), "i" (~PSR_PIL)	\
+		     : "memory");			\
+} while (0)
+
+#define __arch_local_irq_enable()			\
+do {							\
+	unsigned long psr;				\
+	asm volatile("	movsg	psr,%0		\n"	\
+		     "	andi	%0,%1,%0	\n"	\
+		     "	movgs	%0,psr		\n"	\
+		     : "=r"(psr)			\
+		     : "i" (~PSR_PIL)			\
+		     : "memory");			\
+} while (0)
+
+#define __arch_local_save_flags(flags)		\
+do {						\
+	typecheck(unsigned long, flags);	\
+	asm("movsg psr,%0"			\
+	    : "=r"(flags)			\
+	    :					\
+	    : "memory");			\
+} while (0)
+
+#define	__arch_local_irq_save(flags)			\
+do {							\
+	unsigned long npsr;				\
+	typecheck(unsigned long, flags);		\
+	asm volatile("	movsg	psr,%0		\n"	\
+		     "	andi	%0,%3,%1	\n"	\
+		     "	ori	%1,%2,%1	\n"	\
+		     "	movgs	%1,psr		\n"	\
+		     : "=r"(flags), "=r"(npsr)		\
+		     : "i" (PSR_PIL_14), "i" (~PSR_PIL)	\
+		     : "memory");			\
+} while (0)
+
+#define	__arch_local_irq_restore(flags)			\
+do {							\
+	typecheck(unsigned long, flags);		\
+	asm volatile("	movgs	%0,psr		\n"	\
+		     :					\
+		     : "r" (flags)			\
+		     : "memory");			\
+} while (0)
+
+#define __arch_irqs_disabled()			\
+	((__get_PSR() & PSR_PIL) >= PSR_PIL_14)
+
+#endif /* _ASM_IRQFLAGS_H */
diff --git a/arch/frv/include/asm/system.h b/arch/frv/include/asm/system.h
index efd22d9..0a6d8d9 100644
--- a/arch/frv/include/asm/system.h
+++ b/arch/frv/include/asm/system.h
@@ -37,142 +37,6 @@ do {									\
 } while(0)
 
 /*
- * interrupt flag manipulation
- * - use virtual interrupt management since touching the PSR is slow
- *   - ICC2.Z: T if interrupts virtually disabled
- *   - ICC2.C: F if interrupts really disabled
- * - if Z=1 upon interrupt:
- *   - C is set to 0
- *   - interrupts are really disabled
- *   - entry.S returns immediately
- * - uses TIHI (TRAP if Z=0 && C=0) #2 to really reenable interrupts
- *   - if taken, the trap:
- *     - sets ICC2.C
- *     - enables interrupts
- */
-#define local_irq_disable()					\
-do {								\
-	/* set Z flag, but don't change the C flag */		\
-	asm volatile("	andcc	gr0,gr0,gr0,icc2	\n"	\
-		     :						\
-		     :						\
-		     : "memory", "icc2"				\
-		     );						\
-} while(0)
-
-#define local_irq_enable()					\
-do {								\
-	/* clear Z flag and then test the C flag */		\
-	asm volatile("  oricc	gr0,#1,gr0,icc2		\n"	\
-		     "	tihi	icc2,gr0,#2		\n"	\
-		     :						\
-		     :						\
-		     : "memory", "icc2"				\
-		     );						\
-} while(0)
-
-#define local_save_flags(flags)					\
-do {								\
-	typecheck(unsigned long, flags);			\
-	asm volatile("movsg ccr,%0"				\
-		     : "=r"(flags)				\
-		     :						\
-		     : "memory");				\
-								\
-	/* shift ICC2.Z to bit 0 */				\
-	flags >>= 26;						\
-								\
-	/* make flags 1 if interrupts disabled, 0 otherwise */	\
-	flags &= 1UL;						\
-} while(0)
-
-#define irqs_disabled() \
-	({unsigned long flags; local_save_flags(flags); !!flags; })
-
-#define	local_irq_save(flags)			\
-do {						\
-	typecheck(unsigned long, flags);	\
-	local_save_flags(flags);		\
-	local_irq_disable();			\
-} while(0)
-
-#define	local_irq_restore(flags)					\
-do {									\
-	typecheck(unsigned long, flags);				\
-									\
-	/* load the Z flag by turning 1 if disabled into 0 if disabled	\
-	 * and thus setting the Z flag but not the C flag */		\
-	asm volatile("  xoricc	%0,#1,gr0,icc2		\n"		\
-		     /* then test Z=0 and C=0 */			\
-		     "	tihi	icc2,gr0,#2		\n"		\
-		     :							\
-		     : "r"(flags)					\
-		     : "memory", "icc2"					\
-		     );							\
-									\
-} while(0)
-
-/*
- * real interrupt flag manipulation
- */
-#define __local_irq_disable()				\
-do {							\
-	unsigned long psr;				\
-	asm volatile("	movsg	psr,%0		\n"	\
-		     "	andi	%0,%2,%0	\n"	\
-		     "	ori	%0,%1,%0	\n"	\
-		     "	movgs	%0,psr		\n"	\
-		     : "=r"(psr)			\
-		     : "i" (PSR_PIL_14), "i" (~PSR_PIL)	\
-		     : "memory");			\
-} while(0)
-
-#define __local_irq_enable()				\
-do {							\
-	unsigned long psr;				\
-	asm volatile("	movsg	psr,%0		\n"	\
-		     "	andi	%0,%1,%0	\n"	\
-		     "	movgs	%0,psr		\n"	\
-		     : "=r"(psr)			\
-		     : "i" (~PSR_PIL)			\
-		     : "memory");			\
-} while(0)
-
-#define __local_save_flags(flags)		\
-do {						\
-	typecheck(unsigned long, flags);	\
-	asm("movsg psr,%0"			\
-	    : "=r"(flags)			\
-	    :					\
-	    : "memory");			\
-} while(0)
-
-#define	__local_irq_save(flags)				\
-do {							\
-	unsigned long npsr;				\
-	typecheck(unsigned long, flags);		\
-	asm volatile("	movsg	psr,%0		\n"	\
-		     "	andi	%0,%3,%1	\n"	\
-		     "	ori	%1,%2,%1	\n"	\
-		     "	movgs	%1,psr		\n"	\
-		     : "=r"(flags), "=r"(npsr)		\
-		     : "i" (PSR_PIL_14), "i" (~PSR_PIL)	\
-		     : "memory");			\
-} while(0)
-
-#define	__local_irq_restore(flags)			\
-do {							\
-	typecheck(unsigned long, flags);		\
-	asm volatile("	movgs	%0,psr		\n"	\
-		     :					\
-		     : "r" (flags)			\
-		     : "memory");			\
-} while(0)
-
-#define __irqs_disabled() \
-	((__get_PSR() & PSR_PIL) >= PSR_PIL_14)
-
-/*
  * Force strict CPU ordering.
  */
 #define nop()			asm volatile ("nop"::)
diff --git a/arch/h8300/include/asm/irqflags.h b/arch/h8300/include/asm/irqflags.h
new file mode 100644
index 0000000..9617cd5
--- /dev/null
+++ b/arch/h8300/include/asm/irqflags.h
@@ -0,0 +1,43 @@
+#ifndef _H8300_IRQFLAGS_H
+#define _H8300_IRQFLAGS_H
+
+static inline unsigned long arch_local_save_flags(void)
+{
+	unsigned long flags;
+	asm volatile ("stc ccr,%w0" : "=r" (flags));
+	return flags;
+}
+
+static inline void arch_local_irq_disable(void)
+{
+	asm volatile ("orc  #0x80,ccr" : : : "memory");
+}
+
+static inline void arch_local_irq_enable(void)
+{
+	asm volatile ("andc #0x7f,ccr" : : : "memory");
+}
+
+static inline unsigned long arch_local_irq_save(void)
+{
+	unsigned long flags = arch_local_save_flags();
+	arch_local_irq_disable();
+	return flags;
+}
+
+static inline void arch_local_irq_restore(unsigned long flags)
+{
+	asm volatile ("ldc %w0,ccr" : : "r" (flags) : "memory");
+}
+
+static inline bool arch_irqs_disabled_flags(unsigned long flags)
+{
+	return (flags & 0x80) = 0x80;
+}
+
+static inline bool arch_irqs_disabled(void)
+{
+	return arch_irqs_disabled_flags(arch_local_save_flags());
+}
+
+#endif /* _H8300_IRQFLAGS_H */
diff --git a/arch/h8300/include/asm/system.h b/arch/h8300/include/asm/system.h
index 16bf156..2c2382e 100644
--- a/arch/h8300/include/asm/system.h
+++ b/arch/h8300/include/asm/system.h
@@ -2,6 +2,7 @@
 #define _H8300_SYSTEM_H
 
 #include <linux/linkage.h>
+#include <linux/irqflags.h>
 
 struct pt_regs;
 
@@ -51,31 +52,8 @@ asmlinkage void resume(void);
   (last) = _last; 					    \
 }
 
-#define __sti() asm volatile ("andc #0x7f,ccr")
-#define __cli() asm volatile ("orc  #0x80,ccr")
-
-#define __save_flags(x) \
-       asm volatile ("stc ccr,%w0":"=r" (x))
-
-#define __restore_flags(x) \
-       asm volatile ("ldc %w0,ccr": :"r" (x))
-
-#define	irqs_disabled()			\
-({					\
-	unsigned char flags;		\
-	__save_flags(flags);	        \
-	((flags & 0x80) = 0x80);	\
-})
-
 #define iret() __asm__ __volatile__ ("rte": : :"memory", "sp", "cc")
 
-/* For spinlocks etc */
-#define local_irq_disable()	__cli()
-#define local_irq_enable()      __sti()
-#define local_irq_save(x)	({ __save_flags(x); local_irq_disable(); })
-#define local_irq_restore(x)	__restore_flags(x)
-#define local_save_flags(x)     __save_flags(x)
-
 /*
  * Force strict CPU ordering.
  * Not really required on H8...
diff --git a/arch/m32r/include/asm/irqflags.h b/arch/m32r/include/asm/irqflags.h
new file mode 100644
index 0000000..1f92d29
--- /dev/null
+++ b/arch/m32r/include/asm/irqflags.h
@@ -0,0 +1,104 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 2001  Hiroyuki Kondo, Hirokazu Takata, and Hitoshi Yamamoto
+ * Copyright (C) 2004, 2006  Hirokazu Takata <takata at linux-m32r.org>
+ */
+
+#ifndef _ASM_M32R_IRQFLAGS_H
+#define _ASM_M32R_IRQFLAGS_H
+
+#include <linux/types.h>
+
+static inline unsigned long arch_local_save_flags(void)
+{
+	unsigned long flags;
+	asm volatile("mvfc %0,psw" : "=r"(flags));
+	return flags;
+}
+
+static inline void arch_local_irq_disable(void)
+{
+#if !defined(CONFIG_CHIP_M32102) && !defined(CONFIG_CHIP_M32104)
+	asm volatile (
+		"clrpsw #0x40 -> nop"
+		: : : "memory");
+#else
+	unsigned long tmpreg0, tmpreg1;
+	asm volatile (
+		"ld24	%0, #0	; Use 32-bit insn.			\n\t"
+		"mvfc	%1, psw	; No interrupt can be accepted here.	\n\t"
+		"mvtc	%0, psw						\n\t"
+		"and3	%0, %1, #0xffbf					\n\t"
+		"mvtc	%0, psw						\n\t"
+		: "=&r" (tmpreg0), "=&r" (tmpreg1)
+		:
+		: "cbit", "memory");
+#endif
+}
+
+static inline void arch_local_irq_enable(void)
+{
+#if !defined(CONFIG_CHIP_M32102) && !defined(CONFIG_CHIP_M32104)
+	asm volatile (
+		"setpsw #0x40 -> nop"
+		: : : "memory");
+#else
+	unsigned long tmpreg;
+	asm volatile (
+		"mvfc	%0, psw;		\n\t"
+		"or3	%0, %0, #0x0040;	\n\t"
+		"mvtc	%0, psw;		\n\t"
+		: "=&r" (tmpreg)
+		:
+		: "cbit", "memory");
+#endif
+}
+
+static inline unsigned long arch_local_irq_save(void)
+{
+	unsigned long flags;
+
+#if !(defined(CONFIG_CHIP_M32102) || defined(CONFIG_CHIP_M32104))
+	asm volatile (
+		"mvfc	%0, psw;	\n\t"
+		"clrpsw	#0x40 -> nop;	\n\t"
+		: "=r" (flags)
+		:
+		: "memory");
+#else
+	unsigned long tmpreg;
+	asm volatile (
+		"ld24	%1, #0		\n\t"
+		"mvfc	%0, psw		\n\t"
+		"mvtc	%1, psw		\n\t"
+		"and3	%1, %0, #0xffbf	\n\t"
+		"mvtc	%1, psw		\n\t"
+		: "=r" (flags), "=&r" (tmpreg)
+		:
+		: "cbit", "memory");
+#endif
+	return flags;
+}
+
+static inline void arch_local_irq_restore(unsigned long flags)
+{
+	asm volatile("mvtc %0,psw"
+		     :
+		     : "r" (flags)
+		     : "cbit", "memory");
+}
+
+static inline bool arch_irqs_disabled_flags(unsigned long flags)
+{
+	return !(flags & 0x40);
+}
+
+static inline bool arch_irqs_disabled(void)
+{
+	return arch_irqs_disabled_flags(arch_local_save_flags());
+}
+
+#endif /* _ASM_M32R_IRQFLAGS_H */
diff --git a/arch/m32r/include/asm/system.h b/arch/m32r/include/asm/system.h
index c980f5b..13c4679 100644
--- a/arch/m32r/include/asm/system.h
+++ b/arch/m32r/include/asm/system.h
@@ -11,6 +11,7 @@
  */
 
 #include <linux/compiler.h>
+#include <linux/irqflags.h>
 #include <asm/assembler.h>
 
 #ifdef __KERNEL__
@@ -54,71 +55,6 @@
 	); \
 } while(0)
 
-/* Interrupt Control */
-#if !defined(CONFIG_CHIP_M32102) && !defined(CONFIG_CHIP_M32104)
-#define local_irq_enable() \
-	__asm__ __volatile__ ("setpsw #0x40 -> nop": : :"memory")
-#define local_irq_disable() \
-	__asm__ __volatile__ ("clrpsw #0x40 -> nop": : :"memory")
-#else	/* CONFIG_CHIP_M32102 || CONFIG_CHIP_M32104 */
-static inline void local_irq_enable(void)
-{
-	unsigned long tmpreg;
-	__asm__ __volatile__(
-		"mvfc	%0, psw;		\n\t"
-		"or3	%0, %0, #0x0040;	\n\t"
-		"mvtc	%0, psw;		\n\t"
-	: "=&r" (tmpreg) : : "cbit", "memory");
-}
-
-static inline void local_irq_disable(void)
-{
-	unsigned long tmpreg0, tmpreg1;
-	__asm__ __volatile__(
-		"ld24	%0, #0	; Use 32-bit insn. \n\t"
-		"mvfc	%1, psw	; No interrupt can be accepted here. \n\t"
-		"mvtc	%0, psw	\n\t"
-		"and3	%0, %1, #0xffbf	\n\t"
-		"mvtc	%0, psw	\n\t"
-	: "=&r" (tmpreg0), "=&r" (tmpreg1) : : "cbit", "memory");
-}
-#endif	/* CONFIG_CHIP_M32102 || CONFIG_CHIP_M32104 */
-
-#define local_save_flags(x) \
-	__asm__ __volatile__("mvfc %0,psw" : "=r"(x) : /* no input */)
-
-#define local_irq_restore(x) \
-	__asm__ __volatile__("mvtc %0,psw" : /* no outputs */ \
-		: "r" (x) : "cbit", "memory")
-
-#if !(defined(CONFIG_CHIP_M32102) || defined(CONFIG_CHIP_M32104))
-#define local_irq_save(x)				\
-	__asm__ __volatile__(				\
-  		"mvfc	%0, psw;		\n\t"	\
-	  	"clrpsw	#0x40 -> nop;		\n\t"	\
-  		: "=r" (x) : /* no input */ : "memory")
-#else	/* CONFIG_CHIP_M32102 || CONFIG_CHIP_M32104 */
-#define local_irq_save(x) 				\
-	({						\
-		unsigned long tmpreg;			\
-		__asm__ __volatile__( 			\
-			"ld24	%1, #0 \n\t" 		\
-			"mvfc	%0, psw \n\t"		\
-			"mvtc	%1, psw \n\t"		\
-			"and3	%1, %0, #0xffbf \n\t"	\
-			"mvtc	%1, psw \n\t" 		\
-			: "=r" (x), "=&r" (tmpreg)	\
-			: : "cbit", "memory");		\
-	})
-#endif	/* CONFIG_CHIP_M32102 || CONFIG_CHIP_M32104 */
-
-#define irqs_disabled()					\
-	({						\
-		unsigned long flags;			\
-		local_save_flags(flags);		\
-		!(flags & 0x40);			\
-	})
-
 #define nop()	__asm__ __volatile__ ("nop" : : )
 
 #define xchg(ptr, x)							\
diff --git a/arch/m68k/include/asm/entry_no.h b/arch/m68k/include/asm/entry_no.h
index 907ed03..80e4149 100644
--- a/arch/m68k/include/asm/entry_no.h
+++ b/arch/m68k/include/asm/entry_no.h
@@ -28,7 +28,7 @@
  *			M68K		  COLDFIRE
  */
 
-#define ALLOWINT 0xf8ff
+#define ALLOWINT (~0x700)
 
 #ifdef __ASSEMBLY__
 
diff --git a/arch/m68k/include/asm/irqflags.h b/arch/m68k/include/asm/irqflags.h
new file mode 100644
index 0000000..4db30da
--- /dev/null
+++ b/arch/m68k/include/asm/irqflags.h
@@ -0,0 +1,76 @@
+#ifndef _M68K_IRQFLAGS_H
+#define _M68K_IRQFLAGS_H
+
+#include <linux/types.h>
+#include <linux/hardirq.h>
+#include <linux/preempt.h>
+#include <asm/thread_info.h>
+#include <asm/entry.h>
+
+static inline unsigned long arch_local_save_flags(void)
+{
+	unsigned long flags;
+	asm volatile ("movew %%sr,%0" : "=d" (flags) : : "memory");
+	return flags;
+}
+
+static inline void arch_local_irq_disable(void)
+{
+#ifdef CONFIG_COLDFIRE
+	asm volatile (
+		"move	%/sr,%%d0	\n\t"
+		"ori.l	#0x0700,%%d0	\n\t"
+		"move	%%d0,%/sr	\n"
+		: /* no outputs */
+		:
+		: "cc", "%d0", "memory");
+#else
+	asm volatile ("oriw  #0x0700,%%sr" : : : "memory");
+#endif
+}
+
+static inline void arch_local_irq_enable(void)
+{
+#if defined(CONFIG_COLDFIRE)
+	asm volatile (
+		"move	%/sr,%%d0	\n\t"
+		"andi.l	#0xf8ff,%%d0	\n\t"
+		"move	%%d0,%/sr	\n"
+		: /* no outputs */
+		:
+		: "cc", "%d0", "memory");
+#else
+# if defined(CONFIG_MMU)
+	if (MACH_IS_Q40 || !hardirq_count())
+# endif
+		asm volatile (
+			"andiw %0,%%sr"
+			:
+			: "i" (ALLOWINT)
+			: "memory")
+#endif
+}
+
+static inline unsigned long arch_local_irq_save(void)
+{
+	unsigned long flags = arch_local_save_flags();
+	arch_local_irq_disable();
+	return flags;
+}
+
+static inline void arch_local_irq_restore(unsigned long flags)
+{
+	asm volatile ("movew %0,%%sr" : : "d" (flags) : "memory");
+}
+
+static inline bool arch_irqs_disabled_flags(unsigned long flags)
+{
+	return (flags & ~ALLOWINT) != 0;
+}
+
+static inline bool arch_irqs_disabled(void)
+{
+	return arch_irqs_disabled_flags(arch_local_save_flags());
+}
+
+#endif /* _M68K_IRQFLAGS_H */
diff --git a/arch/m68k/include/asm/system_mm.h b/arch/m68k/include/asm/system_mm.h
index dbb6515..12053c4 100644
--- a/arch/m68k/include/asm/system_mm.h
+++ b/arch/m68k/include/asm/system_mm.h
@@ -3,6 +3,7 @@
 
 #include <linux/linkage.h>
 #include <linux/kernel.h>
+#include <linux/irqflags.h>
 #include <asm/segment.h>
 #include <asm/entry.h>
 
@@ -62,30 +63,6 @@ asmlinkage void resume(void);
 #define smp_wmb()	barrier()
 #define smp_read_barrier_depends()	((void)0)
 
-/* interrupt control.. */
-#if 0
-#define local_irq_enable() asm volatile ("andiw %0,%%sr": : "i" (ALLOWINT) : "memory")
-#else
-#include <linux/hardirq.h>
-#define local_irq_enable() ({							\
-	if (MACH_IS_Q40 || !hardirq_count())					\
-		asm volatile ("andiw %0,%%sr": : "i" (ALLOWINT) : "memory");	\
-})
-#endif
-#define local_irq_disable() asm volatile ("oriw  #0x0700,%%sr": : : "memory")
-#define local_save_flags(x) asm volatile ("movew %%sr,%0":"=d" (x) : : "memory")
-#define local_irq_restore(x) asm volatile ("movew %0,%%sr": :"d" (x) : "memory")
-
-static inline int irqs_disabled(void)
-{
-	unsigned long flags;
-	local_save_flags(flags);
-	return flags & ~ALLOWINT;
-}
-
-/* For spinlocks etc */
-#define local_irq_save(x)	({ local_save_flags(x); local_irq_disable(); })
-
 #define xchg(ptr,x) ((__typeof__(*(ptr)))__xchg((unsigned long)(x),(ptr),sizeof(*(ptr))))
 
 struct __xchg_dummy { unsigned long a[100]; };
diff --git a/arch/m68k/include/asm/system_no.h b/arch/m68k/include/asm/system_no.h
index 3c0718d..20126c0 100644
--- a/arch/m68k/include/asm/system_no.h
+++ b/arch/m68k/include/asm/system_no.h
@@ -2,6 +2,7 @@
 #define _M68KNOMMU_SYSTEM_H
 
 #include <linux/linkage.h>
+#include <linux/irqflags.h>
 #include <asm/segment.h>
 #include <asm/entry.h>
 
@@ -46,54 +47,6 @@ asmlinkage void resume(void);
   (last) = _last;						\
 }
 
-#ifdef CONFIG_COLDFIRE
-#define local_irq_enable() __asm__ __volatile__ (		\
-	"move %/sr,%%d0\n\t"					\
-	"andi.l #0xf8ff,%%d0\n\t"				\
-	"move %%d0,%/sr\n"					\
-	: /* no outputs */					\
-	:							\
-        : "cc", "%d0", "memory")
-#define local_irq_disable() __asm__ __volatile__ (		\
-	"move %/sr,%%d0\n\t"					\
-	"ori.l #0x0700,%%d0\n\t"				\
-	"move %%d0,%/sr\n"					\
-	: /* no outputs */					\
-	:							\
-	: "cc", "%d0", "memory")
-/* For spinlocks etc */
-#define local_irq_save(x) __asm__ __volatile__ (		\
-	"movew %%sr,%0\n\t"					\
-	"movew #0x0700,%%d0\n\t"				\
-	"or.l  %0,%%d0\n\t"					\
-	"movew %%d0,%/sr"					\
-	: "=d" (x)						\
-	:							\
-	: "cc", "%d0", "memory")
-#else
-
-/* portable version */ /* FIXME - see entry.h*/
-#define ALLOWINT 0xf8ff
-
-#define local_irq_enable() asm volatile ("andiw %0,%%sr": : "i" (ALLOWINT) : "memory")
-#define local_irq_disable() asm volatile ("oriw  #0x0700,%%sr": : : "memory")
-#endif
-
-#define local_save_flags(x) asm volatile ("movew %%sr,%0":"=d" (x) : : "memory")
-#define local_irq_restore(x) asm volatile ("movew %0,%%sr": :"d" (x) : "memory")
-
-/* For spinlocks etc */
-#ifndef local_irq_save
-#define local_irq_save(x) do { local_save_flags(x); local_irq_disable(); } while (0)
-#endif
-
-#define	irqs_disabled()			\
-({					\
-	unsigned long flags;		\
-	local_save_flags(flags);	\
-	((flags & 0x0700) = 0x0700);	\
-})
-
 #define iret() __asm__ __volatile__ ("rte": : :"memory", "sp", "cc")
 
 /*
@@ -206,12 +159,4 @@ static inline unsigned long __xchg(unsigned long x, volatile void * ptr, int siz
 #define arch_align_stack(x) (x)
 
 
-static inline int irqs_disabled_flags(unsigned long flags)
-{
-	if (flags & 0x0700)
-		return 0;
-	else
-		return 1;
-}
-
 #endif /* _M68KNOMMU_SYSTEM_H */
diff --git a/arch/m68knommu/kernel/asm-offsets.c b/arch/m68knommu/kernel/asm-offsets.c
index 9a8876f..2433502 100644
--- a/arch/m68knommu/kernel/asm-offsets.c
+++ b/arch/m68knommu/kernel/asm-offsets.c
@@ -74,8 +74,6 @@ int main(void)
 
 	DEFINE(PT_PTRACED, PT_PTRACED);
 
-	DEFINE(THREAD_SIZE, THREAD_SIZE);
-
 	/* Offsets in thread_info structure */
 	DEFINE(TI_TASK, offsetof(struct thread_info, task));
 	DEFINE(TI_EXECDOMAIN, offsetof(struct thread_info, exec_domain));
diff --git a/arch/m68knommu/platform/coldfire/head.S b/arch/m68knommu/platform/coldfire/head.S
index 4b91aa2..0b2d7c7 100644
--- a/arch/m68knommu/platform/coldfire/head.S
+++ b/arch/m68knommu/platform/coldfire/head.S
@@ -15,6 +15,7 @@
 #include <asm/coldfire.h>
 #include <asm/mcfcache.h>
 #include <asm/mcfsim.h>
+#include <asm/thread_info.h>
 
 /*****************************************************************************/
 
diff --git a/arch/microblaze/include/asm/irqflags.h b/arch/microblaze/include/asm/irqflags.h
index 2c38c6d..5fd3190 100644
--- a/arch/microblaze/include/asm/irqflags.h
+++ b/arch/microblaze/include/asm/irqflags.h
@@ -9,103 +9,114 @@
 #ifndef _ASM_MICROBLAZE_IRQFLAGS_H
 #define _ASM_MICROBLAZE_IRQFLAGS_H
 
-#include <linux/irqflags.h>
+#include <linux/types.h>
 #include <asm/registers.h>
 
-# if CONFIG_XILINX_MICROBLAZE0_USE_MSR_INSTR
-
-# define raw_local_irq_save(flags)			\
-	do {						\
-		asm volatile ("	msrclr %0, %1;		\
-				nop;"			\
-				: "=r"(flags)		\
-				: "i"(MSR_IE)		\
-				: "memory");		\
-	} while (0)
-
-# define raw_local_irq_disable()			\
-	do {						\
-		asm volatile ("	msrclr r0, %0;		\
-				nop;"			\
-				:			\
-				: "i"(MSR_IE)		\
-				: "memory");		\
-	} while (0)
-
-# define raw_local_irq_enable()				\
-	do {						\
-		asm volatile ("	msrset	r0, %0;		\
-				nop;"			\
-				:			\
-				: "i"(MSR_IE)		\
-				: "memory");		\
-	} while (0)
-
-# else /* CONFIG_XILINX_MICROBLAZE0_USE_MSR_INSTR = 0 */
-
-# define raw_local_irq_save(flags)				\
-	do {							\
-		register unsigned tmp;				\
-		asm volatile ("	mfs	%0, rmsr;		\
-				nop;				\
-				andi	%1, %0, %2;		\
-				mts	rmsr, %1;		\
-				nop;"				\
-				: "=r"(flags), "=r" (tmp)	\
-				: "i"(~MSR_IE)			\
-				: "memory");			\
-	} while (0)
-
-# define raw_local_irq_disable()				\
-	do {							\
-		register unsigned tmp;				\
-		asm volatile ("	mfs	%0, rmsr;		\
-				nop;				\
-				andi	%0, %0, %1;		\
-				mts	rmsr, %0;		\
-				nop;"			\
-				: "=r"(tmp)			\
-				: "i"(~MSR_IE)			\
-				: "memory");			\
-	} while (0)
-
-# define raw_local_irq_enable()					\
-	do {							\
-		register unsigned tmp;				\
-		asm volatile ("	mfs	%0, rmsr;		\
-				nop;				\
-				ori	%0, %0, %1;		\
-				mts	rmsr, %0;		\
-				nop;"				\
-				: "=r"(tmp)			\
-				: "i"(MSR_IE)			\
-				: "memory");			\
-	} while (0)
-
-# endif /* CONFIG_XILINX_MICROBLAZE0_USE_MSR_INSTR */
-
-#define raw_local_irq_restore(flags)				\
-	do {							\
-		asm volatile ("	mts	rmsr, %0;		\
-				nop;"				\
-				:				\
-				: "r"(flags)			\
-				: "memory");			\
-	} while (0)
-
-static inline unsigned long get_msr(void)
+#ifdef CONFIG_XILINX_MICROBLAZE0_USE_MSR_INSTR
+
+static inline unsigned long arch_local_irq_save(void)
+{
+	unsigned long flags;
+	asm volatile("	msrclr %0, %1	\n"
+		     "	nop		\n"
+		     : "=r"(flags)
+		     : "i"(MSR_IE)
+		     : "memory");
+	return flags;
+}
+
+static inline void arch_local_irq_disable(void)
+{
+	/* this uses r0 without declaring it - is that correct? */
+	asm volatile("	msrclr r0, %0	\n"
+		     "	nop		\n"
+		     :
+		     : "i"(MSR_IE)
+		     : "memory");
+}
+
+static inline void arch_local_irq_enable(void)
+{
+	/* this uses r0 without declaring it - is that correct? */
+	asm volatile("	msrset	r0, %0	\n"
+		     "	nop		\n"
+		     :
+		     : "i"(MSR_IE)
+		     : "memory");
+}
+
+#else /* !CONFIG_XILINX_MICROBLAZE0_USE_MSR_INSTR */
+
+static inline unsigned long arch_local_irq_save(void)
+{
+	unsigned long flags, tmp;
+	asm volatile ("	mfs	%0, rmsr	\n"
+		      "	nop			\n"
+		      "	andi	%1, %0, %2	\n"
+		      "	mts	rmsr, %1	\n"
+		      "	nop			\n"
+		      : "=r"(flags), "=r"(tmp)
+		      : "i"(~MSR_IE)
+		      : "memory");
+	return flags;
+}
+
+static inline void arch_local_irq_disable(void)
+{
+	unsigned long tmp;
+	asm volatile("	mfs	%0, rmsr	\n"
+		     "	nop			\n"
+		     "	andi	%0, %0, %1	\n"
+		     "	mts	rmsr, %0	\n"
+		     "	nop			\n"
+		     : "=r"(tmp)
+		     : "i"(~MSR_IE)
+		     : "memory");
+}
+
+static inline void arch_local_irq_enable(void)
+{
+	unsigned long tmp;
+	asm volatile("	mfs	%0, rmsr	\n"
+		     "	nop			\n"
+		     "	ori	%0, %0, %1	\n"
+		     "	mts	rmsr, %0	\n"
+		     "	nop			\n"
+		     : "=r"(tmp)
+		     : "i"(MSR_IE)
+		     : "memory");
+}
+
+#endif /* CONFIG_XILINX_MICROBLAZE0_USE_MSR_INSTR */
+
+static inline unsigned long arch_local_save_flags(void)
 {
 	unsigned long flags;
-	asm volatile ("	mfs	%0, rmsr;	\
-			nop;"			\
-			: "=r"(flags)		\
-			:			\
-			: "memory");		\
+	asm volatile("	mfs	%0, rmsr	\n"
+		     "	nop			\n"
+		     : "=r"(flags)
+		     :
+		     : "memory");
 	return flags;
 }
 
-#define raw_local_save_flags(flags)	((flags) = get_msr())
-#define raw_irqs_disabled()		((get_msr() & MSR_IE) = 0)
-#define raw_irqs_disabled_flags(flags)	((flags & MSR_IE) = 0)
+static inline void arch_local_irq_restore(unsigned long flags)
+{
+	asm volatile("	mts	rmsr, %0	\n"
+		     "	nop			\n"
+		     :
+		     : "r"(flags)
+		     : "memory");
+}
+
+static inline bool arch_irqs_disabled_flags(unsigned long flags)
+{
+	return (flags & MSR_IE) = 0;
+}
+
+static inline bool arch_irqs_disabled(void)
+{
+	return arch_irqs_disabled_flags(arch_local_save_flags());
+}
 
 #endif /* _ASM_MICROBLAZE_IRQFLAGS_H */
diff --git a/arch/mips/include/asm/irqflags.h b/arch/mips/include/asm/irqflags.h
index 701ec0b..9ef3b0d 100644
--- a/arch/mips/include/asm/irqflags.h
+++ b/arch/mips/include/asm/irqflags.h
@@ -17,7 +17,7 @@
 #include <asm/hazards.h>
 
 __asm__(
-	"	.macro	raw_local_irq_enable				\n"
+	"	.macro	arch_local_irq_enable				\n"
 	"	.set	push						\n"
 	"	.set	reorder						\n"
 	"	.set	noat						\n"
@@ -40,7 +40,7 @@ __asm__(
 
 extern void smtc_ipi_replay(void);
 
-static inline void raw_local_irq_enable(void)
+static inline void arch_local_irq_enable(void)
 {
 #ifdef CONFIG_MIPS_MT_SMTC
 	/*
@@ -50,7 +50,7 @@ static inline void raw_local_irq_enable(void)
 	smtc_ipi_replay();
 #endif
 	__asm__ __volatile__(
-		"raw_local_irq_enable"
+		"arch_local_irq_enable"
 		: /* no outputs */
 		: /* no inputs */
 		: "memory");
@@ -76,7 +76,7 @@ static inline void raw_local_irq_enable(void)
  * Workaround: mask EXL bit of the result or place a nop before mfc0.
  */
 __asm__(
-	"	.macro	raw_local_irq_disable\n"
+	"	.macro	arch_local_irq_disable\n"
 	"	.set	push						\n"
 	"	.set	noat						\n"
 #ifdef CONFIG_MIPS_MT_SMTC
@@ -97,17 +97,17 @@ __asm__(
 	"	.set	pop						\n"
 	"	.endm							\n");
 
-static inline void raw_local_irq_disable(void)
+static inline void arch_local_irq_disable(void)
 {
 	__asm__ __volatile__(
-		"raw_local_irq_disable"
+		"arch_local_irq_disable"
 		: /* no outputs */
 		: /* no inputs */
 		: "memory");
 }
 
 __asm__(
-	"	.macro	raw_local_save_flags flags			\n"
+	"	.macro	arch_local_save_flags flags			\n"
 	"	.set	push						\n"
 	"	.set	reorder						\n"
 #ifdef CONFIG_MIPS_MT_SMTC
@@ -118,13 +118,15 @@ __asm__(
 	"	.set	pop						\n"
 	"	.endm							\n");
 
-#define raw_local_save_flags(x)						\
-__asm__ __volatile__(							\
-	"raw_local_save_flags %0"					\
-	: "=r" (x))
+static inline unsigned long arch_local_save_flags(void)
+{
+	unsigned long flags;
+	asm volatile("arch_local_save_flags %0" : "=r" (flags));
+	return flags;
+}
 
 __asm__(
-	"	.macro	raw_local_irq_save result			\n"
+	"	.macro	arch_local_irq_save result			\n"
 	"	.set	push						\n"
 	"	.set	reorder						\n"
 	"	.set	noat						\n"
@@ -148,15 +150,18 @@ __asm__(
 	"	.set	pop						\n"
 	"	.endm							\n");
 
-#define raw_local_irq_save(x)						\
-__asm__ __volatile__(							\
-	"raw_local_irq_save\t%0"					\
-	: "=r" (x)							\
-	: /* no inputs */						\
-	: "memory")
+static inline unsigned long arch_local_irq_save(void)
+{
+	unsigned long flags;
+	asm volatile("arch_local_irq_save\t%0"
+		     : "=r" (flags)
+		     : /* no inputs */
+		     : "memory");
+	return flags;
+}
 
 __asm__(
-	"	.macro	raw_local_irq_restore flags			\n"
+	"	.macro	arch_local_irq_restore flags			\n"
 	"	.set	push						\n"
 	"	.set	noreorder					\n"
 	"	.set	noat						\n"
@@ -196,7 +201,7 @@ __asm__(
 	"	.endm							\n");
 
 
-static inline void raw_local_irq_restore(unsigned long flags)
+static inline void arch_local_irq_restore(unsigned long flags)
 {
 	unsigned long __tmp1;
 
@@ -211,24 +216,24 @@ static inline void raw_local_irq_restore(unsigned long flags)
 #endif
 
 	__asm__ __volatile__(
-		"raw_local_irq_restore\t%0"
+		"arch_local_irq_restore\t%0"
 		: "=r" (__tmp1)
 		: "0" (flags)
 		: "memory");
 }
 
-static inline void __raw_local_irq_restore(unsigned long flags)
+static inline void __arch_local_irq_restore(unsigned long flags)
 {
 	unsigned long __tmp1;
 
 	__asm__ __volatile__(
-		"raw_local_irq_restore\t%0"
+		"arch_local_irq_restore\t%0"
 		: "=r" (__tmp1)
 		: "0" (flags)
 		: "memory");
 }
 
-static inline int raw_irqs_disabled_flags(unsigned long flags)
+static inline int arch_irqs_disabled_flags(unsigned long flags)
 {
 #ifdef CONFIG_MIPS_MT_SMTC
 	/*
diff --git a/arch/mips/kernel/smtc.c b/arch/mips/kernel/smtc.c
index cfeb2c1..39c0825 100644
--- a/arch/mips/kernel/smtc.c
+++ b/arch/mips/kernel/smtc.c
@@ -1038,7 +1038,7 @@ void deferred_smtc_ipi(void)
 		 * but it's more efficient, given that we're already
 		 * running down the IPI queue.
 		 */
-		__raw_local_irq_restore(flags);
+		__arch_local_irq_restore(flags);
 	}
 }
 
@@ -1190,7 +1190,7 @@ void smtc_ipi_replay(void)
 		/*
 		 ** But use a raw restore here to avoid recursion.
 		 */
-		__raw_local_irq_restore(flags);
+		__arch_local_irq_restore(flags);
 
 		if (pipi) {
 			self_ipi(pipi);
diff --git a/arch/mn10300/include/asm/irqflags.h b/arch/mn10300/include/asm/irqflags.h
new file mode 100644
index 0000000..6a25d05
--- /dev/null
+++ b/arch/mn10300/include/asm/irqflags.h
@@ -0,0 +1,119 @@
+/* MN10300 IRQ flag handling
+ *
+ * Copyright (C) 2010 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+#ifndef _ASM_IRQFLAGS_H
+#define _ASM_IRQFLAGS_H
+
+#include <asm/cpu-regs.h>
+
+/*
+ * interrupt control
+ * - "disabled": run in IM1/2
+ *   - level 0 - GDB stub
+ *   - level 1 - virtual serial DMA (if present)
+ *   - level 5 - normal interrupt priority
+ *   - level 6 - timer interrupt
+ * - "enabled":  run in IM7
+ */
+#ifdef CONFIG_MN10300_TTYSM
+#define MN10300_CLI_LEVEL	EPSW_IM_2
+#else
+#define MN10300_CLI_LEVEL	EPSW_IM_1
+#endif
+
+#ifndef __ASSEMBLY__
+
+static inline unsigned long arch_local_save_flags(void)
+{
+	unsigned long flags;
+
+	asm volatile("mov epsw,%0" : "=d"(flags));
+	return flags;
+}
+
+static inline void arch_local_irq_disable(void)
+{
+	asm volatile("	and %0,epsw	\n"
+		     "	or %1,epsw	\n"
+		     "	nop		\n"
+		     "	nop		\n"
+		     "	nop		\n"
+		     :
+		     : "i"(~EPSW_IM), "i"(EPSW_IE | MN10300_CLI_LEVEL));
+}
+
+static inline unsigned long arch_local_irq_save(void)
+{
+	unsigned long flags;
+
+	flags = arch_local_save_flags();
+	arch_local_irq_disable();
+	return flags;
+}
+
+/*
+ * we make sure arch_irq_enable() doesn't cause priority inversion
+ */
+extern unsigned long __mn10300_irq_enabled_epsw;
+
+static inline void arch_local_irq_enable(void)
+{
+	unsigned long tmp;
+
+	asm volatile("	mov	epsw,%0		\n"
+		     "	and	%1,%0		\n"
+		     "	or	%2,%0		\n"
+		     "	mov	%0,epsw		\n"
+		     : "=&d"(tmp)
+		     : "i"(~EPSW_IM), "r"(__mn10300_irq_enabled_epsw)
+		     : "cc");
+}
+
+static inline void arch_local_irq_restore(unsigned long flags)
+{
+	asm volatile("	mov %0,epsw	\n"
+		"	nop		\n"
+		"	nop		\n"
+		"	nop		\n"
+		:
+		: "d"(flags)
+		: "memory", "cc"
+		);
+}
+
+static inline bool arch_irqs_disabled_flags(unsigned long flags)
+{
+	return (flags & EPSW_IM) <= MN10300_CLI_LEVEL;
+}
+
+static inline bool arch_irqs_disabled(void)
+{
+	return arch_irqs_disabled_flags(arch_local_save_flags());
+}
+
+/* hook to save power by halting the CPU
+ * - called from the idle loop
+ * - must reenable interrupts (which takes three instruction cycles to complete)
+ */
+static inline void arch_safe_halt(void)
+{
+	asm volatile("	or	%0,epsw	\n"
+		     "	nop		\n"
+		     "	nop		\n"
+		     "	bset	%2,(%1)	\n"
+		     :
+		     : "i"(EPSW_IE|EPSW_IM), "n"(&CPUM), "i"(CPUM_SLEEP)
+		     : "cc"
+		     );
+}
+
+#endif /* __ASSEMBLY__ */
+#endif /* _ASM_IRQFLAGS_H */
diff --git a/arch/mn10300/include/asm/system.h b/arch/mn10300/include/asm/system.h
index 3636c05..9f7c7e1 100644
--- a/arch/mn10300/include/asm/system.h
+++ b/arch/mn10300/include/asm/system.h
@@ -17,6 +17,7 @@
 #ifndef __ASSEMBLY__
 
 #include <linux/kernel.h>
+#include <linux/irqflags.h>
 
 struct task_struct;
 struct thread_struct;
@@ -81,114 +82,6 @@ do {									\
 
 /*****************************************************************************/
 /*
- * interrupt control
- * - "disabled": run in IM1/2
- *   - level 0 - GDB stub
- *   - level 1 - virtual serial DMA (if present)
- *   - level 5 - normal interrupt priority
- *   - level 6 - timer interrupt
- * - "enabled":  run in IM7
- */
-#ifdef CONFIG_MN10300_TTYSM
-#define MN10300_CLI_LEVEL	EPSW_IM_2
-#else
-#define MN10300_CLI_LEVEL	EPSW_IM_1
-#endif
-
-#define local_save_flags(x)			\
-do {						\
-	typecheck(unsigned long, x);		\
-	asm volatile(				\
-		"	mov epsw,%0	\n"	\
-		: "=d"(x)			\
-		);				\
-} while (0)
-
-#define local_irq_disable()						\
-do {									\
-	asm volatile(							\
-		"	and %0,epsw	\n"				\
-		"	or %1,epsw	\n"				\
-		"	nop		\n"				\
-		"	nop		\n"				\
-		"	nop		\n"				\
-		:							\
-		: "i"(~EPSW_IM), "i"(EPSW_IE | MN10300_CLI_LEVEL)	\
-		);							\
-} while (0)
-
-#define local_irq_save(x)			\
-do {						\
-	local_save_flags(x);			\
-	local_irq_disable();			\
-} while (0)
-
-/*
- * we make sure local_irq_enable() doesn't cause priority inversion
- */
-#ifndef __ASSEMBLY__
-
-extern unsigned long __mn10300_irq_enabled_epsw;
-
-#endif
-
-#define local_irq_enable()						\
-do {									\
-	unsigned long tmp;						\
-									\
-	asm volatile(							\
-		"	mov	epsw,%0		\n"			\
-		"	and	%1,%0		\n"			\
-		"	or	%2,%0		\n"			\
-		"	mov	%0,epsw		\n"			\
-		: "=&d"(tmp)						\
-		: "i"(~EPSW_IM), "r"(__mn10300_irq_enabled_epsw)	\
-		: "cc"							\
-		);							\
-} while (0)
-
-#define local_irq_restore(x)			\
-do {						\
-	typecheck(unsigned long, x);		\
-	asm volatile(				\
-		"	mov %0,epsw	\n"	\
-		"	nop		\n"	\
-		"	nop		\n"	\
-		"	nop		\n"	\
-		:				\
-		: "d"(x)			\
-		: "memory", "cc"		\
-		);				\
-} while (0)
-
-#define irqs_disabled()				\
-({						\
-	unsigned long flags;			\
-	local_save_flags(flags);		\
-	(flags & EPSW_IM) <= MN10300_CLI_LEVEL;	\
-})
-
-/* hook to save power by halting the CPU
- * - called from the idle loop
- * - must reenable interrupts (which takes three instruction cycles to complete)
- */
-#define safe_halt()							\
-do {									\
-	asm volatile("	or	%0,epsw	\n"				\
-		     "	nop		\n"				\
-		     "	nop		\n"				\
-		     "	bset	%2,(%1)	\n"				\
-		     :							\
-		     : "i"(EPSW_IE|EPSW_IM), "n"(&CPUM), "i"(CPUM_SLEEP)\
-		     : "cc"						\
-		     );							\
-} while (0)
-
-#define STI	or EPSW_IE|EPSW_IM,epsw
-#define CLI	and ~EPSW_IM,epsw; or EPSW_IE|MN10300_CLI_LEVEL,epsw; nop; nop; nop
-
-/*****************************************************************************/
-/*
  * MN10300 doesn't actually have an exchange instruction
  */
 #ifndef __ASSEMBLY__
diff --git a/arch/mn10300/kernel/entry.S b/arch/mn10300/kernel/entry.S
index d9ed5a1..3d394b4 100644
--- a/arch/mn10300/kernel/entry.S
+++ b/arch/mn10300/kernel/entry.S
@@ -16,6 +16,7 @@
 #include <linux/linkage.h>
 #include <asm/smp.h>
 #include <asm/system.h>
+#include <asm/irqflags.h>
 #include <asm/thread_info.h>
 #include <asm/intctl-regs.h>
 #include <asm/busctl-regs.h>
diff --git a/arch/parisc/include/asm/irqflags.h b/arch/parisc/include/asm/irqflags.h
new file mode 100644
index 0000000..34f9cb9
--- /dev/null
+++ b/arch/parisc/include/asm/irqflags.h
@@ -0,0 +1,46 @@
+#ifndef __PARISC_IRQFLAGS_H
+#define __PARISC_IRQFLAGS_H
+
+#include <linux/types.h>
+#include <asm/psw.h>
+
+static inline unsigned long arch_local_save_flags(void)
+{
+	unsigned long flags;
+	asm volatile("ssm 0, %0" : "=r" (flags) : : "memory");
+	return flags;
+}
+
+static inline void arch_local_irq_disable(void)
+{
+	asm volatile("rsm %0,%%r0\n" : : "i" (PSW_I) : "memory");
+}
+
+static inline void arch_local_irq_enable(void)
+{
+	asm volatile("ssm %0,%%r0\n" : : "i" (PSW_I) : "memory");
+}
+
+static inline unsigned long arch_local_irq_save(void)
+{
+	unsigned long flags;
+	asm volatile("rsm %1,%0" : "=r" (flags) : "i" (PSW_I) : "memory");
+	return flags;
+}
+
+static inline void arch_local_irq_restore(unsigned long flags)
+{
+	asm volatile("mtsm %0" : : "r" (flags) : "memory");
+}
+
+static inline bool arch_irqs_disabled_flags(unsigned long flags)
+{
+	return (flags & PSW_I) = 0;
+}
+
+static inline bool arch_irqs_disabled(void)
+{
+	return arch_irqs_disabled_flags(arch_local_save_flags());
+}
+
+#endif /* __PARISC_IRQFLAGS_H */
diff --git a/arch/parisc/include/asm/system.h b/arch/parisc/include/asm/system.h
index 2ab4af5..b19e63a 100644
--- a/arch/parisc/include/asm/system.h
+++ b/arch/parisc/include/asm/system.h
@@ -1,7 +1,7 @@
 #ifndef __PARISC_SYSTEM_H
 #define __PARISC_SYSTEM_H
 
-#include <asm/psw.h>
+#include <linux/irqflags.h>
 
 /* The program status word as bitfields.  */
 struct pa_psw {
@@ -48,23 +48,6 @@ extern struct task_struct *_switch_to(struct task_struct *, struct task_struct *
 	(last) = _switch_to(prev, next);			\
 } while(0)
 
-/* interrupt control */
-#define local_save_flags(x)	__asm__ __volatile__("ssm 0, %0" : "=r" (x) : : "memory")
-#define local_irq_disable()	__asm__ __volatile__("rsm %0,%%r0\n" : : "i" (PSW_I) : "memory" )
-#define local_irq_enable()	__asm__ __volatile__("ssm %0,%%r0\n" : : "i" (PSW_I) : "memory" )
-
-#define local_irq_save(x) \
-	__asm__ __volatile__("rsm %1,%0" : "=r" (x) :"i" (PSW_I) : "memory" )
-#define local_irq_restore(x) \
-	__asm__ __volatile__("mtsm %0" : : "r" (x) : "memory" )
-
-#define irqs_disabled()			\
-({					\
-	unsigned long flags;		\
-	local_save_flags(flags);	\
-	(flags & PSW_I) = 0;		\
-})
-
 #define mfctl(reg)	({		\
 	unsigned long cr;		\
 	__asm__ __volatile__(		\
diff --git a/arch/s390/include/asm/irqflags.h b/arch/s390/include/asm/irqflags.h
index 15b3ac2..865d6d8 100644
--- a/arch/s390/include/asm/irqflags.h
+++ b/arch/s390/include/asm/irqflags.h
@@ -8,8 +8,8 @@
 
 #include <linux/types.h>
 
-/* store then or system mask. */
-#define __raw_local_irq_stosm(__or)					\
+/* store then OR system mask. */
+#define __arch_local_irq_stosm(__or)					\
 ({									\
 	unsigned long __mask;						\
 	asm volatile(							\
@@ -18,8 +18,8 @@
 	__mask;								\
 })
 
-/* store then and system mask. */
-#define __raw_local_irq_stnsm(__and)					\
+/* store then AND system mask. */
+#define __arch_local_irq_stnsm(__and)					\
 ({									\
 	unsigned long __mask;						\
 	asm volatile(							\
@@ -29,39 +29,44 @@
 })
 
 /* set system mask. */
-#define __raw_local_irq_ssm(__mask)					\
-({									\
-	asm volatile("ssm   %0" : : "Q" (__mask) : "memory");		\
-})
+static inline void __arch_local_irq_ssm(unsigned long flags)
+{
+	asm volatile("ssm   %0" : : "Q" (flags) : "memory");
+}
 
-/* interrupt control.. */
-static inline unsigned long raw_local_irq_enable(void)
+static inline unsigned long arch_local_save_flags(void)
 {
-	return __raw_local_irq_stosm(0x03);
+	return __arch_local_irq_stosm(0x00);
 }
 
-static inline unsigned long raw_local_irq_disable(void)
+static inline unsigned long arch_local_irq_save(void)
 {
-	return __raw_local_irq_stnsm(0xfc);
+	return __arch_local_irq_stnsm(0xfc);
 }
 
-#define raw_local_save_flags(x)						\
-do {									\
-	typecheck(unsigned long, x);					\
-	(x) = __raw_local_irq_stosm(0x00);				\
-} while (0)
+static inline void arch_local_irq_disable(void)
+{
+	arch_local_irq_save();
+}
 
-static inline void raw_local_irq_restore(unsigned long flags)
+static inline void arch_local_irq_enable(void)
 {
-	__raw_local_irq_ssm(flags);
+	__arch_local_irq_stosm(0x03);
 }
 
-static inline int raw_irqs_disabled_flags(unsigned long flags)
+static inline void arch_local_irq_restore(unsigned long flags)
+{
+	__arch_local_irq_ssm(flags);
+}
+
+static inline bool arch_irqs_disabled_flags(unsigned long flags)
 {
 	return !(flags & (3UL << (BITS_PER_LONG - 8)));
 }
 
-/* For spinlocks etc */
-#define raw_local_irq_save(x)	((x) = raw_local_irq_disable())
+static inline bool arch_irqs_disabled(void)
+{
+	return arch_irqs_disabled_flags(arch_local_save_flags());
+}
 
 #endif /* __ASM_IRQFLAGS_H */
diff --git a/arch/s390/include/asm/system.h b/arch/s390/include/asm/system.h
index cef6621..8e8a50e 100644
--- a/arch/s390/include/asm/system.h
+++ b/arch/s390/include/asm/system.h
@@ -399,7 +399,7 @@ static inline unsigned long __cmpxchg_local(volatile void *ptr,
 static inline void
 __set_psw_mask(unsigned long mask)
 {
-	__load_psw_mask(mask | (__raw_local_irq_stosm(0x00) & ~(-1UL >> 8)));
+	__load_psw_mask(mask | (arch_local_save_flags() & ~(-1UL >> 8)));
 }
 
 #define local_mcck_enable()  __set_psw_mask(psw_kernel_bits)
diff --git a/arch/s390/kernel/mem_detect.c b/arch/s390/kernel/mem_detect.c
index 559af0d..0fbe4e3 100644
--- a/arch/s390/kernel/mem_detect.c
+++ b/arch/s390/kernel/mem_detect.c
@@ -54,11 +54,11 @@ void detect_memory_layout(struct mem_chunk chunk[])
 	 * right thing and we don't get scheduled away with low address
 	 * protection disabled.
 	 */
-	flags = __raw_local_irq_stnsm(0xf8);
+	flags = __arch_local_irq_stnsm(0xf8);
 	__ctl_store(cr0, 0, 0);
 	__ctl_clear_bit(0, 28);
 	find_memory_chunks(chunk);
 	__ctl_load(cr0, 0, 0);
-	__raw_local_irq_ssm(flags);
+	arch_local_irq_restore(flags);
 }
 EXPORT_SYMBOL(detect_memory_layout);
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 30eb6d02..d68004f 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -72,7 +72,7 @@ void __init paging_init(void)
 	__ctl_load(S390_lowcore.kernel_asce, 1, 1);
 	__ctl_load(S390_lowcore.kernel_asce, 7, 7);
 	__ctl_load(S390_lowcore.kernel_asce, 13, 13);
-	__raw_local_irq_ssm(ssm_mask);
+	arch_local_irq_restore(ssm_mask);
 
 	atomic_set(&init_mm.context.attach_count, 1);
 
diff --git a/arch/s390/mm/maccess.c b/arch/s390/mm/maccess.c
index a8c2af8..71a4b0d 100644
--- a/arch/s390/mm/maccess.c
+++ b/arch/s390/mm/maccess.c
@@ -71,7 +71,7 @@ int memcpy_real(void *dest, void *src, size_t count)
 
 	if (!count)
 		return 0;
-	flags = __raw_local_irq_stnsm(0xf8UL);
+	flags = __arch_local_irq_stnsm(0xf8UL);
 	asm volatile (
 		"0:	mvcle	%1,%2,0x0\n"
 		"1:	jo	0b\n"
@@ -82,6 +82,6 @@ int memcpy_real(void *dest, void *src, size_t count)
 		  "+d" (_len2), "=m" (*((long *) dest))
 		: "m" (*((long *) src))
 		: "cc", "memory");
-	__raw_local_irq_ssm(flags);
+	arch_local_irq_restore(flags);
 	return rc;
 }
diff --git a/arch/sparc/include/asm/irqflags_32.h b/arch/sparc/include/asm/irqflags_32.h
index 0fca9d9..d4d0711 100644
--- a/arch/sparc/include/asm/irqflags_32.h
+++ b/arch/sparc/include/asm/irqflags_32.h
@@ -5,33 +5,40 @@
  *
  * This file gets included from lowlevel asm headers too, to provide
  * wrapped versions of the local_irq_*() APIs, based on the
- * raw_local_irq_*() functions from the lowlevel headers.
+ * arch_local_irq_*() functions from the lowlevel headers.
  */
 #ifndef _ASM_IRQFLAGS_H
 #define _ASM_IRQFLAGS_H
 
 #ifndef __ASSEMBLY__
 
-extern void raw_local_irq_restore(unsigned long);
-extern unsigned long __raw_local_irq_save(void);
-extern void raw_local_irq_enable(void);
+#include <linux/types.h>
 
-static inline unsigned long getipl(void)
+extern void arch_local_irq_restore(unsigned long);
+extern unsigned long arch_local_irq_save(void);
+extern void arch_local_irq_enable(void);
+
+static inline unsigned long arch_local_save_flags(void)
 {
-        unsigned long retval;
+	unsigned long flags;
+
+	asm volatile("rd        %%psr, %0" : "=r" (flags));
+	return flags;
+}
 
-        __asm__ __volatile__("rd        %%psr, %0" : "=r" (retval));
-        return retval;
+static inline void arch_local_irq_disable(void)
+{
+	arch_local_irq_save();
 }
 
-#define raw_local_save_flags(flags) ((flags) = getipl())
-#define raw_local_irq_save(flags)   ((flags) = __raw_local_irq_save())
-#define raw_local_irq_disable()     ((void) __raw_local_irq_save())
-#define raw_irqs_disabled()         ((getipl() & PSR_PIL) != 0)
+static inline bool arch_irqs_disabled_flags(unsigned long flags)
+{
+	return (flags & PSR_PIL) != 0;
+}
 
-static inline int raw_irqs_disabled_flags(unsigned long flags)
+static inline bool arch_irqs_disabled(void)
 {
-        return ((flags & PSR_PIL) != 0);
+	return arch_irqs_disabled_flags(arch_local_save_flags());
 }
 
 #endif /* (__ASSEMBLY__) */
diff --git a/arch/sparc/include/asm/irqflags_64.h b/arch/sparc/include/asm/irqflags_64.h
index bfa1ea4..aab969c 100644
--- a/arch/sparc/include/asm/irqflags_64.h
+++ b/arch/sparc/include/asm/irqflags_64.h
@@ -5,7 +5,7 @@
  *
  * This file gets included from lowlevel asm headers too, to provide
  * wrapped versions of the local_irq_*() APIs, based on the
- * raw_local_irq_*() functions from the lowlevel headers.
+ * arch_local_irq_*() functions from the lowlevel headers.
  */
 #ifndef _ASM_IRQFLAGS_H
 #define _ASM_IRQFLAGS_H
@@ -14,7 +14,7 @@
 
 #ifndef __ASSEMBLY__
 
-static inline unsigned long __raw_local_save_flags(void)
+static inline unsigned long arch_local_save_flags(void)
 {
 	unsigned long flags;
 
@@ -26,10 +26,7 @@ static inline unsigned long __raw_local_save_flags(void)
 	return flags;
 }
 
-#define raw_local_save_flags(flags) \
-		do { (flags) = __raw_local_save_flags(); } while (0)
-
-static inline void raw_local_irq_restore(unsigned long flags)
+static inline void arch_local_irq_restore(unsigned long flags)
 {
 	__asm__ __volatile__(
 		"wrpr	%0, %%pil"
@@ -39,7 +36,7 @@ static inline void raw_local_irq_restore(unsigned long flags)
 	);
 }
 
-static inline void raw_local_irq_disable(void)
+static inline void arch_local_irq_disable(void)
 {
 	__asm__ __volatile__(
 		"wrpr	%0, %%pil"
@@ -49,7 +46,7 @@ static inline void raw_local_irq_disable(void)
 	);
 }
 
-static inline void raw_local_irq_enable(void)
+static inline void arch_local_irq_enable(void)
 {
 	__asm__ __volatile__(
 		"wrpr	0, %%pil"
@@ -59,22 +56,17 @@ static inline void raw_local_irq_enable(void)
 	);
 }
 
-static inline int raw_irqs_disabled_flags(unsigned long flags)
+static inline int arch_irqs_disabled_flags(unsigned long flags)
 {
 	return (flags > 0);
 }
 
-static inline int raw_irqs_disabled(void)
+static inline int arch_irqs_disabled(void)
 {
-	unsigned long flags = __raw_local_save_flags();
-
-	return raw_irqs_disabled_flags(flags);
+	return arch_irqs_disabled_flags(arch_local_save_flags());
 }
 
-/*
- * For spinlocks, etc:
- */
-static inline unsigned long __raw_local_irq_save(void)
+static inline unsigned long arch_local_irq_save(void)
 {
 	unsigned long flags, tmp;
 
@@ -100,9 +92,6 @@ static inline unsigned long __raw_local_irq_save(void)
 	return flags;
 }
 
-#define raw_local_irq_save(flags) \
-		do { (flags) = __raw_local_irq_save(); } while (0)
-
 #endif /* (__ASSEMBLY__) */
 
 #endif /* !(_ASM_IRQFLAGS_H) */
diff --git a/arch/sparc/kernel/irq_32.c b/arch/sparc/kernel/irq_32.c
index e1af437..0116d8d 100644
--- a/arch/sparc/kernel/irq_32.c
+++ b/arch/sparc/kernel/irq_32.c
@@ -57,7 +57,7 @@
 #define SMP_NOP2
 #define SMP_NOP3
 #endif /* SMP */
-unsigned long __raw_local_irq_save(void)
+unsigned long arch_local_irq_save(void)
 {
 	unsigned long retval;
 	unsigned long tmp;
@@ -74,8 +74,9 @@ unsigned long __raw_local_irq_save(void)
 
 	return retval;
 }
+EXPORT_SYMBOL(arch_local_irq_save);
 
-void raw_local_irq_enable(void)
+void arch_local_irq_enable(void)
 {
 	unsigned long tmp;
 
@@ -89,8 +90,9 @@ void raw_local_irq_enable(void)
 		: "i" (PSR_PIL)
 		: "memory");
 }
+EXPORT_SYMBOL(arch_local_irq_enable);
 
-void raw_local_irq_restore(unsigned long old_psr)
+void arch_local_irq_restore(unsigned long old_psr)
 {
 	unsigned long tmp;
 
@@ -105,10 +107,7 @@ void raw_local_irq_restore(unsigned long old_psr)
 		: "i" (PSR_PIL), "r" (old_psr)
 		: "memory");
 }
-
-EXPORT_SYMBOL(__raw_local_irq_save);
-EXPORT_SYMBOL(raw_local_irq_enable);
-EXPORT_SYMBOL(raw_local_irq_restore);
+EXPORT_SYMBOL(arch_local_irq_restore);
 
 /*
  * Dave Redman (djhr@tadpole.co.uk)
diff --git a/arch/sparc/prom/p1275.c b/arch/sparc/prom/p1275.c
index fa6e4e2..d9850c2 100644
--- a/arch/sparc/prom/p1275.c
+++ b/arch/sparc/prom/p1275.c
@@ -39,7 +39,7 @@ void p1275_cmd_direct(unsigned long *args)
 	unsigned long flags;
 
 	raw_local_save_flags(flags);
-	raw_local_irq_restore(PIL_NMI);
+	raw_local_irq_restore((unsigned long)PIL_NMI);
 	raw_spin_lock(&prom_entry_lock);
 
 	prom_world(1);
diff --git a/arch/tile/include/asm/irqflags.h b/arch/tile/include/asm/irqflags.h
index 45cf67c..a11d483 100644
--- a/arch/tile/include/asm/irqflags.h
+++ b/arch/tile/include/asm/irqflags.h
@@ -103,55 +103,57 @@ DECLARE_PER_CPU(unsigned long long, interrupts_enabled_mask);
 #define INITIAL_INTERRUPTS_ENABLED INT_MASK(INT_MEM_ERROR)
 
 /* Disable interrupts. */
-#define raw_local_irq_disable() \
+#define arch_local_irq_disable() \
 	interrupt_mask_set_mask(LINUX_MASKABLE_INTERRUPTS)
 
 /* Disable all interrupts, including NMIs. */
-#define raw_local_irq_disable_all() \
+#define arch_local_irq_disable_all() \
 	interrupt_mask_set_mask(-1UL)
 
 /* Re-enable all maskable interrupts. */
-#define raw_local_irq_enable() \
+#define arch_local_irq_enable() \
 	interrupt_mask_reset_mask(__get_cpu_var(interrupts_enabled_mask))
 
 /* Disable or enable interrupts based on flag argument. */
-#define raw_local_irq_restore(disabled) do { \
+#define arch_local_irq_restore(disabled) do { \
 	if (disabled) \
-		raw_local_irq_disable(); \
+		arch_local_irq_disable(); \
 	else \
-		raw_local_irq_enable(); \
+		arch_local_irq_enable(); \
 } while (0)
 
 /* Return true if "flags" argument means interrupts are disabled. */
-#define raw_irqs_disabled_flags(flags) ((flags) != 0)
+#define arch_irqs_disabled_flags(flags) ((flags) != 0)
 
 /* Return true if interrupts are currently disabled. */
-#define raw_irqs_disabled() interrupt_mask_check(INT_MEM_ERROR)
+#define arch_irqs_disabled() interrupt_mask_check(INT_MEM_ERROR)
 
 /* Save whether interrupts are currently disabled. */
-#define raw_local_save_flags(flags) ((flags) = raw_irqs_disabled())
+#define arch_local_save_flags() arch_irqs_disabled()
 
 /* Save whether interrupts are currently disabled, then disable them. */
-#define raw_local_irq_save(flags) \
-	do { raw_local_save_flags(flags); raw_local_irq_disable(); } while (0)
+#define arch_local_irq_save() ({ \
+	unsigned long __flags = arch_local_save_flags(); \
+	arch_local_irq_disable(); \
+	__flags; })
 
 /* Prevent the given interrupt from being enabled next time we enable irqs. */
-#define raw_local_irq_mask(interrupt) \
+#define arch_local_irq_mask(interrupt) \
 	(__get_cpu_var(interrupts_enabled_mask) &= ~INT_MASK(interrupt))
 
 /* Prevent the given interrupt from being enabled immediately. */
-#define raw_local_irq_mask_now(interrupt) do { \
-	raw_local_irq_mask(interrupt); \
+#define arch_local_irq_mask_now(interrupt) do { \
+	arch_local_irq_mask(interrupt); \
 	interrupt_mask_set(interrupt); \
 } while (0)
 
 /* Allow the given interrupt to be enabled next time we enable irqs. */
-#define raw_local_irq_unmask(interrupt) \
+#define arch_local_irq_unmask(interrupt) \
 	(__get_cpu_var(interrupts_enabled_mask) |= INT_MASK(interrupt))
 
 /* Allow the given interrupt to be enabled immediately, if !irqs_disabled. */
-#define raw_local_irq_unmask_now(interrupt) do { \
-	raw_local_irq_unmask(interrupt); \
+#define arch_local_irq_unmask_now(interrupt) do { \
+	arch_local_irq_unmask(interrupt); \
 	if (!irqs_disabled()) \
 		interrupt_mask_reset(interrupt); \
 } while (0)
diff --git a/arch/x86/include/asm/irqflags.h b/arch/x86/include/asm/irqflags.h
index 9e2b952..5745ce8 100644
--- a/arch/x86/include/asm/irqflags.h
+++ b/arch/x86/include/asm/irqflags.h
@@ -61,22 +61,22 @@ static inline void native_halt(void)
 #else
 #ifndef __ASSEMBLY__
 
-static inline unsigned long __raw_local_save_flags(void)
+static inline unsigned long arch_local_save_flags(void)
 {
 	return native_save_fl();
 }
 
-static inline void raw_local_irq_restore(unsigned long flags)
+static inline void arch_local_irq_restore(unsigned long flags)
 {
 	native_restore_fl(flags);
 }
 
-static inline void raw_local_irq_disable(void)
+static inline void arch_local_irq_disable(void)
 {
 	native_irq_disable();
 }
 
-static inline void raw_local_irq_enable(void)
+static inline void arch_local_irq_enable(void)
 {
 	native_irq_enable();
 }
@@ -85,7 +85,7 @@ static inline void raw_local_irq_enable(void)
  * Used in the idle loop; sti takes one instruction cycle
  * to complete:
  */
-static inline void raw_safe_halt(void)
+static inline void arch_safe_halt(void)
 {
 	native_safe_halt();
 }
@@ -102,12 +102,10 @@ static inline void halt(void)
 /*
  * For spinlocks, etc:
  */
-static inline unsigned long __raw_local_irq_save(void)
+static inline unsigned long arch_local_irq_save(void)
 {
-	unsigned long flags = __raw_local_save_flags();
-
-	raw_local_irq_disable();
-
+	unsigned long flags = arch_local_save_flags();
+	arch_local_irq_disable();
 	return flags;
 }
 #else
@@ -153,22 +151,16 @@ static inline unsigned long __raw_local_irq_save(void)
 #endif /* CONFIG_PARAVIRT */
 
 #ifndef __ASSEMBLY__
-#define raw_local_save_flags(flags)				\
-	do { (flags) = __raw_local_save_flags(); } while (0)
-
-#define raw_local_irq_save(flags)				\
-	do { (flags) = __raw_local_irq_save(); } while (0)
-
-static inline int raw_irqs_disabled_flags(unsigned long flags)
+static inline int arch_irqs_disabled_flags(unsigned long flags)
 {
 	return !(flags & X86_EFLAGS_IF);
 }
 
-static inline int raw_irqs_disabled(void)
+static inline int arch_irqs_disabled(void)
 {
-	unsigned long flags = __raw_local_save_flags();
+	unsigned long flags = arch_local_save_flags();
 
-	return raw_irqs_disabled_flags(flags);
+	return arch_irqs_disabled_flags(flags);
 }
 
 #else
diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
index 5653f43..499954c 100644
--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -105,7 +105,7 @@ static inline void write_cr8(unsigned long x)
 }
 #endif
 
-static inline void raw_safe_halt(void)
+static inline void arch_safe_halt(void)
 {
 	PVOP_VCALL0(pv_irq_ops.safe_halt);
 }
@@ -829,32 +829,32 @@ static __always_inline void arch_spin_unlock(struct arch_spinlock *lock)
 #define __PV_IS_CALLEE_SAVE(func)			\
 	((struct paravirt_callee_save) { func })
 
-static inline unsigned long __raw_local_save_flags(void)
+static inline unsigned long arch_local_save_flags(void)
 {
 	return PVOP_CALLEE0(unsigned long, pv_irq_ops.save_fl);
 }
 
-static inline void raw_local_irq_restore(unsigned long f)
+static inline void arch_local_irq_restore(unsigned long f)
 {
 	PVOP_VCALLEE1(pv_irq_ops.restore_fl, f);
 }
 
-static inline void raw_local_irq_disable(void)
+static inline void arch_local_irq_disable(void)
 {
 	PVOP_VCALLEE0(pv_irq_ops.irq_disable);
 }
 
-static inline void raw_local_irq_enable(void)
+static inline void arch_local_irq_enable(void)
 {
 	PVOP_VCALLEE0(pv_irq_ops.irq_enable);
 }
 
-static inline unsigned long __raw_local_irq_save(void)
+static inline unsigned long arch_local_irq_save(void)
 {
 	unsigned long f;
 
-	f = __raw_local_save_flags();
-	raw_local_irq_disable();
+	f = arch_local_save_flags();
+	arch_local_irq_disable();
 	return f;
 }
 
diff --git a/drivers/s390/char/sclp.c b/drivers/s390/char/sclp.c
index f6d72e1..5707a80 100644
--- a/drivers/s390/char/sclp.c
+++ b/drivers/s390/char/sclp.c
@@ -468,7 +468,7 @@ sclp_sync_wait(void)
 	cr0_sync &= 0xffff00a0;
 	cr0_sync |= 0x00000200;
 	__ctl_load(cr0_sync, 0, 0);
-	__raw_local_irq_stosm(0x01);
+	__arch_local_irq_stosm(0x01);
 	/* Loop until driver state indicates finished request */
 	while (sclp_running_state != sclp_running_state_idle) {
 		/* Check for expired request timer */
diff --git a/include/asm-generic/atomic.h b/include/asm-generic/atomic.h
index e53347f..fd57b84 100644
--- a/include/asm-generic/atomic.h
+++ b/include/asm-generic/atomic.h
@@ -43,6 +43,7 @@
  */
 #define atomic_set(v, i) (((v)->counter) = (i))
 
+#include <linux/irqflags.h>
 #include <asm/system.h>
 
 /**
@@ -57,7 +58,7 @@ static inline int atomic_add_return(int i, atomic_t *v)
 	unsigned long flags;
 	int temp;
 
-	raw_local_irq_save(flags); /* Don't trace it in a irqsoff handler */
+	raw_local_irq_save(flags); /* Don't trace it in an irqsoff handler */
 	temp = v->counter;
 	temp += i;
 	v->counter = temp;
@@ -78,7 +79,7 @@ static inline int atomic_sub_return(int i, atomic_t *v)
 	unsigned long flags;
 	int temp;
 
-	raw_local_irq_save(flags); /* Don't trace it in a irqsoff handler */
+	raw_local_irq_save(flags); /* Don't trace it in an irqsoff handler */
 	temp = v->counter;
 	temp -= i;
 	v->counter = temp;
diff --git a/include/asm-generic/cmpxchg-local.h b/include/asm-generic/cmpxchg-local.h
index b2ba2fc..2533fdd 100644
--- a/include/asm-generic/cmpxchg-local.h
+++ b/include/asm-generic/cmpxchg-local.h
@@ -2,6 +2,7 @@
 #define __ASM_GENERIC_CMPXCHG_LOCAL_H
 
 #include <linux/types.h>
+#include <linux/irqflags.h>
 
 extern unsigned long wrong_size_cmpxchg(volatile void *ptr);
 
diff --git a/include/asm-generic/hardirq.h b/include/asm-generic/hardirq.h
index 62f5908..c0771aa 100644
--- a/include/asm-generic/hardirq.h
+++ b/include/asm-generic/hardirq.h
@@ -3,7 +3,6 @@
 
 #include <linux/cache.h>
 #include <linux/threads.h>
-#include <linux/irq.h>
 
 typedef struct {
 	unsigned int __softirq_pending;
diff --git a/include/asm-generic/irqflags.h b/include/asm-generic/irqflags.h
index 9aebf61..1f40d002 100644
--- a/include/asm-generic/irqflags.h
+++ b/include/asm-generic/irqflags.h
@@ -5,68 +5,62 @@
  * All architectures should implement at least the first two functions,
  * usually inline assembly will be the best way.
  */
-#ifndef RAW_IRQ_DISABLED
-#define RAW_IRQ_DISABLED 0
-#define RAW_IRQ_ENABLED 1
+#ifndef ARCH_IRQ_DISABLED
+#define ARCH_IRQ_DISABLED 0
+#define ARCH_IRQ_ENABLED 1
 #endif
 
 /* read interrupt enabled status */
-#ifndef __raw_local_save_flags
-unsigned long __raw_local_save_flags(void);
+#ifndef arch_local_save_flags
+unsigned long arch_local_save_flags(void);
 #endif
 
 /* set interrupt enabled status */
-#ifndef raw_local_irq_restore
-void raw_local_irq_restore(unsigned long flags);
+#ifndef arch_local_irq_restore
+void arch_local_irq_restore(unsigned long flags);
 #endif
 
 /* get status and disable interrupts */
-#ifndef __raw_local_irq_save
-static inline unsigned long __raw_local_irq_save(void)
+#ifndef arch_local_irq_save
+static inline unsigned long arch_local_irq_save(void)
 {
 	unsigned long flags;
-	flags = __raw_local_save_flags();
-	raw_local_irq_restore(RAW_IRQ_DISABLED);
+	flags = arch_local_save_flags();
+	arch_local_irq_restore(ARCH_IRQ_DISABLED);
 	return flags;
 }
 #endif
 
 /* test flags */
-#ifndef raw_irqs_disabled_flags
-static inline int raw_irqs_disabled_flags(unsigned long flags)
+#ifndef arch_irqs_disabled_flags
+static inline int arch_irqs_disabled_flags(unsigned long flags)
 {
-	return flags = RAW_IRQ_DISABLED;
+	return flags = ARCH_IRQ_DISABLED;
 }
 #endif
 
 /* unconditionally enable interrupts */
-#ifndef raw_local_irq_enable
-static inline void raw_local_irq_enable(void)
+#ifndef arch_local_irq_enable
+static inline void arch_local_irq_enable(void)
 {
-	raw_local_irq_restore(RAW_IRQ_ENABLED);
+	arch_local_irq_restore(ARCH_IRQ_ENABLED);
 }
 #endif
 
 /* unconditionally disable interrupts */
-#ifndef raw_local_irq_disable
-static inline void raw_local_irq_disable(void)
+#ifndef arch_local_irq_disable
+static inline void arch_local_irq_disable(void)
 {
-	raw_local_irq_restore(RAW_IRQ_DISABLED);
+	arch_local_irq_restore(ARCH_IRQ_DISABLED);
 }
 #endif
 
 /* test hardware interrupt enable bit */
-#ifndef raw_irqs_disabled
-static inline int raw_irqs_disabled(void)
+#ifndef arch_irqs_disabled
+static inline int arch_irqs_disabled(void)
 {
-	return raw_irqs_disabled_flags(__raw_local_save_flags());
+	return arch_irqs_disabled_flags(arch_local_save_flags());
 }
 #endif
 
-#define raw_local_save_flags(flags) \
-	do { (flags) = __raw_local_save_flags(); } while (0)
-
-#define raw_local_irq_save(flags) \
-	do { (flags) = __raw_local_irq_save(); } while (0)
-
 #endif /* __ASM_GENERIC_IRQFLAGS_H */
diff --git a/include/linux/irqflags.h b/include/linux/irqflags.h
index 006bf45..d176d65 100644
--- a/include/linux/irqflags.h
+++ b/include/linux/irqflags.h
@@ -12,6 +12,7 @@
 #define _LINUX_TRACE_IRQFLAGS_H
 
 #include <linux/typecheck.h>
+#include <asm/irqflags.h>
 
 #ifdef CONFIG_TRACE_IRQFLAGS
   extern void trace_softirqs_on(unsigned long ip);
@@ -52,17 +53,45 @@
 # define start_critical_timings() do { } while (0)
 #endif
 
-#ifdef CONFIG_TRACE_IRQFLAGS_SUPPORT
-
-#include <asm/irqflags.h>
+/*
+ * Wrap the arch provided IRQ routines to provide appropriate checks.
+ */
+#define raw_local_irq_disable()		arch_local_irq_disable()
+#define raw_local_irq_enable()		arch_local_irq_enable()
+#define raw_local_irq_save(flags)			\
+	do {						\
+		typecheck(unsigned long, flags);	\
+		flags = arch_local_irq_save();		\
+	} while (0)
+#define raw_local_irq_restore(flags)			\
+	do {						\
+		typecheck(unsigned long, flags);	\
+		arch_local_irq_restore(flags);		\
+	} while (0)
+#define raw_local_save_flags(flags)			\
+	do {						\
+		typecheck(unsigned long, flags);	\
+		flags = arch_local_save_flags();	\
+	} while (0)
+#define raw_irqs_disabled_flags(flags)			\
+	({						\
+		typecheck(unsigned long, flags);	\
+		arch_irqs_disabled_flags(flags);	\
+	})
+#define raw_irqs_disabled()		(arch_irqs_disabled())
+#define raw_safe_halt()			arch_safe_halt()
 
+/*
+ * The local_irq_*() APIs are equal to the raw_local_irq*()
+ * if !TRACE_IRQFLAGS.
+ */
+#ifdef CONFIG_TRACE_IRQFLAGS_SUPPORT
 #define local_irq_enable() \
 	do { trace_hardirqs_on(); raw_local_irq_enable(); } while (0)
 #define local_irq_disable() \
 	do { raw_local_irq_disable(); trace_hardirqs_off(); } while (0)
 #define local_irq_save(flags)				\
 	do {						\
-		typecheck(unsigned long, flags);	\
 		raw_local_irq_save(flags);		\
 		trace_hardirqs_off();			\
 	} while (0)
@@ -70,7 +99,6 @@
 
 #define local_irq_restore(flags)			\
 	do {						\
-		typecheck(unsigned long, flags);	\
 		if (raw_irqs_disabled_flags(flags)) {	\
 			raw_local_irq_restore(flags);	\
 			trace_hardirqs_off();		\
@@ -79,51 +107,44 @@
 			raw_local_irq_restore(flags);	\
 		}					\
 	} while (0)
-#else /* !CONFIG_TRACE_IRQFLAGS_SUPPORT */
-/*
- * The local_irq_*() APIs are equal to the raw_local_irq*()
- * if !TRACE_IRQFLAGS.
- */
-# define raw_local_irq_disable()	local_irq_disable()
-# define raw_local_irq_enable()		local_irq_enable()
-# define raw_local_irq_save(flags)			\
-	do {						\
-		typecheck(unsigned long, flags);	\
-		local_irq_save(flags);			\
-	} while (0)
-# define raw_local_irq_restore(flags)			\
+#define local_save_flags(flags)				\
 	do {						\
-		typecheck(unsigned long, flags);	\
-		local_irq_restore(flags);		\
+		raw_local_save_flags(flags);		\
 	} while (0)
-#endif /* CONFIG_TRACE_IRQFLAGS_SUPPORT */
 
-#ifdef CONFIG_TRACE_IRQFLAGS_SUPPORT
-#define safe_halt()						\
-	do {							\
-		trace_hardirqs_on();				\
-		raw_safe_halt();				\
-	} while (0)
+#define irqs_disabled_flags(flags)			\
+	({						\
+		raw_irqs_disabled_flags(flags);		\
+	})
 
-#define local_save_flags(flags)				\
-	do {						\
-		typecheck(unsigned long, flags);	\
-		raw_local_save_flags(flags);		\
+#define irqs_disabled()					\
+	({						\
+		unsigned long _flags;			\
+		raw_local_save_flags(_flags);		\
+		raw_irqs_disabled_flags(_flags);	\
+	})
+
+#define safe_halt()				\
+	do {					\
+		trace_hardirqs_on();		\
+		raw_safe_halt();		\
 	} while (0)
 
-#define irqs_disabled()						\
-({								\
-	unsigned long _flags;					\
-								\
-	raw_local_save_flags(_flags);				\
-	raw_irqs_disabled_flags(_flags);			\
-})
 
-#define irqs_disabled_flags(flags)		\
-({						\
-	typecheck(unsigned long, flags);	\
-	raw_irqs_disabled_flags(flags);		\
-})
+#else /* !CONFIG_TRACE_IRQFLAGS_SUPPORT */
+
+#define local_irq_enable()	do { raw_local_irq_enable(); } while (0)
+#define local_irq_disable()	do { raw_local_irq_disable(); } while (0)
+#define local_irq_save(flags)					\
+	do {							\
+		raw_local_irq_save(flags);			\
+	} while (0)
+#define local_irq_restore(flags) do { raw_local_irq_restore(flags); } while (0)
+#define local_save_flags(flags)	do { raw_local_save_flags(flags); } while (0)
+#define irqs_disabled()		(raw_irqs_disabled())
+#define irqs_disabled_flags(flags) (raw_irqs_disabled_flags(flags))
+#define safe_halt()		do { raw_safe_halt(); } while (0)
+
 #endif /* CONFIG_TRACE_IRQFLAGS_SUPPORT */
 
 #endif
diff --git a/include/linux/spinlock.h b/include/linux/spinlock.h
index f885465..80e5358 100644
--- a/include/linux/spinlock.h
+++ b/include/linux/spinlock.h
@@ -50,6 +50,7 @@
 #include <linux/preempt.h>
 #include <linux/linkage.h>
 #include <linux/compiler.h>
+#include <linux/irqflags.h>
 #include <linux/thread_info.h>
 #include <linux/kernel.h>
 #include <linux/stringify.h>

