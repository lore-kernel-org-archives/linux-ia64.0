From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Mon, 22 Dec 2008 05:51:15 +0000
Subject: [PATCH 5/5] ia64/pv_ops/bp/xen: implemented binary patchable pv_cpu_ops.
Message-Id: <1229925075-31465-6-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1227618235-3890-6-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1227618235-3890-6-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

implemented xen binary patch for pv_cpu_ops.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/xen/privop.h |    4 +
 arch/ia64/xen/hypercall.S          |    2 +
 arch/ia64/xen/xen_pv_ops.c         |  665 ++++++++++++++++++++++++++++++++++++
 3 files changed, 671 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/include/asm/xen/privop.h b/arch/ia64/include/asm/xen/privop.h
index 2261dda..e5fbaee 100644
--- a/arch/ia64/include/asm/xen/privop.h
+++ b/arch/ia64/include/asm/xen/privop.h
@@ -82,8 +82,10 @@ extern unsigned long xen_thash(unsigned long addr);
 extern unsigned long xen_get_cpuid(int index);
 extern unsigned long xen_get_pmd(int index);
 
+#ifndef ASM_SUPPORTED
 extern unsigned long xen_get_eflag(void);	/* see xen_ia64_getreg */
 extern void xen_set_eflag(unsigned long);	/* see xen_ia64_setreg */
+#endif
 
 /************************************************/
 /* Instructions paravirtualized for performance */
@@ -108,6 +110,7 @@ extern void xen_set_eflag(unsigned long);	/* see xen_ia64_setreg */
 #define xen_get_virtual_pend()		\
 	(*(((uint8_t *)XEN_MAPPEDREGS->interrupt_mask_addr) - 1))
 
+#ifndef ASM_SUPPORTED
 /* Although all privileged operations can be left to trap and will
  * be properly handled by Xen, some are frequent enough that we use
  * hyperprivops for performance. */
@@ -125,6 +128,7 @@ extern void xen_set_rr0_to_rr4(unsigned long val0, unsigned long val1,
 			       unsigned long val4);
 extern void xen_set_kr(unsigned long index, unsigned long val);
 extern void xen_ptcga(unsigned long addr, unsigned long size);
+#endif /* !ASM_SUPPORTED */
 
 #endif /* !__ASSEMBLY__ */
 
diff --git a/arch/ia64/xen/hypercall.S b/arch/ia64/xen/hypercall.S
index 45e02bb..e32dae4 100644
--- a/arch/ia64/xen/hypercall.S
+++ b/arch/ia64/xen/hypercall.S
@@ -9,6 +9,7 @@
 #include <asm/intrinsics.h>
 #include <asm/xen/privop.h>
 
+#ifdef __INTEL_COMPILER
 /*
  * Hypercalls without parameter.
  */
@@ -72,6 +73,7 @@ GLOBAL_ENTRY(xen_set_rr0_to_rr4)
 	br.ret.sptk.many rp
 	;;
 END(xen_set_rr0_to_rr4)
+#endif
 
 GLOBAL_ENTRY(xen_send_ipi)
 	mov r14=r32
diff --git a/arch/ia64/xen/xen_pv_ops.c b/arch/ia64/xen/xen_pv_ops.c
index eda13a8..7833226 100644
--- a/arch/ia64/xen/xen_pv_ops.c
+++ b/arch/ia64/xen/xen_pv_ops.c
@@ -154,6 +154,13 @@ xen_post_smp_prepare_boot_cpu(void)
 	xen_setup_vcpu_info_placement();
 }
 
+#ifdef ASM_SUPPORTED
+static unsigned long __init_or_module
+xen_patch_bundle(void *sbundle, void *ebundle, unsigned long type);
+#endif
+static void __init
+xen_patch_branch(unsigned long tag, unsigned long type);
+
 static struct pv_init_ops xen_init_ops __initdata = {
 	.banner = xen_banner,
 
@@ -164,6 +171,10 @@ static struct pv_init_ops xen_init_ops __initdata = {
 	.arch_setup_nomca = xen_arch_setup_nomca,
 
 	.post_smp_prepare_boot_cpu = xen_post_smp_prepare_boot_cpu,
+#ifdef ASM_SUPPORTED
+	.patch_bundle = xen_patch_bundle,
+#endif
+	.patch_branch = xen_patch_branch,
 };
 
 /***************************************************************************
@@ -214,6 +225,7 @@ static struct pv_patchdata xen_patchdata __initdata = {
  * intrinsics hooks.
  */
 
+#ifndef ASM_SUPPORTED
 static void
 xen_set_itm_with_offset(unsigned long val)
 {
@@ -381,6 +393,410 @@ xen_intrin_local_irq_restore(unsigned long mask)
 	else
 		xen_rsm_i();
 }
+#else
+#define __DEFINE_FUNC(name, code)					\
+	extern const char xen_ ## name ## _direct_start[];		\
+	extern const char xen_ ## name ## _direct_end[];		\
+	asm (".align 32\n"						\
+	     ".proc xen_" #name "\n"					\
+	     "xen_" #name ":\n"						\
+	     "xen_" #name "_direct_start:\n"				\
+	     code							\
+	     "xen_" #name "_direct_end:\n"				\
+	     "br.cond.sptk.many b6\n"					\
+	     ".endp xen_" #name "\n")
+
+#define DEFINE_VOID_FUNC0(name, code)		\
+	extern void				\
+	xen_ ## name (void);			\
+	__DEFINE_FUNC(name, code)
+
+#define DEFINE_VOID_FUNC1(name, code)		\
+	extern void				\
+	xen_ ## name (unsigned long arg);	\
+	__DEFINE_FUNC(name, code)
+
+#define DEFINE_VOID_FUNC2(name, code)		\
+	extern void				\
+	xen_ ## name (unsigned long arg0,	\
+		      unsigned long arg1);	\
+	__DEFINE_FUNC(name, code)
+
+#define DEFINE_FUNC0(name, code)		\
+	extern unsigned long			\
+	xen_ ## name (void);			\
+	__DEFINE_FUNC(name, code)
+
+#define DEFINE_FUNC1(name, type, code)		\
+	extern unsigned long			\
+	xen_ ## name (type arg);		\
+	__DEFINE_FUNC(name, code)
+
+#define XEN_PSR_I_ADDR_ADDR     (XSI_BASE + XSI_PSR_I_ADDR_OFS)
+
+/*
+ * static void xen_set_itm_with_offset(unsigned long val)
+ *        xen_set_itm(val - XEN_MAPPEDREGS->itc_offset);
+ */
+/* 2 bundles */
+DEFINE_VOID_FUNC1(set_itm_with_offset,
+		  "mov r2 = " __stringify(XSI_BASE) " + "
+		  __stringify(XSI_ITC_OFFSET_OFS) "\n"
+		  ";;\n"
+		  "ld8 r3 = [r2]\n"
+		  ";;\n"
+		  "sub r8 = r8, r3\n"
+		  "break " __stringify(HYPERPRIVOP_SET_ITM) "\n");
+
+/*
+ * static unsigned long xen_get_itm_with_offset(void)
+ *    return ia64_native_getreg(_IA64_REG_CR_ITM) + XEN_MAPPEDREGS->itc_offset;
+ */
+/* 2 bundles */
+DEFINE_FUNC0(get_itm_with_offset,
+	     "mov r2 = " __stringify(XSI_BASE) " + "
+	     __stringify(XSI_ITC_OFFSET_OFS) "\n"
+	     ";;\n"
+	     "ld8 r3 = [r2]\n"
+	     "mov r8 = cr.itm\n"
+	     ";;\n"
+	     "add r8 = r8, r2\n");
+
+/*
+ * static void xen_set_itc(unsigned long val)
+ *	unsigned long mitc;
+ *
+ *	WARN_ON(!irqs_disabled());
+ *	mitc = ia64_native_getreg(_IA64_REG_AR_ITC);
+ *	XEN_MAPPEDREGS->itc_offset = val - mitc;
+ *	XEN_MAPPEDREGS->itc_last = val;
+ */
+/* 2 bundles */
+DEFINE_VOID_FUNC1(set_itc,
+		  "mov r2 = " __stringify(XSI_BASE) " + "
+		  __stringify(XSI_ITC_LAST_OFS) "\n"
+		  "mov r3 = ar.itc\n"
+		  ";;\n"
+		  "sub r3 = r8, r3\n"
+		  "st8 [r2] = r8, "
+		  __stringify(XSI_ITC_LAST_OFS) " - "
+		  __stringify(XSI_ITC_OFFSET_OFS) "\n"
+		  ";;\n"
+		  "st8 [r2] = r3\n");
+
+/*
+ * static unsigned long xen_get_itc(void)
+ *	unsigned long res;
+ *	unsigned long itc_offset;
+ *	unsigned long itc_last;
+ *	unsigned long ret_itc_last;
+ *
+ *	itc_offset = XEN_MAPPEDREGS->itc_offset;
+ *	do {
+ *		itc_last = XEN_MAPPEDREGS->itc_last;
+ *		res = ia64_native_getreg(_IA64_REG_AR_ITC);
+ *		res += itc_offset;
+ *		if (itc_last >= res)
+ *			res = itc_last + 1;
+ *		ret_itc_last = cmpxchg(&XEN_MAPPEDREGS->itc_last,
+ *				       itc_last, res);
+ *	} while (unlikely(ret_itc_last != itc_last));
+ *	return res;
+ */
+/* 5 bundles */
+DEFINE_FUNC0(get_itc,
+	     "mov r2 = " __stringify(XSI_BASE) " + "
+	     __stringify(XSI_ITC_OFFSET_OFS) "\n"
+	     ";;\n"
+	     "ld8 r9 = [r2], " __stringify(XSI_ITC_LAST_OFS) " - "
+	     __stringify(XSI_ITC_OFFSET_OFS) "\n"
+					/* r9 = itc_offset */
+					/* r2 = XSI_ITC_OFFSET */
+	     "888:\n"
+	     "mov r8 = ar.itc\n"	/* res = ar.itc */
+	     ";;\n"
+	     "ld8 r3 = [r2]\n"		/* r3 = itc_last */
+	     "add r8 = r8, r9\n"	/* res = ar.itc + itc_offset */
+	     ";;\n"
+	     "cmp.gtu p6, p0 = r3, r8\n"
+	     ";;\n"
+	     "(p6) add r8 = 1, r3\n"	/* if (itc_last > res) itc_last + 1 */
+	     ";;\n"
+	     "mov ar.ccv = r8\n"
+	     ";;\n"
+	     "cmpxchg8.acq r10 = [r2], r8, ar.ccv\n"
+	     ";;\n"
+	     "cmp.ne p6, p0 = r10, r3\n"
+	     "(p6) hint @pause\n"
+	     "(p6) br.cond.spnt 888b\n");
+
+DEFINE_VOID_FUNC1(fc,
+		  "break " __stringify(HYPERPRIVOP_FC) "\n");
+
+/*
+ * psr_i_addr_addr = XEN_PSR_I_ADDR_ADDR
+ * masked_addr = *psr_i_addr_addr
+ * pending_intr_addr = masked_addr - 1
+ * if (val & IA64_PSR_I) {
+ *   masked = *masked_addr
+ *   *masked_addr = 0:xen_set_virtual_psr_i(1)
+ *   compiler barrier
+ *   if (masked) {
+ *      uint8_t pending = *pending_intr_addr;
+ *      if (pending)
+ *              XEN_HYPER_SSM_I
+ *   }
+ * } else {
+ *   *masked_addr = 1:xen_set_virtual_psr_i(0)
+ * }
+ */
+/* 6 bundles */
+DEFINE_VOID_FUNC1(intrin_local_irq_restore,
+		  /* r8 = input value: 0 or IA64_PSR_I
+		   * p6 =  (flags & IA64_PSR_I)
+		   *    = if clause
+		   * p7 = !(flags & IA64_PSR_I)
+		   *    = else clause
+		   */
+		  "cmp.ne p6, p7 = r8, r0\n"
+		  "mov r9 = " __stringify(XEN_PSR_I_ADDR_ADDR) "\n"
+		  ";;\n"
+		  /* r9 = XEN_PSR_I_ADDR */
+		  "ld8 r9 = [r9]\n"
+		  ";;\n"
+
+		  /* r10 = masked previous value */
+		  "(p6)	ld1.acq r10 = [r9]\n"
+		  ";;\n"
+
+		  /* p8 = !masked interrupt masked previously? */
+		  "(p6)	cmp.ne.unc p8, p0 = r10, r0\n"
+
+		  /* p7 = else clause */
+		  "(p7)	mov r11 = 1\n"
+		  ";;\n"
+		  /* masked = 1 */
+		  "(p7)	st1.rel [r9] = r11\n"
+
+		  /* p6 = if clause */
+		  /* masked = 0
+		   * r9 = masked_addr - 1
+		   *    = pending_intr_addr
+		   */
+		  "(p8)	st1.rel [r9] = r0, -1\n"
+		  ";;\n"
+		  /* r8 = pending_intr */
+		  "(p8)	ld1.acq r11 = [r9]\n"
+		  ";;\n"
+		  /* p9 = interrupt pending? */
+		  "(p8)	cmp.ne.unc p9, p10 = r11, r0\n"
+		  ";;\n"
+		  "(p10) mf\n"
+		  /* issue hypercall to trigger interrupt */
+		  "(p9)	break " __stringify(HYPERPRIVOP_SSM_I) "\n");
+
+DEFINE_VOID_FUNC2(ptcga,
+		  "break " __stringify(HYPERPRIVOP_PTC_GA) "\n");
+DEFINE_VOID_FUNC2(set_rr,
+		  "break " __stringify(HYPERPRIVOP_SET_RR) "\n");
+
+/*
+ * tmp = XEN_MAPPEDREGS->interrupt_mask_addr = XEN_PSR_I_ADDR_ADDR;
+ * tmp = *tmp
+ * tmp = *tmp;
+ * psr_i = tmp? 0: IA64_PSR_I;
+ */
+/* 4 bundles */
+DEFINE_FUNC0(get_psr_i,
+	     "mov r9 = " __stringify(XEN_PSR_I_ADDR_ADDR) "\n"
+	     ";;\n"
+	     "ld8 r9 = [r9]\n"			/* r9 = XEN_PSR_I_ADDR */
+	     "mov r8 = 0\n"			/* psr_i = 0 */
+	     ";;\n"
+	     "ld1.acq r9 = [r9]\n"		/* r9 = XEN_PSR_I */
+	     ";;\n"
+	     "cmp.eq.unc p6, p0 = r9, r0\n"	/* p6 = (XEN_PSR_I != 0) */
+	     ";;\n"
+	     "(p6) mov r8 = " __stringify(1 << IA64_PSR_I_BIT) "\n");
+
+DEFINE_FUNC1(thash, unsigned long,
+	     "break " __stringify(HYPERPRIVOP_THASH) "\n");
+DEFINE_FUNC1(get_cpuid, int,
+	     "break " __stringify(HYPERPRIVOP_GET_CPUID) "\n");
+DEFINE_FUNC1(get_pmd, int,
+	     "break " __stringify(HYPERPRIVOP_GET_PMD) "\n");
+DEFINE_FUNC1(get_rr, unsigned long,
+	     "break " __stringify(HYPERPRIVOP_GET_RR) "\n");
+
+/*
+ * void xen_privop_ssm_i(void)
+ *
+ * int masked = !xen_get_virtual_psr_i();
+ *	// masked = *(*XEN_MAPPEDREGS->interrupt_mask_addr)
+ * xen_set_virtual_psr_i(1)
+ *	// *(*XEN_MAPPEDREGS->interrupt_mask_addr) = 0
+ * // compiler barrier
+ * if (masked) {
+ *	uint8_t* pend_int_addr + *		(uint8_t*)(*XEN_MAPPEDREGS->interrupt_mask_addr) - 1;
+ *	uint8_t pending = *pend_int_addr;
+ *	if (pending)
+ *		XEN_HYPER_SSM_I
+ * }
+ */
+/* 4 bundles */
+DEFINE_VOID_FUNC0(ssm_i,
+		  "mov r8 = " __stringify(XEN_PSR_I_ADDR_ADDR) "\n"
+		  ";;\n"
+		  "ld8 r8 = [r8]\n"		/* r8 = XEN_PSR_I_ADDR */
+		  ";;\n"
+		  "ld1.acq r9 = [r8]\n"		/* r9 = XEN_PSR_I */
+		  ";;\n"
+		  "st1.rel [r8] = r0, -1\n"	/* psr_i = 0. enable interrupt
+						 * r8 = XEN_PSR_I_ADDR - 1
+						 *    = pend_int_addr
+						 */
+		  "cmp.eq.unc p0, p6 = r9, r0\n"/* p6 = !XEN_PSR_I
+						 * previously interrupt
+						 * masked?
+						 */
+		  ";;\n"
+		  "(p6) ld1.acq r8 = [r8]\n"	/* r8 = xen_pend_int */
+		  ";;\n"
+		  "(p6) cmp.eq.unc p6, p7 = r8, r0\n"	/*interrupt pending?*/
+		  ";;\n"
+		  /* issue hypercall to get interrupt */
+		  "(p7) break " __stringify(HYPERPRIVOP_SSM_I) "\n"
+		  ";;\n");
+
+/*
+ * psr_i_addr_addr = XEN_MAPPEDREGS->interrupt_mask_addr
+ *		   = XEN_PSR_I_ADDR_ADDR;
+ * psr_i_addr = *psr_i_addr_addr;
+ * *psr_i_addr = 1;
+ */
+/* 2 bundles */
+DEFINE_VOID_FUNC0(rsm_i,
+		  "mov r8 = " __stringify(XEN_PSR_I_ADDR_ADDR) "\n"
+						/* r8 = XEN_PSR_I_ADDR */
+		  "mov r9 = 1\n"
+		  ";;\n"
+		  "ld8 r8 = [r8]\n"		/* r8 = XEN_PSR_I */
+		  ";;\n"
+		  "st1.rel [r8] = r9\n");	/* XEN_PSR_I = 1 */
+
+extern void
+xen_set_rr0_to_rr4(unsigned long val0, unsigned long val1,
+		   unsigned long val2, unsigned long val3,
+		   unsigned long val4);
+__DEFINE_FUNC(set_rr0_to_rr4,
+	      "break " __stringify(HYPERPRIVOP_SET_RR0_TO_RR4) "\n");
+
+
+extern unsigned long xen_getreg(int regnum);
+#define __DEFINE_GET_REG(id, privop)					\
+	"mov r2 = " __stringify(_IA64_REG_ ## id) "\n"			\
+	";;\n"								\
+	"cmp.eq p6, p0 = r2, r8\n"					\
+	";;\n"								\
+	"(p6) break " __stringify(HYPERPRIVOP_GET_ ## privop) "\n"	\
+	"(p6) br.cond.sptk.many b6\n"					\
+	";;\n"
+
+__DEFINE_FUNC(getreg,
+	      __DEFINE_GET_REG(PSR, PSR)
+#ifdef CONFIG_IA32_SUPPORT
+	      __DEFINE_GET_REG(AR_EFLAG, EFLAG)
+#endif
+
+	      /* get_itc */
+	      "mov r2 = " __stringify(_IA64_REG_AR_ITC) "\n"
+	      ";;\n"
+	      "cmp.eq p6, p0 = r2, r8\n"
+	      ";;\n"
+	      "(p6) br.cond.spnt xen_get_itc\n"
+	      ";;\n"
+
+	      /* get itm */
+	      "mov r2 = " __stringify(_IA64_REG_CR_ITM) "\n"
+	      ";;\n"
+	      "cmp.eq p6, p0 = r2, r8\n"
+	      ";;\n"
+	      "(p6) br.cond.spnt xen_get_itm_with_offset\n"
+	      ";;\n"
+
+	      __DEFINE_GET_REG(CR_IVR, IVR)
+	      __DEFINE_GET_REG(CR_TPR, TPR)
+
+	      /* fall back */
+	      "movl r2 = ia64_native_getreg_func\n"
+	      ";;\n"
+	      "mov b7 = r2\n"
+	      ";;\n"
+	      "br.cond.sptk.many b7\n");
+
+extern void xen_setreg(int regnum, unsigned long val);
+#define __DEFINE_SET_REG(id, privop)					\
+	"mov r2 = " __stringify(_IA64_REG_ ## id) "\n"			\
+	";;\n"								\
+	"cmp.eq p6, p0 = r2, r9\n"					\
+	";;\n"								\
+	"(p6) break " __stringify(HYPERPRIVOP_ ## privop) "\n"		\
+	"(p6) br.cond.sptk.many b6\n"					\
+	";;\n"
+
+__DEFINE_FUNC(setreg,
+	      /* kr0 .. kr 7*/
+	      /*
+	       * if (_IA64_REG_AR_KR0 <= regnum &&
+	       *     regnum <= _IA64_REG_AR_KR7) {
+	       *     register __index asm ("r8") = regnum - _IA64_REG_AR_KR0
+	       *     register __val asm ("r9") = val
+	       *    "break HYPERPRIVOP_SET_KR"
+	       * }
+	       */
+	      "mov r17 = r9\n"
+	      "mov r2 = " __stringify(_IA64_REG_AR_KR0) "\n"
+	      ";;\n"
+	      "cmp.ge p6, p0 = r9, r2\n"
+	      "sub r17 = r17, r2\n"
+	      ";;\n"
+	      "(p6) cmp.ge.unc p7, p0 = "
+	      __stringify(_IA64_REG_AR_KR7) " - " __stringify(_IA64_REG_AR_KR0)
+	      ", r17\n"
+	      ";;\n"
+	      "(p7) mov r9 = r8\n"
+	      ";;\n"
+	      "(p7) mov r8 = r17\n"
+	      "(p7) break " __stringify(HYPERPRIVOP_SET_KR) "\n"
+
+	      /* set itm */
+	      "mov r2 = " __stringify(_IA64_REG_CR_ITM) "\n"
+	      ";;\n"
+	      "cmp.eq p6, p0 = r2, r8\n"
+	      ";;\n"
+	      "(p6) br.cond.spnt xen_set_itm_with_offset\n"
+
+	      /* set itc */
+	      "mov r2 = " __stringify(_IA64_REG_AR_ITC) "\n"
+	      ";;\n"
+	      "cmp.eq p6, p0 = r2, r8\n"
+	      ";;\n"
+	      "(p6) br.cond.spnt xen_set_itc\n"
+
+#ifdef CONFIG_IA32_SUPPORT
+	      __DEFINE_SET_REG(AR_EFLAG, SET_EFLAG)
+#endif
+	      __DEFINE_SET_REG(CR_TPR, SET_TPR)
+	      __DEFINE_SET_REG(CR_EOI, EOI)
+
+	      /* fall back */
+	      "movl r2 = ia64_native_setreg_func\n"
+	      ";;\n"
+	      "mov b7 = r2\n"
+	      ";;\n"
+	      "br.cond.sptk.many b7\n");
+#endif
 
 static struct pv_cpu_ops xen_cpu_ops __initdata = {
 	.fc		= xen_fc,
@@ -486,3 +902,252 @@ xen_setup_pv_ops(void)
 
 	paravirt_cpu_asm_init(&xen_cpu_asm_switch);
 }
+
+#ifdef ASM_SUPPORTED
+/***************************************************************************
+ * binary pacthing
+ * pv_init_ops.patch_bundle
+ */
+
+#define DEFINE_FUNC_GETREG(name, privop)				\
+	DEFINE_FUNC0(get_ ## name,					\
+		     "break "__stringify(HYPERPRIVOP_GET_ ## privop) "\n")
+
+DEFINE_FUNC_GETREG(psr, PSR);
+DEFINE_FUNC_GETREG(eflag, EFLAG);
+DEFINE_FUNC_GETREG(ivr, IVR);
+DEFINE_FUNC_GETREG(tpr, TPR);
+
+#define DEFINE_FUNC_SET_KR(n)						\
+	DEFINE_VOID_FUNC0(set_kr ## n,					\
+			  ";;\n"					\
+			  "mov r9 = r8\n"				\
+			  "mov r8 = " #n "\n"				\
+			  "break " __stringify(HYPERPRIVOP_SET_KR) "\n")
+
+DEFINE_FUNC_SET_KR(0);
+DEFINE_FUNC_SET_KR(1);
+DEFINE_FUNC_SET_KR(2);
+DEFINE_FUNC_SET_KR(3);
+DEFINE_FUNC_SET_KR(4);
+DEFINE_FUNC_SET_KR(5);
+DEFINE_FUNC_SET_KR(6);
+DEFINE_FUNC_SET_KR(7);
+
+#define __DEFINE_FUNC_SETREG(name, privop)				\
+	DEFINE_VOID_FUNC0(name,						\
+			  "break "__stringify(HYPERPRIVOP_ ## privop) "\n")
+
+#define DEFINE_FUNC_SETREG(name, privop)			\
+	__DEFINE_FUNC_SETREG(set_ ## name, SET_ ## privop)
+
+DEFINE_FUNC_SETREG(eflag, EFLAG);
+DEFINE_FUNC_SETREG(tpr, TPR);
+__DEFINE_FUNC_SETREG(eoi, EOI);
+
+extern const char xen_check_events[];
+extern const char __xen_intrin_local_irq_restore_direct_start[];
+extern const char __xen_intrin_local_irq_restore_direct_end[];
+extern const unsigned long __xen_intrin_local_irq_restore_direct_reloc;
+
+asm (
+	".align 32\n"
+	".proc xen_check_events\n"
+	"xen_check_events:\n"
+	/* masked = 0
+	 * r9 = masked_addr - 1
+	 *    = pending_intr_addr
+	 */
+	"st1.rel [r9] = r0, -1\n"
+	";;\n"
+	/* r8 = pending_intr */
+	"ld1.acq r11 = [r9]\n"
+	";;\n"
+	/* p9 = interrupt pending? */
+	"cmp.ne p9, p10 = r11, r0\n"
+	";;\n"
+	"(p10) mf\n"
+	/* issue hypercall to trigger interrupt */
+	"(p9) break " __stringify(HYPERPRIVOP_SSM_I) "\n"
+	"br.cond.sptk.many b6\n"
+	".endp xen_check_events\n"
+	"\n"
+	".align 32\n"
+	".proc __xen_intrin_local_irq_restore_direct\n"
+	"__xen_intrin_local_irq_restore_direct:\n"
+	"__xen_intrin_local_irq_restore_direct_start:\n"
+	"1:\n"
+	"{\n"
+	"cmp.ne p6, p7 = r8, r0\n"
+	"mov r17 = ip\n" /* get ip to calc return address */
+	"mov r9 = "__stringify(XEN_PSR_I_ADDR_ADDR) "\n"
+	";;\n"
+	"}\n"
+	"{\n"
+	/* r9 = XEN_PSR_I_ADDR */
+	"ld8 r9 = [r9]\n"
+	";;\n"
+	/* r10 = masked previous value */
+	"(p6) ld1.acq r10 = [r9]\n"
+	"adds r17 =  1f - 1b, r17\n" /* calculate return address */
+	";;\n"
+	"}\n"
+	"{\n"
+	/* p8 = !masked interrupt masked previously? */
+	"(p6) cmp.ne.unc p8, p0 = r10, r0\n"
+	"\n"
+	/* p7 = else clause */
+	"(p7) mov r11 = 1\n"
+	";;\n"
+	"(p8) mov b6 = r17\n" /* set return address */
+	"}\n"
+	"{\n"
+	/* masked = 1 */
+	"(p7) st1.rel [r9] = r11\n"
+	"\n"
+	"[99:]\n"
+	"(p8) brl.cond.dptk.few xen_check_events\n"
+	"}\n"
+	/* pv calling stub is 5 bundles. fill nop to adjust return address */
+	"{\n"
+	"nop 0\n"
+	"nop 0\n"
+	"nop 0\n"
+	"}\n"
+	"1:\n"
+	"__xen_intrin_local_irq_restore_direct_end:\n"
+	".endp __xen_intrin_local_irq_restore_direct\n"
+	"\n"
+	".align 8\n"
+	"__xen_intrin_local_irq_restore_direct_reloc:\n"
+	"data8 99b\n"
+);
+
+static struct paravirt_patch_bundle_elem xen_patch_bundle_elems[]
+__initdata_or_module +{
+#define XEN_PATCH_BUNDLE_ELEM(name, type)		\
+	{						\
+		(void*)xen_ ## name ## _direct_start,	\
+		(void*)xen_ ## name ## _direct_end,	\
+		PARAVIRT_PATCH_TYPE_ ## type,		\
+	}
+
+	XEN_PATCH_BUNDLE_ELEM(fc, FC),
+	XEN_PATCH_BUNDLE_ELEM(thash, THASH),
+	XEN_PATCH_BUNDLE_ELEM(get_cpuid, GET_CPUID),
+	XEN_PATCH_BUNDLE_ELEM(get_pmd, GET_PMD),
+	XEN_PATCH_BUNDLE_ELEM(ptcga, PTCGA),
+	XEN_PATCH_BUNDLE_ELEM(get_rr, GET_RR),
+	XEN_PATCH_BUNDLE_ELEM(set_rr, SET_RR),
+	XEN_PATCH_BUNDLE_ELEM(set_rr0_to_rr4, SET_RR0_TO_RR4),
+	XEN_PATCH_BUNDLE_ELEM(ssm_i, SSM_I),
+	XEN_PATCH_BUNDLE_ELEM(rsm_i, RSM_I),
+	XEN_PATCH_BUNDLE_ELEM(get_psr_i, GET_PSR_I),
+	{
+		(void*)__xen_intrin_local_irq_restore_direct_start,
+		(void*)__xen_intrin_local_irq_restore_direct_end,
+		PARAVIRT_PATCH_TYPE_INTRIN_LOCAL_IRQ_RESTORE,
+	},
+
+#define XEN_PATCH_BUNDLE_ELEM_GETREG(name, reg)			\
+	{							\
+		xen_get_ ## name ## _direct_start,		\
+		xen_get_ ## name ## _direct_end,		\
+		PARAVIRT_PATCH_TYPE_GETREG + _IA64_REG_ ## reg, \
+	}
+
+	XEN_PATCH_BUNDLE_ELEM_GETREG(psr, PSR),
+	XEN_PATCH_BUNDLE_ELEM_GETREG(eflag, AR_EFLAG),
+
+	XEN_PATCH_BUNDLE_ELEM_GETREG(ivr, CR_IVR),
+	XEN_PATCH_BUNDLE_ELEM_GETREG(tpr, CR_TPR),
+
+	XEN_PATCH_BUNDLE_ELEM_GETREG(itc, AR_ITC),
+	XEN_PATCH_BUNDLE_ELEM_GETREG(itm_with_offset, CR_ITM),
+
+
+#define __XEN_PATCH_BUNDLE_ELEM_SETREG(name, reg)		\
+	{							\
+		xen_ ## name ## _direct_start,			\
+		xen_ ## name ## _direct_end,			\
+		PARAVIRT_PATCH_TYPE_SETREG + _IA64_REG_ ## reg, \
+	}
+
+#define XEN_PATCH_BUNDLE_ELEM_SETREG(name, reg)			\
+	__XEN_PATCH_BUNDLE_ELEM_SETREG(set_ ## name, reg)
+
+	XEN_PATCH_BUNDLE_ELEM_SETREG(kr0, AR_KR0),
+	XEN_PATCH_BUNDLE_ELEM_SETREG(kr1, AR_KR1),
+	XEN_PATCH_BUNDLE_ELEM_SETREG(kr2, AR_KR2),
+	XEN_PATCH_BUNDLE_ELEM_SETREG(kr3, AR_KR3),
+	XEN_PATCH_BUNDLE_ELEM_SETREG(kr4, AR_KR4),
+	XEN_PATCH_BUNDLE_ELEM_SETREG(kr5, AR_KR5),
+	XEN_PATCH_BUNDLE_ELEM_SETREG(kr6, AR_KR6),
+	XEN_PATCH_BUNDLE_ELEM_SETREG(kr7, AR_KR7),
+
+	XEN_PATCH_BUNDLE_ELEM_SETREG(eflag, AR_EFLAG),
+	XEN_PATCH_BUNDLE_ELEM_SETREG(tpr, CR_TPR),
+	__XEN_PATCH_BUNDLE_ELEM_SETREG(eoi, CR_EOI),
+
+	XEN_PATCH_BUNDLE_ELEM_SETREG(itc, AR_ITC),
+	XEN_PATCH_BUNDLE_ELEM_SETREG(itm_with_offset, CR_ITM),
+};
+
+static unsigned long __init_or_module
+xen_patch_bundle(void *sbundle, void *ebundle, unsigned long type)
+{
+	const unsigned long nelems = sizeof(xen_patch_bundle_elems) /
+		sizeof(xen_patch_bundle_elems[0]);
+	unsigned long used;
+	const struct paravirt_patch_bundle_elem *found;
+
+	used = __paravirt_patch_apply_bundle(sbundle, ebundle, type,
+					     xen_patch_bundle_elems, nelems,
+					     &found);
+
+	if (found = NULL)
+		/* fallback */
+		return ia64_native_patch_bundle(sbundle, ebundle, type);
+	if (used = 0)
+		return used;
+
+	/* relocation */
+	switch (type) {
+	case PARAVIRT_PATCH_TYPE_INTRIN_LOCAL_IRQ_RESTORE: {
+		unsigned long reloc +			__xen_intrin_local_irq_restore_direct_reloc;
+		unsigned long reloc_offset = reloc - (unsigned long)
+			__xen_intrin_local_irq_restore_direct_start;
+		unsigned long tag = (unsigned long)sbundle + reloc_offset;
+		paravirt_patch_reloc_brl(tag, xen_check_events);
+		break;
+	}
+	default:
+		/* nothing */
+		break;
+	}
+	return used;
+}
+#endif /* ASM_SUPPOTED */
+
+const struct paravirt_patch_branch_target xen_branch_target[]
+__initconst = {
+#define PARAVIRT_BR_TARGET(name, type)			\
+	{						\
+		&xen_ ## name,				\
+		PARAVIRT_PATCH_TYPE_BR_ ## type,	\
+	}
+	PARAVIRT_BR_TARGET(switch_to, SWITCH_TO),
+	PARAVIRT_BR_TARGET(leave_syscall, LEAVE_SYSCALL),
+	PARAVIRT_BR_TARGET(work_processed_syscall, WORK_PROCESSED_SYSCALL),
+	PARAVIRT_BR_TARGET(leave_kernel, LEAVE_KERNEL),
+};
+
+static void __init
+xen_patch_branch(unsigned long tag, unsigned long type)
+{
+	const unsigned long nelem +		sizeof(xen_branch_target) / sizeof(xen_branch_target[0]);
+	__paravirt_patch_apply_branch(tag, type, xen_branch_target, nelem);
+}
-- 
1.6.0.2

