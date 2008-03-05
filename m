From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 05 Mar 2008 18:18:54 +0000
Subject: [PATCH 39/50] ia64/xen: introduce xen paravirtualized intrinsic operations for privileged instructio
Message-Id: <12047411463456-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/xen/hypercall.S     |  124 ++++++++++
 include/asm-ia64/xen/privop.h |  512 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 636 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/xen/hypercall.S

diff --git a/arch/ia64/xen/hypercall.S b/arch/ia64/xen/hypercall.S
new file mode 100644
index 0000000..a96f278
--- /dev/null
+++ b/arch/ia64/xen/hypercall.S
@@ -0,0 +1,124 @@
+/*
+ * Support routines for Xen hypercalls
+ *
+ * Copyright (C) 2005 Dan Magenheimer <dan.magenheimer@hp.com>
+ */
+
+#include <asm/asmmacro.h>
+#include <asm/intrinsics.h>
+
+#ifdef __INTEL_COMPILER
+# undef ASM_SUPPORTED
+#else
+# define ASM_SUPPORTED
+#endif
+
+#ifndef ASM_SUPPORTED
+GLOBAL_ENTRY(xen_get_psr)
+	XEN_HYPER_GET_PSR
+	br.ret.sptk.many rp
+	;;
+END(xen_get_psr)
+
+GLOBAL_ENTRY(xen_get_ivr)
+	XEN_HYPER_GET_IVR
+	br.ret.sptk.many rp
+	;;
+END(xen_get_ivr)
+
+GLOBAL_ENTRY(xen_get_tpr)
+	XEN_HYPER_GET_TPR
+	br.ret.sptk.many rp
+	;;
+END(xen_get_tpr)
+
+GLOBAL_ENTRY(xen_set_tpr)
+	mov r8=r32
+	XEN_HYPER_SET_TPR
+	br.ret.sptk.many rp
+	;;
+END(xen_set_tpr)
+
+GLOBAL_ENTRY(xen_eoi)
+	mov r8=r32
+	XEN_HYPER_EOI
+	br.ret.sptk.many rp
+	;;
+END(xen_eoi)
+
+GLOBAL_ENTRY(xen_thash)
+	mov r8=r32
+	XEN_HYPER_THASH
+	br.ret.sptk.many rp
+	;;
+END(xen_thash)
+
+GLOBAL_ENTRY(xen_set_itm)
+	mov r8=r32
+	XEN_HYPER_SET_ITM
+	br.ret.sptk.many rp
+	;;
+END(xen_set_itm)
+
+GLOBAL_ENTRY(xen_ptcga)
+	mov r8=r32
+	mov r9=r33
+	XEN_HYPER_PTC_GA
+	br.ret.sptk.many rp
+	;;
+END(xen_ptcga)
+
+GLOBAL_ENTRY(xen_get_rr)
+	mov r8=r32
+	XEN_HYPER_GET_RR
+	br.ret.sptk.many rp
+	;;
+END(xen_get_rr)
+
+GLOBAL_ENTRY(xen_set_rr)
+	mov r8=r32
+	mov r9=r33
+	XEN_HYPER_SET_RR
+	br.ret.sptk.many rp
+	;;
+END(xen_set_rr)
+
+GLOBAL_ENTRY(xen_set_kr)
+	mov r8=r32
+	mov r9=r33
+	XEN_HYPER_SET_KR
+	br.ret.sptk.many rp
+END(xen_set_kr)
+
+GLOBAL_ENTRY(xen_fc)
+	mov r8=r32
+	XEN_HYPER_FC
+	br.ret.sptk.many rp
+END(xen_fc)
+
+GLOBAL_ENTRY(xen_get_cpuid)
+	mov r8=r32
+	XEN_HYPER_GET_CPUID
+	br.ret.sptk.many rp
+END(xen_get_cpuid)
+
+GLOBAL_ENTRY(xen_get_pmd)
+	mov r8=r32
+	XEN_HYPER_GET_PMD
+	br.ret.sptk.many rp
+END(xen_get_pmd)
+
+#ifdef CONFIG_IA32_SUPPORT
+GLOBAL_ENTRY(xen_get_eflag)
+	XEN_HYPER_GET_EFLAG
+	br.ret.sptk.many rp
+END(xen_get_eflag)
+
+// some bits aren't set if pl!=0, see SDM vol1 3.1.8
+GLOBAL_ENTRY(xen_set_eflag)
+	mov r8=r32
+	XEN_HYPER_SET_EFLAG
+	br.ret.sptk.many rp
+END(xen_set_eflag)
+#endif /* CONFIG_IA32_SUPPORT */
+#endif /* ASM_SUPPORTED */
diff --git a/include/asm-ia64/xen/privop.h b/include/asm-ia64/xen/privop.h
index dd3e5ec..95e8e8a 100644
--- a/include/asm-ia64/xen/privop.h
+++ b/include/asm-ia64/xen/privop.h
@@ -70,4 +70,516 @@
 #define XSI_IHA				(XSI_BASE + XSI_IHA_OFS)
 #endif
 
+#ifndef __ASSEMBLY__
+#define	XEN_HYPER_SSM_I		asm("break %0" : : "i" (HYPERPRIVOP_SSM_I))
+#define	XEN_HYPER_GET_IVR	asm("break %0" : : "i" (HYPERPRIVOP_GET_IVR))
+
+/************************************************/
+/* Instructions paravirtualized for correctness */
+/************************************************/
+
+/* "fc" and "thash" are privilege-sensitive instructions, meaning they
+ *  may have different semantics depending on whether they are executed
+ *  at PL0 vs PL!=0.  When paravirtualized, these instructions mustn't
+ *  be allowed to execute directly, lest incorrect semantics result. */
+#ifdef ASM_SUPPORTED
+static inline void
+xen_fc(unsigned long addr)
+{
+	register __u64 __addr asm ("r8") = addr;
+	asm volatile ("break %0":: "i"(HYPERPRIVOP_FC), "r"(__addr));
+}
+
+static inline unsigned long
+xen_thash(unsigned long addr)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	register __u64 __addr asm ("r8") = addr;
+	asm volatile ("break %1":
+		      "=r"(ia64_intri_res):
+		      "i"(HYPERPRIVOP_THASH), "0"(__addr));
+	return ia64_intri_res;
+}
+#else
+extern void xen_fc(unsigned long addr);
+extern unsigned long xen_thash(unsigned long addr);
+#endif
+
+/* Note that "ttag" and "cover" are also privilege-sensitive; "ttag"
+ * is not currently used (though it may be in a long-format VHPT system!)
+ * and the semantics of cover only change if psr.ic is off which is very
+ * rare (and currently non-existent outside of assembly code */
+
+/* There are also privilege-sensitive registers.  These registers are
+ * readable at any privilege level but only writable at PL0. */
+#ifdef ASM_SUPPORTED
+static inline unsigned long
+xen_get_cpuid(int index)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	register __u64 __index asm ("r8") = index;
+	asm volatile ("break %1":
+		      "=r"(ia64_intri_res):
+		      "i"(HYPERPRIVOP_GET_CPUID), "0"(__index));
+	return ia64_intri_res;
+}
+
+static inline unsigned long
+xen_get_pmd(int index)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	register __u64 __index asm ("r8") = index;
+	asm volatile ("break %1":
+		      "=r"(ia64_intri_res):
+		      "i"(HYPERPRIVOP_GET_PMD), "0O"(__index));
+	return ia64_intri_res;
+}
+#else
+extern unsigned long xen_get_cpuid(int index);
+extern unsigned long xen_get_pmd(int index);
+#endif
+
+#ifdef ASM_SUPPORTED
+static inline unsigned long
+xen_get_eflag(void)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	asm volatile ("break %1":
+		      "=r"(ia64_intri_res): "i"(HYPERPRIVOP_GET_EFLAG));
+	return ia64_intri_res;
+}
+
+static inline void
+xen_set_eflag(unsigned long val)
+{
+	register __u64 __val asm ("r8") = val;
+	asm volatile ("break %0":: "i"(HYPERPRIVOP_SET_EFLAG), "r"(__val));
+}
+#else
+extern unsigned long xen_get_eflag(void);	/* see xen_ia64_getreg */
+extern void xen_set_eflag(unsigned long);	/* see xen_ia64_setreg */
+#endif
+
+/************************************************/
+/* Instructions paravirtualized for performance */
+/************************************************/
+
+/* Xen uses memory-mapped virtual privileged registers for access to many
+ * performance-sensitive privileged registers.  Some, like the processor
+ * status register (psr), are broken up into multiple memory locations.
+ * Others, like "pend", are abstractions based on privileged registers.
+ * "Pend" is guaranteed to be set if reading cr.ivr would return a
+ * (non-spurious) interrupt. */
+#define XEN_MAPPEDREGS ((struct mapped_regs *)XMAPPEDREGS_BASE)
+
+#define XSI_PSR_I			\
+	(*XEN_MAPPEDREGS->interrupt_mask_addr)
+#define xen_get_virtual_psr_i()		\
+	(!XSI_PSR_I)
+#define xen_set_virtual_psr_i(_val)	\
+	({ XSI_PSR_I = (uint8_t)(_val) ? 0 : 1; })
+#define xen_set_virtual_psr_ic(_val)	\
+	({ XEN_MAPPEDREGS->interrupt_collection_enabled = _val ? 1 : 0; })
+#define xen_get_virtual_pend()		\
+	(*(((uint8_t *)XEN_MAPPEDREGS->interrupt_mask_addr) - 1))
+
+/* Hyperprivops are "break" instructions with a well-defined API.
+ * In particular, the virtual psr.ic bit must be off; in this way
+ * it is guaranteed to never conflict with a linux break instruction.
+ * Normally, this is done in a xen stub but this one is frequent enough
+ * that we inline it */
+#define xen_hyper_ssm_i()						\
+({									\
+	XEN_HYPER_SSM_I;						\
+})
+
+/* turning off interrupts can be paravirtualized simply by writing
+ * to a memory-mapped virtual psr.i bit (implemented as a 16-bit bool) */
+#define xen_rsm_i()							\
+do {									\
+	xen_set_virtual_psr_i(0);					\
+	barrier();							\
+} while (0)
+
+/* turning on interrupts is a bit more complicated.. write to the
+ * memory-mapped virtual psr.i bit first (to avoid race condition),
+ * then if any interrupts were pending, we have to execute a hyperprivop
+ * to ensure the pending interrupt gets delivered; else we're done! */
+#define xen_ssm_i()							\
+do {									\
+	int old = xen_get_virtual_psr_i();				\
+	xen_set_virtual_psr_i(1);					\
+	barrier();							\
+	if (!old && xen_get_virtual_pend())				\
+		xen_hyper_ssm_i();					\
+} while (0)
+
+#define xen_ia64_intrin_local_irq_restore(x)				\
+do {									\
+     if (is_running_on_xen()) {						\
+	     if ((x) & IA64_PSR_I)					\
+		     xen_ssm_i();					\
+	     else							\
+		     xen_rsm_i();					\
+     } else {								\
+	     native_intrin_local_irq_restore((x));			\
+     }									\
+} while (0)
+
+#define	xen_get_psr_i()							\
+({									\
+									\
+	(is_running_on_xen()) ?						\
+		(xen_get_virtual_psr_i() ? IA64_PSR_I : 0)		\
+		: native_get_psr_i()					\
+})
+
+#define xen_ia64_ssm(mask)						\
+do {									\
+	if ((mask) = IA64_PSR_I) {					\
+		if (is_running_on_xen())				\
+			xen_ssm_i(); 					\
+		else							\
+			native_ssm(mask);				\
+	} else {							\
+		native_ssm(mask);					\
+	}								\
+} while (0)
+
+#define xen_ia64_rsm(mask)						\
+do {									\
+	if ((mask) = IA64_PSR_I) {					\
+		if (is_running_on_xen())				\
+			xen_rsm_i(); 					\
+		else							\
+			native_rsm(mask);				\
+	} else {							\
+		native_rsm(mask);					\
+	}								\
+} while (0)
+
+/* Although all privileged operations can be left to trap and will
+ * be properly handled by Xen, some are frequent enough that we use
+ * hyperprivops for performance. */
+
+#ifndef ASM_SUPPORTED
+extern unsigned long xen_get_psr(void);
+extern unsigned long xen_get_ivr(void);
+extern unsigned long xen_get_tpr(void);
+extern void xen_set_itm(unsigned long);
+extern void xen_set_tpr(unsigned long);
+extern void xen_eoi(unsigned long);
+extern void xen_set_rr(unsigned long index, unsigned long val);
+extern unsigned long xen_get_rr(unsigned long index);
+extern void xen_set_kr(unsigned long index, unsigned long val);
+extern void xen_ptcga(unsigned long addr, unsigned long size);
+#else
+static inline unsigned long
+xen_get_psr(void)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	asm volatile ("break %1":
+		      "=r"(ia64_intri_res): "i"(HYPERPRIVOP_GET_PSR));
+	return ia64_intri_res;
+}
+
+static inline unsigned long
+xen_get_ivr(void)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	asm volatile ("break %1":
+		      "=r"(ia64_intri_res): "i"(HYPERPRIVOP_GET_IVR));
+	return ia64_intri_res;
+}
+
+static inline unsigned long
+xen_get_tpr(void)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	asm volatile ("break %1":
+		      "=r"(ia64_intri_res): "i"(HYPERPRIVOP_GET_TPR));
+	return ia64_intri_res;
+}
+
+static inline void
+xen_set_tpr(unsigned long val)
+{
+	register __u64 __val asm ("r8") = val;
+	asm volatile ("break %0"::
+		      "i"(HYPERPRIVOP_GET_TPR), "r"(__val));
+}
+
+static inline void
+xen_eoi(unsigned long val)
+{
+	register __u64 __val asm ("r8") = val;
+	asm volatile ("break %0"::
+		      "i"(HYPERPRIVOP_EOI), "r"(__val));
+}
+
+static inline void
+xen_set_itm(unsigned long val)
+{
+	register __u64 __val asm ("r8") = val;
+	asm volatile ("break %0":: "i"(HYPERPRIVOP_SET_ITM), "r"(__val));
+}
+
+static inline void
+xen_ptcga(unsigned long addr, unsigned long size)
+{
+	register __u64 __addr asm ("r8") = addr;
+	register __u64 __size asm ("r9") = size;
+	asm volatile ("break %0"::
+		      "i"(HYPERPRIVOP_PTC_GA), "r"(__addr), "r"(__size));
+}
+
+static inline unsigned long
+xen_get_rr(unsigned long index)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	register __u64 __index asm ("r8") = index;
+	asm volatile ("break %1":
+		      "=r"(ia64_intri_res):
+		      "i"(HYPERPRIVOP_GET_RR), "0"(__index));
+	return ia64_intri_res;
+}
+
+static inline void
+xen_set_rr(unsigned long index, unsigned long val)
+{
+	register __u64 __index asm ("r8") = index;
+	register __u64 __val asm ("r9") = val;
+	asm volatile ("break %0"::
+		      "i"(HYPERPRIVOP_SET_RR), "r"(__index), "r"(__val));
+}
+
+static inline void
+xen_set_rr0_to_rr4(unsigned long val0, unsigned long val1,
+		   unsigned long val2, unsigned long val3, unsigned long val4)
+{
+	register __u64 __val0 asm ("r8") = val0;
+	register __u64 __val1 asm ("r9") = val1;
+	register __u64 __val2 asm ("r10") = val2;
+	register __u64 __val3 asm ("r11") = val3;
+	register __u64 __val4 asm ("r14") = val4;
+	asm volatile ("break %0" ::
+		      "i"(HYPERPRIVOP_SET_RR0_TO_RR4),
+		      "r"(__val0), "r"(__val1),
+		      "r"(__val2), "r"(__val3), "r"(__val4));
+}
+
+static inline void
+xen_set_kr(unsigned long index, unsigned long val)
+{
+	register __u64 __index asm ("r8") = index;
+	register __u64 __val asm ("r9") = val;
+	asm volatile ("break %0"::
+		      "i"(HYPERPRIVOP_SET_KR), "r"(__index), "r"(__val));
+}
+#endif
+
+/* Note: It may look wrong to test for is_running_on_xen() in each case.
+ * However regnum is always a constant so, as written, the compiler
+ * eliminates the switch statement, whereas is_running_on_xen() must be
+ * tested dynamically. */
+#define xen_ia64_getreg(regnum)						\
+({									\
+	__u64 ia64_intri_res;						\
+									\
+	switch (regnum) {						\
+	case _IA64_REG_PSR:						\
+		ia64_intri_res = (is_running_on_xen()) ?		\
+			xen_get_psr() :					\
+			native_getreg(regnum);				\
+		break;							\
+	case _IA64_REG_CR_IVR:						\
+		ia64_intri_res = (is_running_on_xen()) ?		\
+			xen_get_ivr() :					\
+			native_getreg(regnum);				\
+		break;							\
+	case _IA64_REG_CR_TPR:						\
+		ia64_intri_res = (is_running_on_xen()) ?		\
+			xen_get_tpr() :					\
+			native_getreg(regnum);				\
+		break;							\
+	case _IA64_REG_AR_EFLAG:					\
+		ia64_intri_res = (is_running_on_xen()) ?		\
+			xen_get_eflag() :				\
+			native_getreg(regnum);				\
+		break;							\
+	default:							\
+		ia64_intri_res = native_getreg(regnum);			\
+		break;							\
+	}								\
+	ia64_intri_res;							\
+})
+
+#define xen_ia64_setreg(regnum, val)					\
+({									\
+	switch (regnum) {						\
+	case _IA64_REG_AR_KR0 ... _IA64_REG_AR_KR7:			\
+		(is_running_on_xen()) ?					\
+			xen_set_kr(((regnum)-_IA64_REG_AR_KR0), (val)) :\
+			native_setreg((regnum), (val));			\
+		break;							\
+	case _IA64_REG_CR_ITM:						\
+		(is_running_on_xen()) ?					\
+			xen_set_itm(val) :				\
+			native_setreg((regnum), (val));			\
+		break;							\
+	case _IA64_REG_CR_TPR:						\
+		(is_running_on_xen()) ?					\
+			xen_set_tpr(val) :				\
+			native_setreg((regnum), (val));			\
+		break;							\
+	case _IA64_REG_CR_EOI:						\
+		(is_running_on_xen()) ?					\
+			xen_eoi(val) :					\
+			native_setreg((regnum), (val));			\
+		break;							\
+	case _IA64_REG_AR_EFLAG:					\
+		(is_running_on_xen()) ?					\
+			xen_set_eflag(val) :				\
+			native_setreg((regnum), (val));			\
+		break;							\
+	default:							\
+		native_setreg((regnum), (val));				\
+		break;							\
+	}								\
+})
+
+#if defined(ASM_SUPPORTED) && !defined(CONFIG_PARAVIRT_ALT)
+
+#define IA64_PARAVIRTUALIZED_PRIVOP
+
+#define ia64_fc(addr)							\
+do {									\
+	if (is_running_on_xen())					\
+		xen_fc((unsigned long)(addr));				\
+	else								\
+		native_fc(addr);					\
+} while (0)
+
+#define ia64_thash(addr)						\
+({									\
+	unsigned long ia64_intri_res;					\
+	if (is_running_on_xen())					\
+		ia64_intri_res =					\
+			xen_thash((unsigned long)(addr));		\
+	else								\
+		ia64_intri_res = native_thash(addr);			\
+	ia64_intri_res;							\
+})
+
+#define ia64_get_cpuid(i)						\
+({									\
+	unsigned long ia64_intri_res;					\
+	if (is_running_on_xen())					\
+		ia64_intri_res = xen_get_cpuid(i);			\
+	else								\
+		ia64_intri_res = native_get_cpuid(i);			\
+	ia64_intri_res;							\
+})
+
+#define ia64_get_pmd(i)							\
+({									\
+	unsigned long ia64_intri_res;					\
+	if (is_running_on_xen())					\
+		ia64_intri_res = xen_get_pmd(i);			\
+	else								\
+		ia64_intri_res = native_get_pmd(i);			\
+	ia64_intri_res;							\
+})
+
+
+#define ia64_ptcga(addr, size)						\
+do {									\
+	if (is_running_on_xen())					\
+		xen_ptcga((addr), (size));				\
+	else								\
+		native_ptcga((addr), (size));				\
+} while (0)
+
+#define ia64_set_rr(index, val)						\
+do {									\
+	if (is_running_on_xen())					\
+		xen_set_rr((index), (val));				\
+	else								\
+		native_set_rr((index), (val));				\
+} while (0)
+
+#define ia64_get_rr(index)						\
+({									\
+	__u64 ia64_intri_res;						\
+	if (is_running_on_xen())					\
+		ia64_intri_res = xen_get_rr((index));			\
+	else								\
+		ia64_intri_res = native_get_rr((index));		\
+	ia64_intri_res;							\
+})
+
+#define ia64_set_rr0_to_rr4(val0, val1, val2, val3, val4)		\
+do {									\
+	if (is_running_on_xen())					\
+		xen_set_rr0_to_rr4((val0), (val1), (val2),		\
+				   (val3), (val4));			\
+	else								\
+		native_set_rr0_to_rr4((val0), (val1), (val2),		\
+				      (val3), (val4));			\
+} while (0)
+
+#define ia64_getreg			xen_ia64_getreg
+#define ia64_setreg			xen_ia64_setreg
+#define ia64_ssm			xen_ia64_ssm
+#define ia64_rsm			xen_ia64_rsm
+#define ia64_intrin_local_irq_restore	xen_ia64_intrin_local_irq_restore
+#define ia64_get_psr_i			xen_get_psr_i
+
+/* the remainder of these are not performance-sensitive so its
+ * OK to not paravirtualize and just take a privop trap and emulate */
+#define ia64_hint			native_hint
+#define ia64_set_pmd			native_set_pmd
+#define ia64_itci			native_itci
+#define ia64_itcd			native_itcd
+#define ia64_itri			native_itri
+#define ia64_itrd			native_itrd
+#define ia64_tpa			native_tpa
+#define ia64_set_ibr			native_set_ibr
+#define ia64_set_pkr			native_set_pkr
+#define ia64_set_pmc			native_set_pmc
+#define ia64_get_ibr			native_get_ibr
+#define ia64_get_pkr			native_get_pkr
+#define ia64_get_pmc			native_get_pmc
+#define ia64_ptce			native_ptce
+#define ia64_ptcl			native_ptcl
+#define ia64_ptri			native_ptri
+#define ia64_ptrd			native_ptrd
+
+#endif /* ASM_SUPPORTED && !CONFIG_PARAVIRT_ALT */
+
+#endif /* !__ASSEMBLY__ */
+
+/* these routines utilize privilege-sensitive or performance-sensitive
+ * privileged instructions so the code must be replaced with
+ * paravirtualized versions */
+#ifndef CONFIG_PARAVIRT_ENTRY
+#define IA64_PARAVIRTUALIZED_ENTRY
+#define ia64_switch_to			xen_switch_to
+#define ia64_leave_syscall		xen_leave_syscall
+#define ia64_work_processed_syscall	xen_work_processed_syscall_with_check
+#define ia64_leave_kernel		xen_leave_kernel
+#define ia64_pal_call_static		xen_pal_call_static
+#endif /* !CONFIG_PARAVIRT_ENTRY */
+
+#ifdef CONFIG_XEN
+#ifdef __ASSEMBLY__
+#define BR_IF_NATIVE(target, reg, pred)		\
+	.body ;					\
+	movl reg=running_on_xen;; ;		\
+	ld4 reg=[reg];; ;			\
+	cmp.eq pred,p0=reg,r0 ;			\
+	(pred)	br.cond.sptk.many target;;
+#endif /* __ASSEMBLY__ */
+#endif
+
 #endif /* _ASM_IA64_XEN_PRIVOP_H */
-- 
1.5.3

